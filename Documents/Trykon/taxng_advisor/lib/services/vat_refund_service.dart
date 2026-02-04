import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/models/tax_result.dart';

/// Service for generating VAT refund documentation and FIRS submissions
class VatRefundService {
  /// Generate FIRS Form 002 (VAT Return) with refund position
  static Future<Uint8List> generateForm002Pdf({
    required VatResult vatResult,
    required String businessName,
    required String tin,
    required String address,
    required String period,
    required int year,
    String? contactPerson,
    String? phone,
    String? email,
  }) async {
    final pdf = pw.Document();
    final bool isRefund = vatResult.refundEligible > 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'FEDERAL INLAND REVENUE SERVICE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'VALUE ADDED TAX RETURN (FORM 002)',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Period: $period $year',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Business Information
          _buildSection('TAXPAYER INFORMATION', [
            ['Business Name:', businessName],
            ['Tax Identification Number (TIN):', tin],
            ['Address:', address],
            if (contactPerson != null) ['Contact Person:', contactPerson],
            if (phone != null) ['Phone:', phone],
            if (email != null) ['Email:', email],
          ]),
          pw.SizedBox(height: 20),

          // VAT Calculation Details
          _buildSection('VAT COMPUTATION', [
            [
              'Total Sales (Turnover)',
              CurrencyFormatter.formatCurrency(vatResult.totalSales)
            ],
            [
              '  - Standard-Rated Sales (7.5%)',
              CurrencyFormatter.formatCurrency(vatResult.vatableSales)
            ],
            [
              '  - Zero-Rated Sales (0%)',
              CurrencyFormatter.formatCurrency(vatResult.zeroRatedSales)
            ],
            [
              '  - Exempt Sales',
              CurrencyFormatter.formatCurrency(vatResult.exemptSales)
            ],
          ]),
          pw.SizedBox(height: 16),

          _buildSection('OUTPUT VAT', [
            [
              'Output VAT on Standard Sales',
              CurrencyFormatter.formatCurrency(vatResult.outputVat)
            ],
            [
              '(${CurrencyFormatter.formatCurrency(vatResult.vatableSales)} × 7.5%)',
              ''
            ],
          ]),
          pw.SizedBox(height: 16),

          _buildSection('INPUT VAT', [
            [
              'Total Input VAT Paid',
              CurrencyFormatter.formatCurrency(vatResult.recoverableInput +
                  (vatResult.outputVat -
                      vatResult.recoverableInput -
                      vatResult.netPayable))
            ],
            [
              'Less: Exempt Input VAT (Non-recoverable)',
              CurrencyFormatter.formatCurrency(vatResult.outputVat -
                  vatResult.recoverableInput -
                  vatResult.netPayable)
            ],
            [
              'Recoverable Input VAT',
              CurrencyFormatter.formatCurrency(vatResult.recoverableInput)
            ],
          ]),
          pw.SizedBox(height: 16),

          // Net Position
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: isRefund ? PdfColors.green50 : PdfColors.blue50,
              border: pw.Border.all(
                color: isRefund ? PdfColors.green : PdfColors.blue,
                width: 2,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NET VAT POSITION',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Output VAT:'),
                    pw.Text(
                        CurrencyFormatter.formatCurrency(vatResult.outputVat)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Less: Recoverable Input VAT:'),
                    pw.Text(
                        '(${CurrencyFormatter.formatCurrency(vatResult.recoverableInput)})'),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      isRefund ? 'VAT REFUND DUE:' : 'NET VAT PAYABLE:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.formatCurrency(isRefund
                          ? vatResult.refundEligible
                          : vatResult.netPayable),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: isRefund ? PdfColors.green : PdfColors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Refund Notice (if applicable)
          if (isRefund) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.yellow50,
                border: pw.Border.all(color: PdfColors.orange, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        '⚠ ',
                        style: const pw.TextStyle(fontSize: 16),
                      ),
                      pw.Text(
                        'VAT REFUND CLAIM',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'This return shows a refund position of ${CurrencyFormatter.formatCurrency(vatResult.refundEligible)}. '
                    'The taxpayer requests refund of excess input VAT in accordance with VAT Act Section 16.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // Declaration
          pw.Divider(),
          pw.SizedBox(height: 16),
          pw.Text(
            'DECLARATION',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'I declare that the information provided in this return is true, correct, and complete to the best of my knowledge.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 24),

          // Signature Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 200,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black),
                      ),
                    ),
                    child: pw.SizedBox(height: 40),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Signature', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 150,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black),
                      ),
                    ),
                    child: pw.SizedBox(height: 40),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Date', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Footer
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SUPPORTING DOCUMENTS (to be attached):',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '✓ Purchase invoices showing input VAT\n'
                  '✓ Sales invoices showing output VAT\n'
                  '✓ Bank statements showing payments\n'
                  '✓ Import documents (if applicable)\n'
                  '✓ VAT reconciliation schedule',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Generated by TaxPadi on ${_formatDate(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate VAT refund claim letter to FIRS
  static Future<Uint8List> generateRefundClaimLetter({
    required VatResult vatResult,
    required String businessName,
    required String tin,
    required String address,
    required String period,
    required int year,
    required String contactPerson,
    required String phone,
    required String email,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
  }) async {
    final pdf = pw.Document();
    final refundAmount = vatResult.refundEligible;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Letterhead
            pw.Text(
              businessName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(address, style: const pw.TextStyle(fontSize: 10)),
            pw.Text('TIN: $tin', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Tel: $phone | Email: $email',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 24),

            // Date
            pw.Text(
              _formatDate(DateTime.now()),
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),

            // Recipient
            pw.Text(
              'The Executive Chairman',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.Text('Federal Inland Revenue Service (FIRS)',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Revenue House, Plot 1147/1148 Cadastral Zone A03',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Central Business District, Abuja',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 16),

            // Subject
            pw.Text(
              'RE: APPLICATION FOR VAT REFUND - $period $year',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 16),

            // Body
            pw.Text(
              'Dear Sir/Madam,',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.SizedBox(height: 12),

            pw.Text(
              'We wish to apply for a refund of excess Value Added Tax (VAT) for the period $period $year.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),

            // Refund Details
            pw.Text(
              'REFUND DETAILS',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            _buildSimpleTable([
              [
                'Output VAT (Collected):',
                CurrencyFormatter.formatCurrency(vatResult.outputVat)
              ],
              [
                'Input VAT (Paid):',
                CurrencyFormatter.formatCurrency(vatResult.recoverableInput)
              ],
              [
                'Excess Input VAT (Refund):',
                CurrencyFormatter.formatCurrency(refundAmount)
              ],
            ]),
            pw.SizedBox(height: 12),

            pw.Text(
              'The excess input VAT arose from our business operations involving zero-rated supplies and/or purchases '
              'exceeding sales during the period. All supporting documentation is attached for your verification.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),

            // Bank Details
            if (bankName != null && bankAccountNumber != null) ...[
              pw.Text(
                'REFUND PAYMENT DETAILS',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              _buildSimpleTable([
                ['Bank Name:', bankName],
                ['Account Number:', bankAccountNumber],
                if (bankAccountName != null) ['Account Name:', bankAccountName],
              ]),
              pw.SizedBox(height: 12),
            ],

            pw.Text(
              'We request that the refund be processed in accordance with Section 16 of the VAT Act. '
              'Please find attached:',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            // Attachments List
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('1. Completed VAT Return Form 002',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('2. VAT Reconciliation Schedule',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('3. Copies of Purchase Invoices',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('4. Copies of Sales Invoices',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('5. Bank Statements',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            pw.Text(
              'We are available for any clarifications or audit verification as may be required.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),

            pw.Text(
              'Thank you for your attention to this matter.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 24),

            // Signature
            pw.Text('Yours faithfully,',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 40),
            pw.Text(
              '________________________________',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(contactPerson,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('For: $businessName',
                style: const pw.TextStyle(fontSize: 10)),

            pw.Spacer(),

            // Footer
            pw.Text(
              'Generated by TaxPadi on ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Generate detailed VAT reconciliation report
  static Future<Uint8List> generateReconciliationReport({
    required VatResult vatResult,
    required String businessName,
    required String tin,
    required String period,
    required int year,
    List<Map<String, dynamic>>? salesBreakdown,
    List<Map<String, dynamic>>? purchasesBreakdown,
  }) async {
    final pdf = pw.Document();
    final isRefund = vatResult.refundEligible > 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'VAT RECONCILIATION REPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  businessName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Period: $period $year | TIN: $tin',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Executive Summary
          pw.Text(
            'EXECUTIVE SUMMARY',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              children: [
                _buildSummaryRow('Total Sales', vatResult.totalSales),
                _buildSummaryRow('Output VAT Collected', vatResult.outputVat),
                _buildSummaryRow('Input VAT Paid', vatResult.recoverableInput),
                pw.Divider(color: PdfColors.grey),
                _buildSummaryRow(
                  isRefund ? 'VAT REFUND DUE' : 'NET VAT PAYABLE',
                  isRefund ? vatResult.refundEligible : vatResult.netPayable,
                  isBold: true,
                  color: isRefund ? PdfColors.green : PdfColors.blue900,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Sales Analysis
          pw.Text(
            'SALES ANALYSIS',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  _buildTableCell('Supply Type', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                  _buildTableCell('VAT Rate', isHeader: true),
                  _buildTableCell('Output VAT', isHeader: true),
                ],
              ),
              // Standard Sales
              pw.TableRow(
                children: [
                  _buildTableCell('Standard-Rated'),
                  _buildTableCell(
                      CurrencyFormatter.formatCurrency(vatResult.vatableSales)),
                  _buildTableCell('7.5%'),
                  _buildTableCell(
                      CurrencyFormatter.formatCurrency(vatResult.outputVat)),
                ],
              ),
              // Zero-Rated Sales
              pw.TableRow(
                children: [
                  _buildTableCell('Zero-Rated'),
                  _buildTableCell(CurrencyFormatter.formatCurrency(
                      vatResult.zeroRatedSales)),
                  _buildTableCell('0%'),
                  _buildTableCell('₦0'),
                ],
              ),
              // Exempt Sales
              pw.TableRow(
                children: [
                  _buildTableCell('Exempt'),
                  _buildTableCell(
                      CurrencyFormatter.formatCurrency(vatResult.exemptSales)),
                  _buildTableCell('N/A'),
                  _buildTableCell('₦0'),
                ],
              ),
              // Total
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('TOTAL', isHeader: true),
                  _buildTableCell(
                      CurrencyFormatter.formatCurrency(vatResult.totalSales),
                      isHeader: true),
                  _buildTableCell(''),
                  _buildTableCell(
                      CurrencyFormatter.formatCurrency(vatResult.outputVat),
                      isHeader: true),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Detailed Sales Breakdown (if provided)
          if (salesBreakdown != null && salesBreakdown.isNotEmpty) ...[
            pw.Text(
              'DETAILED SALES TRANSACTIONS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                  children: [
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Amount', isHeader: true),
                    _buildTableCell('Type', isHeader: true),
                    _buildTableCell('VAT', isHeader: true),
                  ],
                ),
                ...salesBreakdown.map((sale) => pw.TableRow(
                      children: [
                        _buildTableCell(sale['description'] ?? 'Sale',
                            fontSize: 9),
                        _buildTableCell(
                          CurrencyFormatter.formatCurrency(sale['amount'] ?? 0),
                          fontSize: 9,
                        ),
                        _buildTableCell(sale['type'] ?? 'Standard',
                            fontSize: 9),
                        _buildTableCell(
                          CurrencyFormatter.formatCurrency(sale['vat'] ?? 0),
                          fontSize: 9,
                        ),
                      ],
                    )),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // Purchases Analysis
          pw.Text(
            'PURCHASES & INPUT VAT ANALYSIS',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    'Total Input VAT Paid:',
                    CurrencyFormatter.formatCurrency(
                        vatResult.recoverableInput +
                            (vatResult.outputVat -
                                vatResult.recoverableInput -
                                vatResult.netPayable))),
                _buildDetailRow(
                    'Less: Exempt Input VAT:',
                    CurrencyFormatter.formatCurrency(vatResult.outputVat -
                        vatResult.recoverableInput -
                        vatResult.netPayable)),
                pw.Divider(),
                _buildDetailRow(
                  'Recoverable Input VAT:',
                  CurrencyFormatter.formatCurrency(vatResult.recoverableInput),
                  isBold: true,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Detailed Purchases Breakdown (if provided)
          if (purchasesBreakdown != null && purchasesBreakdown.isNotEmpty) ...[
            pw.Text(
              'DETAILED PURCHASE TRANSACTIONS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                  children: [
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Amount', isHeader: true),
                    _buildTableCell('Input VAT', isHeader: true),
                  ],
                ),
                ...purchasesBreakdown.map((purchase) => pw.TableRow(
                      children: [
                        _buildTableCell(purchase['description'] ?? 'Purchase',
                            fontSize: 9),
                        _buildTableCell(
                          CurrencyFormatter.formatCurrency(
                              purchase['amount'] ?? 0),
                          fontSize: 9,
                        ),
                        _buildTableCell(
                          CurrencyFormatter.formatCurrency(
                              purchase['vat'] ?? 0),
                          fontSize: 9,
                        ),
                      ],
                    )),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // Net Position
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: isRefund ? PdfColors.green50 : PdfColors.blue50,
              border: pw.Border.all(
                color: isRefund ? PdfColors.green : PdfColors.blue,
                width: 2,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NET VAT POSITION',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildDetailRow('Output VAT (Collected from customers):',
                    CurrencyFormatter.formatCurrency(vatResult.outputVat)),
                _buildDetailRow('Input VAT (Paid on purchases):',
                    '(${CurrencyFormatter.formatCurrency(vatResult.recoverableInput)})'),
                pw.Divider(thickness: 2),
                _buildDetailRow(
                  isRefund
                      ? 'VAT REFUND DUE TO TAXPAYER:'
                      : 'NET VAT PAYABLE TO FIRS:',
                  CurrencyFormatter.formatCurrency(isRefund
                      ? vatResult.refundEligible
                      : vatResult.netPayable),
                  isBold: true,
                  fontSize: 12,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Compliance Notes
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.yellow50,
              border: pw.Border.all(color: PdfColors.orange),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'COMPLIANCE NOTES',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  isRefund
                      ? '✓ Refund claim must be filed with Form 002 and supporting documents\n'
                          '✓ Keep all purchase invoices for FIRS audit verification\n'
                          '✓ Refunds are subject to FIRS review and approval\n'
                          '✓ Processing time: 60-90 days from submission'
                      : '✓ Payment due within 21 days after end of the month\n'
                          '✓ Late payment attracts 10% penalty plus 5% interest per annum\n'
                          '✓ File returns even if no VAT payable\n'
                          '✓ Keep records for at least 6 years',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Prepared by: TaxPadi',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
              pw.Text(
                'Date: ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Helper to build section with title and data rows
  static pw.Widget _buildSection(String title, List<List<String>> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          child: pw.Column(
            children: rows
                .map(
                  (row) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          row[0],
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: row[0].startsWith('  ')
                                ? pw.FontWeight.normal
                                : pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          row[1],
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Helper to build simple table
  static pw.Widget _buildSimpleTable(List<List<String>> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Column(
        children: rows
            .map(
              (row) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(row[0], style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(row[1],
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Helper to build summary row
  static pw.Widget _buildSummaryRow(
    String label,
    double value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
          pw.Text(
            CurrencyFormatter.formatCurrency(value),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build detail row
  static pw.Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build table cell
  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Format date as DD/MM/YYYY
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Share PDF document
  static Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
