import 'package:flutter/material.dart';

/// Sistema de colores de FutBase 3.0
///
/// Paleta simplificada a 3 colores principales:
/// - VERDE: Color principal de la app
/// - ROJO: Color de error/alerta
/// - GRISS: Escala de grises para textos y fondos
class AppColors {
  AppColors._();

  // ============================================================
  // VERDE - COLOR PRINCIPAL DE LA APP
  // ============================================================

  /// Verde principal - #00554E
  static const Color green = Color(0xFF00554E);

  /// Verde claro - #007A70
  static const Color greenLight = Color(0xFF007A70);

  /// Verde oscuro - #00423D
  static const Color greenDark = Color(0xFF00423D);

  /// Verde accent (neón) - #A4EC13
  static const Color greenAccent = Color(0xFFA4EC13);

  /// Verde accent claro - #B8F52D
  static const Color greenAccentLight = Color(0xFFB8F52D);

  /// Verde accent oscuro - #8BC410
  static const Color greenAccentDark = Color(0xFF8BC410);

  /// Verde olive (modo claro) - #6B7C4C
  static const Color greenOlive = Color(0xFF6B7C4C);

  /// Verde olive oscuro - #5A6840
  static const Color greenOliveDark = Color(0xFF5A6840);

  /// Alias: oliveDark = greenOlive (compatibilidad)
  static const Color oliveDark = greenOlive;

  // ============================================================
  // ROJO - COLOR DE ERROR/ALERTA
  // ============================================================

  /// Rojo principal - #FA4838
  static const Color red = Color(0xFFFA4838);

  /// Rojo claro - #F87171
  static const Color redLight = Color(0xFFF87171);

  /// Rojo oscuro - #DC2626
  static const Color redDark = Color(0xFFDC2626);

  /// Rojo más oscuro - #B91C1C
  static const Color redDarker = Color(0xFFB91C1C);

  // ============================================================
  // GRISS - ESCALA DE GRISES
  // ============================================================

  /// Gris más claro - #F9FAFB
  static const Color gray50 = Color(0xFFF9FAFB);

  /// Gris claro - #F3F4F6
  static const Color gray100 = Color(0xFFF3F4F6);

  /// Gris 200 - #E5E7EB
  static const Color gray200 = Color(0xFFE5E7EB);

  /// Gris 300 - #D1D5DB
  static const Color gray300 = Color(0xFFD1D5DB);

  /// Gris 400 - #9CA3AF
  static const Color gray400 = Color(0xFF9CA3AF);

  /// Gris 500 - #6B7280
  static const Color gray500 = Color(0xFF6B7280);

  /// Gris 600 - #4B5563
  static const Color gray600 = Color(0xFF4B5563);

  /// Gris 700 - #374151
  static const Color gray700 = Color(0xFF374151);

  /// Gris 800 - #1F2937
  static const Color gray800 = Color(0xFF1F2937);

  /// Gris 900 - #111827
  static const Color gray900 = Color(0xFF111827);

  // ============================================================
  // COLORES ESPECIALES
  // ============================================================

  /// Blanco puro
  static const Color white = Color(0xFFFFFFFF);

  /// Negro puro
  static const Color black = Color(0xFF000000);

  // ============================================================
  // ALIAS SEMÁNTICOS (para compatibilidad)
  // ============================================================

  /// Color primario de la app (verde)
  static const Color primary = green;

  /// Color primario claro
  static const Color primaryLight = greenLight;

  /// Color primario oscuro
  static const Color primaryDark = greenDark;

  /// Color de acento (verde neón)
  static const Color accent = greenAccent;

  /// Color de éxito (verde)
  static const Color success = greenAccent;

  /// Color de éxito claro
  static const Color successLight = greenAccentLight;

  /// Color de éxito oscuro
  static const Color successDark = greenOlive;

  /// Color de error (rojo)
  static const Color error = red;

  /// Color de error claro
  static const Color errorLight = redLight;

  /// Color de error oscuro
  static const Color errorDark = redDark;

  /// Color de advertencia (tono rojo suave) - para avisos no críticos
  static const Color warning = red;

  /// Color de advertencia claro
  static const Color warningLight = redLight;

  /// Color de advertencia oscuro
  static const Color warningDark = redDark;

  /// Color de información (verde) - para estados informativos
  static const Color info = greenOlive;

  /// Color de información claro
  static const Color infoLight = greenLight;

  /// Color de información oscuro
  static const Color infoDark = greenDark;

  /// Color secundario (verde oscuro)
  static const Color secondary = greenDark;

  /// Color secundario claro
  static const Color secondaryLight = green;

  /// Color secundario oscuro
  static const Color secondaryDark = greenDark;

  // ============================================================
  // FONDOS MODO OSCURO
  // ============================================================

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

  /// Borde oscuro claro (alias) - #4b543b
  static const Color borderDarkLight = Color(0xFF4B543B);

  // ============================================================
  // FONDOS MODO CLARO
  // ============================================================

  /// Fondo principal claro
  static const Color backgroundLight = white;

  /// Superficie clara
  static const Color surfaceLight = gray50;

  /// Fondo de cards claro
  static const Color cardLight = white;

  /// Borde claro
  static const Color borderLight = gray200;

  /// Sidebar claro
  static const Color sidebarLight = white;

  // ============================================================
  // TEXTOS
  // ============================================================

  /// Texto principal (blanco para dark mode)
  static const Color textPrimary = white;

  /// Texto secundario - #b0b99d
  static const Color textSecondary = Color(0xFFB0B99D);

  /// Texto terciario - #6B7A5A
  static const Color textTertiary = Color(0xFF6B7A5A);

  /// Texto principal modo claro
  static const Color textLightMain = gray900;

  /// Texto secundario modo claro
  static const Color textLightMuted = gray500;

  // ============================================================
  // FONDOS POR DEFECTO
  // ============================================================

  /// Fondo principal (por defecto oscuro)
  static const Color background = backgroundDark;

  /// Fondo de superficie (cards, modales)
  static const Color surface = cardDark;

  // ============================================================
  // GRADIENTES
  // ============================================================

  /// Gradiente primario (hero sections)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, greenLight],
  );

  /// Gradiente radial para fondos
  static const RadialGradient radialPrimary = RadialGradient(
    center: Alignment.center,
    radius: 0.5,
    colors: [
      Color(0x14A4EC13), // greenAccent con 8% opacidad
      Colors.transparent,
    ],
  );

  // ============================================================
  // COLORES CON OPACIDAD
  // ============================================================

  /// Primary con opacidad
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);

  /// Black con opacidad (útil para overlays)
  static Color blackWithOpacity(double opacity) =>
      black.withValues(alpha: opacity);

  /// White con opacidad
  static Color whiteWithOpacity(double opacity) =>
      white.withValues(alpha: opacity);

  // ============================================================
  // SOMBRAS
  // ============================================================

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

  /// Sombra suave para cards modo claro
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

  // ============================================================
  // HELPERS PARA DARK/LIGHT
  // ============================================================

  /// Obtiene el color primario según el tema
  static Color primaryColor(bool isDark) => isDark ? green : greenOlive;

  /// Color primario para landing (siempre verde)
  static const Color landingPrimary = green;

  /// Color de acento para landing
  static const Color landingAccent = greenOlive;

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
