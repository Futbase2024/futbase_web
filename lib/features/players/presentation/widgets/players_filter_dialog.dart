import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo profesional de filtros para jugadores
class PlayersFilterDialog extends StatefulWidget {
  const PlayersFilterDialog({
    super.key,
    required this.teams,
    required this.positions,
    required this.selectedTeam,
    required this.selectedPosition,
    required this.onApply,
    required this.onClear,
    this.showTeamFilter = true,
  });

  final Map<int, String> teams;
  final Map<int, String> positions;
  final int? selectedTeam;
  final int? selectedPosition;
  final void Function(int? team, int? position) onApply;
  final VoidCallback onClear;
  final bool showTeamFilter;

  @override
  State<PlayersFilterDialog> createState() => _PlayersFilterDialogState();
}

class _PlayersFilterDialogState extends State<PlayersFilterDialog> {
  int? _selectedTeam;
  int? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedTeam = widget.selectedTeam;
    _selectedPosition = widget.selectedPosition;
  }

  bool get hasChanges =>
      _selectedTeam != widget.selectedTeam ||
      _selectedPosition != widget.selectedPosition;

  bool get hasActiveFilters => _selectedTeam != null || _selectedPosition != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtro de equipo
                    if (widget.showTeamFilter && widget.teams.isNotEmpty) ...[
                      _buildSectionTitle('Equipo', Icons.groups),
                      AppSpacing.vSpaceSm,
                      _buildTeamDropdown(),
                      AppSpacing.vSpaceLg,
                    ],

                    // Filtro de posición
                    _buildSectionTitle('Posición', Icons.sports_soccer),
                    AppSpacing.vSpaceSm,
                    _buildPositionDropdown(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.filter_list,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros de jugadores',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  'Filtra la lista de jugadores por equipo y posición',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          // Indicador de filtros activos
          if (hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Activos',
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray600),
        AppSpacing.hSpaceXs,
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedTeam != null
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.gray200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedTeam,
          hint: Text(
            'Todos los equipos',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.gray400,
          ),
          borderRadius: BorderRadius.circular(10),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                'Todos los equipos',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
            ),
            ...widget.teams.entries.map((e) => DropdownMenuItem<int>(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: AppTypography.bodyMedium.copyWith(
                      color: _selectedTeam == e.key
                          ? AppColors.primary
                          : AppColors.gray700,
                      fontWeight: _selectedTeam == e.key
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedTeam = value);
          },
        ),
      ),
    );
  }

  Widget _buildPositionDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedPosition != null
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.gray200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedPosition,
          hint: Text(
            'Todas las posiciones',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.gray400,
          ),
          borderRadius: BorderRadius.circular(10),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                'Todas las posiciones',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
            ),
            ...widget.positions.entries.map((e) => DropdownMenuItem<int>(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: AppTypography.bodyMedium.copyWith(
                      color: _selectedPosition == e.key
                          ? AppColors.primary
                          : AppColors.gray700,
                      fontWeight: _selectedPosition == e.key
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedPosition = value);
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          top: BorderSide(color: AppColors.gray100),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Botón limpiar
          if (hasActiveFilters)
            TextButton.icon(
              onPressed: () {
                widget.onClear();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Limpiar todo'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gray600,
              ),
            ),
          const Spacer(),
          // Botón cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          AppSpacing.hSpaceSm,
          // Botón aplicar
          ElevatedButton.icon(
            onPressed: () {
              widget.onApply(_selectedTeam, _selectedPosition);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Aplicar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Función helper para mostrar el diálogo
Future<void> showPlayersFilterDialog({
  required BuildContext context,
  required Map<int, String> teams,
  required Map<int, String> positions,
  required int? selectedTeam,
  required int? selectedPosition,
  required void Function(int? team, int? position) onApply,
  required VoidCallback onClear,
  bool showTeamFilter = true,
}) {
  return showDialog(
    context: context,
    builder: (context) => PlayersFilterDialog(
      teams: teams,
      positions: positions,
      selectedTeam: selectedTeam,
      selectedPosition: selectedPosition,
      onApply: onApply,
      onClear: onClear,
      showTeamFilter: showTeamFilter,
    ),
  );
}
