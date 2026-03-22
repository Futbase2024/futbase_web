import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:futbase_web_3/core/datasources/datasource_factory.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';

import 'matches_event.dart';
import 'matches_state.dart';

/// BLoC para gestión de partidos
class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final AppDataSource _dataSource;

  MatchesBloc({AppDataSource? dataSource})
      : _dataSource = dataSource ?? DataSourceFactory.instance,
        super(const MatchesInitial()) {
    on<MatchesLoadRequested>(_onLoadRequested);
    on<MatchesLoadByClubRequested>(_onLoadByClubRequested);
    on<MatchesRefreshRequested>(_onRefreshRequested);
    on<MatchesFilterByDate>(_onFilterByDate);
    on<MatchesFilterByCompetition>(_onFilterByCompetition);
    on<MatchesFilterByVenue>(_onFilterByVenue);
    on<MatchesClearFilters>(_onClearFilters);
    on<MatchCreateRequested>(_onCreateRequested);
    on<MatchUpdateRequested>(_onUpdateRequested);
    on<MatchDeleteRequested>(_onDeleteRequested);
    on<LineupLoadRequested>(_onLineupLoadRequested);
    on<LineupPlayerMarkRequested>(_onLineupPlayerMarkRequested);
    on<LineupSaveRequested>(_onLineupSaveRequested);
    on<LineupPositionUpdateRequested>(_onLineupPositionUpdateRequested);
    // Convocatoria
    on<ConvocatoriaLoadRequested>(_onConvocatoriaLoadRequested);
    on<ConvocatoriaPlayerToggleRequested>(_onConvocatoriaPlayerToggleRequested);
    on<ConvocatoriaDorsalUpdateRequested>(_onConvocatoriaDorsalUpdateRequested);
  }

  /// Carga inicial de partidos desde la vista vpartido
  Future<void> _onLoadRequested(
    MatchesLoadRequested event,
    Emitter<MatchesState> emit,
  ) async {
    debugPrint('⚽ [MatchesBloc] Cargando partidos (idequipo=${event.idequipo}, idTemporada=${event.idTemporada})');
    emit(const MatchesLoading());

    final response = await _dataSource.getPartidos(
      idequipo: event.idequipo,
      idtemporada: event.idTemporada,
    );

    if (response.success && response.data != null) {
      final matches = response.data!;

      // Extraer competiciones únicas (usamos jornada como identificador de competición)
      final competitions = <int, String>{};
      for (final match in matches) {
        final idjornada = match['idjornada'] as int?;
        final jornada = match['jornada'] as String?;
        if (idjornada != null && jornada != null && !competitions.containsKey(idjornada)) {
          competitions[idjornada] = jornada;
        }
      }

      debugPrint('⚽ [MatchesBloc] Cargados ${matches.length} partidos desde vpartido');
      emit(MatchesLoaded(
        matches: matches,
        filteredMatches: matches,
        competitions: competitions,
      ));
    } else {
      debugPrint('⚽ [MatchesBloc] Error: ${response.message}');
      emit(MatchesError(message: response.message ?? 'Error al cargar partidos'));
    }
  }

  /// Carga partidos de todos los equipos de un club (para club/coordinador)
  Future<void> _onLoadByClubRequested(
    MatchesLoadByClubRequested event,
    Emitter<MatchesState> emit,
  ) async {
    debugPrint('⚽ [MatchesBloc] Cargando partidos del club (idclub=${event.idclub}, idTemporada=${event.idTemporada})');
    emit(const MatchesLoading());

    final response = await _dataSource.getPartidosByClub(
      idclub: event.idclub,
      idtemporada: event.idTemporada,
    );

    if (response.success && response.data != null) {
      final matches = response.data!;

      // Extraer competiciones únicas
      final competitions = <int, String>{};
      for (final match in matches) {
        final idjornada = match['idjornada'] as int?;
        final jornada = match['jornada'] as String?;
        if (idjornada != null && jornada != null && !competitions.containsKey(idjornada)) {
          competitions[idjornada] = jornada;
        }
      }

      debugPrint('⚽ [MatchesBloc] Cargados ${matches.length} partidos del club desde vpartido');
      emit(MatchesLoaded(
        matches: matches,
        filteredMatches: matches,
        competitions: competitions,
      ));
    } else {
      debugPrint('⚽ [MatchesBloc] Error al cargar partidos del club: ${response.message}');
      emit(MatchesError(message: response.message ?? 'Error al cargar partidos'));
    }
  }

  /// Refrescar datos manteniendo filtros (usa vista vpartido)
  Future<void> _onRefreshRequested(
    MatchesRefreshRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    DateTime? currentFromDate;
    DateTime? currentToDate;
    int? currentCompetition;
    bool? currentVenue;

    if (currentState is MatchesLoaded) {
      currentFromDate = currentState.filterFromDate;
      currentToDate = currentState.filterToDate;
      currentCompetition = currentState.filterByCompetition;
      currentVenue = currentState.filterByVenue;
    }

    final response = await _dataSource.getPartidos(
      idequipo: event.idequipo,
      idtemporada: event.idTemporada,
    );

    if (response.success && response.data != null) {
      var matches = response.data!;
      var filteredMatches = matches;

      // Extraer competiciones únicas
      final competitions = <int, String>{};
      for (final match in matches) {
        final idjornada = match['idjornada'] as int?;
        final jornada = match['jornada'] as String?;
        if (idjornada != null && jornada != null && !competitions.containsKey(idjornada)) {
          competitions[idjornada] = jornada;
        }
      }

      // Reaplicar filtros
      if (currentFromDate != null || currentToDate != null) {
        filteredMatches = _filterByDateRange(filteredMatches, currentFromDate, currentToDate);
      }
      if (currentCompetition != null) {
        filteredMatches = _filterByCompetitionId(filteredMatches, currentCompetition);
      }
      if (currentVenue != null) {
        filteredMatches = _filterByVenue(filteredMatches, currentVenue);
      }

      emit(MatchesLoaded(
        matches: matches,
        filteredMatches: filteredMatches,
        competitions: competitions,
        filterFromDate: currentFromDate,
        filterToDate: currentToDate,
        filterByCompetition: currentCompetition,
        filterByVenue: currentVenue,
      ));
    } else {
      emit(MatchesError(message: response.message ?? 'Error al refrescar'));
    }
  }

  /// Filtrar por rango de fechas
  void _onFilterByDate(
    MatchesFilterByDate event,
    Emitter<MatchesState> emit,
  ) {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    var filtered = currentState.matches;

    if (event.fromDate != null || event.toDate != null) {
      filtered = _filterByDateRange(filtered, event.fromDate, event.toDate);
    }

    // Mantener otros filtros si existen
    if (currentState.filterByCompetition != null) {
      filtered = _filterByCompetitionId(filtered, currentState.filterByCompetition!);
    }
    if (currentState.filterByVenue != null) {
      filtered = _filterByVenue(filtered, currentState.filterByVenue!);
    }

    emit(currentState.copyWith(
      filteredMatches: filtered,
      filterFromDate: event.fromDate,
      filterToDate: event.toDate,
    ));
  }

  /// Filtrar por competición
  void _onFilterByCompetition(
    MatchesFilterByCompetition event,
    Emitter<MatchesState> emit,
  ) {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    var filtered = currentState.matches;

    if (event.idcompeticion != null) {
      filtered = _filterByCompetitionId(filtered, event.idcompeticion!);
    }

    // Mantener otros filtros si existen
    if (currentState.filterFromDate != null || currentState.filterToDate != null) {
      filtered = _filterByDateRange(filtered, currentState.filterFromDate, currentState.filterToDate);
    }
    if (currentState.filterByVenue != null) {
      filtered = _filterByVenue(filtered, currentState.filterByVenue!);
    }

    emit(currentState.copyWith(
      filteredMatches: filtered,
      filterByCompetition: event.idcompeticion,
    ));
  }

  /// Filtrar por local/visitante
  void _onFilterByVenue(
    MatchesFilterByVenue event,
    Emitter<MatchesState> emit,
  ) {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    var filtered = currentState.matches;

    if (event.isLocal != null) {
      filtered = _filterByVenue(filtered, event.isLocal!);
    }

    // Mantener otros filtros si existen
    if (currentState.filterFromDate != null || currentState.filterToDate != null) {
      filtered = _filterByDateRange(filtered, currentState.filterFromDate, currentState.filterToDate);
    }
    if (currentState.filterByCompetition != null) {
      filtered = _filterByCompetitionId(filtered, currentState.filterByCompetition!);
    }

    emit(currentState.copyWith(
      filteredMatches: filtered,
      filterByVenue: event.isLocal,
    ));
  }

  /// Limpiar todos los filtros
  void _onClearFilters(
    MatchesClearFilters event,
    Emitter<MatchesState> emit,
  ) {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    emit(currentState.copyWith(
      filteredMatches: currentState.matches,
      filterFromDate: null,
      filterToDate: null,
      filterByCompetition: null,
      filterByVenue: null,
    ));
  }

  /// Crear nuevo partido
  Future<void> _onCreateRequested(
    MatchCreateRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final response = await _dataSource.createPartido(
      idequipo: event.idequipo,
      idtemporada: event.idTemporada,
      fecha: event.fecha,
      rival: event.rival,
      local: event.local,
    );

    if (response.success) {
      debugPrint('⚽ [MatchesBloc] Partido creado correctamente');
      add(MatchesLoadRequested(
        idequipo: event.idequipo,
        idTemporada: event.idTemporada,
      ));
    } else {
      debugPrint('⚽ [MatchesBloc] Error al crear: ${response.message}');
      emit(MatchesError(message: 'Error al crear partido: ${response.message}'));
    }
  }

  /// Actualizar partido existente
  Future<void> _onUpdateRequested(
    MatchUpdateRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final response = await _dataSource.updatePartido(
      id: event.id,
      idequipo: event.idequipo,
      idtemporada: event.idTemporada,
      fecha: event.fecha,
      rival: event.rival,
      local: event.local,
      golesLocal: event.golesLocal,
      golesVisitante: event.golesVisitante,
      finalizado: event.finalizado,
    );

    if (response.success) {
      debugPrint('⚽ [MatchesBloc] Partido actualizado correctamente');
      add(MatchesLoadRequested(
        idequipo: event.idequipo,
        idTemporada: event.idTemporada,
      ));
    } else {
      debugPrint('⚽ [MatchesBloc] Error al actualizar: ${response.message}');
      emit(MatchesError(message: 'Error al actualizar partido: ${response.message}'));
    }
  }

  /// Eliminar partido
  Future<void> _onDeleteRequested(
    MatchDeleteRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final response = await _dataSource.deletePartido(id: event.id);

    if (response.success) {
      debugPrint('⚽ [MatchesBloc] Partido eliminado correctamente');
      add(MatchesLoadRequested(
        idequipo: event.idequipo,
        idTemporada: event.idTemporada,
      ));
    } else {
      debugPrint('⚽ [MatchesBloc] Error al eliminar: ${response.message}');
      emit(MatchesError(message: 'Error al eliminar partido: ${response.message}'));
    }
  }

  /// Cargar alineación - solo jugadores convocados
  Future<void> _onLineupLoadRequested(
    LineupLoadRequested event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      debugPrint('⚽ [MatchesBloc] Cargando alineación (idpartido=${event.idpartido})');

      // Cargar camisetas del partido
      final camisetasResponse = await _dataSource.getPartidoCamisetas(idpartido: event.idpartido);
      String? camisetaUrl;
      String? camisetaPorteroUrl;
      int dorsalColor = 0;

      if (camisetasResponse.success && camisetasResponse.data != null) {
        camisetaUrl = camisetasResponse.data!['camisetaUrl'] as String?;
        camisetaPorteroUrl = camisetasResponse.data!['camisetaPorteroUrl'] as String?;
        dorsalColor = camisetasResponse.data!['dorsalColor'] as int? ?? 0;
      }

      debugPrint('⚽ [MatchesBloc] Camiseta: $camisetaUrl, Portero: $camisetaPorteroUrl, Color dorsal: $dorsalColor');

      // Cargar TODOS los jugadores convocados para este partido
      final lineupResponse = await _dataSource.getLineup(idpartido: event.idpartido);

      // Si no hay convocatoria, mostrar lista vacía (hay que convocar primero)
      if (!lineupResponse.success || lineupResponse.data == null || lineupResponse.data!.isEmpty) {
        debugPrint('⚽ [MatchesBloc] No hay jugadores convocados para este partido');
        emit(LineupState(
          idpartido: event.idpartido,
          players: [],
          lineup: {},
          minutosEntrada: {},
          minutosSalida: {},
          camisetaUrl: camisetaUrl,
          camisetaPorteroUrl: camisetaPorteroUrl,
          dorsalColor: dorsalColor,
        ));
        return;
      }

      final lineupData = lineupResponse.data!;

      // Usar datos de la vista vpartidosjugadores
      final players = lineupData.map((item) => {
        'id': item['idjugador'],
        'nombre': item['apodo'] ?? '',
        'apellidos': '',
        'dorsal': item['dorsal'],
        'idposicion': item['idposicion'],
        'posicion': item['posicion'],
      }).toList().cast<Map<String, dynamic>>();

      // Mapear alineación existente
      final lineup = <int, bool>{};
      final minutosEntrada = <int, int?>{};
      final minutosSalida = <int, int?>{};
      final posX = <int, double?>{};
      final posY = <int, double?>{};

      for (final player in players) {
        final id = player['id'] as int;
        lineup[id] = false;
        minutosEntrada[id] = null;
        minutosSalida[id] = null;
        posX[id] = null;
        posY[id] = null;
      }

      for (final line in lineupData) {
        final idJugador = line['idjugador'] as int;
        lineup[idJugador] = (line['titular'] as int?) == 1;
        minutosEntrada[idJugador] = line['mentra'] as int?;
        minutosSalida[idJugador] = null;
        // Cargar posiciones directamente de la BD (ya normalizadas 0-1)
        posX[idJugador] = line['posx'] != null ? (line['posx'] as num).toDouble() : null;
        posY[idJugador] = line['posy'] != null ? (line['posy'] as num).toDouble() : null;
      }

      debugPrint('⚽ [MatchesBloc] Cargados ${players.length} jugadores convocados');

      // 📍 LOG DETALLADO DE POSICIONES
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📍 [MATCHES BLOC] POSICIONES CARGADAS DE BD (ya normalizadas 0-1):');
      for (final line in lineupData) {
        final id = line['idjugador'] as int;
        final nombre = players.firstWhere((p) => p['id'] == id, orElse: () => <String, dynamic>{})['nombre'] ?? '?';
        final esTitular = lineup[id] == true;
        final pX = posX[id];
        final pY = posY[id];
        final posicion = players.firstWhere((p) => p['id'] == id, orElse: () => <String, dynamic>{})['posicion'] ?? 'Sin posición';
        debugPrint('  👤 #$id "$nombre" | ${esTitular ? "TITULAR" : "SUPLENTE"} | $posicion | posX=$pX | posY=$pY');
      }
      debugPrint('═══════════════════════════════════════════════════════════');

      emit(LineupState(
        idpartido: event.idpartido,
        players: players,
        lineup: lineup,
        minutosEntrada: minutosEntrada,
        minutosSalida: minutosSalida,
        posX: posX,
        posY: posY,
        camisetaUrl: camisetaUrl,
        camisetaPorteroUrl: camisetaPorteroUrl,
        dorsalColor: dorsalColor,
      ));
    } catch (e) {
      debugPrint('⚽ [MatchesBloc] Error al cargar alineación: $e');
      emit(MatchesError(message: 'Error al cargar alineación: $e'));
    }
  }

  /// Marcar jugador como titular/suplente
  void _onLineupPlayerMarkRequested(
    LineupPlayerMarkRequested event,
    Emitter<MatchesState> emit,
  ) {
    final currentState = state;
    if (currentState is! LineupState) return;

    final newLineup = Map<int, bool>.from(currentState.lineup);
    final newMinutosEntrada = Map<int, int?>.from(currentState.minutosEntrada);
    final newMinutosSalida = Map<int, int?>.from(currentState.minutosSalida);

    newLineup[event.idjugador] = event.titular;
    if (event.minutoEntrada != null) {
      newMinutosEntrada[event.idjugador] = event.minutoEntrada;
    }
    if (event.minutoSalida != null) {
      newMinutosSalida[event.idjugador] = event.minutoSalida;
    }

    emit(currentState.copyWith(
      lineup: newLineup,
      minutosEntrada: newMinutosEntrada,
      minutosSalida: newMinutosSalida,
    ));
  }

  /// Guardar alineación completa
  Future<void> _onLineupSaveRequested(
    LineupSaveRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LineupState) return;

    emit(currentState.copyWith(isSaving: true));

    // Eliminar convocatoria anterior
    await _dataSource.deleteConvocatoria(idpartido: event.idpartido);

    // Preparar inserts
    final inserts = <Map<String, dynamic>>[];
    for (final entry in event.lineup.entries) {
      inserts.add({
        'idpartido': event.idpartido,
        'idjugador': entry.key,
        'titular': entry.value ? 1 : 0,
        'convocado': 1,
        'mentra': event.minutosEntrada[entry.key],
        'posx': event.posX[entry.key],
        'posy': event.posY[entry.key],
      });
    }

    if (inserts.isNotEmpty) {
      final response = await _dataSource.saveLineup(
        idpartido: event.idpartido,
        lineup: inserts,
      );

      if (response.success) {
        debugPrint('⚽ [MatchesBloc] Alineación guardada correctamente');
        emit(currentState.copyWith(isSaving: false));
      } else {
        debugPrint('⚽ [MatchesBloc] Error al guardar alineación: ${response.message}');
        emit(MatchesError(message: 'Error al guardar alineación: ${response.message}'));
      }
    } else {
      emit(currentState.copyWith(isSaving: false));
    }
  }

  /// Actualizar posición de un jugador en el campo
  void _onLineupPositionUpdateRequested(
    LineupPositionUpdateRequested event,
    Emitter<MatchesState> emit,
  ) {
    final currentState = state;
    if (currentState is! LineupState) return;

    final newPosX = Map<int, double?>.from(currentState.posX);
    final newPosY = Map<int, double?>.from(currentState.posY);

    newPosX[event.idjugador] = event.posX;
    newPosY[event.idjugador] = event.posY;

    emit(currentState.copyWith(
      posX: newPosX,
      posY: newPosY,
    ));

    debugPrint('⚽ [MatchesBloc] Posición actualizada: jugador=${event.idjugador}, x=${event.posX}, y=${event.posY}');
  }

  /// Filtra partidos por rango de fechas
  List<Map<String, dynamic>> _filterByDateRange(
    List<Map<String, dynamic>> matches,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    return matches.where((m) {
      final fechaStr = m['fecha']?.toString();
      if (fechaStr == null) return false;

      final fecha = DateTime.tryParse(fechaStr);
      if (fecha == null) return false;

      final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);

      if (fromDate != null && fechaSolo.isBefore(DateTime(fromDate.year, fromDate.month, fromDate.day))) {
        return false;
      }

      if (toDate != null && fechaSolo.isAfter(DateTime(toDate.year, toDate.month, toDate.day))) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Filtra partidos por jornada/competición (idjornada en vpartido)
  List<Map<String, dynamic>> _filterByCompetitionId(
    List<Map<String, dynamic>> matches,
    int idjornada,
  ) {
    return matches.where((m) {
      final matchIdJornada = m['idjornada'];
      return matchIdJornada == idjornada;
    }).toList();
  }

  /// Filtra partidos por local/visitante
  /// casafuera: 0 = local, 1 = visitante
  List<Map<String, dynamic>> _filterByVenue(
    List<Map<String, dynamic>> matches,
    bool isLocal,
  ) {
    return matches.where((m) {
      final casafuera = m['casafuera'];
      // casafuera: 1 = visitante, 0 o null = local
      final esVisitante = casafuera == 1 || casafuera == true;
      return isLocal ? !esVisitante : esVisitante;
    }).toList();
  }

  // ==================== CONVOCATORIA ====================

  /// Cargar jugadores del club para convocatoria usando la vista vjugadores
  Future<void> _onConvocatoriaLoadRequested(
    ConvocatoriaLoadRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final startTime = DateTime.now();
    debugPrint('⚽ [MatchesBloc] ⏱️ INICIO carga convocatoria (idclub=${event.idclub}, idTemporada=${event.idTemporada})');

    emit(const MatchesLoading());

    try {
      // Cargar jugadores del club
      final jugadoresResponse = await _dataSource.getJugadoresByClub(
        idclub: event.idclub,
        idtemporada: event.idTemporada,
        soloActivos: true,
      );

      if (!jugadoresResponse.success || jugadoresResponse.data == null) {
        emit(MatchesError(message: jugadoresResponse.message ?? 'Error al cargar jugadores'));
        return;
      }

      final jugadoresData = jugadoresResponse.data!;
      final queryDuration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('⚽ [MatchesBloc] ⏱️ Query vjugadores: ${queryDuration}ms (${jugadoresData.length} registros)');

      if (jugadoresData.isEmpty) {
        debugPrint('⚽ [MatchesBloc] No hay jugadores en el club para esta temporada');
        emit(ConvocatoriaState(
          idpartido: event.idpartido,
          idclub: event.idclub,
          idTemporada: event.idTemporada,
          clubPlayers: [],
          convocados: {},
          equipos: {},
        ));
        return;
      }

      // Mapear jugadores y equipos
      final mapStart = DateTime.now();
      final clubPlayers = <Map<String, dynamic>>[];
      final equipos = <int, String>{};

      for (final jugador in jugadoresData) {
        final idequipo = jugador['idequipo'] as int?;
        if (idequipo != null && !equipos.containsKey(idequipo)) {
          // Usar el nombre del equipo de la vista si está disponible
          equipos[idequipo] = jugador['equipo']?.toString() ?? 'Equipo $idequipo';
        }

        clubPlayers.add({
          'id': jugador['id'],
          'nombre': jugador['nombre'],
          'apellidos': jugador['apellidos'],
          'apodo': jugador['apodo'],
          'dorsal': jugador['dorsal'],
          'foto': jugador['foto'],
          'idposicion': jugador['idposicion'],
          'posicion': jugador['posicion'],
          'idequipo': idequipo,
        });
      }
      final mapDuration = DateTime.now().difference(mapStart).inMilliseconds;
      debugPrint('⚽ [MatchesBloc] ⏱️ Mapeo jugadores: ${mapDuration}ms');

      // Cargar nombres de equipos
      if (equipos.isNotEmpty) {
        final equiposStart = DateTime.now();
        final equiposResponse = await _dataSource.getEquiposInfo(ids: equipos.keys.toList());

        if (equiposResponse.success && equiposResponse.data != null) {
          for (final eq in equiposResponse.data!) {
            final id = eq['id'] as int;
            equipos[id] = eq['ncorto']?.toString() ?? eq['equipo']?.toString() ?? 'Sin equipo';
          }
        }
        final equiposDuration = DateTime.now().difference(equiposStart).inMilliseconds;
        debugPrint('⚽ [MatchesBloc] ⏱️ Query equipos: ${equiposDuration}ms');
      }

      // Cargar convocatoria existente para este partido
      final convStart = DateTime.now();
      final convocatoriaResponse = await _dataSource.getConvocatoria(idpartido: event.idpartido);

      final convocados = <int>{};
      if (convocatoriaResponse.success && convocatoriaResponse.data != null) {
        for (final conv in convocatoriaResponse.data!) {
          final idJugador = conv['idjugador'] as int?;
          if (idJugador != null) {
            convocados.add(idJugador);
          }
        }
      }
      final convDuration = DateTime.now().difference(convStart).inMilliseconds;
      debugPrint('⚽ [MatchesBloc] ⏱️ Query convocatoria: ${convDuration}ms');

      final totalDuration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('⚽ [MatchesBloc] ⏱️ FIN carga convocatoria: ${clubPlayers.length} jugadores, ${convocados.length} convocados | TOTAL: ${totalDuration}ms');

      emit(ConvocatoriaState(
        idpartido: event.idpartido,
        idclub: event.idclub,
        idTemporada: event.idTemporada,
        clubPlayers: clubPlayers,
        convocados: convocados,
        equipos: equipos,
      ));
    } catch (e) {
      final totalDuration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('⚽ [MatchesBloc] ⏱️ ERROR en ${totalDuration}ms: $e');
      emit(MatchesError(message: 'Error al cargar jugadores del club: $e'));
    }
  }

  /// Toggle jugador convocado
  Future<void> _onConvocatoriaPlayerToggleRequested(
    ConvocatoriaPlayerToggleRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConvocatoriaState) return;

    try {
      // Upsert usando el datasource
      final response = await _dataSource.upsertConvocatoria(
        idpartido: currentState.idpartido,
        idjugador: event.idjugador,
        idequipo: event.idequipo,
        idtemporada: currentState.idTemporada,
        convocado: event.convocado,
      );

      if (response.success) {
        debugPrint('⚽ [MatchesBloc] Jugador ${event.idjugador} ${event.convocado ? 'CONVOCADO' : 'DESCONVOCADO'} en BD (UPSERT)');

        // Actualizar estado local
        final newConvocados = Set<int>.from(currentState.convocados);
        if (event.convocado) {
          newConvocados.add(event.idjugador);
        } else {
          newConvocados.remove(event.idjugador);
        }

        emit(currentState.copyWith(convocados: newConvocados));
      }
    } catch (e) {
      debugPrint('⚽ [MatchesBloc] Error al toggle convocatoria: $e');
    }
  }

  /// Actualizar dorsal de un jugador en la convocatoria
  Future<void> _onConvocatoriaDorsalUpdateRequested(
    ConvocatoriaDorsalUpdateRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConvocatoriaState) return;

    try {
      final newDorsal = event.dorsal;

      await _dataSource.updateConvocatoriaDorsal(
        idpartido: currentState.idpartido,
        idjugador: event.idjugador,
        dorsal: newDorsal,
      );

      debugPrint('⚽ [MatchesBloc] Dorsal actualizado a $newDorsal para jugador ${event.idjugador}');

      // Actualizar estado local
      final updatedPlayers = currentState.clubPlayers.map((p) {
        if (p['id'] == event.idjugador) {
          return {...p, 'dorsal': newDorsal};
        }
        return p;
      }).toList();

      emit(currentState.copyWith(clubPlayers: updatedPlayers));
    } catch (e) {
      debugPrint('⚽ [MatchesBloc] Error al actualizar dorsal: $e');
    }
  }
}
