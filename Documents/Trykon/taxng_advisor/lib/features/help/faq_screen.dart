import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  late Future<List<Map<String, String>>> _faqsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _faqsFuture = _loadFaqs();
  }

  Future<List<Map<String, String>>> _loadFaqs() async {
    final raw = await rootBundle.loadString('assets/help/faq.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) {
      return {
        'q': (e['q'] ?? '').toString(),
        'a': (e['a'] ?? '').toString(),
      };
    }).toList();
  }

  List<Map<String, String>> _filter(List<Map<String, String>> items) {
    if (_query.trim().isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((m) {
      return m['q']!.toLowerCase().contains(q) ||
          m['a']!.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search FAQs',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _faqsFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                      child:
                          Text('Failed to load help content: ${snap.error}'));
                }

                final items = _filter(snap.data ?? []);
                if (items.isEmpty) {
                  return const Center(
                      child: Text('No FAQs match your search.'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    return ExpansionTile(
                      title: Text(it['q'] ?? ''),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(it['a'] ?? ''),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
