import 'package:flutter/material.dart';

/// Filing deadlines with countdowns
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  Widget build(BuildContext context) {
    // Define all tax reminders with their details
    final reminders = [
      {
        'title': 'VAT Monthly Return',
        'subtitle': '21st of each month - 9:00 AM',
        'description': 'Submit your monthly VAT return',
        'days': _daysUntil(DateTime.now().copyWith(day: 21)),
        'color': Colors.blue,
        'icon': Icons.receipt_long,
      },
      {
        'title': 'PIT Annual Return',
        'subtitle': '31st May - 9:00 AM',
        'description': 'File annual Personal Income Tax return',
        'days': _daysUntil(DateTime(DateTime.now().year, 5, 31)),
        'color': Colors.green,
        'icon': Icons.person,
      },
      {
        'title': 'CIT Annual Return',
        'subtitle': '31st May - 10:00 AM',
        'description': 'File annual Corporate Income Tax return',
        'days': _daysUntil(DateTime(DateTime.now().year, 5, 31)),
        'color': Colors.orange,
        'icon': Icons.business,
      },
      {
        'title': 'CIT Quarterly Provisional',
        'subtitle': '15th of Apr, Jul, Oct, Jan - 10:00 AM',
        'description': 'File quarterly CIT provisional return',
        'days': _daysUntil(DateTime(DateTime.now().year, 4, 15)),
        'color': Colors.deepOrange,
        'icon': Icons.calendar_month,
      },
      {
        'title': 'WHT Monthly Remittance',
        'subtitle': '15th of each month - 10:00 AM',
        'description': 'Remit Withholding Tax to FIRS',
        'days': _daysUntil(DateTime.now().copyWith(day: 15)),
        'color': Colors.purple,
        'icon': Icons.money,
      },
      {
        'title': 'WHT Annual Summary',
        'subtitle': '28th February - 10:00 AM',
        'description': 'File annual WHT summary statement',
        'days': _daysUntil(DateTime(DateTime.now().year, 2, 28)),
        'color': Colors.indigo,
        'icon': Icons.description,
      },
      {
        'title': 'Payroll Processing',
        'subtitle': 'Last business day of month - 5:00 PM',
        'description': 'Process and pay employee salaries',
        'days': _daysUntil(
            DateTime(DateTime.now().year, DateTime.now().month + 1, 1)
                .subtract(Duration(days: 1))),
        'color': Colors.red,
        'icon': Icons.payments,
      },
      {
        'title': 'Stamp Duty Quarterly',
        'subtitle': 'Month-end of quarters (Mar, Jun, Sep, Dec)',
        'description': 'Submit quarterly stamp duty statement',
        'days': _daysUntil(DateTime(DateTime.now().year, 3, 30)),
        'color': Colors.teal,
        'icon': Icons.document_scanner,
      },
      {
        'title': 'Stamp Duty Six-Monthly Review',
        'subtitle': 'June 30 & December 31 - 2:00 PM',
        'description': 'Review and reconcile stamp duty records',
        'days': _daysUntil(DateTime(DateTime.now().year, 6, 30)),
        'color': Colors.cyan,
        'icon': Icons.check_circle,
      },
      {
        'title': 'PIT Estimate Submission',
        'subtitle': '31st January - 9:00 AM',
        'description': 'File estimated PIT for the year',
        'days': _daysUntil(DateTime(DateTime.now().year, 1, 31)),
        'color': Colors.amber,
        'icon': Icons.assignment,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Reminders & Deadlines'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          final daysLeft = (reminder['days'] as int);
          final isUrgent = daysLeft <= 7;

          return Card(
            elevation: isUrgent ? 4 : 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: isUrgent ? Colors.red[50] : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    (reminder['color'] as Color).withValues(alpha: 0.2),
                child: Icon(reminder['icon'] as IconData,
                    color: reminder['color'] as Color),
              ),
              title: Text(
                reminder['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(reminder['subtitle'] as String,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    reminder['description'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? Colors.red
                          : (reminder['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$daysLeft days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUrgent
                            ? Colors.red[900]
                            : (reminder['color'] as Color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isUrgent)
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
