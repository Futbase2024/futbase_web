import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:futbase_web_3/core/datasources/datasource_factory.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';

import 'scouting_event.dart';
import 'scouting_state.dart';

/// BLoC para gestión de Scouting
class ScoutingBloc extends Bloc<ScoutingEvent, ScoutingState> {
  final AppDataSource _dataSource;

  ScoutingBloc({AppDataSource? dataSource})
      : _dataSource = dataSource ?? DataSourceFactory.instance,
        super(const ScoutingInitial()) {
    on<ScoutingInitializeRequested>(_onInitializeRequested);
    on<ScoutingLoadPlayers>(_onLoadPlayers);
    on<ScoutingFilterSeasonChanged>(_onFilterSeasonChanged);
    on<ScoutingFilterPositionsChanged>(_onFilterPositionsChanged);
    on<ScoutingFilterCategoriesChanged>(_onFilterCategoriesChanged);
    on<ScoutingFilterFootChanged>(_onFilterFootChanged);
    on<ScoutingFilterAgeRangeChanged>(_onFilterAgeRangeChanged);
    on<ScoutingFilterRatingRangeChanged>(_onFilterRatingRangeChanged);
    on<ScoutingSearchChanged>(_onSearchChanged);
    on<ScoutingClearFilters>(_onClearFilters);
    on<ScoutingPlayerSelected>(_onPlayerSelected);
    on<ScoutingLoadPlayerHistory>(_onLoadPlayerHistory);
    on<ScoutingClosePlayerDetail>(_onClosePlayerDetail);
    on<ScoutingAddToComparison>(_onAddToComparison);
    on<ScoutingRemoveFromComparison>(_onRemoveFromComparison);
    on<ScoutingClearComparison>(_onClearComparison);
    on<ScoutingPageChanged>(_onPageChanged);
  }

  /// Inicializar datos maestros
  Future<void> _onInitializeRequested(
    ScoutingInitializeRequested event,
    Emitter<ScoutingState> emit,
  ) async {
    emit(const ScoutingLoading());

    try {
      // Cargar datos maestros en paralelo
      final results = await Future.wait([
        _dataSource.getTemporadas(),
        _dataSource.getPosiciones(),
        _dataSource.getCategorias(),
      ]);

      final temporadasResponse = results[0];
      final posicionesResponse = results[1];
      final categoriasResponse = results[2];

      // Crear mapas de datos maestros
      final temporadasMap = <int, String>{};
      if (temporadasResponse.success && temporadasResponse.data != null) {
        for (final t in temporadasResponse.data!) {
          temporadasMap[t['id'] as int] = t['temporada'] as String;
        }
      }

      final posicionesMap = <int, String>{};
      if (posicionesResponse.success && posicionesResponse.data != null) {
        for (final p in posicionesResponse.data!) {
          posicionesMap[p['id'] as int] = p['posicion'] as String;
        }
      }

      final categoriasMap = <int, String>{};
      if (categoriasResponse.success && categoriasResponse.data != null) {
        for (final c in categoriasResponse.data!) {
          categoriasMap[c['id'] as int] = c['categoria'] as String;
        }
      }

      // Pie dominante (valores únicos)
      final piesMap = <int, String>{
        1: 'DERECHO',
        2: 'ZURDO',
        3: 'AMBIDIESTRO',
      };

      // Cargar jugadores con temporada activa (la más reciente)
      final temporadaActiva = temporadasMap.keys.isNotEmpty
          ? temporadasMap.keys.reduce((a, b) => a > b ? a : b)
          : null;

      final filters = ScoutingFilters(idtemporada: temporadaActiva);

      emit(ScoutingLoaded(
        players: [],
        filteredPlayers: [],
        filters: filters,
        temporadas: temporadasMap,
        posiciones: posicionesMap,
        categorias: categoriasMap,
        pies: piesMap,
        userClubId: event.userClubId,
        isSuperAdmin: event.isSuperAdmin,
        isLoadingPlayers: true,
      ));

      // Cargar jugadores automáticamente
      add(const ScoutingLoadPlayers());
    } catch (e) {
      debugPrint('❌ ScoutingBloc._onInitializeRequested: $e');
      emit(ScoutingError(message: 'Error al cargar datos: $e'));
    }
  }

  /// Cargar jugadores con filtros
  Future<void> _onLoadPlayers(
    ScoutingLoadPlayers event,
    Emitter<ScoutingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    try {
      final filters = currentState.filters;

      // Construir parámetros de filtro
      int? idclubFilter;
      if (!currentState.isSuperAdmin && currentState.userClubId != null) {
        idclubFilter = currentState.userClubId;
      }

      final response = await _dataSource.getScoutingPlayers(
        idclub: idclubFilter,
        idtemporada: filters.idtemporada,
        idposiciones: filters.idposiciones.isNotEmpty
            ? filters.idposiciones.toList()
            : null,
        idcategorias: filters.idcategorias.isNotEmpty
            ? filters.idcategorias.toList()
            : null,
        idpiedominante: filters.idpiedominante,
        searchQuery: filters.searchQuery.isNotEmpty ? filters.searchQuery : null,
      );

      if (!response.success || response.data == null) {
        emit(ScoutingError(message: response.message ?? 'Error al cargar jugadores'));
        return;
      }

      var players = response.data!;

      // Filtrar por edad en memoria (más flexible que SQL)
      if (filters.minAge != null || filters.maxAge != null) {
        players = _filterByAge(players, filters.minAge, filters.maxAge);
      }

      // Filtrar por valoración en memoria
      if (filters.minRating != null || filters.maxRating != null) {
        players = _filterByRating(players, filters.minRating, filters.maxRating);
      }

      emit(currentState.copyWith(
        players: players,
        filteredPlayers: players,
        totalCount: players.length,
        currentPage: 0,
        isLoadingPlayers: false,
      ));
    } catch (e) {
      debugPrint('❌ ScoutingBloc._onLoadPlayers: $e');
      emit(ScoutingError(message: 'Error al cargar jugadores: $e'));
    }
  }

