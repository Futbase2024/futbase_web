import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/scouting_bloc.dart';
import '../../bloc/scouting_event.dart';
import '../../bloc/scouting_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo de filtros para Scouting
class ScoutingFilterDialog extends StatefulWidget {
  const ScoutingFilterDialog({super.key});

  @override
  State<ScoutingFilterDialog> createState() => _ScoutingFilterDialogState();
}

class _ScoutingFilterDialogState extends State<ScoutingFilterDialog> {
  late int? _selectedTemporada;
  late Set<int> _selectedPosiciones;
  late Set<int> _selectedCategorias;
  late int? _selectedPie;
  late RangeValues _ageRange;
  late RangeValues _ratingRange;

  @override
  void initState() {
    super.initState();
    final state = context.read<ScoutingBloc>().state as ScoutingLoaded;
    final filters = state.filters;

    _selectedTemporada = filters.idtemporada;
    _selectedPosiciones = Set.from(filters.idposiciones);
    _selectedCategorias = Set.from(filters.idcategorias);
    _selectedPie = filters.idpiedominante;
    _ageRange = RangeValues(
      (filters.minAge ?? 0).toDouble(),
      (filters.maxAge ?? 99).toDouble(),
    );
    _ratingRange = RangeValues(
      (filters.minRating ?? 0).toDouble(),
      (filters.maxRating ?? 100).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ScoutingBloc>().state as ScoutingLoaded;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temporada
                    _buildSection('Temporada', _buildSeasonDropdown(state)),
                    const SizedBox(height: AppSpacing.lg),

                    // Posiciones
                    _buildSection('Posiciones', _buildPositionChips(state)),
                    const SizedBox(height: AppSpacing.lg),

                    // Categorías
                    _buildSection('Categorías', _buildCategoryChips(state)),
                    const SizedBox(height: AppSpacing.lg),

                    // Pie dominante
                    _buildSection('Pie dominante', _buildFootChips(state)),
                    const SizedBox(height: AppSpacing.lg),

                    // Rango de edad
                    _buildSection(
                      'Edad (${_ageRange.start.toInt()} - ${_ageRange.end.toInt()})',
                      _buildAgeSlider(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Rango de valoración
                    _buildSection(
                      'Valoración (${_ratingRange.start.toInt()} - ${_ratingRange.end.toInt()})',
                      _buildRatingSlider(),
                    ),
                  ],
                ),
              ),
            ),

            // Footer con botones
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: AppColors.white),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Filtros de Scouting',
            style: AppTypography.h6.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        content,
      ],
    );
  }

  Widget _buildSeasonDropdown(ScoutingLoaded state) {
    return DropdownButtonFormField<int?>(
      initialValue: _selectedTemporada,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todas las temporadas')),
        ...state.temporadas.entries.map((e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value),
            )),
      ],
      onChanged: (value) => setState(() => _selectedTemporada = value),
    );
  }

  Widget _buildPositionChips(ScoutingLoaded state) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: state.posiciones.entries.map((e) {
        final isSelected = _selectedPosiciones.contains(e.key);
        return FilterChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedPosiciones.add(e.key);
              } else {
                _selectedPosiciones.remove(e.key);
              }
            });
          },
          backgroundColor: AppColors.gray50,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.gray200),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips(ScoutingLoaded state) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: state.categorias.entries.map((e) {
        final isSelected = _selectedCategorias.contains(e.key);
        return FilterChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategorias.add(e.key);
              } else {
                _selectedCategorias.remove(e.key);
              }
            });
          },
          backgroundColor: AppColors.gray50,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.gray200),
        );
      }).toList(),
    );
  }

  Widget _buildFootChips(ScoutingLoaded state) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: state.pies.entries.map((e) {
        final isSelected = _selectedPie == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedPie = selected ? e.key : null);
          },
          backgroundColor: AppColors.gray50,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.gray200),
        );
      }).toList(),
    );
  }

  Widget _buildAgeSlider() {
    return RangeSlider(
      values: _ageRange,
      min: 0,
      max: 99,
      divisions: 99,
      activeColor: AppColors.primary,
      inactiveColor: AppColors.gray200,
      onChanged: (values) => setState(() => _ageRange = values),
    );
  }

  Widget _buildRatingSlider() {
    return RangeSlider(
      values: _ratingRange,
      min: 0,
      max: 100,
      divisions: 100,
      activeColor: AppColors.primary,
      inactiveColor: AppColors.gray200,
      onChanged: (values) => setState(() => _ratingRange = values),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Row(
        children: [
          // Botón limpiar
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray600,
            ),
          ),
          const Spacer(),
          // Botón cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Botón aplicar
          ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Aplicar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTemporada = null;
      _selectedPosiciones.clear();
      _selectedCategorias.clear();
      _selectedPie = null;
      _ageRange = const RangeValues(0, 99);
      _ratingRange = const RangeValues(0, 100);
    });
  }

  void _applyFilters() {
    final bloc = context.read<ScoutingBloc>();

    // Aplicar todos los filtros
    bloc.add(ScoutingFilterSeasonChanged(idtemporada: _selectedTemporada));
    bloc.add(ScoutingFilterPositionsChanged(idposiciones: _selectedPosiciones));
    bloc.add(ScoutingFilterCategoriesChanged(idcategorias: _selectedCategorias));
    bloc.add(ScoutingFilterFootChanged(idpiedominante: _selectedPie));
    bloc.add(ScoutingFilterAgeRangeChanged(
      minAge: _ageRange.start.toInt() == 0 ? null : _ageRange.start.toInt(),
      maxAge: _ageRange.end.toInt() == 99 ? null : _ageRange.end.toInt(),
    ));
    bloc.add(ScoutingFilterRatingRangeChanged(
      minRating: _ratingRange.start.toInt() == 0 ? null : _ratingRange.start.toInt(),
      maxRating: _ratingRange.end.toInt() == 100 ? null : _ratingRange.end.toInt(),
    ));

    Navigator.of(context).pop();
  }
}
