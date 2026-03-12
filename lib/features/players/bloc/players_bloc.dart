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
    on<PlayersFilterByTeam>(_onFilterByTeam);
    on<PlayersClearFilters>(_onClearFilters);
    on<PlayerSelected>(_onPlayerSelected);
    on<PlayersNoTeamEvent>(_onNoTeam);
    on<PlayersToggleInactive>(_onToggleInactive);
  }

  /// Carga inicial de jugadores
  /// Si loadByClub es true, carga todos los jugadores del club
  /// Si loadByClub es false, carga los jugadores de un equipo específico
  Future<void> _onLoadRequested(
    PlayersLoadRequested event,
    Emitter<PlayersState> emit,
  ) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint('⏱️ [TIMING] 🌐 PlayersBloc._onLoadRequested INICIO: $startTime ms');

    emit(const PlayersLoading());

    try {
      final queryStart = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] 🌐 Iniciando queries (loadByClub=${event.loadByClub}, idclub=${event.idclub}, idequipo=${event.idequipo}): $queryStart ms');

      // Usar la temporada activa del evento (viene del AppConfigCubit global)
      final activeSeasonId = event.activeSeasonId;
      debugPrint('⏱️ [TIMING] 🗓️ Temporada activa: $activeSeasonId');

      // Cargar jugadores desde la vista vjugadores (une tjugadores + testadisticasjugador)
      // Por defecto solo activos (activo = 1) y de la temporada activa
      List<dynamic> jugadoresResponse;
      if (event.loadByClub && event.idclub != null) {
        // Cargar todos los jugadores del club (solo activos y de la temporada activa)
        jugadoresResponse = await _supabase
            .from('vjugadores')
            .select('id, nombre, apellidos, dorsal, idposicion, fechanacimiento, foto, idequipo, activo, idclub')
            .eq('idclub', event.idclub!)
            .eq('activo', 1)
            .eq('idtemporada', activeSeasonId)
            .eq('visible', 1)
            .order('nombre')
            .order('apellidos');
      } else if (event.idequipo != null) {
        // Cargar jugadores de un equipo específico (solo activos y de la temporada activa)
        jugadoresResponse = await _supabase
            .from('vjugadores')
            .select('id, nombre, apellidos, dorsal, idposicion, fechanacimiento, foto, idequipo, activo, idclub')
            .eq('idequipo', event.idequipo!)
            .eq('activo', 1)
            .eq('idtemporada', activeSeasonId)
            .eq('visible', 1)
            .order('nombre')
            .order('apellidos');
      } else {
        // Sin filtro válido
        emit(const PlayersError(
          message: 'No se especificó club ni equipo para cargar jugadores.',
        ));
        return;
      }

      // Cargar posiciones
      final positionsData = await _supabase.from('tposiciones').select('id, posicion');

      // Cargar equipos si es club/coordinador
      Map<int, String> teamsMap = {};
      if (event.loadByClub && event.idclub != null) {
        final teamsData = await _supabase
            .from('tequipos')
            .select('id, equipo')
            .eq('idclub', event.idclub!)
            .order('equipo');
        for (final team in teamsData) {
          teamsMap[team['id'] as int] = team['equipo'] as String;
        }
      }

      final queryEnd = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] 🌐 Queries COMPLETADAS: $queryEnd ms | ⚡ Duración: ${queryEnd - queryStart}ms');

      // Crear mapa de posiciones
      final positionsMap = <int, String>{};
      for (final pos in positionsData) {
        positionsMap[pos['id'] as int] = pos['posicion'] as String;
      }

      final players = jugadoresResponse.cast<Map<String, dynamic>>().toList();

      // Ordenar por nombre y apellidos (case-insensitive)
      _sortPlayers(players);

      // Deduplicar por nombre+apellidos (case-insensitive)
      final deduplicatedPlayers = _deduplicatePlayers(players);

      if (players.length != deduplicatedPlayers.length) {
        debugPrint('⚠️ [PLAYERS] DEDUPLICADOS: ${players.length} → ${deduplicatedPlayers.length} jugadores');
      }

      final emitTime = DateTime.now().millisecondsSinceEpoch;
      if (playersClickTimestamp != null) {
        final totalTime = emitTime - playersClickTimestamp!;
        debugPrint('⏱️ [TIMING] ✅ PlayersBloc EMIT PlayersLoaded: $emitTime ms');
        debugPrint('⏱️ [TIMING] 🎯 ========================================');
        debugPrint('⏱️ [TIMING] 🎯 TIEMPO TOTAL DESDE CLICK: ${totalTime}ms');
        debugPrint('⏱️ [TIMING] 🎯 ========================================');
      } else {
        debugPrint('⏱️ [TIMING] ✅ PlayersBloc EMIT PlayersLoaded: $emitTime ms (${deduplicatedPlayers.length} jugadores)');
      }

      emit(PlayersLoaded(
        players: deduplicatedPlayers,
        filteredPlayers: deduplicatedPlayers,
        positions: positionsMap,
        teams: teamsMap,
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

      // Ordenar por nombre y apellidos (case-insensitive)
      _sortPlayers(players);

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

    // Mantener filtro de equipo si existe
    if (currentState.filterByTeam != null) {
      filteredPlayers = _filterByTeamId(filteredPlayers, currentState.filterByTeam!);
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

  /// Filtrar por equipo
  void _onFilterByTeam(
    PlayersFilterByTeam event,
    Emitter<PlayersState> emit,
  ) {
    final currentState = state;
    if (currentState is! PlayersLoaded) return;

    var filteredPlayers = currentState.players;

    // Filtrar por equipo
    if (event.idequipo != null) {
      filteredPlayers = _filterByTeamId(filteredPlayers, event.idequipo!);
    }

    // Mantener filtro de posición si existe
    if (currentState.filterByPosition != null) {
      filteredPlayers = _filterByPositionId(filteredPlayers, currentState.filterByPosition!);
    }

    // Mantener búsqueda si existe
    if (currentState.searchQuery.isNotEmpty) {
      filteredPlayers = _filterBySearch(filteredPlayers, currentState.searchQuery);
    }

    emit(currentState.copyWith(
      filteredPlayers: filteredPlayers,
      filterByTeam: event.idequipo,
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
      filterByTeam: null,
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

  /// Maneja el caso cuando el usuario no tiene equipo asignado
  void _onNoTeam(
    PlayersNoTeamEvent event,
    Emitter<PlayersState> emit,
  ) {
    emit(const PlayersError(
      message: 'No tienes un equipo asignado. Contacta con el administrador.',
    ));
  }

  /// Toggle para mostrar/ocultar jugadores inactivos
  Future<void> _onToggleInactive(
    PlayersToggleInactive event,
    Emitter<PlayersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PlayersLoaded) return;

    // Recargar datos con el nuevo filtro
    final showInactive = event.showInactive;
    final activeSeasonId = event.activeSeasonId;

    try {
      List<dynamic> jugadoresResponse;

      // Determinar el filtro basado en el estado anterior
      final firstPlayer = currentState.players.isNotEmpty ? currentState.players.first : null;

      if (currentState.teams.isNotEmpty && firstPlayer != null) {
        // Era carga por club - necesitamos el idclub
        // Recargar desde vjugadores sin filtro de activo, pero con temporada
        final allPlayers = await _supabase
            .from('vjugadores')
            .select('id, nombre, apellidos, dorsal, idposicion, fechanacimiento, foto, idequipo, activo, idclub')
            .eq('idclub', currentState.players.first['idclub'] ?? 0)
            .eq('idtemporada', activeSeasonId)
            .eq('visible', 1)
            .order('nombre')
            .order('apellidos');
        jugadoresResponse = allPlayers;
      } else if (currentState.players.isNotEmpty) {
        // Era carga por equipo
        final idequipo = currentState.players.first['idequipo'];
        final allPlayers = await _supabase
            .from('vjugadores')
            .select('id, nombre, apellidos, dorsal, idposicion, fechanacimiento, foto, idequipo, activo, idclub')
            .eq('idequipo', idequipo)
            .eq('idtemporada', activeSeasonId)
            .eq('visible', 1)
            .order('nombre')
            .order('apellidos');
        jugadoresResponse = allPlayers;
      } else {
        return;
      }

      final allPlayersList = jugadoresResponse.cast<Map<String, dynamic>>().toList();

      // Ordenar por nombre y apellidos (case-insensitive)
      _sortPlayers(allPlayersList);

      // Deduplicar por nombre+apellidos
      final deduplicatedList = _deduplicatePlayers(allPlayersList);

      // Filtrar por activo según el toggle
      // showInactive=false -> Solo activos (activo=1)
      // showInactive=true -> Solo inactivos (activo=0)
      var filteredByActive = showInactive
          ? deduplicatedList.where((p) => p['activo'] == 0).toList()
          : deduplicatedList.where((p) => p['activo'] == 1).toList();

      // Aplicar filtros existentes
      var filteredPlayers = filteredByActive;

      if (currentState.filterByPosition != null) {
        filteredPlayers = _filterByPositionId(filteredPlayers, currentState.filterByPosition!);
      }

      if (currentState.filterByTeam != null) {
        filteredPlayers = _filterByTeamId(filteredPlayers, currentState.filterByTeam!);
      }

      if (currentState.searchQuery.isNotEmpty) {
        filteredPlayers = _filterBySearch(filteredPlayers, currentState.searchQuery);
      }

      emit(PlayersLoaded(
        players: filteredByActive,
        filteredPlayers: filteredPlayers,
        positions: currentState.positions,
        teams: currentState.teams,
        searchQuery: currentState.searchQuery,
        filterByPosition: currentState.filterByPosition,
        filterByTeam: currentState.filterByTeam,
        showInactive: showInactive,
      ));
    } catch (e) {
      debugPrint('Error toggling inactive: $e');
    }
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

  /// Ordena jugadores por nombre y apellidos (case-insensitive)
  void _sortPlayers(List<Map<String, dynamic>> players) {
    players.sort((a, b) {
      final nombreA = ((a['nombre'] ?? '') as String).trim().toLowerCase();
      final nombreB = ((b['nombre'] ?? '') as String).trim().toLowerCase();
      final apellidosA = ((a['apellidos'] ?? '') as String).trim().toLowerCase();
      final apellidosB = ((b['apellidos'] ?? '') as String).trim().toLowerCase();

      // Primero comparar por nombre
      final nombreCompare = nombreA.compareTo(nombreB);
      if (nombreCompare != 0) return nombreCompare;

      // Si los nombres son iguales, comparar por apellidos
      return apellidosA.compareTo(apellidosB);
    });
  }

  /// Deduplica jugadores por nombre+apellidos (case-insensitive, ignorando espacios)
  /// Mantiene solo el primer jugador encontrado para cada combinación de nombre+apellidos
  List<Map<String, dynamic>> _deduplicatePlayers(List<Map<String, dynamic>> players) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final player in players) {
      final nombre = ((player['nombre'] ?? '') as String).trim().toLowerCase();
      final apellidos = ((player['apellidos'] ?? '') as String).trim().toLowerCase();
      final key = '$nombre|$apellidos';

      if (!seen.contains(key)) {
        seen.add(key);
        result.add(player);
      }
    }

    return result;
  }

  /// Filtra jugadores por ID de equipo
  List<Map<String, dynamic>> _filterByTeamId(
    List<Map<String, dynamic>> players,
    int idequipo,
  ) {
    return players.where((player) {
      return player['idequipo'] == idequipo;
    }).toList();
  }
}
