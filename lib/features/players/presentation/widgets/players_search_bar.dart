import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Barra de búsqueda para jugadores
class PlayersSearchBar extends StatelessWidget {
  const PlayersSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController controller;
  final void Function(String query) onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.gray200,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o dorsal...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.gray400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.gray400,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.gray400,
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.gray900,
        ),
      ),
    );
  }
}
