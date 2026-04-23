import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE ACCENT COLOR — Cyber Blue
// Used for ALL interactive elements across the app.
// ─────────────────────────────────────────────────────────────────────────────
const Color kAccent = Color(0xFF00B0FF); // Light Blue A400
const Color kAccentDim = Color(0xFF0091EA); // Pressed / dark-mode variant

// ── Semantic Colors (constant across themes) ─────────────────────────────────
const Color kCorrect = Color(0xFF66BB6A); // Green 400
const Color kWrong = Color(0xFFEF5350); // Red 400
const Color kWarning = Color(0xFFFFCA28); // Amber 400

// ─────────────────────────────────────────────────────────────────────────────
// DARK THEME PALETTE
// ─────────────────────────────────────────────────────────────────────────────
const Color kDarkBg = Color(0xFF0D1117);
const Color kDarkSurface = Color(0xFF161B22);
const Color kDarkCard = Color(0xFF1C2128);
const Color kDarkBorder = Color(0xFF30363D);
const Color kDarkTextPrimary = Color(0xFFE6EDF3);
const Color kDarkTextSecondary = Color(0xFF8B949E);

// ─────────────────────────────────────────────────────────────────────────────
// LIGHT THEME PALETTE
// ─────────────────────────────────────────────────────────────────────────────
const Color kLightBg = Color(0xFFF6F8FA);
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightCard = Color(0xFFFFFFFF);
const Color kLightBorder = Color(0xFFD0D7DE);
const Color kLightTextPrimary = Color(0xFF1F2328);
const Color kLightTextSecondary = Color(0xFF656D76);

// ─────────────────────────────────────────────────────────────────────────────
// THEME NOTIFIER — provides dark/light toggle with persistence
// ─────────────────────────────────────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  static const String _key = 'dark_mode_enabled';

  ThemeMode _mode = ThemeMode.dark; // default: dark (cybersecurity aesthetic)
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeNotifier() {
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(_key) ?? true; // default dark
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  // ── ThemeData builders ─────────────────────────────────────────────────────

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDarkBg,
        canvasColor: kDarkBg,
        cardColor: kDarkCard,
        dividerColor: kDarkBorder,
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          secondary: kAccent,
          surface: kDarkSurface,
          error: kWrong,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkBg,
          foregroundColor: kDarkTextPrimary,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: kDarkTextSecondary),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kDarkTextPrimary),
          bodyMedium: TextStyle(color: kDarkTextSecondary),
        ),
        useMaterial3: true,
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: kLightBg,
        canvasColor: kLightBg,
        cardColor: kLightCard,
        dividerColor: kLightBorder,
        colorScheme: const ColorScheme.light(
          primary: kAccent,
          secondary: kAccent,
          surface: kLightSurface,
          error: kWrong,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kLightBg,
          foregroundColor: kLightTextPrimary,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: kLightTextSecondary),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kLightTextPrimary),
          bodyMedium: TextStyle(color: kLightTextSecondary),
        ),
        useMaterial3: true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CONVENIENCE EXTENSION — quick access to theme-aware colors in any widget
// ─────────────────────────────────────────────────────────────────────────────
extension QuizTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? kDarkBg : kLightBg;
  Color get surface => isDark ? kDarkSurface : kLightSurface;
  Color get card => isDark ? kDarkCard : kLightCard;
  Color get border => isDark ? kDarkBorder : kLightBorder;
  Color get textPrimary => isDark ? kDarkTextPrimary : kLightTextPrimary;
  Color get textSecondary => isDark ? kDarkTextSecondary : kLightTextSecondary;
  Color get accent => kAccent;
}
