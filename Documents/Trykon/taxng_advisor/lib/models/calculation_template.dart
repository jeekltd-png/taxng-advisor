import 'package:hive/hive.dart';

part 'calculation_template.g.dart';

/// Calculation Template Model - Stores reusable calculation templates
@HiveType(typeId: 10)
class CalculationTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String taxType; // CIT, PIT, VAT, WHT, PAYE, Stamp Duty

  @HiveField(3)
  Map<String, dynamic> templateData;

  @HiveField(4)
  String category; // Monthly, Quarterly, Annual, Custom

  @HiveField(5)
  String? description;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastUsedAt;

  @HiveField(8)
  int usageCount;

  CalculationTemplate({
    required this.id,
    required this.name,
    required this.taxType,
    required this.templateData,
    required this.category,
    this.description,
    required this.createdAt,
    this.lastUsedAt,
    this.usageCount = 0,
  });

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'taxType': taxType,
      'templateData': templateData,
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// Create from Map
  factory CalculationTemplate.fromMap(Map<String, dynamic> map) {
    return CalculationTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      taxType: map['taxType'] as String,
      templateData: Map<String, dynamic>.from(map['templateData'] as Map),
      category: map['category'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUsedAt: map['lastUsedAt'] != null
          ? DateTime.parse(map['lastUsedAt'] as String)
          : null,
      usageCount: map['usageCount'] as int? ?? 0,
    );
  }

  /// Copy with
  CalculationTemplate copyWith({
    String? id,
    String? name,
    String? taxType,
    Map<String, dynamic>? templateData,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? usageCount,
  }) {
    return CalculationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      taxType: taxType ?? this.taxType,
      templateData: templateData ?? this.templateData,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
