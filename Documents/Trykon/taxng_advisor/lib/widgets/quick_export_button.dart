import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxng_advisor/services/pdf_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Quick export button for calculation results
class QuickExportButton extends StatelessWidget {
  final String taxType;
  final Map<String, dynamic> resultData;
  final String? userName;

  const QuickExportButton({
    super.key,
    required this.taxType,
    required this.resultData,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.file_download, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Export Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportPDF(context),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareResults(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final user = await AuthService.currentUser();

      final pdfBytes = await PdfService.generatePdf(
        resultData,
        taxType,
        userId: user?.id,
        tin: user?.tin,
        userName:
            user?.isBusiness == true ? user?.businessName : user?.username,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Open PDF viewer/share dialog
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name:
              'TaxPadi_${taxType}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ PDF ready! (${(pdfBytes.length / 1024).toStringAsFixed(1)} KB)',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _shareResults(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.blue),
            SizedBox(width: 8),
            Text('Share Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose how to share:'),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _shareViaEmail(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('WhatsApp'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _shareViaWhatsApp(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy, color: Colors.grey),
              title: const Text('Copy Text'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareViaEmail(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing email with PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Get user info for PDF
      final user = await AuthService.currentUser();

      // Generate PDF
      final pdfBytes = await PdfService.generatePdf(
        resultData,
        taxType,
        userId: user?.id,
        tin: user?.tin,
        userName:
            user?.isBusiness == true ? user?.businessName : user?.username,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Share file with email subject and body
        final subject = 'Tax Calculation - $taxType';
        final body = _formatResultsAsText();
        final fileName =
            'TaxPadi_${taxType}_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Use XFile.fromData for web compatibility (no temporary file needed)
        await Share.shareXFiles(
          [
            XFile.fromData(pdfBytes,
                name: fileName, mimeType: 'application/pdf')
          ],
          subject: subject,
          text: body,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('PDF attached to email!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to prepare email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    try {
      final text = Uri.encodeComponent(_formatResultsAsText());
      final uri = Uri.parse('https://wa.me/?text=$text');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: _formatResultsAsText()));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Results copied to clipboard!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatResultsAsText() {
    final buffer = StringBuffer();
    buffer.writeln('===========================================');
    buffer.writeln('TAXPADI - $taxType CALCULATION');
    buffer.writeln('===========================================');
    buffer.writeln();
    buffer.writeln('Calculation Results:');
    buffer.writeln('-------------------------------------------');

    resultData.forEach((key, value) {
      if (value != null) {
        final formattedKey = key
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}',
            )
            .trim();
        final capitalizedKey =
            formattedKey[0].toUpperCase() + formattedKey.substring(1);

        if (value is double) {
          buffer.writeln('$capitalizedKey: ₦${value.toStringAsFixed(2)}');
        } else {
          buffer.writeln('$capitalizedKey: $value');
        }
      }
    });

    buffer.writeln('-------------------------------------------');
    buffer.writeln();
    buffer.writeln('Generated by TaxPadi');
    buffer.writeln('Date: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('===========================================');

    return buffer.toString();
  }
}
