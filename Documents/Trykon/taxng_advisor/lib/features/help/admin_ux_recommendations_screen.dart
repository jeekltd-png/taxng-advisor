import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Admin-only screen for UX recommendations and improvements
class AdminUxRecommendationsScreen extends StatefulWidget {
  const AdminUxRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminUxRecommendationsScreen> createState() =>
      _AdminUxRecommendationsScreenState();
}

class _AdminUxRecommendationsScreenState
    extends State<AdminUxRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = await AuthService.currentUser();
    if (user == null || !user.isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin access required'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UX Recommendations'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildImplementedSection(),
          const SizedBox(height: 24),
          _buildQuickWinsSection(),
          const SizedBox(height: 24),
          _buildHighPrioritySection(),
          const SizedBox(height: 24),
          _buildMediumPrioritySection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.deepPurple[700], size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'User Experience Recommendations',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Comprehensive analysis and recommendations to make TaxPadi more user-friendly. Features are categorized by implementation complexity and user impact.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementedSection() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  '✅ Recently Implemented',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '1. Interactive App Tour / Onboarding',
              'First-time user walkthrough with skip option',
              Colors.green,
            ),
            _buildFeatureItem(
              '2. Dashboard Quick Actions',
              'Quick access buttons for common tasks',
              Colors.green,
            ),
            _buildFeatureItem(
              '3. Calculation History Search/Filter',
              'Advanced filtering and search capabilities',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickWinsSection() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  '⚡ Quick Wins (2-6 hours each)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '4. Dark Mode Support',
              'Add dark theme with automatic switching (4-6 hours)',
              Colors.orange,
            ),
            _buildFeatureItem(
              '5. Number Pad with ₦ Symbol',
              'Custom numeric keyboard (2-3 hours)',
              Colors.orange,
            ),
            _buildFeatureItem(
              '6. Progress Indicators',
              'Visual feedback for uploads/PDF generation (2-3 hours)',
              Colors.orange,
            ),
            _buildFeatureItem(
              '7. Offline Mode Indicator',
              'Show connection status clearly (1-2 hours)',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighPrioritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.red[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  '🎯 High Priority (High User Impact)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '8. Smart Reminders with Push Notifications',
              'Notifications 7, 3, 1 day before tax deadlines',
              Colors.blue,
            ),
            _buildFeatureItem(
              '9. Results Visual Breakdown',
              'Charts, comparisons, tax savings tips',
              Colors.blue,
            ),
            _buildFeatureItem(
              '10. Smart Input Validation',
              'Real-time validation with suggestions',
              Colors.blue,
            ),
            _buildFeatureItem(
              '11. Recent Calculations Widget',
              'Show 3 most recent on dashboard',
              Colors.blue,
            ),
            _buildFeatureItem(
              '12. Calculation Comparison Mode',
              'Side-by-side scenario comparison',
              Colors.blue,
            ),
            _buildFeatureItem(
              '13. Contextual Help Tooltips',
              'Video tutorials and context-aware help',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumPrioritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_half, color: Colors.purple[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  '📊 Medium Priority (Nice to Have)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '14. Accessibility Features',
              'Larger text, screen reader, high contrast',
              Colors.purple,
            ),
            _buildFeatureItem(
              '15. Performance Analytics',
              'Tax trends, year-over-year comparisons',
              Colors.purple,
            ),
            _buildFeatureItem(
              '16. Multi-Language Support',
              'English, Pidgin, Yoruba, Igbo, Hausa',
              Colors.purple,
            ),
            _buildFeatureItem(
              '17. Guided Tax Filing Wizard',
              'Step-by-step question mode',
              Colors.purple,
            ),
            _buildFeatureItem(
              '18. Smart Data Entry',
              'Remember values, import from photo (OCR)',
              Colors.purple,
            ),
            _buildFeatureItem(
              '19. Social Features',
              'Share templates, community tips (optional)',
              Colors.purple,
            ),
            _buildFeatureItem(
              '20. Enhanced Settings',
              'Personalization options, defaults, preferences',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
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
