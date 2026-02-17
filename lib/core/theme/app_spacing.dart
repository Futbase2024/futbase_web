import 'package:flutter/material.dart';

/// Sistema de espaciado consistente para FutBase 3.0
///
/// Basado en múltiplos de 4 para mantener una cuadrícula visual coherente
/// y facilitar el diseño responsive
class AppSpacing {
  // ========== ESPACIADO BASE (múltiplos de 4) ==========

  /// 4px - Espaciado mínimo
  static const double xs = 4.0;

  /// 8px - Espaciado pequeño
  static const double sm = 8.0;

  /// 12px - Espaciado medio-pequeño
  static const double md = 12.0;

  /// 16px - Espaciado estándar (base)
  static const double lg = 16.0;

  /// 24px - Espaciado grande
  static const double xl = 24.0;

  /// 32px - Espaciado extra grande
  static const double xxl = 32.0;

  /// 48px - Espaciado muy grande
  static const double xxxl = 48.0;

  /// 64px - Espaciado masivo
  static const double huge = 64.0;

  /// 96px - Espaciado gigante
  static const double giant = 96.0;

  // ========== PADDING PREDEFINIDOS ==========

  /// Padding mínimo - 4px
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);

  /// Padding pequeño - 8px
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);

  /// Padding medio - 12px
  static const EdgeInsets paddingMd = EdgeInsets.all(md);

  /// Padding estándar - 16px
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Padding grande - 24px
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  /// Padding extra grande - 32px
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // ========== PADDING HORIZONTAL ==========

  /// Padding horizontal mínimo
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);

  /// Padding horizontal pequeño
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Padding horizontal medio
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Padding horizontal estándar
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Padding horizontal grande
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  /// Padding horizontal extra grande
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  // ========== PADDING VERTICAL ==========

  /// Padding vertical mínimo
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);

  /// Padding vertical pequeño
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Padding vertical medio
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// Padding vertical estándar
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// Padding vertical grande
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  /// Padding vertical extra grande
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);

  // ========== SIZED BOXES (para espaciado entre widgets) ==========

  /// SizedBox vertical mínimo
  static const SizedBox vSpaceXs = SizedBox(height: xs);

  /// SizedBox vertical pequeño
  static const SizedBox vSpaceSm = SizedBox(height: sm);

  /// SizedBox vertical medio
  static const SizedBox vSpaceMd = SizedBox(height: md);

  /// SizedBox vertical estándar
  static const SizedBox vSpaceLg = SizedBox(height: lg);

  /// SizedBox vertical grande
  static const SizedBox vSpaceXl = SizedBox(height: xl);

  /// SizedBox vertical extra grande
  static const SizedBox vSpaceXxl = SizedBox(height: xxl);

  /// SizedBox vertical muy grande
  static const SizedBox vSpaceXxxl = SizedBox(height: xxxl);

  /// SizedBox vertical enorme
  static const SizedBox vSpaceHuge = SizedBox(height: huge);

  /// SizedBox horizontal mínimo
  static const SizedBox hSpaceXs = SizedBox(width: xs);

  /// SizedBox horizontal pequeño
  static const SizedBox hSpaceSm = SizedBox(width: sm);

  /// SizedBox horizontal medio
  static const SizedBox hSpaceMd = SizedBox(width: md);

  /// SizedBox horizontal estándar
  static const SizedBox hSpaceLg = SizedBox(width: lg);

  /// SizedBox horizontal grande
  static const SizedBox hSpaceXl = SizedBox(width: xl);

  /// SizedBox horizontal extra grande
  static const SizedBox hSpaceXxl = SizedBox(width: xxl);

  /// SizedBox horizontal enorme
  static const SizedBox hSpaceHuge = SizedBox(width: huge);

  // ========== BORDER RADIUS ==========

  /// Radio de borde mínimo - 4px
  static const double radiusXs = 4.0;

  /// Radio de borde pequeño - 8px
  static const double radiusSm = 8.0;

  /// Radio de borde medio - 12px
  static const double radiusMd = 12.0;

  /// Radio de borde estándar - 16px
  static const double radiusLg = 16.0;

  /// Radio de borde grande - 24px
  static const double radiusXl = 24.0;

  /// Radio de borde circular completo
  static const double radiusFull = 9999.0;

  // ========== BORDER RADIUS PREDEFINIDOS ==========

  /// BorderRadius mínimo
  static BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);

  /// BorderRadius pequeño
  static BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);

  /// BorderRadius medio
  static BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  /// BorderRadius estándar
  static BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);

  /// BorderRadius grande
  static BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);

  /// BorderRadius circular completo
  static BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // ========== TAMAÑOS DE ICONOS ==========

  /// Icono extra pequeño - 16px
  static const double iconXs = 16.0;

  /// Icono pequeño - 20px
  static const double iconSm = 20.0;

  /// Icono medio - 24px
  static const double iconMd = 24.0;

  /// Icono grande - 32px
  static const double iconLg = 32.0;

  /// Icono extra grande - 48px
  static const double iconXl = 48.0;

  /// Icono gigante - 64px
  static const double iconXxl = 64.0;
}
