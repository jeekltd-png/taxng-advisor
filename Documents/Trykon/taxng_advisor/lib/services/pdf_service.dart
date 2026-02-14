import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/models/user.dart';

/// Generate and share PDF reports
class PdfService {
  static Future<Uint8List> generatePdf(
      Map<String, dynamic> result, String type) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (context) => pw.Center(
            child: pw.Text(
                '$type Report – ₦${result.values.firstWhere((v) => v is double)}'))));
    return pdf.save();
  }

  static Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Generate comprehensive admin report PDF
  static Future<Uint8List> generateAdminReport({
    required String reportType,
    required List<dynamic> data,
    required Map<String, dynamic> statistics,
    List<UserProfile>? users,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildReportHeader(reportType),
          pw.SizedBox(height: 20),

          // Statistics Summary
          _buildStatisticsSection(statistics),
          pw.SizedBox(height: 20),

          // Data Table
          _buildDataTable(reportType, data, users),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildReportHeader(String reportType) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TaxPadi',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Admin Report: $reportType',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated: ${DateTime.now().toString().split('.')[0]}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildStatisticsSection(Map<String, dynamic> stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary Statistics',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 20,
            runSpacing: 8,
            children: stats.entries.map((entry) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      entry.key,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      entry.value.toString(),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDataTable(
    String reportType,
    List<dynamic> data,
    List<UserProfile>? users,
  ) {
    if (data.isEmpty) {
      return pw.Center(
        child: pw.Text('No data available'),
      );
    }

    switch (reportType) {
      case 'Users':
        return _buildUsersTable(data.cast<UserProfile>());
      case 'Payments':
        return _buildPaymentsTable(data.cast<Map<String, dynamic>>(), users);
      case 'CIT':
        return _buildCitTable(data);
      case 'PIT':
        return _buildPitTable(data.cast<Map<String, dynamic>>());
      case 'VAT':
        return _buildVatTable(data.cast<Map<String, dynamic>>());
      case 'WHT':
        return _buildWhtTable(data.cast<Map<String, dynamic>>());
      default:
        return pw.Text('Unknown report type');
    }
  }

  static pw.Widget _buildUsersTable(List<UserProfile> users) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      headers: ['Username', 'Email', 'Type', 'Admin', 'Joined'],
      data: users.map((user) {
        return [
          user.username,
          user.email,
          user.isBusiness ? 'Business' : 'Personal',
          user.isAdmin ? 'Yes' : 'No',
          '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildPaymentsTable(
    List<Map<String, dynamic>> payments,
    List<UserProfile>? users,
  ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      headers: ['User', 'Amount', 'Tax Type', 'Status', 'Date'],
      data: payments.map((payment) {
        final userId = payment['userId'] as String? ?? '';
        final user = users?.firstWhere(
          (u) => u.id == userId,
          orElse: () => UserProfile(
            id: 'unknown',
            username: 'Unknown',
            email: '',
            isBusiness: false,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );

        return [
          user?.username ?? 'Unknown',
          CurrencyFormatter.formatCurrency(payment['amount'] as double? ?? 0.0),
          payment['taxType'] ?? 'N/A',
          payment['status'] ?? 'N/A',
          _formatDateForPdf(payment['paidAt']),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildCitTable(List<dynamic> estimates) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      headers: ['Category', 'Tax Payable', 'Turnover', 'Rate', 'Date'],
      data: estimates.map((estimate) {
        return [
          estimate.category ?? 'N/A',
          CurrencyFormatter.formatCurrency(estimate.taxPayable ?? 0.0),
          CurrencyFormatter.formatCurrency(estimate.turnover ?? 0.0),
          '${estimate.effectiveRate?.toStringAsFixed(2) ?? '0.00'}%',
          _formatDateForPdf(estimate.calculatedAt?.toIso8601String()),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildPitTable(List<Map<String, dynamic>> estimates) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
      },
      headers: ['Total Tax', 'Annual Income', 'Rate', 'Date'],
      data: estimates.map((estimate) {
        return [
          CurrencyFormatter.formatCurrency(
              estimate['totalTax'] as double? ?? 0.0),
          CurrencyFormatter.formatCurrency(
              estimate['annualIncome'] as double? ?? 0.0),
          '${estimate['effectiveRate']?.toStringAsFixed(2) ?? '0.00'}%',
          _formatDateForPdf(estimate['timestamp']),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildVatTable(List<Map<String, dynamic>> returns) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerLeft,
      },
      headers: ['VAT Payable', 'Output VAT', 'Input VAT', 'Date'],
      data: returns.map((vatReturn) {
        return [
          CurrencyFormatter.formatCurrency(
              vatReturn['vatPayable'] as double? ?? 0.0),
          CurrencyFormatter.formatCurrency(
              vatReturn['outputVat'] as double? ?? 0.0),
          CurrencyFormatter.formatCurrency(
              vatReturn['inputVat'] as double? ?? 0.0),
          _formatDateForPdf(vatReturn['timestamp']),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildWhtTable(List<Map<String, dynamic>> records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      headers: ['Payment Type', 'WHT Amount', 'Gross Amount', 'Rate', 'Date'],
      data: records.map((record) {
        return [
          record['paymentType'] ?? 'N/A',
          CurrencyFormatter.formatCurrency(
              record['whtAmount'] as double? ?? 0.0),
          CurrencyFormatter.formatCurrency(
              record['grossAmount'] as double? ?? 0.0),
          '${record['whtRate']?.toStringAsFixed(2) ?? '0.00'}%',
          _formatDateForPdf(record['timestamp']),
        ];
      }).toList(),
    );
  }

  static String _formatDateForPdf(dynamic date) {
    if (date == null) return 'N/A';

    DateTime? dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date);
    } else if (date is DateTime) {
      dateTime = date;
    }

    if (dateTime == null) return 'N/A';

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Generate tax payment receipt PDF for email attachment
  static Future<Uint8List> generatePaymentReceiptPdf({
    required String taxType,
    required double amount,
    required String currency,
    required String referenceId,
    required String paymentMethod,
    required String? bankName,
    required String? accountNumber,
    required String? tin,
    required String userName,
    required String userEmail,
    Map<String, dynamic>? taxCalculationDetails,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.green,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TaxPadi',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Your Padi for Nigerian Tax Matters',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Title
          pw.Text(
            'TAX PAYMENT RECEIPT',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: ${DateTime.now().toString().split('.')[0]}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),

          // Payment Information
          _buildReceiptSection('Payment Information', [
            ['Reference ID:', referenceId],
            ['Tax Type:', taxType],
            [
              'Amount:',
              '${currency == 'USD' ? '\$' : currency == 'GBP' ? '£' : '₦'}${amount.toStringAsFixed(2)} ($currency)'
            ],
            ['Payment Method:', paymentMethod],
            if (bankName != null) ['Bank:', bankName],
            if (accountNumber != null) ['Account Number:', accountNumber],
            ['Status:', 'CONFIRMED'],
            ['Date:', DateTime.now().toString().split('.')[0]],
          ]),
          pw.SizedBox(height: 20),

          // Taxpayer Information
          _buildReceiptSection('Taxpayer Information', [
            ['Name:', userName],
            ['Email:', userEmail],
            if (tin != null && tin.isNotEmpty) ['TIN:', tin],
          ]),
          pw.SizedBox(height: 20),

          // Tax Calculation Details (if provided)
          if (taxCalculationDetails != null) ...[
            _buildReceiptSection(
              'Tax Calculation Details',
              taxCalculationDetails.entries
                  .map((e) => [
                        '${e.key}:',
                        e.value.toString(),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'IMPORTANT NOTICE',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• This is a computer-generated receipt from TaxPadi application\n'
            '• Keep this receipt for your records and tax filing\n'
            '• Submit this receipt along with proof of payment to the relevant tax office\n'
            '• For inquiries, contact: support@taxpadi.com',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              '© ${DateTime.now().year} TaxPadi by Trykon. All rights reserved.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildReceiptSection(String title, List<List<String>> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 12),
          ...data.map((row) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 150,
                      child: pw.Text(
                        row[0],
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        row[1],
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
