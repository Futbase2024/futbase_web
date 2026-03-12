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
  final int activeSeasonId; // Temporada activa

  // Campos nuevos para Club/Coordinador
  final List<Map<String, dynamic>> teams; // Equipos del club
  final Map<int, double> attendanceByTeam; // % asistencia por equipo
  final double overallAttendance; // Asistencia media global
  final String viewMode; // 'list', 'month', 'week'
  final DateTime focusedWeek; // Semana enfocada en calendario semanal
  final bool isClubView; // True si es vista de club/coordinador

  // Estadísticas de distribución
  final Map<String, int> trainingsByTimeSlot; // mañana, tarde
  final Map<String, int> trainingsByField; // campo -> cantidad
  final Map<int, int> trainingsByTeam; // idequipo -> cantidad semanal

  const TrainingsLoaded({
    required this.trainings,
    required this.filteredTrainings,
    required this.trainingTypes,
    this.filterFromDate,
    this.filterToDate,
    this.filterByType,
    this.activeSeasonId = 0,
    this.teams = const [],
    this.attendanceByTeam = const {},
    this.overallAttendance = 0.0,
    this.viewMode = 'list',
    required this.focusedWeek,
    this.isClubView = false,
    this.trainingsByTimeSlot = const {},
    this.trainingsByField = const {},
    this.trainingsByTeam = const {},
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

  /// Porcentaje de asistencia media
  double get averageAttendance => overallAttendance;

  bool get hasActiveFilters =>
      filterFromDate != null || filterToDate != null || filterByType != null;

  /// Obtiene los entrenamientos de una fecha específica
  List<Map<String, dynamic>> getTrainingsForDate(DateTime date) {
    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;
      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else {
        fecha = DateTime.tryParse(fechaRaw?.toString() ?? '');
      }
      if (fecha == null) return false;
      return fecha.year == date.year && fecha.month == date.month && fecha.day == date.day;
    }).toList();
  }

  /// Obtiene los entrenamientos de la semana enfocada
  List<Map<String, dynamic>> getWeekTrainings() {
    final startOfWeek = focusedWeek.subtract(Duration(days: focusedWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;
      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else {
        fecha = DateTime.tryParse(fechaRaw?.toString() ?? '');
      }
      if (fecha == null) return false;

      final fechaClean = DateTime(fecha.year, fecha.month, fecha.day);
      final startClean = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endClean = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

      return !fechaClean.isBefore(startClean) && !fechaClean.isAfter(endClean);
    }).toList();
  }

  @override
  List<Object?> get props => [
        trainings,
        filteredTrainings,
        trainingTypes,
        filterFromDate,
        filterToDate,
        filterByType,
        activeSeasonId,
        teams,
        attendanceByTeam,
        overallAttendance,
        viewMode,
        focusedWeek,
        isClubView,
        trainingsByTimeSlot,
        trainingsByField,
        trainingsByTeam,
      ];

  TrainingsLoaded copyWith({
    List<Map<String, dynamic>>? trainings,
    List<Map<String, dynamic>>? filteredTrainings,
    Map<int, String>? trainingTypes,
    Object? filterFromDate = _unset,
    Object? filterToDate = _unset,
    Object? filterByType = _unset,
    int? activeSeasonId,
    List<Map<String, dynamic>>? teams,
    Map<int, double>? attendanceByTeam,
    double? overallAttendance,
    String? viewMode,
    DateTime? focusedWeek,
    bool? isClubView,
    Map<String, int>? trainingsByTimeSlot,
    Map<String, int>? trainingsByField,
    Map<int, int>? trainingsByTeam,
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
      activeSeasonId: activeSeasonId ?? this.activeSeasonId,
      teams: teams ?? this.teams,
      attendanceByTeam: attendanceByTeam ?? this.attendanceByTeam,
      overallAttendance: overallAttendance ?? this.overallAttendance,
      viewMode: viewMode ?? this.viewMode,
      focusedWeek: focusedWeek ?? this.focusedWeek,
      isClubView: isClubView ?? this.isClubView,
      trainingsByTimeSlot: trainingsByTimeSlot ?? this.trainingsByTimeSlot,
      trainingsByField: trainingsByField ?? this.trainingsByField,
      trainingsByTeam: trainingsByTeam ?? this.trainingsByTeam,
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
