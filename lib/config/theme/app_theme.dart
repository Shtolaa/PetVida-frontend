import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // === Primary (Verdes) ===
  static const Color primary100 = Color(0xFFE3EFC6);
  static const Color primary200 = Color(0xFFC8DF8D);
  static const Color primary300 = Color(0xFFAED058);
  static const Color primary400 = Color(0xFF8EB232); 
  static const Color primary500 = Color(0xFF647E23);

  // === Secondary (Turquesas) ===
  static const Color secondary100 = Color(0xFF74FFEA);
  static const Color secondary400 = Color(0xFF00A28A);

  // === Neutral (Grises) ===
  static const Color neutral100 = Color(0xFFFFFFFF); // Blanco puro
  static const Color neutral200 = Color(0xFFE8E8E8); // Fondos suaves
  static const Color neutral300 = Color(0xFFD2D2D2); // Bordes deshabilitados
  static const Color neutral500 = Color(0xFF4A4A4A); // Textos secundarios
  static const Color neutral1000 = Color(0xFF333333); // Textos principales

  // === Feedback Colors ===
  static const Color error = Color(0xFFFB3748);      // Red 200
  static const Color warning = Color(0xFFFFDB43);    // Yellow 200
  static const Color success = Color(0xFF1FC16B);    // Green 200
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      
      // Paleta de colores base
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary400,
        primary: AppColors.primary400,
        secondary: AppColors.secondary400,
        surface: AppColors.neutral100, // Fondo de tarjetas
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      
      scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Gris  sutil para el fondo general

      // === TIPOGRAFÍA ===
    
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.neutral1000), // H1
        displayMedium: GoogleFonts.nunito(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.neutral1000), // H2
        displaySmall: GoogleFonts.nunito(
          fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral1000), // H3
        headlineMedium: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.neutral1000), // H4
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.neutral500), // Body 1
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.neutral500), // Body 2
      ),

      // === INPUTS ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        hintStyle: TextStyle(color: AppColors.neutral300),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary400, width: 2),
        ),
      ),

      // === BOTONES ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary400,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Bordes muy redondeados (Pill shape)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0, // Diseño plano
        ),
      ),
    );
  }
}