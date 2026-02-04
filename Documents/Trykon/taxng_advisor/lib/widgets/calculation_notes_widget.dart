import 'dart:io';
import 'package:flutter/material.dart';
import '../models/calculation_attachment.dart';
import '../services/attachment_service.dart';
import '../services/media_picker_service.dart';

/// Reusable widget for adding notes and attachments to calculations
class CalculationNotesWidget extends StatefulWidget {
  final TextEditingController notesController;
  final List<CalculationAttachment> attachments;
  final Function(CalculationAttachment) onAttachmentAdded;
  final Function(CalculationAttachment) onAttachmentRemoved;
  final String? calculationId; // For storing attachments

  const CalculationNotesWidget({
    super.key,
    required this.notesController,
    required this.attachments,
    required this.onAttachmentAdded,
    required this.onAttachmentRemoved,
    this.calculationId,
  });

  @override
  State<CalculationNotesWidget> createState() => _CalculationNotesWidgetState();
}

class _CalculationNotesWidgetState extends State<CalculationNotesWidget> {
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

  Future<void> _pickImage() async {
    setState(() => _isUploading = true);

    try {
      final result = await _mediaPicker.pickImage();
      if (result != null && mounted) {
        await _saveAttachment(result, 'image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickDocument() async {
    setState(() => _isUploading = true);

    try {
      final result = await _mediaPicker.pickDocument();
      if (result != null && mounted) {
        final fileType = _mediaPicker.getFileType(result.extension);
        await _saveAttachment(result, fileType);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick document: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveAttachment(PickedFileResult result, String fileType) async {
    // Validate file size (max 10MB)
    if (!_mediaPicker.isFileSizeValid(result.size)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File too large. Maximum size is 10MB.'),
          ),
        );
      }
      return;
    }

    try {
      final calcId = widget.calculationId ??
          'temp_${DateTime.now().millisecondsSinceEpoch}';

      final attachment = await _attachmentService.saveAttachment(
        calculationId: calcId,
        sourceFilePath: result.path,
        fileName: result.name,
        fileType: fileType,
      );

      widget.onAttachmentAdded(attachment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} attached successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save attachment: $e')),
        );
      }
    }
  }

  Future<void> _removeAttachment(CalculationAttachment attachment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Attachment'),
        content: Text('Remove ${attachment.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _attachmentService.deleteAttachment(attachment.id);
        widget.onAttachmentRemoved(attachment);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attachment removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove attachment: $e')),
          );
        }
      }
    }
  }

  void _viewAttachment(CalculationAttachment attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attachment.fileName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attachment.fileType == 'image')
              Image.file(
                File(attachment.filePath),
                height: 300,
                fit: BoxFit.contain,
              )
            else ...[
              Text('Type: ${attachment.fileType.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Size: ${attachment.fileSizeFormatted}'),
              const SizedBox(height: 8),
              Text('Uploaded: ${_formatDate(attachment.uploadDate)}'),
            ],
          ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note_add, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Data Source & Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: Colors.blue, size: 20),
                  tooltip: 'Learn more',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Data Source & Notes'),
                        content: const SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This section allows you to record the source of your calculation data and attach supporting documents.\n\n'
                                '📝 Notes:\n'
                                'Record where your data came from (e.g., "Q4 2025 Financial Statement", "Invoice #ABC123", "December Payroll Records")\n\n'
                                '📷 Photo:\n'
                                'Attach images of physical documents, receipts, or invoices\n\n'
                                '📄 Document:\n'
                                'Attach digital files (PDF, Excel, Word, etc.)\n\n'
                                '✅ Benefits:\n'
                                '• Evidence for tax audit trail\n'
                                '• Included in payment confirmation emails\n'
                                '• Helps with record-keeping\n'
                                '• Makes tax filing easier\n\n'
                                'Maximum file size: 10MB per file',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it!'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Document where this data came from (optional)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Notes TextField
            TextField(
              controller: widget.notesController,
              decoration: const InputDecoration(
                hintText: 'e.g., "Q4 bank statement", "Invoice #1234"',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 12),

            // Attachment Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Photo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickDocument,
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Document'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                if (_isUploading) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),

            // Attachments List
            if (widget.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Attached Files:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.attachments.map((attachment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Text(
                          attachment.fileIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attachment.fileName,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                attachment.fileSizeFormatted,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 18),
                          onPressed: () => _viewAttachment(attachment),
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => _removeAttachment(attachment),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
