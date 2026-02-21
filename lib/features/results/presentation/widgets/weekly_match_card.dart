import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/results_state.dart';

/// Tarjeta compacta de partido para el calendario semanal
class WeeklyMatchCard extends StatelessWidget {
  const WeeklyMatchCard({
    super.key,
    required this.match,
  });

  final MatchWithStatus match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;
    final isFinished = match.status == MatchStatus.finished;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.accent.withValues(alpha: 0.05)
            : AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLive ? AppColors.accent.withValues(alpha: 0.3) : AppColors.gray100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora y categoría
          Row(
            children: [
              // Hora
              Text(
                match.hora ?? '--:--',
                style: AppTypography.labelSmall.copyWith(
                  color: isLive ? AppColors.accent : AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Indicador Live
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LIVE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.vSpaceXs,

          // Equipos y resultado
          _buildScoreRow(isLive, isFinished),

          AppSpacing.vSpaceXs,

          // Categoría
          if (match.categoria != null)
            Text(
              match.categoria!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray400,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(bool isLive, bool isFinished) {
    final goles = match.goles;
    final golesrival = match.golesrival;
    final hasScore = goles != null && golesrival != null;

    // Determinar colores según resultado
    Color? homeColor;
    Color? awayColor;
    if (isFinished && hasScore) {
      if (match.isLocal) {
        homeColor = goles > golesrival ? AppColors.success :
                    goles < golesrival ? AppColors.error : AppColors.gray500;
        awayColor = goles < golesrival ? AppColors.success :
                    goles > golesrival ? AppColors.error : AppColors.gray500;
      } else {
        awayColor = golesrival > goles ? AppColors.success :
                    golesrival < goles ? AppColors.error : AppColors.gray500;
        homeColor = golesrival < goles ? AppColors.success :
                    golesrival > goles ? AppColors.error : AppColors.gray500;
      }
    }

    return Row(
      children: [
        // Escudo y nombre equipo local
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TeamShield(
                escudoUrl: match.isLocal ? match.match['escudo'] : match.match['escudorival'],
                size: 20,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  match.isLocal ? match.equipoNombre : match.rivalNombre,
                  style: AppTypography.labelSmall.copyWith(
                    color: homeColor ?? AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Marcador
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: hasScore ? AppColors.gray100 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            hasScore ? '$goles - $golesrival' : 'vs',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),

        // Escudo y nombre equipo visitante
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  match.isLocal ? match.rivalNombre : match.equipoNombre,
                  style: AppTypography.labelSmall.copyWith(
                    color: awayColor ?? AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              _TeamShield(
                escudoUrl: match.isLocal ? match.match['escudorival'] : match.match['escudo'],
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Escudo del equipo
class _TeamShield extends StatelessWidget {
  const _TeamShield({
    required this.escudoUrl,
    required this.size,
  });

  final String? escudoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (escudoUrl == null || escudoUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.sports_soccer,
          size: size * 0.6,
          color: AppColors.gray400,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        escudoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer,
              size: size * 0.6,
              color: AppColors.gray400,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.gray400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
