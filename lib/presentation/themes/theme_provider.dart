import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Key untuk menyimpan tema di SharedPreferences
  static const String _themeKey = "theme";

  // Variabel untuk menyimpan tema saat ini
  ThemeMode _themeMode = ThemeMode.system;

  // Getter untuk tema saat ini
  ThemeMode get themeMode => _themeMode;

  // Constructor
  ThemeProvider() {
    _loadTheme();
  }

  // Method untuk memuat tema dari SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _themeMode = savedTheme == "dark" ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  // Method untuk mengganti tema
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Simpan tema ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, isDark ? "dark" : "light");
  }
}
