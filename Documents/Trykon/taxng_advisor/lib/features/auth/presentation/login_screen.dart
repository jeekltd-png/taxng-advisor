import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isRegister = false;
  bool _isBusiness = false;
  final _businessNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _cacController = TextEditingController();
  final _bvnController = TextEditingController();
  final _vatController = TextEditingController();
  final _payeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedIndustrySector;
  String? _selectedTaxOffice;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _tinController.dispose();
    _cacController.dispose();
    _bvnController.dispose();
    _vatController.dispose();
    _payeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_isRegister) {
      final email = _emailController.text.trim();
      final businessName = _businessNameController.text.trim();
      final tin = _tinController.text.trim();
      final cac = _cacController.text.trim();
      final bvn = _bvnController.text.trim();
      final vat = _vatController.text.trim();
      final paye = _payeController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      final user = await AuthService.register(
        username: username,
        password: password,
        email: email,
        isBusiness: _isBusiness,
        businessName: _isBusiness ? businessName : null,
        tin: tin.isNotEmpty ? tin : null,
        cacNumber: cac.isNotEmpty ? cac : null,
        bvn: bvn.isNotEmpty ? bvn : null,
        vatNumber: vat.isNotEmpty ? vat : null,
        payeRef: paye.isNotEmpty ? paye : null,
        phoneNumber: phone.isNotEmpty ? phone : null,
        address: address.isNotEmpty ? address : null,
        taxOffice: _selectedTaxOffice,
        industrySector: _isBusiness ? _selectedIndustrySector : null,
      );

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
        return;
      }

      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      final user = await AuthService.login(username, password);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
        return;
      }
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login / Register'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // App icon at top center
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/welcome'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'e.g., admin or user@example.com',
                      helperText: 'Username can be a valid email address',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    TextFormField(
                      controller: _tinController,
                      decoration: const InputDecoration(
                        labelText: 'TIN (Tax Identification Number)',
                        hintText: 'e.g., 12345678-0001',
                        helperText:
                            'Optional but recommended for tax compliance',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g., 08012345678',
                        helperText: 'Required by FIRS',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Physical Address',
                        hintText: 'Complete address required by FIRS',
                      ),
                      maxLines: 2,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister && !_isBusiness)
                    TextFormField(
                      controller: _bvnController,
                      decoration: const InputDecoration(
                        labelText: 'BVN (Bank Verification Number)',
                        hintText: '11 digits',
                        helperText: 'Required for individual taxpayers',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    Row(
                      children: [
                        const Text('Register as business'),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isBusiness,
                          onChanged: (v) => setState(() => _isBusiness = v),
                        ),
                      ],
                    ),
                  if (_isRegister && _isBusiness)
                    TextFormField(
                      controller: _businessNameController,
                      decoration:
                          const InputDecoration(labelText: 'Business Name'),
                    ),
                  if (_isRegister && _isBusiness) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cacController,
                      decoration: const InputDecoration(
                        labelText: 'CAC Registration Number',
                        hintText: 'e.g., RC1234567 or BN1234567',
                        helperText: 'Required for registered businesses',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vatController,
                      decoration: const InputDecoration(
                        labelText: 'VAT Registration Number',
                        hintText: 'If turnover > ₦25M',
                        helperText: 'Required for VAT-registered businesses',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _payeController,
                      decoration: const InputDecoration(
                        labelText: 'PAYE Reference Number',
                        hintText: 'If you have employees',
                        helperText: 'Required for employers',
                      ),
                    ),
                  ],
                  if (_isRegister && _isBusiness) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTaxOffice,
                      decoration: const InputDecoration(
                        labelText: 'FIRS Tax Office',
                        helperText: 'Your registered tax office/station',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: null,
                            child: Text('Select tax office (optional)')),
                        DropdownMenuItem(
                            value: 'Lagos Island', child: Text('Lagos Island')),
                        DropdownMenuItem(
                            value: 'Lagos Mainland',
                            child: Text('Lagos Mainland')),
                        DropdownMenuItem(value: 'Ikeja', child: Text('Ikeja')),
                        DropdownMenuItem(
                            value: 'Abuja Wuse', child: Text('Abuja Wuse')),
                        DropdownMenuItem(
                            value: 'Abuja Central',
                            child: Text('Abuja Central')),
                        DropdownMenuItem(
                            value: 'Port Harcourt',
                            child: Text('Port Harcourt')),
                        DropdownMenuItem(value: 'Kano', child: Text('Kano')),
                        DropdownMenuItem(
                            value: 'Ibadan', child: Text('Ibadan')),
                        DropdownMenuItem(value: 'Enugu', child: Text('Enugu')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedTaxOffice = value);
                      },
                    ),
                  ],
                  if (_isRegister && _isBusiness) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedIndustrySector,
                      decoration: const InputDecoration(
                        labelText: 'Industry Sector',
                        helperText: 'Oil & Gas sector payments will be in USD',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Select industry (optional)'),
                        ),
                        DropdownMenuItem(
                          value: 'oil_and_gas',
                          child: Text('Oil and Gas / Petroleum (USD payments)'),
                        ),
                        DropdownMenuItem(
                          value: 'manufacturing',
                          child: Text('Manufacturing'),
                        ),
                        DropdownMenuItem(
                          value: 'technology',
                          child: Text('Technology'),
                        ),
                        DropdownMenuItem(
                          value: 'finance',
                          child: Text('Finance / Banking'),
                        ),
                        DropdownMenuItem(
                          value: 'retail',
                          child: Text('Retail / Trading'),
                        ),
                        DropdownMenuItem(
                          value: 'services',
                          child: Text('Professional Services'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedIndustrySector = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isRegister ? 'Register' : 'Login'),
                  ),
                  if (!_isRegister) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister
                        ? 'Already have an account? Login'
                        : 'Create account'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text('Profile / Import Data'),
                  ),
                  // Debug button only visible in debug mode
                  if (const bool.fromEnvironment('dart.vm.product') ==
                      false) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/debug/users'),
                      child: const Text('Debug - Seed / Login Users'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
