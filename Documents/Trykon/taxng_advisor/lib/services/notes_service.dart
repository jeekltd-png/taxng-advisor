import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' if (dart.library.html) 'notes_service_stub.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Model for calculation notes
class CalculationNote {
  final String calculationId;
  final String note;
  final List<String> attachments; // File paths
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? category; // Optional categorization
  final List<String> tags; // Optional tags

  CalculationNote({
    required this.calculationId,
    required this.note,
    this.attachments = const [],
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'calculationId': calculationId,
      'note': note,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'category': category,
      'tags': tags,
    };
  }

  factory CalculationNote.fromMap(Map<String, dynamic> map) {
    return CalculationNote(
      calculationId: map['calculationId'],
      note: map['note'],
      attachments: List<String>.from(map['attachments'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      category: map['category'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

/// Service for managing calculation notes and attachments
class NotesService {
  static const String _notesBoxName = 'calculation_notes';
  static const String _attachmentsFolderName = 'attachments';

  /// Save or update a note for a calculation
  static Future<void> saveNote(CalculationNote note) async {
    try {
      final box = await Hive.openBox(_notesBoxName);
      await box.put(note.calculationId, note.toMap());
    } catch (e) {
      throw Exception('Error saving note: $e');
    }
  }

  /// Get note for a calculation
  static Future<CalculationNote?> getNote(String calculationId) async {
    try {
      final box = await Hive.openBox(_notesBoxName);
      final noteMap = box.get(calculationId);
      if (noteMap != null) {
        return CalculationNote.fromMap(Map<String, dynamic>.from(noteMap));
      }
    } catch (e) {
      debugPrint('Error getting note: $e');
    }
    return null;
  }

  /// Delete note for a calculation
  static Future<void> deleteNote(String calculationId) async {
    try {
      final box = await Hive.openBox(_notesBoxName);

      // Get note to find attachments
      final noteMap = box.get(calculationId);
      if (noteMap != null) {
        final note =
            CalculationNote.fromMap(Map<String, dynamic>.from(noteMap));

        // Delete attachments
        for (final filePath in note.attachments) {
          try {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint('Error deleting attachment: $e');
          }
        }
      }

      await box.delete(calculationId);
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }

  /// Check if a calculation has notes
  static Future<bool> hasNote(String calculationId) async {
    try {
      final box = await Hive.openBox(_notesBoxName);
      return box.containsKey(calculationId);
    } catch (e) {
      debugPrint('Error checking note: $e');
      return false;
    }
  }

  /// Get all notes
  static Future<List<CalculationNote>> getAllNotes() async {
    try {
      final box = await Hive.openBox(_notesBoxName);
      final notes = <CalculationNote>[];

      for (final value in box.values) {
        try {
          notes.add(CalculationNote.fromMap(Map<String, dynamic>.from(value)));
        } catch (e) {
          debugPrint('Error parsing note: $e');
        }
      }

      return notes;
    } catch (e) {
      debugPrint('Error getting all notes: $e');
      return [];
    }
  }

  /// Search notes by keyword
  static Future<List<CalculationNote>> searchNotes(String query) async {
    try {
      final allNotes = await getAllNotes();
      final lowerQuery = query.toLowerCase();

      return allNotes.where((note) {
        return note.note.toLowerCase().contains(lowerQuery) ||
            note.category?.toLowerCase().contains(lowerQuery) == true ||
            note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      debugPrint('Error searching notes: $e');
      return [];
    }
  }

  /// Pick and save attachment
  static Future<String?> addAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'doc',
          'docx',
          'xls',
          'xlsx'
        ],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Get app directory
        final appDir = await getApplicationDocumentsDirectory();
        final attachmentsDir =
            Directory(path.join(appDir.path, _attachmentsFolderName));

        // Create attachments directory if it doesn't exist
        if (!await attachmentsDir.exists()) {
          await attachmentsDir.create(recursive: true);
        }

        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(file.path);
        final newFileName = 'attachment_$timestamp$extension';
        final newPath = path.join(attachmentsDir.path, newFileName);

        // Copy file to app directory
        await file.copy(newPath);

        return newPath;
      }
    } catch (e) {
      debugPrint('Error adding attachment: $e');
    }
    return null;
  }

  /// Delete attachment
  static Future<void> deleteAttachment(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting attachment: $e');
    }
  }

  /// Get attachment file name
  static String getAttachmentName(String filePath) {
    return path.basename(filePath);
  }

  /// Get attachment size
  static Future<String> getAttachmentSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.length();
        if (bytes < 1024) {
          return '$bytes B';
        } else if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
    } catch (e) {
      debugPrint('Error getting attachment size: $e');
    }
    return 'Unknown';
  }

  /// Get notes count by category
  static Future<Map<String, int>> getNotesByCategory() async {
    try {
      final allNotes = await getAllNotes();
      final categoryCounts = <String, int>{};

      for (final note in allNotes) {
        final category = note.category ?? 'Uncategorized';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      return categoryCounts;
    } catch (e) {
      debugPrint('Error getting notes by category: $e');
      return {};
    }
  }

  /// Get all unique tags
  static Future<List<String>> getAllTags() async {
    try {
      final allNotes = await getAllNotes();
      final tags = <String>{};

      for (final note in allNotes) {
        tags.addAll(note.tags);
      }

      return tags.toList()..sort();
    } catch (e) {
      debugPrint('Error getting all tags: $e');
      return [];
    }
  }
}
