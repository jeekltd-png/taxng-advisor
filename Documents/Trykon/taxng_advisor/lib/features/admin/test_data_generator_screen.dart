import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/user_activity_tracker.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'dart:math';

/// Performance Test Data Generator
///
/// Generates sample user activities for testing the activity tracker dashboard
class PerformanceTestDataGenerator {
  static final _random = Random();

  static final _calculatorTypes = [
    'vat',
    'pit',
    'cit',
    'wht',
    'payroll',
    'stamp_duty',
  ];

  static final _feedbackMessages = [
    'Great app, very helpful!',
    'Easy to use calculator',
    'Would like more features',
    'Excellent for tax calculations',
    'Could improve the UI',
    'Very accurate results',
    'Love the reminders feature',
    'Needs better documentation',
    'Perfect for my business',
    'Simple and effective',
  ];

  /// Generate test activities
  static Future<void> generateTestData({
    int downloadCount = 50,
    int loginCount = 200,
    int logoutCount = 180,
    int calculatorUseCount = 500,
    int feedbackCount = 30,
    int ratingCount = 40,
  }) async {
    debugPrint('🔄 Starting test data generation...');

    try {
      // Initialize tracker if needed
      await UserActivityTracker.initialize();

      final user = await AuthService.currentUser();
      if (user == null) {
        debugPrint('❌ No user logged in. Please log in first.');
        return;
      }

      int totalActivities = downloadCount +
          loginCount +
          logoutCount +
          calculatorUseCount +
          feedbackCount +
          ratingCount;
      int progress = 0;

      // Generate downloads
      for (int i = 0; i < downloadCount; i++) {
        await UserActivityTracker.trackAppDownload();
        progress++;
        if (progress % 50 == 0) {
          debugPrint('Progress: $progress/$totalActivities');
        }
      }
      debugPrint('✅ Generated $downloadCount downloads');

      // Generate logins
      for (int i = 0; i < loginCount; i++) {
        await UserActivityTracker.trackLogin(
            user.id, user.username, user.email);
        progress++;
        if (progress % 50 == 0) {
          debugPrint('Progress: $progress/$totalActivities');
        }
      }
      debugPrint('✅ Generated $loginCount logins');

      // Generate logouts
      for (int i = 0; i < logoutCount; i++) {
        await UserActivityTracker.trackLogout();
        progress++;
        if (progress % 50 == 0) {
          debugPrint('Progress: $progress/$totalActivities');
        }
      }
      debugPrint('✅ Generated $logoutCount logouts');

      // Generate calculator uses
      for (int i = 0; i < calculatorUseCount; i++) {
        final calcType =
            _calculatorTypes[_random.nextInt(_calculatorTypes.length)];
        await UserActivityTracker.trackCalculatorUse(calcType);
        progress++;
        if (progress % 50 == 0) {
          debugPrint('Progress: $progress/$totalActivities');
        }
      }
      debugPrint('✅ Generated $calculatorUseCount calculator uses');

      // Generate feedback
      for (int i = 0; i < feedbackCount; i++) {
        final message =
            _feedbackMessages[_random.nextInt(_feedbackMessages.length)];
        await UserActivityTracker.trackFeedback(message);
        progress++;
        if (progress % 50 == 0) {
          debugPrint('Progress: $progress/$totalActivities');
        }
      }
      debugPrint('✅ Generated $feedbackCount feedback submissions');

      // Generate ratings
      for (int i = 0; i < ratingCount; i++) {
        // Weight ratings towards higher scores (realistic)
        final rating = _random.nextInt(10) < 7
            ? 4 + _random.nextInt(2) // 70% chance of 4-5 stars
            : 1 + _random.nextInt(4); // 30% chance of 1-4 stars
        await UserActivityTracker.trackRating(rating);
        progress++;
        if (progress % 50 == 0) {
          debugPrint('Progress: $progress/$totalActivities');
        }
      }
      debugPrint('✅ Generated $ratingCount ratings');

      debugPrint('🎉 Test data generation complete!');
      debugPrint('Total activities created: $totalActivities');
    } catch (e) {
      debugPrint('❌ Error generating test data: $e');
    }
  }

  /// Generate a smaller set for quick testing
  static Future<void> generateQuickTestData() async {
    await generateTestData(
      downloadCount: 10,
      loginCount: 20,
      logoutCount: 15,
      calculatorUseCount: 50,
      feedbackCount: 5,
      ratingCount: 8,
    );
  }

  /// Generate a large set for performance testing
  static Future<void> generateLargeTestData() async {
    await generateTestData(
      downloadCount: 100,
      loginCount: 500,
      logoutCount: 450,
      calculatorUseCount: 2000,
      feedbackCount: 80,
      ratingCount: 150,
    );
  }

  /// Clear all test data
  static Future<void> clearAllData() async {
    try {
      await UserActivityTracker.initialize();

      final activities = await UserActivityTracker.getAllActivities();
      debugPrint('Clearing ${activities.length} activities...');

      // TODO: Implement clear method in UserActivityTracker
      // For now, just show info
      debugPrint('⚠️ Clear method not implemented yet');
      debugPrint('Total activities: ${activities.length}');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }
}

/// Widget to show test data generation UI
class TestDataGeneratorScreen extends StatefulWidget {
  const TestDataGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<TestDataGeneratorScreen> createState() =>
      _TestDataGeneratorScreenState();
}

class _TestDataGeneratorScreenState extends State<TestDataGeneratorScreen> {
  bool _isGenerating = false;

  Future<void> _generateQuickData() async {
    setState(() => _isGenerating = true);
    await PerformanceTestDataGenerator.generateQuickTestData();
    setState(() => _isGenerating = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quick test data generated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _generateLargeData() async {
    setState(() => _isGenerating = true);
    await PerformanceTestDataGenerator.generateLargeTestData();
    setState(() => _isGenerating = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Large test data generated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Data Generator'),
        backgroundColor: Colors.deepPurple[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Performance Test Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Generate sample user activities to test the activity tracker dashboard performance.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isGenerating)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating test data...'),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _generateQuickData,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Quick Test (108 activities)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _generateLargeData,
                    icon: const Icon(Icons.data_usage),
                    label: const Text('Large Test (3,280 activities)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'After generating data, go to:\nAdmin > User Activity Tracker',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
