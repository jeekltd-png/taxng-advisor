import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Onboarding carousel welcome screen with animated bubbles
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _versionString = '';

  static const _pages = [
    _OnboardingPage(
      emoji: '🇳🇬',
      title: 'TaxNG',
      subtitle: 'Your Padi for\nNigerian Tax Matters',
      description:
          'Navigate Nigeria\'s Tax Act 2025 with confidence — calculate, comply, conquer.',
      icon: Icons.verified_outlined,
    ),
    _OnboardingPage(
      emoji: '🧮',
      title: 'Instant Calculations',
      subtitle: 'VAT • PIT • CIT • WHT\nPayroll • Stamp Duty',
      description:
          'All Nigerian tax types at your fingertips. Get accurate results in seconds.',
      icon: Icons.calculate_rounded,
    ),
    _OnboardingPage(
      emoji: '📊',
      title: 'Smart Records',
      subtitle: 'Generate & Share\nTax Records',
      description:
          'Create professional tax records and share them with your accountant instantly.',
      icon: Icons.receipt_long_rounded,
    ),
    _OnboardingPage(
      emoji: '🔒',
      title: '100% Secure',
      subtitle: 'Your Data Stays\nPrivate & Protected',
      description:
          'Bank-level encryption. Your financial data never leaves your device.',
      icon: Icons.security_rounded,
    ),
  ];

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

    // Load version from package_info_plus
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _versionString = 'v${info.version} (Build ${info.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _versionString = '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF166534),
                  Color(0xFF16A34A),
                  Color(0xFF22C55E),
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
            child: Column(
              children: [
                // App icon + version at top
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _versionString,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Page view carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Emoji
                            Text(
                              page.emoji,
                              style: const TextStyle(fontSize: 52),
                            ),
                            const SizedBox(height: 16),
                            // Feature icon in glass card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Icon(
                                page.icon,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Subtitle
                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Description
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Page indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotColor: Colors.white.withValues(alpha: 0.3),
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip button (visible on non-last pages)
                      if (_currentPage < _pages.length - 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              (await SharedPreferences.getInstance())
                                  .setBool('onboarding_seen', true);
                              if (!context.mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 2),

                      // Continue / Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              (await SharedPreferences.getInstance())
                                  .setBool('onboarding_seen', true);
                              if (!context.mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF166534),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage < _pages.length - 1
                                ? 'Next'
                                : 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () async {
                            (await SharedPreferences.getInstance())
                                .setBool('onboarding_seen', true);
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              '/login',
                              arguments: {'register': true},
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                      // Debug - Seed button (only in debug mode)
                      if (kDebugMode) ...[
                        const SizedBox(height: 2),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/debug/users');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Debug - Seed / Login Users',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 2),

                      // Fine print with tappable links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By continuing, you agree to our ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/help/privacy-policy'),
                            child: Text(
                              'Terms',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.8),
                                height: 1.3,
                              ),
                            ),
                          ),
                          Text(
                            ' & ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/help/privacy-policy'),
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.8),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Onboarding page data model
class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
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
        ..color = Colors.white.withValues(alpha: bubble.opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(
        bubble.x * size.width,
        yPos * size.height,
      );

      // Draw bubble
      canvas.drawCircle(position, bubble.size, paint);

      // Draw bubble highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: bubble.opacity * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        position.translate(-bubble.size * 0.3, -bubble.size * 0.3),
        bubble.size * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
