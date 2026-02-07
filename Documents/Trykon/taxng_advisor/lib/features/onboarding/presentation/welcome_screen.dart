import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Welcome screen shown on first app launch with animated falling bubbles
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Create bubbles
    for (int i = 0; i < 20; i++) {
      _bubbles.add(Bubble());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green[700]!,
                  Colors.green[900]!,
                ],
              ),
            ),
          ),

          // Animated falling bubbles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(_bubbles, _controller.value),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              // App icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Version display
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'v3.0.0 (Build 38)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Tagline
                              const Text(
                                'Your Padi for Nigerian Tax Matters',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Striking statement
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.verified_outlined,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Navigate Nigeria\'s Tax Act 2025 with Confidence',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Calculate taxes accurately • Generate records • Stay compliant with ease',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Key features
                              _buildFeature(
                                  Icons.calculate, 'Instant Tax Calculations'),
                              const SizedBox(height: 10),
                              _buildFeature(Icons.receipt_long,
                                  'Payment Link Generation'),
                              const SizedBox(height: 10),
                              _buildFeature(
                                  Icons.security, '100% Secure & Private'),
                            ],
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              // Continue button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green[800],
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Register button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                      arguments: {'register': true},
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Debug - Seed button (only in debug mode)
                              if (kDebugMode) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/debug/users');
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                    ),
                                    child: const Text(
                                      'Debug - Seed / Login Users',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),

                              // Fine print
                              Text(
                                'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ), // Closing SafeArea
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Bubble data model
class Bubble {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;

  Bubble() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 20 + random.nextDouble() * 60;
    speed = 0.3 + random.nextDouble() * 0.7;
    opacity = 0.1 + random.nextDouble() * 0.3;
  }
}

// Custom painter for bubbles
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animation;

  BubblePainter(this.bubbles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      // Calculate position
      double yPos = (bubble.y + (animation * bubble.speed)) % 1.2;
      if (yPos > 1.0) {
        yPos = yPos - 1.2;
      }

      final paint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(
        bubble.x * size.width,
        yPos * size.height,
      );

      // Draw bubble
      canvas.drawCircle(position, bubble.size, paint);

      // Draw bubble highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        position.translate(-bubble.size * 0.3, -bubble.size * 0.3),
        bubble.size * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}
