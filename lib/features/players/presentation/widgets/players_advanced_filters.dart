import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget de filtros avanzados para Club/Coordinador
/// Permite filtrar por equipo y posición
class PlayersAdvancedFilters extends StatelessWidget {
  const PlayersAdvancedFilters({
    super.key,
    required this.teams,
    required this.positions,
    required this.selectedTeam,
    required this.selectedPosition,
    required this.onTeamChanged,
    required this.onPositionChanged,
    required this.onClearFilters,
    this.showTeamFilter = true,
  });

  final Map<int, String> teams;
  final Map<int, String> positions;
  final int? selectedTeam;
  final int? selectedPosition;
  final ValueChanged<int?> onTeamChanged;
  final ValueChanged<int?> onPositionChanged;
  final VoidCallback onClearFilters;
  final bool showTeamFilter;

  bool get hasActiveFilters => selectedTeam != null || selectedPosition != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          // Icono de filtros
          Icon(
            Icons.filter_list,
            size: 20,
            color: hasActiveFilters ? AppColors.primary : AppColors.gray400,
          ),
          const SizedBox(width: 12),

          // Filtro de equipo (solo para club/coordinador)
          if (showTeamFilter && teams.isNotEmpty) ...[
            _buildTeamDropdown(),
            const SizedBox(width: 16),
          ],

          // Filtro de posición
          _buildPositionDropdown(),

          const Spacer(),

          // Botón limpiar filtros
          if (hasActiveFilters)
            TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Limpiar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gray600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamDropdown() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Equipo:',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selectedTeam != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedTeam != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray200,
            ),
          ),
          child: DropdownButton<int>(
            value: selectedTeam,
            hint: const Text('Todos'),
            underline: const SizedBox(),
            isDense: true,
            borderRadius: BorderRadius.circular(8),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Todos los equipos'),
              ),
              ...teams.entries.map((e) => DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value),
                  )),
            ],
            onChanged: onTeamChanged,
            style: AppTypography.bodySmall.copyWith(
              color: selectedTeam != null ? AppColors.primary : AppColors.gray700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionDropdown() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Posición:',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selectedPosition != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedPosition != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray200,
            ),
          ),
          child: DropdownButton<int>(
            value: selectedPosition,
            hint: const Text('Todas'),
            underline: const SizedBox(),
            isDense: true,
            borderRadius: BorderRadius.circular(8),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Todas las posiciones'),
              ),
              ...positions.entries.map((e) => DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value),
                  )),
            ],
            onChanged: onPositionChanged,
            style: AppTypography.bodySmall.copyWith(
              color: selectedPosition != null ? AppColors.primary : AppColors.gray700,
            ),
          ),
        ),
      ],
    );
  }
}
