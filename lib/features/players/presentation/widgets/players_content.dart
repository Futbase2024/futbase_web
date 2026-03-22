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
import 'players_filter_dialog.dart';
import '../../../player_profile/player_profile_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/config/app_config_cubit.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Contenido de jugadores para integrar en el dashboard
///
/// Widget que muestra la gestión de jugadores sin Scaffold
/// para ser usado dentro del layout del dashboard
class PlayersContent extends StatefulWidget {
  const PlayersContent({
    super.key,
    required this.user,
    required this.userRole,
  });

  final UsuariosEntity user;
  final UserRole userRole;

  @override
  State<PlayersContent> createState() => _PlayersContentState();
}

class _PlayersContentState extends State<PlayersContent> {
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
    final user = widget.user;
    final role = widget.userRole;
    final idclub = user.idclub;
    final idequipo = user.idequipo;

    // Obtener la temporada activa del AppConfigCubit global
    final appConfigCubit = context.read<AppConfigCubit>();
    final activeSeasonId = appConfigCubit.activeSeasonId;

    debugPrint('⏱️ [TIMING] 📦 PlayersContent._loadPlayers: role=$role, idclub=$idclub, idequipo=$idequipo, temporada=$activeSeasonId');

    // Club y Coordinador ven todos los jugadores del club
    if (role == UserRole.club || role == UserRole.coordinador) {
      if (idclub > 0) {
        _playersBloc.add(PlayersLoadRequested(
          idclub: idclub,
          loadByClub: true,
          activeSeasonId: activeSeasonId,
        ));
      } else {
        debugPrint('⏱️ [TIMING] ❌ PlayersContent: Usuario sin club asignado (idclub=$idclub)');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _playersBloc.add(const PlayersNoTeamEvent());
          }
        });
      }
    } else {
      // Entrenador ve solo los jugadores de su equipo
      if (idequipo > 0) {
        _playersBloc.add(PlayersLoadRequested(
          idequipo: idequipo,
          idclub: idclub, // Pasar idclub para evitar consulta adicional al endpoint
          activeSeasonId: activeSeasonId,
        ));
      } else {
        debugPrint('⏱️ [TIMING] ❌ PlayersContent: Usuario sin equipo asignado (idequipo=$idequipo)');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _playersBloc.add(const PlayersNoTeamEvent());
          }
        });
      }
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

  /// Muestra el perfil de un jugador en un diálogo del 90% de la pantalla
  Future<void> _showPlayerProfile(Map<String, dynamic> player) async {
    final playerId = player['id'];
    if (playerId == null) return;

    final id = playerId is int ? playerId : int.tryParse(playerId.toString());
    if (id == null) return;

    // Mostrar diálogo del perfil
    await PlayerProfileDialog.show(
      context,
      playerId: id,
      playerData: player,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _playersBloc,
      child: BlocListener<AppConfigCubit, AppConfigState>(
        listenWhen: (previous, current) =>
            previous.activeSeasonId != current.activeSeasonId,
        listener: (context, configState) {
          // Recargar jugadores cuando cambia la temporada
          debugPrint('🗓️ [PLAYERS] Temporada cambiada a: ${configState.activeSeasonName}');
          _loadPlayers();
        },
        child: BlocBuilder<PlayersBloc, PlayersState>(
          builder: (context, state) {
            return switch (state) {
              PlayersInitial() => const CELoading.inline(),
              PlayersLoading() => const CELoading.inline(),
              PlayersLoaded(
                :final players,
                :final filteredPlayers,
                :final positions,
                :final teams,
                :final searchQuery,
                :final filterByPosition,
                :final filterByTeam,
                :final showInactive,
              ) =>
                _buildLoadedContent(
                  players: players,
                  filteredPlayers: filteredPlayers,
                  positions: positions,
                  teams: teams,
                  searchQuery: searchQuery,
                  filterByPosition: filterByPosition,
                  filterByTeam: filterByTeam,
                  showInactive: showInactive,
                ),
              PlayersError(:final message) => _buildErrorWidget(message),
              _ => const CELoading.inline(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoadedContent({
    required List<Map<String, dynamic>> players,
    required List<Map<String, dynamic>> filteredPlayers,
    required Map<int, String> positions,
    required Map<int, String> teams,
    required String searchQuery,
    required int? filterByPosition,
    required int? filterByTeam,
    required bool showInactive,
  }) {
    final isClubOrCoordinador = widget.userRole == UserRole.club ||
        widget.userRole == UserRole.coordinador;
    final hasActiveFilters =
        searchQuery.isNotEmpty || filterByPosition != null || filterByTeam != null;

    return CustomScrollView(
      slivers: [
        // Header fijo
        SliverToBoxAdapter(
          child: _buildHeader(
            players.length,
            teams: teams,
            positions: positions,
            filterByTeam: filterByTeam,
            filterByPosition: filterByPosition,
            isClubOrCoordinador: isClubOrCoordinador,
            showInactive: showInactive,
          ),
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

        // Filtros: chips de posición solo para Entrenador
        if (!isClubOrCoordinador && positions.isNotEmpty)
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
                        onTap: () {},
                        onEdit: () {
                          // TODO: Implementar edición de jugador
                          debugPrint('Editar jugador: ${player['nombre']}');
                        },
                        onProfile: () => _showPlayerProfile(player),
                        onDelete: () => _confirmDeletePlayer(player),
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

  Widget _buildHeader(
    int totalPlayers, {
    required Map<int, String> teams,
    required Map<int, String> positions,
    required int? filterByTeam,
    required int? filterByPosition,
    required bool isClubOrCoordinador,
    required bool showInactive,
  }) {
    final hasActiveFilters = filterByTeam != null || filterByPosition != null;

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

          // Botón Filtros (solo para Club/Coordinador)
          if (isClubOrCoordinador && teams.isNotEmpty) ...[
            _buildFilterButton(
              teams: teams,
              positions: positions,
              filterByTeam: filterByTeam,
              filterByPosition: filterByPosition,
              hasActiveFilters: hasActiveFilters,
            ),
            AppSpacing.hSpaceSm,
          ],

          // Toggle Activos/Inactivos
          _buildActiveInactiveToggle(showInactive),
          AppSpacing.hSpaceSm,

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

  Widget _buildFilterButton({
    required Map<int, String> teams,
    required Map<int, String> positions,
    required int? filterByTeam,
    required int? filterByPosition,
    required bool hasActiveFilters,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        showPlayersFilterDialog(
          context: context,
          teams: teams,
          positions: positions,
          selectedTeam: filterByTeam,
          selectedPosition: filterByPosition,
          onApply: (team, position) {
            _playersBloc.add(PlayersFilterByTeam(idequipo: team));
            _playersBloc.add(PlayersFilterByPosition(idposicion: position));
          },
          onClear: _clearFilters,
          showTeamFilter: teams.isNotEmpty,
        );
      },
      icon: Icon(
        hasActiveFilters ? Icons.filter_list : Icons.filter_list_outlined,
        size: 18,
      ),
      label: Text(hasActiveFilters ? 'Filtros activos' : 'Filtros'),
      style: OutlinedButton.styleFrom(
        foregroundColor: hasActiveFilters ? AppColors.primary : AppColors.gray700,
        side: BorderSide(
          color: hasActiveFilters ? AppColors.primary : AppColors.gray300,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Botón toggle para mostrar activos/inactivos
  Widget _buildActiveInactiveToggle(bool showInactive) {
    return Tooltip(
      message: showInactive ? 'Mostrando inactivos' : 'Mostrando activos',
      child: InkWell(
        onTap: () {
          // Obtener la temporada activa del AppConfigCubit global
          final activeSeasonId = context.read<AppConfigCubit>().activeSeasonId;
          _playersBloc.add(PlayersToggleInactive(
            showInactive: !showInactive,
            activeSeasonId: activeSeasonId,
          ));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: showInactive
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showInactive
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showInactive ? Icons.person_off_outlined : Icons.person_outline,
                size: 18,
                color: showInactive ? AppColors.error : AppColors.primary,
              ),
              AppSpacing.hSpaceXs,
              Text(
                showInactive ? 'Inactivos' : 'Activos',
                style: AppTypography.labelSmall.copyWith(
                  color: showInactive ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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

  /// Muestra diálogo de confirmación para eliminar jugador
  Future<void> _confirmDeletePlayer(Map<String, dynamic> player) async {
    final nombreCompleto = '${player['nombre'] ?? ''} ${player['apellidos'] ?? ''}'.trim();
    final confirmed = await CeConfirmDialog.show(
      context,
      title: '¿Eliminar jugador?',
      message: '¿Estás seguro de que deseas eliminar a "$nombreCompleto"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );

    if (confirmed) {
      // TODO: Implementar eliminación de jugador
      debugPrint('Eliminar jugador confirmado: ${player['id']}');
    }
  }
}
