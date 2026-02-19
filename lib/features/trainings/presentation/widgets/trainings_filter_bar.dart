import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Barra de filtros para entrenamientos
class TrainingsFilterBar extends StatelessWidget {
  const TrainingsFilterBar({
    super.key,
    this.teamName,
    this.searchQuery,
    required this.onSearchChanged,
  });

  final String? teamName;
  final String? searchQuery;
  final void Function(String) onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadowLight,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          // Indicador de equipo
          if (teamName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  AppSpacing.hSpaceSm,
                  Text(
                    teamName!,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hSpaceMd,
          ],

          // Buscador
          Expanded(
            child: _SearchField(
              value: searchQuery,
              onChanged: onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    this.value,
    required this.onChanged,
  });

  final String? value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar entrenamiento...',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.gray400,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.gray400,
        ),
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.gray700,
      ),
    );
  }
}
