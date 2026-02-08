import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/features/cit/services/cit_storage_service.dart';
import 'package:taxng_advisor/features/pit/services/pit_storage_service.dart';
import 'package:taxng_advisor/features/vat/services/vat_storage_service.dart';
import 'package:taxng_advisor/features/wht/services/wht_storage_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/services/pdf_service.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/models/user.dart';

/// Admin-only screen: Generate reports for all users
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<UserProfile> _allUsers = [];
  String? _selectedUserId;
  DateTimeRange? _dateRange;

  // Statistics
  int _totalUsers = 0;
  int _totalCalculations = 0;
  double _totalPayments = 0.0;
  int _totalCit = 0;
  int _totalPit = 0;
  int _totalVat = 0;
  int _totalWht = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _checkAdminAccess();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    final user = await AuthService.currentUser();
    if (user == null || !user.isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin access required'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load all users
      _allUsers = await AuthService.listUsers();
      _totalUsers = _allUsers.length;

      // Load all calculations
      final citRecords = CitStorageService.getAllEstimates();
      final pitRecords = PitStorageService.getAllEstimates();
      final vatRecords = VatStorageService.getAllReturns();
      final whtRecords = WhtStorageService.getAllRecords();

      _totalCit = citRecords.length;
      _totalPit = pitRecords.length;
      _totalVat = vatRecords.length;
      _totalWht = whtRecords.length;
      _totalCalculations = _totalCit + _totalPit + _totalVat + _totalWht;

      // Calculate total payments (sum from all users)
      _totalPayments = 0.0;
      for (final user in _allUsers) {
        final userPayments = await PaymentService.getPaymentHistory(user.id);
        for (final payment in userPayments) {
          _totalPayments += payment.amount;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedUserId = null;
      _dateRange = null;
    });
  }

  Future<void> _exportToCsv(String reportType) async {
    try {
      // TODO: Implement actual CSV export with file picker
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV export for $reportType is coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting CSV: $e')),
      );
    }
  }

  Future<void> _exportToPdf(String reportType) async {
    try {
      setState(() => _isLoading = true);

      List<dynamic> data = [];
      Map<String, dynamic> statistics = {};

      // Gather data based on report type
      switch (reportType) {
        case 'users':
          data = _allUsers;
          statistics = {
            'Total Users': _totalUsers.toString(),
            'Admin Users': _allUsers.where((u) => u.isAdmin).length.toString(),
            'Business Users':
                _allUsers.where((u) => u.isBusiness).length.toString(),
          };
          reportType = 'Users';
          break;
        case 'payments':
          data = await _getAllPayments();
          final totalAmount = data.fold<double>(
            0.0,
            (sum, p) => sum + ((p as Map)['amount'] as double? ?? 0.0),
          );
          statistics = {
            'Total Payments': data.length.toString(),
            'Total Amount': CurrencyFormatter.formatCurrency(totalAmount),
          };
          reportType = 'Payments';
          break;
        case 'cit':
          data = CitStorageService.getAllEstimates();
          final totalTax = data.fold<double>(
            0.0,
            (sum, e) => sum + (e.taxPayable ?? 0.0),
          );
          statistics = {
            'Total Records': data.length.toString(),
            'Total Tax': CurrencyFormatter.formatCurrency(totalTax),
          };
          reportType = 'CIT';
          break;
        case 'pit':
          data = PitStorageService.getAllEstimates();
          final totalTax = data.fold<double>(
            0.0,
            (sum, e) => sum + ((e as Map)['totalTax'] as double? ?? 0.0),
          );
          statistics = {
            'Total Records': data.length.toString(),
            'Total Tax': CurrencyFormatter.formatCurrency(totalTax),
          };
          reportType = 'PIT';
          break;
        case 'vat':
          data = VatStorageService.getAllReturns();
          final totalVat = data.fold<double>(
            0.0,
            (sum, v) => sum + ((v as Map)['vatPayable'] as double? ?? 0.0),
          );
          statistics = {
            'Total Returns': data.length.toString(),
            'Total VAT': CurrencyFormatter.formatCurrency(totalVat),
          };
          reportType = 'VAT';
          break;
        case 'wht':
          data = WhtStorageService.getAllRecords();
          final totalWht = data.fold<double>(
            0.0,
            (sum, w) => sum + ((w as Map)['whtAmount'] as double? ?? 0.0),
          );
          statistics = {
            'Total Records': data.length.toString(),
            'Total WHT': CurrencyFormatter.formatCurrency(totalWht),
          };
          reportType = 'WHT';
          break;
        default:
          data = [];
          statistics = {};
      }

      // Generate PDF
      final pdfBytes = await PdfService.generateAdminReport(
        reportType: reportType,
        data: data,
        statistics: statistics,
        users: _allUsers,
      );

      // Share PDF
      await PdfService.sharePdf(
        pdfBytes,
        'taxng_admin_${reportType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$reportType report exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.business), text: 'CIT'),
            Tab(icon: Icon(Icons.person), text: 'PIT'),
            Tab(icon: Icon(Icons.receipt_long), text: 'VAT'),
            Tab(icon: Icon(Icons.money_off), text: 'WHT'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildUsersTab(),
                      _buildPaymentsTab(),
                      _buildCitTab(),
                      _buildPitTab(),
                      _buildVatTab(),
                      _buildWhtTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by User',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Users'),
                    ),
                    ..._allUsers.map((user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.username),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(_dateRange == null
                      ? 'Select Date Range'
                      : '${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                tooltip: 'Clear Filters',
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildStatisticsGrid(),
          const SizedBox(height: 32),
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Users',
          _totalUsers.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Calculations',
          _totalCalculations.toString(),
          Icons.calculate,
          Colors.green,
        ),
        _buildStatCard(
          'Total Payments',
          CurrencyFormatter.formatCurrency(_totalPayments),
          Icons.payment,
          Colors.orange,
        ),
        _buildStatCard(
          'Tax Types',
          '6 Active',
          Icons.category,
          Colors.purple,
        ),
        _buildStatCard(
          'CIT Records',
          _totalCit.toString(),
          Icons.business,
          Colors.teal,
        ),
        _buildStatCard(
          'PIT Records',
          _totalPit.toString(),
          Icons.person,
          Colors.indigo,
        ),
        _buildStatCard(
          'VAT Returns',
          _totalVat.toString(),
          Icons.receipt_long,
          Colors.pink,
        ),
        _buildStatCard(
          'WHT Records',
          _totalWht.toString(),
          Icons.money_off,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => _exportToCsv('overview'),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Last 24 hours: New calculations and payments'),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.green),
              title: Text('CIT: $_totalCit total records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _tabController.animateTo(3),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text('PIT: $_totalPit total records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _tabController.animateTo(4),
            ),
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.orange),
              title: Text('VAT: $_totalVat total returns'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _tabController.animateTo(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = _allUsers;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredUsers.length} Users',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _exportToCsv('users'),
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'Export to CSV',
                  ),
                  IconButton(
                    onPressed: () => _exportToPdf('users'),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export to PDF',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin ? Colors.purple : Colors.blue,
                    child: Icon(
                      user.isAdmin
                          ? Icons.admin_panel_settings
                          : (user.isBusiness ? Icons.business : Icons.person),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user.username),
                  subtitle: Text(
                    '${user.email}\n${user.isBusiness ? "Business: ${user.businessName}" : "Personal"}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (user.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Joined: ${user.createdAt.year}-${user.createdAt.month}-${user.createdAt.day}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final payments = snapshot.data ?? [];
        final filteredPayments = _filterPaymentsByDateAndUser(payments);

        final totalAmount = filteredPayments.fold<double>(
          0.0,
          (sum, payment) => sum + (payment['amount'] as double? ?? 0.0),
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filteredPayments.length} Payments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Total: ${CurrencyFormatter.formatCurrency(totalAmount)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _exportToCsv('payments'),
                        icon: const Icon(Icons.table_chart),
                        tooltip: 'Export to CSV',
                      ),
                      IconButton(
                        onPressed: () => _exportToPdf('payments'),
                        icon: const Icon(Icons.picture_as_pdf),
                        tooltip: 'Export to PDF',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredPayments.isEmpty
                  ? const Center(child: Text('No payments found'))
                  : ListView.builder(
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        final user = _allUsers.firstWhere(
                          (u) => u.id == payment['userId'],
                          orElse: () => UserProfile(
                            id: 'unknown',
                            username: 'Unknown',
                            email: '',
                            isBusiness: false,
                            createdAt: DateTime.now(),
                            modifiedAt: DateTime.now(),
                          ),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.payment, color: Colors.green),
                            title: Text(
                              CurrencyFormatter.formatCurrency(
                                  payment['amount'] as double? ?? 0.0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'User: ${user.username}\n'
                              '${payment['taxType'] ?? 'N/A'} - ${payment['method'] ?? 'N/A'}\n'
                              'Status: ${payment['status'] ?? 'N/A'}',
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              _formatDate(payment['paidAt']),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCitTab() {
    final allEstimates = CitStorageService.getAllEstimates();
    final filteredEstimates = _filterCitByDateAndUser(allEstimates);

    final totalLiability = filteredEstimates.fold<double>(
      0.0,
      (sum, estimate) => sum + estimate.taxPayable,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredEstimates.length} CIT Records',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Total Tax: ${CurrencyFormatter.formatCurrency(totalLiability)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _exportToCsv('cit'),
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'Export to CSV',
                  ),
                  IconButton(
                    onPressed: () => _exportToPdf('cit'),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export to PDF',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredEstimates.isEmpty
              ? const Center(child: Text('No CIT records found'))
              : ListView.builder(
                  itemCount: filteredEstimates.length,
                  itemBuilder: (context, index) {
                    final estimate = filteredEstimates[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.business, color: Colors.teal),
                        title: Text(
                          CurrencyFormatter.formatCurrency(estimate.taxPayable),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${estimate.category}\n'
                          'Rate: ${estimate.effectiveRate.toStringAsFixed(2)}%\n'
                          'Turnover: ${CurrencyFormatter.formatCurrency(estimate.turnover)}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          _formatDate(estimate.calculatedAt.toIso8601String()),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPitTab() {
    final allEstimates = PitStorageService.getAllEstimates();
    final filteredEstimates = _filterPitByDateAndUser(allEstimates);

    final totalTax = filteredEstimates.fold<double>(
      0.0,
      (sum, estimate) => sum + (estimate['totalTax'] as double? ?? 0.0),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredEstimates.length} PIT Records',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Total Tax: ${CurrencyFormatter.formatCurrency(totalTax)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _exportToCsv('pit'),
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'Export to CSV',
                  ),
                  IconButton(
                    onPressed: () => _exportToPdf('pit'),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export to PDF',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredEstimates.isEmpty
              ? const Center(child: Text('No PIT records found'))
              : ListView.builder(
                  itemCount: filteredEstimates.length,
                  itemBuilder: (context, index) {
                    final estimate = filteredEstimates[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.indigo),
                        title: Text(
                          CurrencyFormatter.formatCurrency(
                              estimate['totalTax'] as double? ?? 0.0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Annual Income: ${CurrencyFormatter.formatCurrency(estimate['annualIncome'] as double? ?? 0.0)}\n'
                          'Tax Rate: ${estimate['effectiveRate']?.toStringAsFixed(2) ?? '0.00'}%',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          _formatDate(estimate['timestamp']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVatTab() {
    final allReturns = VatStorageService.getAllReturns();
    final filteredReturns = _filterVatByDateAndUser(allReturns);

    final totalVatPayable = filteredReturns.fold<double>(
      0.0,
      (sum, vatReturn) => sum + (vatReturn['vatPayable'] as double? ?? 0.0),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredReturns.length} VAT Returns',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Total VAT: ${CurrencyFormatter.formatCurrency(totalVatPayable)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _exportToCsv('vat'),
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'Export to CSV',
                  ),
                  IconButton(
                    onPressed: () => _exportToPdf('vat'),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export to PDF',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredReturns.isEmpty
              ? const Center(child: Text('No VAT returns found'))
              : ListView.builder(
                  itemCount: filteredReturns.length,
                  itemBuilder: (context, index) {
                    final vatReturn = filteredReturns[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading:
                            const Icon(Icons.receipt_long, color: Colors.pink),
                        title: Text(
                          CurrencyFormatter.formatCurrency(
                              vatReturn['vatPayable'] as double? ?? 0.0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Output VAT: ${CurrencyFormatter.formatCurrency(vatReturn['outputVat'] as double? ?? 0.0)}\n'
                          'Input VAT: ${CurrencyFormatter.formatCurrency(vatReturn['inputVat'] as double? ?? 0.0)}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          _formatDate(vatReturn['timestamp']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWhtTab() {
    final allRecords = WhtStorageService.getAllRecords();
    final filteredRecords = _filterWhtByDateAndUser(allRecords);

    final totalWht = filteredRecords.fold<double>(
      0.0,
      (sum, record) => sum + (record['whtAmount'] as double? ?? 0.0),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredRecords.length} WHT Records',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Total WHT: ${CurrencyFormatter.formatCurrency(totalWht)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _exportToCsv('wht'),
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'Export to CSV',
                  ),
                  IconButton(
                    onPressed: () => _exportToPdf('wht'),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export to PDF',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(child: Text('No WHT records found'))
              : ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading:
                            Icon(Icons.money_off, color: Colors.amber[800]),
                        title: Text(
                          CurrencyFormatter.formatCurrency(
                              record['whtAmount'] as double? ?? 0.0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Payment Type: ${record['paymentType'] ?? 'N/A'}\n'
                          'Gross Amount: ${CurrencyFormatter.formatCurrency(record['grossAmount'] as double? ?? 0.0)}\n'
                          'Rate: ${record['whtRate']?.toStringAsFixed(2) ?? '0.00'}%',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          _formatDate(record['timestamp']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Helper methods for filtering
  List<Map<String, dynamic>> _filterPaymentsByDateAndUser(
      List<Map<String, dynamic>> payments) {
    return payments.where((payment) {
      // Filter by user
      if (_selectedUserId != null && payment['userId'] != _selectedUserId) {
        return false;
      }

      // Filter by date
      if (_dateRange != null) {
        final paidAt = DateTime.tryParse(payment['paidAt'] as String? ?? '');
        if (paidAt == null) return false;
        if (paidAt.isBefore(_dateRange!.start) ||
            paidAt.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<dynamic> _filterCitByDateAndUser(List<dynamic> estimates) {
    return estimates.where((estimate) {
      // Filter by date
      if (_dateRange != null) {
        final calculatedAt = estimate.calculatedAt;
        if (calculatedAt.isBefore(_dateRange!.start) ||
            calculatedAt.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _filterPitByDateAndUser(
      List<Map<String, dynamic>> estimates) {
    return estimates.where((estimate) {
      // Filter by date
      if (_dateRange != null) {
        final timestamp =
            DateTime.tryParse(estimate['timestamp'] as String? ?? '');
        if (timestamp == null) return false;
        if (timestamp.isBefore(_dateRange!.start) ||
            timestamp.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _filterVatByDateAndUser(
      List<Map<String, dynamic>> returns) {
    return returns.where((vatReturn) {
      // Filter by date
      if (_dateRange != null) {
        final timestamp =
            DateTime.tryParse(vatReturn['timestamp'] as String? ?? '');
        if (timestamp == null) return false;
        if (timestamp.isBefore(_dateRange!.start) ||
            timestamp.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _filterWhtByDateAndUser(
      List<Map<String, dynamic>> records) {
    return records.where((record) {
      // Filter by date
      if (_dateRange != null) {
        final timestamp =
            DateTime.tryParse(record['timestamp'] as String? ?? '');
        if (timestamp == null) return false;
        if (timestamp.isBefore(_dateRange!.start) ||
            timestamp.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _getAllPayments() async {
    final allPayments = <Map<String, dynamic>>[];

    for (final user in _allUsers) {
      final userPayments = await PaymentService.getPaymentHistory(user.id);
      for (final payment in userPayments) {
        allPayments.add(payment.toMap());
      }
    }

    return allPayments;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    DateTime? dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date);
    } else if (date is DateTime) {
      dateTime = date;
    }

    if (dateTime == null) return 'N/A';

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
