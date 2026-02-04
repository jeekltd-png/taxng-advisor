import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/notes_service.dart';

/// Dialog for adding/editing notes for a calculation
class NotesDialog extends StatefulWidget {
  final String calculationId;
  final CalculationNote? existingNote;

  const NotesDialog({
    Key? key,
    required this.calculationId,
    this.existingNote,
  }) : super(key: key);

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  late TextEditingController _noteController;
  late TextEditingController _categoryController;
  late TextEditingController _tagController;
  final List<String> _attachments = [];
  final List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noteController =
        TextEditingController(text: widget.existingNote?.note ?? '');
    _categoryController =
        TextEditingController(text: widget.existingNote?.category ?? '');
    _tagController = TextEditingController();

    if (widget.existingNote != null) {
      _attachments.addAll(widget.existingNote!.attachments);
      _tags.addAll(widget.existingNote!.tags);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _addAttachment() async {
    setState(() => _isLoading = true);

    final filePath = await NotesService.addAttachment();

    setState(() => _isLoading = false);

    if (filePath != null) {
      setState(() {
        _attachments.add(filePath);
      });
    }
  }

  void _removeAttachment(String filePath) {
    setState(() {
      _attachments.remove(filePath);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final note = CalculationNote(
        calculationId: widget.calculationId,
        note: _noteController.text.trim(),
        attachments: _attachments,
        createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        tags: _tags,
      );

      await NotesService.saveNote(note);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_add, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.existingNote == null ? 'Add Note' : 'Edit Note',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Note field
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note *',
                        hintText: 'Enter your note here...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),

                    // Category field
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category (Optional)',
                        hintText: 'e.g., Important, Review, Follow-up',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add tag',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(12),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: Colors.blue[100],
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Attachments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _addAttachment,
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Add File'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_attachments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Text(
                            'No attachments',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _attachments.length,
                        itemBuilder: (context, index) {
                          final filePath = _attachments[index];
                          final fileName =
                              NotesService.getAttachmentName(filePath);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                _getFileIcon(fileName),
                                color: Colors.blue,
                              ),
                              title: Text(
                                fileName,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: FutureBuilder<String>(
                                future:
                                    NotesService.getAttachmentSize(filePath),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? 'Loading...',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeAttachment(filePath),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveNote,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Saving...' : 'Save Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// Button to show note indicator
class NoteIndicatorButton extends StatelessWidget {
  final String calculationId;
  final VoidCallback? onPressed;

  const NoteIndicatorButton({
    Key? key,
    required this.calculationId,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: NotesService.hasNote(calculationId),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return IconButton(
            icon: const Icon(Icons.note, color: Colors.orange),
            onPressed: onPressed,
            tooltip: 'View note',
          );
        }
        return IconButton(
          icon: Icon(Icons.note_add_outlined, color: Colors.grey[400]),
          onPressed: onPressed,
          tooltip: 'Add note',
        );
      },
    );
  }
}
