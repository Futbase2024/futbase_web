import 'package:equatable/equatable.dart';

const _unset = Object();

abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

/// Estado de carga
class MatchesLoading extends MatchesState {
  const MatchesLoading();
}

/// Estado con datos cargados desde la vista vpartido
/// Columnas principales: id, fecha, hora, rival, casafuera, goles, golesrival, finalizado,
/// jornada, categoria, equipo, campo, escudo, escudorival, observaciones, sistema, etc.
class MatchesLoaded extends MatchesState {
  final List<Map<String, dynamic>> matches;
  final List<Map<String, dynamic>> filteredMatches;
  final Map<int, String> competitions;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  final int? filterByCompetition;
  final bool? filterByVenue;

  const MatchesLoaded({
    required this.matches,
    required this.filteredMatches,
    required this.competitions,
    this.filterFromDate,
    this.filterToDate,
    this.filterByCompetition,
    this.filterByVenue,
  });

  /// Total de partidos
  int get totalMatches => matches.length;

  /// Partidos completados (finalizado=1)
  int get completedMatches {
    return matches.where((m) {
      final finalizado = m['finalizado'];
      return finalizado == 1 || finalizado == true;
    }).length;
  }

  /// Partidos próximos (no finalizados)
  int get upcomingMatches {
    return matches.where((m) {
      final finalizado = m['finalizado'];
      return finalizado != 1 && finalizado != true;
    }).length;
  }

  /// Partidos de hoy
  int get todayMatches {
    final now = DateTime.now();
    return matches.where((m) {
      final fecha = DateTime.tryParse(m['fecha']?.toString() ?? '');
      return fecha != null &&
          fecha.year == now.year &&
          fecha.month == now.month &&
          fecha.day == now.day;
    }).length;
  }

  /// Partidos esta semana
  int get thisWeekMatches {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return matches.where((m) {
      final fecha = DateTime.tryParse(m['fecha']?.toString() ?? '');
      if (fecha == null) return false;
      final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
      return !fechaSolo.isBefore(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)) &&
          !fechaSolo.isAfter(DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day));
    }).length;
  }

  /// Victorias (goles > golesrival) - solo partidos finalizados
  int get wins {
    return matches.where((m) {
      // Solo contar partidos finalizados
      final finalizado = m['finalizado'];
      if (finalizado != 1 && finalizado != true) return false;

      final goles = _toInt(m['goles']);
      final golesrival = _toInt(m['golesrival']);

      if (goles == null || golesrival == null) return false;

      return goles > golesrival;
    }).length;
  }

  /// Derrotas (goles < golesrival) - solo partidos finalizados
  int get losses {
    return matches.where((m) {
      // Solo contar partidos finalizados
      final finalizado = m['finalizado'];
      if (finalizado != 1 && finalizado != true) return false;

      final goles = _toInt(m['goles']);
      final golesrival = _toInt(m['golesrival']);

      if (goles == null || golesrival == null) return false;

      return goles < golesrival;
    }).length;
  }

  /// Empates (goles == golesrival) - solo partidos finalizados
  int get draws {
    return matches.where((m) {
      // Solo contar partidos finalizados
      final finalizado = m['finalizado'];
      if (finalizado != 1 && finalizado != true) return false;

      final goles = _toInt(m['goles']);
      final golesrival = _toInt(m['golesrival']);

      if (goles == null || golesrival == null) return false;

      return goles == golesrival;
    }).length;
  }

  /// Goles a favor
  int get goalsFor {
    int total = 0;
    for (final m in matches) {
      final goles = _toInt(m['goles']);
      if (goles != null) {
        total += goles;
      }
    }
    return total;
  }

  /// Goles en contra
  int get goalsAgainst {
    int total = 0;
    for (final m in matches) {
      final golesrival = _toInt(m['golesrival']);
      if (golesrival != null) {
        total += golesrival;
      }
    }
    return total;
  }

  /// Helper para convertir a int de forma segura
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  bool get hasActiveFilters =>
      filterFromDate != null ||
      filterToDate != null ||
      filterByCompetition != null ||
      filterByVenue != null;

  @override
  List<Object?> get props => [
        matches,
        filteredMatches,
        competitions,
        filterFromDate,
        filterToDate,
        filterByCompetition,
        filterByVenue,
      ];

  MatchesLoaded copyWith({
    List<Map<String, dynamic>>? matches,
    List<Map<String, dynamic>>? filteredMatches,
    Map<int, String>? competitions,
    Object? filterFromDate = _unset,
    Object? filterToDate = _unset,
    Object? filterByCompetition = _unset,
    Object? filterByVenue = _unset,
  }) {
    return MatchesLoaded(
      matches: matches ?? this.matches,
      filteredMatches: filteredMatches ?? this.filteredMatches,
      competitions: competitions ?? this.competitions,
      filterFromDate: filterFromDate == _unset ? this.filterFromDate : filterFromDate as DateTime?,
      filterToDate: filterToDate == _unset ? this.filterToDate : filterToDate as DateTime?,
      filterByCompetition:
          filterByCompetition == _unset ? this.filterByCompetition : filterByCompetition as int?,
      filterByVenue: filterByVenue == _unset ? this.filterByVenue : filterByVenue as bool?,
    );
  }
}

/// Estado de error
class MatchesError extends MatchesState {
  final String message;

  const MatchesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado para usuarios sin equipo asignado (club/coordinador)
class MatchesNoTeam extends MatchesState {
  final String? message;

