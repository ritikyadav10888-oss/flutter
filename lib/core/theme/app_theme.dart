import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Aura Sports - Expressive Premium Palette
  static const Color primaryIndigo = Color(0xFF4F46E5); // Electric Indigo
  static const Color secondarySky = Color(0xFF0EA5E9); // Sky Blue
  static const Color accentCoral = Color(0xFFFB7185); // Coral Accent
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);

  // Surface Tones
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundAura = Color(0xFFF5F7FF); // Light Indigo Tint
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(
    0xFFF8FAFC,
  ); // Restored for compatibility
  static const Color textMain = Color(0xFF0F172A); // Slate 900
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color borderSoft = Color(0xFFE2E8F0);

  // Backward compatibility aliases
  static const Color accentTeal = secondarySky;
  static const Color secondaryBlue = secondarySky;
  static const Color successEmerald = successGreen;
  static const Color tertiaryAmber = warningAmber;
  static const Color textDark = textMain;
  static const Color borderLight = borderSoft;

  // Aura Geometry & Motion
  static const double radiusXL = 32.0;
  static const double radiusLG = 24.0;
  static const double radiusMD = 16.0;
  static const double auraPadding = 24.0;
  static const double sectionGap = 32.0;

  // Ambient Aura Shadows
  static List<BoxShadow> get ambientShadow => [
    BoxShadow(
      color: primaryIndigo.withOpacity(0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: textMain.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: textMain.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  // Compatibility constants
  static List<BoxShadow> get softShadow => ambientShadow;
  static const double borderRadius = radiusXL;
  static const double cardPadding = auraPadding;
  static const double sectionSpacing = sectionGap;

  // Responsive Constants
  static const double maxContentWidth = 1200.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  // Backward compatibility alias for darkTheme
  // (User requested White theme, so we use lightTheme as a safe placeholder)
  static ThemeData get darkTheme => lightTheme;

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: isLight
          ? backgroundWhite
          : textDark, // Example for dark mode
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryIndigo,
        primary: primaryIndigo,
        secondary: accentTeal,
        tertiary: warningAmber,
        surface: backgroundWhite,
        onSurface: textMain,
        surfaceContainerLow: backgroundAura,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.syne(
            color: textMain,
            fontSize: 48,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
          displayMedium: GoogleFonts.syne(
            color: textMain,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          titleLarge: const TextStyle(
            color: textMain,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: const TextStyle(
            color: textMain,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: const TextStyle(
            color: textMain,
            fontSize: 17,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: const TextStyle(
            color: textMuted,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundAura,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: borderSoft, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: primaryIndigo, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 22,
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: textMuted),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(color: borderSoft, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  // Soft Glassmorphism effect helper for White Theme
  static BoxDecoration glassDecoration({
    Color color = Colors.white,
    double opacity = 0.8,
    double blur = 20.0,
    double radius = 24.0,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderSoft.withOpacity(0.5), width: 1),
    );
  }
}
