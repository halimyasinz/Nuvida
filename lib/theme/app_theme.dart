import 'package:flutter/material.dart';

class AppTheme {
  // Açık Tema Renkleri
  static const Color primaryIndigo = Color(0xFF3F51B5);      // Ana Renk
  static const Color backgroundGhostWhite = Color(0xFFF8F9FF); // Ana Arka Plan
  static const Color cardBackground = Color(0xFFF4F6FA);     // Kart/Sekme Arka Planı
  static const Color textPrimary = Color(0xFF212121);        // Ana Metin
  static const Color textSecondary = Color(0xFF333333);      // İkincil Metin (daha koyu)
  static const Color accentBlue = Color(0xFF2196F3);         // Vurgu
  static const Color actionAmber = Color(0xFFFFC107);        // Aksiyon/İkincil
  static const Color successGreen = Color(0xFF43A047);       // Başarı/Olumlu
  static const Color warningRed = Color(0xFFE53935);         // Uyarı/Olumsuz
  static const Color goalLavender = Color(0xFF8E99F3);       // Hedef/Alışkanlık Tonu

  // Koyu Tema Renkleri
  static const Color darkBackground = Color(0xFF121212);     // Ana Zemin
  static const Color darkCardBackground = Color(0xFF1E1E2F); // Modül/Kartlar
  static const Color darkTextPrimary = Color(0xFFECEFF1);    // Ana Yazılar
  static const Color darkTextSecondary = Color(0xFFB0BEC5);  // Yardımcı Metin
  static const Color darkAccentBlue = Color(0xFF64B5F6);     // Hover Efektleri
  static const Color darkSuccessGreen = Color(0xFF81C784);   // Başarı Bildirimleri
  static const Color darkWarningRed = Color(0xFFEF5350);     // Hata Bildirimleri
  static const Color darkGoalLavender = Color(0xFFB3B8F9);  // Hedef & Alışkanlıklar

  // Eski renkler için alias'lar (geriye uyumluluk)
  static const Color primaryPurple = primaryIndigo;
  static const Color textLight = textPrimary;
  static const Color lightPurple = goalLavender;
  static const Color highRisk = warningRed;
  static const Color mediumRisk = actionAmber;
  static const Color lowRisk = successGreen;
  static const Color success = successGreen;
  static const Color danger = warningRed;
  static const Color warning = actionAmber;
  static const Color info = accentBlue;
  static const Color primaryBlue = accentBlue;
  static const Color secondaryPurple = goalLavender;
  static const Color divider = Color(0xFFE0E0E0);
  
  // Event kategorileri için renkler
  static const Color clubEvent = primaryIndigo;      // Mor/Indigo
  static const Color academicEvent = successGreen;   // Yeşil
  static const Color socialEvent = actionAmber;      // Turuncu

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Açık Tema
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryIndigo,
        secondary: goalLavender,
        surface: cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        error: warningRed,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundGhostWhite,
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        shadowColor: const Color(0x1A000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryIndigo,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: primaryIndigo, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
    );
  }

  // Koyu Tema
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryIndigo,
        secondary: darkGoalLavender,
        surface: darkCardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        error: darkWarningRed,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        shadowColor: const Color(0x1A000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkAccentBlue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: primaryIndigo, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
      ),
    );
  }
}
