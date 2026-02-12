import 'dart:io' if (dart.library.html) 'attachment_service_stub.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/calculation_attachment.dart';

class AttachmentService {
  static const String _boxName = 'attachments';
  late Box<CalculationAttachment> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<CalculationAttachment>(_boxName);
  }

  /// Save an attachment for a calculation
  Future<CalculationAttachment> saveAttachment({
    required String calculationId,
    required String sourceFilePath,
    required String fileName,
    required String fileType,
    String? description,
  }) async {
    if (kIsWeb) {
      // On web, store metadata only (no filesystem access)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final attachment = CalculationAttachment(
        id: '${calculationId}_$timestamp',
        calculationId: calculationId,
        filePath: sourceFilePath,
        fileType: fileType,
        fileName: fileName,
        uploadDate: DateTime.now(),
        description: description,
        fileSizeBytes: 0,
      );
      await _box.put(attachment.id, attachment);
      return attachment;
    }

    // Native: Create app documents directory for attachments
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir =
        Directory('${appDir.path}/attachments/$calculationId');

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    // Copy file to app directory
    final sourceFile = File(sourceFilePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final destinationPath = '${attachmentsDir.path}/${timestamp}_$fileName';
    final destinationFile = await sourceFile.copy(destinationPath);

    // Get file size
    final fileSize = await destinationFile.length();

    // Create attachment record
    final attachment = CalculationAttachment(
      id: '${calculationId}_$timestamp',
      calculationId: calculationId,
      filePath: destinationPath,
      fileType: fileType,
      fileName: fileName,
      uploadDate: DateTime.now(),
      description: description,
      fileSizeBytes: fileSize,
    );

    // Save to Hive
    await _box.put(attachment.id, attachment);

    return attachment;
  }

  /// Get all attachments for a calculation
  List<CalculationAttachment> getAttachments(String calculationId) {
    return _box.values
        .where((attachment) => attachment.calculationId == calculationId)
        .toList()
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  }

  /// Get single attachment by ID
  CalculationAttachment? getAttachment(String attachmentId) {
    return _box.get(attachmentId);
  }

  /// Delete an attachment
  Future<void> deleteAttachment(String attachmentId) async {
    final attachment = _box.get(attachmentId);
    if (attachment != null) {
      if (!kIsWeb) {
        // Delete file from disk (native only)
        final file = File(attachment.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Remove from Hive
      await _box.delete(attachmentId);
    }
  }

  /// Delete all attachments for a calculation
  Future<void> deleteCalculationAttachments(String calculationId) async {
    final attachments = getAttachments(calculationId);
    for (final attachment in attachments) {
      await deleteAttachment(attachment.id);
    }

    // Delete calculation directory if empty (native only)
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final calcDir = Directory('${appDir.path}/attachments/$calculationId');
        if (await calcDir.exists()) {
          final contents = await calcDir.list().toList();
          if (contents.isEmpty) {
            await calcDir.delete();
          }
        }
      } catch (e) {
        // Directory might not exist, ignore
      }
    }
  }

  /// Get total size of all attachments for a calculation
  int getCalculationAttachmentsSize(String calculationId) {
    final attachments = getAttachments(calculationId);
    return attachments.fold(
        0, (sum, attachment) => sum + attachment.fileSizeBytes);
  }

  /// Check if file exists on disk
  Future<bool> fileExists(String filePath) async {
    if (kIsWeb) return false;
    return await File(filePath).exists();
  }

  /// Clean up orphaned files (files without database records)
  Future<void> cleanupOrphanedFiles() async {
    if (kIsWeb) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory('${appDir.path}/attachments');

      if (!await attachmentsDir.exists()) return;

      final allFiles = <String>[];
      await for (final entity in attachmentsDir.list(recursive: true)) {
        if (entity is File) {
          allFiles.add(entity.path);
        }
      }

      final registeredFiles = _box.values.map((a) => a.filePath).toSet();

      for (final filePath in allFiles) {
        if (!registeredFiles.contains(filePath)) {
          await File(filePath).delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Get all attachments count
  int get totalAttachmentsCount => _box.length;

  /// Get total storage used by all attachments
  int get totalStorageUsed {
    return _box.values
        .fold(0, (sum, attachment) => sum + attachment.fileSizeBytes);
  }

  String get totalStorageFormatted {
    final bytes = totalStorageUsed;
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
