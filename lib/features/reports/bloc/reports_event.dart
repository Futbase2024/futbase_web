import 'package:equatable/equatable.dart';

import '../domain/report_types.dart';
import '../domain/report_filter.dart';
import '../domain/saved_report_entity.dart';

/// Eventos del BLoC de informes
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializar el módulo de informes
class ReportsInitialized extends ReportsEvent {
  final int activeSeasonId;
  final int? clubId;
  final int? teamId;
  final String userRole;

  const ReportsInitialized({
    required this.activeSeasonId,
    this.clubId,
    this.teamId,
    required this.userRole,
  });

  @override
  List<Object?> get props => [activeSeasonId, clubId, teamId, userRole];
}

/// Cargar informes guardados
class LoadSavedReports extends ReportsEvent {
  final int? clubId;
  final int? teamId;
  final String userRole;
  final SavedReportType? filterType;

  const LoadSavedReports({
    this.clubId,
    this.teamId,
    required this.userRole,
    this.filterType,
  });

  @override
  List<Object?> get props => [clubId, teamId, userRole, filterType];
}

/// Filtrar informes guardados por tipo
class FilterSavedReports extends ReportsEvent {
  final SavedReportType? filterType;

  const FilterSavedReports({this.filterType});

  @override
  List<Object?> get props => [filterType];
}

/// Eliminar un informe guardado
class DeleteSavedReport extends ReportsEvent {
  final int reportId;

  const DeleteSavedReport({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Seleccionar tipo de informe
class ReportTypeSelected extends ReportsEvent {
  final ReportType type;

  const ReportTypeSelected({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Cambiar filtro
class ReportFilterChanged extends ReportsEvent {
  final ReportFilter filter;

  const ReportFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Cargar informe de jugador
class PlayerReportRequested extends ReportsEvent {
  final int playerId;
  final ReportFilter filter;

  const PlayerReportRequested({
    required this.playerId,
    required this.filter,
  });

  @override
  List<Object?> get props => [playerId, filter];
}

/// Cargar informe de partido
class MatchReportRequested extends ReportsEvent {
  final int matchId;
  final int teamId;

  const MatchReportRequested({
    required this.matchId,
    required this.teamId,
  });

  @override
  List<Object?> get props => [matchId, teamId];
}

/// Cargar informe de convocatoria
class ConvocatoriaReportRequested extends ReportsEvent {
  final int matchId;
  final int teamId;

  const ConvocatoriaReportRequested({
    required this.matchId,
    required this.teamId,
  });

  @override
  List<Object?> get props => [matchId, teamId];
}

/// Cargar informe de asistencia mensual
class AttendanceReportRequested extends ReportsEvent {
  final int teamId;
  final int year;
  final int month;

  const AttendanceReportRequested({
    required this.teamId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [teamId, year, month];
}

/// Cargar informe de estadísticas de equipo
class TeamStatsReportRequested extends ReportsEvent {
  final int teamId;
  final ReportFilter filter;

  const TeamStatsReportRequested({
    required this.teamId,
    required this.filter,
  });

  @override
  List<Object?> get props => [teamId, filter];
}

/// Cargar lista de jugadores para selector
class LoadPlayersForReport extends ReportsEvent {
  final int teamId;
  final int activeSeasonId;

  const LoadPlayersForReport({
    required this.teamId,
    required this.activeSeasonId,
  });

  @override
  List<Object?> get props => [teamId, activeSeasonId];
}

/// Cargar lista de partidos para selector
class LoadMatchesForReport extends ReportsEvent {
  final int teamId;
  final int activeSeasonId;

  const LoadMatchesForReport({
    required this.teamId,
    required this.activeSeasonId,
  });

  @override
  List<Object?> get props => [teamId, activeSeasonId];
}

/// Exportar a PDF
class ExportReportToPdf extends ReportsEvent {
  final dynamic reportData;
  final ReportType type;
  final String fileName;

  const ExportReportToPdf({
    required this.reportData,
    required this.type,
    required this.fileName,
  });

  @override
  List<Object?> get props => [reportData, type, fileName];
}

/// Exportar a Excel
class ExportReportToExcel extends ReportsEvent {
  final dynamic reportData;
  final ReportType type;
  final String fileName;

  const ExportReportToExcel({
    required this.reportData,
    required this.type,
    required this.fileName,
  });

  @override
  List<Object?> get props => [reportData, type, fileName];
}

/// Limpiar informe actual
class ClearReport extends ReportsEvent {
  const ClearReport();
}
