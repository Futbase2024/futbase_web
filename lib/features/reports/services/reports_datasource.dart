import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/report_data.dart';
import '../domain/saved_report_entity.dart';

/// Datasource para consultas de informes en Supabase
class ReportsDatasource {
  final SupabaseClient _client;

  ReportsDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Obtiene estadísticas de un jugador
  Future<PlayerReportData> getPlayerReport({
    required int playerId,
    required int activeSeasonId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      // 1. Datos básicos del jugador
      final jugadorData = await _client
          .from('vjugadores')
          .select('''
            id,
            nombre,
            apellidos,
            dorsal,
            idposicion,
            idequipo,
            idclub
          ''')
          .eq('id', playerId)
          .eq('idtemporada', activeSeasonId)
          .maybeSingle();

      if (jugadorData == null) {
        throw Exception('Jugador no encontrado');
      }

      // 2. Obtener nombre del equipo
      String? teamName;
      if (jugadorData['idequipo'] != null) {
        final equipoData = await _client
            .from('tequipos')
            .select('equipo')
            .eq('id', jugadorData['idequipo'])
            .maybeSingle();
        teamName = equipoData?['equipo'] as String?;
      }

      // 3. Obtener nombre de posición
      String? position;
      if (jugadorData['idposicion'] != null) {
        final posicionData = await _client
            .from('tposiciones')
            .select('posicion')
            .eq('id', jugadorData['idposicion'])
            .maybeSingle();
        position = posicionData?['posicion'] as String?;
      }

      // 4. Estadísticas de partidos
      final partidosData = await _client
          .from('tconvpartidos')
          .select('idpartido')
          .eq('idjugador', playerId);

      final partidoIds =
          partidosData.map((p) => p['idpartido'] as int).toList();

      int totalMatches = 0;
      int totalMinutes = 0;
      int goals = 0;
      int assists = 0;
      int yellowCards = 0;
      int redCards = 0;

      if (partidoIds.isNotEmpty) {
        // Filtrar por temporada
        final partidosTemporada = await _client
            .from('tpartidos')
            .select('id')
            .inFilter('id', partidoIds)
            .eq('idtemporada', activeSeasonId);

        totalMatches = partidosTemporada.length;

        // Estadísticas de minutos jugados
        final statsData = await _client
            .from('testadisticaspartido')
            .select('minutosjugados')
            .eq('idjugador', playerId)
            .inFilter('idpartido', partidoIds);

        for (final stat in statsData) {
          totalMinutes += (stat['minutosjugados'] as int?) ?? 0;
        }

        // Eventos del jugador
        final eventosData = await _client
            .from('teventospartido')
            .select('tipo')
            .eq('idjugador', playerId)
            .inFilter('idpartido', partidoIds);

        for (final evento in eventosData) {
          final tipo = evento['tipo'] as String?;
          switch (tipo?.toLowerCase()) {
            case 'gol':
              goals++;
              break;
            case 'asistencia':
              assists++;
              break;
            case 'amarilla':
              yellowCards++;
              break;
            case 'roja':
              redCards++;
              break;
          }
        }
      }

      // 5. Asistencia a entrenamientos
      final entrenamientosData = await _client
          .from('tentrenamientos')
          .select('id')
          .eq('idequipo', jugadorData['idequipo'] ?? 0)
          .eq('idtemporada', activeSeasonId)
          .gte('fecha', fromDate.toIso8601String())
          .lte('fecha', toDate.toIso8601String());

      final entrenamientoIds =
          entrenamientosData.map((e) => e['id'] as int).toList();

      int totalTrainings = entrenamientoIds.length;
      int attendedTrainings = 0;

      if (entrenamientoIds.isNotEmpty) {
        final asistenciaData = await _client
            .from('tentrenojugador')
            .select('asiste')
            .eq('idjugador', playerId)
            .inFilter('identrenamiento', entrenamientoIds);

        for (final asist in asistenciaData) {
          if (asist['asiste'] == 1 || asist['asiste'] == true) {
            attendedTrainings++;
          }
        }
      }

      final attendancePercentage = totalTrainings > 0
          ? (attendedTrainings / totalTrainings) * 100
          : 0.0;

      return PlayerReportData(
        playerId: playerId,
        playerName: jugadorData['nombre'] as String,
        playerLastName: jugadorData['apellidos'] as String,
        dorsal: jugadorData['dorsal'] as int?,
        position: position,
        teamName: teamName,
        totalMatches: totalMatches,
        totalMinutes: totalMinutes,
        goals: goals,
        assists: assists,
        yellowCards: yellowCards,
        redCards: redCards,
        attendancePercentage: attendancePercentage,
        totalTrainings: totalTrainings,
        attendedTrainings: attendedTrainings,
      );
    } catch (e) {
      debugPrint('Error obteniendo informe de jugador: $e');
      rethrow;
    }
  }

