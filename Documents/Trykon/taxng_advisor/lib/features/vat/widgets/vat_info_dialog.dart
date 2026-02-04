import 'package:flutter/material.dart';

/// A standardized info dialog for VAT field explanations
class VatInfoDialog extends StatelessWidget {
  final String title;
  final String whatItMeans;
  final String example;
  final String? howCalculated;
  final String? keyBenefit;
  final String? important;
  final String? howUsed;

  const VatInfoDialog({
    super.key,
    required this.title,
    required this.whatItMeans,
    required this.example,
    this.howCalculated,
    this.keyBenefit,
    this.important,
    this.howUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What it means:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(whatItMeans),
        const SizedBox(height: 16),
        const Text(
          'Example:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(example),
        if (howCalculated != null) ...[
          const SizedBox(height: 16),
          const Text(
            'How it\'s used:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(howCalculated!),
        ],
        if (keyBenefit != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Key benefit:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(keyBenefit!),
        ],
        if (important != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Important:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(important!),
        ],
        if (howUsed != null) ...[
          const SizedBox(height: 16),
          const Text(
            'How it\'s used:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(howUsed!),
        ],
      ],
    );
  }
}
