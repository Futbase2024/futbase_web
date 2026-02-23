import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Barra de búsqueda para equipos
class TeamsSearchBar extends StatelessWidget {
  const TeamsSearchBar({
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
    return TextField(
      controller: controller,
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: 'Buscar equipos por nombre, categoría...',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.gray400,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.gray400,
          size: 20,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.gray400,
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  onClear();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.gray900,
      ),
    );
  }
}
