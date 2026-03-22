import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:futbase_web_3/core/datasources/datasource_factory.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';

import 'teams_event.dart';
import 'teams_state.dart';

/// BLoC para gestión de equipos
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  final AppDataSource _dataSource;

  TeamsBloc({AppDataSource? dataSource})
      : _dataSource = dataSource ?? DataSourceFactory.instance,
        super(const TeamsInitial()) {
    on<TeamsLoadRequested>(_onLoadRequested);
    on<TeamsRefreshRequested>(_onRefreshRequested);
    on<TeamsSearchRequested>(_onSearchRequested);
    on<TeamsFilterByCategory>(_onFilterByCategory);
    on<TeamsFilterBySeason>(_onFilterBySeason);
    on<TeamsClearFilters>(_onClearFilters);
    on<TeamCreateRequested>(_onCreateRequested);
    on<TeamUpdateRequested>(_onUpdateRequested);
    on<TeamDeleteRequested>(_onDeleteRequested);
  }

  /// Carga inicial de equipos
  Future<void> _onLoadRequested(
    TeamsLoadRequested event,
    Emitter<TeamsState> emit,
  ) async {
    debugPrint('🔵 [TeamsBloc] Cargando equipos del club: ${event.idclub}, temporada: ${event.activeSeasonId}');
    emit(const TeamsLoading());

    try {
      final activeSeasonId = event.activeSeasonId;
      debugPrint('🗓️ [TeamsBloc] Temporada activa: $activeSeasonId');

      // Ejecutar queries en paralelo
      final results = await Future.wait([
        _dataSource.getEquipos(idclub: event.idclub, idtemporada: activeSeasonId),
        _dataSource.getCategorias(),
        _dataSource.getTemporadas(),
      ]);

      final teamsResponse = results[0];
      final categoriesResponse = results[1];
      final seasonsResponse = results[2];

      if (!teamsResponse.success || teamsResponse.data == null) {
        emit(TeamsError(message: teamsResponse.message ?? 'Error al cargar equipos'));
        return;
      }

      final teams = teamsResponse.data!;

      // Crear mapas de categorías y temporadas
      final categoriesMap = <int, String>{};
      if (categoriesResponse.success && categoriesResponse.data != null) {
        for (final cat in categoriesResponse.data!) {
          categoriesMap[cat['id'] as int] = cat['categoria'] as String;
        }
      }

      final seasonsMap = <int, String>{};
      if (seasonsResponse.success && seasonsResponse.data != null) {
        for (final season in seasonsResponse.data!) {
          seasonsMap[season['id'] as int] = season['temporada'] as String;
        }
      }

      debugPrint('✅ [TeamsBloc] Cargados ${teams.length} equipos');

      emit(TeamsLoaded(
        teams: teams,
        filteredTeams: teams,
        categories: categoriesMap,
        seasons: seasonsMap,
        idclub: event.idclub,
        activeSeasonId: activeSeasonId,
      ));
    } catch (e) {
      debugPrint('❌ [TeamsBloc] Error al cargar equipos: $e');
      emit(TeamsError(message: e.toString()));
    }
  }

  /// Refrescar datos
  Future<void> _onRefreshRequested(
    TeamsRefreshRequested event,
    Emitter<TeamsState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    int? currentCategory;
    int? currentSeason;

    if (currentState is TeamsLoaded) {
      currentSearch = currentState.searchQuery;
      currentCategory = currentState.filterByCategory;
      currentSeason = currentState.filterBySeason;
    }

    try {
      final results = await Future.wait([
        _dataSource.getEquipos(idclub: event.idclub, idtemporada: event.activeSeasonId),
        _dataSource.getCategorias(),
        _dataSource.getTemporadas(),
      ]);

      final teamsResponse = results[0];
      final categoriesResponse = results[1];
      final seasonsResponse = results[2];

      if (!teamsResponse.success || teamsResponse.data == null) {
        emit(TeamsError(message: teamsResponse.message ?? 'Error al refrescar'));
        return;
      }

      final teams = teamsResponse.data!;

      final categoriesMap = <int, String>{};
      if (categoriesResponse.success && categoriesResponse.data != null) {
        for (final cat in categoriesResponse.data!) {
          categoriesMap[cat['id'] as int] = cat['categoria'] as String;
        }
      }

      final seasonsMap = <int, String>{};
      if (seasonsResponse.success && seasonsResponse.data != null) {
        for (final season in seasonsResponse.data!) {
          seasonsMap[season['id'] as int] = season['temporada'] as String;
        }
      }

      // Aplicar filtros anteriores
      var filteredTeams = teams;

      if (currentSearch.isNotEmpty) {
        filteredTeams = _filterBySearch(filteredTeams, currentSearch);
      }

      if (currentCategory != null) {
        filteredTeams = _filterByCategoryId(filteredTeams, currentCategory);
      }

      if (currentSeason != null) {
        filteredTeams = _filterBySeasonId(filteredTeams, currentSeason);
      }

      emit(TeamsLoaded(
        teams: teams,
        filteredTeams: filteredTeams,
        categories: categoriesMap,
        seasons: seasonsMap,
        searchQuery: currentSearch,
        filterByCategory: currentCategory,
        filterBySeason: currentSeason,
        idclub: event.idclub,
        activeSeasonId: event.activeSeasonId,
      ));
    } catch (e) {
      emit(TeamsError(message: e.toString()));
    }
  }

  /// Búsqueda de equipos
  void _onSearchRequested(
    TeamsSearchRequested event,
    Emitter<TeamsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    var filteredTeams = currentState.teams;

    // Filtrar por búsqueda
    if (event.query.isNotEmpty) {
      filteredTeams = _filterBySearch(filteredTeams, event.query);
    }

    // Mantener filtros de categoría y temporada si existen
    if (currentState.filterByCategory != null) {
      filteredTeams = _filterByCategoryId(filteredTeams, currentState.filterByCategory!);
    }

    if (currentState.filterBySeason != null) {
      filteredTeams = _filterBySeasonId(filteredTeams, currentState.filterBySeason!);
    }

    emit(currentState.copyWith(
      filteredTeams: filteredTeams,
      searchQuery: event.query,
    ));
  }

  /// Filtrar por categoría
  void _onFilterByCategory(
    TeamsFilterByCategory event,
    Emitter<TeamsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    var filteredTeams = currentState.teams;

    // Filtrar por categoría
    if (event.idcategoria != null) {
      filteredTeams = _filterByCategoryId(filteredTeams, event.idcategoria!);
    }

    // Mantener búsqueda si existe
    if (currentState.searchQuery.isNotEmpty) {
      filteredTeams = _filterBySearch(filteredTeams, currentState.searchQuery);
    }

    // Mantener filtro de temporada si existe
    if (currentState.filterBySeason != null) {
      filteredTeams = _filterBySeasonId(filteredTeams, currentState.filterBySeason!);
    }

    emit(currentState.copyWith(
      filteredTeams: filteredTeams,
      filterByCategory: event.idcategoria,
    ));
  }

  /// Filtrar por temporada
  void _onFilterBySeason(
    TeamsFilterBySeason event,
    Emitter<TeamsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    var filteredTeams = currentState.teams;

    // Filtrar por temporada
    if (event.idtemporada != null) {
      filteredTeams = _filterBySeasonId(filteredTeams, event.idtemporada!);
    }

    // Mantener búsqueda si existe
    if (currentState.searchQuery.isNotEmpty) {
      filteredTeams = _filterBySearch(filteredTeams, currentState.searchQuery);
    }

    // Mantener filtro de categoría si existe
    if (currentState.filterByCategory != null) {
      filteredTeams = _filterByCategoryId(filteredTeams, currentState.filterByCategory!);
    }

    emit(currentState.copyWith(
      filteredTeams: filteredTeams,
      filterBySeason: event.idtemporada,
    ));
  }

  /// Limpiar filtros
  void _onClearFilters(
    TeamsClearFilters event,
    Emitter<TeamsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    emit(currentState.copyWith(
      filteredTeams: currentState.teams,
      searchQuery: '',
      filterByCategory: null,
      filterBySeason: null,
    ));
  }

  /// Crear equipo
  Future<void> _onCreateRequested(
    TeamCreateRequested event,
    Emitter<TeamsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    emit(currentState.copyWith(isCreating: true));

    final response = await _dataSource.createEquipo(
      idclub: event.idclub,
      idcategoria: event.idcategoria,
      idtemporada: event.idtemporada,
      equipo: event.equipo,
      ncorto: event.ncorto,
      titulares: event.titulares,
      minutos: event.minutos,
    );

    if (response.success) {
      debugPrint('✅ [TeamsBloc] Equipo creado: ${event.equipo}');
      add(TeamsRefreshRequested(
        idclub: event.idclub,
        activeSeasonId: event.idtemporada,
      ));
    } else {
      debugPrint('❌ [TeamsBloc] Error al crear equipo: ${response.message}');
      emit(currentState.copyWith(isCreating: false));
      emit(TeamsError(message: 'Error al crear equipo: ${response.message}'));
    }
  }

  /// Actualizar equipo
  Future<void> _onUpdateRequested(
    TeamUpdateRequested event,
    Emitter<TeamsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    final response = await _dataSource.updateEquipo(
      id: event.id,
      idcategoria: event.idcategoria,
      idtemporada: event.idtemporada,
      equipo: event.equipo,
      ncorto: event.ncorto,
      titulares: event.titulares,
      minutos: event.minutos,
    );

    if (response.success) {
      debugPrint('✅ [TeamsBloc] Equipo actualizado: ${event.equipo}');

      // Obtener idclub del equipo actualizado para refrescar
      final teamToUpdate = currentState.teams.firstWhere(
        (t) => t['id'] == event.id,
        orElse: () => <String, dynamic>{},
      );

      if (teamToUpdate.isNotEmpty) {
        add(TeamsRefreshRequested(
          idclub: teamToUpdate['idclub'] as int,
          activeSeasonId: currentState.activeSeasonId,
        ));
      }
    } else {
      debugPrint('❌ [TeamsBloc] Error al actualizar equipo: ${response.message}');
      emit(currentState.copyWith(isUpdating: false));
      emit(TeamsError(message: 'Error al actualizar equipo: ${response.message}'));
    }
  }

  /// Eliminar equipo
  Future<void> _onDeleteRequested(
    TeamDeleteRequested event,
    Emitter<TeamsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeamsLoaded) return;

    emit(currentState.copyWith(isDeleting: true));

    // Obtener idclub antes de eliminar
    final teamToDelete = currentState.teams.firstWhere(
      (t) => t['id'] == event.id,
      orElse: () => <String, dynamic>{},
    );

    final response = await _dataSource.deleteEquipo(id: event.id);

    if (response.success) {
      debugPrint('✅ [TeamsBloc] Equipo eliminado: ${event.id}');

      if (teamToDelete.isNotEmpty) {
        add(TeamsRefreshRequested(
          idclub: teamToDelete['idclub'] as int,
          activeSeasonId: currentState.activeSeasonId,
        ));
      }
    } else {
      debugPrint('❌ [TeamsBloc] Error al eliminar equipo: ${response.message}');
      emit(currentState.copyWith(isDeleting: false));
      emit(TeamsError(message: 'Error al eliminar equipo: ${response.message}'));
    }
  }

  /// Filtra equipos por texto de búsqueda
  List<Map<String, dynamic>> _filterBySearch(
    List<Map<String, dynamic>> teams,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return teams.where((team) {
      final equipo = (team['equipo'] ?? '').toString().toLowerCase();
      final ncorto = (team['ncorto'] ?? '').toString().toLowerCase();
      final categoria = (team['categoria'] ?? '').toString().toLowerCase();
      final clubequipo = (team['clubequipo'] ?? '').toString().toLowerCase();
      return equipo.contains(lowerQuery) ||
          ncorto.contains(lowerQuery) ||
          categoria.contains(lowerQuery) ||
          clubequipo.contains(lowerQuery);
    }).toList();
  }

  /// Filtra equipos por ID de categoría
  List<Map<String, dynamic>> _filterByCategoryId(
    List<Map<String, dynamic>> teams,
    int idcategoria,
  ) {
    return teams.where((team) {
      return team['idcategoria'] == idcategoria;
    }).toList();
  }

  /// Filtra equipos por ID de temporada
  List<Map<String, dynamic>> _filterBySeasonId(
    List<Map<String, dynamic>> teams,
    int idtemporada,
  ) {
    return teams.where((team) {
      return team['idtemporada'] == idtemporada;
    }).toList();
  }
}
