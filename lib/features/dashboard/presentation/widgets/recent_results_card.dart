import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Resultados recientes de partidos
/// Diseño modo claro basado en dashboard-blanco.html
class RecentResultsCard extends StatelessWidget {
  const RecentResultsCard({
    super.key,
    this.results = const [],
  });

  final List<MatchResult> results;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.gray100),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resultados Recientes',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ver Todo',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Results list
          ...results.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ResultItem(result: result),
              )),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({required this.result});

  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          // Team badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: context.borderColor),
            ),
            child: Center(
              child: Text(
                result.teamCategory,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Match info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${result.opponent}',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${result.competition} • ${result.isHome ? 'Local' : 'Visitante'}',
                  style: AppTypography.caption.copyWith(
                    color: context.textSecondaryColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Result badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusBgColor(result.status),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Text(
              _getStatusText(result.status),
              style: AppTypography.labelSmall.copyWith(
                color: _getStatusColor(result.status),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Score
          Text(
            '${result.homeScore} - ${result.awayScore}',
            style: AppTypography.h6.copyWith(
              color: context.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.won:
        return const Color(0xFF15803D); // green-700
      case MatchStatus.draw:
        return AppColors.gray600;
      case MatchStatus.lost:
        return AppColors.errorDark;
    }
  }

  Color _getStatusBgColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.won:
        return const Color(0xFFDCFCE7); // green-100
      case MatchStatus.draw:
        return AppColors.gray100;
      case MatchStatus.lost:
        return const Color(0xFFFEE2E2); // red-100
    }
  }

  String _getStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.won:
        return 'GANADO';
      case MatchStatus.draw:
        return 'EMPATE';
      case MatchStatus.lost:
        return 'PERDIDO';
    }
  }
}

/// Estado del partido
enum MatchStatus { won, draw, lost }

/// Modelo de resultado de partido
class MatchResult {
  const MatchResult({
    required this.teamCategory,
    required this.opponent,
    required this.competition,
    required this.isHome,
    required this.homeScore,
    required this.awayScore,
    required this.status,
  });

  final String teamCategory;
  final String opponent;
  final String competition;
  final bool isHome;
  final int homeScore;
  final int awayScore;
  final MatchStatus status;

  /// Datos de ejemplo
  static const List<MatchResult> sampleData = [
    MatchResult(
      teamCategory: 'U13',
      opponent: 'North Rangers',
      competition: 'Liga Junior',
      isHome: false,
      homeScore: 3,
      awayScore: 1,
      status: MatchStatus.won,
    ),
    MatchResult(
      teamCategory: 'U17',
      opponent: 'Westside FC',
      competition: 'Primera División',
      isHome: true,
      homeScore: 2,
      awayScore: 2,
      status: MatchStatus.draw,
    ),
    MatchResult(
      teamCategory: 'U15',
      opponent: 'Valley Academy',
      competition: 'Amistoso',
      isHome: true,
      homeScore: 0,
      awayScore: 1,
      status: MatchStatus.lost,
    ),
  ];
}
