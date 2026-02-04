/// Calculation history model for audit trail and tracking
library;

import 'package:flutter/material.dart';

/// Types of tax calculations
enum CalculationType { vat, cit, pit, wht, payroll, stampDuty }

/// Calculation history entry model
class CalculationHistory {
  final String id;
  final CalculationType type;
  final String title;
  final DateTime calculatedAt;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;
  final double? totalTax;
  final String? currency;
  final String? notes;
  final List<String>? attachmentIds;
  final bool isSaved;
  final bool isExported;
  final DateTime? exportedAt;
  final String? exportFormat;

  CalculationHistory({
    required this.id,
    required this.type,
    required this.title,
    required this.calculatedAt,
    required this.inputs,
    required this.outputs,
    this.totalTax,
    this.currency = 'NGN',
    this.notes,
    this.attachmentIds,
    this.isSaved = false,
    this.isExported = false,
    this.exportedAt,
    this.exportFormat,
  });

  IconData get typeIcon {
    switch (type) {
      case CalculationType.vat:
        return Icons.receipt_long;
      case CalculationType.cit:
        return Icons.business;
      case CalculationType.pit:
        return Icons.person;
      case CalculationType.wht:
        return Icons.account_balance;
      case CalculationType.payroll:
        return Icons.groups;
      case CalculationType.stampDuty:
        return Icons.description;
    }
  }

  Color get typeColor {
    switch (type) {
      case CalculationType.vat:
        return const Color(0xFF0066FF);
      case CalculationType.cit:
        return const Color(0xFF00CC99);
      case CalculationType.pit:
        return const Color(0xFFFF6B35);
      case CalculationType.wht:
        return const Color(0xFF9C27B0);
      case CalculationType.payroll:
        return const Color(0xFF2196F3);
      case CalculationType.stampDuty:
        return const Color(0xFF795548);
    }
  }

  String get typeName {
    switch (type) {
      case CalculationType.vat:
        return 'VAT';
      case CalculationType.cit:
        return 'Company Income Tax';
      case CalculationType.pit:
        return 'Personal Income Tax';
      case CalculationType.wht:
        return 'Withholding Tax';
      case CalculationType.payroll:
        return 'Payroll Tax';
      case CalculationType.stampDuty:
        return 'Stamp Duty';
    }
  }

  String get typeCode {
    switch (type) {
      case CalculationType.vat:
        return 'VAT';
      case CalculationType.cit:
        return 'CIT';
      case CalculationType.pit:
        return 'PIT';
      case CalculationType.wht:
        return 'WHT';
      case CalculationType.payroll:
        return 'PAY';
      case CalculationType.stampDuty:
        return 'SD';
    }
  }

  CalculationHistory copyWith({
    String? id,
    CalculationType? type,
    String? title,
    DateTime? calculatedAt,
    Map<String, dynamic>? inputs,
    Map<String, dynamic>? outputs,
    double? totalTax,
    String? currency,
    String? notes,
    List<String>? attachmentIds,
    bool? isSaved,
    bool? isExported,
    DateTime? exportedAt,
    String? exportFormat,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      totalTax: totalTax ?? this.totalTax,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      isSaved: isSaved ?? this.isSaved,
      isExported: isExported ?? this.isExported,
      exportedAt: exportedAt ?? this.exportedAt,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'calculatedAt': calculatedAt.toIso8601String(),
        'inputs': inputs,
        'outputs': outputs,
        'totalTax': totalTax,
        'currency': currency,
        'notes': notes,
        'attachmentIds': attachmentIds,
        'isSaved': isSaved,
        'isExported': isExported,
        'exportedAt': exportedAt?.toIso8601String(),
        'exportFormat': exportFormat,
      };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) =>
      CalculationHistory(
        id: json['id'] as String,
        type: CalculationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CalculationType.vat,
        ),
        title: json['title'] as String,
        calculatedAt: DateTime.parse(json['calculatedAt'] as String),
        inputs: Map<String, dynamic>.from(json['inputs'] as Map),
        outputs: Map<String, dynamic>.from(json['outputs'] as Map),
        totalTax: json['totalTax'] as double?,
        currency: json['currency'] as String? ?? 'NGN',
        notes: json['notes'] as String?,
        attachmentIds: (json['attachmentIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        isSaved: json['isSaved'] as bool? ?? false,
        isExported: json['isExported'] as bool? ?? false,
        exportedAt: json['exportedAt'] != null
            ? DateTime.parse(json['exportedAt'] as String)
            : null,
        exportFormat: json['exportFormat'] as String?,
      );
}

/// Filter options for calculation history
class HistoryFilter {
  final List<CalculationType>? types;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minAmount;
  final double? maxAmount;
  final bool? savedOnly;
  final String? searchQuery;

  HistoryFilter({
    this.types,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    this.savedOnly,
    this.searchQuery,
  });

  bool matches(CalculationHistory history) {
    if (types != null && types!.isNotEmpty && !types!.contains(history.type)) {
      return false;
    }
    if (fromDate != null && history.calculatedAt.isBefore(fromDate!)) {
      return false;
    }
    if (toDate != null && history.calculatedAt.isAfter(toDate!)) {
      return false;
    }
    if (minAmount != null && (history.totalTax ?? 0) < minAmount!) {
      return false;
    }
    if (maxAmount != null && (history.totalTax ?? 0) > maxAmount!) {
      return false;
    }
    if (savedOnly == true && !history.isSaved) {
      return false;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!history.title.toLowerCase().contains(query) &&
          !history.typeName.toLowerCase().contains(query)) {
        return false;
      }
    }
    return true;
  }
}

/// Summary statistics for calculation history
class HistorySummary {
  final int totalCalculations;
  final Map<CalculationType, int> calculationsByType;
  final double totalTaxCalculated;
  final Map<CalculationType, double> taxByType;
  final DateTime? firstCalculation;
  final DateTime? lastCalculation;

  HistorySummary({
    required this.totalCalculations,
    required this.calculationsByType,
    required this.totalTaxCalculated,
    required this.taxByType,
    this.firstCalculation,
    this.lastCalculation,
  });

  factory HistorySummary.fromHistories(List<CalculationHistory> histories) {
    if (histories.isEmpty) {
      return HistorySummary(
        totalCalculations: 0,
        calculationsByType: {},
        totalTaxCalculated: 0,
        taxByType: {},
      );
    }

    final calculationsByType = <CalculationType, int>{};
    final taxByType = <CalculationType, double>{};
    double totalTax = 0;

    for (final history in histories) {
      calculationsByType[history.type] =
          (calculationsByType[history.type] ?? 0) + 1;
      taxByType[history.type] =
          (taxByType[history.type] ?? 0) + (history.totalTax ?? 0);
      totalTax += history.totalTax ?? 0;
    }

    final sorted = histories.toList()
      ..sort((a, b) => a.calculatedAt.compareTo(b.calculatedAt));

    return HistorySummary(
      totalCalculations: histories.length,
      calculationsByType: calculationsByType,
      totalTaxCalculated: totalTax,
      taxByType: taxByType,
      firstCalculation: sorted.first.calculatedAt,
      lastCalculation: sorted.last.calculatedAt,
    );
  }
}
