import 'package:flutter/material.dart';

/// Card for displaying summary values
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const SummaryCard(
      {super.key, required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: valueColor)),
          ],
        ),
      ),
    );
  }
}
