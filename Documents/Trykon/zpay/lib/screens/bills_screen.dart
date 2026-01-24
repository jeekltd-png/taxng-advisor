import 'package:flutter/material.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({Key? key}) : super(key: key);
  static const routeName = '/bills';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills & Airtime')),
      body: const Center(child: Text('Bills screen (to be implemented)')),
    );
  }
}
