import 'package:flutter/foundation.dart';
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
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isRegister = false;
  bool _isBusiness = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _useEmailAsUsername = true;
  bool _agreedToTerms = false;
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
        setState(() => _isRegister = true);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _onEmailChanged(String value) {
    if (_useEmailAsUsername) {
      _usernameController.text = value;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    if (_isRegister && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Privacy Policy to continue'),
          backgroundColor: TaxNGColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isRegister) {
        final user = await AuthService.register(
          username: username,
          password: password,
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim().isNotEmpty
              ? _firstNameController.text.trim()
              : null,
          lastName: _lastNameController.text.trim().isNotEmpty
              ? _lastNameController.text.trim()
              : null,
          isBusiness: _isBusiness,
          businessName:
              _isBusiness ? _businessNameController.text.trim() : null,
          tin: _tinController.text.trim().isNotEmpty
              ? _tinController.text.trim()
              : null,
          cacNumber: _cacController.text.trim().isNotEmpty
              ? _cacController.text.trim()
              : null,
          bvn: _bvnController.text.trim().isNotEmpty
              ? _bvnController.text.trim()
              : null,
          vatNumber: _vatController.text.trim().isNotEmpty
              ? _vatController.text.trim()
              : null,
          payeRef: _payeController.text.trim().isNotEmpty
              ? _payeController.text.trim()
              : null,
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          taxOffice: _selectedTaxOffice,
          industrySector: _isBusiness ? _selectedIndustrySector : null,
        );
        if (!mounted) return;
        if (user == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Username already exists or password does not meet requirements'),
              backgroundColor: TaxNGColors.error,
            ),
          );
          return;
        }
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        if (AuthService.isRateLimited(username)) {
          final remaining = AuthService.getRemainingLockoutSeconds(username);
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Account locked. Try again in ${remaining ~/ 60}m ${remaining % 60}s'),
              backgroundColor: TaxNGColors.error,
            ),
          );
          return;
        }
        final user = await AuthService.login(username, password);
        if (!mounted) return;
        if (user == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid username or password. Please try again.'),
              backgroundColor: TaxNGColors.error,
            ),
          );
          return;
        }
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Something went wrong. Please try again or contact support.'),
          backgroundColor: TaxNGColors.error,
        ),
      );
      debugPrint('Login/Register error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : TaxNGColors.textDark;
    final subtitleColor = isDark ? Colors.white60 : TaxNGColors.textMedium;
    final cardColor = isDark ? TaxNGColors.bgDarkSecondary : Colors.white;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/welcome');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    IconButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/welcome'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isRegister ? 'Create Account' : 'Welcome back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegister
                          ? 'Set up your TaxNG profile to get started'
                          : 'Sign in to continue managing your taxes',
                      style: TextStyle(
                          fontSize: 15, color: subtitleColor, height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    if (_isRegister) ...[
                      Row(children: [
                        Expanded(
                          child: _buildField(
                            controller: _firstNameController,
                            label: 'First Name',
                            icon: Icons.person_outline_rounded,
                            action: TextInputAction.next,
                            autofill: const [AutofillHints.givenName],
                            validator: (v) =>
                                _isRegister && (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            icon: Icons.person_outline_rounded,
                            action: TextInputAction.next,
                            autofill: const [AutofillHints.familyName],
                            validator: (v) =>
                                _isRegister && (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.email],
                        onChanged: _onEmailChanged,
                        validator: (v) {
                          if (_isRegister && (v == null || v.isEmpty))
                            return 'Required';
                          if (v != null &&
                              v.isNotEmpty &&
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(v)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '08012345678',
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.telephoneNumberNational],
                      ),
                      const SizedBox(height: 14),
                      _buildToggleRow(
                        icon: _useEmailAsUsername
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        label: 'Use email as username',
                        color: TaxNGColors.primary,
                        value: _useEmailAsUsername,
                        onChanged: (v) {
                          setState(() {
                            _useEmailAsUsername = v;
                            if (v) {
                              _usernameController.text = _emailController.text;
                            } else {
                              _usernameController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: _useEmailAsUsername
                            ? 'Using email as username'
                            : 'Choose a username',
                        icon: Icons.alternate_email_rounded,
                        enabled: !_useEmailAsUsername,
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.username],
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (!_isRegister) ...[
                      _buildField(
                        controller: _usernameController,
                        label: 'Username or Email',
                        hint: 'Enter your username or email',
                        icon: Icons.person_rounded,
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.username],
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Password with visibility toggle
                    _buildField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      action: _isRegister
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofill: _isRegister
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color:
                              isDark ? Colors.white54 : TaxNGColors.textLight,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (_isRegister)
                          return AuthService.validatePasswordStrength(v);
                        return null;
                      },
                    ),

                    // Confirm password
                    if (_isRegister) ...[
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscureConfirmPassword,
                        action: TextInputAction.next,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                            color:
                                isDark ? Colors.white54 : TaxNGColors.textLight,
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _tinController,
                        label: 'TIN (Tax Identification Number)',
                        hint: '12345678-0001',
                        icon: Icons.badge_outlined,
                        keyboard: TextInputType.number,
                        action: TextInputAction.next,
                      ),
                      if (!_isBusiness) ...[
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _bvnController,
                          label: 'BVN',
                          hint: '11 digits',
                          icon: Icons.account_balance_outlined,
                          keyboard: TextInputType.number,
                          maxLength: 11,
                          obscure: true, // Mask BVN for security
                          action: TextInputAction.next,
                        ),
                      ],
                      const SizedBox(height: 14),
                      _buildBusinessToggle(
                          isDark, textColor, subtitleColor, cardColor),
                      if (_isBusiness) ..._buildBusinessFields(isDark),
                      // Terms checkbox
                      const SizedBox(height: 18),
                      _buildTermsCheckbox(
                          isDark, textColor, subtitleColor, cardColor),
                    ],

                    const SizedBox(height: 24),
                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TaxNGColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white)),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isRegister ? 'Create Account' : 'Sign In',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 20),
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
                          child: Text('Forgot Password?',
                              style: TextStyle(
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegister
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style:
                                TextStyle(color: subtitleColor, fontSize: 14),
                          ),
                          InkWell(
                            onTap: () =>
                                setState(() => _isRegister = !_isRegister),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(
                                _isRegister ? 'Sign In' : 'Register',
                                style: const TextStyle(
                                    color: TaxNGColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/import-data'),
                        icon: Icon(Icons.download_rounded,
                            size: 18, color: subtitleColor),
                        label: Text('Import Data',
                            style:
                                TextStyle(color: subtitleColor, fontSize: 13)),
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/debug/users'),
                          child: Text('Debug - Seed / Login Users',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white24
                                      : TaxNGColors.textLighter,
                                  fontSize: 12)),
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

  // ── Business Fields ──────────────────────────────────────────────
  List<Widget> _buildBusinessFields(bool isDark) {
    final borderColor =
        isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight;
    final fillColor = isDark ? TaxNGColors.bgDarkSecondary : Colors.white;
    return [
      const SizedBox(height: 14),
      _buildField(
        controller: _businessNameController,
        label: 'Business Name',
        icon: Icons.domain_rounded,
        action: TextInputAction.next,
        validator: (v) =>
            _isBusiness && (v == null || v.isEmpty) ? 'Required' : null,
      ),
      const SizedBox(height: 14),
      _buildField(
        controller: _cacController,
        label: 'CAC Number (Optional)',
        hint: 'RC1234567',
        icon: Icons.description_outlined,
        action: TextInputAction.next,
      ),
      const SizedBox(height: 14),
      _buildField(
        controller: _addressController,
        label: 'Business Address',
        icon: Icons.location_on_outlined,
        maxLines: 2,
        action: TextInputAction.next,
      ),
      const SizedBox(height: 14),
      _buildField(
        controller: _payeController,
        label: 'PAYE Reference (Optional)',
        icon: Icons.tag_rounded,
        action: TextInputAction.next,
      ),
      const SizedBox(height: 14),
      _buildField(
        controller: _vatController,
        label: 'VAT Number (Optional)',
        hint: 'If turnover > ₦25M',
        icon: Icons.receipt_outlined,
        keyboard: TextInputType.number,
        action: TextInputAction.next,
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        initialValue: _selectedTaxOffice,
        decoration: InputDecoration(
          labelText: 'FIRS Tax Office',
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: TaxNGColors.primary, width: 2)),
        ),
        dropdownColor: fillColor,
        items: const [
          DropdownMenuItem(value: null, child: Text('Select tax office')),
          DropdownMenuItem(value: 'Lagos Island', child: Text('Lagos Island')),
          DropdownMenuItem(
              value: 'Lagos Mainland', child: Text('Lagos Mainland')),
          DropdownMenuItem(value: 'Ikeja', child: Text('Ikeja')),
          DropdownMenuItem(value: 'Abuja Wuse', child: Text('Abuja Wuse')),
          DropdownMenuItem(
              value: 'Abuja Central', child: Text('Abuja Central')),
          DropdownMenuItem(
              value: 'Port Harcourt', child: Text('Port Harcourt')),
          DropdownMenuItem(value: 'Kano', child: Text('Kano')),
          DropdownMenuItem(value: 'Ibadan', child: Text('Ibadan')),
          DropdownMenuItem(value: 'Enugu', child: Text('Enugu')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => _selectedTaxOffice = v),
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        initialValue: _selectedIndustrySector,
        decoration: InputDecoration(
          labelText: 'Industry Sector',
          helperText: 'Oil & Gas sector payments will be in USD',
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: TaxNGColors.primary, width: 2)),
        ),
        dropdownColor: fillColor,
        items: const [
          DropdownMenuItem(value: null, child: Text('Select industry')),
          DropdownMenuItem(
              value: 'oil_and_gas',
              child: Text('Oil and Gas / Petroleum (USD)')),
          DropdownMenuItem(
              value: 'manufacturing', child: Text('Manufacturing')),
          DropdownMenuItem(value: 'technology', child: Text('Technology')),
          DropdownMenuItem(value: 'finance', child: Text('Finance / Banking')),
          DropdownMenuItem(value: 'retail', child: Text('Retail / Trading')),
          DropdownMenuItem(
              value: 'services', child: Text('Professional Services')),
          DropdownMenuItem(value: 'other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => _selectedIndustrySector = v),
      ),
    ];
  }

  // ── Toggle Row ──────────────────────────────────────────────────
  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: color, fontSize: 14)),
          ),
          Switch.adaptive(
              value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }

  // ── Business Toggle ──────────────────────────────────────────────
  Widget _buildBusinessToggle(
      bool isDark, Color textColor, Color subtitleColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isBusiness
            ? TaxNGColors.secondary.withValues(alpha: 0.08)
            : cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isBusiness
              ? TaxNGColors.secondary.withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.business_rounded,
              color:
                  _isBusiness ? TaxNGColors.secondary : TaxNGColors.textLight,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business Account',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor)),
                Text('Register as a business entity',
                    style: TextStyle(fontSize: 12, color: subtitleColor)),
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
    );
  }

  // ── Terms Checkbox ──────────────────────────────────────────────
  Widget _buildTermsCheckbox(
      bool isDark, Color textColor, Color subtitleColor, Color cardColor) {
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _agreedToTerms
              ? TaxNGColors.primary.withValues(alpha: 0.06)
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _agreedToTerms
                ? TaxNGColors.primary.withValues(alpha: 0.3)
                : (isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _agreedToTerms
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: _agreedToTerms ? TaxNGColors.primary : subtitleColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(children: [
                Text('I agree to the ',
                    style: TextStyle(fontSize: 13, color: textColor)),
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, '/help/privacy-policy'),
                  child: const Text('Terms of Service',
                      style: TextStyle(
                          fontSize: 13,
                          color: TaxNGColors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline)),
                ),
                Text(' and ', style: TextStyle(fontSize: 13, color: textColor)),
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, '/help/privacy-policy'),
                  child: const Text('Privacy Policy',
                      style: TextStyle(
                          fontSize: 13,
                          color: TaxNGColors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modern Text Field ──────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscure = false,
    bool enabled = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboard,
    TextInputAction? action,
    Iterable<String>? autofill,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = enabled
        ? (isDark ? TaxNGColors.bgDarkSecondary : Colors.white)
        : (isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight);
    final borderColor =
        isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      maxLines: obscure ? 1 : maxLines,
      maxLength: maxLength,
      keyboardType: keyboard,
      textInputAction: action,
      autofillHints: autofill,
      onChanged: onChanged,
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : TaxNGColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: TaxNGColors.primary),
        suffixIcon: suffix,
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TaxNGColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TaxNGColors.error)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor)),
        labelStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : TaxNGColors.textMedium),
        floatingLabelStyle: TextStyle(
            fontSize: 13,
            color: TaxNGColors.primary,
            fontWeight: FontWeight.w600),
      ),
      validator: validator,
    );
  }
}
