import 'package:flutter/material.dart';

/// Standalone tour guide page accessible from Help menu
class TourGuideScreen extends StatefulWidget {
  const TourGuideScreen({Key? key}) : super(key: key);

  @override
  State<TourGuideScreen> createState() => _TourGuideScreenState();
}

class _TourGuideScreenState extends State<TourGuideScreen> {
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

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('App Tour Guide'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                          horizontal: 32, vertical: 24),
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
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: page['useLogo'] == true
                                    ? ClipOval(
                                        child: Image.asset(
                                          'assets/icon.png',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        page['icon'] as IconData,
                                        size: 48,
                                        color: page['color'] as Color,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Title
                          Text(
                            page['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Bullets
                          if (hasBullets && bullets != null)
                            ...bullets.map((bullet) {
                              if (bullet is Map) {
                                // Structured bullet for calculators
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSecondScreen
                                              ? (page['color'] as Color)
                                                  .withOpacity(0.1)
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSecondScreen
                                                ? (page['color'] as Color)
                                                    .withOpacity(0.3)
                                                : Colors.grey[300]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          bullet['icon'] as IconData,
                                          color: page['color'] as Color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          bullet['text'] as String,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Simple string bullet
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: page['color'] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          bullet as String,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.green[700]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _previous,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 100),

                  // Next/Done button
                  ElevatedButton.icon(
                    onPressed: _next,
                    icon: Icon(
                      _currentPage == _pages.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      _currentPage == _pages.length - 1 ? 'Done' : 'Next',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
