import 'package:hive/hive.dart';
import 'package:taxng_advisor/models/calculation_template.dart';

/// Template Service - Manages calculation templates
class TemplateService {
  static const String _templatesBox = 'calculation_templates';

  /// Initialize templates box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_templatesBox)) {
      await Hive.openBox<CalculationTemplate>(_templatesBox);
    }
  }

  /// Get templates box
  static Box<CalculationTemplate> get _box {
    return Hive.box<CalculationTemplate>(_templatesBox);
  }

  /// Save template
  static Future<void> saveTemplate(CalculationTemplate template) async {
    await _box.put(template.id, template);
  }

  /// Get template by ID
  static CalculationTemplate? getTemplate(String id) {
    return _box.get(id);
  }

  /// Get all templates
  static List<CalculationTemplate> getAllTemplates() {
    return _box.values.toList();
  }

  /// Get templates by tax type
  static List<CalculationTemplate> getTemplatesByTaxType(String taxType) {
    return _box.values.where((t) => t.taxType == taxType).toList();
  }

  /// Get templates by category
  static List<CalculationTemplate> getTemplatesByCategory(String category) {
    return _box.values.where((t) => t.category == category).toList();
  }

  /// Search templates
  static List<CalculationTemplate> searchTemplates(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((t) {
      return t.name.toLowerCase().contains(lowerQuery) ||
          (t.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Update template
  static Future<void> updateTemplate(CalculationTemplate template) async {
    await _box.put(template.id, template);
  }

  /// Delete template
  static Future<void> deleteTemplate(String id) async {
    await _box.delete(id);
  }

  /// Record template usage
  static Future<void> recordUsage(String id) async {
    final template = getTemplate(id);
    if (template != null) {
      final updated = template.copyWith(
        lastUsedAt: DateTime.now(),
        usageCount: template.usageCount + 1,
      );
      await updateTemplate(updated);
    }
  }

  /// Get most used templates
  static List<CalculationTemplate> getMostUsedTemplates({int limit = 5}) {
    final templates = _box.values.toList();
    templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return templates.take(limit).toList();
  }

  /// Get recently used templates
  static List<CalculationTemplate> getRecentlyUsedTemplates({int limit = 5}) {
    final templates = _box.values.where((t) => t.lastUsedAt != null).toList();
    templates.sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));
    return templates.take(limit).toList();
  }

  /// Get template count
  static int getTemplateCount() {
    return _box.length;
  }

  /// Get template count by tax type
  static Map<String, int> getTemplateCountByTaxType() {
    final counts = <String, int>{};
    for (var template in _box.values) {
      counts[template.taxType] = (counts[template.taxType] ?? 0) + 1;
    }
    return counts;
  }

  /// Clear all templates
  static Future<void> clearAllTemplates() async {
    await _box.clear();
  }

  /// Export templates to list of maps
  static List<Map<String, dynamic>> exportTemplates() {
    return _box.values.map((t) => t.toMap()).toList();
  }

  /// Import templates from list of maps
  static Future<void> importTemplates(
      List<Map<String, dynamic>> templateMaps) async {
    for (var map in templateMaps) {
      final template = CalculationTemplate.fromMap(map);
      await saveTemplate(template);
    }
  }
}
