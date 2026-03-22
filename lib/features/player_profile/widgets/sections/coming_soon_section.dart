import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección placeholder para apartados pendientes de implementar
class ComingSoonSection extends StatelessWidget {
  const ComingSoonSection({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          AppSpacing.vSpaceMd,
          Text(
            title,
            style: AppTypography.h6.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vSpaceXs,
          Text(
            'Próximamente',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
