import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adminDocsProvider = StateNotifierProvider<AdminDocsNotifier, List<AdminDoc>>(
  (ref) => AdminDocsNotifier(),
);

class AdminDoc {
  final String id;
  final String title;
  final String content;

  AdminDoc({required this.id, required this.title, required this.content});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'content': content};

  factory AdminDoc.fromJson(Map<String, dynamic> json) => AdminDoc(id: json['id'], title: json['title'], content: json['content']);
}

class AdminDocsNotifier extends StateNotifier<List<AdminDoc>> {
  static const _key = 'admin_docs';
  AdminDocsNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) {
      state = [];
      return;
    }
    final arr = json.decode(raw) as List<dynamic>;
    state = arr.map((e) => AdminDoc.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addDoc(AdminDoc d) async {
    state = [d, ...state];
    await _save();
  }

  Future<void> removeDoc(String id) async {
    state = state.where((d) => d.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final raw = json.encode(state.map((d) => d.toJson()).toList());
    await sp.setString(_key, raw);
  }
}
