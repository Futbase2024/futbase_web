import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/players_bloc.dart';
import '../../bloc/players_event.dart';
import '../../bloc/players_state.dart';
import 'players_grid.dart';
import 'players_search_bar.dart';
import 'players_filter_chips.dart';
import 'players_empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../dashboard/presentation/widgets/dashboard_sidebar.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Contenido de jugadores para integrar en el dashboard
///
/// Widget que muestra la gestión de jugadores sin Scaffold
/// para ser usado dentro del layout del dashboard
class PlayersContent extends StatefulWidget {
  const PlayersContent({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<PlayersContent> createState() => _PlayersContentState();
}

class _PlayersContentState extends State<PlayersContent> {
  late final PlayersBloc _playersBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Log de timing: initState de PlayersContent
    final now = DateTime.now().millisecondsSinceEpoch;
    if (playersClickTimestamp != null) {
      final elapsed = now - playersClickTimestamp!;
      debugPrint('⏱️ [TIMING] 📦 PlayersContent.initState: $now ms | ⚡ Transcurrido desde click: ${elapsed}ms');
    } else {
      debugPrint('⏱️ [TIMING] 📦 PlayersContent.initState: $now ms (sin timestamp de click)');
    }

    _playersBloc = PlayersBloc();
    _loadPlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _playersBloc.close();
    super.dispose();
  }

  void _loadPlayers() {
    final idequipo = widget.user.idequipo;
    if (idequipo > 0) {
      _playersBloc.add(PlayersLoadRequested(idequipo: idequipo));
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _playersBloc.add(const PlayersClearFilters());
    } else {
      _playersBloc.add(PlayersSearchRequested(
        idequipo: widget.user.idequipo,
        query: query,
      ));
    }
  }

  void _onPositionFilter(int? idposicion) {
    // Si es null (Todos), limpiar también la búsqueda
    if (idposicion == null) {
      _searchController.clear();
      _playersBloc.add(const PlayersClearFilters());
    } else {
      _playersBloc.add(PlayersFilterByPosition(idposicion: idposicion));
    }
  }

  void _clearFilters() {
    _searchController.clear();
    _playersBloc.add(const PlayersClearFilters());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _playersBloc,
      child: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          return switch (state) {
            PlayersInitial() => const CELoading.inline(),
            PlayersLoading() => const CELoading.inline(),
            PlayersLoaded(
              :final players,
              :final filteredPlayers,
              :final positions,
              :final searchQuery,
              :final filterByPosition,
            ) =>
              _buildLoadedContent(
                players: players,
                filteredPlayers: filteredPlayers,
                positions: positions,
                searchQuery: searchQuery,
                filterByPosition: filterByPosition,
              ),
            PlayersError(:final message) => _buildErrorWidget(message),
            _ => const CELoading.inline(),
          };
        },
      ),
    );
  }

  Widget _buildLoadedContent({
    required List<Map<String, dynamic>> players,
    required List<Map<String, dynamic>> filteredPlayers,
    required Map<int, String> positions,
    required String searchQuery,
    required int? filterByPosition,
  }) {
    final hasActiveFilters = searchQuery.isNotEmpty || filterByPosition != null;

    return CustomScrollView(
      slivers: [
        // Header fijo
        SliverToBoxAdapter(
          child: _buildHeader(players.length),
        ),

        // Barra de búsqueda
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
            child: PlayersSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onClear: () => _onSearch(''),
            ),
          ),
        ),

        // Filtros por posición
        if (positions.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: PlayersFilterChips(
                positions: positions,
                selectedPosition: filterByPosition,
                onPositionSelected: _onPositionFilter,
              ),
            ),
          ),

        // Indicador de filtros activos
        if (hasActiveFilters)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${filteredPlayers.length} de ${players.length} jugadores',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpiar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Espacio antes del grid
        const SliverToBoxAdapter(
          child: SizedBox(height: 8),
        ),

        // Grid de jugadores o estado vacío
        filteredPlayers.isEmpty
            ? SliverFillRemaining(
                child: PlayersEmptyState(
                  hasFilters: hasActiveFilters,
                  onClearFilters: _clearFilters,
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final player = filteredPlayers[index];
                      final position = _getPositionName(
                        player['idposicion'],
                        positions,
                      );
                      return PlayerCard(
                        player: player,
                        position: position,
                        onTap: () {
                          debugPrint('Jugador: ${player['nombre']}');
                        },
                      );
                    },
                    childCount: filteredPlayers.length,
                  ),
                ),
              ),

        // Espacio final
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  String _getPositionName(dynamic idposicion, Map<int, String> positions) {
    if (idposicion == null) return '';
    final id = idposicion is int ? idposicion : int.tryParse(idposicion.toString());
    if (id == null) return '';
    return positions[id] ?? '';
  }

  Widget _buildHeader(int totalPlayers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Título
          Text(
            'Plantilla',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),

          const Spacer(),

          // Contador de jugadores
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                AppSpacing.hSpaceXs,
                Text(
                  '$totalPlayers jugadores',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSpaceMd,

          // Botón Añadir
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar a crear jugador
              debugPrint('Crear nuevo jugador');
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          AppSpacing.vSpaceMd,
          Text(
            'Error al cargar jugadores',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
            ),
          ),
          AppSpacing.vSpaceSm,
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSpaceMd,
          ElevatedButton.icon(
            onPressed: _loadPlayers,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
