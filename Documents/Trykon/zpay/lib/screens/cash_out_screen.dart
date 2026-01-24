import 'package:flutter/material.dart';

class CashOutScreen extends StatelessWidget {
  const CashOutScreen({Key? key}) : super(key: key);
  static const routeName = '/cash-out';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Out')),
      body: const Center(child: Text('Cash Out screen (to be implemented)')),
    );
  }
}
