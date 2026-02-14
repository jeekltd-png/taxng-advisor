import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Error types for categorization
enum ErrorType {
  network,
  storage,
  validation,
  fileSystem,
  calculation,
  unknown,
}

/// A structured error record for persistence and later reporting.
class ErrorRecord {
  final String message;
  final String errorType;
  final String? stackTrace;
  final String? context;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  ErrorRecord({
    required this.message,
    required this.errorType,
    this.stackTrace,
    this.context,
    this.additionalData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'message': message,
        'errorType': errorType,
        'stackTrace': stackTrace,
        'context': context,
        'additionalData': additionalData,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ErrorRecord.fromMap(Map<String, dynamic> m) => ErrorRecord(
        message: m['message'] as String? ?? '',
        errorType: m['errorType'] as String? ?? 'unknown',
        stackTrace: m['stackTrace'] as String?,
        context: m['context'] as String?,
        additionalData: m['additionalData'] != null
            ? Map<String, dynamic>.from(m['additionalData'] as Map)
            : null,
        timestamp: DateTime.tryParse(m['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Error recovery service for graceful error handling and crash reporting.
///
/// Errors are persisted to a Hive box (`error_logs`) so they survive
/// app restarts. They can later be exported as JSON or sent to a remote
/// backend when one becomes available.
class ErrorRecoveryService {
  static const _errorLogBox = 'error_logs';
  static const int _maxLogEntries = 500;

  /// Open (or return already-open) error log box.
  static Future<Box> _openLogBox() async {
    if (!Hive.isBoxOpen(_errorLogBox)) {
      return await Hive.openBox(_errorLogBox);
    }
    return Hive.box(_errorLogBox);
  }

  /// Initialize the error reporting subsystem (call from main).
  static Future<void> initialize() async {
    await _openLogBox();

    // Capture Flutter framework errors globally.
    FlutterError.onError = (details) {
      logError(
        details.exception,
        stackTrace: details.stack,
        context: 'FlutterError: ${details.library}',
      );
      // Keep the default red-screen in debug mode.
      FlutterError.presentError(details);
    };

    debugPrint('✅ Error reporting service initialized');
  }

  /// Persist an error to the local log.
  static Future<void> _persistError(ErrorRecord record) async {
    try {
      final box = await _openLogBox();
      await box.add(record.toMap());

      // Trim oldest entries to stay within budget.
      if (box.length > _maxLogEntries) {
        final excess = box.length - _maxLogEntries;
        for (int i = 0; i < excess; i++) {
          await box.deleteAt(0);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to persist error log: $e');
    }
  }

  /// Get all persisted error logs.
  static Future<List<ErrorRecord>> getErrorLogs() async {
    final box = await _openLogBox();
    return box.values.map((v) {
      final m = v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
      return ErrorRecord.fromMap(m);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Export error logs as a JSON string (for sharing / support tickets).
  static Future<String> exportErrorLogsAsJson() async {
    final logs = await getErrorLogs();
    return const JsonEncoder.withIndent('  ')
        .convert(logs.map((l) => l.toMap()).toList());
  }

  /// Clear all persisted error logs.
  static Future<void> clearErrorLogs() async {
    final box = await _openLogBox();
    await box.clear();
  }

  /// Handle error with user-friendly dialog and recovery options
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    ErrorType? errorType,
    String? customMessage,
    VoidCallback? onRetry,
    bool showDetails = true,
  }) async {
    final detectedType = errorType ?? _detectErrorType(error);
    final message = customMessage ?? _getErrorMessage(error, detectedType);
    final suggestions = _getRecoverySuggestions(detectedType);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(detectedType),
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Recovery suggestions
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'What you can try:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...suggestions.map((suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Error details (expandable)
              if (showDetails) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text(
                    'Technical Details',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kDebugMode
                              ? error.toString()
                              : 'Error details available in debug mode.',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Detect error type from exception
  static ErrorType _detectErrorType(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return ErrorType.network;
    } else if (errorStr.contains('filesystem') ||
        errorStr.contains('file') ||
        errorStr.contains('permission')) {
      return ErrorType.fileSystem;
    } else if (errorStr.contains('storage') ||
        errorStr.contains('hive') ||
        errorStr.contains('box')) {
      return ErrorType.storage;
    } else if (error is FormatException ||
        error.toString().contains('validation') ||
        error.toString().contains('invalid')) {
      return ErrorType.validation;
    }
    return ErrorType.unknown;
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Unable to connect to the network. Please check your internet connection and try again.';
      case ErrorType.storage:
        return 'There was a problem saving or loading data. Your data may not have been saved.';
      case ErrorType.validation:
        return 'The data you entered is invalid. Please check your inputs and try again.';
      case ErrorType.fileSystem:
        return 'Unable to access files on your device. Please check app permissions.';
      case ErrorType.calculation:
        return 'An error occurred while performing the calculation. Please verify your inputs.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
    }
  }

  /// Get recovery suggestions based on error type
  static List<String> _getRecoverySuggestions(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return [
          'Check your internet connection',
          'Try switching between WiFi and mobile data',
          'Disable VPN if enabled',
          'Try again after a few moments',
        ];
      case ErrorType.storage:
        return [
          'Restart the app',
          'Check available storage space',
          'Clear app cache (Settings > Apps)',
          'Contact support if data is lost',
        ];
      case ErrorType.validation:
        return [
          'Review all input fields for errors',
          'Make sure all required fields are filled',
          'Check that numbers are in valid ranges',
          'Ensure dates are in correct format',
        ];
      case ErrorType.fileSystem:
        return [
          'Check app permissions (Settings > Apps > Permissions)',
          'Ensure sufficient storage space',
          'Try saving to a different location',
          'Restart your device',
        ];
      case ErrorType.calculation:
        return [
          'Verify all input values are correct',
          'Check for negative or zero values where not allowed',
          'Ensure tax rates are within valid ranges',
          'Try breaking down the calculation into smaller steps',
        ];
      case ErrorType.unknown:
        return [
          'Restart the app',
          'Clear app cache',
          'Update to the latest version',
          'Contact support with error details',
        ];
    }
  }

  /// Get appropriate icon for error type
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.fileSystem:
        return Icons.folder_off;
      case ErrorType.calculation:
        return Icons.calculate;
      case ErrorType.unknown:
        return Icons.error;
    }
  }

  /// Log error for debugging AND persist to local crash log.
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    debugPrint('=== ERROR LOG ===');
    debugPrint('Context: ${context ?? 'Unknown'}');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack Trace:\n$stackTrace');
    }
    if (additionalData != null) {
      debugPrint('Additional Data: $additionalData');
    }
    debugPrint('=================');

    // Persist asynchronously — fire-and-forget so it doesn't block the caller.
    final record = ErrorRecord(
      message: error.toString(),
      errorType: _detectErrorType(error).name,
      stackTrace: stackTrace?.toString(),
      context: context,
      additionalData: additionalData,
    );
    _persistError(record);
  }

  /// Wrap an operation with error handling
  static Future<T?> withErrorHandling<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? operationName,
    ErrorType? expectedErrorType,
    VoidCallback? onRetry,
    bool showDialog = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(
        error,
        stackTrace: stackTrace,
        context: operationName,
      );

      if (showDialog && context.mounted) {
        await handleError(
          context,
          error,
          errorType: expectedErrorType,
          onRetry: onRetry,
        );
      }

      return null;
    }
  }

  /// Show warning dialog (non-critical issues)
  static Future<bool> showWarning(
    BuildContext context,
    String message, {
    String title = 'Warning',
    String? continueLabel,
    List<String>? suggestions,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (suggestions != null && suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Suggestions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              ...suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text('• $s', style: const TextStyle(fontSize: 12)),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(continueLabel ?? 'Continue'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Show info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
      ),
    );
  }
}
