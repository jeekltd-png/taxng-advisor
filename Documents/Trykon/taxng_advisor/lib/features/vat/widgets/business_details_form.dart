import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// A reusable form for collecting business details for PDF generation
class BusinessDetailsForm extends StatefulWidget {
  final bool includeBank;
  final Function(Map<String, dynamic>) onSubmit;

  const BusinessDetailsForm({
    super.key,
    required this.onSubmit,
    this.includeBank = false,
  });

  @override
  State<BusinessDetailsForm> createState() => _BusinessDetailsFormState();
}

class _BusinessDetailsFormState extends State<BusinessDetailsForm> {
  final _businessNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();
  final _periodController = TextEditingController(text: 'Q1');
  final _yearController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _yearController.text = DateTime.now().year.toString();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.currentUser();
    if (user != null) {
      setState(() {
        _businessNameController.text = user.username;
        _contactPersonController.text = user.username;
        _emailController.text = user.email;
      });
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _tinController.dispose();
    _addressController.dispose();
    _periodController.dispose();
    _yearController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit({
      'businessName': _businessNameController.text,
      'tin': _tinController.text,
      'address': _addressController.text,
      'period': _periodController.text,
      'year': int.tryParse(_yearController.text) ?? DateTime.now().year,
      'contactPerson': _contactPersonController.text.isEmpty
          ? null
          : _contactPersonController.text,
      'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      if (widget.includeBank) ...{
        'bankName':
            _bankNameController.text.isEmpty ? null : _bankNameController.text,
        'bankAccountNumber': _bankAccountNumberController.text.isEmpty
            ? null
            : _bankAccountNumberController.text,
        'bankAccountName': _bankAccountNameController.text.isEmpty
            ? null
            : _bankAccountNameController.text,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _businessNameController,
          decoration: const InputDecoration(labelText: 'Business Name *'),
        ),
        TextField(
          controller: _tinController,
          decoration: const InputDecoration(labelText: 'TIN *'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: 'Business Address *'),
          maxLines: 2,
        ),
        TextField(
          controller: _periodController,
          decoration: const InputDecoration(
              labelText: 'VAT Period (e.g., Q1, January) *'),
        ),
        TextField(
          controller: _yearController,
          decoration: const InputDecoration(labelText: 'Year *'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _contactPersonController,
          decoration: const InputDecoration(labelText: 'Contact Person'),
        ),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        if (widget.includeBank) ...[
          const SizedBox(height: 16),
          const Text('Bank Details (for refund payment)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _bankNameController,
            decoration: const InputDecoration(labelText: 'Bank Name'),
          ),
          TextField(
            controller: _bankAccountNumberController,
            decoration: const InputDecoration(labelText: 'Account Number'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _bankAccountNameController,
            decoration: const InputDecoration(labelText: 'Account Name'),
          ),
        ],
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
              child: const Text('Generate'),
            ),
          ],
        ),
      ],
    );
  }
}
