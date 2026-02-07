import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Theme service that persists user's theme preference via Hive.
///
/// Wire this into the app via ChangeNotifierProvider. The light/dark
/// theme definitions live in [TaxNGTheme] — this service only manages
/// the selected [ThemeMode].
class ThemeService extends ChangeNotifier {
  static const String _themeBoxName = 'theme_settings';
  static const String _themeModeKey = 'theme_mode';

  late Box _box;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initialize() async {
    _box = await Hive.openBox(_themeBoxName);
    final savedMode = _box.get(_themeModeKey, defaultValue: 'light');
    _themeMode = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _box.put(
        _themeModeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
