import 'package:flutter/foundation.dart';

import 'package:futbase_web_3/core/config/app_config.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';
import 'package:futbase_web_3/core/datasources/supabase_datasource.dart';
import 'package:futbase_web_3/core/datasources/backend_seguro_datasource.dart';

/// Factory para crear el datasource según la configuración
///
/// Uso:
/// ```dart
/// final datasource = DataSourceFactory.create();
/// ```
///
/// Para cambiar entre datasources, modificar [AppConfig.useBackendSeguro]
class DataSourceFactory {
  DataSourceFactory._();

  static AppDataSource? _instance;

  /// Obtiene la instancia del datasource configurado
  static AppDataSource get instance {
    _instance ??= create();
    return _instance!;
  }

  /// Crea una nueva instancia del datasource según la configuración
  static AppDataSource create() {
    if (AppConfig.useBackendSeguro) {
      if (kDebugMode && AppConfig.enableDatasourceLogs) {
        debugPrint('🏭 [DataSourceFactory] Creando BackendSeguroDataSource');
      }
      return BackendSeguroDataSource();
    } else {
      if (kDebugMode && AppConfig.enableDatasourceLogs) {
        debugPrint('🏭 [DataSourceFactory] Creando SupabaseDataSource');
      }
      return SupabaseDataSource();
    }
  }

  /// Resetea la instancia (útil para tests o cambio de configuración en runtime)
  static void reset() {
    _instance = null;
  }
}
