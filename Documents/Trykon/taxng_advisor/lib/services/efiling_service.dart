/// E-Filing Service for FIRS Portal Integration
library;

import 'package:flutter/foundation.dart';

/// Status of an e-filing submission
enum EFilingStatus {
  draft,
  pendingSubmission,
  submitted,
  processing,
  accepted,
  rejected,
  requiresRevision,
}

/// Type of tax filing
enum FilingType {
  vat,
  cit,
  pit,
  wht,
  stampDuty,
  payee,
}

/// TIN validation result
class TINValidationResult {
  final bool isValid;
  final String? taxPayerName;
  final String? taxPayerAddress;
  final String? taxOffice;
  final String? message;
  final DateTime? validatedAt;

  const TINValidationResult({
    required this.isValid,
    this.taxPayerName,
    this.taxPayerAddress,
    this.taxOffice,
    this.message,
    this.validatedAt,
  });

  factory TINValidationResult.valid({
    required String taxPayerName,
    String? taxPayerAddress,
    String? taxOffice,
  }) {
    return TINValidationResult(
      isValid: true,
      taxPayerName: taxPayerName,
      taxPayerAddress: taxPayerAddress,
      taxOffice: taxOffice,
      validatedAt: DateTime.now(),
    );
  }

  factory TINValidationResult.invalid(String message) {
    return TINValidationResult(
      isValid: false,
      message: message,
      validatedAt: DateTime.now(),
    );
  }
}

/// E-Filing submission record
class EFilingSubmission {
  final String id;
  final FilingType filingType;
  final String taxPeriod;
  final DateTime submittedAt;
  final EFilingStatus status;
  final double amount;
  final String? referenceNumber;
  final String? acknowledgmentNumber;
  final Map<String, dynamic> filingData;
  final String? errorMessage;
  final List<String>? attachments;

  const EFilingSubmission({
    required this.id,
    required this.filingType,
    required this.taxPeriod,
    required this.submittedAt,
    required this.status,
    required this.amount,
    this.referenceNumber,
    this.acknowledgmentNumber,
    required this.filingData,
    this.errorMessage,
    this.attachments,
  });

  EFilingSubmission copyWith({
    EFilingStatus? status,
    String? referenceNumber,
    String? acknowledgmentNumber,
    String? errorMessage,
  }) {
    return EFilingSubmission(
      id: id,
      filingType: filingType,
      taxPeriod: taxPeriod,
      submittedAt: submittedAt,
      status: status ?? this.status,
      amount: amount,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      acknowledgmentNumber: acknowledgmentNumber ?? this.acknowledgmentNumber,
      filingData: filingData,
      errorMessage: errorMessage ?? this.errorMessage,
      attachments: attachments,
    );
  }

  String get filingTypeDisplay {
    switch (filingType) {
      case FilingType.vat:
        return 'VAT Return';
      case FilingType.cit:
        return 'Company Income Tax';
      case FilingType.pit:
        return 'Personal Income Tax';
      case FilingType.wht:
        return 'Withholding Tax';
      case FilingType.stampDuty:
        return 'Stamp Duty';
      case FilingType.payee:
        return 'PAYE Return';
    }
  }

  String get statusDisplay {
    switch (status) {
      case EFilingStatus.draft:
        return 'Draft';
      case EFilingStatus.pendingSubmission:
        return 'Pending Submission';
      case EFilingStatus.submitted:
        return 'Submitted';
      case EFilingStatus.processing:
        return 'Processing';
      case EFilingStatus.accepted:
        return 'Accepted';
      case EFilingStatus.rejected:
        return 'Rejected';
      case EFilingStatus.requiresRevision:
        return 'Requires Revision';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filingType': filingType.name,
      'taxPeriod': taxPeriod,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.name,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'acknowledgmentNumber': acknowledgmentNumber,
      'filingData': filingData,
      'errorMessage': errorMessage,
      'attachments': attachments,
    };
  }

