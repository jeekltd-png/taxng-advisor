import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:taxng_advisor/features/auth/presentation/login_screen.dart';
import 'package:taxng_advisor/features/profile/presentation/profile_screen.dart';
import 'package:taxng_advisor/features/vat/presentation/vat_calculator_screen.dart';
import 'package:taxng_advisor/features/pit/presentation/pit_calculator_screen.dart';
import 'package:taxng_advisor/features/cit/presentation/cit_calculator_screen.dart';
import 'package:taxng_advisor/features/wht/presentation/wht_calculator_screen.dart';
import 'package:taxng_advisor/features/payroll/presentation/payroll_calculator_screen.dart';
import 'package:taxng_advisor/features/stamp_duty/presentation/stamp_duty_screen.dart';
import 'package:taxng_advisor/features/reminders/presentation/reminders_screen.dart';
import 'package:taxng_advisor/features/debug/presentation/debug_users_screen.dart';
import 'package:taxng_advisor/features/help/faq_screen.dart';
import 'package:taxng_advisor/features/help/help_articles_screen.dart';
import 'package:taxng_advisor/features/help/contact_support_screen.dart';
import 'package:taxng_advisor/features/help/sample_data_screen.dart';
import 'package:taxng_advisor/features/help/currency_conversion_admin_screen.dart';
import 'package:taxng_advisor/features/help/pricing_screen.dart';
import 'package:taxng_advisor/features/help/admin_pricing_editor_screen.dart';
import 'package:taxng_advisor/features/help/admin_deployment_guide_screen.dart';
import 'package:taxng_advisor/features/help/admin_user_testing_guide_screen.dart';
import 'package:taxng_advisor/features/help/admin_csv_excel_guide_screen.dart';
import 'package:taxng_advisor/features/help/payment_guide_screen.dart';
import 'package:taxng_advisor/features/help/privacy_policy_screen.dart';
import 'package:taxng_advisor/features/payment/payment_history_screen.dart';
import 'package:taxng_advisor/features/pit/services/pit_storage_service.dart';
import 'package:taxng_advisor/services/pricing_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/vat/services/vat_storage_service.dart';
import 'package:taxng_advisor/features/cit/services/cit_storage_service.dart';
import 'package:taxng_advisor/services/reminder_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/services/sync_service.dart';
import 'package:taxng_advisor/services/encryption_service.dart';

/// Application entry point
///
/// This initializes lightweight services required at startup. For web
/// builds some platform-specific services (e.g. Hive desktop adapters)
/// may be skipped or adjusted. The initialization order is:
/// 1. Encryption service (so secure storage helpers are ready)
/// 2. Hive (boxes) initialization
/// 3. Sync listener initialization (non-blocking)
/// 4. Legacy feature initializers (feature-scoped persistence)
/// 5. Reminders and other scheduled tasks
/// 6. Seed development/test users (safe to skip in production)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize encryption helpers (non-blocking)
  EncryptionService.initialize();

  // Initialize unified Hive service (open named boxes used by the app)
  // Hive is used for local persistence; on web this will use hive_flutter's
  // in-memory/web-backed boxes. Ensure this completes before using boxes.
  await HiveService.initialize();

  // Initialize sync service and attach connectivity listener. The listener
  // runs in the background and will not block startup; network checks are
  // performed asynchronously by the listener.
  SyncService.initializeSyncListener();

  // Legacy per-feature initializers (keep for backward compatibility).
  // These will ensure any older storage formats are ready to use.
  await PitStorageService.init();
  await VatStorageService.init();
  await CitStorageService.init();

  // Initialize pricing service (for monetization)
  await PricingService.init();

  // Initialize payment service
  await PaymentService.init();

  // Initialize reminder scheduling (local notifications).
  await ReminderService.init();
  await ReminderService.scheduleAllDefaultReminders();

  // Seed test users for local development (non-blocking). This call is
  // safe to leave in dev builds but should be gated or removed in
  // production to avoid injecting test accounts.
  try {
    await AuthService.seedTestUsers();
    print('✅ Seeded test users');
  } catch (e) {
    print('⚠️ Skipped seeding test users: $e');
  }

  runApp(const TaxNgApp());
}

class TaxNgApp extends StatelessWidget {
  const TaxNgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaxNG Advisor',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/debug/users': (_) => const DebugUsersScreen(),
        '/help/faq': (_) => const FaqScreen(),
        '/help/articles': (_) => const HelpArticlesScreen(),
        '/help/contact': (_) => const ContactSupportScreen(),
        '/help/sample-data': (_) => const SampleDataScreen(),
        '/help/pricing': (_) => const PricingScreen(),
        '/help/admin/pricing': (_) => const AdminPricingEditorScreen(),
        '/help/admin/currency-conversion': (_) =>
            const CurrencyConversionAdminScreen(),
        '/help/admin/deployment': (_) => const AdminDeploymentGuideScreen(),
        '/help/admin/user-testing': (_) => const AdminUserTestingGuideScreen(),
        '/help/admin/csv-excel': (_) => const AdminCsvExcelGuideScreen(),
        '/help/payment-guide': (_) => const PaymentGuideScreen(isAdmin: false),
        '/help/admin/payment-guide': (_) =>
            const PaymentGuideScreen(isAdmin: true),
        '/help/privacy-policy': (_) => const PrivacyPolicyScreen(),
        '/payment/history': (_) => const PaymentHistoryScreen(),
        '/vat': (_) => const VatCalculatorScreen(),
        '/pit': (_) => const PitCalculatorScreen(),
        '/cit': (_) => const CitCalculatorScreen(),
        '/wht': (_) => const WhtCalculatorScreen(),
        '/payroll': (_) => const PayrollCalculatorScreen(),
        '/stamp_duty': (_) => const StampDutyScreen(),
        '/reminders': (_) => const RemindersScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
