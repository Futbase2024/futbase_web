import 'package:equatable/equatable.dart';

/// Filtros de scouting
class ScoutingFilters extends Equatable {
  final int? idtemporada;
  final Set<int> idposiciones;
  final Set<int> idcategorias;
  final int? idpiedominante;
  final int? minAge;
  final int? maxAge;
  final int? minRating;
  final int? maxRating;
  final String searchQuery;

  const ScoutingFilters({
    this.idtemporada,
    this.idposiciones = const {},
    this.idcategorias = const {},
    this.idpiedominante,
    this.minAge,
    this.maxAge,
    this.minRating,
    this.maxRating,
    this.searchQuery = '',
  });

  bool get hasActiveFilters =>
      idtemporada != null ||
      idposiciones.isNotEmpty ||
      idcategorias.isNotEmpty ||
      idpiedominante != null ||
      minAge != null ||
      maxAge != null ||
      minRating != null ||
      maxRating != null ||
      searchQuery.isNotEmpty;

  ScoutingFilters copyWith({
    int? idtemporada,
    bool clearTemporada = false,
    Set<int>? idposiciones,
    Set<int>? idcategorias,
    int? idpiedominante,
    bool clearPie = false,
    int? minAge,
    int? maxAge,
    bool clearAge = false,
    int? minRating,
    int? maxRating,
    bool clearRating = false,
    String? searchQuery,
  }) {
    return ScoutingFilters(
      idtemporada: clearTemporada ? null : (idtemporada ?? this.idtemporada),
      idposiciones: idposiciones ?? this.idposiciones,
      idcategorias: idcategorias ?? this.idcategorias,
      idpiedominante: clearPie ? null : (idpiedominante ?? this.idpiedominante),
      minAge: clearAge ? null : (minAge ?? this.minAge),
      maxAge: clearAge ? null : (maxAge ?? this.maxAge),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      maxRating: clearRating ? null : (maxRating ?? this.maxRating),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        idtemporada,
        idposiciones,
        idcategorias,
        idpiedominante,
        minAge,
        maxAge,
        minRating,
        maxRating,
        searchQuery,
      ];
}

/// Estados del BLoC de Scouting
abstract class ScoutingState extends Equatable {
  const ScoutingState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ScoutingInitial extends ScoutingState {
  const ScoutingInitial();
}

/// Estado cargando datos maestros
class ScoutingLoading extends ScoutingState {
  const ScoutingLoading();
}

/// Estado con datos cargados
class ScoutingLoaded extends ScoutingState {
  /// Lista completa de jugadores
  final List<Map<String, dynamic>> players;

  /// Jugadores filtrados
  final List<Map<String, dynamic>> filteredPlayers;

  /// Filtros activos
  final ScoutingFilters filters;

  /// Datos maestros
  final Map<int, String> temporadas;
  final Map<int, String> posiciones;
  final Map<int, String> categorias;
  final Map<int, String> pies;

  /// Paginación
  final int currentPage;
  final int itemsPerPage;
  final int totalCount;

  /// Jugador seleccionado para detalle
  final Map<String, dynamic>? selectedPlayer;

  /// Historial del jugador seleccionado (por temporada)
  final List<Map<String, dynamic>>? playerHistory;

  /// Jugadores en comparador (máximo 3)
  final List<Map<String, dynamic>> comparisonPlayers;

  /// Club del usuario actual (para filtrar)
  final int? userClubId;

  /// Si el usuario es super admin (puede ver todos los clubs)
  final bool isSuperAdmin;

  /// Si se están cargando los jugadores
  final bool isLoadingPlayers;

  const ScoutingLoaded({
    required this.players,
    required this.filteredPlayers,
    required this.filters,
    required this.temporadas,
    required this.posiciones,
    required this.categorias,
    required this.pies,
    this.currentPage = 0,
    this.itemsPerPage = 20,
    this.totalCount = 0,
    this.selectedPlayer,
    this.playerHistory,
    this.comparisonPlayers = const [],
    this.userClubId,
    this.isSuperAdmin = false,
    this.isLoadingPlayers = false,
  });

  /// Jugadores de la página actual
  List<Map<String, dynamic>> get paginatedPlayers {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= filteredPlayers.length) return [];
    return filteredPlayers.sublist(
      start,
      end > filteredPlayers.length ? filteredPlayers.length : end,
    );
  }

  /// Total de páginas
  int get totalPages => (filteredPlayers.length / itemsPerPage).ceil();

  /// Si puede añadir más al comparador
  bool get canAddToComparison => comparisonPlayers.length < 3;

  @override
  List<Object?> get props => [
        players,
        filteredPlayers,
        filters,
        temporadas,
        posiciones,
        categorias,
        pies,
        currentPage,
        itemsPerPage,
        totalCount,
        selectedPlayer,
        playerHistory,
        comparisonPlayers,
        userClubId,
        isSuperAdmin,
        isLoadingPlayers,
      ];

  ScoutingLoaded copyWith({
    List<Map<String, dynamic>>? players,
    List<Map<String, dynamic>>? filteredPlayers,
    ScoutingFilters? filters,
    Map<int, String>? temporadas,
    Map<int, String>? posiciones,
    Map<int, String>? categorias,
    Map<int, String>? pies,
    int? currentPage,
    int? itemsPerPage,
    int? totalCount,
    Map<String, dynamic>? selectedPlayer,
    bool clearSelectedPlayer = false,
    List<Map<String, dynamic>>? playerHistory,
    bool clearPlayerHistory = false,
    List<Map<String, dynamic>>? comparisonPlayers,
    int? userClubId,
    bool? isSuperAdmin,
    bool? isLoadingPlayers,
  }) {
    return ScoutingLoaded(
      players: players ?? this.players,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      filters: filters ?? this.filters,
      temporadas: temporadas ?? this.temporadas,
      posiciones: posiciones ?? this.posiciones,
      categorias: categorias ?? this.categorias,
      pies: pies ?? this.pies,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalCount: totalCount ?? this.totalCount,
      selectedPlayer:
          clearSelectedPlayer ? null : (selectedPlayer ?? this.selectedPlayer),
      playerHistory:
          clearPlayerHistory ? null : (playerHistory ?? this.playerHistory),
      comparisonPlayers: comparisonPlayers ?? this.comparisonPlayers,
      userClubId: userClubId ?? this.userClubId,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      isLoadingPlayers: isLoadingPlayers ?? this.isLoadingPlayers,
    );
  }
}

/// Estado de error
class ScoutingError extends ScoutingState {
  final String message;

  const ScoutingError({required this.message});

  @override
  List<Object?> get props => [message];
}
