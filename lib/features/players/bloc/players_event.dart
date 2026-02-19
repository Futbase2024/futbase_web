import 'package:equatable/equatable.dart';

/// Eventos del BLoC de jugadores
abstract class PlayersEvent extends Equatable {
  const PlayersEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar jugadores de un equipo
class PlayersLoadRequested extends PlayersEvent {
  final int idequipo;

  const PlayersLoadRequested({required this.idequipo});

  @override
  List<Object?> get props => [idequipo];
}

/// Evento para refrescar la lista de jugadores
class PlayersRefreshRequested extends PlayersEvent {
  final int idequipo;

  const PlayersRefreshRequested({required this.idequipo});

  @override
  List<Object?> get props => [idequipo];
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
