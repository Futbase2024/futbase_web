import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:futbase_web_3/core/config/app_config.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';
import 'package:futbase_web_3/core/datasources/api_response.dart';

/// Implementación de AppDataSource usando backend_seguro_web (PHP + Firebase Auth)
class BackendSeguroDataSource implements AppDataSource {
  BackendSeguroDataSource({
    http.Client? client,
    FirebaseAuth? auth,
  })  : _client = client ?? http.Client(),
        _auth = auth ?? FirebaseAuth.instance;

  final http.Client _client;
  final FirebaseAuth _auth;

  String get _baseUrl => AppConfig.backendSeguroUrl;

  void _log(String message) {
    if (kDebugMode && AppConfig.enableDatasourceLogs) {
      debugPrint('🟢 [BackendSeguroDS] $message');
    }
  }

  /// Obtiene el token de Firebase para autenticación
  Future<String?> _getAuthToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Headers comunes para todas las peticiones
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Realiza una petición GET al endpoint
  Future<ApiResponse<T>> _get<T>(
    String endpoint,
    Map<String, dynamic> params,
    T Function(List<dynamic> data) parser,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint').replace(
        queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
      );

      _log('GET $endpoint: $params');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      return _parseResponse<T>(response, parser);
    } catch (e) {
      _log('GET $endpoint ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Realiza una petición POST al endpoint
  Future<ApiResponse<void>> _post(
    String endpoint,
    Map<String, dynamic> params,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint').replace(
        queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
      );

      _log('POST $endpoint: params=$params, body=${body.keys}');

      final response = await _client
          .post(
            uri,
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      return _parseVoidResponse(response);
    } catch (e) {
      _log('POST $endpoint ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Parsea respuesta con datos
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(List<dynamic> data) parser,
  ) {
    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // DEBUG: Log de la respuesta para endpoints de entrenamientos y partidos
        final isSuccess = json['success'] == true;
        final dataContent = json['data'];
        if (dataContent is Map) {
          _log('Response data keys: ${dataContent.keys.toList()}');
        } else if (dataContent is List) {
          _log('Response data is List with ${dataContent.length} items');
        } else {
          _log('Response data type: ${dataContent.runtimeType}');
        }

        if (isSuccess) {
          final data = json['data'];
          if (data is List) {
            return ApiResponse.ok(parser(data));
          } else if (data is Map) {
            // Si es un mapa con una key específica (ej: 'cuotas', 'entrenamientos')
            final listData = data.values.firstWhere(
              (v) => v is List,
              orElse: () => <dynamic>[],
            );
            return ApiResponse.ok(parser(listData as List<dynamic>));
          }
          return ApiResponse.ok(parser(<dynamic>[]));
        } else {
          return ApiResponse.error(
            json['message']?.toString() ?? 'Error desconocido',
            json['code']?.toString(),
          );
        }
      } catch (e) {
        _log('Parse error: $e');
        return ApiResponse.error('Error al parsear respuesta: $e');
      }
    } else if (response.statusCode == 401) {
      return ApiResponse.error('No autenticado', '401');
    } else if (response.statusCode == 429) {
      return ApiResponse.error('Demasiadas peticiones', '429');
    } else {
      return ApiResponse.error(
        'Error HTTP ${response.statusCode}',
        response.statusCode.toString(),
      );
    }
  }

  /// Parsea respuesta sin datos (solo éxito/error)
  ApiResponse<void> _parseVoidResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return ApiResponse.ok(null);
        } else {
          return ApiResponse.error(
            json['message']?.toString() ?? 'Error desconocido',
            json['code']?.toString(),
          );
        }
      } catch (e) {
        return ApiResponse.error('Error al parsear respuesta: $e');
      }
    } else if (response.statusCode == 401) {
      return ApiResponse.error('No autenticado', '401');
    } else {
      return ApiResponse.error(
        'Error HTTP ${response.statusCode}',
        response.statusCode.toString(),
      );
    }
  }

  // ========================================
  // CUOTAS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCuotas({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/cuotas.php',
      {
        'action': 'getcuotasbyclub',
        'idclub': idclub,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> updateCuotaEstado({
    required int idCuota,
    required int idEstado,
  }) async {
    return _post(
      'endpoints/cuotas.php',
      {'action': 'updatecuota'},
      {
        'id': idCuota,
        'idestado': idEstado,
      },
    );
  }

  @override
  Future<ApiResponse<void>> createReciboPago({
    required int idclub,
    required int idjugador,
    required int idtemporada,
    required double cantidad,
    required String concepto,
    required String metodoPago,
  }) async {
    return _post(
      'endpoints/pagos.php',
      {'action': 'create'},
      {
        'idclub': idclub,
        'idjugador': idjugador,
        'idtemporada': idtemporada,
        'cantidad': cantidad,
        'concepto': concepto,
        'metodo_pago': metodoPago,
        'fecha_pago': DateTime.now().toIso8601String(),
      },
    );
  }

  // ========================================
  // ENTRENAMIENTOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientos({
    required int idequipo,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/entrenamientos.php',
      {
        'action': 'getByTeamTemporada',  // Case-sensitive!
        'idequipo': idequipo,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientosByClub({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/entrenamientos.php',
      {
        'action': 'getbyclubtemporada',
        'idclub': idclub,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> createEntrenamiento({
    required int idequipo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    String? observaciones,
  }) async {
    return _post(
      'endpoints/entrenamientos.php',
      {'action': 'create'},
      {
        'idequipo': idequipo,
        'fecha': fecha.toIso8601String().split('T')[0],
        'hinicio': horaInicio,
        'hfin': horaFin,
        'nombre': observaciones,
        'observaciones': observaciones,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateEntrenamiento({
    required int id,
    required int idequipo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    String? observaciones,
  }) async {
    return _post(
      'endpoints/entrenamientos.php',
      {'action': 'update'},
      {
        'id': id,
        'idequipo': idequipo,
        'fecha': fecha.toIso8601String().split('T')[0],
        'hinicio': horaInicio,
        'hfin': horaFin,
        'nombre': observaciones,
        'observaciones': observaciones,
      },
    );
  }

  @override
  Future<ApiResponse<void>> deleteEntrenamiento({
    required int id,
  }) async {
    return _post(
      'endpoints/entrenamientos.php',
      {'action': 'delete'},
      {'id': id},
    );
  }

  // ========================================
  // ASISTENCIA A ENTRENAMIENTOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMotivosAsistencia() async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/entrenos_jugadores.php',
      {'action': 'getmotivos'},
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getAsistenciaEntrenamiento({
    required int identrenamiento,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/entrenos_jugadores.php',
      {
        'action': 'getbyentrenamiento',
        'identrenamiento': identrenamiento,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> saveAsistenciaEntrenamiento({
    required int identrenamiento,
    required int idequipo,
    required int idclub,
    required List<Map<String, dynamic>> asistencia,
  }) async {
    return _post(
      'endpoints/entrenos_jugadores.php',
      {'action': 'savebatch'},
      {
        'identrenamiento': identrenamiento,
        'idequipo': idequipo,
        'idclub': idclub,
        'asistencia': asistencia,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasAsistencia({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/entrenos_jugadores.php',
      {
        'action': 'getstats',
        'idclub': idclub,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  // ========================================
  // EQUIPOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquipos({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/equipos.php',
      {
        'action': 'getbyclubtemporada',
        'idclub': idclub,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategorias() async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/categories.php',
      {'action': 'getall'},
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  // ========================================
  // JUGADORES
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresEquipo({
    required int idequipo,
    int? idclub,
    int? idtemporada,
  }) async {
    _log('getJugadoresEquipo: idequipo=$idequipo, idclub=$idclub, idtemporada=$idtemporada');

    // Si no tenemos idclub o idtemporada, obtenerlos del equipo
    if (idclub == null || idtemporada == null) {
      _log('getJugadoresEquipo: Obteniendo info del equipo...');
      final equipoResponse = await getEquiposInfo(ids: [idequipo]);
      _log('getJugadoresEquipo: equipoResponse.success=${equipoResponse.success}, data=${equipoResponse.data}');
      if (equipoResponse.success && equipoResponse.data != null && equipoResponse.data!.isNotEmpty) {
        final equipo = equipoResponse.data!.first;
        idclub = idclub ?? equipo['idclub'] as int?;
        idtemporada = idtemporada ?? equipo['idtemporada'] as int?;
        _log('getJugadoresEquipo: Obtenido idclub=$idclub, idtemporada=$idtemporada del equipo');
      }
    }

    // Usar getPlayersByClub y filtrar por equipo
    if (idclub != null && idtemporada != null) {
      _log('getJugadoresEquipo: Llamando a getJugadoresByClub...');
      final response = await getJugadoresByClub(
        idclub: idclub,
        idtemporada: idtemporada,
        soloActivos: true,
      );

      _log('getJugadoresEquipo: getJugadoresByClub response.success=${response.success}, data.length=${response.data?.length}');

      if (response.success && response.data != null) {
        // Filtrar por idequipo
        final filtered = response.data!
            .where((j) => j['idequipo'] == idequipo)
            .toList();
        _log('getJugadoresEquipo: Filtrados ${filtered.length} jugadores para idequipo=$idequipo');
        return ApiResponse.ok(filtered);
      }
      return response;
    }

    // Fallback: devolver lista vacía
    _log('getJugadoresEquipo: Fallback - sin idclub o idtemporada');
    return ApiResponse.ok([]);
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresDatos({
    required List<int> ids,
  }) async {
    if (ids.isEmpty) return ApiResponse.ok([]);

    return _get<List<Map<String, dynamic>>>(
      'endpoints/jugadores.php',
      {
        'action': 'getbyids',
        'ids': ids.join(','),
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  // ========================================
  // PARTIDOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidos({
    required int idequipo,
    required int idtemporada,
    int? idclub,
  }) async {
    // El backend partidos.php usa 'getByTemporada' que requiere idclub e idtemporada
    // Si no tenemos idclub, devolvemos error
    if (idclub == null) {
      _log('getPartidos: ERROR - idclub es requerido para getByTemporada');
      return ApiResponse.error('idclub es requerido');
    }

    final response = await _get<List<Map<String, dynamic>>>(
      'endpoints/partidos.php',
      {
        'action': 'getByTemporada',  // Case-sensitive!
        'idtemporada': idtemporada,
        'idclub': idclub,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );

    // Filtrar por idequipo en el cliente
    if (response.success && response.data != null) {
      final filtered = response.data!
          .where((p) => p['idequipo'] == idequipo)
          .toList();
      _log('getPartidos: Filtrados ${filtered.length} partidos para idequipo=$idequipo');
      return ApiResponse.ok(filtered);
    }

    return response;
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosByClub({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/partidos.php',
      {
        'action': 'getbyclubtemporada',
        'idclub': idclub,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosByDateRange({
    required int idtemporada,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/partidos.php',
      {
        'action': 'getbydaterange',
        'idtemporada': idtemporada,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPartido({required int idpartido}) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/partidos.php').replace(
        queryParameters: {'action': 'getbyid', 'id': idpartido.toString()},
      );

      _log('GET partidos.php: id=$idpartido');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            return ApiResponse.ok(data);
          }
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getPartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> createPartido({
    required int idequipo,
    required int idtemporada,
    required DateTime fecha,
    required String rival,
    required bool local,
  }) async {
    return _post(
      'endpoints/partidos.php',
      {'action': 'create'},
      {
        'idequipo': idequipo,
        'idtemporada': idtemporada,
        'fecha': fecha.toIso8601String().split('T')[0],
        'rival': rival,
        'casafuera': local ? 0 : 1,
        'finalizado': 0,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updatePartido({
    required int id,
    required int idequipo,
    required int idtemporada,
    required DateTime fecha,
    required String rival,
    required bool local,
    int? golesLocal,
    int? golesVisitante,
    bool? finalizado,
  }) async {
    return _post(
      'endpoints/partidos.php',
      {'action': 'update'},
      {
        'id': id,
        'idtemporada': idtemporada,
        'fecha': fecha.toIso8601String().split('T')[0],
        'rival': rival,
        'casafuera': local ? 0 : 1,
        'goles': golesLocal,
        'golesrival': golesVisitante,
        'finalizado': finalizado == true ? 1 : 0,
      },
    );
  }

  @override
  Future<ApiResponse<void>> deletePartido({required int id}) async {
    return _post(
      'endpoints/partidos.php',
      {'action': 'delete'},
      {'id': id},
    );
  }

  // ========================================
  // ALINEACIÓN Y CONVOCATORIA
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLineup({
    required int idpartido,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/convocatoria.php',
      {
        'action': 'getlineup',
        'idpartido': idpartido,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPartidoCamisetas({
    required int idpartido,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/partidos.php').replace(
        queryParameters: {'action': 'getcamisetas', 'id': idpartido.toString()},
      );

      _log('GET partidos.php camisetas: id=$idpartido');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            return ApiResponse.ok(data);
          }
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getPartidoCamisetas ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteConvocatoria({required int idpartido}) async {
    return _post(
      'endpoints/convocatoria.php',
      {'action': 'deleteall'},
      {'idpartido': idpartido},
    );
  }

  @override
  Future<ApiResponse<void>> saveLineup({
    required int idpartido,
    required List<Map<String, dynamic>> lineup,
  }) async {
    return _post(
      'endpoints/convocatoria.php',
      {'action': 'savelineup'},
      {
        'idpartido': idpartido,
        'lineup': lineup,
      },
    );
  }

  @override
  Future<ApiResponse<void>> upsertConvocatoria({
    required int idpartido,
    required int idjugador,
    required int idequipo,
    required int idtemporada,
    required bool convocado,
    int? dorsal,
    bool? titular,
    int? minutoEntrada,
    double? posX,
    double? posY,
  }) async {
    return _post(
      'endpoints/convocatoria.php',
      {'action': 'upsert'},
      {
        'idpartido': idpartido,
        'idjugador': idjugador,
        'idequipo': idequipo,
        'idtemporada': idtemporada,
        'convocado': convocado ? 1 : 0,
        'dorsal': dorsal,
        'titular': titular == true ? 1 : 0,
        'mentra': minutoEntrada,
        'posx': posX,
        'posy': posY,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getConvocatoria({
    required int idpartido,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/convocatoria.php',
      {
        'action': 'getconvocados',
        'idpartido': idpartido,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> updateConvocatoriaDorsal({
    required int idpartido,
    required int idjugador,
    int? dorsal,
  }) async {
    return _post(
      'endpoints/convocatoria.php',
      {'action': 'updatedorsal'},
      {
        'idpartido': idpartido,
        'idjugador': idjugador,
        'dorsal': dorsal,
      },
    );
  }

  // ========================================
  // EQUIPOS (métodos adicionales)
  // ========================================

  @override
  Future<ApiResponse<List<int>>> getEquiposIds({
    required int idclub,
    required int idtemporada,
  }) async {
    final response = await getEquipos(idclub: idclub, idtemporada: idtemporada);
    if (response.success && response.data != null) {
      final ids = response.data!.map((e) => e['id'] as int).toList();
      return ApiResponse.ok(ids);
    }
    return ApiResponse.error(response.message ?? 'Error', response.errorCode);
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquiposInfo({
    required List<int> ids,
  }) async {
    if (ids.isEmpty) return ApiResponse.ok([]);

    return _get<List<Map<String, dynamic>>>(
      'endpoints/equipos.php',
      {
        'action': 'getbyids',
        'ids': ids.join(','),
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> createEquipo({
    required int idclub,
    required int idcategoria,
    required int idtemporada,
    required String equipo,
    String? ncorto,
    int? titulares,
    int? minutos,
  }) async {
    return _post(
      'endpoints/equipos.php',
      {'action': 'create'},
      {
        'idclub': idclub,
        'idcategoria': idcategoria,
        'idtemporada': idtemporada,
        'equipo': equipo,
        'ncorto': ncorto,
        'titulares': titulares,
        'minutos': minutos,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateEquipo({
    required int id,
    required int idcategoria,
    required int idtemporada,
    required String equipo,
    String? ncorto,
    int? titulares,
    int? minutos,
  }) async {
    return _post(
      'endpoints/equipos.php',
      {'action': 'update'},
      {
        'id': id,
        'idcategoria': idcategoria,
        'idtemporada': idtemporada,
        'equipo': equipo,
        'ncorto': ncorto,
        'titulares': titulares,
        'minutos': minutos,
      },
    );
  }

  @override
  Future<ApiResponse<void>> deleteEquipo({required int id}) async {
    return _post(
      'endpoints/equipos.php',
      {'action': 'delete'},
      {'id': id},
    );
  }

  // ========================================
  // JUGADORES (métodos adicionales)
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresByClub({
    required int idclub,
    required int idtemporada,
    bool soloActivos = true,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/jugadores.php',
      {
        'action': 'getPlayersByClub',
        'idclub': idclub,
        'idtemporada': idtemporada,
        'active': soloActivos ? '1' : '0',
        'idtempinicial': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPosiciones() async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/posiciones.php',
      {'action': 'getall'},
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  // ========================================
  // TEMPORADAS (métodos adicionales)
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTemporadas() async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/temporadas.php',
      {'action': 'getall'},
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  // ========================================
  // CLUB
  // ========================================

  @override
  Future<ApiResponse<Map<String, dynamic>>> getClub({
    required int idclub,
    int? idtemporada,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/club.php').replace(
        queryParameters: {
          'action': 'getClub',
          'idclub': idclub.toString(),
          if (idtemporada != null) 'idtemporada': idtemporada.toString(),
        },
      );

      _log('GET club.php: idclub=$idclub, idtemporada=$idtemporada');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            _log('getClub: escudo=${data['escudo']}');
            return ApiResponse.ok(data);
          }
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getClub ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // TEMPORADAS
  // ========================================

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTemporadaActiva({
    required int idclub,
  }) async {
    try {
      // Usar preferences.php que ya existe y funciona en la web antigua
      final uri = Uri.parse('$_baseUrl/endpoints/preferences.php').replace(
        queryParameters: {'action': 'getTemporada'},
      );

      _log('GET preferences.php: getTemporada (idclub=$idclub)');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return ApiResponse.ok(json['data'] as Map<String, dynamic>);
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getTemporadaActiva ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // AUTENTICACIÓN
  // ========================================

  @override
  Future<String?> getAuthToken() async {
    return await _getAuthToken();
  }

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  // ========================================
  // SCOUTING
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getScoutingPlayers({
    int? idclub,
    int? idtemporada,
    List<int>? idposiciones,
    List<int>? idcategorias,
    int? idpiedominante,
    String? searchQuery,
  }) async {
    try {
      final params = <String, String>{
        'action': 'scouting',
      };
      if (idclub != null) params['idclub'] = idclub.toString();
      if (idtemporada != null) params['idtemporada'] = idtemporada.toString();
      if (idposiciones != null && idposiciones.isNotEmpty) {
        params['idposiciones'] = idposiciones.join(',');
      }
      if (idcategorias != null && idcategorias.isNotEmpty) {
        params['idcategorias'] = idcategorias.join(',');
      }
      if (idpiedominante != null) params['idpiedominante'] = idpiedominante.toString();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search'] = searchQuery;
      }

      return _get<List<Map<String, dynamic>>>(
        'endpoints/jugadores.php',
        params,
        (data) => data.cast<Map<String, dynamic>>().toList(),
      );
    } catch (e) {
      _log('getScoutingPlayers ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlayerHistory({
    required int jugadorId,
  }) async {
    try {
      return _get<List<Map<String, dynamic>>>(
        'endpoints/jugadores.php',
        {'action': 'history', 'id': jugadorId.toString()},
        (data) => data.cast<Map<String, dynamic>>().toList(),
      );
    } catch (e) {
      _log('getPlayerHistory ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // USUARIOS Y AUTENTICACIÓN
  // ========================================

  @override
  Future<Map<String, dynamic>?> getUsuarioByUid({required String uid}) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/auth.php').replace(
        queryParameters: {'action': 'getAppUserByUid', 'uid': uid},
      );

      _log('GET auth.php: uid=$uid');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;

          // auth.php devuelve: { uid, appUser: {...} }
          // Los datos del usuario están dentro de 'appUser'
          if (data['appUser'] != null) {
            final appUser = data['appUser'] as Map<String, dynamic>;
            _log('getUsuarioByUid: appUser encontrado - nombre=${appUser['nombre']}, permisos=${appUser['permisos']}, idclub=${appUser['idclub']}, idtemporada=${appUser['idtemporada']}');
            return appUser;
          }

          _log('getUsuarioByUid: No se encontró appUser en la respuesta');
        }
      }
      return null;
    } catch (e) {
      _log('getUsuarioByUid ERROR: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUsuarioByEmail({required String email}) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/usuarios.php').replace(
        queryParameters: {'action': 'getbyemail', 'email': email},
      );

      _log('GET usuarios.php: email=$email');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return json['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      _log('getUsuarioByEmail ERROR: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUsuarioById({required String id}) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/usuarios.php').replace(
        queryParameters: {'action': 'getbyid', 'id': id},
      );

      _log('GET usuarios.php: id=$id');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return json['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      _log('getUsuarioById ERROR: $e');
      return null;
    }
  }

  @override
  Future<void> updateUsuarioUid({
    required String userId,
    required String uid,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/usuarios.php');
      final body = jsonEncode({
        'action': 'updateuid',
        'id': userId,
        'uid': uid,
      });

      _log('POST usuarios.php: updateuid userId=$userId');

      final response = await _client
          .post(
            uri,
            headers: await _getHeaders(),
            body: body,
          )
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          _log('updateUsuarioUid: OK');
        }
      }
    } catch (e) {
      _log('updateUsuarioUid ERROR: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> createUsuario({
    required String nombre,
    required String apellidos,
    required String email,
    required int idclub,
    required String uid,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/usuarios.php');
      final body = jsonEncode({
        'action': 'create',
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
        'idclub': idclub,
        'uid': uid,
      });

      _log('POST usuarios.php: create email=$email');

      final response = await _client
          .post(
            uri,
            headers: await _getHeaders(),
            body: body,
          )
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          _log('createUsuario: OK');
          return json['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      _log('createUsuario ERROR: $e');
      return null;
    }
  }

  @override
  Future<int?> getCurrentTemporada() async {
    try {
      // Usar preferences.php que ya existe y funciona en la web antigua
      final uri = Uri.parse('$_baseUrl/endpoints/preferences.php').replace(
        queryParameters: {'action': 'getTemporada'},
      );

      _log('GET preferences.php: getTemporada');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          final idTemporada = data['idtemporada'] as int?;
          _log('getCurrentTemporada: $idTemporada');
          return idTemporada;
        }
      }
      return null;
    } catch (e) {
      _log('getCurrentTemporada ERROR: $e');
      return null;
    }
  }

  // ========================================
  // AUTENTICACIÓN ESPECÍFICA (Firebase)
  // ========================================

  @override
  Future<ApiResponse<Map<String, dynamic>>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      _log('signInWithPassword: email=$email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _log('signInWithPassword: OK');
        return ApiResponse.ok({
          'uid': credential.user!.uid,
          'email': credential.user!.email,
        });
      }

      return ApiResponse.error('No se pudo iniciar sesión');
    } on FirebaseAuthException catch (e) {
      _log('signInWithPassword FirebaseAuthException: ${e.message}');
      return ApiResponse.error(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      _log('signInWithPassword ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    String? nombre,
    String? apellidos,
    int? idclub,
  }) async {
    try {
      _log('signUp: email=$email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _log('signUp: OK');
        return ApiResponse.ok({
          'uid': credential.user!.uid,
          'email': credential.user!.email,
        });
      }

      return ApiResponse.error('No se pudo crear la cuenta');
    } on FirebaseAuthException catch (e) {
      _log('signUp FirebaseAuthException: ${e.message}');
      return ApiResponse.error(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      _log('signUp ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _log('signOut');
      await _auth.signOut();
      _log('signOut: OK');
    } catch (e) {
      _log('signOut ERROR: $e');
    }
  }

  @override
  Future<ApiResponse<void>> resetPasswordForEmail({required String email}) async {
    try {
      _log('resetPasswordForEmail: email=$email');

      await _auth.sendPasswordResetEmail(email: email);

      _log('resetPasswordForEmail: OK');
      return ApiResponse.ok(null);
    } on FirebaseAuthException catch (e) {
      _log('resetPasswordForEmail FirebaseAuthException: ${e.message}');
      return ApiResponse.error(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      _log('resetPasswordForEmail ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Convierte códigos de error de Firebase a mensajes amigables
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este email ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      default:
        return 'Error de autenticación: $code';
    }
  }

  // ========================================
  // EVENTOS DE PARTIDO
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEventosPartido({
    required int idpartido,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/eventos.php',
      {'action': 'getbypartido', 'idpartido': idpartido.toString()},
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  // ========================================
  // DASHBOARDS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardAsistencia({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/dashboard.php',
      {
        'action': 'asistencia',
        'idclub': idclub.toString(),
        'idtemporada': idtemporada.toString(),
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardProximosPartidos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
    int limit = 5,
  }) async {
    final params = {
      'action': 'proximos',
      'idclub': idclub.toString(),
      'idtemporada': idtemporada.toString(),
      'limit': limit.toString(),
    };
    if (idequipo != null) {
      params['idequipo'] = idequipo.toString();
    }

    return _get<List<Map<String, dynamic>>>(
      'endpoints/dashboard.php',
      params,
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardResultadosRecientes({
    required int idclub,
    required int idtemporada,
    int? idequipo,
    int limit = 5,
  }) async {
    final params = {
      'action': 'resultados',
      'idclub': idclub.toString(),
      'idtemporada': idtemporada.toString(),
      'limit': limit.toString(),
    };
    if (idequipo != null) {
      params['idequipo'] = idequipo.toString();
    }

    return _get<List<Map<String, dynamic>>>(
      'endpoints/dashboard.php',
      params,
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<int>> getConteoJugadores({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  }) async {
    final params = {
      'action': 'conteo_jugadores',
      'idclub': idclub.toString(),
      'idtemporada': idtemporada.toString(),
    };
    if (idequipo != null) {
      params['idequipo'] = idequipo.toString();
    }

    return _get<int>(
      'endpoints/dashboard.php',
      params,
      (data) => data as int,
    );
  }

  @override
  Future<ApiResponse<int>> getConteoEquipos({
    required int idclub,
    required int idtemporada,
  }) async {
    return _get<int>(
      'endpoints/dashboard.php',
      {
        'action': 'conteo_equipos',
        'idclub': idclub.toString(),
        'idtemporada': idtemporada.toString(),
      },
      (data) => data as int,
    );
  }

  @override
  Future<ApiResponse<int>> getConteoPartidos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  }) async {
    final params = {
      'action': 'conteo_partidos',
      'idclub': idclub.toString(),
      'idtemporada': idtemporada.toString(),
    };
    if (idequipo != null) {
      params['idequipo'] = idequipo.toString();
    }

    return _get<int>(
      'endpoints/dashboard.php',
      params,
      (data) => data as int,
    );
  }

  @override
  Future<ApiResponse<int>> getConteoEntrenamientos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  }) async {
    final params = {
      'action': 'conteo_entrenamientos',
      'idclub': idclub.toString(),
      'idtemporada': idtemporada.toString(),
    };
    if (idequipo != null) {
      params['idequipo'] = idequipo.toString();
    }

    return _get<int>(
      'endpoints/dashboard.php',
      params,
      (data) => data as int,
    );
  }

  // ========================================
  // TEMPORADAS (CRUD)
  // ========================================

  @override
  Future<ApiResponse<void>> createTemporada({
    required String temporada,
    required int idclub,
    bool activa = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/temporadas.php');
      final body = jsonEncode({
        'action': 'create',
        'temporada': temporada,
        'idclub': idclub,
        'activa': activa,
      });

      _log('POST temporadas.php: create');

      final response = await _client
          .post(uri, headers: await _getHeaders(), body: body)
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          _log('createTemporada: OK');
          return ApiResponse.ok(null);
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('createTemporada ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> updateTemporada({
    required int id,
    required String temporada,
    bool? activa,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/temporadas.php');
      final body = jsonEncode({
        'action': 'update',
        'id': id,
        'temporada': temporada,
        if (activa != null) 'activa': activa,
      });

      _log('POST temporadas.php: update');

      final response = await _client
          .post(uri, headers: await _getHeaders(), body: body)
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          _log('updateTemporada: OK');
          return ApiResponse.ok(null);
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('updateTemporada ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> setTemporadaActiva({
    required int id,
    required int idclub,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/temporadas.php');
      final body = jsonEncode({
        'action': 'setactiva',
        'id': id,
        'idclub': idclub,
      });

      _log('POST temporadas.php: setactiva');

      final response = await _client
          .post(uri, headers: await _getHeaders(), body: body)
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          _log('setTemporadaActiva: OK');
          return ApiResponse.ok(null);
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('setTemporadaActiva ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // USUARIOS (ADICIONAL)
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenadoresByClub({
    required int idclub,
  }) async {
    try {
      _log('getEntrenadoresByClub: idclub=$idclub');

      final uri = Uri.parse('$_baseUrl/endpoints/usuarios.php?action=entrenadores&idclub=$idclub');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          final data = json.cast<Map<String, dynamic>>().toList();
          _log('getEntrenadoresByClub: ${data.length} entrenadores');
          return ApiResponse.ok(data);
        }
        return ApiResponse.ok([]);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getEntrenadoresByClub ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountClubs() async {
    try {
      _log('getGlobalCountClubs');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=clubs');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountClubs: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountClubs ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountUsuarios() async {
    try {
      _log('getGlobalCountUsuarios');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=usuarios');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountUsuarios: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountUsuarios ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountEquipos() async {
    try {
      _log('getGlobalCountEquipos');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=equipos');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountEquipos: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountEquipos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountJugadores() async {
    try {
      _log('getGlobalCountJugadores');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=jugadores');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountJugadores: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountJugadores ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountEntrenamientos() async {
    try {
      _log('getGlobalCountEntrenamientos');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=entrenamientos');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountEntrenamientos: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountEntrenamientos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountPartidos() async {
    try {
      _log('getGlobalCountPartidos');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=partidos');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountPartidos: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountPartidos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountCuotas() async {
    try {
      _log('getGlobalCountCuotas');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=count&table=cuotas');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final count = json['count'] as int? ?? 0;
        _log('getGlobalCountCuotas: $count');
        return ApiResponse.ok(count);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getGlobalCountCuotas ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquiposPorCategoriaGlobal() async {
    try {
      _log('getEquiposPorCategoriaGlobal');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=equipos_por_categoria');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          final data = json.cast<Map<String, dynamic>>().toList();
          _log('getEquiposPorCategoriaGlobal: ${data.length} categorías');
          return ApiResponse.ok(data);
        }
        return ApiResponse.ok([]);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getEquiposPorCategoriaGlobal ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getUsuariosPorPermisoGlobal() async {
    try {
      _log('getUsuariosPorPermisoGlobal');

      final uri = Uri.parse('$_baseUrl/endpoints/stats.php?action=usuarios_por_permiso');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          final data = json.cast<Map<String, dynamic>>().toList();
          _log('getUsuariosPorPermisoGlobal: ${data.length} permisos');
          return ApiResponse.ok(data);
        }
        return ApiResponse.ok([]);
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getUsuariosPorPermisoGlobal ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // ESTADÍSTICAS DE PARTIDO
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasPartido({
    required int idequipo,
  }) async {
    try {
      _log('getEstadisticasPartido: idequipo=$idequipo');

      // Usar estadisticas_partido.php con la acción existente getEstadisticasPartidoByEquipo
      final uri = Uri.parse('$_baseUrl/endpoints/estadisticas_partido.php?action=getEstadisticasPartidoByEquipo&idequipo=$idequipo');

      _log('GET estadisticas_partido.php: idequipo=$idequipo');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      _log('getEstadisticasPartido: statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json['success'] == true) {
          final data = json['data'];
          if (data is List) {
            final stats = data.cast<Map<String, dynamic>>().toList();
            _log('getEstadisticasPartido: ${stats.length} registros');
            return ApiResponse.ok(stats);
          }
        }
        _log('getEstadisticasPartido: respuesta inesperada: $json');
        return ApiResponse.ok([]);
      }
      _log('getEstadisticasPartido: Error HTTP ${response.statusCode}, body=${response.body}');
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getEstadisticasPartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // PERFIL DE JUGADOR
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasJugador({
    required int idjugador,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/estadisticas_jugadores.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosJugador({
    required int idjugador,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/partidos_jugador.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientosJugador({
    required int idjugador,
    required int idtemporada,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/entrenos_jugadores.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
        'idtemporada': idtemporada,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLesionesJugador({
    required int idjugador,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/lesiones.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> createLesion({
    required int idjugador,
    required String lesion,
    required DateTime fechainicio,
    DateTime? fechafin,
    String? observaciones,
  }) async {
    return _post(
      'endpoints/lesiones.php',
      {'action': 'create'},
      {
        'idjugador': idjugador,
        'lesion': lesion,
        'fechainicio': fechainicio.toIso8601String().split('T')[0],
        if (fechafin != null) 'fechafin': fechafin.toIso8601String().split('T')[0],
        if (observaciones != null) 'observaciones': observaciones,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateLesion({
    required int id,
    String? lesion,
    DateTime? fechainicio,
    DateTime? fechafin,
    String? observaciones,
  }) async {
    return _post(
      'endpoints/lesiones.php',
      {'action': 'update'},
      {
        'id': id,
        if (lesion != null) 'lesion': lesion,
        if (fechainicio != null) 'fechainicio': fechainicio.toIso8601String().split('T')[0],
        if (fechafin != null) 'fechafin': fechafin.toIso8601String().split('T')[0],
        if (observaciones != null) 'observaciones': observaciones,
      },
    );
  }

  @override
  Future<ApiResponse<void>> deleteLesion({required int id}) async {
    return _post(
      'endpoints/lesiones.php',
      {'action': 'delete'},
      {'id': id},
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTallaPesoJugador({
    required int idjugador,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/talla_peso.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> createTallaPeso({
    required int idjugador,
    required DateTime fecha,
    required double talla,
    required double peso,
  }) async {
    return _post(
      'endpoints/talla_peso.php',
      {'action': 'create'},
      {
        'idjugador': idjugador,
        'fecha': fecha.toIso8601String().split('T')[0],
        'talla': talla,
        'peso': peso,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateTallaPeso({
    required int id,
    required DateTime fecha,
    required double talla,
    required double peso,
  }) async {
    return _post(
      'endpoints/talla_peso.php',
      {'action': 'update'},
      {
        'id': id,
        'fecha': fecha.toIso8601String().split('T')[0],
        'talla': talla,
        'peso': peso,
      },
    );
  }

  @override
  Future<ApiResponse<void>> deleteTallaPeso({required int id}) async {
    return _post(
      'endpoints/talla_peso.php',
      {'action': 'delete'},
      {'id': id},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getControlDeuda({
    required int idjugador,
    required int idtemporada,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/control_deuda.php').replace(
        queryParameters: {
          'action': 'getbyjugador',
          'idjugador': idjugador.toString(),
          'idtemporada': idtemporada.toString(),
        },
      );

      _log('GET control_deuda.php: idjugador=$idjugador, idtemporada=$idtemporada');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return ApiResponse.ok(json['data'] as Map<String, dynamic>);
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getControlDeuda ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> createReciboDeuda({
    required int idjugador,
    required int idtemporada,
    required double cantidad,
    required String concepto,
    required String metodopago,
    required DateTime fechapago,
  }) async {
    return _post(
      'endpoints/control_deuda.php',
      {'action': 'createrecibo'},
      {
        'idjugador': idjugador,
        'idtemporada': idtemporada,
        'cantidad': cantidad,
        'concepto': concepto,
        'metodopago': metodopago,
        'fechapago': fechapago.toIso8601String().split('T')[0],
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateReciboDeuda({
    required int id,
    double? cantidad,
    String? concepto,
    String? metodopago,
    DateTime? fechapago,
  }) async {
    return _post(
      'endpoints/control_deuda.php',
      {'action': 'updaterecibo'},
      {
        'id': id,
        if (cantidad != null) 'cantidad': cantidad,
        if (concepto != null) 'concepto': concepto,
        if (metodopago != null) 'metodopago': metodopago,
        if (fechapago != null) 'fechapago': fechapago.toIso8601String().split('T')[0],
      },
    );
  }

  @override
  Future<ApiResponse<void>> deleteReciboDeuda({required int id}) async {
    return _post(
      'endpoints/control_deuda.php',
      {'action': 'deleterecibo'},
      {'id': id},
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTutoresJugador({
    required int idjugador,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/jugador_tutores.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> createTutor({
    required int idjugador,
    required String nombre,
    required String apellidos,
    String? telefono,
    String? email,
    String? parentesco,
  }) async {
    return _post(
      'endpoints/jugador_tutores.php',
      {'action': 'create'},
      {
        'idjugador': idjugador,
        'nombre': nombre,
        'apellidos': apellidos,
        if (telefono != null) 'telefono': telefono,
        if (email != null) 'email': email,
        if (parentesco != null) 'parentesco': parentesco,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateTutor({
    required int id,
    String? nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? parentesco,
  }) async {
    return _post(
      'endpoints/jugador_tutores.php',
      {'action': 'update'},
      {
        'id': id,
        if (nombre != null) 'nombre': nombre,
        if (apellidos != null) 'apellidos': apellidos,
        if (telefono != null) 'telefono': telefono,
        if (email != null) 'email': email,
        if (parentesco != null) 'parentesco': parentesco,
      },
    );
  }

  @override
  Future<ApiResponse<void>> deleteTutor({
    required int idjugador,
    required int idtutor,
  }) async {
    return _post(
      'endpoints/jugador_tutores.php',
      {'action': 'delete'},
      {
        'idjugador': idjugador,
        'idtutor': idtutor,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCarnetsJugador({
    required int idjugador,
  }) async {
    return _get<List<Map<String, dynamic>>>(
      'endpoints/carnets.php',
      {
        'action': 'getbyjugador',
        'idjugador': idjugador,
      },
      (data) => data.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Future<ApiResponse<void>> createCarnet({
    required int idjugador,
    required int idtemporada,
    String? foto,
  }) async {
    return _post(
      'endpoints/carnets.php',
      {'action': 'create'},
      {
        'idjugador': idjugador,
        'idtemporada': idtemporada,
        if (foto != null) 'foto': foto,
      },
    );
  }

  @override
  Future<ApiResponse<void>> updateNotaJugador({
    required int idjugador,
    required String nota,
  }) async {
    return _post(
      'endpoints/jugadores.php',
      {'action': 'updatenota'},
      {
        'id': idjugador,
        'nota': nota,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getFichaFederativa({
    required int idjugador,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoints/jugadores.php').replace(
        queryParameters: {
          'action': 'getficha',
          'id': idjugador.toString(),
        },
      );

      _log('GET jugadores.php ficha: id=$idjugador');

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          return ApiResponse.ok(json['data'] as Map<String, dynamic>);
        }
        return ApiResponse.error(json['message']?.toString() ?? 'Error');
      }
      return ApiResponse.error('Error HTTP ${response.statusCode}');
    } catch (e) {
      _log('getFichaFederativa ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> updateFichaFederativa({
    required int idjugador,
    String? ficha,
    DateTime? fechaficha,
  }) async {
    return _post(
      'endpoints/jugadores.php',
      {'action': 'updateficha'},
      {
        'id': idjugador,
        if (ficha != null) 'ficha': ficha,
        if (fechaficha != null) 'fechaficha': fechaficha.toIso8601String().split('T')[0],
      },
    );
  }
}
