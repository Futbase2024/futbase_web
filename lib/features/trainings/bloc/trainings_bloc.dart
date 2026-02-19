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
  }

  /// Carga inicial de entrenamientos
  Future<void> _onLoadRequested(
    TrainingsLoadRequested event,
    Emitter<TrainingsState> emit,
  ) async {
    debugPrint('🏋️ [TrainingsBloc] Cargando entrenamientos (idequipo=${event.idequipo})');
    emit(const TrainingsLoading());

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

        players.add({
          'id': idJugador,
          'nombre': att['nombrejug']?.toString() ?? '',
          'apellidos': att['apellidos']?.toString() ?? '',
          'dorsal': '', // La vista no tiene dorsal
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

    // Si asiste, limpiar motivo; si no, guardar motivo
    if (event.presente) {
      newSelectedMotive[event.idjugador] = null;
    } else if (event.idmotivo != null) {
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
}
