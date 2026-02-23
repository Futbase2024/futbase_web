import 'package:equatable/equatable.dart';

/// Eventos del BLoC de equipos
abstract class TeamsEvent extends Equatable {
  const TeamsEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar equipos de un club
class TeamsLoadRequested extends TeamsEvent {
  final int idclub;

  const TeamsLoadRequested({required this.idclub});

  @override
  List<Object?> get props => [idclub];
}

/// Evento para refrescar la lista de equipos
class TeamsRefreshRequested extends TeamsEvent {
  final int idclub;

  const TeamsRefreshRequested({required this.idclub});

  @override
  List<Object?> get props => [idclub];
}

/// Evento para buscar equipos por nombre
class TeamsSearchRequested extends TeamsEvent {
  final String query;

  const TeamsSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Evento para filtrar equipos por categoría
class TeamsFilterByCategory extends TeamsEvent {
  final int? idcategoria;

  const TeamsFilterByCategory({this.idcategoria});

  @override
  List<Object?> get props => [idcategoria];
}

/// Evento para filtrar equipos por temporada
class TeamsFilterBySeason extends TeamsEvent {
  final int? idtemporada;

  const TeamsFilterBySeason({this.idtemporada});

  @override
  List<Object?> get props => [idtemporada];
}

/// Evento para limpiar filtros
class TeamsClearFilters extends TeamsEvent {
  const TeamsClearFilters();
}

/// Evento para crear un nuevo equipo
class TeamCreateRequested extends TeamsEvent {
  final int idclub;
  final int idcategoria;
  final int idtemporada;
  final String equipo;
  final String? ncorto;
  final int titulares;
  final int minutos;

  const TeamCreateRequested({
    required this.idclub,
    required this.idcategoria,
    required this.idtemporada,
    required this.equipo,
    this.ncorto,
    this.titulares = 11,
    this.minutos = 45,
  });

  @override
  List<Object?> get props => [
        idclub,
        idcategoria,
        idtemporada,
        equipo,
        ncorto,
        titulares,
        minutos,
      ];
}

/// Evento para actualizar un equipo existente
class TeamUpdateRequested extends TeamsEvent {
  final int id;
  final int idcategoria;
  final int idtemporada;
  final String equipo;
  final String? ncorto;
  final int titulares;
  final int minutos;

  const TeamUpdateRequested({
    required this.id,
    required this.idcategoria,
    required this.idtemporada,
    required this.equipo,
    this.ncorto,
    this.titulares = 11,
    this.minutos = 45,
  });

  @override
  List<Object?> get props => [
        id,
        idcategoria,
        idtemporada,
        equipo,
        ncorto,
        titulares,
        minutos,
      ];
}

/// Evento para eliminar un equipo
class TeamDeleteRequested extends TeamsEvent {
  final int id;

  const TeamDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
