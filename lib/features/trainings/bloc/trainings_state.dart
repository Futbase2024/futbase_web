import 'package:equatable/equatable.dart';

const _unset = Object();

abstract class TrainingsState extends Equatable {
  const TrainingsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TrainingsInitial extends TrainingsState {
  const TrainingsInitial();
}

/// Estado de carga
class TrainingsLoading extends TrainingsState {
  const TrainingsLoading();
}

/// Estado con datos cargados
class TrainingsLoaded extends TrainingsState {
  final List<Map<String, dynamic>> trainings;
  final List<Map<String, dynamic>> filteredTrainings;
  final Map<int, String> trainingTypes;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  final int? filterByType;

  const TrainingsLoaded({
    required this.trainings,
    required this.filteredTrainings,
    required this.trainingTypes,
    this.filterFromDate,
    this.filterToDate,
    this.filterByType,
  });

  /// Total de entrenamientos
  int get totalTrainings => trainings.length;

  /// Entrenamientos completados (fecha anterior a hoy)
  int get completedTrainings {
    final now = DateTime.now();
    return trainings.where((t) {
      final fecha = DateTime.tryParse(t['fecha']?.toString() ?? '');
      return fecha != null && fecha.isBefore(DateTime(now.year, now.month, now.day));
    }).length;
  }

  /// Entrenamientos próximos (fecha igual o posterior a hoy)
  int get upcomingTrainings {
    final now = DateTime.now();
    return trainings.where((t) {
      final fecha = DateTime.tryParse(t['fecha']?.toString() ?? '');
      return fecha != null && !fecha.isBefore(DateTime(now.year, now.month, now.day));
    }).length;
  }

  /// Porcentaje de asistencia media (placeholder - se calcularía con datos de asistencia)
  double get averageAttendance => 0.0;

  bool get hasActiveFilters =>
      filterFromDate != null || filterToDate != null || filterByType != null;

  @override
  List<Object?> get props => [
        trainings,
        filteredTrainings,
        trainingTypes,
        filterFromDate,
        filterToDate,
        filterByType,
      ];

  TrainingsLoaded copyWith({
    List<Map<String, dynamic>>? trainings,
    List<Map<String, dynamic>>? filteredTrainings,
    Map<int, String>? trainingTypes,
    Object? filterFromDate = _unset,
    Object? filterToDate = _unset,
    Object? filterByType = _unset,
  }) {
    return TrainingsLoaded(
      trainings: trainings ?? this.trainings,
      filteredTrainings: filteredTrainings ?? this.filteredTrainings,
      trainingTypes: trainingTypes ?? this.trainingTypes,
      filterFromDate:
          filterFromDate == _unset ? this.filterFromDate : filterFromDate as DateTime?,
      filterToDate:
          filterToDate == _unset ? this.filterToDate : filterToDate as DateTime?,
      filterByType:
          filterByType == _unset ? this.filterByType : filterByType as int?,
    );
  }
}

/// Estado de error
class TrainingsError extends TrainingsState {
  final String message;

  const TrainingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado para gestión de asistencia
class AttendanceState extends TrainingsState {
  final int identrenamiento;
  final int idequipo;
  final int idclub;
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> motives; // Lista de motivos disponibles
  final Map<int, bool> attendance;
  final Map<int, int?> selectedMotive; // idjugador -> idmotivo (1 = Asiste)
  final Map<int, String?> observations;
  final bool isSaving;

  const AttendanceState({
    required this.identrenamiento,
    required this.idequipo,
    required this.idclub,
    required this.players,
    required this.motives,
    required this.attendance,
    required this.selectedMotive,
    required this.observations,
    this.isSaving = false,
  });

  /// Cuenta jugadores que asisten (idmotivo = 1)
  int get presentCount => selectedMotive.values.where((id) => id == 1).length;
  int get absentCount => players.length - presentCount;
  double get attendancePercentage =>
      players.isEmpty ? 0 : (presentCount / players.length) * 100;

  @override
  List<Object?> get props => [identrenamiento, idequipo, idclub, players, motives, attendance, selectedMotive, observations, isSaving];

  AttendanceState copyWith({
    int? identrenamiento,
    int? idequipo,
    int? idclub,
    List<Map<String, dynamic>>? players,
    List<Map<String, dynamic>>? motives,
    Map<int, bool>? attendance,
    Map<int, int?>? selectedMotive,
    Map<int, String?>? observations,
    bool? isSaving,
  }) {
    return AttendanceState(
      identrenamiento: identrenamiento ?? this.identrenamiento,
      idequipo: idequipo ?? this.idequipo,
      idclub: idclub ?? this.idclub,
      players: players ?? this.players,
      motives: motives ?? this.motives,
      attendance: attendance ?? this.attendance,
      selectedMotive: selectedMotive ?? this.selectedMotive,
      observations: observations ?? this.observations,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
