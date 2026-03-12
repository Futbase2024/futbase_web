import 'package:equatable/equatable.dart';

import '../domain/report_types.dart';
import '../domain/report_filter.dart';
import '../domain/report_data.dart';
import '../domain/saved_report_entity.dart';

/// Estados del BLoC de informes
abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

/// Estado de carga
class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

/// Estado con lista de informes guardados
class SavedReportsLoaded extends ReportsState {
  final List<SavedReportEntity> reports;
  final SavedReportType? filterType;
  final String userRole;
  final int? clubId;
  final int? teamId;

  const SavedReportsLoaded({
    required this.reports,
    this.filterType,
    required this.userRole,
    this.clubId,
    this.teamId,
  });

  @override
  List<Object?> get props => [reports, filterType, userRole, clubId, teamId];

  SavedReportsLoaded copyWith({
    List<SavedReportEntity>? reports,
    SavedReportType? filterType,
    String? userRole,
    int? clubId,
    int? teamId,
  }) {
    return SavedReportsLoaded(
      reports: reports ?? this.reports,
      filterType: filterType ?? this.filterType,
      userRole: userRole ?? this.userRole,
      clubId: clubId ?? this.clubId,
      teamId: teamId ?? this.teamId,
    );
  }

  /// Filtra los informes por tipo
  List<SavedReportEntity> get filteredReports {
    if (filterType == null) return reports;
    return reports.where((r) => r.reportType == filterType).toList();
  }
}

/// Estado con tipo de informe seleccionado (mostrando filtros)
class ReportTypeReady extends ReportsState {
  final ReportType selectedType;
  final ReportFilter filter;
  final List<Map<String, dynamic>> availableTeams;
  final List<Map<String, dynamic>> availableCategories;
  final List<Map<String, dynamic>> availablePlayers;
  final List<Map<String, dynamic>> availableMatches;
  final String userRole;

  const ReportTypeReady({
    required this.selectedType,
    required this.filter,
    this.availableTeams = const [],
    this.availableCategories = const [],
    this.availablePlayers = const [],
    this.availableMatches = const [],
    required this.userRole,
  });

  @override
  List<Object?> get props => [
        selectedType,
        filter,
        availableTeams,
        availableCategories,
        availablePlayers,
        availableMatches,
        userRole,
      ];

  ReportTypeReady copyWith({
    ReportType? selectedType,
    ReportFilter? filter,
    List<Map<String, dynamic>>? availableTeams,
    List<Map<String, dynamic>>? availableCategories,
    List<Map<String, dynamic>>? availablePlayers,
    List<Map<String, dynamic>>? availableMatches,
    String? userRole,
  }) {
    return ReportTypeReady(
      selectedType: selectedType ?? this.selectedType,
      filter: filter ?? this.filter,
      availableTeams: availableTeams ?? this.availableTeams,
      availableCategories: availableCategories ?? this.availableCategories,
      availablePlayers: availablePlayers ?? this.availablePlayers,
      availableMatches: availableMatches ?? this.availableMatches,
      userRole: userRole ?? this.userRole,
    );
  }
}

/// Estado con informe de jugador cargado
class PlayerReportLoaded extends ReportsState {
  final PlayerReportData data;
  final ReportFilter filter;
  final List<Map<String, dynamic>> availablePlayers;

  const PlayerReportLoaded({
    required this.data,
    required this.filter,
    this.availablePlayers = const [],
  });

  @override
  List<Object?> get props => [data, filter, availablePlayers];
}

/// Estado con informe de partido cargado
class MatchReportLoaded extends ReportsState {
  final MatchReportData data;
  final int teamId;

  const MatchReportLoaded({
    required this.data,
    required this.teamId,
  });

  @override
  List<Object?> get props => [data, teamId];
}

/// Estado con informe de convocatoria cargado
class ConvocatoriaReportLoaded extends ReportsState {
  final ConvocatoriaReportData data;
  final int teamId;

  const ConvocatoriaReportLoaded({
    required this.data,
    required this.teamId,
  });

  @override
  List<Object?> get props => [data, teamId];
}

/// Estado con informe de asistencia cargado
class AttendanceReportLoaded extends ReportsState {
  final AttendanceReportData data;
  final int teamId;

  const AttendanceReportLoaded({
    required this.data,
    required this.teamId,
  });

  @override
  List<Object?> get props => [data, teamId];
}

/// Estado con informe de estadísticas de equipo cargado
class TeamStatsReportLoaded extends ReportsState {
  final TeamStatsReportData data;
  final ReportFilter filter;

  const TeamStatsReportLoaded({
    required this.data,
    required this.filter,
  });

  @override
  List<Object?> get props => [data, filter];
}

/// Estado de error
class ReportsError extends ReportsState {
  final String message;
  final ReportsState? previousState;

  const ReportsError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Estado de exportación en progreso
class ReportExporting extends ReportsState {
  final double progress;
  final String format;

  const ReportExporting({
    required this.progress,
    required this.format,
  });

  @override
  List<Object?> get props => [progress, format];
}

/// Estado de exportación completada
class ReportExported extends ReportsState {
  final String filePath;
  final String format;
  final ReportsState previousReportState;

  const ReportExported({
    required this.filePath,
    required this.format,
    required this.previousReportState,
  });

  @override
  List<Object?> get props => [filePath, format, previousReportState];
}
