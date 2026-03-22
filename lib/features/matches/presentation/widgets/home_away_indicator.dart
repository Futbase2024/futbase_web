import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Indicador visual de partido en casa o fuera
class HomeAwayIndicator extends StatelessWidget {
  const HomeAwayIndicator({
    super.key,
    required this.isAway,
    this.size = 20.0,
    this.showLabel = false,
  });

  final bool isAway;
  final double size;
  final bool showLabel;

  /// Crea un indicador desde datos de partido
  factory HomeAwayIndicator.fromMatch({
    Key? key,
    required Map<String, dynamic> match,
    double size = 20.0,
    bool showLabel = false,
  }) {
    final casafuera = match['casafuera'];
    final isAway = casafuera == 1 || casafuera == true;

    return HomeAwayIndicator(
      key: key,
      isAway: isAway,
      size: size,
      showLabel: showLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isAway ? AppColors.error : AppColors.primary;
    final icon = isAway ? Icons.flight_takeoff : Icons.home;
    final label = isAway ? 'Fuera' : 'Casa';

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: size * 0.6,
            ),
          ),
        ],
      );
    }

    return Icon(icon, size: size, color: color);
  }
}
