import 'package:equatable/equatable.dart';

/// Eventos del BLoC de jugadores
abstract class PlayersEvent extends Equatable {
  const PlayersEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar jugadores
/// Si se proporciona idclub y loadByClub es true, carga todos los jugadores del club
/// Si se proporciona idequipo, carga los jugadores de ese equipo
/// activeSeasonId es obligatorio para filtrar por temporada activa
class PlayersLoadRequested extends PlayersEvent {
  final int? idclub;
  final int? idequipo;
  final bool loadByClub;
  final int activeSeasonId;

  const PlayersLoadRequested({
    this.idclub,
    this.idequipo,
    this.loadByClub = false,
    required this.activeSeasonId,
  });

  @override
  List<Object?> get props => [idclub, idequipo, loadByClub, activeSeasonId];
}

/// Evento para refrescar la lista de jugadores
class PlayersRefreshRequested extends PlayersEvent {
  final int idequipo;
  final int? idclub;
  final int idtemporada;

  const PlayersRefreshRequested({
    required this.idequipo,
    this.idclub,
    required this.idtemporada,
  });

  @override
  List<Object?> get props => [idequipo, idclub, idtemporada];
}

/// Evento para buscar jugadores por nombre
class PlayersSearchRequested extends PlayersEvent {
  final int idequipo;
  final String query;

  const PlayersSearchRequested({
    required this.idequipo,
    required this.query,
  });

  @override
  List<Object?> get props => [idequipo, query];
}

/// Evento para filtrar jugadores por posición
class PlayersFilterByPosition extends PlayersEvent {
  final int? idposicion;

  const PlayersFilterByPosition({this.idposicion});

  @override
  List<Object?> get props => [idposicion];
}

/// Evento para filtrar jugadores por equipo
class PlayersFilterByTeam extends PlayersEvent {
  final int? idequipo;

  const PlayersFilterByTeam({this.idequipo});

  @override
  List<Object?> get props => [idequipo];
}

/// Evento para limpiar filtros
class PlayersClearFilters extends PlayersEvent {
  const PlayersClearFilters();
}

/// Evento para seleccionar un jugador
class PlayerSelected extends PlayersEvent {
  final Map<String, dynamic> player;

  const PlayerSelected({required this.player});

  @override
  List<Object?> get props => [player];
}

/// Evento cuando el usuario no tiene equipo asignado
class PlayersNoTeamEvent extends PlayersEvent {
  const PlayersNoTeamEvent();
}

/// Evento para alternar mostrar jugadores inactivos
class PlayersToggleInactive extends PlayersEvent {
  final bool showInactive;
  final int activeSeasonId;

  const PlayersToggleInactive({
    required this.showInactive,
    required this.activeSeasonId,
  });

  @override
  List<Object?> get props => [showInactive, activeSeasonId];
}