  /// Cambiar filtro de temporada
  Future<void> _onFilterSeasonChanged(
    ScoutingFilterSeasonChanged event,
    Emitter<ScoutingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      idtemporada: event.idtemporada,
      clearTemporada: event.idtemporada == null,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Cambiar filtro de posiciones
  void _onFilterPositionsChanged(
    ScoutingFilterPositionsChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      idposiciones: event.idposiciones,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Cambiar filtro de categorías
  void _onFilterCategoriesChanged(
    ScoutingFilterCategoriesChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      idcategorias: event.idcategorias,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Cambiar filtro de pie dominante
  void _onFilterFootChanged(
    ScoutingFilterFootChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      idpiedominante: event.idpiedominante,
      clearPie: event.idpiedominante == null,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Cambiar rango de edad
  void _onFilterAgeRangeChanged(
    ScoutingFilterAgeRangeChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      minAge: event.minAge,
      maxAge: event.maxAge,
      clearAge: event.minAge == null && event.maxAge == null,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Cambiar rango de valoración
  void _onFilterRatingRangeChanged(
    ScoutingFilterRatingRangeChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      minRating: event.minRating,
      maxRating: event.maxRating,
      clearRating: event.minRating == null && event.maxRating == null,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Búsqueda por nombre
  void _onSearchChanged(
    ScoutingSearchChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newFilters = currentState.filters.copyWith(
      searchQuery: event.query,
    );

    emit(currentState.copyWith(filters: newFilters));
    add(const ScoutingLoadPlayers());
  }

  /// Limpiar todos los filtros
  void _onClearFilters(
    ScoutingClearFilters event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    emit(currentState.copyWith(filters: const ScoutingFilters()));
    add(const ScoutingLoadPlayers());
  }

  /// Seleccionar jugador para ver detalle
  Future<void> _onPlayerSelected(
    ScoutingPlayerSelected event,
    Emitter<ScoutingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    emit(currentState.copyWith(selectedPlayer: event.player));

    // Cargar historial automáticamente
    final jugadorId = event.player['id'] as int;
    add(ScoutingLoadPlayerHistory(jugadorId: jugadorId));
  }

  /// Cargar historial de un jugador
  Future<void> _onLoadPlayerHistory(
    ScoutingLoadPlayerHistory event,
    Emitter<ScoutingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    try {
      final response = await _dataSource.getPlayerHistory(jugadorId: event.jugadorId);

      if (response.success && response.data != null) {
        emit(currentState.copyWith(playerHistory: response.data));
      } else {
        emit(currentState.copyWith(playerHistory: []));
      }
    } catch (e) {
      debugPrint('❌ ScoutingBloc._onLoadPlayerHistory: $e');
      // No emitir error, mantener historial vacío
    }
  }

  /// Cerrar detalle de jugador
  void _onClosePlayerDetail(
    ScoutingClosePlayerDetail event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    emit(currentState.copyWith(
      clearSelectedPlayer: true,
      clearPlayerHistory: true,
    ));
  }

  /// Añadir jugador al comparador
  void _onAddToComparison(
    ScoutingAddToComparison event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;
    if (!currentState.canAddToComparison) return;

    final jugadorId = event.player['id'];
    final alreadyInComparison = currentState.comparisonPlayers
        .any((p) => p['id'] == jugadorId);

    if (alreadyInComparison) return;

    final newComparisonPlayers = [
      ...currentState.comparisonPlayers,
      event.player,
    ];

    emit(currentState.copyWith(comparisonPlayers: newComparisonPlayers));
  }

  /// Quitar jugador del comparador
  void _onRemoveFromComparison(
    ScoutingRemoveFromComparison event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    final newComparisonPlayers = currentState.comparisonPlayers
        .where((p) => p['id'] != event.jugadorId)
        .toList();

    emit(currentState.copyWith(comparisonPlayers: newComparisonPlayers));
  }

  /// Limpiar comparador
  void _onClearComparison(
    ScoutingClearComparison event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    emit(currentState.copyWith(comparisonPlayers: []));
  }

  /// Cambiar página
  void _onPageChanged(
    ScoutingPageChanged event,
    Emitter<ScoutingState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScoutingLoaded) return;

    if (event.page < 0 || event.page >= currentState.totalPages) return;

    emit(currentState.copyWith(currentPage: event.page));
  }

  /// Filtrar jugadores por edad
  List<Map<String, dynamic>> _filterByAge(
    List<Map<String, dynamic>> players,
    int? minAge,
    int? maxAge,
  ) {
    final now = DateTime.now();
    return players.where((player) {
      final fechaNac = player['fechanacimiento'] as String?;
      if (fechaNac == null || fechaNac.isEmpty) return false;

      try {
        // Parsear fecha en formato dd-MM-yyyy
        final parts = fechaNac.split('-');
        if (parts.length != 3) return false;

        final birthDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );

        int age = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }

        if (minAge != null && age < minAge) return false;
        if (maxAge != null && age > maxAge) return false;

        return true;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Filtrar jugadores por valoración
  List<Map<String, dynamic>> _filterByRating(
    List<Map<String, dynamic>> players,
    int? minRating,
    int? maxRating,
  ) {
    return players.where((player) {
      final valoracion = player['valoracion'] as int?;
      if (valoracion == null) return false;

      if (minRating != null && valoracion < minRating) return false;
      if (maxRating != null && valoracion > maxRating) return false;

      return true;
    }).toList();
  }
}
