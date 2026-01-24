import 'package:flutter/material.dart';

class TransfersScreen extends StatelessWidget {
  const TransfersScreen({Key? key}) : super(key: key);
  static const routeName = '/transfers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfers')),
      body: const Center(child: Text('Transfers screen (to be implemented)')),
    );
  }
}
