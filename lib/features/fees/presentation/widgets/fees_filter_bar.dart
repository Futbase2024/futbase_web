import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Barra de filtros para la lista de cuotas
class FeesFilterBar extends StatelessWidget {
  const FeesFilterBar({
    super.key,
    required this.teams,
    this.selectedMonth,
    this.selectedYear,
    this.selectedTeam,
    this.selectedStatus,
    this.searchQuery = '',
    this.onMonthChanged,
    this.onTeamChanged,
    this.onStatusChanged,
    this.onSearchChanged,
    this.onClearFilters,
    this.showFilters = true,
  });

  final Map<int, String> teams;
  final int? selectedMonth;
  final int? selectedYear;
  final int? selectedTeam;
  final int? selectedStatus;
  final String searchQuery;
  final ValueChanged<int?>? onMonthChanged;
  final ValueChanged<int?>? onTeamChanged;
  final ValueChanged<int?>? onStatusChanged;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearFilters;
  final bool showFilters;

  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const Map<int, String> _statusNames = {
    1: 'Pagado',
    2: 'Pendiente',
    3: 'Vencido',
    4: 'Parcial',
    5: 'Exento',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o equipo...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.gray400),
                          onPressed: () => onSearchChanged?.call(''),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            if (showFilters && _hasActiveFilters) ...[
              AppSpacing.hSpaceSm,
              IconButton(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                color: AppColors.gray500,
                tooltip: 'Limpiar filtros',
              ),
            ],
          ],
        ),
        if (showFilters) ...[
          AppSpacing.vSpaceSm,
          // Filtros en chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtro de mes
                _buildFilterChip(
                  label: selectedMonth != null
                      ? _monthNames[selectedMonth! - 1]
                      : 'Mes',
                  icon: Icons.calendar_today,
                  isSelected: selectedMonth != null,
                  items: List.generate(
                    12,
                    (i) => (value: i + 1, label: _monthNames[i]),
                  ),
                  selectedValue: selectedMonth,
                  onChanged: onMonthChanged,
                ),
                AppSpacing.hSpaceSm,
                // Filtro de equipo
                _buildFilterChip(
                  label: selectedTeam != null
                      ? (teams[selectedTeam] ?? 'Equipo')
                      : 'Equipo',
                  icon: Icons.groups,
                  isSelected: selectedTeam != null,
                  items: teams.entries
                      .map((e) => (value: e.key, label: e.value))
                      .toList(),
                  selectedValue: selectedTeam,
                  onChanged: onTeamChanged,
                ),
                AppSpacing.hSpaceSm,
                // Filtro de estado
                _buildFilterChip(
                  label: selectedStatus != null
                      ? (_statusNames[selectedStatus] ?? 'Estado')
                      : 'Estado',
                  icon: Icons.info_outline,
                  isSelected: selectedStatus != null,
                  items: _statusNames.entries
                      .map((e) => (value: e.key, label: e.value))
                      .toList(),
                  selectedValue: selectedStatus,
                  onChanged: onStatusChanged,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool get _hasActiveFilters =>
      selectedMonth != null ||
      selectedTeam != null ||
      selectedStatus != null ||
      searchQuery.isNotEmpty;

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required List<({int value, String label})> items,
    required int? selectedValue,
    required ValueChanged<int?>? onChanged,
  }) {
    return PopupMenuButton<int>(
      onSelected: (value) {
        if (value == selectedValue) {
          onChanged?.call(null);
        } else {
          onChanged?.call(value);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0, child: Text('Todos')),
        const PopupMenuDivider(),
        ...items.map(
          (item) => PopupMenuItem(
            value: item.value,
            child: Row(
              children: [
                if (item.value == selectedValue)
                  const Icon(Icons.check, size: 16, color: AppColors.primary),
                if (item.value == selectedValue) AppSpacing.hSpaceSm,
                Text(item.label),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.gray500),
            AppSpacing.hSpaceXs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            AppSpacing.hSpaceXs,
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}
