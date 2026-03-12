import 'package:equatable/equatable.dart';

/// Datos del informe de jugador
class PlayerReportData extends Equatable {
  final int playerId;
  final String playerName;
  final String playerLastName;
  final int? dorsal;
  final String? position;
  final String? teamName;
  final int totalMatches;
  final int totalMinutes;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double attendancePercentage;
  final int totalTrainings;
  final int attendedTrainings;
  final List<MatchEventSummary> recentEvents;

  const PlayerReportData({
    required this.playerId,
    required this.playerName,
    required this.playerLastName,
    this.dorsal,
    this.position,
    this.teamName,
    this.totalMatches = 0,
    this.totalMinutes = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.attendancePercentage = 0.0,
    this.totalTrainings = 0,
    this.attendedTrainings = 0,
    this.recentEvents = const [],
  });

  String get fullName => '$playerName $playerLastName';

  double get averageMinutesPerMatch =>
      totalMatches > 0 ? totalMinutes / totalMatches : 0;

  factory PlayerReportData.fromJson(Map<String, dynamic> json) {
    return PlayerReportData(
      playerId: json['player_id'] as int,
      playerName: json['player_name'] as String,
      playerLastName: json['player_last_name'] as String,
      dorsal: json['dorsal'] as int?,
      position: json['position'] as String?,
      teamName: json['team_name'] as String?,
      totalMatches: json['total_matches'] as int? ?? 0,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
      yellowCards: json['yellow_cards'] as int? ?? 0,
      redCards: json['red_cards'] as int? ?? 0,
      attendancePercentage: (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      totalTrainings: json['total_trainings'] as int? ?? 0,
      attendedTrainings: json['attended_trainings'] as int? ?? 0,
      recentEvents: (json['recent_events'] as List<dynamic>?)
              ?.map((e) => MatchEventSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        playerLastName,
        dorsal,
        position,
        teamName,
        totalMatches,
        totalMinutes,
        goals,
        assists,
        yellowCards,
        redCards,
        attendancePercentage,
        totalTrainings,
        attendedTrainings,
        recentEvents,
      ];
}

/// Resumen de evento de partido
class MatchEventSummary extends Equatable {
  final int matchId;
  final String rival;
  final DateTime matchDate;
  final String eventType;
  final int? minute;

  const MatchEventSummary({
    required this.matchId,
    required this.rival,
    required this.matchDate,
    required this.eventType,
    this.minute,
  });

  factory MatchEventSummary.fromJson(Map<String, dynamic> json) {
    return MatchEventSummary(
      matchId: json['match_id'] as int,
      rival: json['rival'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      eventType: json['event_type'] as String,
      minute: json['minute'] as int?,
    );
  }

  @override
  List<Object?> get props => [matchId, rival, matchDate, eventType, minute];
}

/// Datos del informe de partido
class MatchReportData extends Equatable {
  final int matchId;
  final String rival;
  final DateTime matchDate;
  final bool isHome;
  final int? homeScore;
  final int? awayScore;
  final String? competition;
  final int? matchday;
  final List<ConvocadoPlayer> convocatoria;
  final List<MatchEventDetail> events;
  final MatchStatisticsData? statistics;

  const MatchReportData({
    required this.matchId,
    required this.rival,
    required this.matchDate,
    required this.isHome,
    this.homeScore,
    this.awayScore,
    this.competition,
    this.matchday,
    this.convocatoria = const [],
    this.events = const [],
    this.statistics,
  });

  bool get isWin =>
      isHome ? (homeScore ?? 0) > (awayScore ?? 0) : (awayScore ?? 0) > (homeScore ?? 0);
  bool get isLoss =>
      isHome ? (homeScore ?? 0) < (awayScore ?? 0) : (awayScore ?? 0) < (homeScore ?? 0);
  bool get isDraw => homeScore == awayScore;
  int get teamScore => isHome ? (homeScore ?? 0) : (awayScore ?? 0);
  int get rivalScore => isHome ? (awayScore ?? 0) : (homeScore ?? 0);

  factory MatchReportData.fromJson(Map<String, dynamic> json) {
    return MatchReportData(
      matchId: json['match_id'] as int,
      rival: json['rival'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      isHome: json['is_home'] as bool? ?? true,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
      competition: json['competition'] as String?,
      matchday: json['matchday'] as int?,
      convocatoria: (json['convocatoria'] as List<dynamic>?)
              ?.map((e) => ConvocadoPlayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => MatchEventDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statistics: json['statistics'] != null
          ? MatchStatisticsData.fromJson(json['statistics'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        matchId,
        rival,
        matchDate,
        isHome,
        homeScore,
        awayScore,
        competition,
        matchday,
        convocatoria,
        events,
        statistics,
      ];
}

/// Jugador convocado
class ConvocadoPlayer extends Equatable {
  final int playerId;
  final String playerName;
  final String playerLastName;
  final int? dorsal;
  final String? position;
  final bool isStarter;
  final bool isConvoked;
  final int? posx;
  final int? posy;

  const ConvocadoPlayer({
    required this.playerId,
    required this.playerName,
    required this.playerLastName,
    this.dorsal,
    this.position,
    this.isStarter = false,
    this.isConvoked = true,
    this.posx,
    this.posy,
  });

  String get fullName => '$playerName $playerLastName';

  factory ConvocadoPlayer.fromJson(Map<String, dynamic> json) {
    return ConvocadoPlayer(
      playerId: json['player_id'] as int,
      playerName: json['player_name'] as String,
      playerLastName: json['player_last_name'] as String,
      dorsal: json['dorsal'] as int?,
      position: json['position'] as String?,
      isStarter: json['is_starter'] as bool? ?? false,
      isConvoked: json['is_convoked'] as bool? ?? true,
      posx: json['posx'] as int?,
      posy: json['posy'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        playerLastName,
        dorsal,
        position,
        isStarter,
        isConvoked,
        posx,
        posy,
      ];
}

/// Detalle de evento de partido
class MatchEventDetail extends Equatable {
  final int id;
  final int playerId;
  final String playerName;
  final String eventType;
  final int? minute;
  final String? detail;

  const MatchEventDetail({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.eventType,
    this.minute,
    this.detail,
  });

  factory MatchEventDetail.fromJson(Map<String, dynamic> json) {
    return MatchEventDetail(
      id: json['id'] as int,
      playerId: json['player_id'] as int,
      playerName: json['player_name'] as String,
      eventType: json['event_type'] as String,
      minute: json['minute'] as int?,
      detail: json['detail'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, playerId, playerName, eventType, minute, detail];
}

/// Estadísticas de partido
class MatchStatisticsData extends Equatable {
  final double? possession;
  final int? shots;
  final int? shotsOnTarget;
  final int? corners;
  final int? fouls;
  final int? offsides;

  const MatchStatisticsData({
    this.possession,
    this.shots,
    this.shotsOnTarget,
    this.corners,
    this.fouls,
    this.offsides,
  });

  factory MatchStatisticsData.fromJson(Map<String, dynamic> json) {
    return MatchStatisticsData(
      possession: (json['possession'] as num?)?.toDouble(),
      shots: json['shots'] as int?,
      shotsOnTarget: json['shots_on_target'] as int?,
      corners: json['corners'] as int?,
      fouls: json['fouls'] as int?,
      offsides: json['offsides'] as int?,
    );
  }

  @override
  List<Object?> get props => [possession, shots, shotsOnTarget, corners, fouls, offsides];
}

/// Datos del informe de asistencia mensual
class AttendanceReportData extends Equatable {
  final int teamId;
  final String teamName;
  final int year;
  final int month;
  final int totalTrainings;
  final List<PlayerAttendanceData> playersAttendance;

  const AttendanceReportData({
    required this.teamId,
    required this.teamName,
    required this.year,
    required this.month,
    this.totalTrainings = 0,
    this.playersAttendance = const [],
  });

  String get monthName {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  double get averageAttendance {
    if (playersAttendance.isEmpty) return 0;
    return playersAttendance
            .map((p) => p.attendancePercentage)
            .reduce((a, b) => a + b) /
        playersAttendance.length;
  }

  factory AttendanceReportData.fromJson(Map<String, dynamic> json) {
    return AttendanceReportData(
      teamId: json['team_id'] as int,
      teamName: json['team_name'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      totalTrainings: json['total_trainings'] as int? ?? 0,
      playersAttendance: (json['players_attendance'] as List<dynamic>?)
              ?.map((e) => PlayerAttendanceData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        teamId,
        teamName,
        year,
        month,
        totalTrainings,
        playersAttendance,
      ];
}

/// Datos de asistencia de un jugador
class PlayerAttendanceData extends Equatable {
  final int playerId;
  final String playerName;
  final String playerLastName;
  final int? dorsal;
  final int totalTrainings;
  final int attended;
  final int absences;
  final double attendancePercentage;
  final List<AttendanceDetail> details;

  const PlayerAttendanceData({
    required this.playerId,
    required this.playerName,
    required this.playerLastName,
    this.dorsal,
    this.totalTrainings = 0,
    this.attended = 0,
    this.absences = 0,
    this.attendancePercentage = 0.0,
    this.details = const [],
  });

  String get fullName => '$playerName $playerLastName';

  factory PlayerAttendanceData.fromJson(Map<String, dynamic> json) {
    return PlayerAttendanceData(
      playerId: json['player_id'] as int,
      playerName: json['player_name'] as String,
      playerLastName: json['player_last_name'] as String,
      dorsal: json['dorsal'] as int?,
      totalTrainings: json['total_trainings'] as int? ?? 0,
      attended: json['attended'] as int? ?? 0,
      absences: json['absences'] as int? ?? 0,
      attendancePercentage: (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => AttendanceDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        playerLastName,
        dorsal,
        totalTrainings,
        attended,
        absences,
        attendancePercentage,
        details,
      ];
}

/// Detalle de asistencia por entrenamiento
class AttendanceDetail extends Equatable {
  final int trainingId;
  final DateTime date;
  final bool attended;
  final String? absenceReason;

  const AttendanceDetail({
    required this.trainingId,
    required this.date,
    required this.attended,
    this.absenceReason,
  });

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      trainingId: json['training_id'] as int,
      date: DateTime.parse(json['date'] as String),
      attended: json['attended'] as bool? ?? false,
      absenceReason: json['absence_reason'] as String?,
    );
  }

  @override
  List<Object?> get props => [trainingId, date, attended, absenceReason];
}

/// Datos del informe de convocatoria
class ConvocatoriaReportData extends Equatable {
  final int matchId;
  final String rival;
  final DateTime matchDate;
  final bool isHome;
  final String? teamName;
  final List<ConvocadoPlayer> starters;
  final List<ConvocadoPlayer> substitutes;
  final List<ConvocadoPlayer> notConvoked;

  const ConvocatoriaReportData({
    required this.matchId,
    required this.rival,
    required this.matchDate,
    required this.isHome,
    this.teamName,
    this.starters = const [],
    this.substitutes = const [],
    this.notConvoked = const [],
  });

  int get totalConvoked => starters.length + substitutes.length;

  factory ConvocatoriaReportData.fromJson(Map<String, dynamic> json) {
    return ConvocatoriaReportData(
      matchId: json['match_id'] as int,
      rival: json['rival'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      isHome: json['is_home'] as bool? ?? true,
      teamName: json['team_name'] as String?,
      starters: (json['starters'] as List<dynamic>?)
              ?.map((e) => ConvocadoPlayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      substitutes: (json['substitutes'] as List<dynamic>?)
              ?.map((e) => ConvocadoPlayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notConvoked: (json['not_convoked'] as List<dynamic>?)
              ?.map((e) => ConvocadoPlayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        matchId,
        rival,
        matchDate,
        isHome,
        teamName,
        starters,
        substitutes,
        notConvoked,
      ];
}

/// Datos del informe de estadísticas de equipo
class TeamStatsReportData extends Equatable {
  final int teamId;
  final String teamName;
  final int totalMatches;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int totalTrainings;
  final double averageAttendance;
  final List<MatchResultSummary> recentMatches;

  const TeamStatsReportData({
    required this.teamId,
    required this.teamName,
    this.totalMatches = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.totalTrainings = 0,
    this.averageAttendance = 0.0,
    this.recentMatches = const [],
  });

  int get goalDifference => goalsFor - goalsAgainst;
  double get winPercentage =>
      totalMatches > 0 ? (wins / totalMatches) * 100 : 0;
  double get pointsPerMatch =>
      totalMatches > 0 ? ((wins * 3) + draws) / totalMatches : 0;

  factory TeamStatsReportData.fromJson(Map<String, dynamic> json) {
    return TeamStatsReportData(
      teamId: json['team_id'] as int,
      teamName: json['team_name'] as String,
      totalMatches: json['total_matches'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      goalsFor: json['goals_for'] as int? ?? 0,
      goalsAgainst: json['goals_againced'] as int? ?? 0,
      totalTrainings: json['total_trainings'] as int? ?? 0,
      averageAttendance: (json['average_attendance'] as num?)?.toDouble() ?? 0.0,
      recentMatches: (json['recent_matches'] as List<dynamic>?)
              ?.map((e) => MatchResultSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        teamId,
        teamName,
        totalMatches,
        wins,
        draws,
        losses,
        goalsFor,
        goalsAgainst,
        totalTrainings,
        averageAttendance,
        recentMatches,
      ];
}

/// Resumen de resultado de partido
class MatchResultSummary extends Equatable {
  final int matchId;
  final String rival;
  final DateTime matchDate;
  final bool isHome;
  final int? homeScore;
  final int? awayScore;

  const MatchResultSummary({
    required this.matchId,
    required this.rival,
    required this.matchDate,
    required this.isHome,
    this.homeScore,
    this.awayScore,
  });

  bool get isWin =>
      isHome ? (homeScore ?? 0) > (awayScore ?? 0) : (awayScore ?? 0) > (homeScore ?? 0);
  bool get isLoss =>
      isHome ? (homeScore ?? 0) < (awayScore ?? 0) : (awayScore ?? 0) < (homeScore ?? 0);
  bool get isDraw => homeScore == awayScore;

  factory MatchResultSummary.fromJson(Map<String, dynamic> json) {
    return MatchResultSummary(
      matchId: json['match_id'] as int,
      rival: json['rival'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      isHome: json['is_home'] as bool? ?? true,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
    );
  }

  @override
  List<Object?> get props => [matchId, rival, matchDate, isHome, homeScore, awayScore];
}
