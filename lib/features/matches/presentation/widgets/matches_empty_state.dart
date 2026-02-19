import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Estado vacío para partidos
class MatchesEmptyState extends StatelessWidget {
  const MatchesEmptyState({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
    required this.onCreateMatch,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateMatch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        constraints: const BoxConstraints(maxWidth: 400),
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
                hasFilters ? Icons.search_off : Icons.sports_soccer,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vSpaceLg,
            Text(
              hasFilters ? 'Sin resultados' : 'No hay partidos',
              style: AppTypography.h5.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              hasFilters
                  ? 'No se encontraron partidos con los filtros seleccionados'
                  : 'Añade el primer partido para empezar a gestionar la temporada',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceXl,
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text('Limpiar filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onCreateMatch,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Crear partido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
