import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// VAT Form 002 Generator - Business tier exclusive
class VatForm002Screen extends StatefulWidget {
  const VatForm002Screen({Key? key}) : super(key: key);

  @override
  State<VatForm002Screen> createState() => _VatForm002ScreenState();
}

class _VatForm002ScreenState extends State<VatForm002Screen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isAdmin = false;

  // Form controllers
  final _companyNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxPeriodController = TextEditingController();
  final _outputVatController = TextEditingController();
  final _inputVatController = TextEditingController();
  final _refundAmountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _tinController.dispose();
    _addressController.dispose();
    _taxPeriodController.dispose();
    _outputVatController.dispose();
    _inputVatController.dispose();
    _refundAmountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await AuthService.currentUser();
    // Allow access for Business tier OR admin users
    if (user == null ||
        (user.subscriptionTier != 'business' && !user.isAdmin)) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business tier required for VAT Form 002'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      // Pre-fill with user data
      _companyNameController.text = user.businessName ?? '';
      _tinController.text = user.tin ?? '';
      _addressController.text = user.address ?? '';
      _isAdmin = user.isAdmin;
      _isLoading = false;
    });
  }

  void _fillSampleData() {
    setState(() {
      _companyNameController.text = 'Acme Trading Limited';
      _tinController.text = '12345678-0001';
      _addressController.text = '45 Allen Avenue, Ikeja, Lagos State';
      _taxPeriodController.text = 'January 2024';
      _outputVatController.text = '150000';
      _inputVatController.text = '250000';
      _bankNameController.text = 'First Bank of Nigeria';
      _accountNumberController.text = '1234567890';
      _accountNameController.text = 'Acme Trading Limited';
    });
    _calculateRefund();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Sample data loaded. You can now generate the form.'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _calculateRefund() {
    if (_outputVatController.text.isNotEmpty &&
        _inputVatController.text.isNotEmpty) {
      final outputVat = double.tryParse(_outputVatController.text) ?? 0;
      final inputVat = double.tryParse(_inputVatController.text) ?? 0;
      final refund = inputVat - outputVat;
      if (refund > 0) {
        setState(() {
          _refundAmountController.text = refund.toStringAsFixed(2);
        });
      }
    }
  }

  Future<void> _generatePDF() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#2E7D32'),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'VAT REFUND APPLICATION',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Form 002',
                            style: const pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Generated by TaxPadi',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Company Information
                pw.Text(
                  'COMPANY INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2E7D32'),
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfField('Company Name', _companyNameController.text),
                _buildPdfField(
                    'Tax Identification Number (TIN)', _tinController.text),
                _buildPdfField('Registered Address', _addressController.text),
                _buildPdfField('Tax Period', _taxPeriodController.text),
                pw.SizedBox(height: 20),

                // VAT Details
                pw.Text(
                  'VAT COMPUTATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2E7D32'),
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfField('Output VAT (Sales)',
                    'N${_formatNumber(_outputVatController.text)}'),
                _buildPdfField('Input VAT (Purchases)',
                    'N${_formatNumber(_inputVatController.text)}'),
                pw.Divider(thickness: 2),
                _buildPdfField('VAT Refund Due',
                    'N${_formatNumber(_refundAmountController.text)}',
                    isBold: true),
                pw.SizedBox(height: 20),

                // Bank Details
                pw.Text(
                  'BANK DETAILS FOR REFUND',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2E7D32'),
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfField('Bank Name', _bankNameController.text),
                _buildPdfField('Account Number', _accountNumberController.text),
                _buildPdfField('Account Name', _accountNameController.text),
                pw.SizedBox(height: 30),

                // Declaration
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DECLARATION',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'I declare that the information provided in this application is true and correct to the best of my knowledge. I understand that providing false information may result in penalties under the relevant tax laws.',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 150,
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    bottom:
                                        pw.BorderSide(color: PdfColors.black),
                                  ),
                                ),
                                child: pw.SizedBox(height: 40),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text('Signature',
                                  style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data:
                                    'TXP-VAT002-${_tinController.text}-${DateTime.now().millisecondsSinceEpoch}',
                                width: 60,
                                height: 60,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text('QR Code',
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 120,
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    bottom:
                                        pw.BorderSide(color: PdfColors.black),
                                  ),
                                ),
                                child: pw.SizedBox(height: 40),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text('Date',
                                  style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Divider(),
                pw.Text(
                  'Generated by TaxPadi - Your Padi for Nigerian Tax Matters',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      // Add second page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // VAT Refund Claim Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.orange, width: 2),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 12,
                            height: 12,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black, width: 2),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            'VAT REFUND CLAIM',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'This return shows a refund position of N${_formatNumber(_refundAmountController.text)}. The taxpayer requests refund of excess input VAT in accordance with VAT Act Section 16.',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Declaration
                pw.Text(
                  'DECLARATION',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'I declare that the information provided in this return is true, correct, and complete to the best of my knowledge.',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 40),

                // Signature and Date row
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
                          child: pw.SizedBox(height: 1),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Signature',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
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
                          child: pw.SizedBox(height: 1),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Date',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),

                // Supporting Documents
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SUPPORTING DOCUMENTS (to be attached):',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      _buildBulletPoint('Purchase invoices showing input VAT'),
                      _buildBulletPoint('Sales invoices showing output VAT'),
                      _buildBulletPoint('Bank statements showing payments'),
                      _buildBulletPoint('Import documents (if applicable)'),
                      _buildBulletPoint('VAT reconciliation schedule'),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated by TaxPadi on ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('VAT Form 002 generated successfully'),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfField(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6, left: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 6,
            height: 6,
            margin: const pw.EdgeInsets.only(top: 4, right: 8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.black,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String value) {
    final number = double.tryParse(value) ?? 0;
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VAT Form 002 Generator'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'VAT Form 002 is used to apply for VAT refund when your Input VAT exceeds Output VAT',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Admin Sample Data Button
                    if (_isAdmin)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings,
                                color: Colors.purple[700]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Admin Preview Mode',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _fillSampleData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('Fill Sample Data'),
                            ),
                          ],
                        ),
                      ),
                    if (_isAdmin) const SizedBox(height: 24),

                    // Company Information Section
                    _buildSectionHeader('Company Information'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: Icons.business,
                      hint: 'e.g., Acme Trading Ltd',
                      helpText:
                          'Enter your registered company name as it appears on your CAC certificate',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _tinController,
                      label: 'Tax Identification Number (TIN)',
                      icon: Icons.numbers,
                      hint: 'e.g., 12345678-0001',
                      helpText:
                          'Your unique TIN issued by FIRS (format: 8 digits-4 digits)',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Registered Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                      hint: 'e.g., 45 Allen Avenue, Ikeja, Lagos',
                      helpText:
                          'Full registered business address as per CAC documents',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _taxPeriodController,
                      label: 'Tax Period',
                      icon: Icons.calendar_today,
                      hint: 'e.g., January 2024 or Q1 2024',
                      helpText:
                          'The period for which you are claiming VAT refund',
                    ),
                    const SizedBox(height: 24),

                    // VAT Computation Section
                    _buildSectionHeader('VAT Computation'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.amber[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Refund is calculated as: Input VAT - Output VAT',
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _outputVatController,
                      label: 'Output VAT (VAT on Sales)',
                      icon: Icons.arrow_upward,
                      keyboardType: TextInputType.number,
                      prefix: '₦',
                      hint: 'e.g., 150000',
                      helpText:
                          'Total VAT collected from your sales for the period',
                      onChanged: (_) => _calculateRefund(),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _inputVatController,
                      label: 'Input VAT (VAT on Purchases)',
                      icon: Icons.arrow_downward,
                      keyboardType: TextInputType.number,
                      prefix: '₦',
                      hint: 'e.g., 250000',
                      helpText:
                          'Total VAT paid on your business purchases for the period',
                      onChanged: (_) => _calculateRefund(),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'VAT Refund Due:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₦${_formatNumber(_refundAmountController.text)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bank Details Section
                    _buildSectionHeader('Bank Details for Refund'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Ensure bank details match your company registration',
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _bankNameController,
                      label: 'Bank Name',
                      icon: Icons.account_balance,
                      hint: 'e.g., First Bank of Nigeria',
                      helpText: 'Select or enter your bank name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: 'Account Number',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      hint: 'e.g., 1234567890',
                      helpText:
                          'Your 10-digit bank account number (NUBAN format)',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _accountNameController,
                      label: 'Account Name',
                      icon: Icons.person,
                      hint: 'e.g., Acme Trading Ltd',
                      helpText: 'Account name must match your company name',
                    ),
                    const SizedBox(height: 32),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _generatePDF,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text(
                          'Generate VAT Form 002',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
    String? hint,
    String? helpText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon),
            prefixText: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              helpText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
