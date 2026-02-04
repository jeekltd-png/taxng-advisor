/// Localization service for multi-language support
library;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Supported languages
enum AppLanguage {
  english,
  yoruba,
  igbo,
  hausa,
  pidgin,
}

/// Extension for AppLanguage
extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.yoruba:
        return 'yo';
      case AppLanguage.igbo:
        return 'ig';
      case AppLanguage.hausa:
        return 'ha';
      case AppLanguage.pidgin:
        return 'pcm';
    }
  }

  String get name {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.yoruba:
        return 'Yorùbá';
      case AppLanguage.igbo:
        return 'Igbo';
      case AppLanguage.hausa:
        return 'Hausa';
      case AppLanguage.pidgin:
        return 'Pidgin English';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.yoruba:
        return 'Èdè Yorùbá';
      case AppLanguage.igbo:
        return 'Asụsụ Igbo';
      case AppLanguage.hausa:
        return 'Harshen Hausa';
      case AppLanguage.pidgin:
        return 'Naija';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en', 'NG');
      case AppLanguage.yoruba:
        return const Locale('yo', 'NG');
      case AppLanguage.igbo:
        return const Locale('ig', 'NG');
      case AppLanguage.hausa:
        return const Locale('ha', 'NG');
      case AppLanguage.pidgin:
        return const Locale('pcm', 'NG');
    }
  }
}

class LocalizationService {
  static const String _settingsBox = 'localization_settings';
  static const String _currentLanguageKey = 'current_language';

  static AppLanguage _currentLanguage = AppLanguage.english;
  static final Map<String, Map<String, String>> _translations = {};

