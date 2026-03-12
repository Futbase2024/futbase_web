import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'trainings_event.dart';
import 'trainings_state.dart';

/// BLoC para gestión de entrenamientos
class TrainingsBloc extends Bloc<TrainingsEvent, TrainingsState> {
  final SupabaseClient _supabase;

  TrainingsBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
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
    // Nuevos handlers para Club/Coordinador
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

    // Si el idequipo no es válido, emitir estado vacío
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
      // Cargar entrenamientos desde la vista filtrando por temporada
      final queryStopwatch = Stopwatch()..start();
      final trainingsData = await _supabase
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
          .eq('idequipo', event.idequipo)
          .eq('idtemporada', event.activeSeasonId)
          .order('fecha', ascending: false);
      queryStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ Query ventrenamientos: ${queryStopwatch.elapsedMilliseconds}ms (${trainingsData.length} registros)');

      final processingStopwatch = Stopwatch()..start();
      final trainings = (trainingsData as List<dynamic>).cast<Map<String, dynamic>>().toList();
      processingStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ Procesamiento datos: ${processingStopwatch.elapsedMilliseconds}ms');

      totalStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ✅ TOTAL _onLoadRequested: ${totalStopwatch.elapsedMilliseconds}ms');

      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: trainings,
        trainingTypes: {}, // No hay tabla de tipos
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
      // Cargar entrenamientos desde la vista filtrando por temporada
      final trainingsData = await _supabase
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
          .eq('idequipo', event.idequipo)
          .eq('idtemporada', event.activeSeasonId)
          .order('fecha', ascending: false);

      var trainings = (trainingsData as List<dynamic>).cast<Map<String, dynamic>>().toList();
      var filteredTrainings = trainings;

      // Reaplicar filtros
      if (currentFromDate != null || currentToDate != null) {
        filteredTrainings = _filterByDateRange(filteredTrainings, currentFromDate, currentToDate);
      }
      if (currentType != null) {
        filteredTrainings = _filterByTypeId(filteredTrainings, currentType);
      }

      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: filteredTrainings,
        trainingTypes: {}, // No hay tabla de tipos
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

    // Mantener filtro de tipo si existe
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

    // Mantener filtro de fechas si existe
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
      await _supabase.from('tentrenamientos').insert({
        'idequipo': event.idequipo,
        'fecha': event.fecha.toIso8601String().split('T')[0],
        'hinicio': event.horaInicio,
        'hfin': event.horaFin,
        'nombre': event.observaciones, // Usamos nombre como descripción corta
        'observaciones': event.observaciones,
      });

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
      await _supabase
          .from('tentrenamientos')
          .update({
            'fecha': event.fecha.toIso8601String().split('T')[0],
            'hinicio': event.horaInicio,
            'hfin': event.horaFin,
            'nombre': event.observaciones,
            'observaciones': event.observaciones,
          })
          .eq('id', event.id);

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
      await _supabase
          .from('tentrenamientos')
          .delete()
          .eq('id', event.id);

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
      // PASO 1: Cargar motivos de asistencia disponibles
      final step1Stopwatch = Stopwatch()..start();
      final motivesResponse = await _supabase
          .from('tmotivoasistencia')
          .select('id, motivo')
          .order('id');
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [1] Query tmotivoasistencia: ${step1Stopwatch.elapsedMilliseconds}ms');

      // PASO 2: Cargar asistencia desde la vista ventrenojugador
      final step2Stopwatch = Stopwatch()..start();
      final attendanceResponse = await _supabase
          .from('ventrenojugador')
          .select('idjugador, nombrejug, apellidos, asiste, idmotivo, motivo, observaciones, idequipo, idclub')
          .eq('identrenamiento', event.identrenamiento)
          .order('nombrejug')
          .order('apellidos');
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [2] Query ventrenojugador: ${step2Stopwatch.elapsedMilliseconds}ms (${attendanceResponse.length} registros)');

