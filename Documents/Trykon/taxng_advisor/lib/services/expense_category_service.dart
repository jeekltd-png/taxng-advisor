/// Expense categorization service with ML-powered suggestions
library;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taxng_advisor/models/expense_category.dart';

class ExpenseCategoryService {
  static const String _categoriesBox = 'expense_categories';
  static const String _expensesBox = 'expense_entries';
  static const String _rulesBox = 'category_rules';

  static Future<void> _ensureBoxOpen(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  /// Initialize default categories
  static Future<void> initializeCategories() async {
    await _ensureBoxOpen(_categoriesBox);
    final box = Hive.box(_categoriesBox);

    if (box.isEmpty) {
      final defaultCategories = _getDefaultCategories();
      for (var category in defaultCategories) {
        await box.put(category.id, category.toMap());
      }
    }
  }

  /// Get all default categories
  static List<ExpenseCategory> _getDefaultCategories() {
    final now = DateTime.now();
    return [
      // Business Operations
      ExpenseCategory(
        id: 'cat_rent',
        name: 'Rent & Lease',
        description: 'Office rent, warehouse lease, equipment lease',
        type: ExpenseCategoryType.businessOperations,
        icon: Icons.home_work,
        color: const Color(0xFF2196F3),
        isSystem: true,
        isDeductible: true,
        firsCode: 'BO001',
        keywords: ['rent', 'lease', 'property', 'office', 'warehouse'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_utilities',
        name: 'Utilities',
        description: 'Electricity, water, internet, phone bills',
        type: ExpenseCategoryType.utilities,
        icon: Icons.electrical_services,
        color: const Color(0xFFFF9800),
        isSystem: true,
        isDeductible: true,
        firsCode: 'UT001',
        keywords: [
          'electricity',
          'nepa',
          'phcn',
          'water',
          'internet',
          'mtn',
          'airtel',
          'glo',
          'phone'
        ],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_supplies',
        name: 'Office Supplies',
        description: 'Stationery, printing, office consumables',
        type: ExpenseCategoryType.officeExpenses,
        icon: Icons.inventory_2,
        color: const Color(0xFF4CAF50),
        isSystem: true,
        isDeductible: true,
        firsCode: 'OF001',
        keywords: [
          'stationery',
          'paper',
          'printing',
          'ink',
          'toner',
          'supplies'
        ],
        createdAt: now,
      ),

      // Employee Costs
      ExpenseCategory(
        id: 'cat_salaries',
        name: 'Salaries & Wages',
        description: 'Employee salaries, wages, bonuses',
        type: ExpenseCategoryType.employeeCosts,
        icon: Icons.people,
        color: const Color(0xFF9C27B0),
        isSystem: true,
        isDeductible: true,
        firsCode: 'EC001',
        keywords: ['salary', 'wages', 'bonus', 'staff', 'payroll'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_pension',
        name: 'Pension Contributions',
        description: 'Employer pension contributions',
        type: ExpenseCategoryType.employeeCosts,
        icon: Icons.elderly,
        color: const Color(0xFF673AB7),
        isSystem: true,
        isDeductible: true,
        firsCode: 'EC002',
        keywords: ['pension', 'pencom', 'retirement', 'pfa'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_nhf',
        name: 'NHF Contributions',
        description: 'National Housing Fund contributions',
        type: ExpenseCategoryType.employeeCosts,
        icon: Icons.house,
        color: const Color(0xFF3F51B5),
        isSystem: true,
        isDeductible: true,
        firsCode: 'EC003',
        keywords: ['nhf', 'housing fund', 'fmbn'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_training',
        name: 'Training & Development',
        description: 'Staff training, courses, certifications',
        type: ExpenseCategoryType.employeeCosts,
        icon: Icons.school,
        color: const Color(0xFF00BCD4),
        isSystem: true,
        isDeductible: true,
        firsCode: 'EC004',
        keywords: [
          'training',
          'course',
          'certification',
          'workshop',
          'seminar'
        ],
        createdAt: now,
      ),

      // Professional Services
      ExpenseCategory(
        id: 'cat_legal',
        name: 'Legal Fees',
        description: 'Legal services, litigation, contracts',
        type: ExpenseCategoryType.professionalServices,
        icon: Icons.gavel,
        color: const Color(0xFF795548),
        isSystem: true,
        isDeductible: true,
        firsCode: 'PS001',
        keywords: ['legal', 'lawyer', 'attorney', 'litigation', 'court'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_accounting',
        name: 'Accounting & Audit',
        description: 'Accounting services, audit fees, tax consulting',
        type: ExpenseCategoryType.professionalServices,
        icon: Icons.calculate,
        color: const Color(0xFF607D8B),
        isSystem: true,
        isDeductible: true,
        firsCode: 'PS002',
        keywords: [
          'accounting',
          'audit',
          'tax',
          'bookkeeping',
          'cpa',
          'accountant'
        ],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_consulting',
        name: 'Consulting Fees',
        description: 'Business consulting, advisory services',
        type: ExpenseCategoryType.professionalServices,
        icon: Icons.business_center,
        color: const Color(0xFF9E9E9E),
        isSystem: true,
        isDeductible: true,
        firsCode: 'PS003',
        keywords: ['consulting', 'consultant', 'advisory', 'management'],
        createdAt: now,
      ),

      // Marketing
      ExpenseCategory(
        id: 'cat_advertising',
        name: 'Advertising',
        description: 'Ads, promotions, media buying',
        type: ExpenseCategoryType.marketing,
        icon: Icons.campaign,
        color: const Color(0xFFE91E63),
        isSystem: true,
        isDeductible: true,
        firsCode: 'MK001',
        keywords: [
          'advertising',
          'ads',
          'facebook',
          'google',
          'instagram',
          'radio',
          'tv'
        ],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_marketing',
        name: 'Marketing & PR',
        description: 'Marketing campaigns, public relations',
        type: ExpenseCategoryType.marketing,
        icon: Icons.trending_up,
        color: const Color(0xFFF44336),
        isSystem: true,
        isDeductible: true,
        firsCode: 'MK002',
        keywords: ['marketing', 'pr', 'branding', 'promotion', 'event'],
        createdAt: now,
      ),

      // Travel
      ExpenseCategory(
        id: 'cat_travel',
        name: 'Travel Expenses',
        description: 'Business travel, flights, hotels',
        type: ExpenseCategoryType.travel,
        icon: Icons.flight,
        color: const Color(0xFF00BCD4),
        isSystem: true,
        isDeductible: true,
        firsCode: 'TR001',
        keywords: [
          'travel',
          'flight',
          'hotel',
          'accommodation',
          'arik',
          'airpeace',
          'dana'
        ],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_transport',
        name: 'Local Transport',
        description: 'Local transportation, fuel, vehicle maintenance',
        type: ExpenseCategoryType.travel,
        icon: Icons.directions_car,
        color: const Color(0xFF009688),
        isSystem: true,
        isDeductible: true,
        firsCode: 'TR002',
        keywords: [
          'transport',
          'fuel',
          'petrol',
          'diesel',
          'uber',
          'bolt',
          'taxi',
          'maintenance'
        ],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_meals',
        name: 'Meals & Entertainment',
        description: 'Business meals, client entertainment',
        type: ExpenseCategoryType.travel,
        icon: Icons.restaurant,
        color: const Color(0xFFFF5722),
        isSystem: true,
        isDeductible: true,
        deductionLimit: 0.5, // 50% deductible
        firsCode: 'TR003',
        keywords: [
          'meal',
          'lunch',
          'dinner',
          'restaurant',
          'entertainment',
          'client'
        ],
        createdAt: now,
      ),

      // Financial
      ExpenseCategory(
        id: 'cat_interest',
        name: 'Interest Expense',
        description: 'Loan interest, bank charges',
        type: ExpenseCategoryType.financial,
        icon: Icons.account_balance,
        color: const Color(0xFF3F51B5),
        isSystem: true,
        isDeductible: true,
        firsCode: 'FN001',
        keywords: ['interest', 'loan', 'bank charges', 'finance'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_bankfees',
        name: 'Bank Fees',
        description: 'Bank charges, transfer fees, card fees',
        type: ExpenseCategoryType.financial,
        icon: Icons.credit_card,
        color: const Color(0xFF5C6BC0),
        isSystem: true,
        isDeductible: true,
        firsCode: 'FN002',
        keywords: ['bank', 'transfer', 'charges', 'stamp duty', 'sms', 'token'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_insurance',
        name: 'Insurance',
        description: 'Business insurance, health insurance',
        type: ExpenseCategoryType.financial,
        icon: Icons.security,
        color: const Color(0xFF7986CB),
        isSystem: true,
        isDeductible: true,
        firsCode: 'FN003',
        keywords: [
          'insurance',
          'premium',
          'policy',
          'aiico',
          'leadway',
          'custodian'
        ],
        createdAt: now,
      ),

      // Taxes
      ExpenseCategory(
        id: 'cat_taxes',
        name: 'Taxes & Levies',
        description: 'Government taxes and levies (non-deductible)',
        type: ExpenseCategoryType.taxes,
        icon: Icons.receipt_long,
        color: const Color(0xFF8BC34A),
        isSystem: true,
        isDeductible: false,
        firsCode: 'TX001',
        keywords: ['tax', 'levy', 'firs', 'lirs', 'vat', 'wht'],
        createdAt: now,
      ),

      // Depreciation
      ExpenseCategory(
        id: 'cat_depreciation',
        name: 'Depreciation',
        description: 'Asset depreciation expenses',
        type: ExpenseCategoryType.depreciation,
        icon: Icons.trending_down,
        color: const Color(0xFF607D8B),
        isSystem: true,
        isDeductible: true,
        firsCode: 'DP001',
        keywords: ['depreciation', 'amortization', 'asset'],
        createdAt: now,
      ),

      // Other
      ExpenseCategory(
        id: 'cat_repairs',
        name: 'Repairs & Maintenance',
        description: 'Equipment repairs, building maintenance',
        type: ExpenseCategoryType.businessOperations,
        icon: Icons.build,
        color: const Color(0xFFFF7043),
        isSystem: true,
        isDeductible: true,
        firsCode: 'BO002',
        keywords: ['repair', 'maintenance', 'fix', 'service', 'technician'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_software',
        name: 'Software & Subscriptions',
        description: 'Software licenses, SaaS subscriptions',
        type: ExpenseCategoryType.officeExpenses,
        icon: Icons.apps,
        color: const Color(0xFF42A5F5),
        isSystem: true,
        isDeductible: true,
        firsCode: 'OF002',
        keywords: [
          'software',
          'subscription',
          'license',
          'saas',
          'microsoft',
          'google',
          'zoom'
        ],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_donations',
        name: 'Charitable Donations',
        description: 'Donations to approved charities',
        type: ExpenseCategoryType.other,
        icon: Icons.volunteer_activism,
        color: const Color(0xFFAB47BC),
        isSystem: true,
        isDeductible: true,
        deductionLimit: 0.1, // 10% of assessable profit
        firsCode: 'OT001',
        keywords: ['donation', 'charity', 'contribution', 'giving'],
        createdAt: now,
      ),
      ExpenseCategory(
        id: 'cat_other',
        name: 'Other Expenses',
        description: 'Miscellaneous business expenses',
        type: ExpenseCategoryType.other,
        icon: Icons.more_horiz,
        color: const Color(0xFF78909C),
        isSystem: true,
        isDeductible: true,
        firsCode: 'OT999',
        keywords: ['other', 'miscellaneous', 'misc'],
        createdAt: now,
      ),
    ];
  }

  // ==================== CATEGORY METHODS ====================

  /// Get all categories
  static Future<List<ExpenseCategory>> getAllCategories() async {
    await _ensureBoxOpen(_categoriesBox);
    final box = Hive.box(_categoriesBox);

    final categories = <ExpenseCategory>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        categories.add(
            ExpenseCategory.fromMap(Map<String, dynamic>.from(data as Map)));
      }
    }

    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  /// Get active categories
  static Future<List<ExpenseCategory>> getActiveCategories() async {
    final all = await getAllCategories();
    return all.where((c) => c.isActive).toList();
  }

  /// Get categories by type
  static Future<List<ExpenseCategory>> getCategoriesByType(
      ExpenseCategoryType type) async {
    final all = await getAllCategories();
    return all.where((c) => c.type == type && c.isActive).toList();
  }

  /// Get category by ID
  static Future<ExpenseCategory?> getCategory(String id) async {
    await _ensureBoxOpen(_categoriesBox);
    final box = Hive.box(_categoriesBox);

    final data = box.get(id);
    if (data == null) return null;
    return ExpenseCategory.fromMap(Map<String, dynamic>.from(data as Map));
  }

  /// Create custom category
  static Future<ExpenseCategory> createCategory({
    required String name,
    required String description,
    required ExpenseCategoryType type,
    IconData icon = Icons.category,
    Color color = Colors.grey,
    bool isDeductible = true,
    double? deductionLimit,
    List<String> keywords = const [],
  }) async {
    await _ensureBoxOpen(_categoriesBox);
    final box = Hive.box(_categoriesBox);

    final category = ExpenseCategory(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      type: type,
      icon: icon,
      color: color,
      isSystem: false,
      isDeductible: isDeductible,
      deductionLimit: deductionLimit,
      keywords: keywords,
      createdAt: DateTime.now(),
    );

    await box.put(category.id, category.toMap());
    return category;
  }

  /// Update category
  static Future<void> updateCategory(ExpenseCategory category) async {
    await _ensureBoxOpen(_categoriesBox);
    final box = Hive.box(_categoriesBox);
    await box.put(
        category.id, category.copyWith(modifiedAt: DateTime.now()).toMap());
  }

  /// Delete category (only custom categories)
  static Future<bool> deleteCategory(String id) async {
    final category = await getCategory(id);
    if (category == null || category.isSystem) return false;

    await _ensureBoxOpen(_categoriesBox);
    final box = Hive.box(_categoriesBox);
    await box.delete(id);
    return true;
  }

  /// Increment category usage count
  static Future<void> incrementUsage(String categoryId) async {
    final category = await getCategory(categoryId);
    if (category != null) {
      await updateCategory(
          category.copyWith(usageCount: category.usageCount + 1));
    }
  }

  // ==================== EXPENSE METHODS ====================

  /// Add expense entry
  static Future<ExpenseEntry> addExpense({
    required String userId,
    required String categoryId,
    required double amount,
    required String description,
    String? vendor,
    required DateTime transactionDate,
    String? receiptPath,
    String? notes,
    String? taxType,
  }) async {
    await _ensureBoxOpen(_expensesBox);
    final box = Hive.box(_expensesBox);

    // Get category suggestion
    final suggestion = await suggestCategory(description, amount, vendor);

    final expense = ExpenseEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      categoryId: categoryId,
      suggestedCategoryId: suggestion?.id != categoryId ? suggestion?.id : null,
      amount: amount,
      description: description,
      vendor: vendor,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
      receiptPath: receiptPath,
      notes: notes,
      taxType: taxType,
      confidenceScore: suggestion?.id == categoryId ? 1.0 : null,
    );

    await box.put(expense.id, expense.toMap());
    await incrementUsage(categoryId);
    return expense;
  }

  /// Get expenses for user
  static Future<List<ExpenseEntry>> getUserExpenses(String userId) async {
    await _ensureBoxOpen(_expensesBox);
    final box = Hive.box(_expensesBox);

    final expenses = <ExpenseEntry>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['userId'] == userId) {
          expenses.add(ExpenseEntry.fromMap(map));
        }
      }
    }

    expenses.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return expenses;
  }

  /// Get expenses by category
  static Future<List<ExpenseEntry>> getExpensesByCategory(
      String userId, String categoryId) async {
    final all = await getUserExpenses(userId);
    return all.where((e) => e.categoryId == categoryId).toList();
  }

  /// Get expenses by date range
  static Future<List<ExpenseEntry>> getExpensesByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final all = await getUserExpenses(userId);
    return all
        .where((e) =>
            e.transactionDate
                .isAfter(start.subtract(const Duration(days: 1))) &&
            e.transactionDate.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Delete expense
  static Future<void> deleteExpense(String id) async {
    await _ensureBoxOpen(_expensesBox);
    final box = Hive.box(_expensesBox);
    await box.delete(id);
  }

  /// Update expense
  static Future<void> updateExpense(ExpenseEntry expense) async {
    await _ensureBoxOpen(_expensesBox);
    final box = Hive.box(_expensesBox);
    await box.put(expense.id, expense.toMap());
  }

  // ==================== ML CATEGORIZATION ====================

  /// Suggest category based on description, amount, and vendor
  static Future<ExpenseCategory?> suggestCategory(
    String description,
    double amount,
    String? vendor,
  ) async {
    final categories = await getActiveCategories();
    if (categories.isEmpty) return null;

    final descLower = description.toLowerCase();
    final vendorLower = vendor?.toLowerCase() ?? '';
    final combined = '$descLower $vendorLower';

    // Score each category
    final scores = <String, double>{};
    for (var category in categories) {
      double score = 0;

      // Keyword matching (highest weight)
      for (var keyword in category.keywords) {
        if (combined.contains(keyword.toLowerCase())) {
          score += 10;
        }
      }

      // Name matching
      if (combined.contains(category.name.toLowerCase())) {
        score += 5;
      }

      // Usage frequency bonus (popular categories get slight boost)
      score += category.usageCount * 0.01;

      if (score > 0) {
        scores[category.id] = score;
      }
    }

    if (scores.isEmpty) return null;

    // Get highest scoring category
    final bestId =
        scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return categories.firstWhere((c) => c.id == bestId);
  }

  /// Batch categorize transactions
  static Future<Map<String, ExpenseCategory?>> batchSuggestCategories(
    List<Map<String, dynamic>> transactions,
  ) async {
    final results = <String, ExpenseCategory?>{};
    for (var tx in transactions) {
      final id = tx['id'] as String;
      final description = tx['description'] as String;
      final amount = (tx['amount'] as num).toDouble();
      final vendor = tx['vendor'] as String?;

      results[id] = await suggestCategory(description, amount, vendor);
    }
    return results;
  }

  // ==================== RULES ====================

  /// Add categorization rule
  static Future<CategoryRule> addRule({
    required String categoryId,
    required String ruleType,
    required String pattern,
    double? minAmount,
    double? maxAmount,
    int priority = 0,
  }) async {
    await _ensureBoxOpen(_rulesBox);
    final box = Hive.box(_rulesBox);

    final rule = CategoryRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: categoryId,
      ruleType: ruleType,
      pattern: pattern,
      minAmount: minAmount,
      maxAmount: maxAmount,
      priority: priority,
      createdAt: DateTime.now(),
    );

    await box.put(rule.id, rule.toMap());
    return rule;
  }

  /// Get rules for category
  static Future<List<CategoryRule>> getRulesForCategory(
      String categoryId) async {
    await _ensureBoxOpen(_rulesBox);
    final box = Hive.box(_rulesBox);

    final rules = <CategoryRule>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['categoryId'] == categoryId) {
          rules.add(CategoryRule.fromMap(map));
        }
      }
    }

    rules.sort((a, b) => b.priority.compareTo(a.priority));
    return rules;
  }

  // ==================== ANALYTICS ====================

  /// Get expense summary by category
  static Future<Map<String, double>> getExpenseSummaryByCategory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<ExpenseEntry> expenses;
    if (startDate != null && endDate != null) {
      expenses = await getExpensesByDateRange(userId, startDate, endDate);
    } else {
      expenses = await getUserExpenses(userId);
    }

    final summary = <String, double>{};
    for (var expense in expenses) {
      summary[expense.categoryId] =
          (summary[expense.categoryId] ?? 0) + expense.amount;
    }

    return summary;
  }

