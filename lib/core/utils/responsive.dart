import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Utilidades para diseño responsive
///
/// Permite adaptar la interfaz según el tamaño de pantalla
class Responsive {
  /// Obtener el ancho de la pantalla
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtener el alto de la pantalla
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Detectar si es móvil (< 640px)
  static bool isMobile(BuildContext context) {
    return width(context) < AppConstants.mobileBreakpoint;
  }

  /// Detectar si es tablet (640px - 1024px)
  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= AppConstants.mobileBreakpoint &&
        w < AppConstants.desktopBreakpoint;
  }

  /// Detectar si es desktop (> 1024px)
  static bool isDesktop(BuildContext context) {
    return width(context) >= AppConstants.desktopBreakpoint;
  }

  /// Detectar si es ultra-wide (> 1536px)
  static bool isUltraWide(BuildContext context) {
    return width(context) >= AppConstants.ultraWideBreakpoint;
  }

  /// Obtener valor según el tamaño de pantalla
  ///
  /// Uso:
  /// ```dart
  /// final padding = Responsive.value(
  ///   context,
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Widget responsive que construye según el tamaño de pantalla
  ///
  /// Uso:
  /// ```dart
  /// Responsive.builder(
  ///   mobile: (context) => MobileWidget(),
  ///   tablet: (context) => TabletWidget(),
  ///   desktop: (context) => DesktopWidget(),
  /// )
  /// ```
  static Widget builder({
    required Widget Function(BuildContext context) mobile,
    Widget Function(BuildContext context)? tablet,
    Widget Function(BuildContext context)? desktop,
  }) {
    return Builder(
      builder: (context) {
        if (isDesktop(context)) {
          return (desktop ?? tablet ?? mobile)(context);
        } else if (isTablet(context)) {
          return (tablet ?? mobile)(context);
        } else {
          return mobile(context);
        }
      },
    );
  }

  /// Obtener número de columnas para grid según pantalla
  static int gridColumns(BuildContext context) {
    if (isUltraWide(context)) {
      return 4;
    } else if (isDesktop(context)) {
      return 3;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }

  /// Obtener ancho del sidebar según pantalla
  static double sidebarWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 280;
    } else if (isTablet(context)) {
      return 240;
    } else {
      return 0; // No mostrar sidebar en móvil
    }
  }

  /// Determinar si el sidebar debe ser drawer (móvil/tablet)
  static bool shouldUseSidebarDrawer(BuildContext context) {
    return !isDesktop(context);
  }

  /// Padding horizontal responsive
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context,
        mobile: 16.0,
        tablet: 32.0,
        desktop: 48.0,
      ),
    );
  }

  /// Padding vertical responsive
  static EdgeInsets verticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: value(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }

  /// Padding completo responsive
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }

  /// Obtener tamaño de fuente responsive
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Limitar ancho del contenido
  static Widget constrainedContent({
    required Widget child,
    double maxWidth = AppConstants.maxContentWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Extension para usar Responsive más fácilmente
extension ResponsiveContext on BuildContext {
  /// Obtener ancho de pantalla
  double get screenWidth => Responsive.width(this);

  /// Obtener alto de pantalla
  double get screenHeight => Responsive.height(this);

  /// Es móvil
  bool get isMobile => Responsive.isMobile(this);

  /// Es tablet
  bool get isTablet => Responsive.isTablet(this);

  /// Es desktop
  bool get isDesktop => Responsive.isDesktop(this);

  /// Es ultra-wide
  bool get isUltraWide => Responsive.isUltraWide(this);

  /// Es tema oscuro
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Es tema claro
  bool get isLight => !isDark;

  /// Color de fondo según tema
  Color get backgroundColor => AppColors.backgroundColor(isDark);

  /// Color de superficie/card según tema
  Color get cardColor => AppColors.cardColor(isDark);

  /// Color de borde según tema
  Color get borderColor => AppColors.borderColor(isDark);

  /// Color de texto principal según tema
  Color get textColor => AppColors.textColor(isDark);

  /// Color de texto secundario según tema
  Color get textSecondaryColor => AppColors.textSecondaryColor(isDark);

  /// Color de sidebar según tema
  Color get sidebarColor => AppColors.sidebarColor(isDark);

  /// Color primario según tema
  Color get primaryColor => AppColors.primaryColor(isDark);
}