  /// Obtiene datos del informe de partido
  Future<MatchReportData> getMatchReport({
    required int matchId,
    required int teamId,
  }) async {
    try {
      // 1. Datos del partido
      final partidoData = await _client
          .from('vpartido')
          .select('*')
          .eq('id', matchId)
          .maybeSingle();

      if (partidoData == null) {
        throw Exception('Partido no encontrado');
      }

      // 2. Convocatoria
      final convocatoriaData = await _client
          .from('vpartidosjugadores')
          .select('''
            idjugador,
            titular,
            dorsal,
            convocado
          ''')
          .eq('idpartido', matchId);

      // Obtener datos de jugadores
      final List<ConvocadoPlayer> convocatoria = [];
      for (final c in convocatoriaData) {
        final jugadorId = c['idjugador'] as int;
        final jugadorInfo = await _client
            .from('vjugadores')
            .select('nombre, apellidos, idposicion')
            .eq('id', jugadorId)
            .maybeSingle();

        if (jugadorInfo != null) {
          String? posicion;
          if (jugadorInfo['idposicion'] != null) {
            final posData = await _client
                .from('tposiciones')
                .select('posicion')
                .eq('id', jugadorInfo['idposicion'])
                .maybeSingle();
            posicion = posData?['posicion'] as String?;
          }

          convocatoria.add(ConvocadoPlayer(
            playerId: jugadorId,
            playerName: jugadorInfo['nombre'] as String,
            playerLastName: jugadorInfo['apellidos'] as String,
            dorsal: c['dorsal'] as int?,
            position: posicion,
            isStarter: c['titular'] == 1 || c['titular'] == true,
            isConvoked: c['convocado'] == 1 || c['convocado'] == true,
          ));
        }
      }

      // 3. Eventos del partido
      final eventosData = await _client
          .from('veventos')
          .select('*')
          .eq('idpartido', matchId);

      final List<MatchEventDetail> events = [];
      for (final e in eventosData) {
        String playerName = '';
        if (e['idjugador'] != null) {
          final jugadorInfo = await _client
              .from('vjugadores')
              .select('nombre, apellidos')
              .eq('id', e['idjugador'])
              .maybeSingle();
          if (jugadorInfo != null) {
            playerName = '${jugadorInfo['nombre']} ${jugadorInfo['apellidos']}';
          }
        }

        events.add(MatchEventDetail(
          id: e['id'] as int,
          playerId: e['idjugador'] as int? ?? 0,
          playerName: playerName,
          eventType: e['tipo'] as String? ?? '',
          minute: e['minuto'] as int?,
          detail: e['detalle'] as String?,
        ));
      }

      return MatchReportData(
        matchId: matchId,
        rival: partidoData['rival'] as String? ?? '',
        matchDate: DateTime.parse(partidoData['fecha'] as String),
        isHome: partidoData['local'] == 1 || partidoData['local'] == true,
        homeScore: partidoData['goles'] as int?,
        awayScore: partidoData['golesrival'] as int?,
        competition: partidoData['competicion'] as String?,
        matchday: partidoData['jornada'] as int?,
        convocatoria: convocatoria,
        events: events,
      );
    } catch (e) {
      debugPrint('Error obteniendo informe de partido: $e');
      rethrow;
    }
  }

