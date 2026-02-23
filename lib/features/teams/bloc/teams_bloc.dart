import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'teams_event.dart';
import 'teams_state.dart';

/// BLoC para gestión de equipos
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  final SupabaseClient _supabase;

  TeamsBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
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
    debugPrint('🔵 [TeamsBloc] Cargando equipos del club: ${event.idclub}');
    emit(const TeamsLoading());

    try {
      // Ejecutar queries en paralelo
      final results = await Future.wait([
        _supabase
            .from('vequipos')
            .select()
            .eq('idclub', event.idclub)
            .order('equipo'),
        _supabase.from('tcategorias').select('id, categoria').order('id'),
        _supabase.from('ttemporadas').select('id, temporada').order('id', ascending: false),
      ]);

      final teamsResponse = results[0];
      final categoriesData = results[1];
      final seasonsData = results[2];

      // Crear mapas de categorías y temporadas
      final categoriesMap = <int, String>{};
      for (final cat in categoriesData) {
        categoriesMap[cat['id'] as int] = cat['categoria'] as String;
      }

      final seasonsMap = <int, String>{};
      for (final season in seasonsData) {
        seasonsMap[season['id'] as int] = season['temporada'] as String;
      }

      final teams = (teamsResponse as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .toList();

      debugPrint('✅ [TeamsBloc] Cargados ${teams.length} equipos');

      emit(TeamsLoaded(
        teams: teams,
        filteredTeams: teams,
        categories: categoriesMap,
        seasons: seasonsMap,
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
        _supabase
            .from('vequipos')
            .select()
            .eq('idclub', event.idclub)
            .order('equipo'),
        _supabase.from('tcategorias').select('id, categoria').order('id'),
        _supabase.from('ttemporadas').select('id, temporada').order('id', ascending: false),
      ]);

      final teamsData = results[0] as List<dynamic>;
      final categoriesData = results[1] as List<dynamic>;
      final seasonsData = results[2] as List<dynamic>;

      final categoriesMap = <int, String>{};
      for (final cat in categoriesData) {
        categoriesMap[cat['id'] as int] = cat['categoria'] as String;
      }

      final seasonsMap = <int, String>{};
      for (final season in seasonsData) {
        seasonsMap[season['id'] as int] = season['temporada'] as String;
      }

      final teams = teamsData.cast<Map<String, dynamic>>().toList();

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

    try {
      await _supabase.from('tequipos').insert({
        'idclub': event.idclub,
        'idcategoria': event.idcategoria,
        'idtemporada': event.idtemporada,
        'equipo': event.equipo,
        'ncorto': event.ncorto,
        'titulares': event.titulares,
        'minutos': event.minutos,
      });

      debugPrint('✅ [TeamsBloc] Equipo creado: ${event.equipo}');

      // Recargar equipos
      add(TeamsRefreshRequested(idclub: event.idclub));
    } catch (e) {
      debugPrint('❌ [TeamsBloc] Error al crear equipo: $e');
      emit(currentState.copyWith(isCreating: false));
      emit(TeamsError(message: 'Error al crear equipo: $e'));
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

    try {
      await _supabase
          .from('tequipos')
          .update({
            'idcategoria': event.idcategoria,
            'idtemporada': event.idtemporada,
            'equipo': event.equipo,
            'ncorto': event.ncorto,
            'titulares': event.titulares,
            'minutos': event.minutos,
          })
          .eq('id', event.id);

      debugPrint('✅ [TeamsBloc] Equipo actualizado: ${event.equipo}');

      // Obtener idclub del equipo actualizado para refrescar
      final teamToUpdate = currentState.teams.firstWhere(
        (t) => t['id'] == event.id,
        orElse: () => <String, dynamic>{},
      );

      if (teamToUpdate.isNotEmpty) {
        add(TeamsRefreshRequested(idclub: teamToUpdate['idclub'] as int));
      }
    } catch (e) {
      debugPrint('❌ [TeamsBloc] Error al actualizar equipo: $e');
      emit(currentState.copyWith(isUpdating: false));
      emit(TeamsError(message: 'Error al actualizar equipo: $e'));
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

    try {
      // Obtener idclub antes de eliminar
      final teamToDelete = currentState.teams.firstWhere(
        (t) => t['id'] == event.id,
        orElse: () => <String, dynamic>{},
      );

      await _supabase.from('tequipos').delete().eq('id', event.id);

      debugPrint('✅ [TeamsBloc] Equipo eliminado: ${event.id}');

      if (teamToDelete.isNotEmpty) {
        add(TeamsRefreshRequested(idclub: teamToDelete['idclub'] as int));
      }
    } catch (e) {
      debugPrint('❌ [TeamsBloc] Error al eliminar equipo: $e');
      emit(currentState.copyWith(isDeleting: false));
      emit(TeamsError(message: 'Error al eliminar equipo: $e'));
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
