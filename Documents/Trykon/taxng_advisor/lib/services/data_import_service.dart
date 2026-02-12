import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as spdf;

/// Tax classification for imported rows.
enum TaxStatus {
  taxableIncome,
  fullyDeductible,
  halfDeductible,
  nonDeductible,
  businessApply,
  unclassified,
}

/// Service to parse, store, and aggregate imported financial data (CSV/Excel/PDF).
class DataImportService {
  static const String _boxName = 'imported_data';

  // ─── Parsing ───────────────────────────────────────────────────────

  /// Parse raw CSV text into a list of rows (List<List<dynamic>>).
  static List<List<dynamic>> parseCsv(String csvText) {
    const converter = CsvToListConverter(eol: '\n', shouldParseNumbers: true);
    final rows = converter.convert(csvText.trim());
    return rows;
  }

  /// Parse Excel (.xlsx) bytes into a list of rows (List<List<dynamic>>).
  /// Uses the first sheet by default, or a specific [sheetName].
  static List<List<dynamic>> parseExcel(Uint8List bytes, {String? sheetName}) {
    final excel = xl.Excel.decodeBytes(bytes);

    // Pick the requested sheet or the first one
    final sheet = sheetName != null
        ? excel.tables[sheetName]
        : excel.tables[excel.tables.keys.first];

    if (sheet == null || sheet.rows.isEmpty) return [];

    final rows = <List<dynamic>>[];
    for (final row in sheet.rows) {
      rows.add(row.map((cell) {
        if (cell == null) return '';
        final v = cell.value;
        if (v is xl.TextCellValue) return v.value;
        if (v is xl.IntCellValue) return v.value;
        if (v is xl.DoubleCellValue) return v.value;
        if (v is xl.BoolCellValue) return v.value;
        if (v is xl.DateCellValue) {
          return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
        }
        if (v is xl.DateTimeCellValue) {
          return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
        }
        if (v is xl.TimeCellValue) return v.toString();
        if (v is xl.FormulaCellValue) return v.formula;
        return v?.toString() ?? '';
      }).toList());
    }
    return rows;
  }

  /// Get sheet names from an Excel file.
  static List<String> getExcelSheetNames(Uint8List bytes) {
    final excel = xl.Excel.decodeBytes(bytes);
    return excel.tables.keys.toList();
  }

  // ─── PDF Parsing ──────────────────────────────────────────────────