  const MatchesNoTeam({this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado para gestión de alineación
class LineupState extends MatchesState {
  final int idpartido;
  final List<Map<String, dynamic>> players;
  final Map<int, bool> lineup;
  final Map<int, int?> minutosEntrada;
  final Map<int, int?> minutosSalida;
  // Posiciones en el campo (0.0 - 1.0)
  final Map<int, double?> posX;
  final Map<int, double?> posY;
  final Map<int, double?> posXCambio;
  final Map<int, double?> posYCambio;
  final bool isSaving;
  // Camisetas desde la BD
  final String? camisetaUrl;        // URL de la camiseta para jugadores de campo
  final String? camisetaPorteroUrl; // URL de la camiseta del portero
  final int dorsalColor;            // 0=blanco, 1=negro, 2=naranja, 3=rosa

  const LineupState({
    required this.idpartido,
    required this.players,
    required this.lineup,
    required this.minutosEntrada,
    required this.minutosSalida,
    this.posX = const {},
    this.posY = const {},
    this.posXCambio = const {},
    this.posYCambio = const {},
    this.isSaving = false,
    this.camisetaUrl,
    this.camisetaPorteroUrl,
    this.dorsalColor = 0,
  });

  int get startersCount => lineup.values.where((v) => v).length;
  int get substitutesCount => lineup.values.where((v) => !v).length;

  /// Obtener posición de un jugador
  double? getPosX(int idjugador) => posX[idjugador];
  double? getPosY(int idjugador) => posY[idjugador];

  /// Jugadores titulares con su posición
  List<Map<String, dynamic>> get startersWithPosition {
    return players.where((p) => lineup[p['id']] == true).map((p) {
      final id = p['id'] as int;
      return {
        ...p,
        'posX': posX[id],
        'posY': posY[id],
      };
    }).toList();
  }

  /// Obtener URL de camiseta según si es portero o no
  String? getCamisetaUrl(bool isPortero) => isPortero ? camisetaPorteroUrl : camisetaUrl;

  @override
  List<Object?> get props => [
        idpartido,
        players,
        lineup,
        minutosEntrada,
        minutosSalida,
        posX,
        posY,
        posXCambio,
        posYCambio,
        isSaving,
        camisetaUrl,
        camisetaPorteroUrl,
        dorsalColor,
      ];

  LineupState copyWith({
    int? idpartido,
    List<Map<String, dynamic>>? players,
    Map<int, bool>? lineup,
    Map<int, int?>? minutosEntrada,
    Map<int, int?>? minutosSalida,
    Map<int, double?>? posX,
    Map<int, double?>? posY,
    Map<int, double?>? posXCambio,
    Map<int, double?>? posYCambio,
    bool? isSaving,
    String? camisetaUrl,
    String? camisetaPorteroUrl,
    int? dorsalColor,
  }) {
    return LineupState(
      idpartido: idpartido ?? this.idpartido,
      players: players ?? this.players,
      lineup: lineup ?? this.lineup,
      minutosEntrada: minutosEntrada ?? this.minutosEntrada,
      minutosSalida: minutosSalida ?? this.minutosSalida,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posXCambio: posXCambio ?? this.posXCambio,
      posYCambio: posYCambio ?? this.posYCambio,
      isSaving: isSaving ?? this.isSaving,
      camisetaUrl: camisetaUrl ?? this.camisetaUrl,
      camisetaPorteroUrl: camisetaPorteroUrl ?? this.camisetaPorteroUrl,
      dorsalColor: dorsalColor ?? this.dorsalColor,
    );
  }
}

/// Estado para gestión de convocatoria (jugadores de todo el club)
class ConvocatoriaState extends MatchesState {
  final int idpartido;
  final int idclub;
  final int idTemporada;
  final List<Map<String, dynamic>> clubPlayers; // Todos los jugadores del club
  final Set<int> convocados; // IDs de jugadores convocados
  final Map<int, String> equipos; // Mapa de idEquipo -> nombreEquipo
  final bool isSaving;

  const ConvocatoriaState({
    required this.idpartido,
    required this.idclub,
    required this.idTemporada,
    required this.clubPlayers,
    required this.convocados,
    required this.equipos,
    this.isSaving = false,
  });

  int get totalConvocados => convocados.length;
  int get totalJugadores => clubPlayers.length;

  /// Jugadores agrupados por equipo
  Map<int, List<Map<String, dynamic>>> get playersByTeam {
    final map = <int, List<Map<String, dynamic>>>{};
    for (final player in clubPlayers) {
      final idequipo = player['idequipo'] as int? ?? 0;
      map.putIfAbsent(idequipo, () => []).add(player);
    }
    return map;
  }

  @override
  List<Object?> get props => [
        idpartido,
        idclub,
        idTemporada,
        clubPlayers,
        convocados,
        equipos,
        isSaving,
      ];

  ConvocatoriaState copyWith({
    int? idpartido,
    int? idclub,
    int? idTemporada,
    List<Map<String, dynamic>>? clubPlayers,
    Set<int>? convocados,
    Map<int, String>? equipos,
    bool? isSaving,
  }) {
    return ConvocatoriaState(
      idpartido: idpartido ?? this.idpartido,
      idclub: idclub ?? this.idclub,
      idTemporada: idTemporada ?? this.idTemporada,
      clubPlayers: clubPlayers ?? this.clubPlayers,
      convocados: convocados ?? this.convocados,
      equipos: equipos ?? this.equipos,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
