import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // Brand Colors (From Logo)
  // ---------------------------------------------------------------------------
  static const Color _brandMagenta = Color(0xFFD6368F);
  static const Color _brandCyan = Color(0xFF26C6DA);

  // ---------------------------------------------------------------------------
  // Compatibility
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color lightBlue = _brandCyan;
  static const Color darkBlue = Color(0xFF0097A7);
  static const Color background = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Light Mode - Clean White
  // ---------------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),

    colorScheme: const ColorScheme.light(
      primary: _brandMagenta,
      secondary: _brandCyan,
      surface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
      outline: Color(0xFFE0E0E0),
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
      bodyMedium: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
      titleLarge: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandMagenta,
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: _brandMagenta.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _brandCyan,
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 4,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandMagenta, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Color(0xFF757575)),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF424242)),
  );

  // ---------------------------------------------------------------------------
  // Dark Mode - Teal Theme (#14383d base)
  // ---------------------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF14383d), // User's teal color

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4DD0E1), // Light cyan for buttons
      secondary: Color(0xFF80DEEA), // Lighter cyan accent
      surface: Color(0xFF1a4a50), // Slightly lighter teal for cards
      surfaceContainerHighest: Color(
        0xFF225861,
      ), // Even lighter for elevated cards
      onPrimary: Color(0xFF003135), // Dark teal text on primary
      onSecondary: Color(0xFF003135), // Dark teal text on secondary
      onSurface: Color(0xFFE0F2F1), // Very light cyan-tinted white
      outline: Color(0xFF26555b), // Teal border
    ),

    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          bodyLarge: const TextStyle(color: Color(0xFFE0F2F1), fontSize: 16),
          bodyMedium: const TextStyle(color: Color(0xFFB2DFDB), fontSize: 14),
          titleLarge: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: const TextStyle(
            color: Color(0xFFE0F2F1),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF14383d),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4DD0E1), // Light cyan
        foregroundColor: const Color(0xFF003135), // Dark teal text
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF80DEEA), // Lighter cyan
      foregroundColor: Color(0xFF003135), // Dark teal
      elevation: 4,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1a4a50),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF26555b)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF26555b)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4DD0E1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Color(0xFF80CBC4)),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF80DEEA)),
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_brandMagenta, Color(0xFFE91E8C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [_brandCyan, Color(0xFF00ACC1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [_brandMagenta, _brandCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Teal gradient for dark mode
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF14383d), Color(0xFF1a4a50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
