import 'dart:convert';
import 'dart:typed_data';
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

  /// Store file bytes in memory for preview (keyed by attachment ID)
  static final Map<String, Uint8List> _fileBytes = {};

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
        final attachmentId = DateTime.now().millisecondsSinceEpoch.toString();

        // Save bytes for preview
        _fileBytes[attachmentId] = Uint8List.fromList(pickedFile.bytes!);

        final tempAttachment = CalculationAttachment(
          id: attachmentId,
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
                      title: Text(
                        doc.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(doc.description ?? 'No description'),
                      onTap: () {
                        Navigator.pop(context);
                        _previewDocument(doc);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          widget.onDocumentRemoved(doc);
                          _fileBytes.remove(doc.id);
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

  /// Preview a document — images shown inline, CSV/text shown as text,
  /// PDF/other shown with info card.
  void _previewDocument(CalculationAttachment doc) {
    final bytes = _fileBytes[doc.id];
    final ext = doc.fileName.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isText = ['csv', 'txt'].contains(ext);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isImage
                          ? Icons.image
                          : isText
                              ? Icons.description
                              : Icons.insert_drive_file,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        doc.fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Info bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    _infoChip(Icons.category, doc.description ?? 'Document'),
                    const SizedBox(width: 12),
                    _infoChip(Icons.straighten, doc.fileSizeFormatted),
                    const SizedBox(width: 12),
                    _infoChip(
                      Icons.calendar_today,
                      '${doc.uploadDate.day}/${doc.uploadDate.month}/${doc.uploadDate.year}',
                    ),
                  ],
                ),
              ),

              // Content area
              Flexible(
                child: bytes != null
                    ? _buildPreviewContent(bytes, ext, isImage, isText)
                    : _buildNoPreviewContent(doc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(
      Uint8List bytes, String ext, bool isImage, bool isText) {
    if (isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildErrorPreview(),
          ),
        ),
      );
    }

    if (isText) {
      String text;
      try {
        text = utf8.decode(bytes);
      } catch (_) {
        text = String.fromCharCodes(bytes);
      }
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: SingleChildScrollView(
          child: SelectableText(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // PDF / other — show file info
    return _buildFileInfoPreview(ext);
  }

  Widget _buildNoPreviewContent(CalculationAttachment doc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Preview not available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The file data is no longer in memory.\nRe-upload the document to enable preview.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPreview() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Unable to display image',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfoPreview(String ext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ext == 'pdf' ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                ext == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file,
                size: 48,
                color: ext == 'pdf' ? Colors.red[700] : Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '.${ext.toUpperCase()} File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preview is not supported for this file type.\nThe document has been attached successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
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
