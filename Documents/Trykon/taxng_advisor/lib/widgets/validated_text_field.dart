import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/validation_service.dart';

/// Widget that provides real-time validation for form fields
class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String fieldName;
  final String calculatorKey;
  final Map<String, dynamic> Function() getFormData;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? suffixText;
  final String? hintText;
  final int? maxLines;
  final bool enabled;
  final Widget? suffix;

  const ValidatedTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.fieldName,
    required this.calculatorKey,
    required this.getFormData,
    this.keyboardType,
    this.prefixText,
    this.suffixText,
    this.hintText,
    this.maxLines,
    this.enabled = true,
    this.suffix,
  }) : super(key: key);

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorMessage;
  String? _warningMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    // Debounce validation
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _validate();
      }
    });
  }

  void _validate() {
    final formData = widget.getFormData();
    final result = ValidationService.validate(widget.calculatorKey, formData);

    setState(() {
      _errorMessage = result.getErrorMessage(widget.fieldName);
      _warningMessage = result.getWarningMessage(widget.fieldName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;
    final hasWarning = _warningMessage != null && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hintText,
                  prefixText: widget.prefixText,
                  suffixText: widget.suffix == null ? widget.suffixText : null,
                  suffix: widget.suffix,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError
                          ? Colors.red
                          : hasWarning
                              ? Colors.orange
                              : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError
                          ? Colors.red
                          : hasWarning
                              ? Colors.orange
                              : Colors.grey.shade400,
                    ),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError
                          ? Colors.red
                          : hasWarning
                              ? Colors.orange
                              : Colors.green,
                      width: 2,
                    ),
                  ),
                  errorText: _errorMessage,
                ),
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines ?? 1,
                enabled: widget.enabled,
              ),
            ),
            if (hasError || hasWarning) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: _getHelpMessage(),
                child: Icon(
                  Icons.help_outline,
                  size: 20,
                  color: hasError ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ],
        ),
        if (hasWarning) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _warningMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (hasError) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[900],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getSuggestion(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getHelpMessage() {
    if (_errorMessage != null) {
      return 'Fix this error: ${_getSuggestion()}';
    }
    return _warningMessage ?? '';
  }

  String _getSuggestion() {
    if (_errorMessage == null) return '';

    final error = _errorMessage!.toLowerCase();

    if (error.contains('required') || error.contains('empty')) {
      return '💡 This field cannot be empty. Please enter a value.';
    }
    if (error.contains('must be greater than zero')) {
      return '💡 Enter a positive number greater than 0.';
    }
    if (error.contains('invalid') && error.contains('number')) {
      return '💡 Enter numbers only (e.g., 5000000).';
    }
    if (error.contains('turnover') && error.contains('profit')) {
      return '💡 Turnover must be equal to or greater than profit.';
    }
    if (error.contains('percentage')) {
      return '💡 Enter a value between 0 and 100.';
    }
    if (error.contains('minimum')) {
      return '💡 Value is below the minimum requirement.';
    }
    if (error.contains('maximum')) {
      return '💡 Value exceeds the maximum limit.';
    }

    return '💡 Please check the value and try again.';
  }
}

/// Validation summary widget
class ValidationSummary extends StatelessWidget {
  final ValidationResult result;
  final VoidCallback? onDismiss;

  const ValidationSummary({
    Key? key,
    required this.result,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!result.hasErrors && !result.hasWarnings) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: result.hasErrors ? Colors.red[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.hasErrors ? Icons.error : Icons.warning,
                  color: result.hasErrors ? Colors.red : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.hasErrors ? 'Validation Errors' : 'Warnings',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: result.hasErrors
                          ? Colors.red[900]
                          : Colors.orange[900],
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...result.getAllErrors().map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.red)),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            ...result.getAllWarnings().map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.orange)),
                      Expanded(
                        child: Text(
                          warning,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/// Live validation indicator
class ValidationIndicator extends StatelessWidget {
  final bool isValid;
  final bool hasWarnings;
  final String? message;

  const ValidationIndicator({
    Key? key,
    required this.isValid,
    this.hasWarnings = false,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isValid
              ? (hasWarnings ? Icons.warning : Icons.check_circle)
              : Icons.error,
          size: 16,
          color: isValid
              ? (hasWarnings ? Colors.orange : Colors.green)
              : Colors.red,
        ),
        if (message != null) ...[
          const SizedBox(width: 4),
          Text(
            message!,
            style: TextStyle(
              fontSize: 12,
              color: isValid
                  ? (hasWarnings ? Colors.orange : Colors.green)
                  : Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

/// Form validator mixin
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  ValidationResult? _lastValidation;

  ValidationResult? get lastValidation => _lastValidation;

  /// Validate form data
  ValidationResult validateForm(
      String calculatorKey, Map<String, dynamic> data) {
    _lastValidation = ValidationService.validate(calculatorKey, data);
    return _lastValidation!;
  }

  /// Show validation errors dialog
  void showValidationErrors(ValidationResult result) {
    if (!result.hasErrors && !result.hasWarnings) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.hasErrors ? Icons.error : Icons.warning,
              color: result.hasErrors ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(result.hasErrors ? 'Validation Errors' : 'Warnings'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.hasErrors) ...[
                const Text(
                  'Please fix the following errors:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.getAllErrors().map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $error',
                          style: const TextStyle(color: Colors.red)),
                    )),
              ],
              if (result.hasWarnings) ...[
                if (result.hasErrors) const SizedBox(height: 12),
                const Text(
                  'Warnings:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.getAllWarnings().map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $warning',
                          style: const TextStyle(color: Colors.orange)),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          if (!result.hasErrors && result.hasWarnings)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: result.hasErrors ? Colors.grey : Colors.green,
            ),
            child: Text(result.hasErrors ? 'OK' : 'Continue Anyway'),
          ),
        ],
      ),
    );
  }

  /// Check if form can be submitted
  Future<bool> canSubmit(
      String calculatorKey, Map<String, dynamic> data) async {
    final result = validateForm(calculatorKey, data);

    if (result.hasErrors) {
      showValidationErrors(result);
      return false;
    }

    if (result.hasWarnings) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Warnings'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result
                .getAllWarnings()
                .map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $warning'),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      return proceed ?? false;
    }

    return true;
  }
}
