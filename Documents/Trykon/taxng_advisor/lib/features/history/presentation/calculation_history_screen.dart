/// Calculation History Screen - View and manage calculation history (Audit Trail)
library;

import 'package:flutter/material.dart';
import '../../../models/calculation_history.dart';
import '../../../services/calculation_history_service.dart';
import '../../../widgets/common/taxng_app_bar.dart';

class CalculationHistoryScreen extends StatefulWidget {
  const CalculationHistoryScreen({super.key});

  @override
  State<CalculationHistoryScreen> createState() =>
      _CalculationHistoryScreenState();
}

class _CalculationHistoryScreenState extends State<CalculationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CalculationHistoryService _historyService = CalculationHistoryService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';
  CalculationType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    await _historyService.initialize();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CalculationHistory> get _filteredHistory {
    var history = _historyService.sortedHistory;

    if (_searchQuery.isNotEmpty) {
      history = history
          .where((h) =>
              h.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              h.type.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedType != null) {
      history = history.where((h) => h.type == _selectedType).toList();
    }

    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TaxNGAppBar(
        title: 'Calculation History',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.history)),
            Tab(text: 'Saved', icon: Icon(Icons.bookmark)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(),
                _buildSavedTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  Widget _buildAllTab() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadHistory,
            child: _filteredHistory.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(_filteredHistory),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search calculations...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('VAT', CalculationType.vat),
                _buildFilterChip('CIT', CalculationType.cit),
                _buildFilterChip('PIT', CalculationType.pit),
                _buildFilterChip('WHT', CalculationType.wht),
                _buildFilterChip('Payroll', CalculationType.payroll),
                _buildFilterChip('Stamp Duty', CalculationType.stampDuty),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CalculationType? type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedType = selected ? type : null);
        },
        selectedColor: const Color(0xFF0066FF).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF0066FF),
      ),
    );
  }

  Widget _buildSavedTab() {
    final savedHistory = _historyService.savedCalculations;

    if (savedHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No saved calculations',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon to save a calculation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: _buildHistoryList(savedHistory),
    );
  }

  Widget _buildAnalyticsTab() {
    final summary = _historyService.summary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(summary),
          const SizedBox(height: 24),
          const Text(
            'Calculations by Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTypeBreakdown(summary),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...(_historyService.recentCalculations.take(5).map(
                (h) => _buildHistoryCard(h),
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(HistorySummary summary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF00AAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  summary.totalCalculations.toString(),
                  'Total',
                  Icons.calculate,
                ),
                _buildStatItem(
                  _historyService.savedCalculations.length.toString(),
                  'Saved',
                  Icons.bookmark,
                ),
                _buildStatItem(
                  _formatCurrency(summary.totalTaxCalculated),
                  'Total Tax',
                  Icons.attach_money,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBreakdown(HistorySummary summary) {
    final typeNames = {
      CalculationType.vat: 'VAT',
      CalculationType.cit: 'CIT',
      CalculationType.pit: 'PIT',
      CalculationType.wht: 'WHT',
      CalculationType.payroll: 'Payroll',
      CalculationType.stampDuty: 'Stamp Duty',
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: summary.calculationsByType.entries.map((entry) {
            final percentage = summary.totalCalculations > 0
                ? (entry.value / summary.totalCalculations * 100)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      typeNames[entry.key] ?? entry.key.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF0066FF)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your calculation history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<CalculationHistory> history) {
    final grouped = <String, List<CalculationHistory>>{};

    for (final item in history) {
      final dateKey = _formatDateGroup(item.calculatedAt);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries
          .expand((entry) => [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                ...entry.value.map((h) => _buildHistoryCard(h)),
              ])
          .toList(),
    );
  }

  Widget _buildHistoryCard(CalculationHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showHistoryDetails(history),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(history.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      history.typeName,
                      style: TextStyle(
                        color: _getTypeColor(history.type),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      history.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: history.isSaved
                          ? const Color(0xFF0066FF)
                          : Colors.grey,
                    ),
                    onPressed: () => _toggleSaved(history),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                history.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (history.totalTax != null) ...[
                Text(
                  'Tax: ${_formatCurrency(history.totalTax!)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                _formatTime(history.calculatedAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(CalculationType type) {
    switch (type) {
      case CalculationType.vat:
        return Colors.blue;
      case CalculationType.cit:
        return Colors.purple;
      case CalculationType.pit:
        return Colors.green;
      case CalculationType.wht:
        return Colors.orange;
      case CalculationType.payroll:
        return Colors.teal;
      case CalculationType.stampDuty:
        return Colors.red;
    }
  }

  String _formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'This Week';
    } else if (date.isAfter(today.subtract(const Duration(days: 30)))) {
      return 'This Month';
    } else {
      return 'Older';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _toggleSaved(CalculationHistory history) async {
    if (history.isSaved) {
      await _historyService.unsaveCalculation(history.id);
    } else {
      await _historyService.saveCalculation(history.id);
    }
    setState(() {});
  }

  void _showHistoryDetails(CalculationHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      history.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      history.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: history.isSaved
                          ? const Color(0xFF0066FF)
                          : Colors.grey,
                    ),
                    onPressed: () {
                      _toggleSaved(history);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection('Inputs', history.inputs),
              const SizedBox(height: 16),
              _buildDetailSection('Results', history.outputs),
              if (history.notes != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(history.notes!),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _deleteCalculation(history);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: data.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCalculation(CalculationHistory history) async {
    await _historyService.deleteCalculation(history.id);
    setState(() {});
  }
}
