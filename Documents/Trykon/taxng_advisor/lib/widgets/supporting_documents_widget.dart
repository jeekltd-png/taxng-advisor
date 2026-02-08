import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/calculation_attachment.dart';
import '../services/attachment_service.dart';
import '../services/media_picker_service.dart';

/// Widget for uploading supporting documents for FIRS audit verification
/// Includes: Purchase Invoice, Sales Invoice, Bank Statement
class SupportingDocumentsWidget extends StatefulWidget {
  final List<CalculationAttachment> attachments;
  final Function(CalculationAttachment) onDocumentAdded;
  final Function(CalculationAttachment) onDocumentRemoved;
  final String? calculationId;

  const SupportingDocumentsWidget({
    super.key,
    required this.attachments,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
    this.calculationId,
  });

  @override
  State<SupportingDocumentsWidget> createState() =>
      _SupportingDocumentsWidgetState();
}

class _SupportingDocumentsWidgetState extends State<SupportingDocumentsWidget> {
  final _mediaPicker = MediaPickerService();
  final _attachmentService = AttachmentService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _attachmentService.initialize();
  }

  Future<void> _pickDocument(String documentType) async {
    setState(() => _isUploading = true);

    try {
      final result = await _mediaPicker.pickDocument();
      if (result != null && mounted) {
        await _saveDocument(result, documentType);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickImage(String documentType) async {
    setState(() => _isUploading = true);

    try {
      final result = await _mediaPicker.pickImage();
      if (result != null && mounted) {
        await _saveDocument(result, documentType);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveDocument(
      PickedFileResult pickedFile, String documentType) async {
    try {
      final fileName = pickedFile.name;
      final fileSize = pickedFile.size;

      // On web, we have bytes; on mobile/desktop, we have a file path
      if (kIsWeb && pickedFile.bytes != null) {
        // For web, store the bytes-based document info
        final tempAttachment = CalculationAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          calculationId: widget.calculationId ?? 'temp',
          fileName: fileName,
          filePath: 'web:$fileName', // Mark as web file
          fileType: _getFileType(fileName),
          uploadDate: DateTime.now(),
          description: documentType,
          fileSizeBytes: fileSize,
        );

        widget.onDocumentAdded(tempAttachment);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('$documentType added (${pickedFile.sizeFormatted})'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (pickedFile.path.isNotEmpty) {
        // For mobile/desktop, use file-based approach

        if (widget.calculationId != null) {
          final savedAttachment = await _attachmentService.saveAttachment(
            calculationId: widget.calculationId!,
            sourceFilePath: pickedFile.path,
            fileName: fileName,
            fileType: _getFileType(fileName),
            description: documentType,
          );

          widget.onDocumentAdded(savedAttachment);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$documentType uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Create temporary attachment if no calculationId yet
          final tempAttachment = CalculationAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            calculationId: 'temp',
            fileName: fileName,
            filePath: pickedFile.path,
            fileType: _getFileType(fileName),
            uploadDate: DateTime.now(),
            description: documentType,
            fileSizeBytes: fileSize,
          );

          widget.onDocumentAdded(tempAttachment);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('$documentType added (will save with calculation)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        throw Exception('No file data available');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return 'image';
    } else if (extension == 'pdf') {
      return 'pdf';
    } else {
      return 'document';
    }
  }

  void _showDocumentOptions(String documentType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(documentType);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.insert_drive_file, color: Colors.orange),
              title: const Text('Pick PDF/Document'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument(documentType);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<CalculationAttachment> _getDocumentsByType(String type) {
    return widget.attachments.where((doc) => doc.description == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseInvoices = _getDocumentsByType('Purchase Invoice');
    final salesInvoices = _getDocumentsByType('Sales Invoice');
    final bankStatements = _getDocumentsByType('Bank Statement');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Supporting Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supporting Documents'),
                        content: const Text(
                          'Attach invoices and documents for FIRS audit verification.\n\n'
                          '• Purchase Invoice: Evidence of expenses\n'
                          '• Sales Invoice: Proof of revenue\n'
                          '• Bank Statement: Payment confirmation\n\n'
                          'Accepted formats: PDF, JPG, PNG',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Attach invoices and documents for FIRS audit verification.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Document Upload Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DocumentButton(
                  icon: Icons.shopping_cart,
                  label: 'Purchase Invoice',
                  count: purchaseInvoices.length,
                  onPressed: () => _showDocumentOptions('Purchase Invoice'),
                  isUploading: _isUploading,
                ),
                _DocumentButton(
                  icon: Icons.receipt,
                  label: 'Sales Invoice',
                  count: salesInvoices.length,
                  onPressed: () => _showDocumentOptions('Sales Invoice'),
                  isUploading: _isUploading,
                ),
                _DocumentButton(
                  icon: Icons.account_balance,
                  label: 'Bank Statement',
                  count: bankStatements.length,
                  onPressed: () => _showDocumentOptions('Bank Statement'),
                  isUploading: _isUploading,
                ),
                _DocumentButton(
                  icon: Icons.visibility,
                  label: 'View All',
                  count: widget.attachments.length,
                  onPressed: () => _showAllDocuments(),
                  isUploading: false,
                  isPrimary: false,
                ),
              ],
            ),

            // Show uploaded documents count
            if (widget.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.attachments.length} document(s) uploaded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllDocuments() {
    if (widget.attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No documents uploaded yet')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'All Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.attachments.length,
                  itemBuilder: (context, index) {
                    final doc = widget.attachments[index];
                    return ListTile(
                      leading: Icon(
                        doc.fileType == 'image'
                            ? Icons.image
                            : doc.fileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.insert_drive_file,
                        color: Colors.blue,
                      ),
                      title: Text(doc.fileName),
                      subtitle: Text(doc.description ?? 'No description'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          widget.onDocumentRemoved(doc);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onPressed;
  final bool isUploading;
  final bool isPrimary;

  const _DocumentButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onPressed,
    required this.isUploading,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isUploading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0 && isPrimary) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.green[50] : Colors.grey[100],
        foregroundColor: isPrimary ? Colors.green[700] : Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
