import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated splash screen with TaxPadi logo animation
/// - "Tax" slides from top
/// - "Padi" slides from bottom
/// - Green squares converge from all sides
/// - Logo zooms in/out
/// - Bubbles fall like water drops
/// - Slogan appears
/// - Tap/click to continue
class SplashAnimationScreen extends StatefulWidget {
  const SplashAnimationScreen({Key? key}) : super(key: key);

  @override
  State<SplashAnimationScreen> createState() => _SplashAnimationScreenState();
}

class _SplashAnimationScreenState extends State<SplashAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _taxController;
  late AnimationController _padiController;
  late AnimationController _squaresController;
  late AnimationController _zoomController;
  late AnimationController _bubblesController;
  late AnimationController _sloganController;

  late Animation<Offset> _taxSlide;
  late Animation<Offset> _padiSlide;
  late Animation<double> _squaresAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _bubblesAnimation;
  late Animation<double> _sloganFade;

  bool _showContinue = false;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();

    // Tax text animation (from top)
    _taxController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _taxSlide = Tween<Offset>(
      begin: const Offset(0, -3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _taxController,
      curve: Curves.elasticOut,
    ));

    // Padi text animation (from bottom)
    _padiController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _padiSlide = Tween<Offset>(
      begin: const Offset(0, 3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _padiController,
      curve: Curves.elasticOut,
    ));

    // Green squares converging
    _squaresController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _squaresAnimation = CurvedAnimation(
      parent: _squaresController,
      curve: Curves.easeInOut,
    );

    // Zoom in/out animation
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _zoomAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_zoomController);

    // Bubbles falling animation
    _bubblesController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _bubblesAnimation = CurvedAnimation(
      parent: _bubblesController,
      curve: Curves.linear,
    );

    // Slogan fade in
    _sloganController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sloganFade = CurvedAnimation(
      parent: _sloganController,
      curve: Curves.easeIn,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Generate random bubbles
    _generateBubbles();

    // Start Tax animation
    await Future.delayed(const Duration(milliseconds: 300));
    _taxController.forward();

    // Start Padi animation (slightly delayed)
    await Future.delayed(const Duration(milliseconds: 200));
    _padiController.forward();

    // Start squares converging
    await Future.delayed(const Duration(milliseconds: 400));
    _squaresController.forward();

    // Wait for convergence
    await Future.delayed(const Duration(milliseconds: 800));

    // Zoom in/out
    _zoomController.forward();

    // Start bubbles falling
    await Future.delayed(const Duration(milliseconds: 500));
    _bubblesController.forward();

    // Show slogan
    await Future.delayed(const Duration(milliseconds: 800));
    _sloganController.forward();

    // Show continue button
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _showContinue = true;
      });
    }
  }

  void _generateBubbles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _bubbles.add(Bubble(
        x: random.nextDouble(),
        delay: random.nextDouble() * 0.5,
        size: 10 + random.nextDouble() * 20,
        speed: 0.5 + random.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _taxController.dispose();
    _padiController.dispose();
    _squaresController.dispose();
    _zoomController.dispose();
    _bubblesController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _showContinue ? _continue : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background squares converging
            AnimatedBuilder(
              animation: _squaresAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: SquaresPainter(_squaresAnimation.value),
                );
              },
            ),

            // Main content centered
            Center(
              child: AnimatedBuilder(
                animation: _zoomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _zoomAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo container
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Green square background
                              Center(
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.green[600]!,
                                        Colors.green[800]!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              // Icon
                              Center(
                                child: Image.asset(
                                  'assets/icon.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tax & Padi text
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tax (from top)
                            SlideTransition(
                              position: _taxSlide,
                              child: Text(
                                'Tax',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            // Padi (from bottom)
                            SlideTransition(
                              position: _padiSlide,
                              child: Text(
                                'Padi',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bubbles falling
            AnimatedBuilder(
              animation: _bubblesAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: BubblesPainter(
                    _bubblesAnimation.value,
                    _bubbles,
                  ),
                );
              },
            ),

            // Slogan at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 150,
              child: FadeTransition(
                opacity: _sloganFade,
                child: Text(
                  'Your Padi for Nigerian Tax Matters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Continue button/hint
            if (_showContinue)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                child: AnimatedOpacity(
                  opacity: _showContinue ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.green[700],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Painter for converging green squares from all sides
class SquaresPainter extends CustomPainter {
  final double progress;

  SquaresPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final squareSize = 30.0;

    // Calculate positions based on progress (1.0 = fully converged)
    final distance = (1 - progress) * math.max(size.width, size.height) / 2;

    // Squares from top
    for (int i = 0; i < 5; i++) {
      final x = centerX + (i - 2) * 60;
      final y = centerY - distance;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x - squareSize / 2, y - squareSize / 2, squareSize, squareSize),
          const Radius.circular(8),
        ),
        paint,
      );
    }

    // Squares from bottom
    for (int i = 0; i < 5; i++) {
      final x = centerX + (i - 2) * 60;
      final y = centerY + distance;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x - squareSize / 2, y - squareSize / 2, squareSize, squareSize),
          const Radius.circular(8),
        ),
        paint,
      );
    }

    // Squares from left
    for (int i = 0; i < 5; i++) {
      final x = centerX - distance;
      final y = centerY + (i - 2) * 60;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x - squareSize / 2, y - squareSize / 2, squareSize, squareSize),
          const Radius.circular(8),
        ),
        paint,
      );
    }

    // Squares from right
    for (int i = 0; i < 5; i++) {
      final x = centerX + distance;
      final y = centerY + (i - 2) * 60;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x - squareSize / 2, y - squareSize / 2, squareSize, squareSize),
          const Radius.circular(8),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SquaresPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Painter for falling bubbles
class BubblesPainter extends CustomPainter {
  final double progress;
  final List<Bubble> bubbles;

  BubblesPainter(this.progress, this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final adjustedProgress =
          ((progress - bubble.delay).clamp(0.0, 1.0) * bubble.speed);
      if (adjustedProgress <= 0) continue;

      final x = bubble.x * size.width;
      final y = adjustedProgress * size.height;

      final paint = Paint()
        ..color = Colors.green.withOpacity(0.3 - (adjustedProgress * 0.2))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        bubble.size * (1 - adjustedProgress * 0.5),
        paint,
      );

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.5 - (adjustedProgress * 0.3))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x - bubble.size * 0.2, y - bubble.size * 0.2),
        bubble.size * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Bubble data class
class Bubble {
  final double x; // Normalized position (0-1)
  final double delay; // Delay before starting (0-1)
  final double size; // Bubble size
  final double speed; // Fall speed multiplier

  Bubble({
    required this.x,
    required this.delay,
    required this.size,
    required this.speed,
  });
}
