import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF93C5FD);

  static const Color pastelPink = Color(0xFFFADADD);
  static const Color pastelPinkDark = Color(0xFFF5B8C0);
  static const Color pastelTeal = Color(0xFF88D8C0);
  static const Color pastelTealDark = Color(0xFF5EC4A8);
  static const Color pastelPurple = Color(0xFFA29BFE);
  static const Color pastelOrange = Color(0xFFFFB347);

  static const Color primary = primaryBlue;
  static const Color primaryLight = primaryBlueLight;
  static const Color primaryDark = primaryBlueDark;

  static const Color accent = pastelPinkDark;
  static const Color accentAlt = pastelPink;

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color coin = Color(0xFFFFD93D);

  static const Color trueBlack = Color(0xFF0F172A);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkNavBar = Color(0xFF1E293B);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlueLight, primaryBlue],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF60A5FA), primaryBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0), Color(0xFF86EFAC)],
  );

  static const List<Color> categoryPalette = [
    primaryBlue,
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];

  static const List<Color> countdownColors = [
    Color(0xFFFCE7F3),
    Color(0xFFDBEAFE),
    Color(0xFFEDE9FE),
    Color(0xFFFFEDD5),
    Color(0xFFD1FAE5),
    Color(0xFFFEF3C7),
  ];
}
