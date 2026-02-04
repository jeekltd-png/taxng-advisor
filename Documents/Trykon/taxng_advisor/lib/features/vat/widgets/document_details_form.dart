import 'package:flutter/material.dart';

/// A reusable form for collecting document details for file uploads
class DocumentDetailsForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const DocumentDetailsForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<DocumentDetailsForm> createState() => _DocumentDetailsFormState();
}

class _DocumentDetailsFormState extends State<DocumentDetailsForm> {
  final _periodController = TextEditingController(text: 'Q1');
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _vatAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _periodController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _vatAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit({
      'period': _periodController.text,
      'year': int.tryParse(_yearController.text) ?? DateTime.now().year,
      'description': _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      'amount': double.tryParse(_amountController.text),
      'vatAmount': double.tryParse(_vatAmountController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _periodController,
          decoration: const InputDecoration(labelText: 'VAT Period *'),
        ),
        TextField(
          controller: _yearController,
          decoration: const InputDecoration(labelText: 'Year *'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description (optional)'),
        ),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Amount (optional)'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _vatAmountController,
          decoration: const InputDecoration(labelText: 'VAT Amount (optional)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Select File'),
            ),
          ],
        ),
      ],
    );
  }
}
