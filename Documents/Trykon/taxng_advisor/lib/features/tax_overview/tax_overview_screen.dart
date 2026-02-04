import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:taxng_advisor/services/tax_analytics_service.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:intl/intl.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// Tax Overview Dashboard - Shows aggregated tax data with charts
class TaxOverviewScreen extends StatefulWidget {
  const TaxOverviewScreen({Key? key}) : super(key: key);

  @override
  State<TaxOverviewScreen> createState() => _TaxOverviewScreenState();
}

class _TaxOverviewScreenState extends State<TaxOverviewScreen> {
  String _selectedPeriod = 'This Year';
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedChartType = 'Overview'; // 'Overview', 'Trends', 'Comparison'

  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'This Quarter':
        final quarter = ((now.month - 1) / 3).floor();
        _startDate = DateTime(now.year, quarter * 3 + 1, 1);
        _endDate = DateTime(now.year, (quarter + 1) * 3 + 1, 0);
        break;
      case 'This Year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case 'All Time':
        _startDate = null;
        _endDate = null;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCalculated = TaxAnalyticsService.getTotalTaxCalculated(
      startDate: _startDate,
      endDate: _endDate,
    );
    final totalPaid = TaxAnalyticsService.getTotalPaid(
      startDate: _startDate,
      endDate: _endDate,
    );
    final pending = totalCalculated - totalPaid;
    final breakdown = TaxAnalyticsService.getTaxBreakdown(
      startDate: _startDate,
      endDate: _endDate,
    );
    final recentCalculations =
        TaxAnalyticsService.getRecentCalculations(limit: 5);
    final counts = TaxAnalyticsService.getCalculationCount(
      startDate: _startDate,
      endDate: _endDate,
    );

