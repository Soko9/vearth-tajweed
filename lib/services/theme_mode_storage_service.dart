import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeStorageService {
  static const String _themeModeKey = 'tajweed_theme_mode_v1';
  static const String _lightValue = 'light';
  static const String _darkValue = 'dark';

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    switch (raw) {
      case _darkValue:
        return ThemeMode.dark;
      case _lightValue:
      default:
        return ThemeMode.light;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _encode(mode));
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return _darkValue;
      case ThemeMode.light:
      case ThemeMode.system:
        return _lightValue;
    }
  }
}
