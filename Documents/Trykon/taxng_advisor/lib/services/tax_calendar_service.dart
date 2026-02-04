/// Tax Calendar Service for managing deadlines and reminders
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tax_deadline.dart';

/// Service for managing tax calendar and deadlines
class TaxCalendarService extends ChangeNotifier {
  static const String _customDeadlinesKey = 'custom_tax_deadlines';
  static const String _completedDeadlinesKey = 'completed_deadlines';

  List<TaxDeadline> _deadlines = [];
  List<TaxDeadline> _customDeadlines = [];
  Set<String> _completedIds = {};
  bool _isLoading = false;
  String? _error;

  List<TaxDeadline> get deadlines => _deadlines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaxDeadline> get allDeadlines {
    final all = [..._deadlines, ..._customDeadlines];
    return all.map((d) {
      if (_completedIds.contains(d.id)) {
        return d.copyWith(
          status: DeadlineStatus.completed,
          completedDate: DateTime.now(),
        );
      }
      return d;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<TaxDeadline> get upcomingDeadlines {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    return allDeadlines.where((d) {
      return d.status != DeadlineStatus.completed &&
          d.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
          d.dueDate.isBefore(thirtyDaysLater);
    }).toList();
  }

  List<TaxDeadline> get overdueDeadlines =>
      allDeadlines.where((d) => d.isOverdue).toList();

  List<TaxDeadline> get todayDeadlines =>
      allDeadlines.where((d) => d.isDueToday).toList();

  List<TaxDeadline> getDeadlinesForMonth(int year, int month) =>
      allDeadlines.where((d) =>
          d.dueDate.year == year && d.dueDate.month == month).toList();

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final completedJson = prefs.getStringList(_completedDeadlinesKey) ?? [];
      _completedIds = completedJson.toSet();

      final customJson = prefs.getString(_customDeadlinesKey);
      if (customJson != null) {
        final List<dynamic> customList = json.decode(customJson);
        _customDeadlines =
            customList.map((e) => TaxDeadline.fromJson(e)).toList();
      }

      final now = DateTime.now();
      _deadlines = [
        ...NigerianTaxCalendar.getStandardDeadlines(now.year),
        ...NigerianTaxCalendar.getStandardDeadlines(now.year + 1),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tax calendar: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomDeadline(TaxDeadline deadline) async {
    _customDeadlines.add(deadline);
    await _saveCustomDeadlines();
    notifyListeners();
  }

  Future<void> markCompleted(String id) async {
    _completedIds.add(id);
    await _saveCompletedIds();
    notifyListeners();
  }

  Future<void> markNotCompleted(String id) async {
    _completedIds.remove(id);
    await _saveCompletedIds();
    notifyListeners();
  }

  bool isCompleted(String id) => _completedIds.contains(id);

  TaxDeadline? get nextDeadline {
    final upcoming = upcomingDeadlines;
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  Future<void> _saveCustomDeadlines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _customDeadlines.map((d) => d.toJson()).toList();
    await prefs.setString(_customDeadlinesKey, json.encode(jsonList));
  }

  Future<void> _saveCompletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedDeadlinesKey, _completedIds.toList());
  }
}
