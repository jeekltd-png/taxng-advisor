/// Enhanced validation service with custom rules for tax calculators
class ValidationService {
  /// Validation rule model
  static final Map<String, List<ValidationRule>> _rules = {};

  /// Register validation rules for a calculator
  static void registerRules(String calculatorKey, List<ValidationRule> rules) {
    _rules[calculatorKey] = rules;
  }

  /// Validate data against registered rules
  static ValidationResult validate(
      String calculatorKey, Map<String, dynamic> data) {
    final rules = _rules[calculatorKey] ?? [];
    final errors = <String, String>{};
    final warnings = <String, String>{};

    for (final rule in rules) {
      final result = rule.validate(data);
      if (!result.isValid) {
        if (rule.severity == ValidationSeverity.error) {
          errors[rule.fieldName] = result.message;
        } else {
          warnings[rule.fieldName] = result.message;
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Get default rules for CIT calculator
  static List<ValidationRule> getCITRules() {
    return [
      ValidationRule(
        fieldName: 'turnover',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['turnover'] as double?;
          if (value == null || value <= 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Turnover must be a positive number',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'profit',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['profit'] as double?;
          if (value == null || value <= 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Profit must be a positive number',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'turnover',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final value = data['turnover'] as double?;
          if (value != null && value > 1000000000) {
            return RuleValidationResult(
              isValid: false,
              message: 'Turnover exceeds ₦1 billion - please verify',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'profit',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final turnover = data['turnover'] as double?;
          final profit = data['profit'] as double?;
          if (turnover != null && profit != null && profit > turnover) {
            return RuleValidationResult(
              isValid: false,
              message: 'Profit exceeds turnover - please verify',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
    ];
  }

  /// Get default rules for PIT calculator
  static List<ValidationRule> getPITRules() {
    return [
      ValidationRule(
        fieldName: 'grossIncome',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['grossIncome'] as double?;
          if (value == null || value < 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Gross income must be a positive number',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'otherDeductions',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final grossIncome = data['grossIncome'] as double?;
          final reliefs =
              (data['otherDeductions'] ?? data['reliefs']) as double?;
          if (grossIncome != null &&
              reliefs != null &&
              reliefs > grossIncome * 0.25) {
            return RuleValidationResult(
              isValid: false,
              message: 'Reliefs exceed 25% of gross income. Please verify.',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
    ];
  }

  /// Get default rules for VAT calculator
  static List<ValidationRule> getVATRules() {
    return [
      ValidationRule(
        fieldName: 'standardSales',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['standardSales'] as double?;
          if (value != null && value < 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Standard sales cannot be negative',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'zeroRatedSales',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['zeroRatedSales'] as double?;
          if (value != null && value < 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Zero-rated sales cannot be negative',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'exemptSales',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['exemptSales'] as double?;
          if (value != null && value < 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Exempt sales cannot be negative',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'totalInputVat',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['totalInputVat'] as double?;
          if (value != null && value < 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Total input VAT cannot be negative',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'exemptInputVat',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['exemptInputVat'] as double?;
          final totalInputVat = data['totalInputVat'] as double?;
          if (value != null && value < 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Exempt input VAT cannot be negative',
            );
          }
          if (value != null && totalInputVat != null && value > totalInputVat) {
            return RuleValidationResult(
              isValid: false,
              message: 'Exempt input VAT cannot exceed total input VAT',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'totalInputVat',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final standardSales = data['standardSales'] as double? ?? 0;
          final outputVAT = standardSales * 0.075; // 7.5% standard rate
          final inputVAT = data['totalInputVat'] as double? ?? 0;
          if (outputVAT > 0 && inputVAT > outputVAT * 1.5) {
            return RuleValidationResult(
              isValid: false,
              message:
                  'Input VAT exceeds output VAT - VAT refund due. File VAT return (Form 002) with FIRS showing refund position. Keep purchase invoices and reconciliation records for audit verification.',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
    ];
  }

  /// Get default rules for WHT calculator
  static List<ValidationRule> getWHTRules() {
    return [
      ValidationRule(
        fieldName: 'amount',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['amount'] as double?;
          if (value == null || value <= 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Amount must be greater than zero',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'type',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['type'];
          if (value == null) {
            return RuleValidationResult(
              isValid: false,
              message: 'Payment type is required',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
    ];
  }

  /// Get default rules for PAYE calculator
  static List<ValidationRule> getPAYERules() {
    return [
      ValidationRule(
        fieldName: 'monthlyGross',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['monthlyGross'] as double?;
          if (value == null || value <= 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Monthly gross salary must be greater than zero',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'monthlyGross',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final value = data['monthlyGross'] as double?;
          if (value != null && value < 70000) {
            return RuleValidationResult(
              isValid: false,
              message: 'Monthly gross salary is below minimum wage (₦70,000).',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
    ];
  }

  /// Get default rules for Stamp Duty calculator
  static List<ValidationRule> getStampDutyRules() {
    return [
      ValidationRule(
        fieldName: 'amount',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value =
              (data['amount'] ?? data['transactionAmount']) as double?;
          if (value == null || value <= 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Transaction amount must be greater than zero',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
      ValidationRule(
        fieldName: 'amount',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final value =
              (data['amount'] ?? data['transactionAmount']) as double?;
          if (value != null && value > 10000000) {
            return RuleValidationResult(
              isValid: false,
              message: 'Transaction amount exceeds ₦10 million. Please verify.',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      ),
    ];
  }
}

/// Validation rule model
class ValidationRule {
  final String fieldName;
  final ValidationSeverity severity;
  final RuleValidationResult Function(Map<String, dynamic> data) validate;

  ValidationRule({
    required this.fieldName,
    required this.severity,
    required this.validate,
  });
}

/// Validation severity
enum ValidationSeverity {
  error,
  warning,
}

/// Result of a single rule validation
class RuleValidationResult {
  final bool isValid;
  final String message;

  RuleValidationResult({
    required this.isValid,
    this.message = '',
  });
}

/// Overall validation result
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  String getErrorMessage(String fieldName) => errors[fieldName] ?? '';
  String getWarningMessage(String fieldName) => warnings[fieldName] ?? '';

  List<String> getAllErrors() => errors.values.toList();
  List<String> getAllWarnings() => warnings.values.toList();
}
