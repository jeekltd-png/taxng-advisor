/// Base class for all tax calculation results
abstract class TaxResult {
  DateTime get calculatedAt;
  String get taxType;
}

/// CIT Calculation Result
class CitResult extends TaxResult {
  final double turnover;
  final double profit;
  final String category;
  final double rate;
  final double taxPayable;
  final DateTime _calculatedAt;

  CitResult({
    required this.turnover,
    required this.profit,
    required this.category,
    required this.rate,
    required this.taxPayable,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  @override
  String get taxType => 'CIT';

  /// Effective tax rate (tax/turnover)
  double get effectiveRate => turnover > 0 ? taxPayable / turnover : 0.0;

  /// Convert to map for storage
  Map<String, dynamic> toMap() => {
        'turnover': turnover,
        'profit': profit,
        'category': category,
        'rate': rate,
        'taxPayable': taxPayable,
        'calculatedAt': _calculatedAt.toIso8601String(),
      };

  factory CitResult.fromMap(Map<String, dynamic> map) => CitResult(
        turnover: map['turnover'] as double,
        profit: map['profit'] as double,
        category: map['category'] as String,
        rate: map['rate'] as double,
        taxPayable: map['taxPayable'] as double,
        calculatedAt: DateTime.parse(map['calculatedAt'] as String),
      );
}

/// PIT Calculation Result
class PitResult extends TaxResult {
  final double grossIncome;
  final List<double> otherDeductions;
  final double annualRentPaid;
  final double totalDeductions;
  final double rentRelief;
  final double chargeableIncome;
  final double totalTax;
  final Map<String, double> breakdown;
  final DateTime _calculatedAt;

  PitResult({
    required this.grossIncome,
    required this.otherDeductions,
    required this.annualRentPaid,
    required this.totalDeductions,
    required this.rentRelief,
    required this.chargeableIncome,
    required this.totalTax,
    required this.breakdown,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  @override
  String get taxType => 'PIT';

  /// Effective tax rate on gross income
  double get effectiveRate => grossIncome > 0 ? totalTax / grossIncome : 0.0;

  /// Tax as percentage of chargeable income
  double get chargeableRate =>
      chargeableIncome > 0 ? totalTax / chargeableIncome : 0.0;

  Map<String, dynamic> toMap() => {
        'grossIncome': grossIncome,
        'otherDeductions': otherDeductions,
        'annualRentPaid': annualRentPaid,
        'totalDeductions': totalDeductions,
        'rentRelief': rentRelief,
        'chargeableIncome': chargeableIncome,
        'totalTax': totalTax,
        'breakdown': breakdown,
        'calculatedAt': _calculatedAt.toIso8601String(),
      };

  factory PitResult.fromMap(Map<String, dynamic> map) => PitResult(
        grossIncome: map['grossIncome'] as double,
        otherDeductions: List<double>.from(map['otherDeductions'] as List),
        annualRentPaid: map['annualRentPaid'] as double,
        totalDeductions: map['totalDeductions'] as double,
        rentRelief: map['rentRelief'] as double,
        chargeableIncome: map['chargeableIncome'] as double,
        totalTax: map['totalTax'] as double,
        breakdown: Map<String, double>.from(map['breakdown'] as Map),
        calculatedAt: DateTime.parse(map['calculatedAt'] as String),
      );
}

/// VAT Calculation Result
class VatResult extends TaxResult {
  final double vatableSales;
  final double zeroRatedSales;
  final double exemptSales;
  final double outputVat;
  final double recoverableInput;
  final double netPayable;
  final double refundEligible;
  final DateTime _calculatedAt;

  VatResult({
    required this.vatableSales,
    required this.zeroRatedSales,
    required this.exemptSales,
    required this.outputVat,
    required this.recoverableInput,
    required this.netPayable,
    required this.refundEligible,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  @override
  String get taxType => 'VAT';

  /// Total sales
  double get totalSales => vatableSales + zeroRatedSales + exemptSales;

  /// VAT compliance status
  bool get isRefund => refundEligible > 0;

  Map<String, dynamic> toMap() => {
        'vatableSales': vatableSales,
        'zeroRatedSales': zeroRatedSales,
        'exemptSales': exemptSales,
        'outputVat': outputVat,
        'recoverableInput': recoverableInput,
        'netPayable': netPayable,
        'refundEligible': refundEligible,
        'calculatedAt': _calculatedAt.toIso8601String(),
      };

  factory VatResult.fromMap(Map<String, dynamic> map) => VatResult(
        vatableSales: map['vatableSales'] as double,
        zeroRatedSales: map['zeroRatedSales'] as double,
        exemptSales: map['exemptSales'] as double,
        outputVat: map['outputVat'] as double,
        recoverableInput: map['recoverableInput'] as double,
        netPayable: map['netPayable'] as double,
        refundEligible: map['refundEligible'] as double,
        calculatedAt: DateTime.parse(map['calculatedAt'] as String),
      );
}

/// WHT Calculation Result
class WhtResult extends TaxResult {
  final double amount;
  final String type;
  final double rate;
  final double wht;
  final double netAmount;
  final DateTime _calculatedAt;

  WhtResult({
    required this.amount,
    required this.type,
    required this.rate,
    required this.wht,
    required this.netAmount,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  @override
  String get taxType => 'WHT';

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'type': type,
        'rate': rate,
        'wht': wht,
        'netAmount': netAmount,
        'calculatedAt': _calculatedAt.toIso8601String(),
      };

  factory WhtResult.fromMap(Map<String, dynamic> map) => WhtResult(
        amount: map['amount'] as double,
        type: map['type'] as String,
        rate: map['rate'] as double,
        wht: map['wht'] as double,
        netAmount: map['netAmount'] as double,
        calculatedAt: DateTime.parse(map['calculatedAt'] as String),
      );
}

/// Stamp Duty Calculation Result
class StampDutyResult extends TaxResult {
  final double amount;
  final String type;
  final double duty;
  final DateTime _calculatedAt;

  StampDutyResult({
    required this.amount,
    required this.type,
    required this.duty,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  @override
  String get taxType => 'StampDuty';

  double get netAmount => amount - duty;

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'type': type,
        'duty': duty,
        'calculatedAt': _calculatedAt.toIso8601String(),
      };

  factory StampDutyResult.fromMap(Map<String, dynamic> map) => StampDutyResult(
        amount: map['amount'] as double,
        type: map['type'] as String,
        duty: map['duty'] as double,
        calculatedAt: DateTime.parse(map['calculatedAt'] as String),
      );
}

/// Payroll Calculation Result
class PayrollResult extends TaxResult {
  final double monthlyGross;
  final double annualGross;
  final double monthlyPaye;
  final double annualPaye;
  final double monthlyNet;
  final double annualNet;
  final DateTime _calculatedAt;

  PayrollResult({
    required this.monthlyGross,
    required this.annualGross,
    required this.monthlyPaye,
    required this.annualPaye,
    required this.monthlyNet,
    required this.annualNet,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  @override
  String get taxType => 'Payroll';

  double get effectiveMonthlyRate =>
      monthlyGross > 0 ? monthlyPaye / monthlyGross : 0.0;

  double get effectiveAnnualRate =>
      annualGross > 0 ? annualPaye / annualGross : 0.0;

  Map<String, dynamic> toMap() => {
        'monthlyGross': monthlyGross,
        'annualGross': annualGross,
        'monthlyPaye': monthlyPaye,
        'annualPaye': annualPaye,
        'monthlyNet': monthlyNet,
        'annualNet': annualNet,
        'calculatedAt': _calculatedAt.toIso8601String(),
      };

  factory PayrollResult.fromMap(Map<String, dynamic> map) => PayrollResult(
        monthlyGross: map['monthlyGross'] as double,
        annualGross: map['annualGross'] as double,
        monthlyPaye: map['monthlyPaye'] as double,
        annualPaye: map['annualPaye'] as double,
        monthlyNet: map['monthlyNet'] as double,
        annualNet: map['annualNet'] as double,
        calculatedAt: DateTime.parse(map['calculatedAt'] as String),
      );
}
