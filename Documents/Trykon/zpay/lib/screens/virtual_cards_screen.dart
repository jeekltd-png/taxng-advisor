import 'package:flutter/material.dart';

class VirtualCardsScreen extends StatelessWidget {
  const VirtualCardsScreen({Key? key}) : super(key: key);
  static const routeName = '/virtual-cards';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Cards')),
      body: const Center(child: Text('Virtual cards screen (to be implemented)')),
    );
  }
}
