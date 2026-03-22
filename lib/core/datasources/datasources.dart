/// Datasources - Capa de abstracción para fuentes de datos
///
/// Permite cambiar entre Supabase y backend_seguro_web modificando
/// solo [AppConfig.useBackendSeguro]
///
/// Uso:
/// ```dart
/// import 'package:futbase_web_3/core/datasources/datasources.dart';
///
/// final datasource = DataSourceFactory.instance;
/// final cuotas = await datasource.getCuotas(idclub: 1, idtemporada: 1);
/// ```
library;

export 'api_response.dart';
export 'app_datasource.dart';
export 'datasource_factory.dart';
export 'supabase_datasource.dart';
export 'backend_seguro_datasource.dart';