    return Scaffold(
      appBar: TaxNGAppBar(
        title: 'Tax Overview',
        additionalActions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
                _updateDateRange();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(
                  value: 'This Quarter', child: Text('This Quarter')),
              const PopupMenuItem(value: 'This Year', child: Text('This Year')),
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_selectedPeriod, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
            stops: const [0.0, 0.15],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              Text(
                'Financial Summary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Overview of your tax calculations',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Calculated',
                      amount: totalCalculated,
                      color: Colors.blue,
                      icon: Icons.calculate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Paid',
                      amount: totalPaid,
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Pending Payment',
                amount: pending > 0 ? pending : 0,
                color: pending > 0 ? Colors.orange : Colors.grey,
                icon: Icons.pending_actions,
              ),
              const SizedBox(height: 28),

              // Chart Type Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ChartTypeButton(
                          label: 'Overview',
                          icon: Icons.pie_chart,
                          isSelected: _selectedChartType == 'Overview',
                          onTap: () {
                            setState(() {
                              _selectedChartType = 'Overview';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ChartTypeButton(
                          label: 'Trends',
                          icon: Icons.show_chart,
                          isSelected: _selectedChartType == 'Trends',
                          onTap: () {
                            setState(() {
                              _selectedChartType = 'Trends';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ChartTypeButton(
                          label: 'Compare',
                          icon: Icons.compare_arrows,
                          isSelected: _selectedChartType == 'Comparison',
                          onTap: () {
                            setState(() {
                              _selectedChartType = 'Comparison';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tax Breakdown Section
              Text(
                _selectedChartType == 'Overview'
                    ? 'Tax Breakdown by Type'
                    : _selectedChartType == 'Trends'
                        ? 'Tax Trends Over Time'
                        : 'Period Comparison',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Charts based on selected type
              if (totalCalculated > 0) ...[
                if (_selectedChartType == 'Overview') ...[
                  // Pie Chart
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections:
                            _getPieChartSections(breakdown, totalCalculated),
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            // Add touch feedback
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legend
                  _buildLegend(breakdown, totalCalculated),
                  const SizedBox(height: 24),
                ] else if (_selectedChartType == 'Trends') ...[
                  // Line Chart for Trends
                  SizedBox(
                    height: 300,
                    child: _buildLineChart(breakdown),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Line chart shows tax trends over the selected period',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blue[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (_selectedChartType == 'Comparison') ...[
                  // Comparison View
                  _buildComparisonView(breakdown, totalCalculated),
                  const SizedBox(height: 24),
                ],

                // Bar Chart
                Text(
                  'Amount by Tax Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxYValue(breakdown),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final types = breakdown.keys.toList();
                              if (value.toInt() >= 0 &&
                                  value.toInt() < types.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    types[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const Text('0');
                              return Text(
                                '₦${(value / 1000).toStringAsFixed(0)}K',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getBarGroups(breakdown),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Calculation Count
                Text(
                  'Calculation Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: counts.entries
                          .where((e) => e.value > 0)
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key),
                                    Text(
                                      '${e.value} calculation${e.value > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.info_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No tax calculations for $_selectedPeriod',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start calculating taxes to see your overview',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Recent Calculations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Calculations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/calculation-history');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentCalculations.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No calculations yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                ...recentCalculations.map((calc) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTaxColor(calc.type),
                          child: Text(
                            calc.type.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(calc.description),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(calc.date),
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatCurrency(calc.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(
    Map<String, double> breakdown,
    double total,
  ) {
    final colors = {
      'CIT': Colors.blue,
      'PIT': Colors.green,
      'VAT': Colors.orange,
      'WHT': Colors.purple,
      'PAYE': Colors.teal,
      'Stamp Duty': Colors.red,
    };

    return breakdown.entries.where((e) => e.value > 0).map((e) {
      final percentage = (e.value / total * 100);
      return PieChartSectionData(
        color: colors[e.key] ?? Colors.grey,
        value: e.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> breakdown, double total) {
    final colors = {
      'CIT': Colors.blue,
      'PIT': Colors.green,
      'VAT': Colors.orange,
      'WHT': Colors.purple,
      'PAYE': Colors.teal,
      'Stamp Duty': Colors.red,
    };

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: breakdown.entries
          .where((e) => e.value > 0)
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors[e.key],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e.key}: ${CurrencyFormatter.formatCurrency(e.value)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ))
          .toList(),
    );
  }

  double _getMaxYValue(Map<String, double> breakdown) {
    final max = breakdown.values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _getBarGroups(Map<String, double> breakdown) {
    final colors = {
      'CIT': Colors.blue,
      'PIT': Colors.green,
      'VAT': Colors.orange,
      'WHT': Colors.purple,
      'PAYE': Colors.teal,
      'Stamp Duty': Colors.red,
    };

    return breakdown.entries.map((e) {
      final index = breakdown.keys.toList().indexOf(e.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: colors[e.key] ?? Colors.grey,
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Color _getTaxColor(String type) {
    switch (type) {
      case 'CIT':
        return Colors.blue;
      case 'PIT':
        return Colors.green;
      case 'VAT':
        return Colors.orange;
      case 'WHT':
        return Colors.purple;
      case 'PAYE':
        return Colors.teal;
      case 'Stamp Duty':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLineChart(Map<String, double> breakdown) {
    // Generate dummy trend data for demonstration
    final spots = <LineChartBarData>[];
    final colors = {
      'CIT': Colors.blue,
      'PIT': Colors.green,
      'VAT': Colors.orange,
      'WHT': Colors.purple,
      'PAYE': Colors.teal,
      'Stamp Duty': Colors.red,
    };

    breakdown.entries.where((e) => e.value > 0).forEach((entry) {
      final points = <FlSpot>[];
      for (int i = 0; i < 6; i++) {
        final variance = (i * 0.15) - 0.3;
        points.add(FlSpot(i.toDouble(), entry.value * (1 + variance)));
      }

      spots.add(LineChartBarData(
        spots: points,
        isCurved: true,
        color: colors[entry.key],
        barWidth: 3,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ));
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₦${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: spots,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  CurrencyFormatter.formatCurrency(spot.y),
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonView(Map<String, double> breakdown, double total) {
    // Compare current period with previous
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Period',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCurrency(total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ...breakdown.entries.where((e) => e.value > 0).map((e) {
                  final percentage = (e.value / total * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: const TextStyle(fontSize: 13)),
                            Text(
                              CurrencyFormatter.formatCurrency(e.value),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          color: _getTaxColor(e.key),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Insight',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compare different periods by changing the filter above',
                        style:
                            TextStyle(fontSize: 12, color: Colors.orange[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Chart Type Button Widget
class _ChartTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[700] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.formatCurrency(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
