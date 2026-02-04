/// Tax deadline model for tracking important tax dates and reminders
library;

import 'package:flutter/material.dart';

/// Types of tax deadlines
enum TaxDeadlineType {
  vatFiling,
  vatPayment,
  citFiling,
  citPayment,
  pitFiling,
  pitPayment,
  whtRemittance,
  payrollTax,
  stampDuty,
  annualReturns,
  auditDeadline,
  custom,
}

/// Priority levels for deadlines
enum DeadlinePriority {
  low,
  medium,
  high,
  critical,
}

/// Status of a deadline
enum DeadlineStatus {
  upcoming,
  dueToday,
  overdue,
  completed,
  waived,
}

/// Tax deadline model
class TaxDeadline {
  final String id;
  final String title;
  final String description;
  final TaxDeadlineType type;
  final DateTime dueDate;
  final DateTime? completedDate;
  final DeadlinePriority priority;
  final DeadlineStatus status;
  final double? estimatedAmount;
  final String? currency;
  final bool isRecurring;
  final String? recurrencePattern;
  final int? reminderDaysBefore;
  final String? notes;
  final List<String>? attachmentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaxDeadline({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dueDate,
    this.completedDate,
    this.priority = DeadlinePriority.medium,
    this.status = DeadlineStatus.upcoming,
    this.estimatedAmount,
    this.currency = 'NGN',
    this.isRecurring = false,
    this.recurrencePattern,
    this.reminderDaysBefore = 7,
    this.notes,
    this.attachmentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return deadline.difference(today).inDays;
  }

  bool get isOverdue => daysRemaining < 0 && status != DeadlineStatus.completed;
  bool get isDueToday =>
      daysRemaining == 0 && status != DeadlineStatus.completed;

  bool get shouldShowReminder {
    if (status == DeadlineStatus.completed) return false;
    return daysRemaining <= (reminderDaysBefore ?? 7);
  }

  DeadlineStatus get computedStatus {
    if (status == DeadlineStatus.completed) return DeadlineStatus.completed;
    if (status == DeadlineStatus.waived) return DeadlineStatus.waived;
    if (isOverdue) return DeadlineStatus.overdue;
    if (isDueToday) return DeadlineStatus.dueToday;
    return DeadlineStatus.upcoming;
  }

  Color get statusColor {
    switch (computedStatus) {
      case DeadlineStatus.overdue:
        return const Color(0xFFE53935);
      case DeadlineStatus.dueToday:
        return const Color(0xFFFF6B35);
      case DeadlineStatus.upcoming:
        if (daysRemaining <= 7) return const Color(0xFFFFC107);
        return const Color(0xFF00CC99);
      case DeadlineStatus.completed:
        return const Color(0xFF4CAF50);
      case DeadlineStatus.waived:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TaxDeadlineType.vatFiling:
      case TaxDeadlineType.vatPayment:
        return Icons.receipt_long;
      case TaxDeadlineType.citFiling:
      case TaxDeadlineType.citPayment:
        return Icons.business;
      case TaxDeadlineType.pitFiling:
      case TaxDeadlineType.pitPayment:
        return Icons.person;
      case TaxDeadlineType.whtRemittance:
        return Icons.account_balance;
      case TaxDeadlineType.payrollTax:
        return Icons.groups;
      case TaxDeadlineType.stampDuty:
        return Icons.description;
      case TaxDeadlineType.annualReturns:
        return Icons.calendar_month;
      case TaxDeadlineType.auditDeadline:
        return Icons.fact_check;
      case TaxDeadlineType.custom:
        return Icons.event;
    }
  }

  String get typeName {
    switch (type) {
      case TaxDeadlineType.vatFiling:
        return 'VAT Filing';
      case TaxDeadlineType.vatPayment:
        return 'VAT Payment';
      case TaxDeadlineType.citFiling:
        return 'CIT Filing';
      case TaxDeadlineType.citPayment:
        return 'CIT Payment';
      case TaxDeadlineType.pitFiling:
        return 'PIT Filing';
      case TaxDeadlineType.pitPayment:
        return 'PIT Payment';
      case TaxDeadlineType.whtRemittance:
        return 'WHT Remittance';
      case TaxDeadlineType.payrollTax:
        return 'Payroll Tax';
      case TaxDeadlineType.stampDuty:
        return 'Stamp Duty';
      case TaxDeadlineType.annualReturns:
        return 'Annual Returns';
      case TaxDeadlineType.auditDeadline:
        return 'Audit Deadline';
      case TaxDeadlineType.custom:
        return 'Custom';
    }
  }

  TaxDeadline copyWith({
    String? id,
    String? title,
    String? description,
    TaxDeadlineType? type,
    DateTime? dueDate,
    DateTime? completedDate,
    DeadlinePriority? priority,
    DeadlineStatus? status,
    double? estimatedAmount,
    String? currency,
    bool? isRecurring,
    String? recurrencePattern,
    int? reminderDaysBefore,
    String? notes,
    List<String>? attachmentIds,
  }) {
    return TaxDeadline(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      currency: currency ?? this.currency,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'dueDate': dueDate.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'estimatedAmount': estimatedAmount,
        'currency': currency,
        'isRecurring': isRecurring,
        'recurrencePattern': recurrencePattern,
        'reminderDaysBefore': reminderDaysBefore,
        'notes': notes,
        'attachmentIds': attachmentIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TaxDeadline.fromJson(Map<String, dynamic> json) => TaxDeadline(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: TaxDeadlineType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TaxDeadlineType.custom,
        ),
        dueDate: DateTime.parse(json['dueDate'] as String),
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'] as String)
            : null,
        priority: DeadlinePriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => DeadlinePriority.medium,
        ),
        status: DeadlineStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => DeadlineStatus.upcoming,
        ),
        estimatedAmount: json['estimatedAmount'] as double?,
        currency: json['currency'] as String? ?? 'NGN',
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurrencePattern: json['recurrencePattern'] as String?,
        reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 7,
        notes: json['notes'] as String?,
        attachmentIds: (json['attachmentIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}

/// Nigerian tax calendar with standard deadlines
class NigerianTaxCalendar {
  static List<TaxDeadline> getStandardDeadlines(int year) {
    final deadlines = <TaxDeadline>[];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // VAT and WHT Monthly deadlines - 21st of following month
    for (int month = 1; month <= 12; month++) {
      final filingMonth = month == 12 ? 1 : month + 1;
      final filingYear = month == 12 ? year + 1 : year;

      deadlines.add(TaxDeadline(
        id: 'vat_${year}_$month',
        title: 'VAT Return - ${months[month - 1]} $year',
        description: 'File and pay VAT for ${months[month - 1]} $year',
        type: TaxDeadlineType.vatFiling,
        dueDate: DateTime(filingYear, filingMonth, 21),
        priority: DeadlinePriority.high,
        isRecurring: true,
        recurrencePattern: 'monthly',
      ));

      deadlines.add(TaxDeadline(
        id: 'wht_${year}_$month',
        title: 'WHT Remittance - ${months[month - 1]} $year',
        description: 'Remit withholding tax for ${months[month - 1]} $year',
        type: TaxDeadlineType.whtRemittance,
        dueDate: DateTime(filingYear, filingMonth, 21),
        priority: DeadlinePriority.high,
        isRecurring: true,
        recurrencePattern: 'monthly',
      ));

      // PAYE - 10th of following month
      deadlines.add(TaxDeadline(
        id: 'paye_${year}_$month',
        title: 'PAYE Remittance - ${months[month - 1]} $year',
        description: 'Remit PAYE tax for ${months[month - 1]} $year',
        type: TaxDeadlineType.payrollTax,
        dueDate: DateTime(filingYear, filingMonth, 10),
        priority: DeadlinePriority.high,
        isRecurring: true,
        recurrencePattern: 'monthly',
      ));
    }

    // Annual CIT - June 30th
    deadlines.add(TaxDeadline(
      id: 'cit_annual_$year',
      title: 'Company Income Tax Return - $year',
      description: 'File annual CIT return for fiscal year ${year - 1}',
      type: TaxDeadlineType.citFiling,
      dueDate: DateTime(year, 6, 30),
      priority: DeadlinePriority.critical,
      isRecurring: true,
      recurrencePattern: 'annually',
    ));

    // Annual PIT - March 31st
    deadlines.add(TaxDeadline(
      id: 'pit_annual_$year',
      title: 'Personal Income Tax Return - $year',
      description: 'File annual PIT return for tax year ${year - 1}',
      type: TaxDeadlineType.pitFiling,
      dueDate: DateTime(year, 3, 31),
      priority: DeadlinePriority.critical,
      isRecurring: true,
      recurrencePattern: 'annually',
    ));

    return deadlines;
  }
}
