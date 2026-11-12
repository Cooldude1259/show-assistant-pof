import 'package:flutter/material.dart';

/// Backstage palette.
///
/// Backstage runs under blue work lights, which wash out blues and purples and
/// make dim greys hard to read. So: true black, pure white text, and only
/// bright warm/green signal colours. Nothing important is blue.
class Backstage {
  static const black = Color(0xFF000000);
  static const surface = Color(0xFF0E0E0E);
  static const surfaceHigh = Color(0xFF1C1C1C);
  static const border = Color(0xFF4A4A4A);
  static const text = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFFD6D6D6); // still bright: no 50% greys
  static const accent = Color(0xFFFFD400); // signal yellow
  static const standby = Color(0xFFFFA000); // amber
  static const go = Color(0xFF00E676); // green
  static const danger = Color(0xFFFF5252);
}

ThemeData backstageTheme() {
  const scheme = ColorScheme.dark(
    primary: Backstage.accent,
    onPrimary: Backstage.black,
    secondary: Backstage.accent,
    onSecondary: Backstage.black,
    secondaryContainer: Color(0xFF3D3300),
    onSecondaryContainer: Backstage.accent,
    surface: Backstage.surface,
    onSurface: Backstage.text,
    error: Backstage.danger,
    onError: Backstage.black,
    outline: Backstage.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Backstage.black,
    dividerColor: Backstage.border,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: Backstage.text, displayColor: Backstage.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: Backstage.black,
      foregroundColor: Backstage.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Backstage.surfaceHigh,
      labelStyle: const TextStyle(color: Backstage.textMuted),
      prefixIconColor: Backstage.textMuted,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Backstage.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Backstage.accent, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Audience palette: a printed-programme look. Dark (it's used in a dark
/// auditorium) but warm, with serif headings, so it feels like its own app.
class Playbill {
  static const bg = Color(0xFF12060A);
  static const panel = Color(0xFF220C12);
  static const panelHigh = Color(0xFF2E1018);
  static const curtain = Color(0xFF7A1424);
  static const gold = Color(0xFFF5C76B);
  static const cream = Color(0xFFFFF5E6);
  static const muted = Color(0xFFE6D3BC);
  static const line = Color(0xFF6B3A44);

  /// Built into iOS, so no font package needed.
  static const serif = 'Georgia';
}

ThemeData playbillTheme() {
  const scheme = ColorScheme.dark(
    primary: Playbill.gold,
    onPrimary: Playbill.bg,
    secondary: Playbill.curtain,
    onSecondary: Playbill.cream,
    surface: Playbill.panel,
    onSurface: Playbill.cream,
    error: Color(0xFFFF8A80),
    onError: Playbill.bg,
    outline: Playbill.line,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Playbill.bg,
    dividerColor: Playbill.line,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: Playbill.cream, displayColor: Playbill.cream),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Playbill.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Playbill.panel,
      hintStyle: const TextStyle(color: Playbill.line),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Playbill.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Playbill.gold, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
