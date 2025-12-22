# Admin Currency Conversion Documentation - Setup Guide

## Overview

The currency conversion feature now includes **admin-only documentation** accessible through the Help section. Only users with admin privileges can access the complete implementation guide, code examples, and API reference.

## Admin Access

### Default Admin Account
- **Username:** `admin`
- **Password:** `Admin@123`

### How Admins Access Documentation

1. Login with admin account
2. Go to Help menu → Help Articles
3. Look for **"Admin: Currency Conversion"** button (purple)
4. Click to open comprehensive documentation

### What Admins Can See

The admin documentation screen includes 3 tabs:

#### **Tab 1: Overview**
- Feature summary
- Key features list
- Exchange rate configuration
- User benefits
- Files created/modified

#### **Tab 2: Implementation**
- Integration steps (4 steps)
- Code examples for CIT Calculator
- Integration points for all 6 calculators
- Integration time estimates
- Code snippets ready to use

#### **Tab 3: API Reference**
- Complete method documentation
- Parameter specifications
- Return types
- Usage examples
- Constructor signatures
- Exchange rate configuration

## Security Features

✅ **Admin-Only Access**
- Non-admins cannot access `/help/admin/currency-conversion` route
- Automatic redirect if non-admin tries to access
- Authorization check on screen load

✅ **User Model Updated**
- Added `isAdmin` boolean field
- Default: `false` for all users
- Set to `true` only for admin user

✅ **Authentication Integrated**
- Screen checks `AuthService.currentUser()`
- Verifies `isAdmin` property
- Redirects unauthorized users

## File Changes

| File | Change | Details |
|------|--------|---------|
| `lib/models/user.dart` | Modified | Added `isAdmin` field to UserProfile |
| `lib/services/auth_service.dart` | Modified | Marked admin user with `isAdmin: true` |
| `lib/features/help/currency_conversion_admin_screen.dart` | Created | New admin documentation screen |
| `lib/features/help/help_articles_screen.dart` | Modified | Added admin button and auth check |
| `lib/main.dart` | Modified | Added admin screen route |

## How It Works

### 1. User Authentication
When a user logs in, the `isAdmin` field is checked from the Hive database.

### 2. Admin Status Detection
In Help Articles screen:
```dart
// Check if current user is admin
final user = await AuthService.currentUser();
setState(() {
  _isAdmin = user?.isAdmin ?? false;
});
```

### 3. Conditional Button Display
Only admins see the purple "Admin: Currency Conversion" button:
```dart
if (_isAdmin)
  FloatingActionButton.extended(
    onPressed: () => Navigator.pushNamed(
      context,
      '/help/admin/currency-conversion',
    ),
    label: const Text('Admin: Currency'),
    icon: const Icon(Icons.admin_panel_settings),
    backgroundColor: Colors.deepPurple,
  ),
```

### 4. Route Protection
When admin route is accessed:
```dart
Future<void> _checkAdminAccess() async {
  final currentUser = await AuthService.currentUser();
  if (currentUser == null || !currentUser.isAdmin) {
    // Redirect and show error
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin access required')),
    );
  }
}
```

## Adding More Admins

To make other users admins:

### Option 1: Database Direct Edit
Edit the Hive box directly in code:
```dart
final usersBox = Hive.box('users');
// Find the user and set isAdmin to true
final userMap = usersBox.getAt(userIndex) as Map;
userMap['isAdmin'] = true;
await usersBox.putAt(userIndex, userMap);
```

### Option 2: Admin Management Screen (Future)
Create a profile settings screen where admins can:
- Promote/demote users
- Manage access levels
- Audit access logs

### Option 3: Seed More Admins
Add to `AuthService.seedTestUsers()`:
```dart
{
  'username': 'superadmin',
  'password': 'SuperAdmin@123',
  'email': 'superadmin@example.com',
  'isBusiness': false,
  'businessName': null,
  'isAdmin': true,  // Add this
},
```

## Testing

### Test Admin Access
1. Login with `admin` / `Admin@123`
2. Go to Help Articles
3. Click "Admin: Currency Conversion" button (purple)
4. Should display 3-tab documentation screen

### Test Non-Admin Access
1. Login with `testuser` / `Test@1234`
2. Go to Help Articles
3. No admin button should appear
4. If trying to access route directly, should be redirected

### Test Documentation Tabs
In admin screen, verify each tab loads:
- **Overview:** Shows features and benefits
- **Implementation:** Shows code examples
- **API Reference:** Shows method documentation

## Documentation Content

### Overview Tab Contains
- Feature summary and description
- Key features bullet list
- Exchange rate configuration (with code)
- User benefits (4 categories)
- Files created/modified reference

### Implementation Tab Contains
- 4 integration steps
- CIT calculator code example
- Integration checklist for all 6 calculators
- Integration time estimates
- Ready-to-use code snippets

### API Reference Tab Contains
- 5 method cards with:
  - Method name
  - Parameters
  - Return type
  - Description
- Widget constructor signatures
- Usage examples with copy-paste code blocks
- Exchange rate configuration

## Accessing from Code

Developers can also access the admin screen programmatically:

```dart
// Navigate to admin documentation
Navigator.pushNamed(context, '/help/admin/currency-conversion');
```

Or use a button in any admin panel:
```dart
ElevatedButton(
  onPressed: () => Navigator.pushNamed(
    context,
    '/help/admin/currency-conversion',
  ),
  child: const Text('View Currency Conversion Docs'),
),
```

## Future Enhancements

### Phase 2
- [ ] Admin dashboard for user management
- [ ] Audit logs of documentation access
- [ ] In-app code editor for documentation
- [ ] Export documentation as PDF

### Phase 3
- [ ] Multiple admin roles (SuperAdmin, Developer, Moderator)
- [ ] Role-based documentation access
- [ ] Feature flags for documentation visibility
- [ ] Version history for documentation

## Security Best Practices

✅ **Current Implementation**
- Admin status stored in Hive database
- Authentication checked on screen load
- Non-admins automatically redirected
- Error feedback with SnackBar

✅ **For Production**
- Add audit logging for admin access
- Implement admin activity monitoring
- Use time-limited access tokens
- Add two-factor authentication for admins
- Encrypt sensitive admin data

## Support

For questions about admin documentation access:
1. Check this guide
2. Review `currency_conversion_admin_screen.dart`
3. Check `AuthService.currentUser()` implementation
4. Review Hive user model storage

---

**Status:** ✅ Ready for Use  
**Last Updated:** December 2025  
**Admin Account:** admin / Admin@123
