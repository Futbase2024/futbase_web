import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Barra de filtros para partidos
class MatchesFilterBar extends StatelessWidget {
  const MatchesFilterBar({
    super.key,
    this.teamName,
    this.searchQuery,
    required this.competitions,
    required this.onSearchChanged,
    required this.onFilterByDate,
    required this.onFilterByCompetition,
    required this.onFilterByVenue,
    required this.onClearFilters,
    required this.hasActiveFilters,
    this.filterFromDate,
    this.filterToDate,
  });

  final String? teamName;
  final String? searchQuery;
  final Map<int, String> competitions;
  final void Function(String) onSearchChanged;
  final void Function(DateTime?, DateTime?) onFilterByDate;
  final void Function(int?) onFilterByCompetition;
  final void Function(bool?) onFilterByVenue;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.gray100),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          // Buscador
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar por rival...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.gray400,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.gray50,
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMd,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              AppSpacing.hSpaceMd,
              // Filtro por fecha
              _DateFilterButton(
                fromDate: filterFromDate,
                toDate: filterToDate,
                onFilterSelected: onFilterByDate,
              ),
              AppSpacing.hSpaceSm,
              // Filtro por competición
              _CompetitionFilterButton(
                competitions: competitions,
                onFilterSelected: onFilterByCompetition,
              ),
              AppSpacing.hSpaceSm,
              // Filtro por local/visitante
              _VenueFilterButton(
                onFilterSelected: onFilterByVenue,
              ),
              if (hasActiveFilters) ...[
                AppSpacing.hSpaceSm,
                // Limpiar filtros
                Tooltip(
                  message: 'Limpiar filtros',
                  child: Material(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusMd,
                    child: InkWell(
                      onTap: onClearFilters,
                      borderRadius: AppSpacing.borderRadiusMd,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.filter_alt_off,
                          size: 20,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.fromDate,
    required this.toDate,
    required this.onFilterSelected,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final void Function(DateTime?, DateTime?) onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final hasFilter = fromDate != null || toDate != null;

    return Tooltip(
      message: 'Filtrar por fecha',
      child: Material(
        color: hasFilter
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.gray50,
        borderRadius: AppSpacing.borderRadiusMd,
        child: InkWell(
          onTap: () => _showDateRangePicker(context),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.date_range,
              size: 20,
              color: hasFilter ? AppColors.primary : AppColors.gray500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
      locale: const Locale('es', 'ES'),
    );

    if (range != null) {
      onFilterSelected(range.start, range.end);
    }
  }
}

class _CompetitionFilterButton extends StatelessWidget {
  const _CompetitionFilterButton({
    required this.competitions,
    required this.onFilterSelected,
  });

  final Map<int, String> competitions;
  final void Function(int?) onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Filtrar por competición',
      child: Material(
        color: AppColors.gray50,
        borderRadius: AppSpacing.borderRadiusMd,
        child: InkWell(
          onTap: () => _showCompetitionMenu(context),
          borderRadius: AppSpacing.borderRadiusMd,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 20,
              color: AppColors.gray500,
            ),
          ),
        ),
      ),
    );
  }

  void _showCompetitionMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu<int?>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy,
      ),
      items: [
        const PopupMenuItem<int?>(
          value: null,
          child: Text('Todas las competiciones'),
        ),
        ...competitions.entries.map((e) => PopupMenuItem<int?>(
              value: e.key,
              child: Text(e.value),
            )),
      ],
    ).then((value) {
      if (value != null) {
        onFilterSelected(value);
      }
    });
  }
}

class _VenueFilterButton extends StatelessWidget {
  const _VenueFilterButton({
    required this.onFilterSelected,
  });

  final void Function(bool?) onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Local / Visitante',
      child: Material(
        color: AppColors.gray50,
        borderRadius: AppSpacing.borderRadiusMd,
        child: InkWell(
          onTap: () => _showVenueMenu(context),
          borderRadius: AppSpacing.borderRadiusMd,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.home_outlined,
              size: 20,
              color: AppColors.gray500,
            ),
          ),
        ),
      ),
    );
  }

  void _showVenueMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu<bool?>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy,
      ),
      items: const [
        PopupMenuItem<bool?>(
          value: null,
          child: Text('Todos'),
        ),
        PopupMenuItem<bool?>(
          value: true,
          child: Text('Local'),
        ),
        PopupMenuItem<bool?>(
          value: false,
          child: Text('Visitante'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        onFilterSelected(value);
      }
    });
  }
}
