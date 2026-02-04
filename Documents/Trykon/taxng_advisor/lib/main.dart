import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:taxng_advisor/features/auth/presentation/login_screen.dart';
import 'package:taxng_advisor/features/auth/presentation/forgot_password_screen.dart';
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
import 'package:taxng_advisor/features/help/test_cases_admin_screen.dart';
import 'package:taxng_advisor/features/help/payment_guide_screen.dart';
import 'package:taxng_advisor/features/help/privacy_policy_screen.dart';
import 'package:taxng_advisor/features/payment/payment_history_screen.dart';
import 'package:taxng_advisor/features/subscription/upgrade_request_screen.dart';
import 'package:taxng_advisor/features/admin/admin_subscription_screen.dart';
import 'package:taxng_advisor/features/onboarding/presentation/welcome_screen.dart';
import 'package:taxng_advisor/features/tax_overview/tax_overview_screen.dart';
import 'package:taxng_advisor/features/templates/template_management_screen.dart';
import 'package:taxng_advisor/features/help/feedback_screen.dart';
import 'package:taxng_advisor/features/calendar/presentation/tax_calendar_screen.dart';
import 'package:taxng_advisor/features/history/presentation/calculation_history_screen.dart';
// Phase 3 - Nice-to-Have Features
import 'package:taxng_advisor/features/sharing/presentation/share_with_accountant_screen.dart';
import 'package:taxng_advisor/features/sharing/presentation/cpa_dashboard_screen.dart';
import 'package:taxng_advisor/features/expenses/presentation/expense_categories_screen.dart';
import 'package:taxng_advisor/features/settings/presentation/language_settings_screen.dart';
import 'package:taxng_advisor/features/settings/presentation/whatsapp_settings_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive database
    await HiveService.initialize();

    // Seed test users
    await AuthService.seedTestUsers();
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(const TaxNgApp());
}

class TaxNgApp extends StatelessWidget {
  const TaxNgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaxNG',
      theme: TaxNGTheme.lightTheme(),
      darkTheme: TaxNGTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
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
        '/help/admin/test-cases': (_) => const TestCasesAdminScreen(),
        '/help/payment-guide': (_) => const PaymentGuideScreen(isAdmin: false),
        '/help/admin/payment-guide': (_) =>
            const PaymentGuideScreen(isAdmin: true),
        '/help/privacy-policy': (_) => const PrivacyPolicyScreen(),
        '/payment/history': (_) => const PaymentHistoryScreen(),
        '/subscription/upgrade': (_) => const UpgradeRequestScreen(),
        '/admin/subscriptions': (_) => const AdminSubscriptionScreen(),
        '/vat': (_) => const VatCalculatorScreen(),
        '/pit': (_) => const PitCalculatorScreen(),
        '/cit': (_) => const CitCalculatorScreen(),
        '/wht': (_) => const WhtCalculatorScreen(),
        '/payroll': (_) => const PayrollCalculatorScreen(),
        '/stamp_duty': (_) => const StampDutyScreen(),
        '/reminders': (_) => const RemindersScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/tax-overview': (_) => const TaxOverviewScreen(),
        '/templates': (_) => const TemplateManagementScreen(),
        '/help/feedback': (_) => const FeedbackScreen(),
        '/calendar': (_) => const TaxCalendarScreen(),
        '/history': (_) => const CalculationHistoryScreen(),
        // Phase 3 - Nice-to-Have Features
        '/share': (_) => const ShareWithAccountantScreen(),
        '/cpa-dashboard': (_) => const CPADashboardScreen(),
        '/expenses': (_) => const ExpenseCategoriesScreen(),
        '/settings/language': (_) => const LanguageSettingsScreen(),
        '/settings/whatsapp': (_) => const WhatsAppSettingsScreen(),
      },
    );
  }
}
