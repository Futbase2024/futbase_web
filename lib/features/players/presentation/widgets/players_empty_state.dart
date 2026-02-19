import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Estado vacío cuando no hay jugadores o no hay resultados
class PlayersEmptyState extends StatelessWidget {
  const PlayersEmptyState({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          AppSpacing.vSpaceXl,
          Text(
            hasFilters ? 'Sin resultados' : 'No hay jugadores',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),
          AppSpacing.vSpaceSm,
          Text(
            hasFilters
                ? 'No se encontraron jugadores con los filtros aplicados'
                : 'Añade jugadores a tu plantilla para empezar',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSpaceXl,
          if (hasFilters)
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all),
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
              onPressed: () {
                // TODO: Navegar a crear jugador
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir jugador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