  factory EFilingSubmission.fromJson(Map<String, dynamic> json) {
    return EFilingSubmission(
      id: json['id'],
      filingType: FilingType.values.firstWhere(
        (e) => e.name == json['filingType'],
      ),
      taxPeriod: json['taxPeriod'],
      submittedAt: DateTime.parse(json['submittedAt']),
      status: EFilingStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      amount: json['amount'].toDouble(),
      referenceNumber: json['referenceNumber'],
      acknowledgmentNumber: json['acknowledgmentNumber'],
      filingData: Map<String, dynamic>.from(json['filingData']),
      errorMessage: json['errorMessage'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }
}

/// Service for handling e-filing with FIRS
class EFilingService extends ChangeNotifier {
  final List<EFilingSubmission> _submissions = [];
  bool _isLoading = false;
  String? _error;
  TINValidationResult? _lastTINValidation;

  List<EFilingSubmission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TINValidationResult? get lastTINValidation => _lastTINValidation;

  List<EFilingSubmission> get pendingSubmissions => _submissions
      .where((s) =>
          s.status == EFilingStatus.pendingSubmission ||
          s.status == EFilingStatus.processing)
      .toList();

  List<EFilingSubmission> get completedSubmissions =>
      _submissions.where((s) => s.status == EFilingStatus.accepted).toList();

  Future<TINValidationResult> validateTIN(String tin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (tin.length != 10 && tin.length != 14) {
        _lastTINValidation = TINValidationResult.invalid(
          'Invalid TIN format. TIN should be 10 or 14 digits.',
        );
      } else if (!RegExp(r'^\d+$').hasMatch(tin)) {
        _lastTINValidation = TINValidationResult.invalid(
          'TIN should contain only numbers.',
        );
      } else {
        _lastTINValidation = TINValidationResult.valid(
          taxPayerName: 'Sample Tax Payer',
          taxPayerAddress: 'Lagos, Nigeria',
          taxOffice: 'Federal Inland Revenue Service',
        );
      }

      _isLoading = false;
      notifyListeners();
      return _lastTINValidation!;
    } catch (e) {
      _error = 'TIN validation failed: $e';
      _lastTINValidation = TINValidationResult.invalid(_error!);
      _isLoading = false;
      notifyListeners();
      return _lastTINValidation!;
    }
  }

  Future<EFilingSubmission> createSubmission({
    required FilingType filingType,
    required String taxPeriod,
    required double amount,
    required Map<String, dynamic> filingData,
    List<String>? attachments,
  }) async {
    final submission = EFilingSubmission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filingType: filingType,
      taxPeriod: taxPeriod,
      submittedAt: DateTime.now(),
      status: EFilingStatus.draft,
      amount: amount,
      filingData: filingData,
      attachments: attachments,
    );

    _submissions.add(submission);
    notifyListeners();
    return submission;
  }

  Future<EFilingSubmission> submitToFIRS(String submissionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _submissions.indexWhere((s) => s.id == submissionId);
      if (index == -1) {
        throw Exception('Submission not found');
      }

      await Future.delayed(const Duration(seconds: 3));

      final referenceNumber =
          'FIRS-${DateTime.now().year}-${submissionId.substring(submissionId.length - 6)}';

      _submissions[index] = _submissions[index].copyWith(
        status: EFilingStatus.submitted,
        referenceNumber: referenceNumber,
      );

      _isLoading = false;
      notifyListeners();
      return _submissions[index];
    } catch (e) {
      _error = 'Submission failed: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<EFilingStatus> checkSubmissionStatus(String referenceNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return EFilingStatus.processing;
    } catch (e) {
      _error = 'Status check failed: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  String getFIRSPortalUrl(FilingType type) {
    switch (type) {
      case FilingType.vat:
        return 'https://tax.firs.gov.ng/vat';
      case FilingType.cit:
        return 'https://tax.firs.gov.ng/cit';
      case FilingType.pit:
        return 'https://tax.firs.gov.ng/pit';
      case FilingType.wht:
        return 'https://tax.firs.gov.ng/wht';
      case FilingType.stampDuty:
        return 'https://tax.firs.gov.ng/stamp-duty';
      case FilingType.payee:
        return 'https://tax.firs.gov.ng/paye';
    }
  }

  List<String> getRequiredDocuments(FilingType type) {
    switch (type) {
      case FilingType.vat:
        return [
          'VAT Returns Form',
          'Schedule of Input VAT',
          'Schedule of Output VAT',
          'Supporting invoices',
        ];
      case FilingType.cit:
        return [
          'Audited Financial Statements',
          'Tax Computation',
          'Capital Allowance Schedule',
          'Schedule of Qualifying Expenditure',
        ];
      case FilingType.pit:
        return [
          'Form A - Self Assessment',
          'Evidence of Income',
          'Relief Claims Documentation',
        ];
      case FilingType.wht:
        return [
          'WHT Deduction Schedule',
          'Contracts/Invoices',
          'Proof of Payment to Contractors',
        ];
      case FilingType.stampDuty:
        return [
          'Original Document for Stamping',
          'Stamp Duty Assessment Form',
        ];
      case FilingType.payee:
        return [
          'Monthly PAYE Schedule',
          'Employee Details',
          'Tax Deduction Cards',
        ];
    }
  }
}
