import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Header estandarizado para listas de partidos
class MatchListHeader extends StatelessWidget {
  const MatchListHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.count,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final int? count;
  final Widget? trailing;

  /// Header para calendario de competición
  factory MatchListHeader.calendar({
    Key? key,
    int? count,
    Widget? trailing,
  }) {
    return MatchListHeader(
      key: key,
      title: 'Calendario de Competición',
      icon: Icons.event_note,
      iconColor: AppColors.primary,
      count: count,
      trailing: trailing,
    );
  }

  /// Header para resultados recientes
  factory MatchListHeader.recentResults({
    Key? key,
    int? count,
    Widget? trailing,
  }) {
    return MatchListHeader(
      key: key,
      title: 'Resultados Recientes',
      icon: Icons.analytics,
      iconColor: AppColors.primary,
      count: count,
      trailing: trailing,
    );
  }

  /// Header para historial de partidos
  factory MatchListHeader.history({
    Key? key,
    int? count,
    Widget? trailing,
  }) {
    return MatchListHeader(
      key: key,
      title: 'Historial de Partidos',
      icon: Icons.history,
      iconColor: AppColors.primary,
      count: count,
      trailing: trailing,
    );
  }

  /// Header para próximos partidos
  factory MatchListHeader.upcoming({
    Key? key,
    int? count,
    Widget? trailing,
  }) {
    return MatchListHeader(
      key: key,
      title: 'Próximos Partidos',
      icon: Icons.upcoming,
      iconColor: AppColors.primary,
      count: count,
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.primary,
              ),
              AppSpacing.hSpaceSm,
            ],
            Text(
              title,
              style: AppTypography.h6.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (count != null) ...[
              AppSpacing.hSpaceSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count partidos',
                  style: AppTypography.labelSmall.copyWith(
                    color: iconColor ?? AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