  /// Extract tabular text from a PDF file and return as rows/columns.
  /// Works with text-based PDFs (digital bank statements, invoices).
  /// Scanned/image PDFs will return minimal or no data.
  static List<List<dynamic>> parsePdf(Uint8List bytes) {
    try {
      final document = spdf.PdfDocument(inputBytes: bytes);
      final allRows = <List<dynamic>>[];

      for (var i = 0; i < document.pages.count; i++) {
        final text = spdf.PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i);

        if (text.trim().isEmpty) continue;

        final lines = text
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

        for (final line in lines) {
          // Split on 2+ spaces or tab — typical for PDF tabular data
          final cells = line
              .split(RegExp(r'\s{2,}|\t'))
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList();

          if (cells.length >= 2) {
            // Try to convert numeric-looking cells to numbers
            final parsed = cells.map<dynamic>((c) {
              final cleaned = c.replaceAll(',', '').replaceAll(' ', '');
              final num = double.tryParse(cleaned);
              return num ?? c;
            }).toList();
            allRows.add(parsed);
          }
        }
      }

      document.dispose();

      if (allRows.isEmpty) return [];

      // Normalise column count to the most frequent width
      final widthCounts = <int, int>{};
      for (final row in allRows) {
        widthCounts[row.length] = (widthCounts[row.length] ?? 0) + 1;
      }
      final targetWidth =
          widthCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

      final normalised = <List<dynamic>>[];
      for (final row in allRows) {
        if (row.length == targetWidth) {
          normalised.add(row);
        } else if (row.length > targetWidth) {
          normalised.add(row.sublist(0, targetWidth));
        }
        // Skip rows that are too short (likely headers/footers)
      }

      // If the first row looks like a header (mostly text), keep it;
      // otherwise generate synthetic headers
      if (normalised.isNotEmpty) {
        final firstRow = normalised.first;
        final textCount = firstRow
            .where((c) =>
                c is String &&
                double.tryParse(c.toString().replaceAll(',', '')) == null)
            .length;
        if (textCount < firstRow.length * 0.5) {
          // Add synthetic headers
          final headers = List.generate(
              targetWidth, (i) => 'Column ${String.fromCharCode(65 + i)}');
          normalised.insert(0, headers);
        }
      }

      return normalised;
    } catch (e) {
      debugPrint('PDF parse error: $e');
      return [];
    }
  }

  /// Check if a PDF has extractable text (not just scanned images).
  static bool isPdfTextBased(Uint8List bytes) {
    try {
      final document = spdf.PdfDocument(inputBytes: bytes);
      final text = spdf.PdfTextExtractor(document)
          .extractText(startPageIndex: 0, endPageIndex: 0);
      document.dispose();
      return text.trim().length > 20;
    } catch (_) {
      return false;
    }
  }

  /// Detect which columns look like monetary amounts.
  /// Returns column indices that contain mostly numeric values.
  static List<int> detectAmountColumns(List<List<dynamic>> rows) {
    if (rows.length < 2) return [];
    final headers = rows.first;
    final dataRows = rows.sublist(1);
    final amountCols = <int>[];

    for (var col = 0; col < headers.length; col++) {
      int numericCount = 0;
      for (final row in dataRows) {
        if (col < row.length) {
          final val = row[col];
          if (val is num || (val is String && _isNumericString(val))) {
            numericCount++;
          }
        }
      }
      // If >60% of values are numeric, consider it an amount column
      if (dataRows.isNotEmpty && numericCount / dataRows.length > 0.6) {
        amountCols.add(col);
      }
    }
    return amountCols;
  }

  /// Detect which column is the description/narration column.
  static int? detectDescriptionColumn(List<List<dynamic>> rows) {
    if (rows.isEmpty) return null;
    final headers = rows.first;
    final keywords = [
      'description',
      'narration',
      'details',
      'memo',
      'particulars',
      'remarks'
    ];
    for (var i = 0; i < headers.length; i++) {
      final h = headers[i].toString().toLowerCase().trim();
      if (keywords.any((k) => h.contains(k))) return i;
    }
    return null;
  }

  /// Detect date column.
  static int? detectDateColumn(List<List<dynamic>> rows) {
    if (rows.isEmpty) return null;
    final headers = rows.first;
    final keywords = [
      'date',
      'txn date',
      'transaction date',
      'value date',
      'post date'
    ];
    for (var i = 0; i < headers.length; i++) {
      final h = headers[i].toString().toLowerCase().trim();
      if (keywords.any((k) => h.contains(k))) return i;
    }
    return null;
  }

  // ─── Aggregation ──────────────────────────────────────────────────

  /// Calculate summary statistics for a specific column.
  static Map<String, dynamic> aggregateColumn(
      List<List<dynamic>> rows, int colIndex) {
    if (rows.length < 2) {
      return {'sum': 0.0, 'count': 0, 'min': 0.0, 'max': 0.0, 'avg': 0.0};
    }
    final dataRows = rows.sublist(1);
    final values = <double>[];

    for (final row in dataRows) {
      if (colIndex < row.length) {
        final parsed = _toDouble(row[colIndex]);
        if (parsed != null) values.add(parsed);
      }
    }

    if (values.isEmpty) {
      return {'sum': 0.0, 'count': 0, 'min': 0.0, 'max': 0.0, 'avg': 0.0};
    }

    final sum = values.fold<double>(0, (s, v) => s + v);
    values.sort();
    return {
      'sum': sum,
      'count': values.length,
      'min': values.first,
      'max': values.last,
      'avg': sum / values.length,
    };
  }

  /// Categorise rows by a text column and sum amounts per category.
  static Map<String, double> groupByAndSum(
      List<List<dynamic>> rows, int groupCol, int sumCol) {
    if (rows.length < 2) return {};
    final dataRows = rows.sublist(1);
    final result = <String, double>{};

    for (final row in dataRows) {
      if (groupCol < row.length && sumCol < row.length) {
        final key = row[groupCol].toString().trim();
        final val = _toDouble(row[sumCol]) ?? 0;
        result[key] = (result[key] ?? 0) + val;
      }
    }
    return result;
  }

  // ─── Tax-Specific Helpers ─────────────────────────────────────────

  /// Calculate VAT-relevant totals from imported data.
  static Map<String, double> calculateVatTotals(
      List<List<dynamic>> rows, int amountCol) {
    final agg = aggregateColumn(rows, amountCol);
    final totalAmount = agg['sum'] as double;
    const vatRate = 0.075;
    return {
      'totalAmount': totalAmount,
      'vatAmount': totalAmount * vatRate,
      'netAmount': totalAmount * (1 - vatRate),
    };
  }

  /// Calculate WHT-relevant totals.
  static Map<String, double> calculateWhtTotals(
      List<List<dynamic>> rows, int amountCol,
      {double rate = 0.10}) {
    final agg = aggregateColumn(rows, amountCol);
    final totalAmount = agg['sum'] as double;
    return {
      'totalAmount': totalAmount,
      'whtAmount': totalAmount * rate,
      'netPayable': totalAmount * (1 - rate),
    };
  }

  // ─── Deduction Classification ─────────────────────────────────────

  /// Classify a row's tax status based on a status column value.
  static TaxStatus classifyTaxStatus(String statusText) {
    final lower = statusText.toLowerCase().trim();

    if (lower.contains('taxable income') || lower.contains('taxable')) {
      return TaxStatus.taxableIncome;
    }
    if (lower.contains('non-deductible') || lower.contains('non deductible')) {
      return TaxStatus.nonDeductible;
    }
    if (lower.contains('50% deductible') || lower.contains('half deductible')) {
      return TaxStatus.halfDeductible;
    }
    if (lower.contains('deductible expense') ||
        lower.contains('fully deductible') ||
        lower.contains('deductible')) {
      return TaxStatus.fullyDeductible;
    }
    if (lower.contains('business') && lower.contains('apply')) {
      return TaxStatus.businessApply;
    }
    return TaxStatus.unclassified;
  }

  /// Detect which column contains tax status / classification labels.
  static int? detectTaxStatusColumn(List<List<dynamic>> rows) {
    if (rows.isEmpty) return null;
    final headers = rows.first;
    final keywords = [
      'status',
      'tax status',
      'classification',
      'category',
      'type',
      'tax type',
      'deduction',
    ];
    for (var i = 0; i < headers.length; i++) {
      final h = headers[i].toString().toLowerCase().trim();
      if (keywords.any((k) => h.contains(k))) return i;
    }
    return null;
  }

  /// Calculate deduction-aware totals for PIT/CIT.
  /// Uses a tax-status column to classify each row and aggregate
  /// gross income, total deductions, and net taxable amount.
  static Map<String, double> calculateDeductionTotals(
    List<List<dynamic>> rows,
    int amountCol, {
    int? statusCol,
    double businessUsePercent = 1.0,
  }) {
    if (rows.length < 2) {
      return {
        'grossIncome': 0,
        'fullyDeductible': 0,
        'halfDeductible': 0,
        'nonDeductible': 0,
        'businessDeductible': 0,
        'totalDeductions': 0,
        'taxableAmount': 0,
        'rowCount': 0,
      };
    }

    final dataRows = rows.sublist(1);
    double grossIncome = 0;
    double fullyDeductible = 0;
    double halfDeductible = 0;
    double nonDeductible = 0;
    double businessDeductible = 0;
    int classifiedRows = 0;

    for (final row in dataRows) {
      if (amountCol >= row.length) continue;
      final amount = _toDouble(row[amountCol]);
      if (amount == null) continue;

      if (statusCol != null && statusCol < row.length) {
        final status = classifyTaxStatus(row[statusCol].toString());
        classifiedRows++;

        switch (status) {
          case TaxStatus.taxableIncome:
            grossIncome += amount.abs();
          case TaxStatus.fullyDeductible:
            fullyDeductible += amount.abs();
          case TaxStatus.halfDeductible:
            halfDeductible += amount.abs() * 0.5;
          case TaxStatus.nonDeductible:
            nonDeductible += amount.abs();
          case TaxStatus.businessApply:
            businessDeductible += amount.abs() * businessUsePercent;
          case TaxStatus.unclassified:
            // Positive = income, negative = expense by convention
            if (amount >= 0) {
              grossIncome += amount;
            } else {
              fullyDeductible += amount.abs();
            }
        }
      } else {
        // No status column: positive = income, negative = expense
        if (amount >= 0) {
          grossIncome += amount;
        } else {
          fullyDeductible += amount.abs();
        }
      }
    }

    final totalDeductions =
        fullyDeductible + halfDeductible + businessDeductible;
    final taxableAmount = grossIncome - totalDeductions;

    return {
      'grossIncome': grossIncome,
      'fullyDeductible': fullyDeductible,
      'halfDeductible': halfDeductible,
      'nonDeductible': nonDeductible,
      'businessDeductible': businessDeductible,
      'totalDeductions': totalDeductions,
      'taxableAmount': taxableAmount < 0 ? 0 : taxableAmount,
      'rowCount': classifiedRows.toDouble(),
    };
  }

  // ─── Persistence ──────────────────────────────────────────────────

  /// Save an import session to Hive (with full data for history replay).
  static Future<void> saveImport({
    required String userId,
    required String fileName,
    required List<List<dynamic>> data,
    required String taxType,
    Map<int, String>? columnMappings,
    Map<String, double>? taxTotals,
    Map<String, dynamic>? aggregation,
  }) async {
    final box = await Hive.openBox(_boxName);
    final imports = List<Map<String, dynamic>>.from(
      box.get('imports_$userId', defaultValue: []),
    );
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    imports.add({
      'id': id,
      'fileName': fileName,
      'rowCount': data.length - 1,
      'colCount': data.isNotEmpty ? data.first.length : 0,
      'taxType': taxType,
      'importedAt': DateTime.now().toIso8601String(),
      'headers':
          data.isNotEmpty ? data.first.map((e) => e.toString()).toList() : [],
      'columnMappings': columnMappings?.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'taxTotals': taxTotals?.map((k, v) => MapEntry(k, v)),
      'aggregation': aggregation,
    });
    await box.put('imports_$userId', imports);

    // Also save the raw data for this import
    final serialisedData =
        data.map((row) => row.map((cell) => cell.toString()).toList()).toList();
    await box.put('import_data_$id', serialisedData);
  }

  /// Get all past imports for a user.
  static Future<List<Map<String, dynamic>>> getImports(String userId) async {
    final box = await Hive.openBox(_boxName);
    return List<Map<String, dynamic>>.from(
      box.get('imports_$userId', defaultValue: []),
    );
  }

  /// Get the raw data for a specific import.
  static Future<List<List<dynamic>>?> getImportData(String importId) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('import_data_$importId');
    if (raw == null) return null;
    final rows = <List<dynamic>>[];
    for (final row in (raw as List)) {
      rows.add(List<dynamic>.from(row));
    }
    // Try to convert numeric strings back to numbers
    if (rows.length > 1) {
      for (var i = 1; i < rows.length; i++) {
        for (var j = 0; j < rows[i].length; j++) {
          final cell = rows[i][j];
          if (cell is String) {
            final n = double.tryParse(cell.replaceAll(',', ''));
            if (n != null) rows[i][j] = n;
          }
        }
      }
    }
    return rows;
  }

  /// Delete an import record and its data.
  static Future<void> deleteImport(String userId, String importId) async {
    final box = await Hive.openBox(_boxName);
    final imports = List<Map<String, dynamic>>.from(
      box.get('imports_$userId', defaultValue: []),
    );
    imports.removeWhere((i) => i['id'] == importId);
    await box.put('imports_$userId', imports);
    await box.delete('import_data_$importId');
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  static bool _isNumericString(String s) {
    final cleaned = s.replaceAll(',', '').replaceAll(' ', '').trim();
    return double.tryParse(cleaned) != null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').replaceAll(' ', '').trim();
      return double.tryParse(cleaned);
    }
    return null;
  }
}
