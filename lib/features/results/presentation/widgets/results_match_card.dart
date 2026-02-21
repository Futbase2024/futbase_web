import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../bloc/results_state.dart';

/// Tarjeta de partido normal (finalizado o programado)
class ResultsMatchCard extends StatelessWidget {
  const ResultsMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  final MatchWithStatus match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isScheduled = match.status == MatchStatus.scheduled;

    // Colores según resultado
    final (badgeBgColor, badgeTextColor, resultText) = _getResultColors(
      match.resultText,
      isScheduled,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray100),
            boxShadow: AppColors.cardShadowLight,
          ),
          child: Column(
            children: [
              // Fila superior: fecha y badge de resultado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fecha/Hora
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Badge de resultado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      resultText,
                      style: AppTypography.labelSmall.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Equipos y marcador
              _ScoreRow(match: match, isScheduled: isScheduled),

              // Info adicional (campo y competición)
              if (match.campo != null || match.jornada != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (match.campo != null) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        match.campo!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                    if (match.campo != null && match.jornada != null)
                      Text(
                        ' · ',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    if (match.jornada != null)
                      Text(
                        match.jornada!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime() {
    final fecha = match.fecha;
    final hora = match.hora;

    if (fecha == null && hora == null) return '--/--/----';

    if (fecha != null && hora != null) {
      return '${DateFormat('dd/MM').format(fecha)} · $hora';
    }

    if (fecha != null) {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }

    return hora ?? '';
  }

  (Color, Color, String) _getResultColors(String result, bool isScheduled) {
    if (isScheduled) {
      return (
        AppColors.info.withValues(alpha: 0.1),
        AppColors.info,
        'PROGRAMADO',
      );
    }

    switch (result) {
      case 'VICTORIA':
        return (
          const Color(0xFFEAF7EF),
          const Color(0xFF078830),
          'VICTORIA',
        );
      case 'DERROTA':
        return (
          AppColors.error.withValues(alpha: 0.1),
          AppColors.error,
          'DERROTA',
        );
      case 'EMPATE':
        return (
          AppColors.gray100,
          AppColors.gray600,
          'EMPATE',
        );
      default:
        return (
          AppColors.gray50,
          AppColors.gray500,
          'PENDIENTE',
        );
    }
  }
}

/// Fila con los equipos y el marcador
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.match,
    required this.isScheduled,
  });

  final MatchWithStatus match;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    // Determinar qué va primero según local/visitante
    final myTeamName = match.equipoNombre;
    final rivalName = match.rivalNombre;
    final myTeamGoals = match.isLocal ? match.goles : match.golesrival;
    final rivalGoals = match.isLocal ? match.golesrival : match.goles;
    final myTeamEscudo = match.escudoEquipo;
    final rivalEscudo = match.escudoRival;

    return Row(
      children: [
        // Equipo local (nuestro equipo si es local)
        Expanded(
          child: _TeamColumn(
            name: match.isLocal ? myTeamName : rivalName,
            escudoUrl: match.isLocal ? myTeamEscudo : rivalEscudo,
            isMyTeam: match.isLocal,
          ),
        ),

        // Marcador
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isScheduled
              ? _ScheduledScore(hora: match.hora)
              : _FinishedScore(
                  localGoals: match.isLocal ? myTeamGoals : rivalGoals,
                  awayGoals: match.isLocal ? rivalGoals : myTeamGoals,
                  isLocal: match.isLocal,
                ),
        ),

        // Equipo visitante (rival si somos local)
        Expanded(
          child: _TeamColumn(
            name: match.isLocal ? rivalName : myTeamName,
            escudoUrl: match.isLocal ? rivalEscudo : myTeamEscudo,
            isMyTeam: !match.isLocal,
          ),
        ),
      ],
    );
  }
}

/// Columna con escudo y nombre del equipo
class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.name,
    this.escudoUrl,
    required this.isMyTeam,
  });

  final String name;
  final String? escudoUrl;
  final bool isMyTeam;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TeamShield(
          escudoUrl: escudoUrl,
          isMyTeam: isMyTeam,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTypography.labelSmall.copyWith(
            color: isMyTeam ? AppColors.primary : AppColors.gray600,
            fontWeight: isMyTeam ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Escudo del equipo
class _TeamShield extends StatelessWidget {
  const _TeamShield({
    this.escudoUrl,
    required this.isMyTeam,
  });

  final String? escudoUrl;
  final bool isMyTeam;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: escudoUrl != null && escudoUrl!.isNotEmpty
          ? Image.network(
              escudoUrl!,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildFallback(isLoading: true);
              },
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback({bool isLoading = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gray100),
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gray300,
                ),
              ),
            )
          : Icon(
              isMyTeam ? Icons.shield : Icons.shield_outlined,
              size: 24,
              color: isMyTeam ? AppColors.primary : AppColors.gray400,
            ),
    );
  }
}

/// Marcador para partido programado
class _ScheduledScore extends StatelessWidget {
  const _ScheduledScore({this.hora});

  final String? hora;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          hora ?? '--:--',
          style: AppTypography.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Marcador para partido finalizado
class _FinishedScore extends StatelessWidget {
  const _FinishedScore({
    required this.localGoals,
    required this.awayGoals,
    required this.isLocal,
  });

  final int? localGoals;
  final int? awayGoals;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final myGoals = isLocal ? localGoals : awayGoals;
    final rivalGoals = isLocal ? awayGoals : localGoals;

    // Determinar color según resultado
    Color myGoalsColor = AppColors.gray500;
    Color rivalGoalsColor = AppColors.gray500;

    if (myGoals != null && rivalGoals != null) {
      if (myGoals > rivalGoals) {
        myGoalsColor = AppColors.primary;
        rivalGoalsColor = AppColors.gray400;
      } else if (myGoals < rivalGoals) {
        myGoalsColor = AppColors.gray400;
        rivalGoalsColor = AppColors.error;
      }
    }

    return Row(
      children: [
        Text(
          '${localGoals ?? '-'}',
          style: AppTypography.h3.copyWith(
            color: isLocal ? myGoalsColor : rivalGoalsColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '-',
          style: AppTypography.h4.copyWith(
            color: AppColors.gray300,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${awayGoals ?? '-'}',
          style: AppTypography.h3.copyWith(
            color: isLocal ? rivalGoalsColor : myGoalsColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
