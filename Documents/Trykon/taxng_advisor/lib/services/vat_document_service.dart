import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';

/// Model for attached documents
class VatDocument {
  final String id;
  final String filePath;
  final String filename;
  final String
      fileType; // 'purchase_invoice', 'sales_invoice', 'bank_statement', 'other'
  final DateTime uploadedAt;
  final String vatPeriod;
  final int vatYear;
  final String? description;
  final double? amount;
  final double? vatAmount;

  VatDocument({
    required this.id,
    required this.filePath,
    required this.filename,
    required this.fileType,
    required this.uploadedAt,
    required this.vatPeriod,
    required this.vatYear,
    this.description,
    this.amount,
    this.vatAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'filename': filename,
      'fileType': fileType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'vatPeriod': vatPeriod,
      'vatYear': vatYear,
      'description': description,
      'amount': amount,
      'vatAmount': vatAmount,
    };
  }

  factory VatDocument.fromMap(Map<String, dynamic> map) {
    return VatDocument(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      filename: map['filename'] as String,
      fileType: map['fileType'] as String,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
      vatPeriod: map['vatPeriod'] as String,
      vatYear: map['vatYear'] as int,
      description: map['description'] as String?,
      amount: map['amount'] as double?,
      vatAmount: map['vatAmount'] as double?,
    );
  }
}

/// Service for managing VAT-related document attachments
class VatDocumentService {
  static const String boxName = 'vat_documents';

  /// Initialize the document storage box
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  /// Pick and upload a document file
  static Future<VatDocument?> pickAndUploadDocument({
    required String fileType,
    required String vatPeriod,
    required int vatYear,
    String? description,
    double? amount,
    double? vatAmount,
  }) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) {
        return null;
      }

      // Create document record
      final document = VatDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: filePath,
        filename: file.name,
        fileType: fileType,
        uploadedAt: DateTime.now(),
        vatPeriod: vatPeriod,
        vatYear: vatYear,
        description: description,
        amount: amount,
        vatAmount: vatAmount,
      );

      // Save to Hive
      final box = Hive.box(boxName);
      await box.put(document.id, document.toMap());

      return document;
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }

  /// Save a document record
  static Future<void> saveDocument(VatDocument document) async {
    final box = Hive.box(boxName);
    await box.put(document.id, document.toMap());
  }

  /// Get all documents for a specific VAT period
  static List<VatDocument> getDocumentsForPeriod(String period, int year) {
    final box = Hive.box(boxName);
    final documents = <VatDocument>[];

    for (var key in box.keys) {
      final data = box.get(key) as Map<String, dynamic>;
      final document = VatDocument.fromMap(data);

      if (document.vatPeriod == period && document.vatYear == year) {
        documents.add(document);
      }
    }

    // Sort by upload date (newest first)
    documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    return documents;
  }

  /// Get all documents by type
  static List<VatDocument> getDocumentsByType(String fileType) {
    final box = Hive.box(boxName);
    final documents = <VatDocument>[];

    for (var key in box.keys) {
      final data = box.get(key) as Map<String, dynamic>;
      final document = VatDocument.fromMap(data);

      if (document.fileType == fileType) {
        documents.add(document);
      }
    }

    documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    return documents;
  }

  /// Get all documents
  static List<VatDocument> getAllDocuments() {
    final box = Hive.box(boxName);
    final documents = <VatDocument>[];

    for (var key in box.keys) {
      final data = box.get(key) as Map<String, dynamic>;
      documents.add(VatDocument.fromMap(data));
    }

    documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    return documents;
  }

  /// Delete a document
  static Future<void> deleteDocument(String documentId) async {
    final box = Hive.box(boxName);
    await box.delete(documentId);
  }

  /// Get document by ID
  static VatDocument? getDocument(String documentId) {
    final box = Hive.box(boxName);
    final data = box.get(documentId) as Map<String, dynamic>?;

    if (data == null) return null;

    return VatDocument.fromMap(data);
  }

  /// Get summary statistics for a period
  static Map<String, dynamic> getDocumentSummary(String period, int year) {
    final documents = getDocumentsForPeriod(period, year);

    int purchaseInvoices = 0;
    int salesInvoices = 0;
    int bankStatements = 0;
    int others = 0;
    double totalPurchaseAmount = 0;
    double totalSalesAmount = 0;
    double totalInputVat = 0;
    double totalOutputVat = 0;

    for (var doc in documents) {
      switch (doc.fileType) {
        case 'purchase_invoice':
          purchaseInvoices++;
          if (doc.amount != null) totalPurchaseAmount += doc.amount!;
          if (doc.vatAmount != null) totalInputVat += doc.vatAmount!;
          break;
        case 'sales_invoice':
          salesInvoices++;
          if (doc.amount != null) totalSalesAmount += doc.amount!;
          if (doc.vatAmount != null) totalOutputVat += doc.vatAmount!;
          break;
        case 'bank_statement':
          bankStatements++;
          break;
        default:
          others++;
      }
    }

    return {
      'totalDocuments': documents.length,
      'purchaseInvoices': purchaseInvoices,
      'salesInvoices': salesInvoices,
      'bankStatements': bankStatements,
      'others': others,
      'totalPurchaseAmount': totalPurchaseAmount,
      'totalSalesAmount': totalSalesAmount,
      'totalInputVat': totalInputVat,
      'totalOutputVat': totalOutputVat,
    };
  }

  /// Check if sufficient documents are attached for FIRS submission
  static bool hasRequiredDocuments(String period, int year) {
    final summary = getDocumentSummary(period, year);

    // Minimum requirements for FIRS submission
    return summary['purchaseInvoices'] > 0 && summary['salesInvoices'] > 0;
  }

  /// Get document count by period
  static Map<String, int> getDocumentCountByPeriod() {
    final box = Hive.box(boxName);
    final counts = <String, int>{};

    for (var key in box.keys) {
      final data = box.get(key) as Map<String, dynamic>;
      final document = VatDocument.fromMap(data);
      final periodKey = '${document.vatPeriod} ${document.vatYear}';

      counts[periodKey] = (counts[periodKey] ?? 0) + 1;
    }

    return counts;
  }

  /// Clear all documents for a period
  static Future<void> clearDocumentsForPeriod(String period, int year) async {
    final box = Hive.box(boxName);
    final keysToDelete = <String>[];

    for (var key in box.keys) {
      final data = box.get(key) as Map<String, dynamic>;
      final document = VatDocument.fromMap(data);

      if (document.vatPeriod == period && document.vatYear == year) {
        keysToDelete.add(document.id);
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// Update document details
  static Future<void> updateDocument({
    required String documentId,
    String? description,
    double? amount,
    double? vatAmount,
  }) async {
    final document = getDocument(documentId);
    if (document == null) return;

    final updatedDocument = VatDocument(
      id: document.id,
      filePath: document.filePath,
      filename: document.filename,
      fileType: document.fileType,
      uploadedAt: document.uploadedAt,
      vatPeriod: document.vatPeriod,
      vatYear: document.vatYear,
      description: description ?? document.description,
      amount: amount ?? document.amount,
      vatAmount: vatAmount ?? document.vatAmount,
    );

    await saveDocument(updatedDocument);
  }
}
