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
    debugPrint('🏋️ [TrainingsBloc] Cargando entrenamientos (idequipo=${event.idequipo})');
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
      // Cargar entrenamientos desde la vista que ya incluye el campo 'campo' (lugar)
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
          .order('fecha', ascending: false);

      final trainings = (trainingsData as List<dynamic>).cast<Map<String, dynamic>>().toList();

      debugPrint('🏋️ [TrainingsBloc] Cargados ${trainings.length} entrenamientos');
      emit(TrainingsLoaded(
        trainings: trainings,
        filteredTrainings: trainings,
        trainingTypes: {}, // No hay tabla de tipos
        focusedWeek: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error: $e');
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
      // Cargar entrenamientos desde la vista que ya incluye el campo 'campo' (lugar)
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
      add(TrainingsLoadRequested(idequipo: event.idequipo));
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
      add(TrainingsLoadRequested(idequipo: event.idequipo));
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
    try {
      await _supabase
          .from('tentrenamientos')
          .delete()
          .eq('id', event.id);

      debugPrint('🏋️ [TrainingsBloc] Entrenamiento eliminado correctamente');
      add(TrainingsLoadRequested(idequipo: event.idequipo));
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
    emit(const TrainingsLoading());
    debugPrint('🏋️ [TrainingsBloc] Cargando asistencia (identrenamiento=${event.identrenamiento})');

    try {
      // Cargar motivos de asistencia disponibles
      final motivesResponse = await _supabase
          .from('tmotivoasistencia')
          .select('id, motivo')
          .order('id');

      // Cargar asistencia desde la vista ventrenojugador (incluye datos del jugador)
      final attendanceResponse = await _supabase
          .from('ventrenojugador')
          .select('idjugador, nombrejug, apellidos, asiste, idmotivo, motivo, observaciones, idequipo, idclub')
          .eq('identrenamiento', event.identrenamiento)
          .order('nombrejug')
          .order('apellidos');

      final motives = (motivesResponse as List<dynamic>).cast<Map<String, dynamic>>().toList();
      final attendanceData = attendanceResponse as List<dynamic>;

      debugPrint('🏋️ [TrainingsBloc] Registros encontrados: ${attendanceData.length}');

      if (attendanceData.isEmpty) {
        // No hay registros de asistencia para este entrenamiento
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

      // Obtener IDs de jugadores para hacer query a tjugadores
      final jugadorIds = attendanceData
          .map((att) => att['idjugador'] as int)
          .toSet()
          .toList();

      // Cargar datos adicionales de jugadores (foto, dorsal, idposicion)
      final jugadoresData = await _supabase
          .from('tjugadores')
          .select('id, dorsal, foto, idposicion')
          .inFilter('id', jugadorIds);

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

        // Obtener datos adicionales del jugador
        final jugadorExtra = jugadoresMap[idJugador];

        players.add({
          'id': idJugador,
          'nombre': att['nombrejug']?.toString() ?? '',
          'apellidos': att['apellidos']?.toString() ?? '',
          'dorsal': jugadorExtra?['dorsal']?.toString() ?? '',
          'foto': jugadorExtra?['foto']?.toString() ?? '',
          'idposicion': jugadorExtra?['idposicion'],
        });

        // asiste es smallint: 0 = no asiste, 1 = asiste
        attendance[idJugador] = (att['asiste'] as int?) == 1;
        selectedMotive[idJugador] = att['idmotivo'] as int?;
        observations[idJugador] = att['observaciones'] as String?;
      }

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
      debugPrint('🏋️ [TrainingsBloc] Error al cargar asistencia: $e');
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
    debugPrint('🏋️ [TrainingsBloc] Cargando entrenamientos del club (idclub=${event.idclub})');
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
      ));
      return;
    }

    try {
      final now = DateTime.now();

      // Calcular rango de fechas (por defecto: mes actual + 2 semanas antes/después)
      final startDate = event.startDate ??
          DateTime(now.year, now.month, 1).subtract(const Duration(days: 14));
      final endDate = event.endDate ??
          DateTime(now.year, now.month + 1, 0).add(const Duration(days: 14));

      // Obtener equipos del club
      final equiposData = await _supabase
          .from('tequipos')
          .select('id, equipo, ncorto, idcategoria')
          .eq('idclub', event.idclub);

      final equipoIds = (equiposData as List)
          .map((e) => e['id'] as int)
          .toList();

      if (equipoIds.isEmpty) {
        emit(TrainingsLoaded(
          trainings: [],
          filteredTrainings: [],
          trainingTypes: {},
          teams: [],
          focusedWeek: DateTime.now(),
          isClubView: true,
        ));
        return;
      }

      // Obtener categorías
      final categoriasData = await _supabase
          .from('tcategorias')
          .select('id, categoria');

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

      // Cargar entrenamientos de todos los equipos
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
          .gte('fecha', startDate.toIso8601String().split('T')[0])
          .lte('fecha', endDate.toIso8601String().split('T')[0])
          .order('fecha', ascending: true)
          .order('hinicio', ascending: true);

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

      debugPrint('🏋️ [TrainingsBloc] Cargados ${trainings.length} entrenamientos de ${teams.length} equipos');

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
      ));

      // Cargar estadísticas de asistencia en segundo plano
      add(AttendanceStatsRequested(idclub: event.idclub));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error: $e');
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

    try {
      debugPrint('🏋️ [TrainingsBloc] Cargando estadísticas de asistencia');

      // Obtener estadísticas de asistencia por equipo
      final statsResponse = await _supabase
          .from('ventrenojugador')
          .select('idequipo, asiste, idmotivo')
          .eq('idclub', event.idclub);

      final attendanceByTeam = <int, double>{};
      final teamCounts = <int, int>{};
      final teamPresent = <int, int>{};

      for (final record in statsResponse as List) {
        final idequipo = record['idequipo'] as int?;
        if (idequipo == null) continue;

        teamCounts[idequipo] = (teamCounts[idequipo] ?? 0) + 1;

        // asiste = 1 o idmotivo = 1 significa que asistió
        final asiste = record['asiste'] as int?;
        final idmotivo = record['idmotivo'] as int?;
        if (asiste == 1 || idmotivo == 1) {
          teamPresent[idequipo] = (teamPresent[idequipo] ?? 0) + 1;
        }
      }

      // Calcular porcentajes
      double totalPresent = 0;
      int totalCount = 0;

      for (final entry in teamCounts.entries) {
        final idequipo = entry.key;
        final count = entry.value;
        final present = teamPresent[idequipo] ?? 0;
        final percentage = count > 0 ? (present / count) * 100 : 0.0;
        attendanceByTeam[idequipo] = double.parse(percentage.toStringAsFixed(1));

        totalPresent += present;
        totalCount += count;
      }

      final overallAttendance = totalCount > 0
          ? double.parse(((totalPresent / totalCount) * 100).toStringAsFixed(1))
          : 0.0;

      debugPrint('🏋️ [TrainingsBloc] Asistencia media: $overallAttendance%');

      emit(currentState.copyWith(
        attendanceByTeam: attendanceByTeam,
        overallAttendance: overallAttendance,
      ));
    } catch (e) {
      debugPrint('🏋️ [TrainingsBloc] Error al cargar estadísticas: $e');
      // No emitir error, mantener estado actual
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
