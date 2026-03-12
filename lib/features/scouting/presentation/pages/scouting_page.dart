import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/scouting_bloc.dart';
import '../../bloc/scouting_event.dart';
import '../../bloc/scouting_state.dart';
import '../widgets/scouting_filter_dialog.dart';
import '../widgets/scouting_player_card.dart';
import '../widgets/scouting_comparison_bar.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/ce_loading.dart';

/// Página principal de Scouting
class ScoutingPage extends StatelessWidget {
  const ScoutingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener datos del usuario autenticado
    final authState = context.watch<AuthBloc>().state;
    final userClubId = authState.user?.idclub;
    final isSuperAdmin = authState.role == UserRole.superAdmin;

    return BlocProvider(
      create: (context) => ScoutingBloc()..add(ScoutingInitializeRequested(
        userClubId: userClubId,
        isSuperAdmin: isSuperAdmin,
      )),
      child: const ScoutingView(),
    );
  }
}

class ScoutingView extends StatefulWidget {
  const ScoutingView({super.key});

  @override
  State<ScoutingView> createState() => _ScoutingViewState();
}

class _ScoutingViewState extends State<ScoutingView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoutingBloc, ScoutingState>(
      builder: (context, state) {
        return switch (state) {
          ScoutingInitial() => const CELoading.inline(message: 'Inicializando...'),
          ScoutingLoading() => const CELoading.inline(message: 'Cargando datos...'),
          ScoutingLoaded() => _buildLoadedContent(context, state),
          ScoutingError(:final message) => _buildErrorView(context, message),
          _ => const CELoading.inline(),
        };
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, ScoutingLoaded state) {
    return Stack(
      children: [
        // Contenido principal
        Column(
          children: [
            // Header compacto
            _buildCompactHeader(context, state),

            // Grid de jugadores
            Expanded(
              child: _buildPlayersGrid(context, state),
            ),
          ],
        ),

        // Barra de comparación (si hay jugadores en comparación)
        if (state.comparisonPlayers.isNotEmpty)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ScoutingComparisonBar(),
          ),
      ],
    );
  }

  Widget _buildCompactHeader(BuildContext context, ScoutingLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Título
            Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Scouting',
              style: AppTypography.h5.copyWith(
                color: AppColors.gray900,
              ),
            ),

            // Contador de resultados
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.filteredPlayers.length}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.xl),

            // Buscador
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<ScoutingBloc>().add(ScoutingSearchChanged(query: value));
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, apodo o equipo...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.gray400),
                  prefixIcon: Icon(Icons.search, color: AppColors.gray400, size: 20),
                  suffixIcon: state.filters.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.gray400, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ScoutingBloc>().add(const ScoutingSearchChanged(query: ''));
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Botón de filtros
            _buildFilterButton(context, state),

            // Botón limpiar (solo si hay filtros activos)
            if (state.filters.hasActiveFilters) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  context.read<ScoutingBloc>().add(const ScoutingClearFilters());
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gray600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, ScoutingLoaded state) {
    final activeCount = _getActiveFiltersCount(state);

    return Stack(
      children: [
        OutlinedButton.icon(
          onPressed: () => _showFilterDialog(context),
          icon: const Icon(Icons.tune, size: 18),
          label: const Text('Filtros'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gray700,
            side: BorderSide(color: AppColors.gray200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        if (activeCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$activeCount',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final bloc = context.read<ScoutingBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const ScoutingFilterDialog(),
      ),
    );
  }

  Widget _buildPlayersGrid(BuildContext context, ScoutingLoaded state) {
    // Mostrar loading mientras se cargan los jugadores
    if (state.isLoadingPlayers) {
      return const Center(
        child: CELoading.inline(message: 'Cargando jugadores...'),
      );
    }

    if (state.filteredPlayers.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.3,
        ),
        itemCount: state.filteredPlayers.length,
        itemBuilder: (context, index) {
          final player = state.filteredPlayers[index];
          final isComparing = state.comparisonPlayers.any((p) => p['id'] == player['id']);

          return ScoutingPlayerCard(
            player: player,
            isComparing: isComparing,
            showClub: state.isSuperAdmin,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_outlined,
              size: 48,
              color: AppColors.gray300,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No se encontraron jugadores',
            style: AppTypography.h5.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Prueba a modificar los filtros de búsqueda',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  int _getActiveFiltersCount(ScoutingLoaded state) {
    int count = 0;
    final filters = state.filters;

    if (filters.idtemporada != null) count++;
    if (filters.idposiciones.isNotEmpty) count++;
    if (filters.idcategorias.isNotEmpty) count++;
    if (filters.idpiedominante != null) count++;
    if (filters.minAge != null || filters.maxAge != null) count++;
    if (filters.minRating != null || filters.maxRating != null) count++;

    return count;
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Error al cargar datos',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ScoutingBloc>().add(const ScoutingInitializeRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
