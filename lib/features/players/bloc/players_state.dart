import 'package:equatable/equatable.dart';

/// Valor sentinel para indicar "no cambiar" en copyWith
const _unset = Object();

/// Estados del BLoC de jugadores
abstract class PlayersState extends Equatable {
  const PlayersState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PlayersInitial extends PlayersState {
  const PlayersInitial();
}

/// Estado de carga
class PlayersLoading extends PlayersState {
  const PlayersLoading();
}

/// Estado con datos cargados
class PlayersLoaded extends PlayersState {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> filteredPlayers;
  final Map<int, String> positions;
  final Map<int, String> teams;
  final String searchQuery;
  final int? filterByPosition;
  final int? filterByTeam;
  final bool showInactive;
  final int totalPlayers;

  const PlayersLoaded({
    required this.players,
    required this.filteredPlayers,
    required this.positions,
    this.teams = const {},
    this.searchQuery = '',
    this.filterByPosition,
    this.filterByTeam,
    this.showInactive = false,
  }) : totalPlayers = players.length;

  @override
  List<Object?> get props => [
        players,
        filteredPlayers,
        positions,
        teams,
        searchQuery,
        filterByPosition,
        filterByTeam,
        showInactive,
        totalPlayers,
      ];

  /// Copia con nuevos valores
  /// Usa _unset como valor por defecto para permitir establecer null
  PlayersLoaded copyWith({
    List<Map<String, dynamic>>? players,
    List<Map<String, dynamic>>? filteredPlayers,
    Map<int, String>? positions,
    Map<int, String>? teams,
    Object? searchQuery = _unset,
    Object? filterByPosition = _unset,
    Object? filterByTeam = _unset,
    bool? showInactive,
  }) {
    return PlayersLoaded(
      players: players ?? this.players,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      positions: positions ?? this.positions,
      teams: teams ?? this.teams,
      searchQuery: searchQuery == _unset
          ? this.searchQuery
          : searchQuery as String,
      filterByPosition: filterByPosition == _unset
          ? this.filterByPosition
          : filterByPosition as int?,
      filterByTeam: filterByTeam == _unset
          ? this.filterByTeam
          : filterByTeam as int?,
      showInactive: showInactive ?? this.showInactive,
    );
  }
}

/// Estado de error
class PlayersError extends PlayersState {
  final String message;

  const PlayersError({required this.message});

  @override
  List<Object?> get props => [message];
}
