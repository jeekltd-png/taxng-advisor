import 'package:hive/hive.dart';

// part 'calculation_attachment.g.dart';

@HiveType(typeId: 20)
class CalculationAttachment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String calculationId;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final String fileType; // 'image', 'pdf', 'document'

  @HiveField(4)
  final String fileName;

  @HiveField(5)
  final DateTime uploadDate;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final int fileSizeBytes;

  CalculationAttachment({
    required this.id,
    required this.calculationId,
    required this.filePath,
    required this.fileType,
    required this.fileName,
    required this.uploadDate,
    this.description,
    required this.fileSizeBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calculationId': calculationId,
      'filePath': filePath,
      'fileType': fileType,
      'fileName': fileName,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'fileSizeBytes': fileSizeBytes,
    };
  }

  factory CalculationAttachment.fromMap(Map<String, dynamic> map) {
    return CalculationAttachment(
      id: map['id'] as String,
      calculationId: map['calculationId'] as String,
      filePath: map['filePath'] as String,
      fileType: map['fileType'] as String,
      fileName: map['fileName'] as String,
      uploadDate: DateTime.parse(map['uploadDate'] as String),
      description: map['description'] as String?,
      fileSizeBytes: map['fileSizeBytes'] as int,
    );
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get fileIcon {
    switch (fileType) {
      case 'image':
        return '📷';
      case 'pdf':
        return '📄';
      case 'document':
        return '📎';
      default:
        return '📁';
    }
  }
}
