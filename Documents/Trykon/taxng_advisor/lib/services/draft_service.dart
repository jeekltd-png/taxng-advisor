import 'dart:async';
import 'package:hive/hive.dart';
import 'package:taxng_advisor/services/hive_service.dart';

/// Service for auto-saving calculator drafts
class DraftService {
  static const String _draftBoxName = 'calculator_drafts';
  Timer? _autoSaveTimer;
  String? _currentCalculatorKey;
  Map<String, dynamic>? _currentData;
  Function? _onSave;

  /// Initialize draft service for a specific calculator
  void initialize({
    required String calculatorKey,
    required Map<String, dynamic> initialData,
    Function? onSave,
  }) {
    _currentCalculatorKey = calculatorKey;
    _currentData = Map.from(initialData);
    _onSave = onSave;
    _startAutoSave();
  }

  /// Update the current draft data
  void updateData(Map<String, dynamic> data) {
    _currentData = Map.from(data);
  }

  /// Start auto-save timer (saves every 30 seconds)
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentCalculatorKey != null && _currentData != null) {
        saveDraft();
      }
    });
  }

  /// Manually save draft
  Future<void> saveDraft() async {
    if (_currentCalculatorKey == null || _currentData == null) return;

    try {
      final box = await Hive.openBox(_draftBoxName);
      await box.put(_currentCalculatorKey, {
        'data': _currentData,
        'savedAt': DateTime.now().toIso8601String(),
      });
      _onSave?.call();
    } catch (e) {
      print('Error saving draft: $e');
    }
  }

  /// Load draft for a calculator
  static Future<Map<String, dynamic>?> loadDraft(String calculatorKey) async {
    try {
      final box = await Hive.openBox(_draftBoxName);
      final draftData = box.get(calculatorKey);
      if (draftData != null) {
        return {
          'data': draftData['data'] as Map<String, dynamic>,
          'savedAt': DateTime.parse(draftData['savedAt']),
        };
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
    return null;
  }

  /// Delete draft for a calculator
  static Future<void> deleteDraft(String calculatorKey) async {
    try {
      final box = await Hive.openBox(_draftBoxName);
      await box.delete(calculatorKey);
    } catch (e) {
      print('Error deleting draft: $e');
    }
  }

  /// Check if a draft exists for a calculator
  static Future<bool> hasDraft(String calculatorKey) async {
    try {
      final box = await Hive.openBox(_draftBoxName);
      return box.containsKey(calculatorKey);
    } catch (e) {
      print('Error checking draft: $e');
      return false;
    }
  }

  /// Stop auto-save and cleanup
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _currentCalculatorKey = null;
    _currentData = null;
    _onSave = null;
  }
}

/// Service for storing and retrieving recent calculator values
class RecentValuesService {
  static const String _recentBoxName = 'recent_values';
  static const int _maxRecentValues = 5;

  /// Save a recent value for a specific field
  static Future<void> saveRecentValue({
    required String calculatorKey,
    required String fieldName,
    required dynamic value,
  }) async {
    if (value == null || value.toString().isEmpty) return;

    try {
      final box = await Hive.openBox(_recentBoxName);
      final key = '${calculatorKey}_$fieldName';

      List<dynamic> recentValues = [];
      if (box.containsKey(key)) {
        recentValues = List.from(box.get(key) as List);
      }

      // Remove if already exists (to move to front)
      recentValues.remove(value.toString());

      // Add to front
      recentValues.insert(0, value.toString());

      // Keep only max recent values
      if (recentValues.length > _maxRecentValues) {
        recentValues = recentValues.take(_maxRecentValues).toList();
      }

      await box.put(key, recentValues);
    } catch (e) {
      print('Error saving recent value: $e');
    }
  }

  /// Get recent values for a specific field
  static Future<List<String>> getRecentValues({
    required String calculatorKey,
    required String fieldName,
  }) async {
    try {
      final box = await Hive.openBox(_recentBoxName);
      final key = '${calculatorKey}_$fieldName';

      if (box.containsKey(key)) {
        final values = box.get(key) as List;
        return values.map((v) => v.toString()).toList();
      }
    } catch (e) {
      print('Error getting recent values: $e');
    }
    return [];
  }

  /// Clear recent values for a specific field
  static Future<void> clearRecentValues({
    required String calculatorKey,
    required String fieldName,
  }) async {
    try {
      final box = await Hive.openBox(_recentBoxName);
      final key = '${calculatorKey}_$fieldName';
      await box.delete(key);
    } catch (e) {
      print('Error clearing recent values: $e');
    }
  }

  /// Get the last calculated values for a calculator
  static Future<Map<String, dynamic>?> getLastCalculation(
      String calculatorType) async {
    try {
      Box box;
      String dateKey = 'calculatedAt';

      switch (calculatorType) {
        case 'CIT':
          box = Hive.box(HiveService.citBox);
          break;
        case 'PIT':
          box = Hive.box(HiveService.pitBox);
          break;
        case 'VAT':
          box = Hive.box(HiveService.vatBox);
          break;
        case 'WHT':
          box = Hive.box(HiveService.whtBox);
          break;
        case 'PAYE':
          box = Hive.box(HiveService.payrollBox);
          break;
        case 'STAMP':
          box = Hive.box(HiveService.stampDutyBox);
          break;
        default:
          return null;
      }

      if (box.isEmpty) return null;

      // Get the most recent calculation
      final values = box.values.toList();
      values.sort((a, b) {
        final dateA = DateTime.parse((a as Map<String, dynamic>)[dateKey]);
        final dateB = DateTime.parse((b as Map<String, dynamic>)[dateKey]);
        return dateB.compareTo(dateA);
      });

      if (values.isNotEmpty) {
        return values.first as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting last calculation: $e');
    }
    return null;
  }
}
