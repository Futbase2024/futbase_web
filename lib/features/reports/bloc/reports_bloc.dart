import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/report_types.dart';
import '../domain/report_filter.dart';
import '../domain/saved_report_entity.dart';
import '../services/reports_datasource.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// BLoC para gestión de informes
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsDatasource _datasource;

  ReportsBloc({ReportsDatasource? datasource})
      : _datasource = datasource ?? ReportsDatasource(),
        super(const ReportsInitial()) {
    on<ReportsInitialized>(_onInitialized);
    on<LoadSavedReports>(_onLoadSavedReports);
    on<FilterSavedReports>(_onFilterSavedReports);
    on<DeleteSavedReport>(_onDeleteSavedReport);
    on<ReportTypeSelected>(_onReportTypeSelected);
    on<ReportFilterChanged>(_onFilterChanged);
    on<PlayerReportRequested>(_onPlayerReportRequested);
    on<MatchReportRequested>(_onMatchReportRequested);
    on<ConvocatoriaReportRequested>(_onConvocatoriaReportRequested);
    on<AttendanceReportRequested>(_onAttendanceReportRequested);
    on<TeamStatsReportRequested>(_onTeamStatsReportRequested);
    on<LoadPlayersForReport>(_onLoadPlayersForReport);
    on<LoadMatchesForReport>(_onLoadMatchesForReport);
    on<ClearReport>(_onClearReport);
    on<ExportReportToPdf>(_onExportToPdf);
    on<ExportReportToExcel>(_onExportToExcel);
  }

  /// Inicializar el módulo de informes - cargar informes guardados
  Future<void> _onInitialized(
    ReportsInitialized event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      // Cargar TODOS los informes guardados según el rol
      // El filtro visual por defecto es Partidos, pero se cargan todos
      final reports = await _datasource.getSavedReports(
        clubId: event.clubId,
        teamId: event.teamId,
        userRole: event.userRole,
      );

      emit(SavedReportsLoaded(
        reports: reports,
        filterType: SavedReportType.partidos, // Filtro visual por defecto
        userRole: event.userRole,
        clubId: event.clubId,
        teamId: event.teamId,
      ));
    } catch (e) {
      debugPrint('Error inicializando informes: $e');
      emit(ReportsError(message: 'Error al cargar informes: $e'));
    }
  }

  /// Cargar informes guardados
  Future<void> _onLoadSavedReports(
    LoadSavedReports event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      final reports = await _datasource.getSavedReports(
        clubId: event.clubId,
        teamId: event.teamId,
        userRole: event.userRole,
        tipoFilter: event.filterType?.id,
      );

      emit(SavedReportsLoaded(
        reports: reports,
        filterType: event.filterType,
        userRole: event.userRole,
        clubId: event.clubId,
        teamId: event.teamId,
      ));
    } catch (e) {
      debugPrint('Error cargando informes guardados: $e');
      emit(ReportsError(message: 'Error al cargar informes: $e'));
    }
  }

  /// Filtrar informes por tipo
  void _onFilterSavedReports(
    FilterSavedReports event,
    Emitter<ReportsState> emit,
  ) {
    final currentState = state;
    if (currentState is SavedReportsLoaded) {
      emit(currentState.copyWith(filterType: event.filterType));
    }
  }

  /// Eliminar un informe guardado
  Future<void> _onDeleteSavedReport(
    DeleteSavedReport event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SavedReportsLoaded) return;

    try {
      final success = await _datasource.deleteSavedReport(event.reportId);

      if (success) {
        final updatedReports = currentState.reports
            .where((r) => r.id != event.reportId)
            .toList();

        emit(currentState.copyWith(reports: updatedReports));
      }
    } catch (e) {
      debugPrint('Error eliminando informe: $e');
      emit(ReportsError(
        message: 'Error al eliminar informe: $e',
        previousState: currentState,
      ));
    }
  }

  /// Seleccionar tipo de informe
  void _onReportTypeSelected(
    ReportTypeSelected event,
    Emitter<ReportsState> emit,
  ) {
    final currentState = state;
    ReportFilter currentFilter;
    List<Map<String, dynamic>> teams = [];
    String userRole = 'entrenador';

    if (currentState is ReportTypeReady) {
      currentFilter = currentState.filter;
      teams = currentState.availableTeams;
      userRole = currentState.userRole;
    } else if (currentState is PlayerReportLoaded) {
      currentFilter = currentState.filter;
      userRole = 'entrenador';
    } else {
      currentFilter = ReportFilter(
        type: event.type,
        activeSeasonId: 1,
      );
    }

    final newFilter = currentFilter.copyWith(type: event.type);

    emit(ReportTypeReady(
      selectedType: event.type,
      filter: newFilter,
      availableTeams: teams,
      userRole: userRole,
    ));
  }

  /// Cambiar filtro
  Future<void> _onFilterChanged(
    ReportFilterChanged event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    List<Map<String, dynamic>> teams = [];
    List<Map<String, dynamic>> players = [];
    List<Map<String, dynamic>> matches = [];
    String userRole = 'entrenador';

    if (currentState is ReportTypeReady) {
      teams = currentState.availableTeams;
      players = currentState.availablePlayers;
      matches = currentState.availableMatches;
      userRole = currentState.userRole;
    }

    // Cargar jugadores si cambia el equipo y es informe de jugador
    if (event.filter.teamId != null && event.filter.type == ReportType.player) {
      players = await _datasource.getPlayersForSelector(
        teamId: event.filter.teamId!,
        activeSeasonId: event.filter.activeSeasonId,
      );
    }

    // Cargar partidos si cambia el equipo y es informe de partido/convocatoria
    if (event.filter.teamId != null &&
        (event.filter.type == ReportType.match ||
            event.filter.type == ReportType.convocatoria)) {
      matches = await _datasource.getMatchesForSelector(
        teamId: event.filter.teamId!,
        activeSeasonId: event.filter.activeSeasonId,
      );
    }

    emit(ReportTypeReady(
      selectedType: event.filter.type,
      filter: event.filter,
      availableTeams: teams,
      availablePlayers: players,
      availableMatches: matches,
      userRole: userRole,
    ));
  }

  /// Cargar informe de jugador
  Future<void> _onPlayerReportRequested(
    PlayerReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      final dateRange = event.filter.getDateRange();

      final data = await _datasource.getPlayerReport(
        playerId: event.playerId,
        activeSeasonId: event.filter.activeSeasonId,
        fromDate: dateRange.start,
        toDate: dateRange.end,
      );

      // Cargar jugadores para el selector
      final players = event.filter.teamId != null
          ? await _datasource.getPlayersForSelector(
              teamId: event.filter.teamId!,
              activeSeasonId: event.filter.activeSeasonId,
            )
          : <Map<String, dynamic>>[];

      emit(PlayerReportLoaded(
        data: data,
        filter: event.filter,
        availablePlayers: players,
      ));
    } catch (e) {
      debugPrint('Error cargando informe de jugador: $e');
      emit(ReportsError(message: 'Error al cargar informe: $e'));
    }
  }

  /// Cargar informe de partido
  Future<void> _onMatchReportRequested(
    MatchReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      final data = await _datasource.getMatchReport(
        matchId: event.matchId,
        teamId: event.teamId,
      );

      emit(MatchReportLoaded(
        data: data,
        teamId: event.teamId,
      ));
    } catch (e) {
      debugPrint('Error cargando informe de partido: $e');
      emit(ReportsError(message: 'Error al cargar informe: $e'));
    }
  }

  /// Cargar informe de convocatoria
  Future<void> _onConvocatoriaReportRequested(
    ConvocatoriaReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      final data = await _datasource.getConvocatoriaReport(
        matchId: event.matchId,
        teamId: event.teamId,
      );

      emit(ConvocatoriaReportLoaded(
        data: data,
        teamId: event.teamId,
      ));
    } catch (e) {
      debugPrint('Error cargando informe de convocatoria: $e');
      emit(ReportsError(message: 'Error al cargar informe: $e'));
    }
  }

  /// Cargar informe de asistencia
  Future<void> _onAttendanceReportRequested(
    AttendanceReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      final data = await _datasource.getAttendanceReport(
        teamId: event.teamId,
        year: event.year,
        month: event.month,
      );

      emit(AttendanceReportLoaded(
        data: data,
        teamId: event.teamId,
      ));
    } catch (e) {
      debugPrint('Error cargando informe de asistencia: $e');
      emit(ReportsError(message: 'Error al cargar informe: $e'));
    }
  }

  /// Cargar informe de estadísticas de equipo
  Future<void> _onTeamStatsReportRequested(
    TeamStatsReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    try {
      final dateRange = event.filter.getDateRange();

      final data = await _datasource.getTeamStatsReport(
        teamId: event.teamId,
        activeSeasonId: event.filter.activeSeasonId,
        fromDate: dateRange.start,
        toDate: dateRange.end,
      );

      emit(TeamStatsReportLoaded(
        data: data,
        filter: event.filter,
      ));
    } catch (e) {
      debugPrint('Error cargando estadísticas de equipo: $e');
      emit(ReportsError(message: 'Error al cargar informe: $e'));
    }
  }

  /// Cargar jugadores para selector
  Future<void> _onLoadPlayersForReport(
    LoadPlayersForReport event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportTypeReady) return;

    try {
      final players = await _datasource.getPlayersForSelector(
        teamId: event.teamId,
        activeSeasonId: event.activeSeasonId,
      );

      emit(currentState.copyWith(availablePlayers: players));
    } catch (e) {
      debugPrint('Error cargando jugadores: $e');
    }
  }

  /// Cargar partidos para selector
  Future<void> _onLoadMatchesForReport(
    LoadMatchesForReport event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportTypeReady) return;

    try {
      final matches = await _datasource.getMatchesForSelector(
        teamId: event.teamId,
        activeSeasonId: event.activeSeasonId,
      );

      emit(currentState.copyWith(availableMatches: matches));
    } catch (e) {
      debugPrint('Error cargando partidos: $e');
    }
  }

  /// Limpiar informe actual
  void _onClearReport(
    ClearReport event,
    Emitter<ReportsState> emit,
  ) {
    final currentState = state;

    if (currentState is PlayerReportLoaded ||
        currentState is MatchReportLoaded ||
        currentState is ConvocatoriaReportLoaded ||
        currentState is AttendanceReportLoaded ||
        currentState is TeamStatsReportLoaded) {
      // Volver al estado de selección
      ReportFilter? filter;
      String userRole = 'entrenador';
      List<Map<String, dynamic>> teams = [];

      if (currentState is PlayerReportLoaded) {
        filter = currentState.filter;
      }

      if (filter != null) {
        emit(ReportTypeReady(
          selectedType: filter.type,
          filter: filter,
          availableTeams: teams,
          userRole: userRole,
        ));
      } else {
        emit(const ReportsInitial());
      }
    }
  }

  /// Exportar a PDF (placeholder - se implementa en servicio de exportación)
  Future<void> _onExportToPdf(
    ExportReportToPdf event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportExporting(progress: 0.0, format: 'pdf'));

    try {
      // TODO: Implementar exportación PDF real
      // Por ahora simulamos el proceso
      await Future.delayed(const Duration(seconds: 1));

      emit(ReportExporting(progress: 0.5, format: 'pdf'));
      await Future.delayed(const Duration(seconds: 1));

      emit(ReportExported(
        filePath: '/downloads/${event.fileName}.pdf',
        format: 'pdf',
        previousReportState: state,
      ));
    } catch (e) {
      debugPrint('Error exportando a PDF: $e');
      emit(ReportsError(message: 'Error al exportar: $e'));
    }
  }

  /// Exportar a Excel (placeholder - se implementa en servicio de exportación)
  Future<void> _onExportToExcel(
    ExportReportToExcel event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportExporting(progress: 0.0, format: 'excel'));

    try {
      // TODO: Implementar exportación Excel real
      // Por ahora simulamos el proceso
      await Future.delayed(const Duration(seconds: 1));

      emit(ReportExporting(progress: 0.5, format: 'excel'));
      await Future.delayed(const Duration(seconds: 1));

      emit(ReportExported(
        filePath: '/downloads/${event.fileName}.xlsx',
        format: 'excel',
        previousReportState: state,
      ));
    } catch (e) {
      debugPrint('Error exportando a Excel: $e');
      emit(ReportsError(message: 'Error al exportar: $e'));
    }
  }
}
