import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Lista de próximos partidos
/// Diseño basado en dashboard_principal_futbase (code.html)
/// Muestra una lista vertical de partidos programados
class UpcomingMatchesList extends StatelessWidget {
  const UpcomingMatchesList({
    super.key,
    this.matches = const [],
    this.onViewAll,
  });

  final List<UpcomingMatch> matches;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Próximos Partidos',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'VER TODO',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Matches list
          ...matches.map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MatchItem(match: match),
              )),
        ],
      ),
    );
  }
}

class _MatchItem extends StatelessWidget {
  const _MatchItem({required this.match});

  final UpcomingMatch match;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
          ),
          child: Row(
            children: [
              // Team badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    match.teamInitials,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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
                      '${match.teamName} vs ${match.opponent}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match.schedule,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Match type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: match.isLeague ? AppColors.primary : AppColors.gray400,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  match.isLeague ? 'LIGA' : 'AMISTOSO',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modelo de próximo partido
class UpcomingMatch {
  const UpcomingMatch({
    required this.teamInitials,
    required this.teamName,
    required this.opponent,
    required this.schedule,
    this.isLeague = true,
  });

  final String teamInitials;
  final String teamName;
  final String opponent;
  final String schedule;
  final bool isLeague;

  /// Datos de ejemplo
  static const List<UpcomingMatch> sampleData = [
    UpcomingMatch(
      teamInitials: 'VCF',
      teamName: 'Alevín A',
      opponent: 'Rival 1',
      schedule: 'Sábado, 10:00 • Campo 1',
      isLeague: true,
    ),
    UpcomingMatch(
      teamInitials: 'LEH',
      teamName: 'Cadete B',
      opponent: 'Rival 2',
      schedule: 'Sábado, 12:30 • Campo Principal',
      isLeague: false,
    ),
    UpcomingMatch(
      teamInitials: 'AMB',
      teamName: 'Prebenjamín',
      opponent: 'Rival 3',
      schedule: 'Domingo, 09:30 • Campo 3',
      isLeague: true,
    ),
  ];
}
