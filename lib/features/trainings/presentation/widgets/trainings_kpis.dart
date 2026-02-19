import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Tarjetas KPI para estadísticas de entrenamientos
class TrainingsKpis extends StatelessWidget {
  const TrainingsKpis({
    super.key,
    required this.todayTrainings,
    required this.averageAttendance,
    required this.completedThisWeek,
    required this.upcomingThisWeek,
  });

  final int todayTrainings;
  final double averageAttendance;
  final int completedThisWeek;
  final int upcomingThisWeek;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KpiCard(
              icon: Icons.event,
              label: 'ENTRENAMIENTOS HOY',
              value: todayTrainings.toString(),
              iconColor: AppColors.primary,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: _KpiCard(
              icon: Icons.people_outline,
              label: 'ASISTENCIA MEDIA',
              value: '${averageAttendance.toStringAsFixed(0)}%',
              iconColor: AppColors.primary,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: _KpiCard(
              icon: Icons.check_circle_outline,
              label: 'COMPLETADOS (SEMANA)',
              value: completedThisWeek.toString(),
              iconColor: AppColors.primary,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: _KpiCard(
              icon: Icons.schedule,
              label: 'PRÓXIMOS (SEMANA)',
              value: upcomingThisWeek.toString(),
              iconColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadowLight,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.statMedium.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
