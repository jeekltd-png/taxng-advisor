import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/hive_service.dart';

/// Interactive app tour for first-time users
class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to TaxPadi!',
      'bullets': [
        'The Multi Tax professional-grade Tool to calculate, document, and communicate Nigerian Tax',
      ],
      'icon': Icons.waving_hand,
      'color': Colors.green,
      'useLogo': true,
    },
    {
      'title': 'Smart Tax Calculators',
      'bullets': [
        {'text': 'Companies Income Tax (CIT)', 'icon': Icons.business},
        {'text': 'Value Added Tax (VAT)', 'icon': Icons.receipt_long},
        {'text': 'Personal Income Tax (PIT)', 'icon': Icons.person_outline},
        {'text': 'Withholding Tax (WHT)', 'icon': Icons.account_balance},
        {'text': 'Pay As You Earn (PAYE)', 'icon': Icons.payments_outlined},
        {'text': 'Stamp Duty', 'icon': Icons.verified_outlined},
      ],
      'icon': Icons.calculate_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Evidence & Documentation',
      'bullets': [
        'Add notes and attachments to every calculation',
        'Generate professional PDFs with QR codes',
        'Verification and audit trails included',
      ],
      'icon': Icons.description_outlined,
      'color': Colors.purple,
    },
    {
      'title': 'Templates Save Time',
      'bullets': [
        'Save recurring calculations as templates',
        'Reuse them anytime with one tap',
        'Perfect for monthly VAT, payroll, or regular expenses',
      ],
      'icon': Icons.bookmark_outline,
      'color': Colors.orange,
    },
    {
      'title': 'Import & Export Data',
      'bullets': [
        'Import from CSV/JSON files to auto-fill calculators',
        'Export records for further use',
      ],
      'icon': Icons.import_export,
      'color': Colors.indigo,
    },
    {
      'title': 'Comprehensive Help',
      'bullets': [
        'Access our detailed User Manual',
        'Quick guides and sample data available',
        'Get help whenever you need it, right from the app',
      ],
      'icon': Icons.menu_book_outlined,
      'color': Colors.cyan,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markTourAsCompleted() async {
    try {
      final box = HiveService.getProfileBox();
      await box.put('tour_completed', true);
    } catch (e) {
      debugPrint('Error marking tour as completed: $e');
    }
  }

  void _skip() async {
    await _markTourAsCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }

  void _previous() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back and Skip buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previous,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Previous',
                    )
                  else
                    const SizedBox(width: 48),
                  // Skip button
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final hasBullets = page.containsKey('bullets');
                  final bullets = page['bullets'] as List?;
                  final isSecondScreen = index == 1; // Tax calculators screen

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon or Logo - centered at top
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    (page['color'] as Color).withOpacity(0.3),
                                    (page['color'] as Color).withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (page['color'] as Color)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: page['useLogo'] == true
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.asset(
                                        'assets/icon.png',
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.waving_hand,
                                            size: 50,
                                            color: page['color'] as Color,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      page['icon'] as IconData,
                                      size: 50,
                                      color: page['color'] as Color,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            page['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: page['color'] as Color,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Bullet points below - center aligned
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: hasBullets && bullets != null
                                ? isSecondScreen
                                    ? Center(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 600),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left column - first 3 items
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: bullets
                                                      .take(3)
                                                      .map<Widget>((bullet) {
                                                    if (bullet is Map<String,
                                                        dynamic>) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 6),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              bullet['icon']
                                                                  as IconData,
                                                              size: 20,
                                                              color:
                                                                  page['color']
                                                                      as Color,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                bullet['text']
                                                                    as String,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                  height: 1.4,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox
                                                        .shrink();
                                                  }).toList(),
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                              // Right column - remaining items
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: bullets
                                                      .skip(3)
                                                      .map<Widget>((bullet) {
                                                    if (bullet is Map<String,
                                                        dynamic>) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 6),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              bullet['icon']
                                                                  as IconData,
                                                              size: 20,
                                                              color:
                                                                  page['color']
                                                                      as Color,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                bullet['text']
                                                                    as String,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                  height: 1.4,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox
                                                        .shrink();
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: bullets.map<Widget>((bullet) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6),
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: page['color']
                                                          as Color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Text(
                                                    bullet is String
                                                        ? bullet
                                                        : bullet['text']
                                                            as String,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      )
                                : Text(
                                    page['description'] as String? ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      height: 1.6,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: _currentPage == index
                        ? LinearGradient(
                            colors: [
                              Colors.green,
                              Colors.green[700]!,
                            ],
                          )
                        : null,
                    color: _currentPage == index ? null : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage == _pages.length - 1
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
