import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Badge de competición reutilizable
class CompetitionBadge extends StatelessWidget {
  const CompetitionBadge({
    super.key,
    required this.text,
    this.isLiga = true,
    this.size = CompetitionBadgeSize.small,
  });

  final String text;
  final bool isLiga;
  final CompetitionBadgeSize size;

  /// Crea un badge desde datos de partido
  factory CompetitionBadge.fromMatch({
    Key? key,
    required Map<String, dynamic> match,
    CompetitionBadgeSize size = CompetitionBadgeSize.small,
  }) {
    final idjornada = match['idjornada'];
    final jcorta = match['jcorta']?.toString();
    final esLiga = idjornada != null;
    final competicionText = esLiga ? (jcorta ?? 'LIGA') : 'AMISTOSO';

    return CompetitionBadge(
      key: key,
      text: competicionText,
      isLiga: esLiga,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = size == CompetitionBadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final fontSize = size == CompetitionBadgeSize.small ? 9.0 : 11.0;
    final borderRadius = size == CompetitionBadgeSize.small ? 4.0 : 6.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isLiga
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray100,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: isLiga ? AppColors.primary : AppColors.gray600,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tamaños disponibles para el badge de competición
enum CompetitionBadgeSize { small, medium }