  /// Get total deductible amount
  static Future<double> getTotalDeductible(String userId,
      {String? taxType}) async {
    final expenses = await getUserExpenses(userId);
    final categories = await getAllCategories();
    final categoryMap = {for (var c in categories) c.id: c};

    double total = 0;
    for (var expense in expenses) {
      if (taxType != null && expense.taxType != taxType) continue;

      final category = categoryMap[expense.categoryId];
      if (category?.isDeductible ?? false) {
        if (category!.deductionLimit != null) {
          total += expense.amount * category.deductionLimit!;
        } else {
          total += expense.amount;
        }
      }
    }

    return total;
  }

  /// Get category statistics
  static Future<Map<String, dynamic>> getCategoryStatistics() async {
    final categories = await getAllCategories();
    final active = categories.where((c) => c.isActive).length;
    final custom = categories.where((c) => !c.isSystem).length;
    final deductible = categories.where((c) => c.isDeductible).length;
    final mostUsed = categories.isNotEmpty
        ? categories.reduce((a, b) => a.usageCount > b.usageCount ? a : b)
        : null;

    return {
      'total': categories.length,
      'active': active,
      'custom': custom,
      'deductible': deductible,
      'mostUsed': mostUsed?.name,
      'mostUsedCount': mostUsed?.usageCount ?? 0,
    };
  }
}
