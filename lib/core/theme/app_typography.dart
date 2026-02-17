import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema de tipografía de FutBase 3.0
///
/// Basado en Lexend (Google Fonts) - fuente del diseño oficial
/// Excelente legibilidad y diseño moderno para aplicaciones deportivas
class AppTypography {
  // ========== FAMILIA DE FUENTES ==========

  /// Fuente principal - Lexend
  static String get fontFamily => GoogleFonts.lexend().fontFamily!;

  /// Fuente para títulos - Lexend Bold
  static String get headingFontFamily => GoogleFonts.lexend().fontFamily!;

  /// Fuente monoespaciada - JetBrains Mono (para códigos/números)
  static String get monoFontFamily => GoogleFonts.jetBrainsMono().fontFamily!;

  // ========== TÍTULOS (HEADINGS) ==========

  /// H1 - Título principal (Hero sections)
  /// Uso: Títulos de landing, headers principales
  static TextStyle get h1 => GoogleFonts.lexend(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
      );

  /// H2 - Título secundario
  /// Uso: Títulos de secciones importantes
  static TextStyle get h2 => GoogleFonts.lexend(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
      );

  /// H3 - Título terciario
  /// Uso: Subtítulos de secciones
  static TextStyle get h3 => GoogleFonts.lexend(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// H4 - Título de componentes
  /// Uso: Títulos de cards, modales
  static TextStyle get h4 => GoogleFonts.lexend(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  /// H5 - Subtítulo de componentes
  /// Uso: Subtítulos en cards
  static TextStyle get h5 => GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  /// H6 - Título pequeño
  /// Uso: Headers de listas, tabs
  static TextStyle get h6 => GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // ========== CUERPO DE TEXTO (BODY) ==========

  /// Body Large - Texto principal grande
  /// Uso: Párrafos destacados, introducciones
  static TextStyle get bodyLarge => GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  /// Body Medium - Texto principal
  /// Uso: Contenido principal, descripciones
  static TextStyle get bodyMedium => GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  /// Body Small - Texto secundario
  /// Uso: Notas, textos de apoyo
  static TextStyle get bodySmall => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  // ========== LABELS Y BOTONES ==========

  /// Label Large - Etiquetas grandes
  /// Uso: Labels en formularios, botones grandes
  static TextStyle get labelLarge => GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  /// Label Medium - Etiquetas medianas
  /// Uso: Botones, badges, chips
  static TextStyle get labelMedium => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  /// Label Small - Etiquetas pequeñas
  /// Uso: Labels pequeños, tags
  static TextStyle get labelSmall => GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  // ========== CAPTION Y OVERLINE ==========

  /// Caption - Texto de ayuda
  /// Uso: Tooltips, hints, metadata
  static TextStyle get caption => GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: 0.25,
        color: AppColors.textSecondary,
      );

  /// Overline - Texto superior
  /// Uso: Categorías, etiquetas superiores
  static TextStyle get overline => GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 1.5,
        color: AppColors.textSecondary,
      ).copyWith(
        textBaseline: TextBaseline.alphabetic,
      );

  // ========== NÚMEROS Y ESTADÍSTICAS ==========

  /// Display - Números grandes
  /// Uso: Estadísticas, métricas importantes
  static TextStyle get display => GoogleFonts.lexend(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: -2.0,
        color: AppColors.primary,
      );

  /// Estadísticas medianas
  /// Uso: KPIs en dashboard
  static TextStyle get statLarge => GoogleFonts.lexend(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
      );

  /// Estadísticas pequeñas
  /// Uso: Números en cards
  static TextStyle get statMedium => GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// Número monoespaciado
  /// Uso: Códigos, timestamps, datos técnicos
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  // ========== BOTONES ==========

  /// Botón grande
  static TextStyle get buttonLarge => GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
        color: AppColors.backgroundDark,
      );

  /// Botón mediano
  static TextStyle get buttonMedium => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
        color: AppColors.backgroundDark,
      );

  /// Botón pequeño
  static TextStyle get buttonSmall => GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
        color: AppColors.backgroundDark,
      );

  // ========== ESTILOS ESPECIALES PARA DARK THEME ==========

  /// Texto secundario con color correcto para dark mode
  static TextStyle get bodySecondary => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  /// Texto de link/interactivo
  static TextStyle get link => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      );

  // ========== UTILIDADES ==========

  /// Obtener TextTheme completo para Material
  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        displayMedium: h1,
        displaySmall: h2,
        headlineLarge: h2,
        headlineMedium: h3,
        headlineSmall: h4,
        titleLarge: h5,
        titleMedium: h6,
        titleSmall: labelLarge,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  /// Obtener TextTheme para modo claro
  static TextTheme get textThemeLight => TextTheme(
        displayLarge: display.copyWith(color: AppColors.gray900),
        displayMedium: h1.copyWith(color: AppColors.gray900),
        displaySmall: h2.copyWith(color: AppColors.gray900),
        headlineLarge: h2.copyWith(color: AppColors.gray900),
        headlineMedium: h3.copyWith(color: AppColors.gray900),
        headlineSmall: h4.copyWith(color: AppColors.gray900),
        titleLarge: h5.copyWith(color: AppColors.gray900),
        titleMedium: h6.copyWith(color: AppColors.gray900),
        titleSmall: labelLarge.copyWith(color: AppColors.gray900),
        bodyLarge: bodyLarge.copyWith(color: AppColors.gray700),
        bodyMedium: bodyMedium.copyWith(color: AppColors.gray700),
        bodySmall: bodySmall.copyWith(color: AppColors.gray600),
        labelLarge: labelLarge.copyWith(color: AppColors.gray900),
        labelMedium: labelMedium.copyWith(color: AppColors.gray900),
        labelSmall: labelSmall.copyWith(color: AppColors.gray700),
      );
}
