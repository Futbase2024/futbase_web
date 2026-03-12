import 'package:equatable/equatable.dart';

import 'report_types.dart';

/// Filtros para los informes
class ReportFilter extends Equatable {
  final ReportType type;
  final ReportPeriod period;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? teamId;
  final int? categoryId;
  final int? playerId;
  final int? matchId;
  final int? clubId;
  final int activeSeasonId;

  const ReportFilter({
    required this.type,
    required this.activeSeasonId,
    this.period = ReportPeriod.month,
    this.fromDate,
    this.toDate,
    this.teamId,
    this.categoryId,
    this.playerId,
    this.matchId,
    this.clubId,
  });

  /// Copia el filtro con nuevos valores
  ReportFilter copyWith({
    ReportType? type,
    ReportPeriod? period,
    DateTime? fromDate,
    DateTime? toDate,
    int? teamId,
    int? categoryId,
    int? playerId,
    int? matchId,
    int? clubId,
    int? activeSeasonId,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearTeamId = false,
    bool clearCategoryId = false,
    bool clearPlayerId = false,
    bool clearMatchId = false,
  }) {
    return ReportFilter(
      type: type ?? this.type,
      period: period ?? this.period,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      teamId: clearTeamId ? null : (teamId ?? this.teamId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      playerId: clearPlayerId ? null : (playerId ?? this.playerId),
      matchId: clearMatchId ? null : (matchId ?? this.matchId),
      clubId: clubId ?? this.clubId,
      activeSeasonId: activeSeasonId ?? this.activeSeasonId,
    );
  }

  /// Obtiene el rango de fechas efectivo
  ({DateTime start, DateTime end}) getDateRange() {
    final now = DateTime.now();
    final end = toDate ?? now;
    final start = period == ReportPeriod.custom
        ? (fromDate ?? now.subtract(const Duration(days: 30)))
        : period.getStartDate(end, seasonStartYear: now.year);
    return (start: start, end: end);
  }

  @override
  List<Object?> get props => [
        type,
        period,
        fromDate,
        toDate,
        teamId,
        categoryId,
        playerId,
        matchId,
        clubId,
        activeSeasonId,
      ];
}
