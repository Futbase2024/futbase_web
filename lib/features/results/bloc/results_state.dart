import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

const _unset = Object();

/// Estado de un partido calculado
enum MatchStatus { live, scheduled, finished }

/// Estados de partido para filtros
enum MatchStatusFilter { live, scheduled, finished }

/// Partidos agrupados por fecha
class ResultsGroupedByDate {
  final DateTime date;
  final List<MatchWithStatus> matches;

  const ResultsGroupedByDate({
    required this.date,
    required this.matches,
  });

  /// Etiqueta de fecha legible (Hoy, Ayer, fecha completa)
  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) return 'Hoy';
    if (dateOnly.isAtSameMomentAs(yesterday)) return 'Ayer';
    if (dateOnly.isAtSameMomentAs(tomorrow)) return 'Mañana';

    return DateFormat('EEEE, d MMMM', 'es').format(date);
  }

  /// Día de la semana abreviado (LUN, MAR, etc.)
  String get dayName {
    const days = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];
    return days[date.weekday - 1];
  }

  /// Número del día
  int get dayNumber => date.day;

  /// Es hoy?
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isAtSameMomentAs(today);
  }

  /// Cantidad de partidos en vivo en este grupo
  int get liveCount => matches.where((m) => m.status == MatchStatus.live).length;
}

/// Partido con su estado calculado
class MatchWithStatus {
  final Map<String, dynamic> match;
  final MatchStatus status;
  final String equipoNombre;
  final String rivalNombre;
  final bool isLocal;

  const MatchWithStatus({
    required this.match,
    required this.status,
    required this.equipoNombre,
    required this.rivalNombre,
    required this.isLocal,
  });

  /// ID del partido
  int? get id => match['id'] as int?;

  /// Goles del equipo
  int? get goles => _toInt(match['goles']);

  /// Goles del rival
  int? get golesrival => _toInt(match['golesrival']);

  /// Minuto actual (para partidos en vivo) - formato MM:SS
  int? get minuto {
    final minutoStr = match['minuto']?.toString();
    if (minutoStr == null || minutoStr.isEmpty) return null;
    // El formato es MM:SS, extraemos solo los minutos
    final parts = minutoStr.split(':');
    if (parts.isNotEmpty) {
      return int.tryParse(parts[0]);
    }
    return int.tryParse(minutoStr);
  }

  /// Fecha del partido
  DateTime? get fecha {
    final fechaStr = match['fecha']?.toString();
    if (fechaStr == null) return null;
    return DateTime.tryParse(fechaStr);
  }

  /// Hora del partido
  String? get hora => match['hora']?.toString();

  /// Nombre del campo
  String? get campo => match['campo']?.toString();

  /// Nombre de la jornada/competicion
  String? get jornada => match['jornada']?.toString();

  /// Categoría del partido
  String? get categoria => match['categoria']?.toString();

  /// URL del escudo del equipo
  String? get escudoEquipo => isLocal
      ? match['escudo']?.toString()
      : match['escudorival']?.toString();

  /// URL del escudo del rival
  String? get escudoRival => isLocal
      ? match['escudorival']?.toString()
      : match['escudo']?.toString();

  /// Resultado del partido (Victoria, Derrota, Empate, Pendiente)
  String get resultText {
    if (status == MatchStatus.scheduled) return 'PROGRAMADO';

    final g = goles;
    final gr = golesrival;

    if (g == null || gr == null) return 'PENDIENTE';

    if (g > gr) return 'VICTORIA';
    if (g < gr) return 'DERROTA';
    return 'EMPATE';
  }

  /// Helper para convertir a int de forma segura
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

/// Estados del BLoC de Resultados
abstract class ResultsState extends Equatable {
  const ResultsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ResultsInitial extends ResultsState {
  const ResultsInitial();
}

/// Estado de carga
class ResultsLoading extends ResultsState {
  final String message;

  const ResultsLoading({this.message = 'Cargando resultados...'});

  @override
  List<Object?> get props => [message];
}

/// Filtro de alcance (todos los partidos o solo mi club)
enum ResultsScope { all, myClub }

/// Estado con datos cargados
class ResultsLoaded extends ResultsState {
  /// Todos los partidos de la semana sin filtrar
  final List<Map<String, dynamic>> allMatches;

  /// Partidos agrupados por fecha (ya filtrados)
  final List<ResultsGroupedByDate> groupedMatches;

  /// Mapa de equipos (idEquipo -> nombre)
  final Map<int, String> equipos;

  /// Inicio de la semana actual (Lunes)
  final DateTime currentWeekStart;

  /// Temporada seleccionada
  final int idtemporada;

  /// ID del club del usuario actual (para filtro "Mi club")
  final int? idclub;

  /// Día seleccionado en el calendario (null = hoy por defecto)
  final DateTime? selectedDate;

  /// Filtro de alcance: todos o solo mi club
  final ResultsScope filterScope;

  /// Filtro por estado
  final MatchStatusFilter? filterByStatus;

  /// Modo live activado (actualizacion automatica)
  final bool isLiveMode;

