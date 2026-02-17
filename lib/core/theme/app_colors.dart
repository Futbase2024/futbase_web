import 'package:flutter/material.dart';

/// Sistema de colores de FutBase 3.0
///
/// Paleta basada en el diseño oficial Stitch (landing page modo claro)
/// Primary: Verde oscuro #00554E (landing light mode)
/// Accent: Verde neón #a4ec13 (dashboard dark mode)
class AppColors {
  // ========== COLORES PRINCIPALES (STITCH LANDING LIGHT) ==========

  /// Color primario Landing (Stitch) - Verde oscuro #00554E
  static const Color primary = Color(0xFF00554E);
  static const Color primaryLight = Color(0xFF007A70);
  static const Color primaryDark = Color(0xFF00423D);

  /// Color accent - Verde neón #a4ec13 (para modo oscuro/dashboard)
  static const Color accent = Color(0xFFA4EC13);
  static const Color accentLight = Color(0xFFB8F52D);
  static const Color accentDark = Color(0xFF8BC410);

  /// Color primario modo claro (dashboard) - Verde oliva #6b7c4c
  static const Color primaryLightMode = Color(0xFF6B7C4C);
  static const Color primaryLightModeHover = Color(0xFF5A6840);

  /// Color secundario - Verde oscuro
  static const Color secondary = Color(0xFF4B543B);
  static const Color secondaryLight = Color(0xFF5F6A4A);
  static const Color secondaryDark = Color(0xFF3A412C);

  // ========== TEMA OSCURO (DARK MODE) ==========

  /// Fondo principal oscuro - #12140e
  static const Color backgroundDark = Color(0xFF12140E);

  /// Fondo oscuro alternativo - #1c2210
  static const Color surfaceDark = Color(0xFF1C2210);

  /// Fondo de cards oscuro - #23271c
  static const Color cardDark = Color(0xFF23271C);

  /// Fondo sidebar oscuro - #161811
  static const Color sidebarDark = Color(0xFF161811);

  /// Borde oscuro - #333928
  static const Color borderDark = Color(0xFF333928);

  /// Borde claro oscuro - #4b543b
  static const Color borderDarkLight = Color(0xFF4B543B);

  // ========== TEMA CLARO (LIGHT MODE) ==========

  /// Fondo principal claro - #ffffff (landing-blanco.html)
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Superficie clara - #f8fafc
  static const Color surfaceLight = Color(0xFFF8FAFC);

  /// Fondo de cards claro
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Borde claro - #e2e8f0
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Borde claro más oscuro
  static const Color borderLightDark = Color(0xFFD1D5DB);

  /// Sidebar claro
  static const Color sidebarLight = Color(0xFFFFFFFF);

  /// Texto principal modo claro (charcoal) - #1e293b
  static const Color textLightMain = Color(0xFF1E293B);

  /// Texto secundario modo claro - slate-600 #475569
  static const Color textLightMuted = Color(0xFF475569);

  /// Color olive dark para acentos - #6a9a08
  static const Color oliveDark = Color(0xFF6A9A08);

  // ========== ESCALA DE TEXTOS OSCUROS ==========

  /// Texto principal (blanco)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Texto secundario - #b0b99d
  static const Color textSecondary = Color(0xFFB0B99D);

  /// Texto terciario - #6B7A5A
  static const Color textTertiary = Color(0xFF6B7A5A);

  // ========== ESCALA DE GRISES (para modo claro) ==========

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ========== COLORES SEMÁNTICOS (ESTADOS) ==========

  /// Success - Verde #0bda2a
  static const Color success = Color(0xFF0BDA2A);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  /// Warning - Amber #F59E0B
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  /// Error - Rojo #fa4838
  static const Color error = Color(0xFFFA4838);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  /// Info - Azul #3B82F6
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ========== COLORES ESPECIALES ==========

  /// Blanco puro
  static const Color white = Color(0xFFFFFFFF);

  /// Negro puro
  static const Color black = Color(0xFF000000);

  /// Fondo principal (por defecto oscuro)
  static const Color background = backgroundDark;

  /// Fondo de superficie (cards, modales)
  static const Color surface = cardDark;

  // ========== GRADIENTES ==========

  /// Gradiente primario (hero sections)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// Gradiente radial para fondos
  static const RadialGradient radialPrimary = RadialGradient(
    center: Alignment.center,
    radius: 0.5,
    colors: [
      Color(0x14A4EC13), // primary con 8% opacidad
      Colors.transparent,
    ],
  );

  // ========== COLORES CON OPACIDAD ==========

  /// Primary con opacidad
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);

  /// Secondary con opacidad
  static Color secondaryWithOpacity(double opacity) =>
      secondary.withValues(alpha: opacity);

  /// Black con opacidad (útil para overlays)
  static Color blackWithOpacity(double opacity) =>
      black.withValues(alpha: opacity);

  /// White con opacidad
  static Color whiteWithOpacity(double opacity) =>
      white.withValues(alpha: opacity);

  // ========== SOMBRAS ==========

  /// Sombra suave para cards (modo oscuro)
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: black.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  /// Sombra media para elementos elevados
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  /// Sombra con glow primary
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.2),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  /// Sombra grande con glow primary (para CTAs)
  static List<BoxShadow> primaryGlowLarge = [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 30,
      spreadRadius: 5,
      offset: const Offset(0, 8),
    ),
  ];

  /// Sombra suave para cards modo claro (shadow-soft)
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: black.withValues(alpha: 0.07),
      blurRadius: 15,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: black.withValues(alpha: 0.05),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  // ========== HELPERS PARA DARK/LIGHT ==========

  /// Obtiene el color primario según el tema
  /// Para landing page: siempre usa primary (#a4ec13)
  /// Para dashboard: usa olive en modo claro
  static Color primaryColor(bool isDark) =>
      isDark ? primary : primaryLightMode;

  /// Color primario para landing (siempre #a4ec13)
  static const Color landingPrimary = primary;

  /// Color de acento para landing en modo claro (oliveDark)
  static const Color landingAccent = oliveDark;

  /// Obtiene el color de fondo según el tema
  static Color backgroundColor(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;

  /// Obtiene el color de superficie según el tema
  static Color surfaceColor(bool isDark) =>
      isDark ? cardDark : surfaceLight;

  /// Obtiene el color de card según el tema
  static Color cardColor(bool isDark) =>
      isDark ? cardDark : cardLight;

  /// Obtiene el color de borde según el tema
  static Color borderColor(bool isDark) =>
      isDark ? borderDark : borderLight;

  /// Obtiene el color de sidebar según el tema
  static Color sidebarColor(bool isDark) =>
      isDark ? sidebarDark : sidebarLight;

  /// Obtiene el color de texto principal según el tema
  static Color textColor(bool isDark) =>
      isDark ? textPrimary : textLightMain;

  /// Obtiene el color de texto secundario según el tema
  static Color textSecondaryColor(bool isDark) =>
      isDark ? textSecondary : gray500;

  /// Obtiene el color de texto terciario según el tema
  static Color textTertiaryColor(bool isDark) =>
      isDark ? textTertiary : gray400;
}
