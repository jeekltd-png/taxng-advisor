/// Expense category model for smart expense categorization
library;

import 'package:flutter/material.dart';

/// Main expense category types
enum ExpenseCategoryType {
  businessOperations,
  employeeCosts,
  professionalServices,
  marketing,
  travel,
  officeExpenses,
  utilities,
  financial,
  taxes,
  depreciation,
  other,
}

/// Expense category model
class ExpenseCategory {
  final String id;
  final String name;
  final String description;
  final ExpenseCategoryType type;
  final IconData icon;
  final Color color;
  final String? parentCategoryId;
  final bool isSystem; // System-defined vs user-created
  final bool isActive;
  final bool isDeductible; // Tax deductible
  final double? deductionLimit; // Max deduction limit
  final String? firsCode; // FIRS expense code
  final List<String> keywords; // Keywords for auto-categorization
  final int usageCount; // How many times used
  final DateTime createdAt;
  final DateTime? modifiedAt;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    this.parentCategoryId,
    this.isSystem = false,
    this.isActive = true,
    this.isDeductible = true,
    this.deductionLimit,
    this.firsCode,
    this.keywords = const [],
    this.usageCount = 0,
    required this.createdAt,
    this.modifiedAt,
  });

  String get typeLabel {
    switch (type) {
      case ExpenseCategoryType.businessOperations:
        return 'Business Operations';
      case ExpenseCategoryType.employeeCosts:
        return 'Employee Costs';
      case ExpenseCategoryType.professionalServices:
        return 'Professional Services';
      case ExpenseCategoryType.marketing:
        return 'Marketing & Advertising';
      case ExpenseCategoryType.travel:
        return 'Travel & Entertainment';
      case ExpenseCategoryType.officeExpenses:
        return 'Office Expenses';
      case ExpenseCategoryType.utilities:
        return 'Utilities';
      case ExpenseCategoryType.financial:
        return 'Financial Expenses';
      case ExpenseCategoryType.taxes:
        return 'Taxes & Levies';
      case ExpenseCategoryType.depreciation:
        return 'Depreciation';
      case ExpenseCategoryType.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'icon': icon.codePoint,
      'color': color.value,
      'parentCategoryId': parentCategoryId,
      'isSystem': isSystem,
      'isActive': isActive,
      'isDeductible': isDeductible,
      'deductionLimit': deductionLimit,
      'firsCode': firsCode,
      'keywords': keywords,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> m) {
    return ExpenseCategory(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String,
      type: ExpenseCategoryType.values[m['type'] as int? ?? 0],
      icon: IconData(m['icon'] as int? ?? Icons.category.codePoint,
          fontFamily: 'MaterialIcons'),
      color: Color(m['color'] as int? ?? Colors.grey.value),
      parentCategoryId: m['parentCategoryId'] as String?,
      isSystem: m['isSystem'] as bool? ?? false,
      isActive: m['isActive'] as bool? ?? true,
      isDeductible: m['isDeductible'] as bool? ?? true,
      deductionLimit: (m['deductionLimit'] as num?)?.toDouble(),
      firsCode: m['firsCode'] as String?,
      keywords: (m['keywords'] as List?)?.cast<String>() ?? [],
      usageCount: m['usageCount'] as int? ?? 0,
      createdAt: DateTime.parse(m['createdAt'] as String),
      modifiedAt: m['modifiedAt'] != null
          ? DateTime.parse(m['modifiedAt'] as String)
          : null,
    );
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? description,
    ExpenseCategoryType? type,
    IconData? icon,
    Color? color,
    String? parentCategoryId,
    bool? isSystem,
    bool? isActive,
    bool? isDeductible,
    double? deductionLimit,
    String? firsCode,
    List<String>? keywords,
    int? usageCount,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      isDeductible: isDeductible ?? this.isDeductible,
      deductionLimit: deductionLimit ?? this.deductionLimit,
      firsCode: firsCode ?? this.firsCode,
      keywords: keywords ?? this.keywords,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}

/// Expense entry model
class ExpenseEntry {
  final String id;
  final String userId;
  final String categoryId;
  final String? suggestedCategoryId; // ML suggestion
  final double amount;
  final String currency;
  final String description;
  final String? vendor;
  final DateTime transactionDate;
  final DateTime createdAt;
  final String? receiptPath;
  final String? notes;
  final bool isDeductible;
  final double? deductibleAmount;
  final String? taxType; // 'CIT', 'PIT', 'VAT'
  final bool isVerified;
  final double? confidenceScore; // ML confidence (0-1)
  final Map<String, dynamic>? metadata;

  ExpenseEntry({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.suggestedCategoryId,
    required this.amount,
    this.currency = 'NGN',
    required this.description,
    this.vendor,
    required this.transactionDate,
    required this.createdAt,
    this.receiptPath,
    this.notes,
    this.isDeductible = true,
    this.deductibleAmount,
    this.taxType,
    this.isVerified = false,
    this.confidenceScore,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'suggestedCategoryId': suggestedCategoryId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'vendor': vendor,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'receiptPath': receiptPath,
      'notes': notes,
      'isDeductible': isDeductible,
      'deductibleAmount': deductibleAmount,
      'taxType': taxType,
      'isVerified': isVerified,
      'confidenceScore': confidenceScore,
      'metadata': metadata,
    };
  }

  factory ExpenseEntry.fromMap(Map<String, dynamic> m) {
    return ExpenseEntry(
      id: m['id'] as String,
      userId: m['userId'] as String,
      categoryId: m['categoryId'] as String,
      suggestedCategoryId: m['suggestedCategoryId'] as String?,
      amount: (m['amount'] as num).toDouble(),
      currency: m['currency'] as String? ?? 'NGN',
      description: m['description'] as String,
      vendor: m['vendor'] as String?,
      transactionDate: DateTime.parse(m['transactionDate'] as String),
      createdAt: DateTime.parse(m['createdAt'] as String),
      receiptPath: m['receiptPath'] as String?,
      notes: m['notes'] as String?,
      isDeductible: m['isDeductible'] as bool? ?? true,
      deductibleAmount: (m['deductibleAmount'] as num?)?.toDouble(),
      taxType: m['taxType'] as String?,
      isVerified: m['isVerified'] as bool? ?? false,
      confidenceScore: (m['confidenceScore'] as num?)?.toDouble(),
      metadata: m['metadata'] as Map<String, dynamic>?,
    );
  }

  ExpenseEntry copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? suggestedCategoryId,
    double? amount,
    String? currency,
    String? description,
    String? vendor,
    DateTime? transactionDate,
    DateTime? createdAt,
    String? receiptPath,
    String? notes,
    bool? isDeductible,
    double? deductibleAmount,
    String? taxType,
    bool? isVerified,
    double? confidenceScore,
    Map<String, dynamic>? metadata,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      suggestedCategoryId: suggestedCategoryId ?? this.suggestedCategoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      receiptPath: receiptPath ?? this.receiptPath,
      notes: notes ?? this.notes,
      isDeductible: isDeductible ?? this.isDeductible,
      deductibleAmount: deductibleAmount ?? this.deductibleAmount,
      taxType: taxType ?? this.taxType,
      isVerified: isVerified ?? this.isVerified,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Category rule for auto-categorization
class CategoryRule {
  final String id;
  final String categoryId;
  final String ruleType; // 'keyword', 'vendor', 'amount_range', 'regex'
  final String pattern;
  final double? minAmount;
  final double? maxAmount;
  final int priority; // Higher = more important
  final bool isActive;
  final int matchCount; // Times rule matched
  final DateTime createdAt;

  CategoryRule({
    required this.id,
    required this.categoryId,
    required this.ruleType,
    required this.pattern,
    this.minAmount,
    this.maxAmount,
    this.priority = 0,
    this.isActive = true,
    this.matchCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'ruleType': ruleType,
      'pattern': pattern,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'priority': priority,
      'isActive': isActive,
      'matchCount': matchCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryRule.fromMap(Map<String, dynamic> m) {
    return CategoryRule(
      id: m['id'] as String,
      categoryId: m['categoryId'] as String,
      ruleType: m['ruleType'] as String,
      pattern: m['pattern'] as String,
      minAmount: (m['minAmount'] as num?)?.toDouble(),
      maxAmount: (m['maxAmount'] as num?)?.toDouble(),
      priority: m['priority'] as int? ?? 0,
      isActive: m['isActive'] as bool? ?? true,
      matchCount: m['matchCount'] as int? ?? 0,
      createdAt: DateTime.parse(m['createdAt'] as String),
    );
  }
}
