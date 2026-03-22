import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Estilos visuales para resultados de partidos
enum MatchResultType {
  victory,
  defeat,
  draw,
}

/// Clase auxiliar para obtener estilos de resultado
class ResultStyle {
  const ResultStyle._({
    required this.color,
    required this.icon,
    required this.text,
    required this.type,
  });

  final Color color;
  final IconData icon;
  final String text;
  final MatchResultType type;

  /// Obtiene el estilo basado en el marcador
  factory ResultStyle.fromScore({
    required int goles,
    required int golesrival,
  }) {
    if (goles > golesrival) {
      return const ResultStyle._(
        color: AppColors.primary,
        icon: Icons.emoji_events_outlined,
        text: 'Victoria',
        type: MatchResultType.victory,
      );
    } else if (goles < golesrival) {
      return const ResultStyle._(
        color: AppColors.error,
        icon: Icons.close,
        text: 'Derrota',
        type: MatchResultType.defeat,
      );
    } else {
      return const ResultStyle._(
        color: AppColors.gray800,
        icon: Icons.handshake_outlined,
        text: 'Empate',
        type: MatchResultType.draw,
      );
    }
  }

  /// Color de fondo con transparencia
  Color get backgroundColor => color.withValues(alpha: 0.1);

  /// Color de fondo más intenso
  Color get backgroundStrong => color.withValues(alpha: 0.15);
}
