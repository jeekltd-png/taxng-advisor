import 'dart:io' if (dart.library.html) 'export_service_stub.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:taxng_advisor/services/tax_analytics_service.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:intl/intl.dart';

/// Export Service - Handles CSV and PDF exports
class ExportService {
  /// Export calculations to CSV
  static Future<String> exportToCSV({
    List<TaxCalculationItem>? calculations,
    String? fileName,
  }) async {
    calculations ??= TaxAnalyticsService.getRecentCalculations(limit: 1000);

    if (calculations.isEmpty) {
      throw Exception('No calculations to export');
    }

    // Prepare CSV data
    List<List<dynamic>> rows = [
      ['Date', 'Tax Type', 'Description', 'Amount', 'Currency']
    ];

    for (var calc in calculations) {
      rows.add([
        DateFormat('yyyy-MM-dd HH:mm').format(calc.date),
        calc.type,
        calc.description,
        calc.amount.toStringAsFixed(2),
        'NGN',
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    fileName ??=
        'tax_calculations_${DateTime.now().millisecondsSinceEpoch}.csv';
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  /// Export calculations to Excel-compatible CSV
  /// Note: For true Excel format (.xlsx), a premium library would be needed.
  /// This exports as CSV which can be opened in Excel.
  static Future<String> exportToExcel({
    List<TaxCalculationItem>? calculations,
    String? fileName,
  }) async {
    // Use CSV format which Excel can open
    fileName ??=
        'tax_calculations_${DateTime.now().millisecondsSinceEpoch}.csv';
    return exportToCSV(calculations: calculations, fileName: fileName);
  }

  /// Export calculations to PDF
  static Future<String> exportToPDF({
    List<TaxCalculationItem>? calculations,
    String? fileName,
    String? reportTitle,
  }) async {
    calculations ??= TaxAnalyticsService.getRecentCalculations(limit: 1000);

    if (calculations.isEmpty) {
      throw Exception('No calculations to export');
    }

    final pdf = pw.Document();

    // Calculate totals
    final totalAmount =
        calculations.fold<double>(0, (sum, calc) => sum + calc.amount);
    final breakdown = <String, double>{};
    for (var calc in calculations) {
      breakdown[calc.type] = (breakdown[calc.type] ?? 0) + calc.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                reportTitle ?? 'Tax Calculations Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated: ${DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Summary section
            pw.Text(
              'Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Total Calculations: ${calculations?.length ?? 0}',
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(
                      'Total Amount: ${CurrencyFormatter.formatCurrency(totalAmount)}',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Breakdown by Tax Type:',
                      style: const pw.TextStyle(fontSize: 12)),
                  ...breakdown.entries.map(
                    (e) => pw.Text(
                        '  ${e.key}: ${CurrencyFormatter.formatCurrency(e.value)}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Calculations table
            pw.Text(
              'Detailed Calculations',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.green,
              ),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
              headers: ['Date', 'Tax Type', 'Description', 'Amount'],
              data: calculations!
                  .map((calc) => [
                        DateFormat('yyyy-MM-dd').format(calc.date),
                        calc.type,
                        calc.description.length > 40
                            ? '${calc.description.substring(0, 40)}...'
                            : calc.description,
                        CurrencyFormatter.formatCurrency(calc.amount),
                      ])
                  .toList(),
            ),

            // Footer
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text(
              'Generated by TaxPadi - Nigeria Tax Compliance App',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    fileName ??= 'tax_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    return path;
  }

  /// Share exported file
  static Future<void> shareFile(String filePath, String title) async {
    final xFile = XFile(filePath);
    await Share.shareXFiles([xFile], text: title);
  }

  /// Get file size in human-readable format
  static String getFileSize(String filePath) {
    final file = File(filePath);
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
