import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
}
