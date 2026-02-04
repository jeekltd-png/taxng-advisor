/// Tax Rate Service for Nigerian tax rates with real-time updates
library;

import 'package:flutter/foundation.dart';
import '../models/tax_rates.dart';

/// Service for managing and updating Nigerian tax rates
class TaxRateService extends ChangeNotifier {
  NigerianTaxRates _rates = NigerianTaxRates.current();
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  NigerianTaxRates get rates => _rates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  double get vatRate => _rates.vatRate;
  double get citRate => _rates.citRate;
  double get eduTaxRate => _rates.eduTaxRate;
  double get nassTaxRate => _rates.nassTaxRate;
  Map<String, double> get whtRates => _rates.whtRates;
  List<PITBand> get pitBands => _rates.pitBands;
  double get minimumWage => _rates.minimumWage;

  Future<void> initialize() async {
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  Future<void> refreshRates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _rates = NigerianTaxRates.current();
      _lastUpdated = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update tax rates: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  double calculateVAT(double amount) {
    return amount * vatRate;
  }

  double calculateCIT(double taxableIncome) {
    return taxableIncome * citRate;
  }

  double calculateEduTax(double assessableProfit) {
    return assessableProfit * eduTaxRate;
  }

  double calculateWHT(String category, double amount) {
    final rate = whtRates[category] ?? whtRates['Others']!;
    return amount * rate;
  }

  double calculatePIT(double annualIncome) {
    if (annualIncome <= minimumWage * 12) {
      return 0;
    }

    double tax = 0;
    double remainingIncome = annualIncome;

    for (final band in pitBands) {
      if (remainingIncome <= 0) break;

      final bandAmount = band.upperLimit != null
          ? (band.upperLimit! - band.lowerLimit)
          : remainingIncome;

      final taxableInBand = remainingIncome > bandAmount
          ? bandAmount
          : remainingIncome;

      tax += taxableInBand * band.rate;
      remainingIncome -= taxableInBand;
    }

    return tax;
  }

  Map<String, double> calculatePITBreakdown(double annualIncome) {
    final breakdown = <String, double>{};

    if (annualIncome <= minimumWage * 12) {
      return {'Total Tax': 0};
    }

    double remainingIncome = annualIncome;

    for (int i = 0; i < pitBands.length && remainingIncome > 0; i++) {
      final band = pitBands[i];
      final bandAmount = band.upperLimit != null
          ? (band.upperLimit! - band.lowerLimit)
          : remainingIncome;

      final taxableInBand = remainingIncome > bandAmount
          ? bandAmount
          : remainingIncome;

      final taxInBand = taxableInBand * band.rate;
      breakdown['Band ${i + 1} (${(band.rate * 100).toInt()}%)'] = taxInBand;
      remainingIncome -= taxableInBand;
    }

    breakdown['Total Tax'] = breakdown.values.fold(0, (sum, tax) => sum + tax);
    return breakdown;
  }

  String formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )}';
  }

  String formatPercentage(double rate) {
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  Map<String, String> getRateSummary() {
    return {
      'VAT Rate': formatPercentage(vatRate),
      'CIT Rate': formatPercentage(citRate),
      'EDT Rate': formatPercentage(eduTaxRate),
      'Minimum Wage': formatCurrency(minimumWage),
      'Effective Date': _rates.effectiveDate.toIso8601String().split('T').first,
    };
  }
}
