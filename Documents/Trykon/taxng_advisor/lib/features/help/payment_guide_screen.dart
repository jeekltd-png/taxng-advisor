import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Payment Guide Screen - For users to learn about tax payment features
class PaymentGuideScreen extends StatefulWidget {
  final bool isAdmin;

  const PaymentGuideScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<PaymentGuideScreen> createState() => _PaymentGuideScreenState();
}

class _PaymentGuideScreenState extends State<PaymentGuideScreen> {
  late Future<String> _markdownFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _checkAdminAccess();
    }
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
        .loadString('docs/PAYMENT_INTEGRATION_GUIDE.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isAdmin ? 'Admin: Payment Guide' : 'Tax Payment Guide'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
