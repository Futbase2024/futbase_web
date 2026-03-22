import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:futbase_web_3/core/datasources/app_datasource.dart';
import 'package:futbase_web_3/core/datasources/api_response.dart';

/// Implementación de AppDataSource usando Supabase
class SupabaseDataSource implements AppDataSource {
  SupabaseDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🔵 [SupabaseDS] $message');
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
    try {
      _log('getCuotas: idclub=$idclub, idtemporada=$idtemporada');

      final response = await _client
          .from('vcuotas')
          .select('''
            id,
            idclub,
            idequipo,
            equipo,
            idjugador,
            nombre,
            apellidos,
            mes,
            year,
            idestado,
            estado,
            cantidad,
            idtipocuota,
            tipo,
            idtemporada,
            temporada,
            icono,
            timestamp
          ''')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada)
          .order('year', ascending: false)
          .order('mes', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      // Añadir campos calculados para compatibilidad
      for (final fee in data) {
        fee['jugador_nombre'] = '${fee['nombre'] ?? ''} ${fee['apellidos'] ?? ''}'.trim();
        fee['equipo_nombre'] = fee['equipo'] ?? '-';
      }

      _log('getCuotas: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getCuotas ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> updateCuotaEstado({
    required int idCuota,
    required int idEstado,
  }) async {
    try {
      _log('updateCuotaEstado: idCuota=$idCuota, idEstado=$idEstado');

      await _client
          .from('tcuotas')
          .update({'idestado': idEstado})
          .eq('id', idCuota);

      _log('updateCuotaEstado: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('updateCuotaEstado ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('createReciboPago: idclub=$idclub, idjugador=$idjugador');

      await _client.from('trecibos_pagos').insert({
        'idclub': idclub,
        'idjugador': idjugador,
        'idtemporada': idtemporada,
        'cantidad': cantidad,
        'fecha_pago': DateTime.now().toIso8601String(),
        'concepto': concepto,
        'metodo_pago': metodoPago,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _log('createReciboPago: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('createReciboPago ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // ENTRENAMIENTOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientos({
    required int idequipo,
    required int idtemporada,
  }) async {
    try {
      _log('getEntrenamientos: idequipo=$idequipo, idtemporada=$idtemporada');

      final response = await _client
          .from('ventrenamientos')
          .select('''
            id,
            fecha,
            hinicio,
            hfin,
            idequipo,
            nombre,
            observaciones,
            finalizado,
            campo
          ''')
          .eq('idequipo', idequipo)
          .eq('idtemporada', idtemporada)
          .order('fecha', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEntrenamientos: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEntrenamientos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientosByClub({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getEntrenamientosByClub: idclub=$idclub, idtemporada=$idtemporada');

      // Primero obtener equipos del club
      final equiposResponse = await _client
          .from('vequipos')
          .select('id, equipo, ncorto, idcategoria')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final equipoIds = (equiposResponse as List)
          .map((e) => e['id'] as int)
          .toList();

      if (equipoIds.isEmpty) {
        return ApiResponse.ok([]);
      }

      // Obtener entrenamientos de todos los equipos
      final response = await _client
          .from('ventrenamientos')
          .select('''
            id,
            fecha,
            hinicio,
            hfin,
            idequipo,
            nombre,
            observaciones,
            finalizado,
            campo
          ''')
          .inFilter('idequipo', equipoIds)
          .eq('idtemporada', idtemporada)
          .order('fecha', ascending: true)
          .order('hinicio', ascending: true);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEntrenamientosByClub: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEntrenamientosByClub ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> createEntrenamiento({
    required int idequipo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    String? observaciones,
  }) async {
    try {
      _log('createEntrenamiento: idequipo=$idequipo');

      await _client.from('tentrenamientos').insert({
        'idequipo': idequipo,
        'fecha': fecha.toIso8601String().split('T')[0],
        'hinicio': horaInicio,
        'hfin': horaFin,
        'nombre': observaciones,
        'observaciones': observaciones,
      });

      _log('createEntrenamiento: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('createEntrenamiento ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('updateEntrenamiento: id=$id');

      await _client
          .from('tentrenamientos')
          .update({
            'fecha': fecha.toIso8601String().split('T')[0],
            'hinicio': horaInicio,
            'hfin': horaFin,
            'nombre': observaciones,
            'observaciones': observaciones,
          })
          .eq('id', id);

      _log('updateEntrenamiento: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('updateEntrenamiento ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteEntrenamiento({
    required int id,
  }) async {
    try {
      _log('deleteEntrenamiento: id=$id');

      await _client
          .from('tentrenamientos')
          .delete()
          .eq('id', id);

      _log('deleteEntrenamiento: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('deleteEntrenamiento ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // ASISTENCIA A ENTRENAMIENTOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMotivosAsistencia() async {
    try {
      _log('getMotivosAsistencia');

      final response = await _client
          .from('tmotivoasistencia')
          .select('id, motivo')
          .order('id');

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getMotivosAsistencia: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getMotivosAsistencia ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getAsistenciaEntrenamiento({
    required int identrenamiento,
  }) async {
    try {
      _log('getAsistenciaEntrenamiento: identrenamiento=$identrenamiento');

      final response = await _client
          .from('ventrenojugador')
          .select('idjugador, nombrejug, apellidos, asiste, idmotivo, motivo, observaciones, idequipo, idclub')
          .eq('identrenamiento', identrenamiento)
          .order('nombrejug')
          .order('apellidos');

      final attendanceData = response as List<dynamic>;

      if (attendanceData.isEmpty) {
        return ApiResponse.ok([]);
      }

      // Obtener datos adicionales de jugadores
      final jugadorIds = attendanceData
          .map((att) => att['idjugador'] as int)
          .toSet()
          .toList();

      final jugadoresData = await _client
          .from('tjugadores')
          .select('id, dorsal, foto, idposicion')
          .inFilter('id', jugadorIds);

      final jugadoresMap = <int, Map<String, dynamic>>{};
      for (final jug in jugadoresData) {
        jugadoresMap[jug['id'] as int] = jug;
      }

      // Construir lista completa
      final data = <Map<String, dynamic>>[];
      for (final att in attendanceData) {
        final idJugador = att['idjugador'] as int;
        final jugadorExtra = jugadoresMap[idJugador];

        data.add({
          'id': idJugador,
          'nombre': att['nombrejug']?.toString() ?? '',
          'apellidos': att['apellidos']?.toString() ?? '',
          'dorsal': jugadorExtra?['dorsal']?.toString() ?? '',
          'foto': jugadorExtra?['foto']?.toString() ?? '',
          'idposicion': jugadorExtra?['idposicion'],
          'asiste': (att['asiste'] as int?) == 1,
          'idmotivo': att['idmotivo'] as int?,
          'motivo': att['motivo']?.toString(),
          'observaciones': att['observaciones']?.toString(),
          'idequipo': att['idequipo'] as int?,
          'idclub': att['idclub'] as int?,
        });
      }

      _log('getAsistenciaEntrenamiento: ${data.length} jugadores');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getAsistenciaEntrenamiento ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> saveAsistenciaEntrenamiento({
    required int identrenamiento,
    required int idequipo,
    required int idclub,
    required List<Map<String, dynamic>> asistencia,
  }) async {
    try {
      _log('saveAsistenciaEntrenamiento: identrenamiento=$identrenamiento, ${asistencia.length} registros');

      // Eliminar asistencia anterior
      await _client
          .from('tentrenojugador')
          .delete()
          .eq('identrenamiento', identrenamiento);

      // Insertar nueva asistencia
      final inserts = asistencia.map((item) {
        return {
          'identrenamiento': identrenamiento,
          'idjugador': item['idjugador'],
          'idequipo': idequipo,
          'idclub': idclub,
          'asiste': item['asiste'] == true ? 1 : 0,
          'motivo': item['idmotivo'],
          'observaciones': item['observaciones'],
        };
      }).toList();

      if (inserts.isNotEmpty) {
        await _client.from('tentrenojugador').insert(inserts);
      }

      _log('saveAsistenciaEntrenamiento: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('saveAsistenciaEntrenamiento ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasAsistencia({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getEstadisticasAsistencia: idclub=$idclub');

      final response = await _client
          .from('vm_asistencia_stats')
          .select('idequipo, total, presentes')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEstadisticasAsistencia: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEstadisticasAsistencia ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // EQUIPOS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquipos({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getEquipos: idclub=$idclub, idtemporada=$idtemporada');

      final response = await _client
          .from('vequipos')
          .select('id, equipo, ncorto, idcategoria, idclub')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEquipos: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEquipos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategorias() async {
    try {
      _log('getCategorias');

      final response = await _client
          .from('tcategorias')
          .select('id, categoria')
          .order('id');

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getCategorias: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getCategorias ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<int>>> getEquiposIds({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getEquiposIds: idclub=$idclub, idtemporada=$idtemporada');

      final response = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final ids = (response as List).map((e) => e['id'] as int).toList();

      _log('getEquiposIds: ${ids.length} IDs');
      return ApiResponse.ok(ids);
    } catch (e) {
      _log('getEquiposIds ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquiposInfo({
    required List<int> ids,
  }) async {
    try {
      _log('getEquiposInfo: ${ids.length} ids');

      if (ids.isEmpty) return ApiResponse.ok([]);

      final response = await _client
          .from('tequipos')
          .select('id, ncorto, equipo')
          .inFilter('id', ids);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEquiposInfo: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEquiposInfo ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('createEquipo: $equipo');

      await _client.from('tequipos').insert({
        'idclub': idclub,
        'idcategoria': idcategoria,
        'idtemporada': idtemporada,
        'equipo': equipo,
        'ncorto': ncorto,
        'titulares': titulares,
        'minutos': minutos,
      });

      _log('createEquipo: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('createEquipo ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('updateEquipo: id=$id');

      await _client
          .from('tequipos')
          .update({
            'idcategoria': idcategoria,
            'idtemporada': idtemporada,
            'equipo': equipo,
            'ncorto': ncorto,
            'titulares': titulares,
            'minutos': minutos,
          })
          .eq('id', id);

      _log('updateEquipo: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('updateEquipo ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteEquipo({required int id}) async {
    try {
      _log('deleteEquipo: id=$id');

      await _client.from('tequipos').delete().eq('id', id);

      _log('deleteEquipo: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('deleteEquipo ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('getJugadoresEquipo: idequipo=$idequipo');

      final response = await _client
          .from('vjugadores')
          .select('id, nombre, apellidos, dorsal, foto, idposicion, fechanacimiento, activo')
          .eq('idequipo', idequipo)
          .eq('activo', 1)
          .order('nombre')
          .order('apellidos');

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getJugadoresEquipo: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getJugadoresEquipo ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresByClub({
    required int idclub,
    required int idtemporada,
    bool soloActivos = true,
  }) async {
    try {
      _log('getJugadoresByClub: idclub=$idclub, idtemporada=$idtemporada');

      var query = _client
          .from('vjugadores')
          .select('id, idequipo, nombre, apellidos, apodo, dorsal, idposicion, posicion, foto, activo, equipo, fechanacimiento')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada)
          .eq('visible', 1);

      if (soloActivos) {
        query = query.eq('activo', 1);
      }

      final response = await query.order('dorsal');
      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getJugadoresByClub: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getJugadoresByClub ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresDatos({
    required List<int> ids,
  }) async {
    try {
      _log('getJugadoresDatos: ${ids.length} ids');

      if (ids.isEmpty) return ApiResponse.ok([]);

      final response = await _client
          .from('tjugadores')
          .select('id, dorsal, foto, idposicion')
          .inFilter('id', ids);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getJugadoresDatos: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getJugadoresDatos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPosiciones() async {
    try {
      _log('getPosiciones');

      final response = await _client
          .from('tposiciones')
          .select('id, posicion')
          .order('id');

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getPosiciones: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getPosiciones ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('getPartidos: idequipo=$idequipo, idtemporada=$idtemporada');

      final response = await _client
          .from('vpartido')
          .select('''
            id, idjornada, idtemporada, idcategoria, idequipo, idclub,
            idrival, idclubrival, rival, ncortorival, ncortoclubrival,
            fecha, hora, horaconvocatoria, casafuera, goles, golesrival,
            finalizado, minuto, jornada, jcorta, temporada, categoria,
            club, escudo, ncortoclub, equipo, ncortoequipo, campo,
            escudorival, observaciones, obsconvocatoria, sistema,
            titulares, clubequipo, camiseta, camisetapor, descanso
          ''')
          .eq('idequipo', idequipo)
          .eq('idtemporada', idtemporada)
          .order('fecha', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getPartidos: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getPartidos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosByClub({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getPartidosByClub: idclub=$idclub, idtemporada=$idtemporada');

      // Obtener IDs de equipos del club
      final equiposResponse = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final equipoIds = (equiposResponse as List)
          .map((e) => e['id'] as int)
          .toList();

      if (equipoIds.isEmpty) {
        return ApiResponse.ok([]);
      }

      final response = await _client
          .from('vpartido')
          .select('''
            id, idjornada, idtemporada, idcategoria, idequipo, idclub,
            idrival, idclubrival, rival, ncortorival, ncortoclubrival,
            fecha, hora, horaconvocatoria, casafuera, goles, golesrival,
            finalizado, minuto, jornada, jcorta, temporada, categoria,
            club, escudo, ncortoclub, equipo, ncortoequipo, campo,
            escudorival, observaciones, obsconvocatoria, sistema,
            titulares, clubequipo, camiseta, camisetapor, descanso
          ''')
          .inFilter('idequipo', equipoIds)
          .eq('idtemporada', idtemporada)
          .order('fecha', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getPartidosByClub: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getPartidosByClub ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosByDateRange({
    required int idtemporada,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _log('getPartidosByDateRange: $startDate - $endDate');

      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      final response = await _client
          .from('vpartido')
          .select('''
            id, idequipo, idclub, equipo, ncortoequipo, rival, ncortorival,
            fecha, hora, casafuera, goles, golesrival, finalizado, descanso,
            minuto, jornada, escudo, escudorival, campo, categoria
          ''')
          .eq('idtemporada', idtemporada)
          .gte('fecha', startStr)
          .lt('fecha', endStr)
          .order('fecha', ascending: true)
          .order('hora', ascending: true);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getPartidosByDateRange: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getPartidosByDateRange ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPartido({required int idpartido}) async {
    try {
      _log('getPartido: idpartido=$idpartido');

      final response = await _client
          .from('vpartido')
          .select('*')
          .eq('id', idpartido)
          .single();

      _log('getPartido: OK');
      return ApiResponse.ok(response);
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
    try {
      _log('createPartido: $rival');

      await _client.from('tpartidos').insert({
        'idequipo': idequipo,
        'idtemporada': idtemporada,
        'fecha': fecha.toIso8601String().split('T')[0],
        'rival': rival,
        'casafuera': local ? 0 : 1,
        'finalizado': 0,
      });

      _log('createPartido: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('createPartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('updatePartido: id=$id');

      await _client
          .from('tpartidos')
          .update({
            'idtemporada': idtemporada,
            'fecha': fecha.toIso8601String().split('T')[0],
            'rival': rival,
            'casafuera': local ? 0 : 1,
            'goles': golesLocal,
            'golesrival': golesVisitante,
            'finalizado': finalizado == true ? 1 : 0,
          })
          .eq('id', id);

      _log('updatePartido: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('updatePartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deletePartido({required int id}) async {
    try {
      _log('deletePartido: id=$id');

      await _client.from('tpartidos').delete().eq('id', id);

      _log('deletePartido: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('deletePartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // ALINEACIÓN Y CONVOCATORIA
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLineup({
    required int idpartido,
  }) async {
    try {
      _log('getLineup: idpartido=$idpartido');

      final response = await _client
          .from('vpartidosjugadores')
          .select('idjugador, titular, mentra, apodo, dorsal, posicion, foto, convocado, posx, posy')
          .eq('idpartido', idpartido)
          .eq('convocado', 1)
          .order('dorsal');

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getLineup: ${data.length} jugadores');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getLineup ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPartidoCamisetas({
    required int idpartido,
  }) async {
    try {
      _log('getPartidoCamisetas: idpartido=$idpartido');

      final partidoData = await _client
          .from('tpartidos')
          .select('camiseta, camisetapor')
          .eq('id', idpartido)
          .maybeSingle();

      if (partidoData == null) {
        return ApiResponse.ok({});
      }

      String? camisetaUrl;
      String? camisetaPorteroUrl;
      int dorsalColor = 0;

      final camisetaId = partidoData['camiseta'] as int?;
      final camisetaporId = partidoData['camisetapor'] as int?;

      if (camisetaId != null || camisetaporId != null) {
        final camisetaIds = [camisetaId, camisetaporId].whereType<int>().toList();
        if (camisetaIds.isNotEmpty) {
          final camisetasData = await _client
              .from('tcamisetas')
              .select('id, url, idcolor')
              .inFilter('id', camisetaIds);

          for (final cam in camisetasData as List) {
            final id = cam['id'] as int;
            final url = cam['url'] as String?;
            final color = cam['idcolor'] as int? ?? 0;

            if (id == camisetaId) {
              camisetaUrl = url;
              dorsalColor = color;
            }
            if (id == camisetaporId) {
              camisetaPorteroUrl = url;
            }
          }
        }
      }

      _log('getPartidoCamisetas: OK');
      return ApiResponse.ok({
        'camisetaUrl': camisetaUrl,
        'camisetaPorteroUrl': camisetaPorteroUrl,
        'dorsalColor': dorsalColor,
      });
    } catch (e) {
      _log('getPartidoCamisetas ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteConvocatoria({required int idpartido}) async {
    try {
      _log('deleteConvocatoria: idpartido=$idpartido');

      await _client
          .from('tconvpartidos')
          .delete()
          .eq('idpartido', idpartido);

      _log('deleteConvocatoria: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('deleteConvocatoria ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> saveLineup({
    required int idpartido,
    required List<Map<String, dynamic>> lineup,
  }) async {
    try {
      _log('saveLineup: idpartido=$idpartido, ${lineup.length} jugadores');

      // Eliminar convocatoria anterior
      await deleteConvocatoria(idpartido: idpartido);

      // Insertar nueva convocatoria
      if (lineup.isNotEmpty) {
        final inserts = lineup.map((entry) {
          return {
            'idpartido': idpartido,
            'idjugador': entry['idjugador'],
            'titular': entry['titular'] == true ? 1 : 0,
            'convocado': 1,
            'mentra': entry['mentra'],
            'posx': entry['posx'],
            'posy': entry['posy'],
          };
        }).toList();

        await _client.from('tconvpartidos').insert(inserts);
      }

      _log('saveLineup: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('saveLineup ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
    try {
      _log('upsertConvocatoria: idpartido=$idpartido, idjugador=$idjugador');

      await _client.from('tconvpartidos').upsert({
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
      }, onConflict: 'idpartido,idjugador');

      _log('upsertConvocatoria: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('upsertConvocatoria ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getConvocatoria({
    required int idpartido,
  }) async {
    try {
      _log('getConvocatoria: idpartido=$idpartido');

      final response = await _client
          .from('tconvpartidos')
          .select('idjugador')
          .eq('idpartido', idpartido)
          .eq('convocado', 1);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getConvocatoria: ${data.length} convocados');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getConvocatoria ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> updateConvocatoriaDorsal({
    required int idpartido,
    required int idjugador,
    int? dorsal,
  }) async {
    try {
      _log('updateConvocatoriaDorsal: idpartido=$idpartido, idjugador=$idjugador');

      // Verificar dorsal duplicado
      if (dorsal != null) {
        final existing = await _client
            .from('tconvpartidos')
            .select('idjugador')
            .eq('idpartido', idpartido)
            .eq('dorsal', dorsal)
            .neq('idjugador', idjugador)
            .maybeSingle();

        if (existing != null) {
          _log('updateConvocatoriaDorsal: Dorsal ya asignado');
          return ApiResponse.ok(null);
        }
      }

      await _client
          .from('tconvpartidos')
          .update({'dorsal': dorsal})
          .eq('idpartido', idpartido)
          .eq('idjugador', idjugador);

      _log('updateConvocatoriaDorsal: OK');
      return ApiResponse.ok(null);
    } catch (e) {
      _log('updateConvocatoriaDorsal ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
      _log('getClub: idclub=$idclub');

      final response = await _client
          .from('tclub')
          .select('*')
          .eq('id', idclub)
          .single();

      _log('getClub: OK');
      return ApiResponse.ok(response);
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
      _log('getTemporadaActiva: idclub=$idclub');

      final response = await _client
          .from('ttemporadas')
          .select('*')
          .eq('idclub', idclub)
          .eq('activa', true)
          .single();

      _log('getTemporadaActiva: OK');
      return ApiResponse.ok(response);
    } catch (e) {
      _log('getTemporadaActiva ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTemporadas() async {
    try {
      _log('getTemporadas');

      final response = await _client
          .from('ttemporadas')
          .select('id, temporada')
          .order('id', ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getTemporadas: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getTemporadas ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // AUTENTICACIÓN
  // ========================================

  @override
  Future<String?> getAuthToken() async {
    final session = _client.auth.currentSession;
    return session?.accessToken;
  }

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  String? get currentUserEmail => _client.auth.currentUser?.email;

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
      _log('getScoutingPlayers: idclub=$idclub, idtemporada=$idtemporada');

      dynamic query = _client
          .from('vjugadores')
          .select('''
            id, nombre, apellidos, apodo, foto, dorsal,
            idposicion, posicion,
            idcategoria, categoria,
            idpiedominante, pie,
            fechanacimiento, altura, peso,
            idtemporada, temporada,
            idequipo, equipo,
            idclub, club,
            pj, ptitular, plesionado,
            goles, penalti, ta, ta2, tr,
            minutos, valoracion, capitan
          ''');

      // Aplicar filtros
      if (idclub != null) {
        query = query.eq('idclub', idclub);
      }
      if (idtemporada != null) {
        query = query.eq('idtemporada', idtemporada);
      }
      if (idposiciones != null && idposiciones.isNotEmpty) {
        query = query.inFilter('idposicion', idposiciones);
      }
      if (idcategorias != null && idcategorias.isNotEmpty) {
        query = query.inFilter('idcategoria', idcategorias);
      }
      if (idpiedominante != null) {
        query = query.eq('idpiedominante', idpiedominante);
      }

      // Ordenar
      final response = await query
          .order('nombre', ascending: true)
          .order('apellidos', ascending: true);

      var players = (response as List<dynamic>).cast<Map<String, dynamic>>();

      // Filtrar por búsqueda en memoria
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        players = players.where((player) {
          final nombre = (player['nombre'] ?? '').toString().toLowerCase();
          final apellidos = (player['apellidos'] ?? '').toString().toLowerCase();
          final apodo = (player['apodo'] ?? '').toString().toLowerCase();
          final equipo = (player['equipo'] ?? '').toString().toLowerCase();
          return '$nombre $apellidos $apodo'.contains(lowerQuery) ||
              equipo.contains(lowerQuery);
        }).toList();
      }

      _log('getScoutingPlayers: ${players.length} jugadores');
      return ApiResponse.ok(players);
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
      _log('getPlayerHistory: jugadorId=$jugadorId');

      final response = await _client
          .from('vjugadores')
          .select('''
            id, nombre, apellidos, apodo,
            idtemporada, temporada,
            pj, ptitular, plesionado,
            goles, penalti, ta, ta2, tr,
            minutos, valoracion, capitan,
            categoria, equipo
          ''')
          .eq('id', jugadorId)
          .order('idtemporada');

      final data = (response as List<dynamic>).cast<Map<String, dynamic>>();

      _log('getPlayerHistory: ${data.length} temporadas');
      return ApiResponse.ok(data);
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
      _log('getUsuarioByUid: uid=$uid');

      // Obtener usuario de tusuarios
      final userResponse = await _client
          .from('tusuarios')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (userResponse == null) {
        return null;
      }

      // Obtener rol activo de troles
      final rolResponse = await _client
          .from('troles')
          .select()
          .eq('uid', uid)
          .eq('selectedrol', 1)
          .maybeSingle();

      // Si hay rol activo, mergear sus valores
      if (rolResponse != null) {
        _log('getUsuarioByUid: Found active role - tipo: ${rolResponse['tipo']}');
        userResponse['idclub'] = rolResponse['idclub'] ?? userResponse['idclub'];
        userResponse['idequipo'] = rolResponse['idequipo'] ?? userResponse['idequipo'];
        userResponse['permisos'] = rolResponse['tipo'] ?? userResponse['permisos'];
      }

      return userResponse;
    } catch (e) {
      _log('getUsuarioByUid ERROR: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUsuarioByEmail({required String email}) async {
    try {
      _log('getUsuarioByEmail: email=$email');

      final response = await _client
          .from('tusuarios')
          .select()
          .eq('email', email)
          .maybeSingle();

      return response;
    } catch (e) {
      _log('getUsuarioByEmail ERROR: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUsuarioById({required String id}) async {
    try {
      _log('getUsuarioById: id=$id');

      final response = await _client
          .from('tusuarios')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response;
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
      _log('updateUsuarioUid: userId=$userId, uid=$uid');

      final userIdInt = int.parse(userId);

      // Actualizar en tusuarios
      await _client
          .from('tusuarios')
          .update({'uid': uid})
          .eq('id', userIdInt);

      // Actualizar en troles
      await _client
          .from('troles')
          .update({'uid': uid})
          .eq('idusuario', userIdInt);

      _log('updateUsuarioUid: OK');
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
      _log('createUsuario: email=$email');

      final response = await _client
          .from('tusuarios')
          .insert({
            'nombre': nombre,
            'apellidos': apellidos,
            'email': email,
            'idclub': idclub,
            'idequipo': 0,
            'permisos': 1,
            'uid': uid,
          })
          .select()
          .single();

      _log('createUsuario: OK');
      return response;
    } catch (e) {
      _log('createUsuario ERROR: $e');
      return null;
    }
  }

  @override
  Future<int?> getCurrentTemporada() async {
    try {
      _log('getCurrentTemporada');

      final response = await _client
          .from('tconfig')
          .select('idtemporada')
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final idTemporada = response['idtemporada'] as int?;
        _log('getCurrentTemporada: $idTemporada');
        return idTemporada;
      }
      return null;
    } catch (e) {
      _log('getCurrentTemporada ERROR: $e');
      return null;
    }
  }

  // ========================================
  // AUTENTICACIÓN ESPECÍFICA
  // ========================================

  @override
  Future<ApiResponse<Map<String, dynamic>>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      _log('signInWithPassword: email=$email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _log('signInWithPassword: OK');
        return ApiResponse.ok({
          'uid': response.user!.id,
          'email': response.user!.email,
        });
      }

      return ApiResponse.error('No se pudo iniciar sesión');
    } on AuthException catch (e) {
      _log('signInWithPassword AuthException: ${e.message}');
      return ApiResponse.error(e.message);
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

      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _log('signUp: OK');
        return ApiResponse.ok({
          'uid': response.user!.id,
          'email': response.user!.email,
        });
      }

      return ApiResponse.error('No se pudo crear la cuenta');
    } on AuthException catch (e) {
      _log('signUp AuthException: ${e.message}');
      return ApiResponse.error(e.message);
    } catch (e) {
      _log('signUp ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _log('signOut');
      await _client.auth.signOut();
      _log('signOut: OK');
    } catch (e) {
      _log('signOut ERROR: $e');
    }
  }

  @override
  Future<ApiResponse<void>> resetPasswordForEmail({required String email}) async {
    try {
      _log('resetPasswordForEmail: email=$email');

      await _client.auth.resetPasswordForEmail(email);

      _log('resetPasswordForEmail: OK');
      return ApiResponse.ok(null);
    } on AuthException catch (e) {
      _log('resetPasswordForEmail AuthException: ${e.message}');
      return ApiResponse.error(e.message);
    } catch (e) {
      _log('resetPasswordForEmail ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // EVENTOS DE PARTIDO
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEventosPartido({
    required int idpartido,
  }) async {
    try {
      _log('getEventosPartido: idpartido=$idpartido');

      final response = await _client
          .from('veventos')
          .select('*')
          .eq('idpartido', idpartido)
          .order('minuto');

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEventosPartido: ${data.length} eventos');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEventosPartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // DASHBOARDS
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardAsistencia({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getDashboardAsistencia: idclub=$idclub');

      final response = await _client
          .from('vm_asistencia_stats')
          .select('idequipo, total, presentes')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getDashboardAsistencia: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getDashboardAsistencia ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardProximosPartidos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
    int limit = 5,
  }) async {
    try {
      _log('getDashboardProximosPartidos: idclub=$idclub');

      final hoy = DateTime.now().toIso8601String().split('T')[0];

      // Obtener IDs de equipos del club
      final equiposResponse = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final equipoIds = (equiposResponse as List).map((e) => e['id'] as int).toList();

      if (equipoIds.isEmpty) {
        return ApiResponse.ok([]);
      }

      var query = _client
          .from('vpartido')
          .select('''
            id, idequipo, idclub, equipo, ncortoequipo, rival, ncortorival,
            fecha, hora, casafuera, goles, golesrival, finalizado,
            jornada, escudo, escudorival, campo, categoria
          ''')
          .inFilter('idequipo', idequipo != null ? [idequipo] : equipoIds)
          .eq('idtemporada', idtemporada)
          .gte('fecha', hoy)
          .eq('finalizado', 0)
          .order('fecha')
          .order('hora')
          .limit(limit);

      final response = await query;
      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getDashboardProximosPartidos: ${data.length} partidos');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getDashboardProximosPartidos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardResultadosRecientes({
    required int idclub,
    required int idtemporada,
    int? idequipo,
    int limit = 5,
  }) async {
    try {
      _log('getDashboardResultadosRecientes: idclub=$idclub');

      // Obtener IDs de equipos del club
      final equiposResponse = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final equipoIds = (equiposResponse as List).map((e) => e['id'] as int).toList();

      if (equipoIds.isEmpty) {
        return ApiResponse.ok([]);
      }

      final response = await _client
          .from('vpartido')
          .select('''
            id, idequipo, idclub, equipo, ncortoequipo, rival, ncortorival,
            fecha, hora, casafuera, goles, golesrival, finalizado,
            jornada, escudo, escudorival, campo, categoria
          ''')
          .inFilter('idequipo', idequipo != null ? [idequipo] : equipoIds)
          .eq('idtemporada', idtemporada)
          .eq('finalizado', 1)
          .order('fecha', ascending: false)
          .limit(limit);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getDashboardResultadosRecientes: ${data.length} partidos');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getDashboardResultadosRecientes ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getConteoJugadores({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  }) async {
    try {
      _log('getConteoJugadores: idclub=$idclub');

      var query = _client
          .from('vjugadores')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada)
          .eq('activo', 1);

      if (idequipo != null) {
        query = query.eq('idequipo', idequipo);
      }

      final response = await query;
      final count = (response as List).length;

      _log('getConteoJugadores: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getConteoJugadores ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getConteoEquipos({
    required int idclub,
    required int idtemporada,
  }) async {
    try {
      _log('getConteoEquipos: idclub=$idclub');

      final response = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final count = (response as List).length;

      _log('getConteoEquipos: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getConteoEquipos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getConteoPartidos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  }) async {
    try {
      _log('getConteoPartidos: idclub=$idclub');

      // Obtener IDs de equipos del club
      final equiposResponse = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final equipoIds = (equiposResponse as List).map((e) => e['id'] as int).toList();

      if (equipoIds.isEmpty) {
        return ApiResponse.ok(0);
      }

      final response = await _client
          .from('vpartido')
          .select('id')
          .inFilter('idequipo', idequipo != null ? [idequipo] : equipoIds)
          .eq('idtemporada', idtemporada);

      final count = (response as List).length;

      _log('getConteoPartidos: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getConteoPartidos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getConteoEntrenamientos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  }) async {
    try {
      _log('getConteoEntrenamientos: idclub=$idclub');

      // Obtener IDs de equipos del club
      final equiposResponse = await _client
          .from('vequipos')
          .select('id')
          .eq('idclub', idclub)
          .eq('idtemporada', idtemporada);

      final equipoIds = (equiposResponse as List).map((e) => e['id'] as int).toList();

      if (equipoIds.isEmpty) {
        return ApiResponse.ok(0);
      }

      final response = await _client
          .from('ventrenamientos')
          .select('id')
          .inFilter('idequipo', idequipo != null ? [idequipo] : equipoIds)
          .eq('idtemporada', idtemporada);

      final count = (response as List).length;

      _log('getConteoEntrenamientos: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getConteoEntrenamientos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
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
      _log('createTemporada: $temporada');

      await _client.from('ttemporadas').insert({
        'temporada': temporada,
        'idclub': idclub,
        'activa': activa,
      });

      _log('createTemporada: OK');
      return ApiResponse.ok(null);
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
      _log('updateTemporada: id=$id');

      final updates = <String, dynamic>{'temporada': temporada};
      if (activa != null) {
        updates['activa'] = activa;
      }

      await _client
          .from('ttemporadas')
          .update(updates)
          .eq('id', id);

      _log('updateTemporada: OK');
      return ApiResponse.ok(null);
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
      _log('setTemporadaActiva: id=$id, idclub=$idclub');

      // Desactivar todas las temporadas del club
      await _client
          .from('ttemporadas')
          .update({'activa': false})
          .eq('idclub', idclub);

      // Activar la temporada seleccionada
      await _client
          .from('ttemporadas')
          .update({'activa': true})
          .eq('id', id);

      // Actualizar tconfig
      await _client
          .from('tconfig')
          .update({'idtemporada': id})
          .eq('idclub', idclub);

      _log('setTemporadaActiva: OK');
      return ApiResponse.ok(null);
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

      final response = await _client
          .from('tusuarios')
          .select('id, nombre, apellidos, email')
          .eq('idclub', idclub)
          .inFilter('permisos', [2, 9]);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEntrenadoresByClub: ${data.length} entrenadores');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEntrenadoresByClub ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountClubs() async {
    try {
      _log('getGlobalCountClubs');

      final response = await _client.from('tclubes').select('id');
      final count = (response as List).length;

      _log('getGlobalCountClubs: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountClubs ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountUsuarios() async {
    try {
      _log('getGlobalCountUsuarios');

      final response = await _client.from('tusuarios').select('id');
      final count = (response as List).length;

      _log('getGlobalCountUsuarios: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountUsuarios ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountEquipos() async {
    try {
      _log('getGlobalCountEquipos');

      final response = await _client.from('tequipos').select('id');
      final count = (response as List).length;

      _log('getGlobalCountEquipos: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountEquipos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountJugadores() async {
    try {
      _log('getGlobalCountJugadores');

      final response = await _client.from('tjugadores').select('id');
      final count = (response as List).length;

      _log('getGlobalCountJugadores: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountJugadores ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountEntrenamientos() async {
    try {
      _log('getGlobalCountEntrenamientos');

      final response = await _client.from('tentrenamientos').select('id');
      final count = (response as List).length;

      _log('getGlobalCountEntrenamientos: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountEntrenamientos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountPartidos() async {
    try {
      _log('getGlobalCountPartidos');

      final response = await _client.from('vpartido').select('id');
      final count = (response as List).length;

      _log('getGlobalCountPartidos: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountPartidos ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> getGlobalCountCuotas() async {
    try {
      _log('getGlobalCountCuotas');

      final response = await _client.from('tcuotas').select('id');
      final count = (response as List).length;

      _log('getGlobalCountCuotas: $count');
      return ApiResponse.ok(count);
    } catch (e) {
      _log('getGlobalCountCuotas ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquiposPorCategoriaGlobal() async {
    try {
      _log('getEquiposPorCategoriaGlobal');

      final response = await _client
          .from('tequipos')
          .select('idcategoria');

      // Agrupar por categoría
      final categoriaCount = <int, int>{};
      for (final item in response as List) {
        final cat = item['idcategoria'] as int? ?? 0;
        categoriaCount[cat] = (categoriaCount[cat] ?? 0) + 1;
      }

      final data = categoriaCount.entries
          .map((e) => {'categoria': e.key, 'total': e.value})
          .toList()
        ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

      _log('getEquiposPorCategoriaGlobal: ${data.length} categorías');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEquiposPorCategoriaGlobal ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getUsuariosPorPermisoGlobal() async {
    try {
      _log('getUsuariosPorPermisoGlobal');

      final response = await _client
          .from('tusuarios')
          .select('permisos');

      // Agrupar por permiso
      final permisoCount = <int, int>{};
      for (final item in response as List) {
        final perm = item['permisos'] as int? ?? 0;
        permisoCount[perm] = (permisoCount[perm] ?? 0) + 1;
      }

      final data = permisoCount.entries
          .map((e) => {'permiso': e.key, 'total': e.value})
          .toList()
        ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

      _log('getUsuariosPorPermisoGlobal: ${data.length} permisos');
      return ApiResponse.ok(data);
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

      final response = await _client
          .from('testadisticaspartido')
          .select('idpartido, idequipo, faltaf, faltac, cornerf, cornerc, disparosf, disparosc, disparosfap, disparoscap, fjuegof, fjuegoc, llegadasf, llegadasc, ocasionesf, ocasionesc')
          .eq('idequipo', idequipo);

      final data = (response as List).cast<Map<String, dynamic>>().toList();

      _log('getEstadisticasPartido: ${data.length} registros');
      return ApiResponse.ok(data);
    } catch (e) {
      _log('getEstadisticasPartido ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ========================================
  // PERFIL DE JUGADOR (Stubs - usar BackendSeguroDataSource)
  // ========================================

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasJugador({
    required int idjugador,
    required int idtemporada,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosJugador({
    required int idjugador,
    required int idtemporada,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientosJugador({
    required int idjugador,
    required int idtemporada,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLesionesJugador({
    required int idjugador,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> createLesion({
    required int idjugador,
    required String lesion,
    required DateTime fechainicio,
    DateTime? fechafin,
    String? observaciones,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> updateLesion({
    required int id,
    String? lesion,
    DateTime? fechainicio,
    DateTime? fechafin,
    String? observaciones,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> deleteLesion({required int id}) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTallaPesoJugador({
    required int idjugador,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> createTallaPeso({
    required int idjugador,
    required DateTime fecha,
    required double talla,
    required double peso,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> updateTallaPeso({
    required int id,
    required DateTime fecha,
    required double talla,
    required double peso,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> deleteTallaPeso({required int id}) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getControlDeuda({
    required int idjugador,
    required int idtemporada,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
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
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> updateReciboDeuda({
    required int id,
    double? cantidad,
    String? concepto,
    String? metodopago,
    DateTime? fechapago,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> deleteReciboDeuda({required int id}) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTutoresJugador({
    required int idjugador,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
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
    throw UnimplementedError('Use BackendSeguroDataSource');
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
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> deleteTutor({
    required int idjugador,
    required int idtutor,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCarnetsJugador({
    required int idjugador,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> createCarnet({
    required int idjugador,
    required int idtemporada,
    String? foto,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> updateNotaJugador({
    required int idjugador,
    required String nota,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getFichaFederativa({
    required int idjugador,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }

  @override
  Future<ApiResponse<void>> updateFichaFederativa({
    required int idjugador,
    String? ficha,
    DateTime? fechaficha,
  }) async {
    throw UnimplementedError('Use BackendSeguroDataSource');
  }
}
