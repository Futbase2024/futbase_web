import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Barra de filtros para equipos (categoría y temporada)
class TeamsFilterBar extends StatelessWidget {
  const TeamsFilterBar({
    super.key,
    required this.categories,
    required this.seasons,
    required this.selectedCategory,
    required this.selectedSeason,
    required this.onCategoryChanged,
    required this.onSeasonChanged,
  });

  final Map<int, String> categories;
  final Map<int, String> seasons;
  final int? selectedCategory;
  final int? selectedSeason;
  final void Function(int? idcategoria) onCategoryChanged;
  final void Function(int? idtemporada) onSeasonChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Filtro de categoría
        if (categories.isNotEmpty) ...[
          Expanded(
            child: _buildDropdown(
              label: 'Categoría',
              value: selectedCategory,
              items: categories,
              onChanged: onCategoryChanged,
              icon: Icons.category_outlined,
            ),
          ),
          AppSpacing.hSpaceMd,
        ],

        // Filtro de temporada
        if (seasons.isNotEmpty)
          Expanded(
            child: _buildDropdown(
              label: 'Temporada',
              value: selectedSeason,
              items: seasons,
              onChanged: onSeasonChanged,
              icon: Icons.calendar_today_outlined,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required Map<int, String> items,
    required void Function(int?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.gray400),
              AppSpacing.hSpaceSm,
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.gray400),
                  AppSpacing.hSpaceSm,
                  Text(
                    'Todas las $label',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            ...items.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.primary),
                    AppSpacing.hSpaceSm,
                    Text(
                      entry.value,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.gray400,
          ),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          elevation: 4,
        ),
      ),
    );
  }
}
