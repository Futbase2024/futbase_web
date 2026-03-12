import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'scouting_event.dart';
import 'scouting_state.dart';

/// BLoC para gestión de Scouting
class ScoutingBloc extends Bloc<ScoutingEvent, ScoutingState> {
  final SupabaseClient _supabase;

  ScoutingBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
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
        _supabase.from('ttemporadas').select('id, temporada').order('id', ascending: false),
        _supabase.from('tposiciones').select('id, posicion').order('id'),
        _supabase.from('tcategorias').select('id, categoria').order('id'),
        _supabase
            .from('tjugadores')
            .select('idpiedominante')
            .not('idpiedominante', 'is', null),
      ]);

      final temporadasData = results[0] as List<dynamic>;
      final posicionesData = results[1] as List<dynamic>;
      final categoriasData = results[2] as List<dynamic>;
      // piesData no se usa directamente, los valores son fijos

      // Crear mapas de datos maestros
      final temporadasMap = <int, String>{};
      for (final t in temporadasData) {
        temporadasMap[t['id'] as int] = t['temporada'] as String;
      }

      final posicionesMap = <int, String>{};
      for (final p in posicionesData) {
        posicionesMap[p['id'] as int] = p['posicion'] as String;
      }

      final categoriasMap = <int, String>{};
      for (final c in categoriasData) {
        categoriasMap[c['id'] as int] = c['categoria'] as String;
      }

      // Pie dominante (valores únicos)
      final piesMap = <int, String>{
        1: 'DERECHO',
        2: 'ZURDO',
        3: 'AMBIDIESTRO',
      };

      // Cargar jugadores con temporada activa (la más reciente)
      final temporadaActiva = temporadasData.isNotEmpty
          ? temporadasData.first['id'] as int
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

      // Construir query base usando la vista vjugadores
      dynamic query = _supabase
          .from('vjugadores')
          .select('''
            id, nombre, apellidos, apodo, foto, dorsal,
            idposicion, posicion,
            idcategoria, categoria,
            idpiedominante, pie,
            fechanacimiento, altura, peso,
            idtemporada, temporada,
            idequipo, equipo,
            idclub, club,
            pj, ptitular, plesionado,
            goles, penalti, ta, ta2, tr,
            minutos, valoracion, capitan
          ''');

      // Si NO es superAdmin, filtrar por el club del usuario
      if (!currentState.isSuperAdmin && currentState.userClubId != null) {
        query = query.eq('idclub', currentState.userClubId!);
      }

      // Aplicar filtro de temporada
      if (filters.idtemporada != null) {
        query = query.eq('idtemporada', filters.idtemporada!);
      }

      // Aplicar filtro de posiciones
      if (filters.idposiciones.isNotEmpty) {
        query = query.inFilter('idposicion', filters.idposiciones.toList());
      }

      // Aplicar filtro de categorías
      if (filters.idcategorias.isNotEmpty) {
        query = query.inFilter('idcategoria', filters.idcategorias.toList());
      }

      // Aplicar filtro de pie dominante
      if (filters.idpiedominante != null) {
        query = query.eq('idpiedominante', filters.idpiedominante!);
      }

      // Ordenar por nombre y apellidos de A a Z (ascendente)
      final response = await query
          .order('nombre', ascending: true)
          .order('apellidos', ascending: true);
      var players = (response as List<dynamic>).cast<Map<String, dynamic>>();

      // Filtrar por edad en memoria (más flexible que SQL)
      if (filters.minAge != null || filters.maxAge != null) {
        players = _filterByAge(players, filters.minAge, filters.maxAge);
      }

      // Filtrar por valoración en memoria
      if (filters.minRating != null || filters.maxRating != null) {
        players = _filterByRating(
            players, filters.minRating, filters.maxRating);
      }

      // Filtrar por búsqueda en memoria
      if (filters.searchQuery.isNotEmpty) {
        players = _filterBySearch(players, filters.searchQuery);
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
      final response = await _supabase
          .from('vjugadores')
          .select('''
            id, nombre, apellidos, apodo,
            idtemporada, temporada,
            pj, ptitular, plesionado,
            goles, penalti, ta, ta2, tr,
            minutos, valoracion, capitan,
            categoria, equipo
          ''')
          .eq('id', event.jugadorId)
          .order('idtemporada');

      final history = (response as List<dynamic>).cast<Map<String, dynamic>>();

      emit(currentState.copyWith(playerHistory: history));
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

  /// Filtrar jugadores por búsqueda
  List<Map<String, dynamic>> _filterBySearch(
    List<Map<String, dynamic>> players,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return players.where((player) {
      final nombre = (player['nombre'] ?? '').toString().toLowerCase();
      final apellidos = (player['apellidos'] ?? '').toString().toLowerCase();
      final apodo = (player['apodo'] ?? '').toString().toLowerCase();
      final equipo = (player['equipo'] ?? '').toString().toLowerCase();

      return '$nombre $apellidos $apodo'.contains(lowerQuery) ||
          equipo.contains(lowerQuery);
    }).toList();
  }
}
