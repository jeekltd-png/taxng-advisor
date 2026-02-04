import 'package:flutter/material.dart';

/// Overlay widget for showing progress during long operations
class ProgressOverlay extends StatelessWidget {
  final String message;
  final double? progress; // 0.0 to 1.0, null for indeterminate
  final bool showPercentage;

  const ProgressOverlay({
    Key? key,
    required this.message,
    this.progress,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress == null)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (progress != null && showPercentage) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(progress! * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show progress overlay
  static void show(
    BuildContext context, {
    required String message,
    double? progress,
    bool showPercentage = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressOverlay(
        message: message,
        progress: progress,
        showPercentage: showPercentage,
      ),
    );
  }

  /// Hide progress overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Mixin for adding progress tracking to widgets
mixin ProgressMixin<T extends StatefulWidget> on State<T> {
  bool _isShowingProgress = false;

  /// Show progress with message
  void showProgress(String message, {double? progress}) {
    if (!_isShowingProgress && mounted) {
      _isShowingProgress = true;
      ProgressOverlay.show(
        context,
        message: message,
        progress: progress,
      );
    }
  }

  /// Update progress
  void updateProgress(String message, {double? progress}) {
    if (_isShowingProgress && mounted) {
      Navigator.of(context).pop();
      showProgress(message, progress: progress);
    }
  }

  /// Hide progress
  void hideProgress() {
    if (_isShowingProgress && mounted) {
      _isShowingProgress = false;
      Navigator.of(context).pop();
    }
  }

  /// Run operation with progress
  Future<R> withProgress<R>({
    required String message,
    required Future<R> Function() operation,
    String? successMessage,
    String? errorMessage,
  }) async {
    showProgress(message);
    try {
      final result = await operation();
      hideProgress();
      
      if (successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      return result;
    } catch (e) {
      hideProgress();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      rethrow;
    }
  }
}

/// Linear progress indicator for lists and grids
class LinearProgressOverlay extends StatelessWidget {
  final String message;
  final double progress; // 0.0 to 1.0
  final int currentItem;
  final int totalItems;

  const LinearProgressOverlay({
    Key? key,
    required this.message,
    required this.progress,
    required this.currentItem,
    required this.totalItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$currentItem of $totalItems items',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact progress indicator for inline use
class CompactProgressIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const CompactProgressIndicator({
    Key? key,
    this.message,
    this.size = 20,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

/// Progress controller for managing progress state
class ProgressController extends ChangeNotifier {
  bool _isLoading = false;
  double _progress = 0.0;
  String _message = '';
  int _currentItem = 0;
  int _totalItems = 0;

  bool get isLoading => _isLoading;
  double get progress => _progress;
  String get message => _message;
  int get currentItem => _currentItem;
  int get totalItems => _totalItems;

  void start(String message, {int totalItems = 0}) {
    _isLoading = true;
    _message = message;
    _progress = 0.0;
    _currentItem = 0;
    _totalItems = totalItems;
    notifyListeners();
  }

  void update(String message, {double? progress, int? currentItem}) {
    _message = message;
    if (progress != null) _progress = progress;
    if (currentItem != null) {
      _currentItem = currentItem;
      if (_totalItems > 0) {
        _progress = currentItem / _totalItems;
      }
    }
    notifyListeners();
  }

  void complete() {
    _isLoading = false;
    _progress = 1.0;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _progress = 0.0;
    _message = '';
    _currentItem = 0;
    _totalItems = 0;
    notifyListeners();
  }
}
