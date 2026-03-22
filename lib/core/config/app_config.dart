/// Configuración global de la aplicación
class AppConfig {
  AppConfig._();

  /// ========================================
  /// 🔄 CAMBIAR ESTE VALOR PARA ALTERNAR ENTRE DATASOURCES
  /// ========================================
  ///
  /// true  = Usar backend_seguro_web (PHP + Firebase Auth) + MySQL Arsys
  /// false = Usar Supabase directo
  static const bool useBackendSeguro = true;

  /// URL base del backend seguro
  static const String backendSeguroUrl =
      'https://futbase.es/backend_seguro_web';

  /// Timeout para peticiones HTTP (en segundos)
  static const int httpTimeoutSeconds = 30;

  /// Habilitar logs de debug para datasources
  static const bool enableDatasourceLogs = true;
}