      final processingStopwatch = Stopwatch()..start();
      final motives = (motivesResponse as List<dynamic>).cast<Map<String, dynamic>>().toList();
      final attendanceData = attendanceResponse as List<dynamic>;

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

      // PASO 3: Cargar datos adicionales de jugadores
      final step3Stopwatch = Stopwatch()..start();
      final jugadorIds = attendanceData
          .map((att) => att['idjugador'] as int)
          .toSet()
          .toList();

      final jugadoresData = await _supabase
          .from('tjugadores')
          .select('id, dorsal, foto, idposicion')
          .inFilter('id', jugadorIds);
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [3] Query tjugadores: ${step3Stopwatch.elapsedMilliseconds}ms (${jugadoresData.length} jugadores)');

      // Crear mapa de datos de jugadores
      final jugadoresMap = <int, Map<String, dynamic>>{};
      for (final jug in jugadoresData) {
        jugadoresMap[jug['id'] as int] = jug;
      }

      // Construir lista de jugadores y su asistencia
      final players = <Map<String, dynamic>>[];
      final attendance = <int, bool>{};
      final selectedMotive = <int, int?>{};
      final observations = <int, String?>{};

      int? idclub;
      int? idequipo;

      for (final att in attendanceData) {
        final idJugador = att['idjugador'] as int;
        idclub ??= att['idclub'] as int?;
        idequipo ??= att['idequipo'] as int?;

        final jugadorExtra = jugadoresMap[idJugador];

        players.add({
          'id': idJugador,
          'nombre': att['nombrejug']?.toString() ?? '',
          'apellidos': att['apellidos']?.toString() ?? '',
          'dorsal': jugadorExtra?['dorsal']?.toString() ?? '',
          'foto': jugadorExtra?['foto']?.toString() ?? '',
          'idposicion': jugadorExtra?['idposicion'],
        });

        attendance[idJugador] = (att['asiste'] as int?) == 1;
        selectedMotive[idJugador] = att['idmotivo'] as int?;
        observations[idJugador] = att['observaciones'] as String?;
      }
      debugPrint('🏋️ [TrainingsBloc] ⏱️ Procesamiento: ${processingStopwatch.elapsedMilliseconds}ms');

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

    // Guardar el motivo seleccionado (incluyendo Asiste = 1)
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
      // Eliminar asistencia anterior (tabla: tentrenojugador)
      await _supabase
          .from('tentrenojugador')
          .delete()
          .eq('identrenamiento', event.identrenamiento);

      // Insertar nueva asistencia
      final inserts = <Map<String, dynamic>>[];
      for (final entry in event.attendance.entries) {
        inserts.add({
          'identrenamiento': event.identrenamiento,
          'idjugador': entry.key,
          'idequipo': currentState.idequipo,
          'idclub': currentState.idclub,
          'asiste': entry.value ? 1 : 0, // smallint: 1 = asiste, 0 = no asiste
          'motivo': event.selectedMotive[entry.key], // Motivo de ausencia
          'observaciones': event.observations[entry.key],
        });
      }

