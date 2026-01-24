import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpay/providers/auth_provider.dart';
import 'package:zpay/providers/admin_firestore_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({Key? key}) : super(key: key);
  static const routeName = '/admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    final docsAsync = ref.watch(adminDocsStreamProvider);

    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin')),
            body: Center(
                child: Text('Access denied. Admins only.',
                    style: Theme.of(context).textTheme.titleMedium)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Admin - Documents')),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add document')),
                const SizedBox(height: 12),
                Expanded(
                  child: docsAsync.when(
                    data: (docs) => docs.isEmpty
                        ? const Center(child: Text('No documents yet'))
                        : ListView.separated(
                            itemBuilder: (ctx, i) {
                              final d = docs[i];
                              return ListTile(
                                title: Text(d.title),
                                subtitle: Text(d.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                trailing: IconButton(
                                    icon: const Icon(Icons.delete_forever),
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(adminDocsActionsProvider)
                                            .removeDoc(d.id);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text('Delete failed: $e')));
                                      }
                                    }),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: docs.length,
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, st) =>
                        Center(child: Text('Error loading docs: $err')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(
          body: Center(child: Text('Error checking admin status: $err'))),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Add document'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: contentCtrl,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 4),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(adminDocsActionsProvider).addDoc(
                          title: titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                        );
                    Navigator.of(ctx).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Save failed: $e')));
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        });
  }
}
