import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MediaPickerService {
  /// Pick image from camera or gallery
  /// Returns file path if successful, null if cancelled
  Future<PickedFileResult?> pickImage({bool fromCamera = false}) async {
    // Note: image_picker doesn't work on web, use file_picker instead
    if (kIsWeb) {
      return await _pickFileWeb(
        type: FileType.image,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      );
    }

    // For mobile/desktop, we'll use file_picker for simplicity
    // (image_picker requires additional setup for camera permissions)
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return PickedFileResult(
          path: file.path!,
          name: file.name,
          size: file.size,
          extension: file.extension ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick PDF document
  Future<PickedFileResult?> pickPDF() async {
    return await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
  }

  /// Pick any document (PDF, DOC, DOCX, XLS, XLSX)
  Future<PickedFileResult?> pickDocument() async {
    return await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'csv', 'txt'],
    );
  }

  /// Pick any file
  Future<PickedFileResult?> pickAnyFile() async {
    return await _pickFile(type: FileType.any);
  }

  /// Internal method to pick file
  Future<PickedFileResult?> _pickFile({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // On web, bytes are available but path is not
        if (kIsWeb) {
          return PickedFileResult(
            path: '', // No path on web
            name: file.name,
            size: file.size,
            extension: file.extension ?? '',
            bytes: file.bytes,
          );
        }

        return PickedFileResult(
          path: file.path!,
          name: file.name,
          size: file.size,
          extension: file.extension ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Internal method for web file picking
  Future<PickedFileResult?> _pickFileWeb({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    return await _pickFile(
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }

  /// Determine file type from extension
  String getFileType(String extension) {
    final ext = extension.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return 'image';
    } else if (ext == 'pdf') {
      return 'pdf';
    } else if (['doc', 'docx', 'xls', 'xlsx', 'csv', 'txt'].contains(ext)) {
      return 'document';
    } else {
      return 'file';
    }
  }

  /// Validate file size (max 10MB by default)
  bool isFileSizeValid(int sizeInBytes, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return sizeInBytes <= maxSizeBytes;
  }

  /// Validate file extension
  bool isFileTypeValid(String extension, List<String> allowedExtensions) {
    return allowedExtensions.contains(extension.toLowerCase());
  }

  /// Get file size formatted
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Result object for picked files
class PickedFileResult {
  final String path;
  final String name;
  final int size;
  final String extension;
  final List<int>? bytes; // For web platform

  PickedFileResult({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
    this.bytes,
  });

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
      .contains(extension.toLowerCase());

  bool get isPDF => extension.toLowerCase() == 'pdf';

  bool get isDocument => ['doc', 'docx', 'xls', 'xlsx', 'csv', 'txt']
      .contains(extension.toLowerCase());

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  File? get file => path.isNotEmpty ? File(path) : null;
}
