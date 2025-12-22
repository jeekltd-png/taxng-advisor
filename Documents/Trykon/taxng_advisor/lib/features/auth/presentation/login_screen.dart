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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_isRegister) {
      final email = _emailController.text.trim();
      final businessName = _businessNameController.text.trim();
      final user = await AuthService.register(
        username: username,
        password: password,
        email: email,
        isBusiness: _isBusiness,
        businessName: _isBusiness ? businessName : null,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isRegister ? 'Register' : 'Login'),
                ),
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/debug/users'),
                  child: const Text('Debug - Seed / Login Users'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