      if (inserts.isNotEmpty) {
        await _supabase.from('tentrenojugador').insert(inserts);
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

  /// Cargar entrenamientos de todos los equipos de un club (para Club/Coordinador)
  Future<void> _onLoadByClubRequested(
    TrainingsLoadByClubRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final totalStopwatch = Stopwatch()..start();
    debugPrint('🏋️⏱️ [BLOC] ========== INICIO _onLoadByClubRequested ==========');
    debugPrint('🏋️⏱️ [BLOC] idclub=${event.idclub}, temporada=${event.activeSeasonId}');
    emit(const TrainingsLoading());

    // Si el idclub no es válido, emitir estado vacío
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
      // PASO 1: Obtener equipos del club filtrados por temporada usando la vista
      debugPrint('🏋️⏱️ [BLOC] [1/4] INICIANDO Query vequipos...');
      final step1Stopwatch = Stopwatch()..start();
      final equiposData = await _supabase
          .from('vequipos')
          .select('id, equipo, ncorto, idcategoria')
          .eq('idclub', event.idclub)
          .eq('idtemporada', event.activeSeasonId);
      step1Stopwatch.stop();
      debugPrint('🏋️⏱️ [BLOC] [1/4] Query vequipos: ${step1Stopwatch.elapsedMilliseconds}ms (${equiposData.length} equipos)');

      final equipoIds = (equiposData as List)
          .map((e) => e['id'] as int)
          .toList();

      if (equipoIds.isEmpty) {
        debugPrint('🏋️ [TrainingsBloc] ⏱️ TOTAL (sin equipos): ${totalStopwatch.elapsedMilliseconds}ms');
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

      // PASO 2: Obtener categorías
      debugPrint('🏋️⏱️ [BLOC] [2/4] INICIANDO Query tcategorias...');
      final step2Stopwatch = Stopwatch()..start();
      final categoriasData = await _supabase
          .from('tcategorias')
          .select('id, categoria');
      step2Stopwatch.stop();
      debugPrint('🏋️⏱️ [BLOC] [2/4] Query tcategorias: ${step2Stopwatch.elapsedMilliseconds}ms');

      // PASO 3: Procesar categorías y equipos (sin DB)
      final step3Stopwatch = Stopwatch()..start();
      final categoriasMap = <int, String>{};
      for (final cat in categoriasData as List) {
        categoriasMap[cat['id'] as int] = cat['categoria'] as String;
      }

      // Construir lista de equipos enriquecida
      final teams = equiposData.map((e) {
        final idCategoria = e['idcategoria'] as int?;
        return {
          'id': e['id'],
          'equipo': e['equipo'],
          'ncorto': e['ncorto'],
          'categoria': idCategoria != null ? categoriasMap[idCategoria] ?? '-' : '-',
        };
      }).toList();
      step3Stopwatch.stop();
      debugPrint('🏋️⏱️ [BLOC] [3/4] Procesar equipos (local): ${step3Stopwatch.elapsedMilliseconds}ms');

      // PASO 4: Cargar entrenamientos de todos los equipos
      debugPrint('🏋️⏱️ [BLOC] [4/4] INICIANDO Query ventrenamientos (inFilter con ${equipoIds.length} IDs)...');
      final step4Stopwatch = Stopwatch()..start();
      final trainingsData = await _supabase
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
          .eq('idtemporada', event.activeSeasonId)
          .order('fecha', ascending: true)
          .order('hinicio', ascending: true);
      step4Stopwatch.stop();
      debugPrint('🏋️⏱️ [BLOC] [4/4] Query ventrenamientos: ${step4Stopwatch.elapsedMilliseconds}ms (${trainingsData.length} registros)');

      // PASO 5: Procesar entrenamientos (sin DB)
      final step5Stopwatch = Stopwatch()..start();
      final trainings = (trainingsData as List<dynamic>).cast<Map<String, dynamic>>().toList();

      // Enriquecer entrenamientos con datos del equipo
      final equiposMap = <int, Map<String, dynamic>>{};
      for (final equipo in teams) {
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

      // Calcular distribución por horarios
      final trainingsByTimeSlot = <String, int>{'mañana': 0, 'tarde': 0};
      final trainingsByField = <String, int>{};
      final trainingsByTeam = <int, int>{};

      for (final training in trainings) {
        // Clasificar por horario
        final hinicio = training['hinicio']?.toString() ?? '';
        if (hinicio.isNotEmpty) {
          final hora = int.tryParse(hinicio.split(':').first) ?? 12;
          if (hora < 14) {
            trainingsByTimeSlot['mañana'] = (trainingsByTimeSlot['mañana'] ?? 0) + 1;
          } else {
            trainingsByTimeSlot['tarde'] = (trainingsByTimeSlot['tarde'] ?? 0) + 1;
          }
        }

        // Clasificar por campo
        final campo = training['campo']?.toString() ?? 'Sin campo';
        trainingsByField[campo] = (trainingsByField[campo] ?? 0) + 1;

        // Clasificar por equipo
        final idequipo = training['idequipo'] as int?;
        if (idequipo != null) {
          trainingsByTeam[idequipo] = (trainingsByTeam[idequipo] ?? 0) + 1;
        }
      }
      step5Stopwatch.stop();
      debugPrint('🏋️⏱️ [BLOC] [5/5] Procesar entrenamientos (local): ${step5Stopwatch.elapsedMilliseconds}ms');

      totalStopwatch.stop();
      final dbTime = step1Stopwatch.elapsedMilliseconds + step2Stopwatch.elapsedMilliseconds + step4Stopwatch.elapsedMilliseconds;
      final localTime = step3Stopwatch.elapsedMilliseconds + step5Stopwatch.elapsedMilliseconds;
      debugPrint('🏋️⏱️ [BLOC] ========== RESUMEN ==========');
      debugPrint('🏋️⏱️ [BLOC] Tiempo DB: ${dbTime}ms');
      debugPrint('🏋️⏱️ [BLOC] Tiempo Local: ${localTime}ms');
      debugPrint('🏋️⏱️ [BLOC] TOTAL: ${totalStopwatch.elapsedMilliseconds}ms');
      debugPrint('🏋️⏱️ [BLOC] ==============================');

      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: trainings,
        trainingTypes: {},
        teams: teams,
        focusedWeek: DateTime.now(),
        isClubView: true,
        trainingsByTimeSlot: trainingsByTimeSlot,
        trainingsByField: trainingsByField,
        trainingsByTeam: trainingsByTeam,
        activeSeasonId: event.activeSeasonId,
      ));

      // NOTA: Las estadísticas de asistencia se cargan bajo demanda
      // cuando el usuario cambia a la vista mensual que las necesita
      // add(AttendanceStatsRequested(idclub: event.idclub, activeSeasonId: event.activeSeasonId));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] ❌ Error tras ${totalStopwatch.elapsedMilliseconds}ms: $e');
      emit(TrainingsError(message: e.toString()));
    }
  }

