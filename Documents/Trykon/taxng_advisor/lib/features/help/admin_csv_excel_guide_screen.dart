import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Admin-only screen: CSV & Excel Import Guide
class AdminCsvExcelGuideScreen extends StatefulWidget {
  const AdminCsvExcelGuideScreen({Key? key}) : super(key: key);

  @override
  State<AdminCsvExcelGuideScreen> createState() =>
      _AdminCsvExcelGuideScreenState();
}

class _AdminCsvExcelGuideScreenState extends State<AdminCsvExcelGuideScreen> {
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
        .loadString('docs/CSV_EXCEL_IMPORT_GUIDE.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: CSV & Excel Import Guide'),
        backgroundColor: Colors.deepPurple,
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
