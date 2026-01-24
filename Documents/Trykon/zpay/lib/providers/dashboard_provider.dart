// lib/providers/dashboard_provider.dart
// Provider and mock data for the zpay dashboard

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpay/services/api_service.dart';
import 'package:intl/intl.dart';

/// Public provider to read the dashboard state
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState.initial()) {
    loadData();
  }

  /// Simulates network loading and populates mock data
  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true, isError: false);
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock wallets (balances are in their native currencies)
      final wallets = [
        Wallet(
            currencyCode: 'USD',
            balance: 12450.75,
            displayName: 'US Dollar',
            icon: Icons.attach_money),
        Wallet(
            currencyCode: 'EUR',
            balance: 980.20,
            displayName: 'Euro',
            icon: Icons.euro),
        Wallet(
            currencyCode: 'GBP',
            balance: 740.50,
            displayName: 'British Pound',
            icon: Icons.currency_pound),
        Wallet(
            currencyCode: 'NGN',
            balance: 320000.00,
            displayName: 'Naira',
            icon: Icons.currency_exchange),
        Wallet(
            currencyCode: 'BTC',
            balance: 0.0372,
            displayName: 'Bitcoin',
            icon: Icons.currency_bitcoin),
      ];

      // Api client
      final api = ApiService();

      // Try to fetch recent transactions from API, fallback to mock
      final rawTx = await api.fetchRecentTransactions(limit: 8);
      final transactions = rawTx.map((e) {
        return TransactionItem(
          id: e['id'] as String,
          date: DateTime.parse(e['date'] as String),
          currencyCode: e['currency'] as String,
          amount: (e['amount'] as num).toDouble(),
          description: e['description'] as String,
          type: (e['type'] as String) == 'credit'
              ? TransactionType.credit
              : TransactionType.debit,
        );
      }).toList();

      // Try fetch real rates (fallback to mock on error)
      final fetchedRates = await api.fetchExchangeRates(
          base: 'USD', symbols: ['USD', 'EUR', 'GBP', 'NGN']);
      final btcUsd = await api.fetchBitcoinUsdPrice();
      final rates = Map<String, double>.from(fetchedRates);
      rates['BTC'] = btcUsd;

      state = state.copyWith(
        isLoading: false,
        isError: false,
        wallets: wallets,
        transactions: transactions,
        exchangeRates: rates,
      );
    } catch (e) {
      // If network fails, keep mock data and mark error softly
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

  void toggleShowBalance() {
    state = state.copyWith(showBalance: !state.showBalance);
  }

  void setPrimaryCurrency(String code) {
    state = state.copyWith(primaryCurrency: code);
  }

  /// Compute total portfolio in primaryCurrency using exchange rates (simple mock calculation)
  double get totalPortfolioInPrimary {
    final rates = state.exchangeRates;
    if (rates.isEmpty) return 0.0;
    double totalInUSD = 0.0;
    for (final w in state.wallets) {
      final rate = rates[w.currencyCode] ?? 1.0;
      final val =
          (w.currencyCode == 'BTC') ? w.balance * rate : w.balance * rate;
      totalInUSD += val;
    }
    final convert =
        (rates[state.primaryCurrency] ?? 1.0) / (rates['USD'] ?? 1.0);
    return totalInUSD * convert;
  }

  /// Helper to format amounts with Intl, fallback to symbol map if necessary
  String formatCurrency(num amount, String currencyCode, {String? locale}) {
    final sym = _currencySymbols[currencyCode] ?? currencyCode;
    try {
      final format = NumberFormat.currency(
          name: currencyCode, symbol: sym, locale: locale);
      return format.format(amount);
    } catch (_) {
      return '$sym${amount.toStringAsFixed(2)}';
    }
  }

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'NGN': '₦',
    'BTC': '₿',
  };
}

@immutable
class DashboardState {
  final bool isLoading;
  final bool isError;
  final bool showBalance;
  final String primaryCurrency;
  final List<Wallet> wallets;
  final List<TransactionItem> transactions;
  final Map<String, double> exchangeRates;

  const DashboardState({
    required this.isLoading,
    required this.isError,
    required this.showBalance,
    required this.primaryCurrency,
    required this.wallets,
    required this.transactions,
    required this.exchangeRates,
  });

  factory DashboardState.initial() => const DashboardState(
        isLoading: true,
        isError: false,
        showBalance: true,
        primaryCurrency: 'USD',
        wallets: [],
        transactions: [],
        exchangeRates: {},
      );

  DashboardState copyWith({
    bool? isLoading,
    bool? isError,
    bool? showBalance,
    String? primaryCurrency,
    List<Wallet>? wallets,
    List<TransactionItem>? transactions,
    Map<String, double>? exchangeRates,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      showBalance: showBalance ?? this.showBalance,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      wallets: wallets ?? this.wallets,
      transactions: transactions ?? this.transactions,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }
}

@immutable
class Wallet {
  final String currencyCode;
  final double balance;
  final String displayName;
  final IconData icon;

  const Wallet(
      {required this.currencyCode,
      required this.balance,
      required this.displayName,
      required this.icon});
}

enum TransactionType { credit, debit }

@immutable
class TransactionItem {
  final String id;
  final DateTime date;
  final String currencyCode;
  final double amount;
  final String description;
  final TransactionType type;

  const TransactionItem(
      {required this.id,
      required this.date,
      required this.currencyCode,
      required this.amount,
      required this.description,
      required this.type});
}
