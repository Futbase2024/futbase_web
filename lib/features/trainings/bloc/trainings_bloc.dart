import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:futbase_web_3/core/datasources/datasources.dart';

import 'trainings_event.dart';
import 'trainings_state.dart';

/// BLoC para gestión de entrenamientos
class TrainingsBloc extends Bloc<TrainingsEvent, TrainingsState> {
  final AppDataSource _datasource;

  TrainingsBloc({AppDataSource? datasource})
      : _datasource = datasource ?? DataSourceFactory.instance,
        super(const TrainingsInitial()) {
    on<TrainingsLoadRequested>(_onLoadRequested);
    on<TrainingsRefreshRequested>(_onRefreshRequested);
    on<TrainingsFilterByDate>(_onFilterByDate);
    on<TrainingsFilterByType>(_onFilterByType);
    on<TrainingsClearFilters>(_onClearFilters);
    on<TrainingCreateRequested>(_onCreateRequested);
    on<TrainingUpdateRequested>(_onUpdateRequested);
    on<TrainingDeleteRequested>(_onDeleteRequested);
    on<AttendanceLoadRequested>(_onAttendanceLoadRequested);
    on<AttendanceMarkRequested>(_onAttendanceMarkRequested);
    on<AttendanceSaveRequested>(_onAttendanceSaveRequested);
    on<TrainingsLoadByClubRequested>(_onLoadByClubRequested);
    on<AttendanceStatsRequested>(_onAttendanceStatsRequested);
    on<CalendarViewChanged>(_onCalendarViewChanged);
    on<WeekNavigationRequested>(_onWeekNavigationRequested);
  }

