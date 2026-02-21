import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/results_state.dart';
import 'results_match_card.dart';
import 'results_live_match_card.dart';

/// Agrupa partidos por fecha y los muestra en una lista
class ResultsDateGroup extends StatelessWidget {
  const ResultsDateGroup({
    super.key,
    required this.group,
  });

  final ResultsGroupedByDate group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de fecha
        _DateHeader(
          dateLabel: group.dateLabel,
          matchCount: group.matches.length,
          liveCount: group.liveCount,
        ),

        // Lista de partidos
        ...group.matches.map((match) => Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: match.status == MatchStatus.live
                  ? ResultsLiveMatchCard(match: match)
                  : ResultsMatchCard(match: match),
            )),

        AppSpacing.vSpaceSm,
      ],
    );
  }
}

/// Header con la fecha del grupo
class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.dateLabel,
    required this.matchCount,
    required this.liveCount,
  });

  final String dateLabel;
  final int matchCount;
  final int liveCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Fecha
          Text(
            dateLabel,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.hSpaceSm,

          // Contador de partidos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$matchCount ${matchCount == 1 ? 'partido' : 'partidos'}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Indicador de partidos en vivo
          if (liveCount > 0) ...[
            AppSpacing.hSpaceSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$liveCount en vivo',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
