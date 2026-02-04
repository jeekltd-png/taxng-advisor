import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Quick import button widget for calculator screens
/// Allows users to quickly import CSV/JSON data without navigating to Profile
class QuickImportButton extends StatelessWidget {
  final String calculatorType; // 'CIT', 'VAT', 'PIT', etc.
  final Function(Map<String, dynamic>) onDataImported;

  const QuickImportButton({
    Key? key,
    required this.calculatorType,
    required this.onDataImported,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showImportOptions(context),
      icon: const Icon(Icons.upload_file, color: Colors.white),
      label: const Text('Import', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      heroTag: 'import_$calculatorType',
    );
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cloud_upload,
                      color: Colors.green[700], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Import Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Import $calculatorType calculation data',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Import from file button
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade200, width: 1),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _pickAndImportFile(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.insert_drive_file,
                            color: Colors.green[700], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Import from File',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'CSV, JSON, or Excel file',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.green[700], size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Paste data button
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.blue.shade200, width: 1),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showPasteDialog(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.content_paste,
                            color: Colors.blue[700], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Paste Data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Copy-paste CSV or JSON text',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.blue[700], size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // View sample format
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.orange.shade200, width: 1),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showSampleFormat(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.info_outline,
                            color: Colors.orange[700], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'View Sample Format',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'See examples of correct format',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.orange[700], size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImportFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final content = String.fromCharCodes(file.bytes!);

        _processImportedData(context, content, file.name);
      }
    } catch (e) {
      _showError(context, 'File selection error: $e');
    }
  }

  void _showPasteDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.content_paste, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Paste Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your CSV or JSON data below:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Paste CSV or JSON data here...\n\nExample CSV:\ntype,turnover,profit\nCIT,75000000,15000000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _processImportedData(context, controller.text, 'pasted data');
            },
            icon: const Icon(Icons.check),
            label: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _processImportedData(
      BuildContext context, String content, String source) {
    try {
      Map<String, dynamic> data;

      // Detect format
      final trimmed = content.trim();
      if (trimmed.startsWith('{')) {
        // JSON format
        final jsonData = jsonDecode(trimmed) as Map<String, dynamic>;
        data = _parseJsonData(jsonData);
      } else if (trimmed.contains(',')) {
        // CSV format
        data = _parseCsvData(trimmed);
      } else {
        throw Exception('Unrecognized format. Please use CSV or JSON.');
      }

      // Validate calculator type
      if (data['type'] != calculatorType) {
        _showError(
          context,
          'Data type mismatch: Expected $calculatorType, got ${data['type']}',
        );
        return;
      }

      // Show success and trigger callback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Successfully imported from $source'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      onDataImported(data);
    } catch (e) {
      _showError(context, 'Import failed: $e');
    }
  }

  Map<String, dynamic> _parseJsonData(Map<String, dynamic> json) {
    // Expected format: {"type": "CIT", "data": {"turnover": 75000000, "profit": 15000000}}
    final type = json['type'] as String?;
    final data = json['data'] as Map<String, dynamic>?;

    if (type == null || data == null) {
      throw Exception(
          'Invalid JSON format. Expected: {"type": "CIT", "data": {...}}');
    }

    return {'type': type, ...data};
  }

  Map<String, dynamic> _parseCsvData(String csv) {
    final lines = csv.trim().split('\n');
    if (lines.length < 2) {
      throw Exception('CSV must have at least 2 lines (header + data)');
    }

    // Parse header
    final headers = lines[0].split(',').map((h) => h.trim()).toList();

    // Parse first data row
    final values = lines[1].split(',').map((v) => v.trim()).toList();

    if (headers.length != values.length) {
      throw Exception('CSV header and data column count mismatch');
    }

    // Build data map
    final data = <String, dynamic>{};
    for (int i = 0; i < headers.length; i++) {
      final key = headers[i];
      final value = values[i];

      // Try to parse as number
      final numValue = num.tryParse(value);
      data[key] = numValue ?? value;
    }

    return data;
  }

  void _showSampleFormat(BuildContext context) {
    final samples = _getSampleFormats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Text('$calculatorType Sample Formats'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CSV Format:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  samples['csv']!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'JSON Format:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  samples['json']!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getSampleFormats() {
    switch (calculatorType) {
      case 'CIT':
        return {
          'csv': '''type,turnover,profit
CIT,75000000,15000000''',
          'json': '''{
  "type": "CIT",
  "data": {
    "turnover": 75000000,
    "profit": 15000000
  }
}''',
        };
      case 'VAT':
        return {
          'csv': '''type,taxableSupplies,rate
VAT,50000000,0.075''',
          'json': '''{
  "type": "VAT",
  "data": {
    "taxableSupplies": 50000000,
    "rate": 0.075
  }
}''',
        };
      case 'PIT':
        return {
          'csv': '''type,grossIncome,deductions,rent
PIT,12000000,2000000,1500000''',
          'json': '''{
  "type": "PIT",
  "data": {
    "grossIncome": 12000000,
    "deductions": 2000000,
    "rent": 1500000
  }
}''',
        };
      case 'WHT':
        return {
          'csv': '''type,amount,whtType
WHT,10000000,dividends''',
          'json': '''{
  "type": "WHT",
  "data": {
    "amount": 10000000,
    "whtType": "dividends"
  }
}''',
        };
      case 'PAYE':
        return {
          'csv': '''type,basicSalary,allowances
PAYE,500000,200000''',
          'json': '''{
  "type": "PAYE",
  "data": {
    "basicSalary": 500000,
    "allowances": 200000
  }
}''',
        };
      case 'Stamp Duty':
        return {
          'csv': '''type,amount,transactionType
Stamp Duty,50000000,sale''',
          'json': '''{
  "type": "Stamp Duty",
  "data": {
    "amount": 50000000,
    "transactionType": "sale"
  }
}''',
        };
      default:
        return {
          'csv': 'type,field1,field2\n$calculatorType,value1,value2',
          'json': '{"type": "$calculatorType", "data": {...}}',
        };
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Import Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
