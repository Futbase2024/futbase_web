import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/teams_bloc.dart';
import '../../bloc/teams_event.dart';
import '../../bloc/teams_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/shared_widgets.dart';
import 'teams_list.dart';
import 'teams_search_bar.dart';
import 'teams_filter_bar.dart';
import 'teams_empty_state.dart';
import 'team_form_dialog.dart';

/// Contenido de la página de equipos
///
/// Widget que contiene toda la lógica de UI para gestionar equipos
class TeamsContent extends StatefulWidget {
  const TeamsContent({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<TeamsContent> createState() => _TeamsContentState();
}

class _TeamsContentState extends State<TeamsContent> {
  late final TeamsBloc _teamsBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teamsBloc = TeamsBloc();
    _loadTeams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _teamsBloc.close();
    super.dispose();
  }

  void _loadTeams() {
    final idclub = widget.user.idclub;
    if (idclub > 0) {
      _teamsBloc.add(TeamsLoadRequested(idclub: idclub));
    }
  }

  void _onSearch(String query) {
    _teamsBloc.add(TeamsSearchRequested(query: query));
  }

  void _onCategoryFilter(int? idcategoria) {
    _teamsBloc.add(TeamsFilterByCategory(idcategoria: idcategoria));
  }

  void _onSeasonFilter(int? idtemporada) {
    _teamsBloc.add(TeamsFilterBySeason(idtemporada: idtemporada));
  }

  void _clearFilters() {
    _searchController.clear();
    _teamsBloc.add(const TeamsClearFilters());
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TeamFormDialog(
        idclub: widget.user.idclub,
        categories: const {},
        seasons: const {},
      ),
    );

    if (result != null && mounted) {
      final currentState = _teamsBloc.state;
      Map<int, String> categories = {};
      Map<int, String> seasons = {};

      if (currentState is TeamsLoaded) {
        categories = currentState.categories;
        seasons = currentState.seasons;
      }

      // Reabrir con datos de categorías y temporadas
      final confirmedResult = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => TeamFormDialog(
          idclub: widget.user.idclub,
          categories: categories,
          seasons: seasons,
          initialData: result,
        ),
      );

      if (confirmedResult != null) {
        _teamsBloc.add(TeamCreateRequested(
          idclub: widget.user.idclub,
          idcategoria: confirmedResult['idcategoria'] as int,
          idtemporada: confirmedResult['idtemporada'] as int,
          equipo: confirmedResult['equipo'] as String,
          ncorto: confirmedResult['ncorto'] as String?,
          titulares: confirmedResult['titulares'] as int? ?? 11,
          minutos: confirmedResult['minutos'] as int? ?? 45,
        ));
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> team) async {
    final currentState = _teamsBloc.state;
    Map<int, String> categories = {};
    Map<int, String> seasons = {};

    if (currentState is TeamsLoaded) {
      categories = currentState.categories;
      seasons = currentState.seasons;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TeamFormDialog(
        idclub: widget.user.idclub,
        categories: categories,
        seasons: seasons,
        initialData: team,
        isEditing: true,
      ),
    );

    if (result != null) {
      _teamsBloc.add(TeamUpdateRequested(
        id: team['id'] as int,
        idcategoria: result['idcategoria'] as int,
        idtemporada: result['idtemporada'] as int,
        equipo: result['equipo'] as String,
        ncorto: result['ncorto'] as String?,
        titulares: result['titulares'] as int? ?? 11,
        minutos: result['minutos'] as int? ?? 45,
      ));
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> team) async {
    final confirmed = await CeConfirmDialog.show(
      context,
      title: '¿Eliminar equipo?',
      message: '¿Estás seguro de que deseas eliminar el equipo "${team['equipo']}"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );

    if (confirmed) {
      _teamsBloc.add(TeamDeleteRequested(id: team['id'] as int));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _teamsBloc,
      child: BlocConsumer<TeamsBloc, TeamsState>(
        listener: (context, state) {
          if (state is TeamsError) {
            CeInfoDialog.error(
              context,
              title: 'Error',
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFB),
            body: SafeArea(
              child: switch (state) {
                TeamsInitial() => const CELoading.inline(),
                TeamsLoading() => const CELoading.inline(),
                TeamsLoaded(
                  :final teams,
                  :final filteredTeams,
                  :final categories,
                  :final seasons,
                  :final searchQuery,
                  :final filterByCategory,
                  :final filterBySeason,
                  :final isCreating,
                  :final isUpdating,
                  :final isDeleting,
                ) =>
                  Stack(
                    children: [
                      _buildLoadedContent(
                        context,
                        teams: teams,
                        filteredTeams: filteredTeams,
                        categories: categories,
                        seasons: seasons,
                        searchQuery: searchQuery,
                        filterByCategory: filterByCategory,
                        filterBySeason: filterBySeason,
                      ),
                      if (isCreating || isUpdating || isDeleting)
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: CELoading.inline(message: 'Guardando...'),
                          ),
                        ),
                    ],
                  ),
                TeamsError(:final message) => _buildErrorWidget(message),
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
    required List<Map<String, dynamic>> teams,
    required List<Map<String, dynamic>> filteredTeams,
    required Map<int, String> categories,
    required Map<int, String> seasons,
    required String searchQuery,
    required int? filterByCategory,
    required int? filterBySeason,
  }) {
    final hasActiveFilters =
        searchQuery.isNotEmpty || filterByCategory != null || filterBySeason != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas
        _buildHeader(teams.length),

        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: TeamsSearchBar(
            controller: _searchController,
            onSearch: _onSearch,
            onClear: () => _onSearch(''),
          ),
        ),

        // Filtros por categoría y temporada
        if (categories.isNotEmpty || seasons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TeamsFilterBar(
              categories: categories,
              seasons: seasons,
              selectedCategory: filterByCategory,
              selectedSeason: filterBySeason,
              onCategoryChanged: _onCategoryFilter,
              onSeasonChanged: _onSeasonFilter,
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
                  '${filteredTeams.length} de ${teams.length} equipos',
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

        // Lista de equipos
        Expanded(
          child: filteredTeams.isEmpty
              ? TeamsEmptyState(
                  hasFilters: hasActiveFilters,
                  onClearFilters: _clearFilters,
                  onCreateTeam: _showCreateDialog,
                )
              : TeamsList(
                  teams: filteredTeams,
                  onEdit: _showEditDialog,
                  onDelete: _confirmDelete,
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalTeams) {
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
                  'Equipos',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                AppSpacing.vSpaceXs,
                Text(
                  'Gestiona los equipos de tu club',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // KPIs rápidos
          _buildQuickStat(
            icon: Icons.groups,
            value: totalTeams.toString(),
            label: 'Equipos',
            color: AppColors.primary,
          ),
          AppSpacing.hSpaceXl,
          _buildQuickStat(
            icon: Icons.add_circle_outline,
            value: 'Añadir',
            label: 'Nuevo',
            color: AppColors.success,
            isButton: true,
            onTap: _showCreateDialog,
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
            'Error al cargar equipos',
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
            onPressed: _loadTeams,
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
