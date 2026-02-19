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
  final String searchQuery;
  final int? filterByPosition;
  final int totalPlayers;

  const PlayersLoaded({
    required this.players,
    required this.filteredPlayers,
    required this.positions,
    this.searchQuery = '',
    this.filterByPosition,
  }) : totalPlayers = players.length;

  @override
  List<Object?> get props => [
        players,
        filteredPlayers,
        positions,
        searchQuery,
        filterByPosition,
        totalPlayers,
      ];

  /// Copia con nuevos valores
  /// Usa _unset como valor por defecto para permitir establecer null
  PlayersLoaded copyWith({
    List<Map<String, dynamic>>? players,
    List<Map<String, dynamic>>? filteredPlayers,
    Map<int, String>? positions,
    Object? searchQuery = _unset,
    Object? filterByPosition = _unset,
  }) {
    return PlayersLoaded(
      players: players ?? this.players,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      positions: positions ?? this.positions,
      searchQuery: searchQuery == _unset
          ? this.searchQuery
          : searchQuery as String,
      filterByPosition: filterByPosition == _unset
          ? this.filterByPosition
          : filterByPosition as int?,
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
