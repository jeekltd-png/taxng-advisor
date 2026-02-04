import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/expense_category.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/services/expense_category_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/utils/currency_formatter.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _currentUser;
  List<ExpenseCategory> _categories = [];
  List<ExpenseEntry> _expenses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ExpenseCategoryType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await ExpenseCategoryService.initializeCategories();

      final usersBox = HiveService.getUsersBox();
      final currentUserId = usersBox.get('current_user_id');

      if (currentUserId != null) {
        final userData = usersBox.get(currentUserId);
        if (userData != null) {
          _currentUser =
              UserProfile.fromMap(Map<String, dynamic>.from(userData));
          _expenses =
              await ExpenseCategoryService.getUserExpenses(_currentUser!.id);
        }
      }

      _categories = await ExpenseCategoryService.getAllCategories();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  List<ExpenseCategory> get _filteredCategories {
    return _categories.where((c) {
      if (!c.isActive) return false;
      if (_filterType != null && c.type != _filterType) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return c.name.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query) ||
            c.keywords.any((k) => k.toLowerCase().contains(query));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories', icon: Icon(Icons.category)),
            Tab(text: 'Expenses', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Expense',
            onPressed: () => _showAddExpenseDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(),
                _buildExpensesTab(),
                _buildAnalyticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', null),
                    _buildFilterChip(
                        'Operations', ExpenseCategoryType.businessOperations),
                    _buildFilterChip(
                        'Employee', ExpenseCategoryType.employeeCosts),
                    _buildFilterChip(
                        'Services', ExpenseCategoryType.professionalServices),
                    _buildFilterChip(
                        'Marketing', ExpenseCategoryType.marketing),
                    _buildFilterChip('Travel', ExpenseCategoryType.travel),
                    _buildFilterChip(
                        'Office', ExpenseCategoryType.officeExpenses),
                    _buildFilterChip(
                        'Financial', ExpenseCategoryType.financial),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredCategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No categories found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(_filteredCategories[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, ExpenseCategoryType? type) {
    final isSelected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterType = selected ? type : null;
          });
        },
      ),
    );
  }

  Widget _buildCategoryCard(ExpenseCategory category) {
    final expenseCount =
        _expenses.where((e) => e.categoryId == category.id).length;
    final totalAmount = _expenses
        .where((e) => e.categoryId == category.id)
        .fold<double>(0, (sum, e) => sum + e.amount);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.2),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (category.isDeductible)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Deductible',
                      style: TextStyle(fontSize: 10, color: Colors.green[700]),
                    ),
                  ),
                if (category.firsCode != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    category.firsCode!,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatNaira(totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              '$expenseCount expenses',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        onTap: () => _showCategoryDetails(category),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to start tracking',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddExpenseDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      );
    }

    // Group expenses by date
    final grouped = <String, List<ExpenseEntry>>{};
    for (var expense in _expenses) {
      final dateKey = _formatDate(expense.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final dateKey = sortedKeys[index];
          final dayExpenses = grouped[dateKey]!;
          final dayTotal =
              dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateKey,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatNaira(dayTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ...dayExpenses.map((expense) => _buildExpenseCard(expense)),
              const Divider(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseEntry expense) {
    final category = _categories.firstWhere(
      (c) => c.id == expense.categoryId,
      orElse: () => _categories.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.2),
          radius: 20,
          child: Icon(category.icon, color: category.color, size: 18),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              category.name,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (expense.vendor != null) ...[
              const SizedBox(width: 8),
              Text(
                '• ${expense.vendor}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatNaira(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (expense.isDeductible)
              Text(
                'Deductible',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[600],
                ),
              ),
          ],
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final totalExpenses = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final deductibleAmount = _expenses
        .where((e) => e.isDeductible)
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Group by category type
    final byType = <ExpenseCategoryType, double>{};
    for (var expense in _expenses) {
      final category = _categories.firstWhere(
        (c) => c.id == expense.categoryId,
        orElse: () => _categories.first,
      );
      byType[category.type] = (byType[category.type] ?? 0) + expense.amount;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Expenses',
                CurrencyFormatter.formatNaira(totalExpenses),
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Deductible',
                CurrencyFormatter.formatNaira(deductibleAmount),
                Icons.savings,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Categories Used',
                '${_expenses.map((e) => e.categoryId).toSet().length}',
                Icons.category,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Transactions',
                '${_expenses.length}',
                Icons.swap_horiz,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Breakdown by Type
        const Text(
          'Breakdown by Category Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...byType.entries.map((entry) {
          final percentage =
              totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0;
          return _buildBreakdownRow(
            entry.key.name,
            entry.value,
            percentage.toDouble(),
            _getTypeColor(entry.key),
          );
        }),

        const SizedBox(height: 24),

        // Top Categories
        const Text(
          'Top Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<Map<String, double>>(
          future: _currentUser != null
              ? ExpenseCategoryService.getExpenseSummaryByCategory(
                  _currentUser!.id)
              : Future.value({}),
          builder: (context, snapshot) {
            final summary = snapshot.data ?? {};
            final sortedEntries = summary.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return Column(
              children: sortedEntries.take(5).map((entry) {
                final category = _categories.firstWhere(
                  (c) => c.id == entry.key,
                  orElse: () => _categories.first,
                );
                final percentage =
                    totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withOpacity(0.2),
                      child:
                          Icon(category.icon, color: category.color, size: 18),
                    ),
                    title: Text(category.name),
                    subtitle: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      color: category.color,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatNaira(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
      String label, double amount, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
              Text(
                CurrencyFormatter.formatNaira(amount),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ExpenseCategoryType type) {
    switch (type) {
      case ExpenseCategoryType.businessOperations:
        return Colors.blue;
      case ExpenseCategoryType.employeeCosts:
        return Colors.purple;
      case ExpenseCategoryType.professionalServices:
        return Colors.teal;
      case ExpenseCategoryType.marketing:
        return Colors.pink;
      case ExpenseCategoryType.travel:
        return Colors.cyan;
      case ExpenseCategoryType.officeExpenses:
        return Colors.green;
      case ExpenseCategoryType.utilities:
        return Colors.orange;
      case ExpenseCategoryType.financial:
        return Colors.indigo;
      case ExpenseCategoryType.taxes:
        return Colors.red;
      case ExpenseCategoryType.depreciation:
        return Colors.brown;
      case ExpenseCategoryType.other:
        return Colors.grey;
    }
  }

  void _showCategoryDetails(ExpenseCategory category) {
    final categoryExpenses =
        _expenses.where((e) => e.categoryId == category.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.2),
                        radius: 28,
                        child: Icon(category.icon,
                            color: category.color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              category.typeLabel,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (category.isDeductible)
                        Chip(
                          label: const Text('Tax Deductible'),
                          backgroundColor: Colors.green[50],
                          avatar: Icon(Icons.check,
                              size: 16, color: Colors.green[700]),
                        ),
                      if (category.firsCode != null)
                        Chip(
                          label: Text('FIRS: ${category.firsCode}'),
                          backgroundColor: Colors.blue[50],
                        ),
                      if (category.deductionLimit != null)
                        Chip(
                          label: Text(
                              '${(category.deductionLimit! * 100).toInt()}% limit'),
                          backgroundColor: Colors.orange[50],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (category.keywords.isNotEmpty) ...[
                    const Text(
                      'Keywords',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: category.keywords.map((k) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(k, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Recent Expenses (${categoryExpenses.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (categoryExpenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No expenses in this category',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ...categoryExpenses
                        .take(5)
                        .map((e) => _buildExpenseCard(e)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExpenseDetails(ExpenseEntry expense) {
    final category = _categories.firstWhere(
      (c) => c.id == expense.categoryId,
      orElse: () => _categories.first,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.description),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Amount', CurrencyFormatter.formatNaira(expense.amount)),
              _buildDetailRow('Category', category.name),
              _buildDetailRow('Date', _formatDate(expense.transactionDate)),
              if (expense.vendor != null)
                _buildDetailRow('Vendor', expense.vendor!),
              if (expense.notes != null)
                _buildDetailRow('Notes', expense.notes!),
              _buildDetailRow(
                  'Deductible', expense.isDeductible ? 'Yes' : 'No'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ExpenseCategoryService.deleteExpense(expense.id);
                _loadData();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final vendorController = TextEditingController();
    final notesController = TextEditingController();
    ExpenseCategory? selectedCategory;
    DateTime selectedDate = DateTime.now();
    bool isDeductible = true;
    ExpenseCategory? suggestedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_card, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Add Expense',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₦ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g., Office supplies from Shoprite',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) async {
                        // Get ML suggestion
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        final suggestion =
                            await ExpenseCategoryService.suggestCategory(
                          value,
                          amount,
                          vendorController.text,
                        );
                        setModalState(() {
                          suggestedCategory = suggestion;
                        });
                      },
                    ),
                    if (suggestedCategory != null &&
                        selectedCategory?.id != suggestedCategory?.id) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setModalState(() {
                            selectedCategory = suggestedCategory;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: Colors.blue[700], size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Suggested: ${suggestedCategory!.name}',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                              const Spacer(),
                              Text(
                                'Tap to use',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: vendorController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor (optional)',
                        hintText: 'e.g., Shoprite',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExpenseCategory>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: _categories.where((c) => c.isActive).map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon, size: 18, color: c.color),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value;
                          isDeductible = value?.isDeductible ?? true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transaction Date'),
                      subtitle: Text(_formatDate(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setModalState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tax Deductible'),
                      value: isDeductible,
                      onChanged: (value) {
                        setModalState(() {
                          isDeductible = value;
                        });
                      },
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentUser == null ||
                              selectedCategory == null ||
                              amountController.text.isEmpty ||
                              descriptionController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in required fields'),
                              ),
                            );
                            return;
                          }

                          await ExpenseCategoryService.addExpense(
                            userId: _currentUser!.id,
                            categoryId: selectedCategory!.id,
                            amount: double.parse(amountController.text),
                            description: descriptionController.text,
                            vendor: vendorController.text.isEmpty
                                ? null
                                : vendorController.text,
                            transactionDate: selectedDate,
                            notes: notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Expense added!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Add Expense'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