  /// Cargar estadísticas de asistencia usando vista materializada (pre-calculada)
  Future<void> _onAttendanceStatsRequested(
    AttendanceStatsRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TrainingsLoaded) return;

    final totalStopwatch = Stopwatch()..start();
    debugPrint('🏋️ [TrainingsBloc] ⏱️ [0] INICIO _onAttendanceStatsRequested');

    try {
      // Construir query
      final buildStopwatch = Stopwatch()..start();
      final query = _supabase
          .from('vm_asistencia_stats')
          .select('idequipo, total, presentes')
          .eq('idclub', event.idclub)
          .eq('idtemporada', event.activeSeasonId);
      buildStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [1] Build query: ${buildStopwatch.elapsedMilliseconds}ms');

      // Ejecutar query
      final execStopwatch = Stopwatch()..start();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [2] Ejecutando query...');
      final statsResponse = await query;
      execStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [3] Query ejecutada: ${execStopwatch.elapsedMilliseconds}ms (${statsResponse.length} equipos)');

      // Parsear respuesta
      final parseStopwatch = Stopwatch()..start();
      final statsList = statsResponse as List;
      parseStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [4] Parseo a List: ${parseStopwatch.elapsedMilliseconds}ms');

      // Calcular estadísticas
      final calcStopwatch = Stopwatch()..start();
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
      calcStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [5] Cálculo estadísticas: ${calcStopwatch.elapsedMilliseconds}ms');

      // Emitir estado
      final emitStopwatch = Stopwatch()..start();
      emit(currentState.copyWith(
        attendanceByTeam: attendanceByTeam,
        overallAttendance: overallAttendance,
      ));
      emitStopwatch.stop();
      debugPrint('🏋️ [TrainingsBloc] ⏱️ [6] Emit estado: ${emitStopwatch.elapsedMilliseconds}ms');

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

    // Cargar estadísticas de asistencia solo cuando se cambia a vista mensual
    // y no están ya cargadas
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
