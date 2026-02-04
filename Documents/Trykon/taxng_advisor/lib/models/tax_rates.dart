/// Tax Rate Model and Nigerian Tax Rates Configuration
library;

/// Nigerian Tax Rates - Current as of 2026
class NigerianTaxRates {
  static final DateTime lastUpdated = DateTime(2026, 2, 4);

  // VAT Rates
  static const double vatStandardRate = 7.5;
  static const double vatExemptRate = 0.0;

  // Company Income Tax (CIT) Rates
  static const double citLargeCompanyRate = 30.0;
  static const double citMediumCompanyRate = 20.0;
  static const double citSmallCompanyRate = 0.0;
  static const double citLargeThreshold = 100000000;
  static const double citMediumThreshold = 25000000;

  // Tertiary Education Tax
  static const double tertiaryEducationTaxRate = 2.5;

  // Withholding Tax (WHT) Rates - Companies
  static const double whtDividendCompany = 10.0;
  static const double whtInterestCompany = 10.0;
  static const double whtRoyaltyCompany = 10.0;
  static const double whtRentCompany = 10.0;
  static const double whtContractCompany = 5.0;
  static const double whtConsultancyCompany = 10.0;

  // WHT Rates - Individuals
  static const double whtDividendIndividual = 10.0;
  static const double whtInterestIndividual = 10.0;
  static const double whtRoyaltyIndividual = 5.0;
  static const double whtRentIndividual = 10.0;
  static const double whtContractIndividual = 5.0;
  static const double whtConsultancyIndividual = 5.0;

  // Pension Contribution
  static const double pensionEmployeeRate = 8.0;
  static const double pensionEmployerRate = 10.0;
  static const double pensionTotalRate = 18.0;

  // NHF Rate
  static const double nhfRate = 2.5;

  // Stamp Duty Rates
  static const double stampDutyAgreement = 0.75;
  static const double stampDutyDeed = 1.5;
  static const double stampDutyLease = 0.78;
  static const double stampDutyMortgage = 0.375;
  static const double stampDutyShareTransfer = 0.75;
  static const double stampDutyReceipt = 50.0;
  static const double stampDutyReceiptThreshold = 10000;
  static const double stampDutyElectronicTransfer = 50.0;
  static const double stampDutyElectronicThreshold = 10000;

  // PIT Bands
  static final List<PITBand> pitBands = [
    PITBand(lowerLimit: 0, upperLimit: 300000, rate: 7.0),
    PITBand(lowerLimit: 300000, upperLimit: 600000, rate: 11.0),
    PITBand(lowerLimit: 600000, upperLimit: 1100000, rate: 15.0),
    PITBand(lowerLimit: 1100000, upperLimit: 1600000, rate: 19.0),
    PITBand(lowerLimit: 1600000, upperLimit: 3200000, rate: 21.0),
    PITBand(lowerLimit: 3200000, upperLimit: double.infinity, rate: 24.0),
  ];

  static const double consolidatedReliefAllowance = 200000;
  static const double consolidatedReliefPercent = 20.0;

  static double getCITRate(double turnover) {
    if (turnover < citMediumThreshold) {
      return citSmallCompanyRate;
    } else if (turnover < citLargeThreshold) {
      return citMediumCompanyRate;
    }
    return citLargeCompanyRate;
  }

  static String getCITCategory(double turnover) {
    if (turnover < citMediumThreshold) {
      return 'Small Company (Exempt)';
    } else if (turnover < citLargeThreshold) {
      return 'Medium Company';
    }
    return 'Large Company';
  }

  static double calculatePIT(double taxableIncome) {
    double tax = 0;
    double remainingIncome = taxableIncome;

    for (final band in pitBands) {
      if (remainingIncome <= 0) break;
      final bandAmount = band.upperLimit - band.lowerLimit;
      final taxableInBand =
          remainingIncome > bandAmount ? bandAmount : remainingIncome;
      tax += taxableInBand * (band.rate / 100);
      remainingIncome -= taxableInBand;
    }

    return tax;
  }

  static double getWHTRate(String incomeType, {bool isCompany = true}) {
    switch (incomeType.toLowerCase()) {
      case 'dividend':
        return isCompany ? whtDividendCompany : whtDividendIndividual;
      case 'interest':
        return isCompany ? whtInterestCompany : whtInterestIndividual;
      case 'royalty':
        return isCompany ? whtRoyaltyCompany : whtRoyaltyIndividual;
      case 'rent':
        return isCompany ? whtRentCompany : whtRentIndividual;
      case 'contract':
        return isCompany ? whtContractCompany : whtContractIndividual;
      case 'consultancy':
        return isCompany ? whtConsultancyCompany : whtConsultancyIndividual;
      default:
        return 10.0;
    }
  }

  static Map<String, dynamic> getAllRates() => {
        'lastUpdated': lastUpdated.toIso8601String(),
        'vat': {'standard': vatStandardRate, 'exempt': vatExemptRate},
        'cit': {
          'large': citLargeCompanyRate,
          'medium': citMediumCompanyRate,
          'small': citSmallCompanyRate,
          'thresholds': {
            'large': citLargeThreshold,
            'medium': citMediumThreshold,
          },
        },
        'tertiaryEducationTax': tertiaryEducationTaxRate,
        'pension': {
          'employee': pensionEmployeeRate,
          'employer': pensionEmployerRate,
          'total': pensionTotalRate,
        },
        'nhf': nhfRate,
        'stampDuty': {
          'agreement': stampDutyAgreement,
          'deed': stampDutyDeed,
          'lease': stampDutyLease,
          'mortgage': stampDutyMortgage,
          'shareTransfer': stampDutyShareTransfer,
          'receipt': stampDutyReceipt,
          'receiptThreshold': stampDutyReceiptThreshold,
          'electronicTransfer': stampDutyElectronicTransfer,
          'electronicThreshold': stampDutyElectronicThreshold,
        },
      };
}

/// Personal Income Tax band
class PITBand {
  final double lowerLimit;
  final double upperLimit;
  final double rate;

  PITBand({
    required this.lowerLimit,
    required this.upperLimit,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
        'lowerLimit': lowerLimit,
        'upperLimit': upperLimit,
        'rate': rate,
      };

  factory PITBand.fromJson(Map<String, dynamic> json) => PITBand(
        lowerLimit: (json['lowerLimit'] as num).toDouble(),
        upperLimit: (json['upperLimit'] as num).toDouble(),
        rate: (json['rate'] as num).toDouble(),
      );
}
