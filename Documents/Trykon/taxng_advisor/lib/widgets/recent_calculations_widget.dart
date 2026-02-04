import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:intl/intl.dart';

/// Widget to display recent calculations on dashboard
class RecentCalculationsWidget extends StatelessWidget {
  const RecentCalculationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecentCalculations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history, size: 20, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Recent Calculations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.calculate,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No calculations yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start with a calculator below',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final calculations = snapshot.data!.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Calculations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/calculation-history');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...calculations
                    .map((calc) => _buildCalculationTile(context, calc))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalculationTile(
      BuildContext context, Map<String, dynamic> calc) {
    final type = calc['type'] as String? ?? 'Unknown';
    final timestamp = calc['timestamp'] as DateTime?;
    final tax = calc['tax'] as double? ?? 0.0;

    final IconData icon;
    final Color color;
    final String route;

    switch (type.toUpperCase()) {
      case 'CIT':
        icon = Icons.business;
        color = Colors.blue;
        route = '/cit';
        break;
      case 'PIT':
        icon = Icons.person;
        color = Colors.purple;
        route = '/pit';
        break;
      case 'VAT':
        icon = Icons.shopping_cart;
        color = Colors.orange;
        route = '/vat';
        break;
      case 'WHT':
        icon = Icons.account_balance;
        color = Colors.teal;
        route = '/wht';
        break;
      case 'PAYROLL':
        icon = Icons.people;
        color = Colors.indigo;
        route = '/payroll';
        break;
      case 'STAMPDUTY':
        icon = Icons.description;
        color = Colors.brown;
        route = '/stamp_duty';
        break;
      default:
        icon = Icons.calculate;
        color = Colors.grey;
        route = '/dashboard';
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tax: ₦${_formatAmount(tax)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getRecentCalculations() async {
    try {
      // Collect calculations from all tax type boxes
      final calculations = <Map<String, dynamic>>[];

      // Get CIT calculations
      final citBox = Hive.box(HiveService.citBox);
      for (var value in citBox.values) {
        final map = value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{};
        if (map.isNotEmpty) {
          map['taxType'] = 'CIT';
          map['timestamp'] = map['calculatedAt'] != null
              ? DateTime.tryParse(map['calculatedAt'].toString()) ??
                  DateTime.now()
              : DateTime.now();
          calculations.add(map);
        }
      }

      // Get PIT calculations
      final pitBox = Hive.box(HiveService.pitBox);
      for (var value in pitBox.values) {
        final map = value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{};
        if (map.isNotEmpty) {
          map['taxType'] = 'PIT';
          map['timestamp'] = map['calculatedAt'] != null
              ? DateTime.tryParse(map['calculatedAt'].toString()) ??
                  DateTime.now()
              : DateTime.now();
          calculations.add(map);
        }
      }

      // Get VAT calculations
      final vatBox = Hive.box(HiveService.vatBox);
      for (var value in vatBox.values) {
        final map = value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{};
        if (map.isNotEmpty) {
          map['taxType'] = 'VAT';
          map['timestamp'] = map['calculatedAt'] != null
              ? DateTime.tryParse(map['calculatedAt'].toString()) ??
                  DateTime.now()
              : DateTime.now();
          calculations.add(map);
        }
      }

      // Sort by timestamp descending
      calculations.sort((a, b) {
        final aTime = a['timestamp'] as DateTime? ?? DateTime.now();
        final bTime = b['timestamp'] as DateTime? ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      return calculations;
    } catch (e) {
      print('Error getting recent calculations: $e');
      return [];
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