  const ResultsLoaded({
    required this.allMatches,
    required this.groupedMatches,
    required this.equipos,
    required this.currentWeekStart,
    required this.idtemporada,
    this.idclub,
    this.selectedDate,
    this.filterScope = ResultsScope.all,
    this.filterByStatus,
    this.isLiveMode = false,
  });

  /// Total de partidos
  int get totalMatches => allMatches.length;

  /// Cantidad de partidos en vivo
  int get liveMatchesCount {
    return allMatches.where((m) => _getMatchStatus(m) == MatchStatus.live).length;
  }

  /// Cantidad de partidos finalizados
  int get finishedCount {
    return allMatches.where((m) => _getMatchStatus(m) == MatchStatus.finished).length;
  }

  /// Cantidad de partidos programados
  int get scheduledCount {
    return allMatches.where((m) => _getMatchStatus(m) == MatchStatus.scheduled).length;
  }

  /// Fin de la semana (Domingo)
  DateTime get currentWeekEnd => currentWeekStart.add(const Duration(days: 6));

  /// Etiqueta de la semana (ej: "17 - 23 Feb 2025")
  String get weekLabel {
    final start = currentWeekStart;
    final end = currentWeekEnd;
    final monthName = DateFormat('MMM', 'es').format(end);

    if (start.month == end.month) {
      return '${start.day} - ${end.day} ${monthName.toUpperCase()} ${start.year}';
    } else {
      final startMonth = DateFormat('MMM', 'es').format(start);
      return '${start.day} ${startMonth.toUpperCase()} - ${end.day} ${monthName.toUpperCase()} ${end.year}';
    }
  }

  /// Número de semana del año
  int get weekNumber {
    final firstDayOfYear = DateTime(currentWeekStart.year, 1, 1);
    final days = currentWeekStart.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Es la semana actual?
  bool get isCurrentWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _getWeekStart(today);
    return weekStart.isAtSameMomentAs(currentWeekStart);
  }

  /// Indica si hay filtros activos
  bool get hasActiveFilters => filterScope != ResultsScope.all || filterByStatus != null;

  /// Día seleccionado efectivo (si es null, usar hoy)
  DateTime get effectiveSelectedDate {
    if (selectedDate != null) return selectedDate!;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Partidos del día seleccionado
  List<MatchWithStatus> get selectedDayMatches {
    final selected = effectiveSelectedDate;
    for (final group in groupedMatches) {
      final groupDate = DateTime(group.date.year, group.date.month, group.date.day);
      if (groupDate.isAtSameMomentAs(selected)) {
        return group.matches;
      }
    }
    return [];
  }

  /// Obtener inicio de semana (Lunes) para una fecha
  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Calcular estado de un partido
  MatchStatus _getMatchStatus(Map<String, dynamic> match) {
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;
    if (finalizado) return MatchStatus.finished;

    // Si descanso == 1, está en vivo (descanso del partido)
    final descanso = match['descanso'] == 1 || match['descanso'] == true;
    if (descanso) return MatchStatus.live;

    // Si tiene minutos registrados (> 0), está en vivo
    final minutoStr = match['minuto']?.toString();
    if (minutoStr != null && minutoStr.isNotEmpty) {
      final parts = minutoStr.split(':');
      if (parts.isNotEmpty) {
        final minutos = int.tryParse(parts[0]) ?? 0;
        if (minutos > 0) return MatchStatus.live;
      }
    }

    return MatchStatus.scheduled;
  }

  @override
  List<Object?> get props => [
        allMatches,
        groupedMatches,
        equipos,
        currentWeekStart,
        idtemporada,
        idclub,
        selectedDate,
        filterScope,
        filterByStatus,
        isLiveMode,
      ];

  ResultsLoaded copyWith({
    List<Map<String, dynamic>>? allMatches,
    List<ResultsGroupedByDate>? groupedMatches,
    Map<int, String>? equipos,
    DateTime? currentWeekStart,
    int? idtemporada,
    int? idclub,
    Object? selectedDate = _unset,
    ResultsScope? filterScope,
    Object? filterByStatus = _unset,
    bool? isLiveMode,
  }) {
    return ResultsLoaded(
      allMatches: allMatches ?? this.allMatches,
      groupedMatches: groupedMatches ?? this.groupedMatches,
      equipos: equipos ?? this.equipos,
      currentWeekStart: currentWeekStart ?? this.currentWeekStart,
      idtemporada: idtemporada ?? this.idtemporada,
      idclub: idclub ?? this.idclub,
      selectedDate: selectedDate == _unset ? this.selectedDate : selectedDate as DateTime?,
      filterScope: filterScope ?? this.filterScope,
      filterByStatus: filterByStatus == _unset
          ? this.filterByStatus
          : filterByStatus as MatchStatusFilter?,
      isLiveMode: isLiveMode ?? this.isLiveMode,
    );
  }
}

/// Estado de error
class ResultsError extends ResultsState {
  final String message;

  const ResultsError({required this.message});

  @override
  List<Object?> get props => [message];
}
