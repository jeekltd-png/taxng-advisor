import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Admin-only screen: User Testing Guide
class AdminUserTestingGuideScreen extends StatefulWidget {
  const AdminUserTestingGuideScreen({super.key});

  @override
  State<AdminUserTestingGuideScreen> createState() =>
      _AdminUserTestingGuideScreenState();
}

class _AdminUserTestingGuideScreenState
    extends State<AdminUserTestingGuideScreen> {
  late Future<String> _markdownFuture;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _markdownFuture = _loadMarkdown();
  }

  Future<void> _checkAdminAccess() async {
    final user = await AuthService.currentUser();
    if (user == null || !user.isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Admin access required'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String> _loadMarkdown() async {
    return await DefaultAssetBundle.of(context)
        .loadString('docs/USER_TESTING_GUIDE.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: User Testing Guide'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TaxNGColors.primaryDark, TaxNGColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<String>(
        future: _markdownFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading guide: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No content available'));
          }
          return Markdown(
            data: snapshot.data!,
            selectable: true,
          );
        },
      ),
    );
  }
}