  /// Obtiene datos del informe de convocatoria
  Future<ConvocatoriaReportData> getConvocatoriaReport({
    required int matchId,
    required int teamId,
  }) async {
    try {
      // 1. Datos del partido
      final partidoData = await _client
          .from('vpartido')
          .select('*')
          .eq('id', matchId)
          .maybeSingle();

      if (partidoData == null) {
        throw Exception('Partido no encontrado');
      }

      // 2. Nombre del equipo
      final equipoData = await _client
          .from('tequipos')
          .select('equipo')
          .eq('id', teamId)
          .maybeSingle();

      final teamName = equipoData?['equipo'] as String?;

      // 3. Convocatoria completa
      final convocatoriaData = await _client
          .from('vpartidosjugadores')
          .select('''
            idjugador,
            titular,
            dorsal,
            convocado,
            posx,
            posy
          ''')
          .eq('idpartido', matchId);

      final List<ConvocadoPlayer> starters = [];
      final List<ConvocadoPlayer> substitutes = [];
      final List<ConvocadoPlayer> notConvoked = [];

      for (final c in convocatoriaData) {
        final jugadorId = c['idjugador'] as int;
        final jugadorInfo = await _client
            .from('vjugadores')
            .select('nombre, apellidos, idposicion')
            .eq('id', jugadorId)
            .maybeSingle();

        if (jugadorInfo != null) {
          String? posicion;
          if (jugadorInfo['idposicion'] != null) {
            final posData = await _client
                .from('tposiciones')
                .select('posicion')
                .eq('id', jugadorInfo['idposicion'])
                .maybeSingle();
            posicion = posData?['posicion'] as String?;
          }

          final player = ConvocadoPlayer(
            playerId: jugadorId,
            playerName: jugadorInfo['nombre'] as String,
            playerLastName: jugadorInfo['apellidos'] as String,
            dorsal: c['dorsal'] as int?,
            position: posicion,
            isStarter: c['titular'] == 1 || c['titular'] == true,
            isConvoked: c['convocado'] == 1 || c['convocado'] == true,
            posx: c['posx'] as int?,
            posy: c['posy'] as int?,
          );

          if (!player.isConvoked) {
            notConvoked.add(player);
          } else if (player.isStarter) {
            starters.add(player);
          } else {
            substitutes.add(player);
          }
        }
      }

      return ConvocatoriaReportData(
        matchId: matchId,
        rival: partidoData['rival'] as String? ?? '',
        matchDate: DateTime.parse(partidoData['fecha'] as String),
        isHome: partidoData['local'] == 1 || partidoData['local'] == true,
        teamName: teamName,
        starters: starters,
        substitutes: substitutes,
        notConvoked: notConvoked,
      );
    } catch (e) {
      debugPrint('Error obteniendo informe de convocatoria: $e');
      rethrow;
    }
  }

