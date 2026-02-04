/// TaxNG AppBar Widget with user profile display
import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Custom AppBar that displays user profile photo and name on the right side
class TaxNGAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showUserProfile;
  final PreferredSizeWidget? bottom;

  const TaxNGAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.showUserProfile = true,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      bottom: bottom,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        if (showUserProfile) const _UserProfileWidget(),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Widget that displays user photo and name
class _UserProfileWidget extends StatelessWidget {
  const _UserProfileWidget();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userName =
            user?['name'] ?? user?['email']?.split('@').first ?? 'User';
        final userPhoto = user?['photoUrl'] as String?;
        final initials = _getInitials(userName);

        return InkWell(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  backgroundImage: userPhoto != null && userPhoto.isNotEmpty
                      ? NetworkImage(userPhoto)
                      : null,
                  child: userPhoto == null || userPhoto.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final user = await AuthService.currentUser();
    if (user != null) {
      return {
        'name': user.username,
        'email': user.email,
        'photoUrl':
            null, // UserProfile doesn't have photoUrl, will use initials
      };
    }
    return null;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }
}

/// Standalone user profile widget for use in any AppBar
class UserProfileAppBarWidget extends StatelessWidget {
  const UserProfileAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserProfileWidget();
  }
}
