import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String _markdown = '';
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final text = await rootBundle.loadString('docs/TERMS_OF_SERVICE.md');
      setState(() {
        _markdown = text;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load terms of service. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Terms of Service'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Markdown(
                  data: _markdown,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
    );
  }
}
