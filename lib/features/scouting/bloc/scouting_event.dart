import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Scouting
abstract class ScoutingEvent extends Equatable {
  const ScoutingEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar datos iniciales (temporadas, posiciones, categorías)
class ScoutingInitializeRequested extends ScoutingEvent {
  const ScoutingInitializeRequested();
}

/// Evento para cargar jugadores con los filtros actuales
class ScoutingLoadPlayers extends ScoutingEvent {
  const ScoutingLoadPlayers();
}

/// Evento para cambiar filtro de temporada
class ScoutingFilterSeasonChanged extends ScoutingEvent {
  final int? idtemporada;

  const ScoutingFilterSeasonChanged({this.idtemporada});

  @override
  List<Object?> get props => [idtemporada];
}

/// Evento para cambiar filtro de posiciones (múltiples)
class ScoutingFilterPositionsChanged extends ScoutingEvent {
  final Set<int> idposiciones;

  const ScoutingFilterPositionsChanged({required this.idposiciones});

  @override
  List<Object?> get props => [idposiciones];
}

/// Evento para cambiar filtro de categorías (múltiples)
class ScoutingFilterCategoriesChanged extends ScoutingEvent {
  final Set<int> idcategorias;

  const ScoutingFilterCategoriesChanged({required this.idcategorias});

  @override
  List<Object?> get props => [idcategorias];
}

/// Evento para cambiar filtro de pie dominante
class ScoutingFilterFootChanged extends ScoutingEvent {
  final int? idpiedominante;

  const ScoutingFilterFootChanged({this.idpiedominante});

  @override
  List<Object?> get props => [idpiedominante];
}

/// Evento para cambiar rango de edad
class ScoutingFilterAgeRangeChanged extends ScoutingEvent {
  final int? minAge;
  final int? maxAge;

  const ScoutingFilterAgeRangeChanged({this.minAge, this.maxAge});

  @override
  List<Object?> get props => [minAge, maxAge];
}

/// Evento para cambiar rango de valoración
class ScoutingFilterRatingRangeChanged extends ScoutingEvent {
  final int? minRating;
  final int? maxRating;

  const ScoutingFilterRatingRangeChanged({this.minRating, this.maxRating});

  @override
  List<Object?> get props => [minRating, maxRating];
}

/// Evento para búsqueda por nombre
class ScoutingSearchChanged extends ScoutingEvent {
  final String query;

  const ScoutingSearchChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Evento para limpiar todos los filtros
class ScoutingClearFilters extends ScoutingEvent {
  const ScoutingClearFilters();
}

/// Evento para seleccionar un jugador y ver detalle
class ScoutingPlayerSelected extends ScoutingEvent {
  final Map<String, dynamic> player;

  const ScoutingPlayerSelected({required this.player});

  @override
  List<Object?> get props => [player];
}

/// Evento para cargar estadísticas históricas de un jugador
class ScoutingLoadPlayerHistory extends ScoutingEvent {
  final int jugadorId;

  const ScoutingLoadPlayerHistory({required this.jugadorId});

  @override
  List<Object?> get props => [jugadorId];
}

/// Evento para cerrar el detalle de jugador
class ScoutingClosePlayerDetail extends ScoutingEvent {
  const ScoutingClosePlayerDetail();
}

/// Evento para añadir jugador al comparador
class ScoutingAddToComparison extends ScoutingEvent {
  final Map<String, dynamic> player;

  const ScoutingAddToComparison({required this.player});

  @override
  List<Object?> get props => [player];
}

/// Evento para quitar jugador del comparador
class ScoutingRemoveFromComparison extends ScoutingEvent {
  final int jugadorId;

  const ScoutingRemoveFromComparison({required this.jugadorId});

  @override
  List<Object?> get props => [jugadorId];
}

/// Evento para limpiar el comparador
class ScoutingClearComparison extends ScoutingEvent {
  const ScoutingClearComparison();
}

/// Evento para cambiar página (paginación)
class ScoutingPageChanged extends ScoutingEvent {
  final int page;

  const ScoutingPageChanged({required this.page});

  @override
  List<Object?> get props => [page];
}
