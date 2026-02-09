import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xl;
import 'package:hive/hive.dart';

/// Service to parse, store, and aggregate imported financial data (CSV/Excel).
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

  // ─── Persistence ──────────────────────────────────────────────────

  /// Save an import session to Hive (with full data for history replay).
  static Future<void> saveImport({
    required String userId,
    required String fileName,
    required List<List<dynamic>> data,
    required String taxType,
    Map<int, String>? columnMappings,
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
