import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Admin Access Control Service
///
/// Provides methods to check admin permissions and restrict access
/// to admin-only features like bank account configuration and
/// sensitive payment information.
class AdminAccessControl {
  /// Check if the current user is an admin (main admin or sub admin)
  static Future<bool> isAdmin() async {
    final user = await AuthService.currentUser();
    return user?.isAdmin ?? false;
  }

  /// Check if the current user is the main admin
  static Future<bool> isMainAdmin() async {
    final user = await AuthService.currentUser();
    return user?.isMainAdmin ?? false;
  }

  /// Check if the current user is sub admin 2 (can approve subscriptions)
  static Future<bool> canApproveSubscriptions() async {
    final user = await AuthService.currentUser();
    return (user?.isMainAdmin ?? false) || (user?.isSubAdmin2 ?? false);
  }

  /// Get current admin user
  static Future<User?> getCurrentAdmin() async {
    final user = await AuthService.currentUser();
    if (user != null && user.isAdmin) {
      return user;
    }
    return null;
  }

  /// Show access denied dialog
  static void showAccessDeniedDialog(
    BuildContext context, {
    String? message,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            Text(title ?? 'Access Denied'),
          ],
        ),
        content: Text(
          message ??
              'You do not have permission to access this feature. Admin access required.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigate back with access denied message
  static void denyAccessAndNavigateBack(
    BuildContext context, {
    String? message,
  }) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'Access denied. Admin privileges required.',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Check admin access and navigate back if not authorized
  static Future<bool> checkAdminAccessOrNavigateBack(
    BuildContext context, {
    String? message,
    bool requireMainAdmin = false,
  }) async {
    final user = await AuthService.currentUser();

    if (user == null) {
      if (context.mounted) {
        denyAccessAndNavigateBack(context,
            message: 'Please login to continue.');
      }
      return false;
    }

    final hasAccess = requireMainAdmin ? user.isMainAdmin : user.isAdmin;

    if (!hasAccess) {
      if (context.mounted) {
        denyAccessAndNavigateBack(
          context,
          message: message ??
              (requireMainAdmin
                  ? 'Main Admin access required.'
                  : 'Admin access required.'),
        );
      }
      return false;
    }

    return true;
  }

  /// Create an admin-only widget wrapper
  /// Shows placeholder or nothing if user is not admin
  static Widget adminOnly({
    required Widget child,
    Widget? placeholder,
    required bool isAdmin,
  }) {
    if (isAdmin) {
      return child;
    }
    return placeholder ?? const SizedBox.shrink();
  }

  /// Create a sensitive info blur widget for non-admins
  static Widget sensitiveInfo({
    required Widget child,
    required bool isAdmin,
    String? message,
  }) {
    if (isAdmin) {
      return child;
    }

    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: child,
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black12,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 32, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    message ?? 'Admin Only',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget for admin-protected screens
class AdminProtectedScreen extends StatefulWidget {
  final Widget child;
  final String? deniedMessage;
  final bool requireMainAdmin;

  const AdminProtectedScreen({
    super.key,
    required this.child,
    this.deniedMessage,
    this.requireMainAdmin = false,
  });

  @override
  State<AdminProtectedScreen> createState() => _AdminProtectedScreenState();
}

class _AdminProtectedScreenState extends State<AdminProtectedScreen> {
  bool _isLoading = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final hasAccess = await AdminAccessControl.checkAdminAccessOrNavigateBack(
      context,
      message: widget.deniedMessage,
      requireMainAdmin: widget.requireMainAdmin,
    );

    if (mounted) {
      setState(() {
        _hasAccess = hasAccess;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied'),
        ),
      );
    }

    return widget.child;
  }
}
