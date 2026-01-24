// lib/screens/dashboard_screen.dart
// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:zpay/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    final media = MediaQuery.of(context);
    final isTablet = media.size.width > 700;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: isTablet ? 260 : 200,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _Header(
                    isLoading: state.isLoading,
                    showBalance: state.showBalance,
                    onToggleVisibility: notifier.toggleShowBalance,
                    formattedBalance: state.showBalance
                        ? notifier.formatCurrency(
                            notifier.totalPortfolioInPrimary,
                            state.primaryCurrency,
                          )
                        : '••••••',
                    currencyCode: state.primaryCurrency,
                    onChangeCurrency: (code) =>
                        notifier.setPrimaryCurrency(code),
                    onProfileTap: () => context.go('/profile'),
                    isTablet: isTablet,
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Wallet Summary Horizontal List
                    _buildSectionTitle(context, 'Wallets'),
                    const SizedBox(height: 8),
                    _WalletsList(
                        isLoading: state.isLoading,
                        wallets: state.wallets,
                        formatCurrency: notifier.formatCurrency),
                    const SizedBox(height: 16),

                    // Pie Chart
                    _buildSectionTitle(context, 'Asset distribution'),
                    const SizedBox(height: 8),
                    _AssetPieChart(
                        isLoading: state.isLoading,
                        wallets: state.wallets,
                        exchangeRates: state.exchangeRates),
                    const SizedBox(height: 16),

                    // Recent Transactions
                    _buildSectionTitle(context, 'Recent transactions'),
                    const SizedBox(height: 8),
                    _RecentTransactions(
                        isLoading: state.isLoading,
                        transactions: state.transactions,
                        formatCurrency: notifier.formatCurrency),
                    const SizedBox(height: 16),

                    // Quick Actions Grid
                    _buildSectionTitle(context, 'Quick actions'),
                    const SizedBox(height: 8),
                    _QuickActionsGrid(
                        onAction: (id) => _onQuickAction(context, id)),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQuickAction(BuildContext context, String id) {
    switch (id) {
      case 'transfers':
        context.go('/transfers');
        break;
      case 'bills':
        context.go('/bills');
        break;
      case 'savings':
        context.go('/savings');
        break;
      case 'virtual_cards':
        context.go('/virtual-cards');
        break;
      case 'cash_out':
        context.go('/cash-out');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action not implemented')));
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isLoading;
  final bool showBalance;
  final VoidCallback onToggleVisibility;
  final String formattedBalance;
  final String currencyCode;
  final ValueChanged<String> onChangeCurrency;
  final VoidCallback onProfileTap;
  final bool isTablet;

  const _Header({
    Key? key,
    required this.isLoading,
    required this.showBalance,
    required this.onToggleVisibility,
    required this.formattedBalance,
    required this.currencyCode,
    required this.onChangeCurrency,
    required this.onProfileTap,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Colors.blueGrey.shade800, Colors.teal.shade600],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white70)),
                ),
                IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                      showBalance ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white),
                  tooltip: showBalance ? 'Hide balance' : 'Show balance',
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isLoading ? 0.5 : 1.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total portfolio',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(formattedBalance,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: currencyCode,
                    dropdownColor: Colors.blueGrey.shade700,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'USD',
                          child: Text('USD',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 'EUR',
                          child: Text('EUR',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 'NGN',
                          child: Text('NGN',
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (v) {
                      if (v != null) onChangeCurrency(v);
                    },
                    iconEnabledColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _WalletsList extends StatelessWidget {
  final bool isLoading;
  final List<Wallet> wallets;
  final String Function(num, String, {String? locale}) formatCurrency;

  const _WalletsList(
      {Key? key,
      required this.isLoading,
      required this.wallets,
      required this.formatCurrency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, __) => _buildSkeletonCard(),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: 4,
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) {
          final w = wallets[i];
          return GestureDetector(
            onTap: () => ScaffoldMessenger.of(ctx)
                .showSnackBar(SnackBar(content: Text('Open ${w.displayName}'))),
            child: SizedBox(
              width: 220,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade200,
                              child: Icon(w.icon, color: Colors.black54)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(w.displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                          Text(w.currencyCode,
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      const Spacer(),
                      Text(formatCurrency(w.balance, w.currencyCode),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: wallets.length,
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _AssetPieChart extends StatelessWidget {
  final bool isLoading;
  final List<Wallet> wallets;
  final Map<String, double> exchangeRates;

  const _AssetPieChart(
      {Key? key,
      required this.isLoading,
      required this.wallets,
      required this.exchangeRates})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }

    final Map<String, double> values = {};
    for (final w in wallets) {
      final rate = exchangeRates[w.currencyCode] ?? 1.0;
      final val =
          (w.currencyCode == 'BTC') ? w.balance * rate : w.balance * rate;
      values[w.currencyCode] = val;
    }

    final total = values.values.fold<double>(0.0, (a, b) => a + b);
    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.green,
      Colors.purple
    ];

    int i = 0;
    values.forEach((code, val) {
      final perc = total <= 0 ? 0.0 : (val / total) * 100;
      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: val,
        title: '${perc.toStringAsFixed(0)}%',
        radius: 48,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      i++;
    });

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 6,
                    centerSpaceRadius: 38,
                    borderData: FlBorderData(show: false),
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: values.keys.map((code) {
                    final idx = values.keys.toList().indexOf(code);
                    final color = colors[idx % colors.length];
                    final amount = values[code] ?? 0.0;
                    final formatted = NumberFormat.currency(
                            name: code, symbol: code == 'BTC' ? '₿' : '')
                        .format(amount);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(code,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                          Text(formatted,
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final bool isLoading;
  final List<TransactionItem> transactions;
  final String Function(num, String, {String? locale}) formatCurrency;

  const _RecentTransactions(
      {Key? key,
      required this.isLoading,
      required this.transactions,
      required this.formatCurrency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 110,
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CircularProgressIndicator()],
        )),
      );
    }

    final items = transactions.take(5).toList();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) {
          final t = items[i];
          final isCredit = t.type == TransactionType.credit;
          return SizedBox(
            width: 260,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          isCredit ? Colors.green.shade50 : Colors.red.shade50,
                      child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.description,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(DateFormat.yMMMd().format(t.date),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(t.amount.abs(), t.currencyCode),
                      style: TextStyle(
                          color: isCredit ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final void Function(String id) onAction;

  const _QuickActionsGrid({Key? key, required this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'id': 'transfers', 'label': 'Transfers', 'icon': Icons.send},
      {'id': 'bills', 'label': 'Bills & Airtime', 'icon': Icons.receipt_long},
      {'id': 'savings', 'label': 'Savings', 'icon': Icons.savings},
      {
        'id': 'virtual_cards',
        'label': 'Virtual Cards',
        'icon': Icons.credit_card
      },
      {'id': 'cash_out', 'label': 'Cash Out', 'icon': Icons.money_off},
    ];

    final crossAxisCount = MediaQuery.of(context).size.width > 700 ? 4 : 3;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2),
      itemBuilder: (ctx, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () => onAction(a['id'] as String),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade100,
                      child:
                          Icon(a['icon'] as IconData, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(a['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
