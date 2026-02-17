import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Sección de estadísticas impactantes
/// Diseño modo claro basado en landing-blanco.html
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat(
        number: '500+',
        label: 'Clubes Confían',
        trend: '+12% mensual',
        trendIcon: Icons.trending_up,
      ),
      _Stat(
        number: '25k+',
        label: 'Jugadores Activos',
        trend: '+25% Crecimiento',
        trendIcon: Icons.trending_up,
      ),
      _Stat(
        number: '100k+',
        label: 'Partidos Registrados',
        trend: 'Sincronización Real',
        trendIcon: Icons.bolt,
      ),
      _Stat(
        number: '99%',
        label: 'Tasa de Cobro',
        trend: 'Automatizado',
        trendIcon: Icons.verified_user,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      padding: Responsive.padding(context).copyWith(
        top: AppSpacing.xxl,
        bottom: AppSpacing.xxl,
      ),
      child: Responsive.constrainedContent(
        maxWidth: 1280,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 800 ? 4 : 2;
            return Wrap(
              spacing: AppSpacing.xxl,
              runSpacing: AppSpacing.xl,
              children: stats.map((stat) {
                final width = (constraints.maxWidth - (AppSpacing.xxl * (columns - 1))) / columns;
                return SizedBox(
                  width: width,
                  child: _StatItem(stat: stat, isCentered: columns == 4),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final _Stat stat;
  final bool isCentered;

  const _StatItem({
    required this.stat,
    this.isCentered = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Número grande
        Text(
          stat.number,
          style: AppTypography.statLarge.copyWith(
            color: AppColors.textLightMain,
          ),
        ),
        const SizedBox(height: 4),

        // Label
        Text(
          stat.label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray500,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Trend badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              stat.trendIcon,
              color: AppColors.primaryLight,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              stat.trend,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat {
  final String number;
  final String label;
  final String trend;
  final IconData trendIcon;

  const _Stat({
    required this.number,
    required this.label,
    required this.trend,
    required this.trendIcon,
  });
}
