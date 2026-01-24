import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpay/providers/auth_provider.dart';

final adminDocsStreamProvider = StreamProvider<List<AdminDoc>>((ref) {
  final col = FirebaseFirestore.instance.collection('admin_docs').orderBy('createdAt', descending: true);
  return col.snapshots().map((snap) => snap.docs.map((d) => AdminDoc.fromFirestore(d)).toList());
});

final adminDocsActionsProvider = Provider((ref) => AdminDocsActions(ref));

class AdminDoc {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? createdBy;

  AdminDoc({required this.id, required this.title, required this.content, required this.createdAt, this.createdBy});

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'content': content,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'createdBy': createdBy,
      };

  factory AdminDoc.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    return AdminDoc(
      id: d.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }
}

class AdminDocsActions {
  final Ref _ref;
  AdminDocsActions(this._ref);

  Future<void> addDoc({required String title, required String content}) async {
    final isAdmin = await _ref.read(isAdminProvider.future);
    if (!isAdmin) throw Exception('Not authorized');

    await FirebaseFirestore.instance.collection('admin_docs').add({
      'title': title,
      'content': content,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'createdBy': _ref.read(authProvider)?.uid,
    });
  }

  Future<void> removeDoc(String id) async {
    final isAdmin = await _ref.read(isAdminProvider.future);
    if (!isAdmin) throw Exception('Not authorized');
    await FirebaseFirestore.instance.collection('admin_docs').doc(id).delete();
  }
}
