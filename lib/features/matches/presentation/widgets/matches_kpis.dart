import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// KPIs de partidos con estadísticas de rendimiento
class MatchesKpis extends StatelessWidget {
  const MatchesKpis({
    super.key,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.completedMatches,
  });

  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int completedMatches;

  String _getPercentage(int value) {
    if (completedMatches == 0) return '0%';
    final percentage = (value / completedMatches * 100).round();
    return '$percentage%';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'PARTIDOS TOTALES',
            value: totalMatches.toString(),
            subtitle: '$completedMatches jugados',
            icon: Icons.event_available,
            iconColor: AppColors.gray500,
            subtitleColor: AppColors.gray500,
          ),
        ),
        AppSpacing.hSpaceMd,
        Expanded(
          child: _KpiCard(
            label: 'VICTORIAS',
            value: wins.toString(),
            subtitle: _getPercentage(wins),
            icon: Icons.emoji_events,
            iconColor: AppColors.green,
            subtitleColor: AppColors.green,
          ),
        ),
        AppSpacing.hSpaceMd,
        Expanded(
          child: _KpiCard(
            label: 'DERROTAS',
            value: losses.toString(),
            subtitle: _getPercentage(losses),
            icon: Icons.cancel,
            iconColor: AppColors.red,
            subtitleColor: AppColors.red,
          ),
        ),
        AppSpacing.hSpaceMd,
        Expanded(
          child: _KpiCard(
            label: 'EMPATES',
            value: draws.toString(),
            subtitle: _getPercentage(draws),
            icon: Icons.drag_handle,
            iconColor: AppColors.gray500,
            subtitleColor: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.subtitleColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label e icono
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Valor principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
