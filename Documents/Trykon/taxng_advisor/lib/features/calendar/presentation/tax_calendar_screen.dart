/// Tax Calendar Screen - View and manage tax deadlines
import 'package:flutter/material.dart';
import '../../../models/tax_deadline.dart';
import '../../../services/tax_calendar_service.dart';
import '../../../widgets/common/taxng_app_bar.dart';

class TaxCalendarScreen extends StatefulWidget {
  const TaxCalendarScreen({super.key});

  @override
  State<TaxCalendarScreen> createState() => _TaxCalendarScreenState();
}

class _TaxCalendarScreenState extends State<TaxCalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaxCalendarService _calendarService = TaxCalendarService();
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDeadlines();
  }

  Future<void> _loadDeadlines() async {
    setState(() => _isLoading = true);
    await _calendarService.initialize();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TaxNGAppBar(
        title: 'Tax Calendar',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.upcoming)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(),
                _buildCalendarTab(),
                _buildAllTab(),
              ],
            ),
    );
  }

  Widget _buildUpcomingTab() {
    final upcomingDeadlines = _calendarService.upcomingDeadlines;
    final overdueDeadlines = _calendarService.overdueDeadlines;

    return RefreshIndicator(
      onRefresh: _loadDeadlines,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (overdueDeadlines.isNotEmpty) ...[
            _buildSectionHeader('Overdue', Colors.red),
            ...overdueDeadlines
                .map((d) => _buildDeadlineCard(d, isOverdue: true)),
            const SizedBox(height: 16),
          ],
          _buildSectionHeader(
              'Upcoming (Next 30 Days)', const Color(0xFF0066FF)),
          if (upcomingDeadlines.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'No upcoming deadlines!',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            ...upcomingDeadlines.map((d) => _buildDeadlineCard(d)),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final deadlinesForMonth = _calendarService.getDeadlinesForMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    return Column(
      children: [
        _buildMonthSelector(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deadlinesForMonth.length,
            itemBuilder: (context, index) {
              return _buildDeadlineCard(deadlinesForMonth[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            _formatMonth(_selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    final allDeadlines = _calendarService.deadlines;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allDeadlines.length,
      itemBuilder: (context, index) {
        return _buildDeadlineCard(allDeadlines[index]);
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard(TaxDeadline deadline, {bool isOverdue = false}) {
    final priorityColor = _getPriorityColor(deadline.priority);
    final daysUntil = deadline.daysRemaining;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showDeadlineDetails(deadline),
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
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      deadline.typeName,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildDaysChip(daysUntil, isOverdue),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                deadline.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deadline.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(deadline.dueDate),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (deadline.status == DeadlineStatus.completed)
                    const Chip(
                      label: Text('Completed'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                      padding: EdgeInsets.zero,
                    )
                  else
                    TextButton(
                      onPressed: () => _markAsCompleted(deadline),
                      child: const Text('Mark Complete'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysChip(int daysUntil, bool isOverdue) {
    String label;
    Color color;

    if (isOverdue || daysUntil < 0) {
      label = '${-daysUntil}d overdue';
      color = Colors.red;
    } else if (daysUntil == 0) {
      label = 'Due Today!';
      color = Colors.orange;
    } else if (daysUntil <= 7) {
      label = '$daysUntil days';
      color = Colors.orange;
    } else {
      label = '$daysUntil days';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getPriorityColor(DeadlinePriority priority) {
    switch (priority) {
      case DeadlinePriority.critical:
        return Colors.red;
      case DeadlinePriority.high:
        return Colors.orange;
      case DeadlinePriority.medium:
        return const Color(0xFF0066FF);
      case DeadlinePriority.low:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatMonth(DateTime date) {
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
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showDeadlineDetails(TaxDeadline deadline) {
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
              Text(
                deadline.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', deadline.typeName),
              _buildDetailRow('Due Date', _formatDate(deadline.dueDate)),
              _buildDetailRow('Recurrence',
                  deadline.isRecurring ? 'Recurring' : 'One-time'),
              _buildDetailRow('Priority', deadline.priority.name.toUpperCase()),
              _buildDetailRow('Status', deadline.status.name.toUpperCase()),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(deadline.description),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _markAsCompleted(deadline);
                  },
                  child: Text(
                    deadline.status == DeadlineStatus.completed
                        ? 'Mark as Pending'
                        : 'Mark as Completed',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsCompleted(TaxDeadline deadline) async {
    if (deadline.status == DeadlineStatus.completed) {
      await _calendarService.markNotCompleted(deadline.id);
    } else {
      await _calendarService.markCompleted(deadline.id);
    }
    await _loadDeadlines();
  }
}
