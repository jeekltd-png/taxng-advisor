import 'package:hive/hive.dart';
import 'package:taxng_advisor/models/pricing_tier.dart';

/// Service for managing pricing tier data
class PricingService {
  static const String _boxName = 'pricing';
  static const String _tiersKey = 'tiers';

  /// Get the pricing box
  static Box get _box => Hive.box(_boxName);

  /// Initialize the pricing service
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }

    // Seed default pricing if none exists
    final existing = _box.get(_tiersKey);
    if (existing == null) {
      await saveTiers(PricingTier.getDefaultTiers());
    }
  }

  /// Get all pricing tiers
  static List<PricingTier> getTiers() {
    try {
      final data = _box.get(_tiersKey) as List<dynamic>?;
      if (data == null || data.isEmpty) {
        return PricingTier.getDefaultTiers();
      }
      return data
          .map((e) => PricingTier.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Error loading pricing tiers: $e');
      return PricingTier.getDefaultTiers();
    }
  }

  /// Save pricing tiers
  static Future<void> saveTiers(List<PricingTier> tiers) async {
    final data = tiers.map((t) => t.toMap()).toList();
    await _box.put(_tiersKey, data);
  }

  /// Reset to default pricing
  static Future<void> resetToDefaults() async {
    await saveTiers(PricingTier.getDefaultTiers());
  }
}
