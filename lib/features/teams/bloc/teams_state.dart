import 'package:equatable/equatable.dart';

/// Valor sentinel para indicar "no cambiar" en copyWith
const _unset = Object();

/// Estados del BLoC de equipos
abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TeamsInitial extends TeamsState {
  const TeamsInitial();
}

/// Estado de carga
class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

/// Estado con datos cargados
class TeamsLoaded extends TeamsState {
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> filteredTeams;
  final Map<int, String> categories;
  final Map<int, String> seasons;
  final String searchQuery;
  final int? filterByCategory;
  final int? filterBySeason;
  final int totalTeams;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final int idclub;
  final int activeSeasonId;

  const TeamsLoaded({
    required this.teams,
    required this.filteredTeams,
    required this.categories,
    required this.seasons,
    required this.idclub,
    required this.activeSeasonId,
    this.searchQuery = '',
    this.filterByCategory,
    this.filterBySeason,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  }) : totalTeams = teams.length;

  @override
  List<Object?> get props => [
        teams,
        filteredTeams,
        categories,
        seasons,
        searchQuery,
        filterByCategory,
        filterBySeason,
        totalTeams,
        isCreating,
        isUpdating,
        isDeleting,
        idclub,
        activeSeasonId,
      ];

  /// Copia con nuevos valores
  /// Usa _unset como valor por defecto para permitir establecer null
  TeamsLoaded copyWith({
    List<Map<String, dynamic>>? teams,
    List<Map<String, dynamic>>? filteredTeams,
    Map<int, String>? categories,
    Map<int, String>? seasons,
    Object? searchQuery = _unset,
    Object? filterByCategory = _unset,
    Object? filterBySeason = _unset,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    int? idclub,
    int? activeSeasonId,
  }) {
    return TeamsLoaded(
      teams: teams ?? this.teams,
      filteredTeams: filteredTeams ?? this.filteredTeams,
      categories: categories ?? this.categories,
      seasons: seasons ?? this.seasons,
      searchQuery: searchQuery == _unset
          ? this.searchQuery
          : searchQuery as String,
      filterByCategory: filterByCategory == _unset
          ? this.filterByCategory
          : filterByCategory as int?,
      filterBySeason: filterBySeason == _unset
          ? this.filterBySeason
          : filterBySeason as int?,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      idclub: idclub ?? this.idclub,
      activeSeasonId: activeSeasonId ?? this.activeSeasonId,
    );
  }
}

/// Estado de error
class TeamsError extends TeamsState {
  final String message;

  const TeamsError({required this.message});

  @override
  List<Object?> get props => [message];
}