  /// Initialize localization service
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_settingsBox)) {
      await Hive.openBox(_settingsBox);
    }

    // Load saved language preference
    final box = Hive.box(_settingsBox);
    final savedLang = box.get(_currentLanguageKey, defaultValue: 'en');
    _currentLanguage = AppLanguage.values.firstWhere(
      (l) => l.code == savedLang,
      orElse: () => AppLanguage.english,
    );

    // Load all translations
    _loadTranslations();
  }

  /// Get current language
  static AppLanguage get currentLanguage => _currentLanguage;

  /// Get current locale
  static Locale get currentLocale => _currentLanguage.locale;

  /// Set language
  static Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;

    if (!Hive.isBoxOpen(_settingsBox)) {
      await Hive.openBox(_settingsBox);
    }
    final box = Hive.box(_settingsBox);
    await box.put(_currentLanguageKey, language.code);
  }

  /// Translate a key
  static String translate(String key) {
    final langCode = _currentLanguage.code;
    return _translations[langCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  /// Shorthand for translate
  static String t(String key) => translate(key);

  /// Translate with parameters
  static String translateWith(String key, Map<String, String> params) {
    String text = translate(key);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  /// Load all translations
  static void _loadTranslations() {
    // English translations
    _translations['en'] = {
      // Common
      'app_name': 'TaxNG',
      'welcome': 'Welcome',
      'hello': 'Hello',
      'goodbye': 'Goodbye',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'refresh': 'Refresh',
      'settings': 'Settings',
      'help': 'Help',
      'logout': 'Logout',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'phone': 'Phone Number',
      'submit': 'Submit',
      'continue': 'Continue',

      // Navigation
      'nav_home': 'Home',
      'nav_calculate': 'Calculate',
      'nav_history': 'History',
      'nav_profile': 'Profile',
      'nav_more': 'More',

      // Tax Types
      'tax_vat': 'Value Added Tax (VAT)',
      'tax_cit': 'Company Income Tax',
      'tax_pit': 'Personal Income Tax',
      'tax_wht': 'Withholding Tax',
      'tax_payroll': 'Payroll/PAYE Tax',
      'tax_stamp_duty': 'Stamp Duty',

      // Calculator
      'calc_title': 'Tax Calculator',
      'calc_amount': 'Amount',
      'calc_rate': 'Tax Rate',
      'calc_result': 'Tax Amount',
      'calc_net': 'Net Amount',
      'calc_gross': 'Gross Amount',
      'calc_calculate': 'Calculate',
      'calc_clear': 'Clear',
      'calc_save': 'Save Calculation',
      'calc_export': 'Export',
      'calc_share': 'Share',

      // Deadlines
      'deadline_upcoming': 'Upcoming Deadlines',
      'deadline_overdue': 'Overdue',
      'deadline_today': 'Due Today',
      'deadline_days_left': '{days} days left',
      'deadline_reminder': 'Reminder Set',

      // Currency
      'currency_ngn': 'Nigerian Naira (₦)',
      'currency_usd': 'US Dollar (\$)',

      // Errors
      'error_network': 'Network error. Please check your connection.',
      'error_invalid_input': 'Invalid input. Please check and try again.',
      'error_required_field': 'This field is required',
      'error_invalid_email': 'Please enter a valid email address',
      'error_invalid_amount': 'Please enter a valid amount',

      // Success Messages
      'success_saved': 'Saved successfully',
      'success_deleted': 'Deleted successfully',
      'success_exported': 'Exported successfully',
      'success_shared': 'Shared successfully',

      // Sharing
      'share_title': 'Share with Accountant',
      'share_description': 'Share your calculations securely',
      'share_permission': 'Permission Level',
      'share_expiry': 'Link Expiry',
      'share_create': 'Create Share Link',
      'share_revoke': 'Revoke Access',

      // Expenses
      'expense_add': 'Add Expense',
      'expense_category': 'Category',
      'expense_amount': 'Amount',
      'expense_date': 'Date',
      'expense_description': 'Description',
      'expense_receipt': 'Receipt',
      'expense_deductible': 'Tax Deductible',

      // Profile
      'profile_title': 'Profile',
      'profile_business': 'Business Profile',
      'profile_personal': 'Personal Information',
      'profile_tax_info': 'Tax Information',
      'profile_tin': 'Tax Identification Number',
      'profile_cac': 'CAC Registration Number',

      // Subscription
      'subscription_free': 'Free',
      'subscription_basic': 'Basic',
      'subscription_pro': 'Pro',
      'subscription_business': 'Business',
      'subscription_upgrade': 'Upgrade',

      // Language
      'language_title': 'Language',
      'language_select': 'Select Language',
      'language_current': 'Current Language',
    };

    // Yoruba translations
    _translations['yo'] = {
      // Common
      'app_name': 'TaxNG',
      'welcome': 'Ẹ káàbọ̀',
      'hello': 'Báwo',
      'goodbye': 'Ó dàbọ̀',
      'yes': 'Bẹ́ẹ̀ni',
      'no': 'Bẹ́ẹ̀kọ́',
      'ok': 'Ó dára',
      'cancel': 'Fagilee',
      'save': 'Tọ́jú',
      'delete': 'Pa rẹ́',
      'edit': 'Ṣàtúnṣe',
      'close': 'Pa dé',
      'back': 'Padà',
      'next': 'Tẹ̀síwájú',
      'done': 'Parí',
      'loading': 'Ó ń gbé...',
      'error': 'Àṣìṣe',
      'success': 'Aṣeyọrí',
      'warning': 'Ìkìlọ̀',
      'info': 'Ìsọfúnni',
      'search': 'Ṣàwárí',
      'settings': 'Ètò',
      'help': 'Ìrànlọ́wọ́',
      'logout': 'Jáde',
      'login': 'Wọlé',
      'register': 'Forúkọsílẹ̀',
      'email': 'Ímeèlì',
      'password': 'Ọ̀rọ̀ aṣínà',
      'submit': 'Fi ránṣẹ́',

      // Navigation
      'nav_home': 'Ilé',
      'nav_calculate': 'Ṣírò',
      'nav_history': 'Ìtàn',
      'nav_profile': 'Àkọsílẹ̀',
      'nav_more': 'Sí i',

      // Tax Types
      'tax_vat': 'Owó Orí Tà (VAT)',
      'tax_cit': 'Owó Orí Ilé-iṣẹ́',
      'tax_pit': 'Owó Orí Ènìyàn',
      'tax_wht': 'Owó Orí Dídámú',
      'tax_payroll': 'Owó Orí Òṣìṣẹ́',
      'tax_stamp_duty': 'Owó Ẹ̀dà',

      // Calculator
      'calc_title': 'Ẹ̀rọ Ìṣírò Owó Orí',
      'calc_amount': 'Iye',
      'calc_rate': 'Ìwọ̀n Owó Orí',
      'calc_result': 'Iye Owó Orí',
      'calc_calculate': 'Ṣírò',
      'calc_clear': 'Pa rẹ́',

      // Deadlines
      'deadline_upcoming': 'Àsìkò tí ń bọ̀',
      'deadline_overdue': 'Ti kọjá',
      'deadline_today': 'Lónìí',
      'deadline_days_left': 'Ọjọ́ {days} kù',

      // Currency
      'currency_ngn': 'Náírà (₦)',

      // Errors
      'error_network': 'Ìṣòro nẹ́tíwọ̀ọ̀kì. Jọ̀wọ́ ṣàyẹ̀wò àsopọ̀ rẹ.',
      'error_required_field': 'Apá yìí jẹ́ dandan',

      // Language
      'language_title': 'Èdè',
      'language_select': 'Yan Èdè',
    };

    // Igbo translations
    _translations['ig'] = {
      // Common
      'app_name': 'TaxNG',
      'welcome': 'Nnọọ',
      'hello': 'Ndewo',
      'goodbye': 'Ka ọ dị',
      'yes': 'Ee',
      'no': 'Mba',
      'ok': 'Ọ dị mma',
      'cancel': 'Kagbuo',
      'save': 'Chekwaa',
      'delete': 'Hichapụ',
      'edit': 'Dezie',
      'close': 'Mechie',
      'back': 'Laghachi',
      'next': 'Gaa n\'ihu',
      'done': 'Emechara',
      'loading': 'Ọ na-ebute...',
      'error': 'Njehie',
      'success': 'Ọ gara nke ọma',
      'warning': 'Ịdọ aka ná ntị',
      'info': 'Ozi',
      'search': 'Chọọ',
      'settings': 'Nhazi',
      'help': 'Enyemaka',
      'logout': 'Pụọ',
      'login': 'Banye',
      'register': 'Debanye aha',
      'email': 'Email',
      'password': 'Okwuntughe',
      'submit': 'Nyefee',

      // Navigation
      'nav_home': 'Ụlọ',
      'nav_calculate': 'Gbakọọ',
      'nav_history': 'Akụkọ',
      'nav_profile': 'Profaịlụ',
      'nav_more': 'Ọzọ',

      // Tax Types
      'tax_vat': 'Ụtụ Ahịa (VAT)',
      'tax_cit': 'Ụtụ Ụlọ Ọrụ',
      'tax_pit': 'Ụtụ Onwe',
      'tax_wht': 'Ụtụ Ewepụtara',
      'tax_payroll': 'Ụtụ Ụgwọ Ọrụ',
      'tax_stamp_duty': 'Ụtụ Akwụkwọ',

      // Calculator
      'calc_title': 'Ngwa Ọgụgụ Ụtụ',
      'calc_amount': 'Ego',
      'calc_rate': 'Ọnụego Ụtụ',
      'calc_result': 'Ego Ụtụ',
      'calc_calculate': 'Gbakọọ',
      'calc_clear': 'Hichapụ',

      // Language
      'language_title': 'Asụsụ',
      'language_select': 'Họrọ Asụsụ',
    };

    // Hausa translations
    _translations['ha'] = {
      // Common
      'app_name': 'TaxNG',
      'welcome': 'Barka da zuwa',
      'hello': 'Sannu',
      'goodbye': 'Sai anjima',
      'yes': 'Ee',
      'no': "A'a",
      'ok': 'To',
      'cancel': 'Soke',
      'save': 'Ajiye',
      'delete': 'Share',
      'edit': 'Gyara',
      'close': 'Rufe',
      'back': 'Koma',
      'next': 'Gaba',
      'done': 'An gama',
      'loading': 'Ana loda...',
      'error': 'Kuskure',
      'success': 'Nasara',
      'warning': 'Gargaɗi',
      'info': 'Bayani',
      'search': 'Bincika',
      'settings': 'Saiti',
      'help': 'Taimako',
      'logout': 'Fita',
      'login': 'Shiga',
      'register': 'Yi rajista',
      'email': 'Imel',
      'password': 'Kalmar sirri',
      'submit': 'Aika',

      // Navigation
      'nav_home': 'Gida',
      'nav_calculate': 'Lissafa',
      'nav_history': 'Tarihi',
      'nav_profile': 'Bayanan kai',
      'nav_more': 'Ƙari',

      // Tax Types
      'tax_vat': 'Haraji Kan Kaya (VAT)',
      'tax_cit': 'Harajin Kamfani',
      'tax_pit': 'Harajin Mutum',
      'tax_wht': 'Harajin Riƙe',
      'tax_payroll': 'Harajin Albashin',
      'tax_stamp_duty': 'Harajin Tambari',

      // Calculator
      'calc_title': 'Na\'urar Lissafin Haraji',
      'calc_amount': 'Adadi',
      'calc_rate': 'Farashin Haraji',
      'calc_result': 'Kuɗin Haraji',
      'calc_calculate': 'Lissafa',
      'calc_clear': 'Share',

      // Language
      'language_title': 'Harshe',
      'language_select': 'Zaɓi Harshe',
    };

    // Pidgin translations
    _translations['pcm'] = {
      // Common
      'app_name': 'TaxNG',
      'welcome': 'Welcome o!',
      'hello': 'How far',
      'goodbye': 'We go see',
      'yes': 'Yes o',
      'no': 'No be so',
      'ok': 'E dey okay',
      'cancel': 'Cancel am',
      'save': 'Save am',
      'delete': 'Delete am',
      'edit': 'Change am',
      'close': 'Close am',
      'back': 'Go back',
      'next': 'Go front',
      'done': 'E don finish',
      'loading': 'E dey load...',
      'error': 'Wahala don happen',
      'success': 'E don work!',
      'warning': 'Abeg take note',
      'info': 'Info wey you need',
      'search': 'Find am',
      'settings': 'Settings',
      'help': 'Help',
      'logout': 'Comot',
      'login': 'Enter',
      'register': 'Sign up',
      'email': 'Email',
      'password': 'Password',
      'submit': 'Submit am',

      // Navigation
      'nav_home': 'Home',
      'nav_calculate': 'Calculate',
      'nav_history': 'History',
      'nav_profile': 'Profile',
      'nav_more': 'More',

      // Tax Types
      'tax_vat': 'VAT Tax',
      'tax_cit': 'Company Tax',
      'tax_pit': 'Personal Tax',
      'tax_wht': 'Withholding Tax',
      'tax_payroll': 'Salary Tax',
      'tax_stamp_duty': 'Stamp Duty',

      // Calculator
      'calc_title': 'Tax Calculator',
      'calc_amount': 'How much',
      'calc_rate': 'Tax Rate',
      'calc_result': 'Tax wey you go pay',
      'calc_calculate': 'Calculate am',
      'calc_clear': 'Clear am',

      // Deadlines
      'deadline_upcoming': 'Wetin dey come',
      'deadline_overdue': 'E don pass time',
      'deadline_today': 'Today own',
      'deadline_days_left': '{days} days remain',

      // Errors
      'error_network': 'Network get problem. Abeg check your connection.',
      'error_required_field': 'You must fill this one',

      // Language
      'language_title': 'Language',
      'language_select': 'Choose Language',
    };
  }

  /// Format currency based on locale
  static String formatCurrency(double amount, {String currency = 'NGN'}) {
    final symbol = currency == 'NGN' ? '₦' : '\$';
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$symbol$formatted';
  }

  /// Format date based on locale
  static String formatDate(DateTime date) {
    // Simple format for now, can be expanded with intl package
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format number based on locale
  static String formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Get all supported languages
  static List<AppLanguage> get supportedLanguages => AppLanguage.values;

  /// Check if language is supported
  static bool isSupported(String code) {
    return AppLanguage.values.any((l) => l.code == code);
  }

  /// Get language by code
  static AppLanguage? getLanguageByCode(String code) {
    try {
      return AppLanguage.values.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }
}

/// Shorthand function for translation
String tr(String key) => LocalizationService.translate(key);

/// Shorthand function for translation with params
String trWith(String key, Map<String, String> params) =>
    LocalizationService.translateWith(key, params);
