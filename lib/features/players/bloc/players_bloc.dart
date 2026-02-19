import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'players_event.dart';
import 'players_state.dart';
import '../../dashboard/presentation/widgets/dashboard_sidebar.dart';

/// BLoC para gestión de jugadores
class PlayersBloc extends Bloc<PlayersEvent, PlayersState> {
  final SupabaseClient _supabase;

  PlayersBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(const PlayersInitial()) {
    on<PlayersLoadRequested>(_onLoadRequested);
    on<PlayersRefreshRequested>(_onRefreshRequested);
    on<PlayersSearchRequested>(_onSearchRequested);
    on<PlayersFilterByPosition>(_onFilterByPosition);
    on<PlayersClearFilters>(_onClearFilters);
    on<PlayerSelected>(_onPlayerSelected);
  }

  /// Carga inicial de jugadores
  Future<void> _onLoadRequested(
    PlayersLoadRequested event,
    Emitter<PlayersState> emit,
  ) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint('⏱️ [TIMING] 🌐 PlayersBloc._onLoadRequested INICIO: $startTime ms');

    emit(const PlayersLoading());

    try {
      // Ejecutar AMBAS queries en PARALELO
      final queryStart = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] 🌐 Iniciando queries en PARALELO (idequipo=${event.idequipo}): $queryStart ms');

      final results = await Future.wait([
        _supabase
            .from('tjugadores')
            .select('id, nombre, apellidos, dorsal, idposicion, fechanacimiento, foto, idequipo')
            .eq('idequipo', event.idequipo)
            .order('dorsal')
            .order('nombre')
            .order('apellidos'),
        _supabase.from('tposiciones').select('id, posicion'),
      ]);

      final queryEnd = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] 🌐 Queries PARALELAS COMPLETADAS: $queryEnd ms | ⚡ Duración: ${queryEnd - queryStart}ms');

      final jugadoresResponse = results[0];
      final positionsData = results[1];

      // Crear mapa de posiciones
      final positionsMap = <int, String>{};
      for (final pos in positionsData) {
        positionsMap[pos['id'] as int] = pos['posicion'] as String;
      }

      final players = (jugadoresResponse as List<dynamic>).cast<Map<String, dynamic>>().toList();

      final emitTime = DateTime.now().millisecondsSinceEpoch;
      if (playersClickTimestamp != null) {
        final totalTime = emitTime - playersClickTimestamp!;
        debugPrint('⏱️ [TIMING] ✅ PlayersBloc EMIT PlayersLoaded: $emitTime ms');
        debugPrint('⏱️ [TIMING] 🎯 ========================================');
        debugPrint('⏱️ [TIMING] 🎯 TIEMPO TOTAL DESDE CLICK: ${totalTime}ms');
        debugPrint('⏱️ [TIMING] 🎯 ========================================');
      } else {
        debugPrint('⏱️ [TIMING] ✅ PlayersBloc EMIT PlayersLoaded: $emitTime ms (${players.length} jugadores)');
      }

      emit(PlayersLoaded(
        players: players,
        filteredPlayers: players,
        positions: positionsMap,
      ));
    } catch (e) {
      final errorTime = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] ❌ PlayersBloc ERROR: $errorTime ms | Error: $e');
      emit(PlayersError(message: e.toString()));
    }
  }

  /// Refrescar datos
  Future<void> _onRefreshRequested(
    PlayersRefreshRequested event,
    Emitter<PlayersState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    int? currentPosition;

    if (currentState is PlayersLoaded) {
      currentSearch = currentState.searchQuery;
      currentPosition = currentState.filterByPosition;
    }

    try {
      final results = await Future.wait([
        _supabase
            .from('tjugadores')
            .select('id, nombre, apellidos, dorsal, idposicion, fechanacimiento, foto, idequipo')
            .eq('idequipo', event.idequipo)
            .order('dorsal')
            .order('nombre')
            .order('apellidos'),
        _supabase.from('tposiciones').select('id, posicion'),
      ]);

      final playersData = results[0] as List<dynamic>;
      final positionsData = results[1] as List<dynamic>;

      final positionsMap = <int, String>{};
      for (final pos in positionsData) {
        positionsMap[pos['id'] as int] = pos['posicion'] as String;
      }

      final players = playersData.cast<Map<String, dynamic>>().toList();

      // Aplicar filtros anteriores
      var filteredPlayers = players;

      if (currentSearch.isNotEmpty) {
        filteredPlayers = _filterBySearch(filteredPlayers, currentSearch);
      }

      if (currentPosition != null) {
        filteredPlayers = _filterByPositionId(filteredPlayers, currentPosition);
      }

      emit(PlayersLoaded(
        players: players,
        filteredPlayers: filteredPlayers,
        positions: positionsMap,
        searchQuery: currentSearch,
        filterByPosition: currentPosition,
      ));
    } catch (e) {
      emit(PlayersError(message: e.toString()));
    }
  }

  /// Búsqueda de jugadores
  void _onSearchRequested(
    PlayersSearchRequested event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is! PlayersLoaded) return;

    var filteredPlayers = currentState.players;

    // Filtrar por búsqueda
    if (event.query.isNotEmpty) {
      filteredPlayers = _filterBySearch(filteredPlayers, event.query);
    }

    // Mantener filtro de posición si existe
    if (currentState.filterByPosition != null) {
      filteredPlayers = _filterByPositionId(filteredPlayers, currentState.filterByPosition!);
    }

    emit(currentState.copyWith(
      filteredPlayers: filteredPlayers,
      searchQuery: event.query,
    ));
  }

  /// Filtrar por posición
  void _onFilterByPosition(
    PlayersFilterByPosition event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is! PlayersLoaded) return;

    var filteredPlayers = currentState.players;

    // Filtrar por posición
    if (event.idposicion != null) {
      filteredPlayers = _filterByPositionId(filteredPlayers, event.idposicion!);
    }

    // Mantener búsqueda si existe
    if (currentState.searchQuery.isNotEmpty) {
      filteredPlayers = _filterBySearch(filteredPlayers, currentState.searchQuery);
    }

    emit(currentState.copyWith(
      filteredPlayers: filteredPlayers,
      filterByPosition: event.idposicion,
    ));
  }

  /// Limpiar filtros
  void _onClearFilters(
    PlayersClearFilters event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is! PlayersLoaded) return;

    emit(currentState.copyWith(
      filteredPlayers: currentState.players,
      searchQuery: '',
      filterByPosition: null,
    ));
  }

  /// Selección de jugador
  void _onPlayerSelected(
    PlayerSelected event,
    Emitter<PlayersState> emit,
  ) {
    // Por ahora solo notifica, en el futuro puede navegar al detalle
    // La navegación se maneja en la UI
  }

  /// Filtra jugadores por texto de búsqueda
  List<Map<String, dynamic>> _filterBySearch(
    List<Map<String, dynamic>> players,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return players.where((player) {
      final nombre = (player['nombre'] ?? '').toString().toLowerCase();
      final apellidos = (player['apellidos'] ?? '').toString().toLowerCase();
      final dorsal = (player['dorsal'] ?? '').toString();
      return '$nombre $apellidos'.contains(lowerQuery) || dorsal.contains(lowerQuery);
    }).toList();
  }

  /// Filtra jugadores por ID de posición
  List<Map<String, dynamic>> _filterByPositionId(
    List<Map<String, dynamic>> players,
    int idposicion,
  ) {
    return players.where((player) {
      return player['idposicion'] == idposicion;
    }).toList();
  }
}
