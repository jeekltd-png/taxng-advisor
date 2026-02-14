import 'dart:math';
import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  // Multi-step flow: 0=identify, 1=verify OTP, 2=new password
  int _step = 0;
  String? _verifiedUsername;
  String? _generatedOtp;
  String? _maskedEmail;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Step 1: Verify user exists and generate a simulated OTP
  Future<void> _verifyUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final input = _usernameOrEmailController.text.trim();
    final username = await AuthService.verifyUserForPasswordReset(input);

    if (username == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found with this username or email'),
          ),
        );
      }
      return;
    }

    // Generate a 6-digit OTP
    final otp = (100000 + Random.secure().nextInt(900000)).toString();
    _generatedOtp = otp;
    _verifiedUsername = username;

    // Mask the email for display (show first 2 chars + domain)
    _maskedEmail = _maskEmail(input.contains('@') ? input : '$username@*');

    // In production this would be sent via SMS/email backend.
    // For now we show it in a dialog (simulating "check your email").
    debugPrint('🔐 OTP for $username: $otp'); // Debug only

    setState(() {
      _step = 1;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent to $_maskedEmail'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Show OTP in a dialog for demo purposes (remove in production with real email/SMS)
      _showOtpDemoDialog(otp);
    }
  }

  /// Show OTP for demo/development (replace with real email/SMS in production)
  void _showOtpDemoDialog(String otp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Verification Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'In production, this code would be sent to your registered email/phone. For now:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                otp,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return '***@***';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  /// Step 2: Verify OTP
  void _verifyOtp() {
    if (!_formKey.currentState!.validate()) return;

    if (_otpController.text.trim() != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid verification code. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _step = 2;
    });
  }

  /// Step 3: Reset password
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Validate password strength
    final strengthError = AuthService.validatePasswordStrength(newPassword);
    if (strengthError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strengthError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await AuthService.resetPassword(
      _verifiedUsername!,
      newPassword,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reset password')),
        );
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    return AuthService.validatePasswordStrength(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Forgot your password?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Step indicator
                _buildStepIndicator(),
                const SizedBox(height: 24),

                // ── Step 0: Identify user ──
                if (_step == 0) ...[
                  const Text(
                    'Enter your username or email address to receive a verification code.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameOrEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Username or Email',
                      hintText: 'e.g., admin or user@example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Send Verification Code'),
                    ),
                  ),
                ],

                // ── Step 1: Verify OTP ──
                if (_step == 1) ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.email, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Enter the 6-digit code sent to $_maskedEmail',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter 6-digit code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_clock),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length != 6) return 'Enter a 6-digit code';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Verify Code'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _step = 0);
                      },
                      child: const Text('Resend code'),
                    ),
                  ),
                ],

                // ── Step 2: New password ──
                if (_step == 2) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Identity verified: $_verifiedUsername',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Min 8 chars, upper+lower+digit+special',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter new password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Reset Password'),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _stepCircle(0, 'Identify'),
          _stepLine(0),
          _stepCircle(1, 'Verify'),
          _stepLine(1),
          _stepCircle(2, 'Reset'),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    final isActive = _step >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? Colors.green : Colors.grey.shade300,
          child: isActive
              ? (_step > step
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('${step + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)))
              : Text('${step + 1}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _stepLine(int afterStep) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: _step > afterStep ? Colors.green : Colors.grey.shade300,
      ),
    );
  }
}
