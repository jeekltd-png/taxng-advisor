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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isRegister = false;
  bool _isBusiness = false;
  bool _useEmailAsUsername = true; // Default to using email as username
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
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  /// Sync username with email when "use email as username" is enabled
  void _onEmailChanged(String value) {
    if (_useEmailAsUsername) {
      _usernameController.text = value;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_isRegister) {
      final email = _emailController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
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
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
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
                  // First Name and Last Name (only for registration)
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => _isRegister && (v == null || v.isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => _isRegister && (v == null || v.isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Email field (for registration)
                    TextFormField(
                      controller: _emailController,
                      onChanged: _onEmailChanged,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (_isRegister && (v == null || v.isEmpty)) {
                          return 'Required';
                        }
                        if (v != null && v.isNotEmpty && !v.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g., 08012345678',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    // Use email as username toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _useEmailAsUsername
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Use email as username',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                Text(
                                  _useEmailAsUsername
                                      ? 'Your email will be used for login'
                                      : 'Enter a custom username below',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _useEmailAsUsername,
                            onChanged: (v) {
                              setState(() {
                                _useEmailAsUsername = v;
                                if (v) {
                                  _usernameController.text =
                                      _emailController.text;
                                } else {
                                  _usernameController.clear();
                                }
                              });
                            },
                            activeColor: Colors.blue[700],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Username field (disabled if using email)
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_useEmailAsUsername,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: _useEmailAsUsername
                            ? 'Using email as username'
                            : 'Enter your username',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: _useEmailAsUsername
                            ? Colors.grey[200]
                            : Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        helperText: _useEmailAsUsername
                            ? 'Auto-populated from email'
                            : null,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Username field for Login only
                  if (!_isRegister)
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'e.g., admin or user@example.com',
                        helperText: 'Username can be a valid email address',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  if (!_isRegister) const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    TextFormField(
                      controller: _tinController,
                      decoration: InputDecoration(
                        labelText: 'Tax Identification Number (TIN)',
                        hintText: 'e.g., 12345678-0001',
                        helperText:
                            'Optional but recommended for tax compliance',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister && !_isBusiness)
                    TextFormField(
                      controller: _bvnController,
                      decoration: InputDecoration(
                        labelText: 'BVN (Bank Verification Number)',
                        hintText: '11 digits',
                        helperText: 'Required for individual taxpayers',
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                    ),
                  const SizedBox(height: 12),
                  if (_isRegister)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isBusiness ? Colors.blue[50] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isBusiness
                              ? Colors.blue[300]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: _isBusiness
                                ? Colors.blue[700]
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isBusiness
                                        ? Colors.blue[900]
                                        : Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Register as a business entity',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isBusiness
                                        ? Colors.blue[700]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isBusiness,
                            onChanged: (v) => setState(() => _isBusiness = v),
                            activeColor: Colors.blue[700],
                          ),
                        ],
                      ),
                    ),
                  if (_isRegister && _isBusiness) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: InputDecoration(
                        labelText: 'Business Name',
                        prefixIcon: const Icon(Icons.domain),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => _isBusiness && (v == null || v.isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cacController,
                      decoration: InputDecoration(
                        labelText: 'CAC Number (Optional)',
                        hintText: 'e.g., RC1234567 or BN1234567',
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Business Address',
                        hintText: 'Complete address required by FIRS',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vatController,
                      decoration: InputDecoration(
                        labelText: 'VAT Number (Optional)',
                        hintText: 'If turnover > ₦25M',
                        prefixIcon: const Icon(Icons.receipt_outlined),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegister ? 'Create Account' : 'Login',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
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
