import 'package:equatable/equatable.dart';

abstract class TrainingsEvent extends Equatable {
  const TrainingsEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar entrenamientos de un equipo
class TrainingsLoadRequested extends TrainingsEvent {
  final int idequipo;

  const TrainingsLoadRequested({required this.idequipo});

  @override
  List<Object?> get props => [idequipo];
}

/// Refrescar lista de entrenamientos
class TrainingsRefreshRequested extends TrainingsEvent {
  final int idequipo;

  const TrainingsRefreshRequested({required this.idequipo});

  @override
  List<Object?> get props => [idequipo];
}

/// Filtrar entrenamientos por rango de fechas
class TrainingsFilterByDate extends TrainingsEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const TrainingsFilterByDate({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Filtrar entrenamientos por tipo
class TrainingsFilterByType extends TrainingsEvent {
  final int? idtipo;

  const TrainingsFilterByType({this.idtipo});

  @override
  List<Object?> get props => [idtipo];
}

/// Limpiar todos los filtros
class TrainingsClearFilters extends TrainingsEvent {
  const TrainingsClearFilters();
}

/// Crear nuevo entrenamiento
class TrainingCreateRequested extends TrainingsEvent {
  final int idequipo;
  final DateTime fecha;
  final String? horaInicio;
  final String? horaFin;
  final int? idtipo;
  final String? observaciones;

  const TrainingCreateRequested({
    required this.idequipo,
    required this.fecha,
    this.horaInicio,
    this.horaFin,
    this.idtipo,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        idequipo,
        fecha,
        horaInicio,
        horaFin,
        idtipo,
        observaciones,
      ];
}

/// Actualizar entrenamiento existente
class TrainingUpdateRequested extends TrainingsEvent {
  final int id;
  final int idequipo;
  final DateTime fecha;
  final String? horaInicio;
  final String? horaFin;
  final int? idtipo;
  final String? observaciones;

  const TrainingUpdateRequested({
    required this.id,
    required this.idequipo,
    required this.fecha,
    this.horaInicio,
    this.horaFin,
    this.idtipo,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        id,
        idequipo,
        fecha,
        horaInicio,
        horaFin,
        idtipo,
        observaciones,
      ];
}

/// Eliminar entrenamiento
class TrainingDeleteRequested extends TrainingsEvent {
  final int id;
  final int idequipo;

  const TrainingDeleteRequested({required this.id, required this.idequipo});

  @override
  List<Object?> get props => [id, idequipo];
}

/// Cargar lista de asistencia de un entrenamiento
class AttendanceLoadRequested extends TrainingsEvent {
  final int identrenamiento;
  final int idequipo;

  const AttendanceLoadRequested({
    required this.identrenamiento,
    required this.idequipo,
  });

  @override
  List<Object?> get props => [identrenamiento, idequipo];
}

/// Registrar asistencia de un jugador
class AttendanceMarkRequested extends TrainingsEvent {
  final int identrenamiento;
  final int idjugador;
  final bool presente;
  final int? idmotivo; // Motivo si no asiste
  final String? observaciones;

  const AttendanceMarkRequested({
    required this.identrenamiento,
    required this.idjugador,
    required this.presente,
    this.idmotivo,
    this.observaciones,
  });

  @override
  List<Object?> get props => [identrenamiento, idjugador, presente, idmotivo, observaciones];
}

/// Guardar toda la asistencia de una vez
class AttendanceSaveRequested extends TrainingsEvent {
  final int identrenamiento;
  final Map<int, bool> attendance;
  final Map<int, int?> selectedMotive;
  final Map<int, String?> observations;

  const AttendanceSaveRequested({
    required this.identrenamiento,
    required this.attendance,
    required this.selectedMotive,
    required this.observations,
  });

  @override
  List<Object?> get props => [identrenamiento, attendance, selectedMotive, observations];
}

/// Cargar entrenamientos de todos los equipos de un club (para Club/Coordinador)
class TrainingsLoadByClubRequested extends TrainingsEvent {
  final int idclub;
  final DateTime? startDate;
  final DateTime? endDate;

  const TrainingsLoadByClubRequested({
    required this.idclub,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [idclub, startDate, endDate];
}

/// Cargar estadísticas de asistencia
class AttendanceStatsRequested extends TrainingsEvent {
  final int idclub;
  final int? idequipo;

  const AttendanceStatsRequested({
    required this.idclub,
    this.idequipo,
  });

  @override
  List<Object?> get props => [idclub, idequipo];
}

/// Cambiar vista de calendario
class CalendarViewChanged extends TrainingsEvent {
  final String viewMode; // 'list', 'month', 'week'

  const CalendarViewChanged({required this.viewMode});

  @override
  List<Object?> get props => [viewMode];
}

/// Navegar entre semanas
class WeekNavigationRequested extends TrainingsEvent {
  final DateTime focusedWeek;
  final bool goToNext;

  const WeekNavigationRequested({
    required this.focusedWeek,
    required this.goToNext,
  });

  @override
  List<Object?> get props => [focusedWeek, goToNext];
}
