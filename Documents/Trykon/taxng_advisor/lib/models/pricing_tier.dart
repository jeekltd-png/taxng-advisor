/// Billing cycle options
enum BillingCycle {
  monthly,
  quarterly,
  annual,
}

/// Pricing tier data model
class PricingTier {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final double monthlyPrice; // Base monthly price in Naira
  final int freeTrialDays; // Free trial days (0 = no trial)

  PricingTier({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.monthlyPrice = 0.0,
    this.freeTrialDays = 0,
  });

  /// Calculate price based on billing cycle with discounts
  /// - Monthly: Full price
  /// - Quarterly: 10% discount (pay for 2.7 months)
  /// - Annual: 20% discount (pay for 9.6 months = ~10 months)
  double getPriceForCycle(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return monthlyPrice;
      case BillingCycle.quarterly:
        // 10% discount: pay 2.7 months for 3 months
        return monthlyPrice * 3 * 0.90;
      case BillingCycle.annual:
        // 20% discount: pay 9.6 months for 12 months
        return monthlyPrice * 12 * 0.80;
    }
  }

  /// Get savings amount for a billing cycle
  double getSavings(BillingCycle cycle) {
    final fullPrice = monthlyPrice * _getMonthsInCycle(cycle);
    final discountedPrice = getPriceForCycle(cycle);
    return fullPrice - discountedPrice;
  }

  /// Get discount percentage for a billing cycle
  int getDiscountPercent(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 0;
      case BillingCycle.quarterly:
        return 10;
      case BillingCycle.annual:
        return 20;
    }
  }

  int _getMonthsInCycle(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.quarterly:
        return 3;
      case BillingCycle.annual:
        return 12;
    }
  }

  /// Get billing cycle display name
  static String getCycleDisplayName(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.annual:
        return 'Annual';
    }
  }

  /// Get billing cycle period suffix
  static String getCyclePeriod(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return '/month';
      case BillingCycle.quarterly:
        return '/quarter';
      case BillingCycle.annual:
        return '/year';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'period': period,
      'features': features,
      'isPopular': isPopular,
      'monthlyPrice': monthlyPrice,
      'freeTrialDays': freeTrialDays,
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
      monthlyPrice: (map['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      freeTrialDays: map['freeTrialDays'] as int? ?? 0,
    );
  }

  /// Default pricing tiers with Nigerian market-appropriate pricing
  /// - Individual: ₦2,000/month (reduced for price-sensitive individuals)
  /// - Business: ₦12,000/month (well-positioned for SMEs)
  /// - Enterprise: ₦50,000/month (for large organizations)
  /// All paid tiers include 14-day free trial
  static List<PricingTier> getDefaultTiers() {
    return [
      PricingTier(
        name: 'Free',
        price: '₦0',
        period: '/month',
        monthlyPrice: 0.0,
        freeTrialDays: 0,
        features: [
          'View-only access to all calculators',
          'Use "Example Data" button only',
          'See calculated tax amounts',
          'No custom data entry',
        ],
        isPopular: false,
      ),
      PricingTier(
        name: 'Individual',
        price: '₦2,000',
        period: '/month',
        monthlyPrice: 2000.0,
        freeTrialDays: 14,
        features: [
          'Unlimited calculations',
          'PDF export',
          'Calculation history (6 months)',
          'Tax reminders',
          'Import/export data (CSV, JSON)',
          'Email support',
          '14-day free trial',
        ],
        isPopular: false,
      ),
      PricingTier(
        name: 'Business',
        price: '₦12,000',
        period: '/month',
        monthlyPrice: 12000.0,
        freeTrialDays: 14,
        features: [
          'Everything in Individual',
          'VAT refund tools (Form 002)',
          'Document vault',
          'Unlimited history',
          'Multiple users (up to 5)',
          'Priority support',
          'Tax templates',
          '14-day free trial',
        ],
        isPopular: true,
      ),
      PricingTier(
        name: 'Enterprise',
        price: '₦50,000',
        period: '/month',
        monthlyPrice: 50000.0,
        freeTrialDays: 14,
        features: [
          'Everything in Business',
          'Unlimited users',
          'Dedicated account manager',
          'Custom integrations & API',
          'Tax advisor consultation',
          'White-label option',
          '14-day free trial',
        ],
        isPopular: false,
      ),
    ];
  }
}