  /// Carga inicial de entrenamientos
  Future<void> _onLoadRequested(
    TrainingsLoadRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final totalStopwatch = Stopwatch()..start();
    debugPrint('🏋️ [TrainingsBloc] ⏱️ INICIO _onLoadRequested (idequipo=${event.idequipo}, temporada=${event.activeSeasonId})');
    emit(const TrainingsLoading());

    if (event.idequipo <= 0) {
      debugPrint('🏋️ [TrainingsBloc] ID de equipo inválido, emitiendo estado vacío');
      emit(TrainingsLoaded(
        trainings: [],
        filteredTrainings: [],
        trainingTypes: {},
        focusedWeek: DateTime.now(),
      ));
      return;
    }

    try {
      final response = await _datasource.getEntrenamientos(
        idequipo: event.idequipo,
        idtemporada: event.activeSeasonId,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Error al cargar entrenamientos');
      }

      final trainings = response.data!;

      totalStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ✅ TOTAL _onLoadRequested: ${totalStopwatch.elapsedMilliseconds}ms');

      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: trainings,
        trainingTypes: {},
        focusedWeek: DateTime.now(),
        activeSeasonId: event.activeSeasonId,
      ));
    } catch (e) {
      totalStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ❌ Error tras ${totalStopwatch.elapsedMilliseconds}ms: $e');
      emit(TrainingsError(message: e.toString()));
    }
  }

  /// Refrescar datos manteniendo filtros
  Future<void> _onRefreshRequested(
    TrainingsRefreshRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    DateTime? currentFromDate;
    DateTime? currentToDate;
    int? currentType;

    if (currentState is TrainingsLoaded) {
      currentFromDate = currentState.filterFromDate;
      currentToDate = currentState.filterToDate;
      currentType = currentState.filterByType;
    }

    try {
      final response = await _datasource.getEntrenamientos(
        idequipo: event.idequipo,
        idtemporada: event.activeSeasonId,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Error al refrescar entrenamientos');
      }

      var trainings = response.data!;
      var filteredTrainings = trainings;

      if (currentFromDate != null || currentToDate != null) {
        filteredTrainings = _filterByDateRange(filteredTrainings, currentFromDate, currentToDate);
      }
      if (currentType != null) {
        filteredTrainings = _filterByTypeId(filteredTrainings, currentType);
      }

      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: filteredTrainings,
        trainingTypes: {},
        filterFromDate: currentFromDate,
        filterToDate: currentToDate,
        filterByType: currentType,
        focusedWeek: DateTime.now(),
        activeSeasonId: event.activeSeasonId,
      ));
    } catch (e) {
      emit(TrainingsError(message: e.toString()));
    }
  }

  /// Filtrar por rango de fechas
  void _onFilterByDate(
    TrainingsFilterByDate event,
    Emitter<TrainingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    var filtered = currentState.trainings;

    if (event.fromDate != null || event.toDate != null) {
      filtered = _filterByDateRange(filtered, event.fromDate, event.toDate);
    }

    if (currentState.filterByType != null) {
      filtered = _filterByTypeId(filtered, currentState.filterByType!);
    }

    emit(currentState.copyWith(
      filteredTrainings: filtered,
      filterFromDate: event.fromDate,
      filterToDate: event.toDate,
    ));
  }

  /// Filtrar por tipo de entrenamiento
  void _onFilterByType(
    TrainingsFilterByType event,
    Emitter<TrainingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    var filtered = currentState.trainings;

    if (event.idtipo != null) {
      filtered = _filterByTypeId(filtered, event.idtipo!);
    }

    if (currentState.filterFromDate != null || currentState.filterToDate != null) {
      filtered = _filterByDateRange(filtered, currentState.filterFromDate, currentState.filterToDate);
    }

    emit(currentState.copyWith(
      filteredTrainings: filtered,
      filterByType: event.idtipo,
    ));
  }

  /// Limpiar todos los filtros
  void _onClearFilters(
    TrainingsClearFilters event,
    Emitter<TrainingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    emit(currentState.copyWith(
      filteredTrainings: currentState.trainings,
      filterFromDate: null,
      filterToDate: null,
      filterByType: null,
    ));
  }

  /// Crear nuevo entrenamiento
  Future<void> _onCreateRequested(
    TrainingCreateRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    final activeSeasonId = currentState is TrainingsLoaded ? currentState.activeSeasonId : 0;

    try {
      final response = await _datasource.createEntrenamiento(
        idequipo: event.idequipo,
        fecha: event.fecha,
        horaInicio: event.horaInicio ?? '00:00',
        horaFin: event.horaFin ?? '00:00',
        observaciones: event.observaciones,
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Error al crear entrenamiento');
      }

      debugPrint('🏋️ [TrainingsBloc] Entrenamiento creado correctamente');
      add(TrainingsLoadRequested(idequipo: event.idequipo, activeSeasonId: activeSeasonId));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error al crear: $e');
      emit(TrainingsError(message: 'Error al crear entrenamiento: $e'));
    }
  }

  /// Actualizar entrenamiento existente
  Future<void> _onUpdateRequested(
    TrainingUpdateRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    final activeSeasonId = currentState is TrainingsLoaded ? currentState.activeSeasonId : 0;

    try {
      final response = await _datasource.updateEntrenamiento(
        id: event.id,
        idequipo: event.idequipo,
        fecha: event.fecha,
        horaInicio: event.horaInicio ?? '00:00',
        horaFin: event.horaFin ?? '00:00',
        observaciones: event.observaciones,
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Error al actualizar entrenamiento');
      }

      debugPrint('🏋️ [TrainingsBloc] Entrenamiento actualizado correctamente');
      add(TrainingsLoadRequested(idequipo: event.idequipo, activeSeasonId: activeSeasonId));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error al actualizar: $e');
      emit(TrainingsError(message: 'Error al actualizar entrenamiento: $e'));
    }
  }

  /// Eliminar entrenamiento
  Future<void> _onDeleteRequested(
    TrainingDeleteRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    final activeSeasonId = currentState is TrainingsLoaded ? currentState.activeSeasonId : 0;

    try {
      final response = await _datasource.deleteEntrenamiento(id: event.id);

      if (!response.success) {
        throw Exception(response.message ?? 'Error al eliminar entrenamiento');
      }

      debugPrint('🏋️ [TrainingsBloc] Entrenamiento eliminado correctamente');
      add(TrainingsLoadRequested(idequipo: event.idequipo, activeSeasonId: activeSeasonId));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error al eliminar: $e');
      emit(TrainingsError(message: 'Error al eliminar entrenamiento: $e'));
    }
  }

  /// Cargar lista de asistencia
  Future<void> _onAttendanceLoadRequested(
    AttendanceLoadRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final totalStopwatch = Stopwatch()..start();
    emit(const TrainingsLoading());
    debugPrint('🏋️ [TrainingsBloc] ⏱️ INICIO _onAttendanceLoadRequested (identrenamiento=${event.identrenamiento})');

    try {
      // Cargar motivos
      final motivesResponse = await _datasource.getMotivosAsistencia();
      if (!motivesResponse.success || motivesResponse.data == null) {
        throw Exception(motivesResponse.message ?? 'Error al cargar motivos');
      }
      final motives = motivesResponse.data!;

      // Cargar asistencia
      final attendanceResponse = await _datasource.getAsistenciaEntrenamiento(
        identrenamiento: event.identrenamiento,
      );

      if (!attendanceResponse.success || attendanceResponse.data == null) {
        throw Exception(attendanceResponse.message ?? 'Error al cargar asistencia');
      }

      final attendanceData = attendanceResponse.data!;

      if (attendanceData.isEmpty) {
        debugPrint('🏋️ [TrainingsBloc] ✅ TOTAL _onAttendanceLoadRequested: ${totalStopwatch.elapsedMilliseconds}ms (sin jugadores)');
        emit(AttendanceState(
          identrenamiento: event.identrenamiento,
          idequipo: event.idequipo,
          idclub: 0,
          players: [],
          motives: motives,
          attendance: {},
          selectedMotive: {},
          observations: {},
        ));
        return;
      }

      // Construir listas
      final players = <Map<String, dynamic>>[];
      final attendance = <int, bool>{};
      final selectedMotive = <int, int?>{};
      final observations = <int, String?>{};

      int? idclub;
      int? idequipo;

      for (final att in attendanceData) {
        final idJugador = att['id'] as int;
        idclub ??= att['idclub'] as int?;
        idequipo ??= att['idequipo'] as int?;

        players.add({
          'id': idJugador,
          'nombre': att['nombre']?.toString() ?? '',
          'apellidos': att['apellidos']?.toString() ?? '',
          'dorsal': att['dorsal']?.toString() ?? '',
          'foto': att['foto']?.toString() ?? '',
          'idposicion': att['idposicion'],
        });

        attendance[idJugador] = att['asiste'] == true;
        selectedMotive[idJugador] = att['idmotivo'] as int?;
        observations[idJugador] = att['observaciones'] as String?;
      }

      debugPrint('🏋️ [TrainingsBloc] ✅ TOTAL _onAttendanceLoadRequested: ${totalStopwatch.elapsedMilliseconds}ms (${players.length} jugadores)');

      emit(AttendanceState(
        identrenamiento: event.identrenamiento,
        idequipo: idequipo ?? event.idequipo,
        idclub: idclub ?? 0,
        players: players,
        motives: motives,
        attendance: attendance,
        selectedMotive: selectedMotive,
        observations: observations,
      ));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] ❌ Error tras ${totalStopwatch.elapsedMilliseconds}ms: $e');
      emit(TrainingsError(message: 'Error al cargar asistencia: $e'));
    }
  }

  /// Marcar asistencia individual
  void _onAttendanceMarkRequested(
    AttendanceMarkRequested event,
    Emitter<TrainingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! AttendanceState) return;

    final newAttendance = Map<int, bool>.from(currentState.attendance);
    final newSelectedMotive = Map<int, int?>.from(currentState.selectedMotive);
    final newObservations = Map<int, String?>.from(currentState.observations);

    newAttendance[event.idjugador] = event.presente;

    if (event.idmotivo != null) {
      newSelectedMotive[event.idjugador] = event.idmotivo;
    }

    if (event.observaciones != null) {
      newObservations[event.idjugador] = event.observaciones;
    }

    emit(currentState.copyWith(
      attendance: newAttendance,
      selectedMotive: newSelectedMotive,
      observations: newObservations,
    ));
  }

  /// Guardar toda la asistencia
  Future<void> _onAttendanceSaveRequested(
    AttendanceSaveRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttendanceState) return;

    emit(currentState.copyWith(isSaving: true));

    try {
      // Preparar datos de asistencia
      final asistencia = event.attendance.entries.map((entry) {
        return {
          'idjugador': entry.key,
          'asiste': entry.value,
          'idmotivo': event.selectedMotive[entry.key],
          'observaciones': event.observations[entry.key],
        };
      }).toList();

      final response = await _datasource.saveAsistenciaEntrenamiento(
        identrenamiento: event.identrenamiento,
        idequipo: currentState.idequipo,
        idclub: currentState.idclub,
        asistencia: asistencia,
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Error al guardar asistencia');
      }

      debugPrint('🏋️ [TrainingsBloc] Asistencia guardada correctamente');
      emit(currentState.copyWith(isSaving: false));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error al guardar asistencia: $e');
      emit(TrainingsError(message: 'Error al guardar asistencia: $e'));
    }
  }

  /// Filtra entrenamientos por rango de fechas
  List<Map<String, dynamic>> _filterByDateRange(
    List<Map<String, dynamic>> trainings,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    return trainings.where((t) {
      final fechaStr = t['fecha']?.toString();
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

  /// Filtra entrenamientos por tipo
  List<Map<String, dynamic>> _filterByTypeId(
    List<Map<String, dynamic>> trainings,
    int idtipo,
  ) {
    return trainings.where((t) => t['idpauta'] == idtipo).toList();
  }

  /// Cargar entrenamientos de todos los equipos de un club
  Future<void> _onLoadByClubRequested(
    TrainingsLoadByClubRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final totalStopwatch = Stopwatch()..start();
    debugPrint('🏋️⏱️ [BLOC] ========== INICIO _onLoadByClubRequested ==========');
    debugPrint('🏋️⏱️ [BLOC] idclub=${event.idclub}, temporada=${event.activeSeasonId}');
    emit(const TrainingsLoading());

    if (event.idclub <= 0) {
      debugPrint('🏋️ [TrainingsBloc] ID de club inválido, emitiendo estado vacío');
      emit(TrainingsLoaded(
        trainings: [],
        filteredTrainings: [],
        trainingTypes: {},
        teams: [],
        focusedWeek: DateTime.now(),
        isClubView: true,
        activeSeasonId: event.activeSeasonId,
      ));
      return;
    }

    try {
      // Cargar equipos
      final equiposResponse = await _datasource.getEquipos(
        idclub: event.idclub,
        idtemporada: event.activeSeasonId,
      );

      if (!equiposResponse.success || equiposResponse.data == null) {
        throw Exception(equiposResponse.message ?? 'Error al cargar equipos');
      }

      final teams = equiposResponse.data!;

      if (teams.isEmpty) {
        emit(TrainingsLoaded(
          trainings: [],
          filteredTrainings: [],
          trainingTypes: {},
          teams: [],
          focusedWeek: DateTime.now(),
          isClubView: true,
          activeSeasonId: event.activeSeasonId,
        ));
        return;
      }

      // Cargar categorías
      final categoriasResponse = await _datasource.getCategorias();
      final categoriasMap = <int, String>{};
      if (categoriasResponse.success && categoriasResponse.data != null) {
        for (final cat in categoriasResponse.data!) {
          categoriasMap[cat['id'] as int] = cat['categoria'] as String;
        }
      }

      // Enriquecer equipos con categoría
      final enrichedTeams = teams.map((e) {
        final idCategoria = e['idcategoria'] as int?;
        return {
          'id': e['id'],
          'equipo': e['equipo'],
          'ncorto': e['ncorto'],
          'categoria': idCategoria != null ? categoriasMap[idCategoria] ?? '-' : '-',
        };
      }).toList();

      // Cargar entrenamientos
      final trainingsResponse = await _datasource.getEntrenamientosByClub(
        idclub: event.idclub,
        idtemporada: event.activeSeasonId,
      );

      if (!trainingsResponse.success || trainingsResponse.data == null) {
        throw Exception(trainingsResponse.message ?? 'Error al cargar entrenamientos');
      }

      final trainings = trainingsResponse.data!;

      // Enriquecer entrenamientos con datos del equipo
      final equiposMap = <int, Map<String, dynamic>>{};
      for (final equipo in enrichedTeams) {
        equiposMap[equipo['id'] as int] = equipo;
      }

      for (final training in trainings) {
        final idequipo = training['idequipo'] as int?;
        if (idequipo != null && equiposMap.containsKey(idequipo)) {
          final equipo = equiposMap[idequipo]!;
          training['nombre_equipo'] = equipo['equipo'];
          training['ncorto'] = equipo['ncorto'];
          training['categoria'] = equipo['categoria'];
        }
      }

      // Calcular distribuciones
      final trainingsByTimeSlot = <String, int>{'mañana': 0, 'tarde': 0};
      final trainingsByField = <String, int>{};
      final trainingsByTeam = <int, int>{};

      for (final training in trainings) {
        final hinicio = training['hinicio']?.toString() ?? '';
        if (hinicio.isNotEmpty) {
          final hora = int.tryParse(hinicio.split(':').first) ?? 12;
          if (hora < 14) {
            trainingsByTimeSlot['mañana'] = (trainingsByTimeSlot['mañana'] ?? 0) + 1;
          } else {
            trainingsByTimeSlot['tarde'] = (trainingsByTimeSlot['tarde'] ?? 0) + 1;
          }
        }

        final campo = training['campo']?.toString() ?? 'Sin campo';
        trainingsByField[campo] = (trainingsByField[campo] ?? 0) + 1;

        final idequipo = training['idequipo'] as int?;
        if (idequipo != null) {
          trainingsByTeam[idequipo] = (trainingsByTeam[idequipo] ?? 0) + 1;
        }
      }

      totalStopwatch.stop();
      debugPrint('🏋️⏱️ [BLOC] ========== RESUMEN ==========');
      debugPrint('🏋️⏱️ [BLOC] TOTAL: ${totalStopwatch.elapsedMilliseconds}ms');
      debugPrint('🏋️⏱️ [BLOC] ==============================');

      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: trainings,
        trainingTypes: {},
        teams: enrichedTeams,
        focusedWeek: DateTime.now(),
        isClubView: true,
        trainingsByTimeSlot: trainingsByTimeSlot,
        trainingsByField: trainingsByField,
        trainingsByTeam: trainingsByTeam,
        activeSeasonId: event.activeSeasonId,
      ));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] ❌ Error tras ${totalStopwatch.elapsedMilliseconds}ms: $e');
      emit(TrainingsError(message: e.toString()));
    }
  }

  /// Cargar estadísticas de asistencia
  Future<void> _onAttendanceStatsRequested(
    AttendanceStatsRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    final totalStopwatch = Stopwatch()..start();
    debugPrint('🏋️ [TrainingsBloc] ⏱️ [0] INICIO _onAttendanceStatsRequested');

    try {
      final response = await _datasource.getEstadisticasAsistencia(
        idclub: event.idclub,
        idtemporada: event.activeSeasonId,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Error al cargar estadísticas');
      }

      final statsList = response.data!;

      final attendanceByTeam = <int, double>{};
      double totalPresent = 0;
      int totalCount = 0;

      for (final record in statsList) {
        final idequipo = record['idequipo'] as int;
        final total = (record['total'] as num).toInt();
        final presentes = (record['presentes'] as num).toInt();
        final percentage = total > 0 ? (presentes / total) * 100 : 0.0;

        attendanceByTeam[idequipo] = double.parse(percentage.toStringAsFixed(1));
        totalPresent += presentes;
        totalCount += total;
      }

      final overallAttendance = totalCount > 0
          ? double.parse(((totalPresent / totalCount) * 100).toStringAsFixed(1))
          : 0.0;

      emit(currentState.copyWith(
        attendanceByTeam: attendanceByTeam,
        overallAttendance: overallAttendance,
      ));

      debugPrint('🏋️ [TrainingsBloc] ✅ TOTAL: ${totalStopwatch.elapsedMilliseconds}ms - Asistencia: $overallAttendance%');
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] ❌ Error tras ${totalStopwatch.elapsedMilliseconds}ms: $e');
    }
  }

  /// Cambiar vista de calendario
  void _onCalendarViewChanged(
    CalendarViewChanged event,
    Emitter<TrainingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    emit(currentState.copyWith(viewMode: event.viewMode));

    if (event.viewMode == 'month' && currentState.attendanceByTeam.isEmpty) {
      add(AttendanceStatsRequested(
        idclub: currentState.trainings.first['idclub'] ?? 0,
        activeSeasonId: currentState.activeSeasonId,
      ));
    }
  }

  /// Navegar entre semanas
  void _onWeekNavigationRequested(
    WeekNavigationRequested event,
    Emitter<TrainingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    final newFocusedWeek = event.goToNext
        ? event.focusedWeek.add(const Duration(days: 7))
        : event.focusedWeek.subtract(const Duration(days: 7));

    emit(currentState.copyWith(focusedWeek: newFocusedWeek));
  }
}
