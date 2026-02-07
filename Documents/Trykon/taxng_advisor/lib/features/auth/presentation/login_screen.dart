import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/theme/colors.dart';

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
  bool _didCheckArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didCheckArgs) {
      _didCheckArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['register'] == true) {
        setState(() {
          _isRegister = true;
        });
      }
    }
  }

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
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      },
      child: Scaffold(
        backgroundColor: TaxNGColors.bgLight,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Text(
                      _isRegister ? 'Create Account' : 'Welcome back',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: TaxNGColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegister
                          ? 'Set up your TaxNG profile to get started'
                          : 'Sign in to continue managing your taxes',
                      style: const TextStyle(
                        fontSize: 15,
                        color: TaxNGColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Registration fields
                    if (_isRegister) ...[
                      // Name row
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernField(
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  _isRegister && (v == null || v.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModernField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  _isRegister && (v == null || v.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildModernField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _onEmailChanged,
                        validator: (v) {
                          if (_isRegister && (v == null || v.isEmpty)) {
                            return 'Required';
                          }
                          if (v != null && v.isNotEmpty && !v.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildModernField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '08012345678',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      // Email as username toggle
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: TaxNGColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: TaxNGColors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _useEmailAsUsername
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: TaxNGColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Use email as username',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: TaxNGColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Switch.adaptive(
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
                              activeColor: TaxNGColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildModernField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: _useEmailAsUsername
                            ? 'Using email as username'
                            : 'Choose a username',
                        icon: Icons.alternate_email_rounded,
                        enabled: !_useEmailAsUsername,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Login username field
                    if (!_isRegister) ...[
                      _buildModernField(
                        controller: _usernameController,
                        label: 'Username or Email',
                        hint: 'admin or user@example.com',
                        icon: Icons.person_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Password field
                    _buildModernField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),

                    // Registration extra fields
                    if (_isRegister) ...[
                      const SizedBox(height: 14),
                      _buildModernField(
                        controller: _tinController,
                        label: 'TIN (Tax Identification Number)',
                        hint: '12345678-0001',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      if (!_isBusiness) ...[
                        const SizedBox(height: 14),
                        _buildModernField(
                          controller: _bvnController,
                          label: 'BVN',
                          hint: '11 digits',
                          icon: Icons.account_balance_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                        ),
                      ],
                      const SizedBox(height: 14),
                      // Business toggle
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _isBusiness
                              ? TaxNGColors.secondary.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isBusiness
                                ? TaxNGColors.secondary.withOpacity(0.3)
                                : TaxNGColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              color: _isBusiness
                                  ? TaxNGColors.secondary
                                  : TaxNGColors.textLight,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Business Account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Register as a business entity',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TaxNGColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _isBusiness,
                              onChanged: (v) => setState(() => _isBusiness = v),
                              activeColor: TaxNGColors.secondary,
                            ),
                          ],
                        ),
                      ),
                      if (_isBusiness) ...[
                        const SizedBox(height: 14),
                        _buildModernField(
                          controller: _businessNameController,
                          label: 'Business Name',
                          icon: Icons.domain_rounded,
                          validator: (v) =>
                              _isBusiness && (v == null || v.isEmpty)
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        _buildModernField(
                          controller: _cacController,
                          label: 'CAC Number (Optional)',
                          hint: 'RC1234567',
                          icon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildModernField(
                          controller: _addressController,
                          label: 'Business Address',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        _buildModernField(
                          controller: _vatController,
                          label: 'VAT Number (Optional)',
                          hint: 'If turnover > ₦25M',
                          icon: Icons.receipt_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _selectedTaxOffice,
                          decoration: InputDecoration(
                            labelText: 'FIRS Tax Office',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: TaxNGColors.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: TaxNGColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: TaxNGColors.primary, width: 2),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: null, child: Text('Select tax office')),
                            DropdownMenuItem(
                                value: 'Lagos Island',
                                child: Text('Lagos Island')),
                            DropdownMenuItem(
                                value: 'Lagos Mainland',
                                child: Text('Lagos Mainland')),
                            DropdownMenuItem(
                                value: 'Ikeja', child: Text('Ikeja')),
                            DropdownMenuItem(
                                value: 'Abuja Wuse', child: Text('Abuja Wuse')),
                            DropdownMenuItem(
                                value: 'Abuja Central',
                                child: Text('Abuja Central')),
                            DropdownMenuItem(
                                value: 'Port Harcourt',
                                child: Text('Port Harcourt')),
                            DropdownMenuItem(
                                value: 'Kano', child: Text('Kano')),
                            DropdownMenuItem(
                                value: 'Ibadan', child: Text('Ibadan')),
                            DropdownMenuItem(
                                value: 'Enugu', child: Text('Enugu')),
                            DropdownMenuItem(
                                value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedTaxOffice = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _selectedIndustrySector,
                          decoration: InputDecoration(
                            labelText: 'Industry Sector',
                            helperText:
                                'Oil & Gas sector payments will be in USD',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: TaxNGColors.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: TaxNGColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: TaxNGColors.primary, width: 2),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: null, child: Text('Select industry')),
                            DropdownMenuItem(
                                value: 'oil_and_gas',
                                child: Text('Oil and Gas / Petroleum (USD)')),
                            DropdownMenuItem(
                                value: 'manufacturing',
                                child: Text('Manufacturing')),
                            DropdownMenuItem(
                                value: 'technology', child: Text('Technology')),
                            DropdownMenuItem(
                                value: 'finance',
                                child: Text('Finance / Banking')),
                            DropdownMenuItem(
                                value: 'retail',
                                child: Text('Retail / Trading')),
                            DropdownMenuItem(
                                value: 'services',
                                child: Text('Professional Services')),
                            DropdownMenuItem(
                                value: 'other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedIndustrySector = value);
                          },
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TaxNGColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRegister ? 'Create Account' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),

                    if (!_isRegister) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: TaxNGColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Toggle Register/Login
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegister
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style: const TextStyle(
                              color: TaxNGColors.textMedium,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isRegister = !_isRegister),
                            child: Text(
                              _isRegister ? 'Sign In' : 'Register',
                              style: const TextStyle(
                                color: TaxNGColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Profile / Import Data
                    Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/profile'),
                        icon: const Icon(Icons.download_rounded,
                            size: 18, color: TaxNGColors.textLight),
                        label: const Text(
                          'Import Data',
                          style: TextStyle(
                            color: TaxNGColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    // Debug button
                    if (const bool.fromEnvironment('dart.vm.product') ==
                        false) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/debug/users'),
                          child: const Text(
                            'Debug - Seed / Login Users',
                            style: TextStyle(
                              color: TaxNGColors.textLighter,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscureText = false,
    bool enabled = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: TaxNGColors.primary),
        filled: true,
        fillColor: enabled ? Colors.white : TaxNGColors.bgLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TaxNGColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TaxNGColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TaxNGColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TaxNGColors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TaxNGColors.borderLight),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: TaxNGColors.textMedium,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 13,
          color: TaxNGColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: validator,
    );
  }
}