  /// Obtiene datos del informe de asistencia mensual
  Future<AttendanceReportData> getAttendanceReport({
    required int teamId,
    required int year,
    required int month,
  }) async {
    try {
      // 1. Nombre del equipo
      final equipoData = await _client
          .from('tequipos')
          .select('equipo')
          .eq('id', teamId)
          .maybeSingle();

      final teamName = equipoData?['equipo'] as String? ?? 'Equipo';

      // 2. Fechas del mes
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0);

      // 3. Entrenamientos del mes
      final entrenamientosData = await _client
          .from('tentrenamientos')
          .select('id, fecha')
          .eq('idequipo', teamId)
          .gte('fecha', monthStart.toIso8601String())
          .lte('fecha', monthEnd.toIso8601String())
          .order('fecha');

      final totalTrainings = entrenamientosData.length;
      final entrenamientoIds =
          entrenamientosData.map((e) => e['id'] as int).toList();

      // 4. Jugadores del equipo
      final jugadoresData = await _client
          .from('vjugadores')
          .select('id, nombre, apellidos, dorsal')
          .eq('idequipo', teamId)
          .eq('activo', 1);

      // 5. Asistencia de cada jugador
      final List<PlayerAttendanceData> playersAttendance = [];

      for (final jugador in jugadoresData) {
        final jugadorId = jugador['id'] as int;
        int attended = 0;
        int absences = 0;

        if (entrenamientoIds.isNotEmpty) {
          final asistenciaData = await _client
              .from('tentrenojugador')
              .select('asiste')
              .eq('idjugador', jugadorId)
              .inFilter('identrenamiento', entrenamientoIds);

          for (final asist in asistenciaData) {
            if (asist['asiste'] == 1 || asist['asiste'] == true) {
              attended++;
            } else {
              absences++;
            }
          }
        }

        final attendancePercentage = totalTrainings > 0
            ? (attended / totalTrainings) * 100
            : 0.0;

        playersAttendance.add(PlayerAttendanceData(
          playerId: jugadorId,
          playerName: jugador['nombre'] as String,
          playerLastName: jugador['apellidos'] as String,
          dorsal: jugador['dorsal'] as int?,
          totalTrainings: totalTrainings,
          attended: attended,
          absences: absences,
          attendancePercentage: attendancePercentage,
        ));
      }

      // Ordenar por porcentaje de asistencia descendente
      playersAttendance.sort(
          (a, b) => b.attendancePercentage.compareTo(a.attendancePercentage));

      return AttendanceReportData(
        teamId: teamId,
        teamName: teamName,
        year: year,
        month: month,
        totalTrainings: totalTrainings,
        playersAttendance: playersAttendance,
      );
    } catch (e) {
      debugPrint('Error obteniendo informe de asistencia: $e');
      rethrow;
    }
  }

  /// Obtiene estadísticas agregadas del equipo
  Future<TeamStatsReportData> getTeamStatsReport({
    required int teamId,
    required int activeSeasonId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      // 1. Nombre del equipo
      final equipoData = await _client
          .from('tequipos')
          .select('equipo')
          .eq('id', teamId)
          .maybeSingle();

      final teamName = equipoData?['equipo'] as String? ?? 'Equipo';

      // 2. Partidos del equipo en el período
      final partidosData = await _client
          .from('vpartido')
          .select('*')
          .eq('idequipo', teamId)
          .eq('idtemporada', activeSeasonId)
          .gte('fecha', fromDate.toIso8601String())
          .lte('fecha', toDate.toIso8601String());

      int wins = 0;
      int draws = 0;
      int losses = 0;
      int goalsFor = 0;
      int goalsAgainst = 0;

      final List<MatchResultSummary> recentMatches = [];

      for (final partido in partidosData) {
        final isHome = partido['local'] == 1 || partido['local'] == true;
        final homeScore = partido['goles'] as int? ?? 0;
        final awayScore = partido['golesrival'] as int? ?? 0;

        final teamScore = isHome ? homeScore : awayScore;
        final rivalScore = isHome ? awayScore : homeScore;

        goalsFor += teamScore;
        goalsAgainst += rivalScore;

        if (teamScore > rivalScore) {
          wins++;
        } else if (teamScore < rivalScore) {
          losses++;
        } else {
          draws++;
        }

        recentMatches.add(MatchResultSummary(
          matchId: partido['id'] as int,
          rival: partido['rival'] as String? ?? '',
          matchDate: DateTime.parse(partido['fecha'] as String),
          isHome: isHome,
          homeScore: homeScore,
          awayScore: awayScore,
        ));
      }

      // Ordenar por fecha descendente y tomar los últimos 5
      recentMatches.sort((a, b) => b.matchDate.compareTo(a.matchDate));
      final lastFive = recentMatches.take(5).toList();

      // 3. Entrenamientos
      final entrenamientosData = await _client
          .from('tentrenamientos')
          .select('id')
          .eq('idequipo', teamId)
          .eq('idtemporada', activeSeasonId);

      final totalTrainings = entrenamientosData.length;

      // 4. Asistencia promedio
      final asistenciaStats = await _client
          .from('vm_asistencia_stats')
          .select('total, presentes')
          .eq('idequipo', teamId)
          .maybeSingle();

      double averageAttendance = 0.0;
      if (asistenciaStats != null) {
        final total = asistenciaStats['total'] as int? ?? 0;
        final presentes = asistenciaStats['presentes'] as int? ?? 0;
        if (total > 0) {
          averageAttendance = (presentes / total) * 100;
        }
      }

      return TeamStatsReportData(
        teamId: teamId,
        teamName: teamName,
        totalMatches: partidosData.length,
        wins: wins,
        draws: draws,
        losses: losses,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
        totalTrainings: totalTrainings,
        averageAttendance: averageAttendance,
        recentMatches: lastFive,
      );
    } catch (e) {
      debugPrint('Error obteniendo estadísticas de equipo: $e');
      rethrow;
    }
  }

  /// Obtiene lista de equipos según rol
  Future<List<Map<String, dynamic>>> getTeamsForRole({
    required int? clubId,
    required String userRole,
    required int activeSeasonId,
  }) async {
    try {
      List<dynamic> data;

      if (userRole == 'club' || userRole == 'coordinador') {
        data = await _client
            .from('vequipos')
            .select('id, equipo, idcategoria')
            .eq('idclub', clubId!)
            .eq('idtemporada', activeSeasonId)
            .order('equipo');
      } else {
        // Entrenador: solo su equipo (esto se maneja en el BLoC con el teamId del usuario)
        data = await _client
            .from('vequipos')
            .select('id, equipo, idcategoria')
            .eq('idclub', clubId!)
            .eq('idtemporada', activeSeasonId)
            .order('equipo');
      }

      return data.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error obteniendo equipos: $e');
      return [];
    }
  }

  /// Obtiene lista de jugadores para selector
  Future<List<Map<String, dynamic>>> getPlayersForSelector({
    required int teamId,
    required int activeSeasonId,
  }) async {
    try {
      final data = await _client
          .from('vjugadores')
          .select('id, nombre, apellidos, dorsal')
          .eq('idequipo', teamId)
          .eq('activo', 1)
          .eq('idtemporada', activeSeasonId)
          .order('nombre')
          .order('apellidos');

      return data.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error obteniendo jugadores: $e');
      return [];
    }
  }

  /// Obtiene lista de partidos para selector
  Future<List<Map<String, dynamic>>> getMatchesForSelector({
    required int teamId,
    required int activeSeasonId,
  }) async {
    try {
      final data = await _client
          .from('vpartido')
          .select('id, rival, fecha, goles, golesrival, local')
          .eq('idequipo', teamId)
          .eq('idtemporada', activeSeasonId)
          .order('fecha', ascending: false);

      return data.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error obteniendo partidos: $e');
      return [];
    }
  }

  /// Obtiene informes guardados según el rol del usuario
  /// - Club/Coordinador: informes del club
  /// - Entrenador: informes de su equipo
  Future<List<SavedReportEntity>> getSavedReports({
    required int? clubId,
    required int? teamId,
    required String userRole,
    int? tipoFilter,
  }) async {
    try {
      List<dynamic> data;

      if (userRole == 'entrenador') {
        // Entrenador: solo informes de su equipo
        if (teamId == null) return [];

        var query = _client
            .from('tinformes')
            .select('*')
            .eq('idequipo', teamId);

        if (tipoFilter != null) {
          data = await query.eq('tipo', tipoFilter).order('fechasubida', ascending: false);
        } else {
          data = await query.order('fechasubida', ascending: false);
        }
      } else {
        // Club/Coordinador: informes del club
        if (clubId == null) return [];

        var query = _client
            .from('tinformes')
            .select('*')
            .eq('idclub', clubId);

        if (tipoFilter != null) {
          data = await query.eq('tipo', tipoFilter).order('fechasubida', ascending: false);
        } else {
          data = await query.order('fechasubida', ascending: false);
        }
      }

      return data
          .map((json) => SavedReportEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo informes guardados: $e');
      return [];
    }
  }

  /// Elimina un informe guardado
  Future<bool> deleteSavedReport(int reportId) async {
    try {
      await _client
          .from('tinformes')
          .delete()
          .eq('id', reportId);
      return true;
    } catch (e) {
      debugPrint('Error eliminando informe: $e');
      return false;
    }
  }
}
