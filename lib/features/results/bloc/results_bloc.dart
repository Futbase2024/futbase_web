import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'results_event.dart';
import 'results_state.dart';

/// BLoC para gestión de resultados - Vista global semanal de todos los partidos
class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final SupabaseClient _supabase;
  Timer? _liveUpdateTimer;

  ResultsBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(const ResultsInitial()) {
    on<ResultsLoadWeekRequested>(_onLoadWeekRequested);
    on<ResultsPreviousWeek>(_onPreviousWeek);
    on<ResultsNextWeek>(_onNextWeek);
    on<ResultsGoToToday>(_onGoToToday);
    on<ResultsRefreshRequested>(_onRefreshRequested);
    on<ResultsFilterByScope>(_onFilterByScope);
    on<ResultsFilterByStatus>(_onFilterByStatus);
    on<ResultsClearFilters>(_onClearFilters);
    on<ResultsToggleLiveMode>(_onToggleLiveMode);
    on<ResultsSelectDate>(_onSelectDate);
  }

  @override
  Future<void> close() {
    _liveUpdateTimer?.cancel();
    return super.close();
  }

  /// Obtener inicio de semana (Lunes) para una fecha
  DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  /// Cargar partidos de una semana específica
  Future<void> _onLoadWeekRequested(
    ResultsLoadWeekRequested event,
    Emitter<ResultsState> emit,
  ) async {
    final weekStart = _getWeekStart(event.weekStart);
    debugPrint('📊 [ResultsBloc] Cargando semana: ${weekStart.toIso8601String()} (temporada=${event.idtemporada})');
    emit(const ResultsLoading());

    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekStartStr = weekStart.toIso8601String().split('T')[0];
      final weekEndStr = weekEnd.toIso8601String().split('T')[0];

      // Cargar TODOS los partidos de la temporada en el rango de fechas (sin filtro de club)
      final matchesData = await _supabase
          .from('vpartido')
          .select('''
            id,
            idequipo,
            idclub,
            equipo,
            ncortoequipo,
            rival,
            ncortorival,
            fecha,
            hora,
            casafuera,
            goles,
            golesrival,
            finalizado,
            descanso,
            minuto,
            jornada,
            escudo,
            escudorival,
            campo,
            categoria
          ''')
          .eq('idtemporada', event.idtemporada)
          .gte('fecha', weekStartStr)
          .lt('fecha', weekEndStr)
          .order('fecha', ascending: true)
          .order('hora', ascending: true);

      final matches = (matchesData as List).cast<Map<String, dynamic>>();

      // Extraer equipos únicos
      final equipos = <int, String>{};
      for (final match in matches) {
        final idequipo = match['idequipo'] as int?;
        final equipo = match['ncortoequipo']?.toString() ?? match['equipo']?.toString();
        if (idequipo != null && equipo != null) {
          equipos[idequipo] = equipo;
        }
      }

      // Agrupar por fecha
      final grouped = _groupByDate(matches);

      debugPrint('📊 [ResultsBloc] Cargados ${matches.length} partidos, ${equipos.length} equipos');

      emit(ResultsLoaded(
        allMatches: matches,
        groupedMatches: grouped,
        equipos: equipos,
        currentWeekStart: weekStart,
        idtemporada: event.idtemporada,
        idclub: event.idclub,
      ));
    } catch (e) {
      debugPrint('📊 [ResultsBloc] Error: $e');
      emit(ResultsError(message: 'Error al cargar resultados: $e'));
    }
  }

  /// Navegar a la semana anterior
  void _onPreviousWeek(
    ResultsPreviousWeek event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    final newWeekStart = currentState.currentWeekStart.subtract(const Duration(days: 7));
    add(ResultsLoadWeekRequested(
      weekStart: newWeekStart,
      idtemporada: currentState.idtemporada,
      idclub: currentState.idclub,
    ));
  }

  /// Navegar a la siguiente semana
  void _onNextWeek(
    ResultsNextWeek event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    final newWeekStart = currentState.currentWeekStart.add(const Duration(days: 7));
    add(ResultsLoadWeekRequested(
      weekStart: newWeekStart,
      idtemporada: currentState.idtemporada,
      idclub: currentState.idclub,
    ));
  }

  /// Ir a la semana actual (Hoy)
  void _onGoToToday(
    ResultsGoToToday event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    final today = DateTime.now();
    add(ResultsLoadWeekRequested(
      weekStart: today,
      idtemporada: currentState.idtemporada,
      idclub: currentState.idclub,
    ));
  }

  /// Refrescar datos de la semana actual
  Future<void> _onRefreshRequested(
    ResultsRefreshRequested event,
    Emitter<ResultsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    add(ResultsLoadWeekRequested(
      weekStart: currentState.currentWeekStart,
      idtemporada: currentState.idtemporada,
      idclub: currentState.idclub,
    ));
  }

  /// Filtrar por alcance (todos o mi club)
  void _onFilterByScope(
    ResultsFilterByScope event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    var filtered = currentState.allMatches;

    // Filtrar por scope
    if (event.scope == ResultsScope.myClub && currentState.idclub != null) {
      filtered = _filterByClub(filtered, currentState.idclub!);
    }

    // Mantener filtro de estado
    if (currentState.filterByStatus != null) {
      filtered = _filterByStatusMethod(filtered, currentState.filterByStatus!);
    }

    final grouped = _groupByDate(filtered);

    emit(currentState.copyWith(
      groupedMatches: grouped,
      filterScope: event.scope,
    ));
  }

  /// Filtrar por estado del partido
  void _onFilterByStatus(
    ResultsFilterByStatus event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    var filtered = currentState.allMatches;

    // Mantener filtro de scope
    if (currentState.filterScope == ResultsScope.myClub && currentState.idclub != null) {
      filtered = _filterByClub(filtered, currentState.idclub!);
    }

    // Filtrar por estado
    if (event.status != null) {
      filtered = _filterByStatusMethod(filtered, event.status!);
    }

    final grouped = _groupByDate(filtered);

    emit(currentState.copyWith(
      groupedMatches: grouped,
      filterByStatus: event.status,
    ));
  }

  /// Limpiar todos los filtros
  void _onClearFilters(
    ResultsClearFilters event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    final grouped = _groupByDate(currentState.allMatches);

    emit(currentState.copyWith(
      groupedMatches: grouped,
      filterScope: ResultsScope.all,
      filterByStatus: null,
    ));
  }

  /// Toggle modo live (activa/desactiva actualización automática)
  void _onToggleLiveMode(
    ResultsToggleLiveMode event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    final newLiveMode = !currentState.isLiveMode;

    if (newLiveMode) {
      // Iniciar actualización automática cada 30 segundos
      _liveUpdateTimer?.cancel();
      _liveUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) {
          final state = this.state;
          if (state is ResultsLoaded) {
            add(ResultsLoadWeekRequested(
              weekStart: state.currentWeekStart,
              idtemporada: state.idtemporada,
              idclub: state.idclub,
            ));
          }
        },
      );
      debugPrint('📊 [ResultsBloc] Modo LIVE activado - actualización cada 30s');
    } else {
      _liveUpdateTimer?.cancel();
      debugPrint('📊 [ResultsBloc] Modo LIVE desactivado');
    }

    emit(currentState.copyWith(isLiveMode: newLiveMode));
  }

  /// Seleccionar un día del calendario
  void _onSelectDate(
    ResultsSelectDate event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    emit(currentState.copyWith(selectedDate: event.date));
  }

  // ==================== MÉTODOS PRIVADOS ====================

  /// Agrupa partidos por fecha
  List<ResultsGroupedByDate> _groupByDate(List<Map<String, dynamic>> matches) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final match in matches) {
      final fechaStr = match['fecha']?.toString();
      if (fechaStr == null) continue;

      final fecha = DateTime.tryParse(fechaStr);
      if (fecha == null) continue;

      final key = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(match);
    }

    return grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final matchesWithStatus = entry.value.map((m) => _createMatchWithStatus(m)).toList();

      // Ordenar: live primero, luego por hora
      matchesWithStatus.sort((a, b) {
        // Live primero
        if (a.status == MatchStatus.live && b.status != MatchStatus.live) return -1;
        if (a.status != MatchStatus.live && b.status == MatchStatus.live) return 1;
        // Luego por hora
        final horaA = a.match['hora']?.toString() ?? '';
        final horaB = b.match['hora']?.toString() ?? '';
        return horaA.compareTo(horaB);
      });

      return ResultsGroupedByDate(date: date, matches: matchesWithStatus);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Más antiguo primero (Lunes-Domingo)
  }

  /// Crea un MatchWithStatus a partir de un mapa de partido
  MatchWithStatus _createMatchWithStatus(Map<String, dynamic> match) {
    final status = _getMatchStatus(match);
    final casafuera = match['casafuera'];
    final isLocal = !(casafuera == 1 || casafuera == true);

    // Si ncortorival es '0' (idrival=14), usar el campo 'rival'
    final ncortoRivalValue = match['ncortorival']?.toString();
    final rivalNombre = (ncortoRivalValue != null && ncortoRivalValue != '0')
        ? ncortoRivalValue
        : match['rival']?.toString() ?? 'Rival';

    return MatchWithStatus(
      match: match,
      status: status,
      equipoNombre: match['ncortoequipo']?.toString() ?? match['equipo']?.toString() ?? 'Equipo',
      rivalNombre: rivalNombre,
      isLocal: isLocal,
    );
  }

  /// Calcula el estado de un partido
  MatchStatus _getMatchStatus(Map<String, dynamic> match) {
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;
    if (finalizado) return MatchStatus.finished;

    // Si descanso == 1, está en vivo (descanso del partido)
    final descanso = match['descanso'] == 1 || match['descanso'] == true;
    if (descanso) return MatchStatus.live;

    // Si tiene minutos registrados (> 0), está en vivo
    final minutoStr = match['minuto']?.toString();
    if (minutoStr != null && minutoStr.isNotEmpty) {
      final parts = minutoStr.split(':');
      if (parts.isNotEmpty) {
        final minutos = int.tryParse(parts[0]) ?? 0;
        if (minutos > 0) return MatchStatus.live;
      }
    }

    return MatchStatus.scheduled;
  }

  /// Filtra partidos por club (mi club)
  List<Map<String, dynamic>> _filterByClub(
    List<Map<String, dynamic>> matches,
    int idclub,
  ) {
    return matches.where((m) {
      final matchClub = m['idclub'];
      return matchClub == idclub;
    }).toList();
  }

  /// Filtra partidos por estado
  List<Map<String, dynamic>> _filterByStatusMethod(
    List<Map<String, dynamic>> matches,
    MatchStatusFilter status,
  ) {
    return matches.where((m) {
      final matchStatus = _getMatchStatus(m);
      switch (status) {
        case MatchStatusFilter.live:
          return matchStatus == MatchStatus.live;
        case MatchStatusFilter.scheduled:
          return matchStatus == MatchStatus.scheduled;
        case MatchStatusFilter.finished:
          return matchStatus == MatchStatus.finished;
      }
    }).toList();
  }
}
