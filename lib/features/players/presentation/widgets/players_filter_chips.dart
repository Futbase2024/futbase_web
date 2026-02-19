import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Chips de filtro por posición
class PlayersFilterChips extends StatelessWidget {
  const PlayersFilterChips({
    super.key,
    required this.positions,
    required this.selectedPosition,
    required this.onPositionSelected,
  });

  final Map<int, String> positions;
  final int? selectedPosition;
  final void Function(int? idposicion) onPositionSelected;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          // Permite scroll con mouse, touch, etc.
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Chip "Todos"
            _buildFilterChip(
              label: 'Todos',
              isSelected: selectedPosition == null,
              onTap: () => onPositionSelected(null),
            ),
            AppSpacing.hSpaceSm,

            // Chips por posición
            ...positions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: entry.value,
                  isSelected: selectedPosition == entry.key,
                  onTap: () => onPositionSelected(
                    selectedPosition == entry.key ? null : entry.key,
                  ),
                ),
              );
            }),

            // Espacio final para que no se corte el último chip
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
