/// Constantes globales de la aplicación FutBase 3.0
class AppConstants {
  // ========== INFORMACIÓN DE LA APP ==========

  static const String appName = 'FutBase';
  static const String appVersion = '3.0';
  static const String appTagline = 'La Plataforma de Gestión Deportiva Más Completa';

  // ========== BREAKPOINTS RESPONSIVE ==========

  /// Mobile: < 640px
  static const double mobileBreakpoint = 640;

  /// Tablet: 640px - 1024px
  static const double tabletBreakpoint = 1024;

  /// Desktop: > 1024px
  static const double desktopBreakpoint = 1024;

  /// Ultra-wide: > 1536px
  static const double ultraWideBreakpoint = 1536;

  // ========== DIMENSIONES MÁXIMAS ==========

  /// Ancho máximo para contenido (legibilidad)
  static const double maxContentWidth = 1280;

  /// Ancho máximo para textos largos
  static const double maxTextWidth = 720;

  // ========== ANIMACIONES ==========

  /// Duración de animaciones rápidas (ms)
  static const int fastAnimationDuration = 200;

  /// Duración de animaciones normales (ms)
  static const int normalAnimationDuration = 300;

  /// Duración de animaciones lentas (ms)
  static const int slowAnimationDuration = 500;

  // ========== DURATIONS ==========

  /// Duración rápida
  static const Duration fastDuration = Duration(milliseconds: fastAnimationDuration);

  /// Duración normal
  static const Duration normalDuration = Duration(milliseconds: normalAnimationDuration);

  /// Duración lenta
  static const Duration slowDuration = Duration(milliseconds: slowAnimationDuration);

  // ========== API ENDPOINTS ==========

  /// URL base de la API
  static const String apiBaseUrl = 'https://api.futbase.com';

  /// Versión de la API
  static const String apiVersion = 'v1';

  // ========== PAGINACIÓN ==========

  /// Número de items por página (por defecto)
  static const int defaultPageSize = 20;

  /// Número de items por página (tablas)
  static const int tablePageSize = 15;

  // ========== CACHE ==========

  /// Duración de caché de imágenes (días)
  static const int imageCacheDuration = 7;

  /// Duración de caché de datos (minutos)
  static const int dataCacheDuration = 30;

  // ========== VALIDACIÓN ==========

  /// Longitud mínima de contraseña
  static const int minPasswordLength = 8;

  /// Longitud máxima de nombre
  static const int maxNameLength = 50;

  /// Longitud máxima de descripción
  static const int maxDescriptionLength = 500;

  // ========== FORMATOS ==========

  /// Formato de fecha corta
  static const String shortDateFormat = 'dd/MM/yyyy';

  /// Formato de fecha larga
  static const String longDateFormat = 'dd MMMM yyyy';

  /// Formato de hora
  static const String timeFormat = 'HH:mm';

  /// Formato de fecha y hora
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // ========== REDES SOCIALES (ejemplo) ==========

  static const String facebookUrl = 'https://facebook.com/futbase';
  static const String twitterUrl = 'https://twitter.com/futbase';
  static const String instagramUrl = 'https://instagram.com/futbase';
  static const String linkedinUrl = 'https://linkedin.com/company/futbase';

  // ========== EMAILS ==========

  static const String supportEmail = 'soporte@futbase.com';
  static const String contactEmail = 'contacto@futbase.com';

  // ========== FEATURES FLAGS ==========

  /// Habilitar modo debug
  static const bool enableDebugMode = false;

  /// Habilitar analytics
  static const bool enableAnalytics = true;

  /// Habilitar crash reports
  static const bool enableCrashReports = true;
}
