import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Estado vacío para la lista de equipos
class TeamsEmptyState extends StatelessWidget {
  const TeamsEmptyState({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
    required this.onCreateTeam,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateTeam;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.search_off : Icons.groups_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.vSpaceMd,
          Text(
            hasFilters ? 'Sin resultados' : 'No hay equipos',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
            ),
          ),
          AppSpacing.vSpaceSm,
          Text(
            hasFilters
                ? 'No se encontraron equipos con los filtros aplicados'
                : 'Crea tu primer equipo para empezar',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSpaceMd,
          if (hasFilters)
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Limpiar filtros'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: onCreateTeam,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Crear equipo'),
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
