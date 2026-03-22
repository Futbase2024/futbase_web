import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import 'result_style.dart';

/// Badge de resultado de partido con diseño profesional y animación
class MatchResultBadge extends StatelessWidget {
  const MatchResultBadge({
    super.key,
    required this.goles,
    required this.golesrival,
    this.showIcon = true,
    this.showText = false,
    this.size = MatchResultBadgeSize.small,
    this.animate = true,
  });

  final int goles;
  final int golesrival;
  final bool showIcon;
  final bool showText;
  final MatchResultBadgeSize size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final style = ResultStyle.fromScore(goles: goles, golesrival: golesrival);
    final padding = size == MatchResultBadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    final iconSize = size == MatchResultBadgeSize.small ? 14.0 : 18.0;
    final fontSize = size == MatchResultBadgeSize.small ? 12.0 : 14.0;

    final badge = IntrinsicWidth(
      child: AnimatedContainer(
        duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              AnimatedSwitcher(
                duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
                child: Icon(
                  style.icon,
                  key: ValueKey(style.icon),
                  size: iconSize,
                  color: style.color,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              showText ? style.text : '$goles-$golesrival',
              style: AppTypography.labelSmall.copyWith(
                color: style.color,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );

    return Align(alignment: Alignment.centerLeft, child: badge);
  }
}

/// Tamaños disponibles para el badge
enum MatchResultBadgeSize { small, medium }
