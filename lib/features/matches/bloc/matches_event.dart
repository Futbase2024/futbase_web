import 'package:equatable/equatable.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar partidos de un equipo
class MatchesLoadRequested extends MatchesEvent {
  final int idequipo;
  final int idTemporada;

  const MatchesLoadRequested({
    required this.idequipo,
    required this.idTemporada,
  });

  @override
  List<Object?> get props => [idequipo, idTemporada];
}

/// Refrescar lista de partidos
class MatchesRefreshRequested extends MatchesEvent {
  final int idequipo;
  final int idTemporada;

  const MatchesRefreshRequested({
    required this.idequipo,
    required this.idTemporada,
  });

  @override
  List<Object?> get props => [idequipo, idTemporada];
}

/// Filtrar partidos por rango de fechas
class MatchesFilterByDate extends MatchesEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const MatchesFilterByDate({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Filtrar partidos por competición
class MatchesFilterByCompetition extends MatchesEvent {
  final int? idcompeticion;

  const MatchesFilterByCompetition({this.idcompeticion});

  @override
  List<Object?> get props => [idcompeticion];
}

/// Filtrar partidos por estado (local/visitante)
class MatchesFilterByVenue extends MatchesEvent {
  final bool? isLocal;

  const MatchesFilterByVenue({this.isLocal});

  @override
  List<Object?> get props => [isLocal];
}

/// Limpiar todos los filtros
class MatchesClearFilters extends MatchesEvent {
  const MatchesClearFilters();
}

/// Crear nuevo partido
class MatchCreateRequested extends MatchesEvent {
  final int idequipo;
  final int idTemporada;
  final DateTime fecha;
  final String? horaInicio;
  final String? horaFin;
  final String rival;
  final bool local;
  final int? idcompeticion;
  final String? observaciones;

  const MatchCreateRequested({
    required this.idequipo,
    required this.idTemporada,
    required this.fecha,
    this.horaInicio,
    this.horaFin,
    required this.rival,
    required this.local,
    this.idcompeticion,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        idequipo,
        idTemporada,
        fecha,
        horaInicio,
        horaFin,
        rival,
        local,
        idcompeticion,
        observaciones,
      ];
}

/// Actualizar partido existente
class MatchUpdateRequested extends MatchesEvent {
  final int id;
  final int idequipo;
  final int idTemporada;
  final DateTime fecha;
  final String? horaInicio;
  final String? horaFin;
  final String rival;
  final bool local;
  final int? idcompeticion;
  final String? observaciones;
  final int? golesLocal;
  final int? golesVisitante;
  final bool finalizado;

  const MatchUpdateRequested({
    required this.id,
    required this.idequipo,
    required this.idTemporada,
    required this.fecha,
    this.horaInicio,
    this.horaFin,
    required this.rival,
    required this.local,
    this.idcompeticion,
    this.observaciones,
    this.golesLocal,
    this.golesVisitante,
    this.finalizado = false,
  });

  @override
  List<Object?> get props => [
        id,
        idequipo,
        idTemporada,
        fecha,
        horaInicio,
        horaFin,
        rival,
        local,
        idcompeticion,
        observaciones,
        golesLocal,
        golesVisitante,
        finalizado,
      ];
}

/// Eliminar partido
class MatchDeleteRequested extends MatchesEvent {
  final int id;
  final int idequipo;
  final int idTemporada;

  const MatchDeleteRequested({
    required this.id,
    required this.idequipo,
    required this.idTemporada,
  });

  @override
  List<Object?> get props => [id, idequipo, idTemporada];
}

/// Cargar alineación de un partido
class LineupLoadRequested extends MatchesEvent {
  final int idpartido;
  final int idequipo;

  const LineupLoadRequested({
    required this.idpartido,
    required this.idequipo,
  });

  @override
  List<Object?> get props => [idpartido, idequipo];
}

/// Marcar jugador como titular/suplente
class LineupPlayerMarkRequested extends MatchesEvent {
  final int idpartido;
  final int idjugador;
  final bool titular;
  final int? minutoEntrada;
  final int? minutoSalida;

  const LineupPlayerMarkRequested({
    required this.idpartido,
    required this.idjugador,
    required this.titular,
    this.minutoEntrada,
    this.minutoSalida,
  });

  @override
  List<Object?> get props => [idpartido, idjugador, titular, minutoEntrada, minutoSalida];
}

/// Guardar alineación completa
class LineupSaveRequested extends MatchesEvent {
  final int idpartido;
  final Map<int, bool> lineup;
  final Map<int, int?> minutosEntrada;
  final Map<int, int?> minutosSalida;
  final Map<int, double?> posX;
  final Map<int, double?> posY;

  const LineupSaveRequested({
    required this.idpartido,
    required this.lineup,
    required this.minutosEntrada,
    required this.minutosSalida,
    this.posX = const {},
    this.posY = const {},
  });

  @override
  List<Object?> get props => [idpartido, lineup, minutosEntrada, minutosSalida, posX, posY];
}

/// Actualizar posición de un jugador en el campo
class LineupPositionUpdateRequested extends MatchesEvent {
  final int idpartido;
  final int idjugador;
  final double? posX;
  final double? posY;

  const LineupPositionUpdateRequested({
    required this.idpartido,
    required this.idjugador,
    this.posX,
    this.posY,
  });

  @override
  List<Object?> get props => [idpartido, idjugador, posX, posY];
}

// ==================== CONVOCATORIA ====================

/// Cargar jugadores del club para convocatoria
class ConvocatoriaLoadRequested extends MatchesEvent {
  final int idpartido;
  final int idclub;
  final int idTemporada;

  const ConvocatoriaLoadRequested({
    required this.idpartido,
    required this.idclub,
    required this.idTemporada,
  });

  @override
  List<Object?> get props => [idpartido, idclub, idTemporada];
}

/// Toggle jugador convocado (actualiza directamente en BD)
class ConvocatoriaPlayerToggleRequested extends MatchesEvent {
  final int idjugador;
  final int idequipo;
  final bool convocado;

  const ConvocatoriaPlayerToggleRequested({
    required this.idjugador,
    required this.idequipo,
    required this.convocado,
  });

  @override
  List<Object?> get props => [idjugador, idequipo, convocado];
}

/// Actualizar dorsal de un jugador convocado
class ConvocatoriaDorsalUpdateRequested extends MatchesEvent {
  final int idjugador;
  final int? dorsal;

  const ConvocatoriaDorsalUpdateRequested({
    required this.idjugador,
    this.dorsal,
  });

  @override
  List<Object?> get props => [idjugador, dorsal];
}
