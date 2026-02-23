import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/players_bloc.dart';
import '../../bloc/players_event.dart';
import '../../bloc/players_state.dart';
import '../widgets/players_grid.dart';
import '../widgets/players_search_bar.dart';
import '../widgets/players_filter_chips.dart';
import '../widgets/players_empty_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/config/app_config_cubit.dart';
import '../../../../../shared/widgets/shared_widgets.dart';

/// Página de gestión de jugadores
///
/// Muestra un listado completo de jugadores del equipo con:
/// - Búsqueda por nombre/dorsal
/// - Filtros por posición
/// - Vista en grid con tarjetas de jugadores
class PlayersPage extends StatefulWidget {
  const PlayersPage({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  late final PlayersBloc _playersBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    // Obtener la temporada activa del AppConfigCubit global
    final activeSeasonId = context.read<AppConfigCubit>().activeSeasonId;
    if (idequipo > 0) {
      _playersBloc.add(PlayersLoadRequested(
        idequipo: idequipo,
        activeSeasonId: activeSeasonId,
      ));
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
    _playersBloc.add(PlayersFilterByPosition(idposicion: idposicion));
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
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFB),
            body: SafeArea(
              child: switch (state) {
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
                    context,
                    players: players,
                    filteredPlayers: filteredPlayers,
                    positions: positions,
                    searchQuery: searchQuery,
                    filterByPosition: filterByPosition,
                  ),
                PlayersError(:final message) => _buildErrorWidget(message),
                _ => const CELoading.inline(),
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context, {
    required List<Map<String, dynamic>> players,
    required List<Map<String, dynamic>> filteredPlayers,
    required Map<int, String> positions,
    required String searchQuery,
    required int? filterByPosition,
  }) {
    final hasActiveFilters = searchQuery.isNotEmpty || filterByPosition != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas
        _buildHeader(players.length),

        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: PlayersSearchBar(
            controller: _searchController,
            onSearch: _onSearch,
            onClear: () => _onSearch(''),
          ),
        ),

        // Filtros por posición
        if (positions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: PlayersFilterChips(
              positions: positions,
              selectedPosition: filterByPosition,
              onPositionSelected: _onPositionFilter,
            ),
          ),

        AppSpacing.vSpaceMd,

        // Indicador de filtros activos
        if (hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
                  label: const Text('Limpiar filtros'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

        AppSpacing.vSpaceMd,

        // Grid de jugadores
        Expanded(
          child: filteredPlayers.isEmpty
              ? PlayersEmptyState(
                  hasFilters: hasActiveFilters,
                  onClearFilters: _clearFilters,
                )
              : PlayersGrid(
                  players: filteredPlayers,
                  positions: positions,
                  onPlayerTap: (player) {
                    // TODO: Navegar al detalle del jugador
                    debugPrint('Jugador seleccionado: ${player['nombre']}');
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalPlayers) {
    return Container(
      padding: const EdgeInsets.all(32),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plantilla',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                AppSpacing.vSpaceXs,
                Text(
                  'Gestiona los jugadores de tu equipo',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // KPIs rápidos
          _buildQuickStat(
            icon: Icons.people,
            value: totalPlayers.toString(),
            label: 'Jugadores',
            color: AppColors.primary,
          ),
          AppSpacing.hSpaceXl,
          _buildQuickStat(
            icon: Icons.add_circle_outline,
            value: 'Añadir',
            label: 'Nuevo',
            color: AppColors.success,
            isButton: true,
            onTap: () {
              // TODO: Navegar a crear jugador
              debugPrint('Crear nuevo jugador');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isButton = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isButton ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isButton ? color : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isButton ? Colors.white : color,
              size: 20,
            ),
            AppSpacing.hSpaceSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.labelMedium.copyWith(
                    color: isButton ? Colors.white : color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: isButton
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
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
