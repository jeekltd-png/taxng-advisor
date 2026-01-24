import 'package:flutter/material.dart';

class MerchantsScreen extends StatelessWidget {
  const MerchantsScreen({Key? key}) : super(key: key);
  static const routeName = '/merchants';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchants')),
      body: const Center(child: Text('Merchants screen (to be implemented)')),
    );
  }
}
