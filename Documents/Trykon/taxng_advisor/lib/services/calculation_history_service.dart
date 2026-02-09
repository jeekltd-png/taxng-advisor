/// Calculation History Service for tracking all tax calculations (Audit Trail)
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';

/// Service for managing calculation history and audit trail
class CalculationHistoryService extends ChangeNotifier {
  static const String _historyKey = 'calculation_history';
  static const int _maxHistoryItems = 500;

  List<CalculationHistory> _history = [];
  bool _isLoading = false;
  String? _error;

  List<CalculationHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CalculationHistory> get sortedHistory => _history.toList()
    ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

  HistorySummary get summary => HistorySummary.fromHistories(_history);

  List<CalculationHistory> get recentCalculations =>
      sortedHistory.take(10).toList();

  List<CalculationHistory> getByType(CalculationType type) =>
      _history.where((h) => h.type == type).toList()
        ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

  List<CalculationHistory> filter(HistoryFilter filter) =>
      sortedHistory.where((h) => filter.matches(h)).toList();

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _history =
            historyList.map((e) => CalculationHistory.fromJson(e)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load calculation history: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addCalculation({
    required CalculationType type,
    required String title,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
    double? totalTax,
    String? currency,
    String? notes,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final calculation = CalculationHistory(
      id: id,
      type: type,
      title: title,
      calculatedAt: DateTime.now(),
      inputs: inputs,
      outputs: outputs,
      totalTax: totalTax,
      currency: currency ?? 'NGN',
      notes: notes,
    );

    _history.insert(0, calculation);

    if (_history.length > _maxHistoryItems) {
      _history = _history.sublist(0, _maxHistoryItems);
    }

    await _saveHistory();
    notifyListeners();

    return id;
  }

  Future<void> saveCalculation(String id) async {
    final index = _history.indexWhere((h) => h.id == id);
    if (index != -1) {
      _history[index] = _history[index].copyWith(isSaved: true);
      await _saveHistory();
      notifyListeners();
    }
  }

  Future<void> unsaveCalculation(String id) async {
    final index = _history.indexWhere((h) => h.id == id);
    if (index != -1) {
      _history[index] = _history[index].copyWith(isSaved: false);
      await _saveHistory();
      notifyListeners();
    }
  }

  Future<void> deleteCalculation(String id) async {
    _history.removeWhere((h) => h.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  List<CalculationHistory> get savedCalculations =>
      sortedHistory.where((h) => h.isSaved).toList();

  String exportToJson() {
    final jsonList = _history.map((h) => h.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _history.map((h) => h.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  /// Static convenience — get recent calculations without a Provider.
  static Future<List<Map<String, dynamic>>> getRecentCalculations(
      {int limit = 5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson == null) return [];

      final List<dynamic> list = json.decode(historyJson);
      final histories = list.map((e) => CalculationHistory.fromJson(e)).toList()
        ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

      return histories
          .take(limit)
          .map((h) => {
                'type': h.type.name.toUpperCase(),
                'amount': h.totalTax ?? 0.0,
                'date':
                    '${h.calculatedAt.day}/${h.calculatedAt.month}/${h.calculatedAt.year}',
              })
          .toList();
    } catch (_) {
      return [];
    }
  }
}
