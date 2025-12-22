/// Pricing tier data model
class PricingTier {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  PricingTier({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'period': period,
      'features': features,
      'isPopular': isPopular,
    };
  }

  factory PricingTier.fromMap(Map<String, dynamic> map) {
    return PricingTier(
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
      period: map['period'] as String? ?? '',
      features: (map['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isPopular: map['isPopular'] as bool? ?? false,
    );
  }

  /// Default pricing tiers
  static List<PricingTier> getDefaultTiers() {
    return [
      PricingTier(
        name: 'Free',
        price: '₦0',
        period: '/month',
        features: [
          'Core tax calculators (CIT, VAT, WHT, PAYE/PIT, Stamp Duty)',
          '3 reminders per month',
          'Local encrypted storage',
          'Basic calculations',
        ],
        isPopular: false,
      ),
      PricingTier(
        name: 'Basic',
        price: '₦500',
        period: '/month',
        features: [
          'All calculators',
          '10 reminders per month',
          'CSV export',
          'Watermarked PDF export',
          'Email support (business hours)',
        ],
        isPopular: false,
      ),
      PricingTier(
        name: 'Pro',
        price: '₦2,000',
        period: '/month',
        features: [
          'Multi-entity support',
          'Unlimited reminders',
          'Official-format PDF reports',
          'Payment link generation',
          'Remita, Flutterwave, Paystack integration',
          'Priority email/chat support',
          'Multi-user access',
          'Accountant invites',
        ],
        isPopular: true,
      ),
      PricingTier(
        name: 'Business',
        price: '₦8,000+',
        period: '/month',
        features: [
          'Everything in Pro, plus:',
          'Team accounts & role management',
          'White-labeling options',
          'API access',
          'Bulk filing tools',
          'Audit logs',
          'Dedicated account manager',
          'Custom pricing available',
        ],
        isPopular: false,
      ),
    ];
  }
}
