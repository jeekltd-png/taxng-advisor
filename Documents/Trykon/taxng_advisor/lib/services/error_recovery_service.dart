import 'package:flutter/material.dart';
import 'dart:io';

/// Error types for categorization
enum ErrorType {
  network,
  storage,
  validation,
  fileSystem,
  calculation,
  unknown,
}

/// Error recovery service for graceful error handling
class ErrorRecoveryService {
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
                          error.toString(),
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
    if (error is SocketException || error.toString().contains('network')) {
      return ErrorType.network;
    } else if (error is FileSystemException ||
        error.toString().contains('file') ||
        error.toString().contains('permission')) {
      return ErrorType.fileSystem;
    } else if (error.toString().contains('storage') ||
        error.toString().contains('hive') ||
        error.toString().contains('box')) {
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

  /// Log error for debugging (console only, could be extended to file/analytics)
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    print('=== ERROR LOG ===');
    print('Context: ${context ?? 'Unknown'}');
    print('Error: $error');
    if (stackTrace != null) {
      print('Stack Trace:\n$stackTrace');
    }
    if (additionalData != null) {
      print('Additional Data: $additionalData');
    }
    print('=================');
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
