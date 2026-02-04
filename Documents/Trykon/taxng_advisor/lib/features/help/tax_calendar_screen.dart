import 'package:flutter/material.dart';

/// Nigerian Tax Calendar with important deadlines and reminders
class TaxCalendarScreen extends StatelessWidget {
  const TaxCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Calendar 2026'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.calendar_month,
                      size: 48, color: Colors.green[700]),
                  const SizedBox(height: 12),
                  const Text(
                    'Nigerian Tax Filing Calendar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Important tax deadlines and filing requirements for ${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Deadlines
          _buildSectionHeader('Monthly Deadlines'),
          const SizedBox(height: 8),
          _buildDeadlineCard(
            title: 'WHT Filing',
            deadline: '15th of each month',
            description: 'File and remit Withholding Tax for previous month',
            icon: Icons.attach_money,
            color: Colors.orange,
            isRecurring: true,
          ),
          _buildDeadlineCard(
            title: 'VAT Returns',
            deadline: '21st of each month',
            description: 'File monthly VAT returns for previous month',
            icon: Icons.receipt_long,
            color: Colors.blue,
            isRecurring: true,
          ),
          _buildDeadlineCard(
            title: 'PAYE Remittance',
            deadline: 'Last business day of month',
            description: 'Remit employee PAYE deductions to tax authority',
            icon: Icons.people,
            color: Colors.purple,
            isRecurring: true,
          ),
          const SizedBox(height: 24),

          // Quarterly Deadlines
          _buildSectionHeader('Quarterly Deadlines'),
          const SizedBox(height: 8),
          _buildDeadlineCard(
            title: 'VAT Quarterly Returns',
            deadline: 'Within 21 days of quarter end',
            description: 'Q1: Apr 21 | Q2: Jul 21 | Q3: Oct 21 | Q4: Jan 21',
            icon: Icons.calendar_today,
            color: Colors.teal,
          ),
          _buildDeadlineCard(
            title: 'CIT Installments',
            deadline: 'Quarterly installment payments',
            description: 'Pay 25% of prior year tax liability each quarter',
            icon: Icons.business,
            color: Colors.indigo,
          ),
          const SizedBox(height: 24),

          // Annual Deadlines
          _buildSectionHeader('Annual Deadlines'),
          const SizedBox(height: 8),
          _buildDeadlineCard(
            title: 'CIT Filing',
            deadline: 'May 31, ${DateTime.now().year}',
            description: 'File Corporate Income Tax returns for previous year',
            icon: Icons.business_center,
            color: Colors.red,
            daysUntil:
                _calculateDaysUntil(DateTime(DateTime.now().year, 5, 31)),
          ),
          _buildDeadlineCard(
            title: 'PIT Filing',
            deadline: 'May 31, ${DateTime.now().year}',
            description: 'File Personal Income Tax returns for previous year',
            icon: Icons.person,
            color: Colors.pink,
            daysUntil:
                _calculateDaysUntil(DateTime(DateTime.now().year, 5, 31)),
          ),
          _buildDeadlineCard(
            title: 'Annual Stamp Duty Registration',
            deadline: 'If annual duty ≥ ₦100,000',
            description: 'Register with FIRS for stamp duty compliance',
            icon: Icons.description,
            color: Colors.brown,
          ),
          const SizedBox(height: 24),

          // Important Notes
          _buildSectionHeader('Important Notes'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNote(
                    '📌',
                    'Late Filing Penalties',
                    'Failure to file on time attracts penalties. File early to avoid extra charges.',
                  ),
                  const SizedBox(height: 12),
                  _buildNote(
                    '🏦',
                    'Payment Methods',
                    'Use authorized banks and keep proof of payment for all tax remittances.',
                  ),
                  const SizedBox(height: 12),
                  _buildNote(
                    '📧',
                    'Email Confirmations',
                    'After payment, send Tax Notification and bank transfer confirmation to FIRS/NRS.',
                  ),
                  const SizedBox(height: 12),
                  _buildNote(
                    '⚠️',
                    'Penalties for Non-Compliance',
                    'Non-compliance can result in penalties up to 100% of tax due plus interest.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // VAT Registration Threshold
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber[800]),
                      const SizedBox(width: 8),
                      const Text(
                        'VAT Registration Reminder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Businesses with annual turnover exceeding ₦25 million must register for VAT.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDeadlineCard({
    required String title,
    required String deadline,
    required String description,
    required IconData icon,
    required Color color,
    int? daysUntil,
    bool isRecurring = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isRecurring)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'MONTHLY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        deadline,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                  if (daysUntil != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            daysUntil < 30 ? Colors.red[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: daysUntil < 30
                              ? Colors.red[300]!
                              : Colors.blue[300]!,
                        ),
                      ),
                      child: Text(
                        daysUntil > 0
                            ? '$daysUntil days remaining'
                            : daysUntil == 0
                                ? 'Due today!'
                                : '${-daysUntil} days overdue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: daysUntil < 30
                              ? Colors.red[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateDaysUntil(DateTime deadline) {
    final now = DateTime.now();
    final difference =
        deadline.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }
}
