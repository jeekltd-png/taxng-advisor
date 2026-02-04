import 'package:flutter/material.dart';

/// Shows a progress indicator during calculations
class CalculationProgressOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String message = 'Calculating...'}) {
    if (_overlayEntry != null) return; // Already showing

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Animated progress indicator widget
class AnimatedCalculationProgress extends StatefulWidget {
  final String message;

  const AnimatedCalculationProgress({
    super.key,
    this.message = 'Calculating...',
  });

  @override
  State<AnimatedCalculationProgress> createState() =>
      _AnimatedCalculationProgressState();
}

class _AnimatedCalculationProgressState
    extends State<AnimatedCalculationProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[900],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: _animation.value,
                      backgroundColor: Colors.green[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple inline progress indicator
class InlineProgressIndicator extends StatelessWidget {
  final String message;

  const InlineProgressIndicator({
    super.key,
    this.message = 'Processing...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
