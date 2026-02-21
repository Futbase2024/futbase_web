import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../bloc/results_state.dart';

/// Tarjeta de partido en vivo con indicador animado
class ResultsLiveMatchCard extends StatefulWidget {
  const ResultsLiveMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  final MatchWithStatus match;
  final VoidCallback? onTap;

  @override
  State<ResultsLiveMatchCard> createState() => _ResultsLiveMatchCardState();
}

class _ResultsLiveMatchCardState extends State<ResultsLiveMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(
                      alpha: 0.1 + _pulseController.value * 0.15,
                    ),
                    blurRadius: 8 + _pulseController.value * 8,
                    spreadRadius: _pulseController.value * 2,
                  ),
                  ...AppColors.cardShadowLight,
                ],
              ),
              child: child,
            );
          },
          child: Column(
            children: [
              // Badge EN VIVO con minuto
              _LiveIndicator(minuto: widget.match.minuto),
              const SizedBox(height: 16),

              // Equipos y marcador
              _ScoreRow(match: widget.match),

              // Info adicional
              if (widget.match.campo != null || widget.match.jornada != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.match.campo != null) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.match.campo!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                    if (widget.match.campo != null && widget.match.jornada != null)
                      Text(
                        ' · ',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    if (widget.match.jornada != null)
                      Text(
                        widget.match.jornada!,
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
}

/// Indicador "EN VIVO" con punto pulsante y minuto
class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator({this.minuto});

  final int? minuto;

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Punto pulsante
          AnimatedBuilder(
            animation: _dotController,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(
                        alpha: 0.4 + _dotController.value * 0.4,
                      ),
                      blurRadius: 4 + _dotController.value * 4,
                      spreadRadius: _dotController.value * 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'EN VIVO',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          if (widget.minuto != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${widget.minuto}'",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila con los equipos y el marcador
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.match});

  final MatchWithStatus match;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Equipo local
        Expanded(
          child: _TeamColumn(
            name: match.isLocal ? match.equipoNombre : match.rivalNombre,
            escudoUrl: match.isLocal ? match.escudoEquipo : match.escudoRival,
            isMyTeam: match.isLocal,
          ),
        ),

        // Marcador
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _LiveScore(match: match),
        ),

        // Equipo visitante
        Expanded(
          child: _TeamColumn(
            name: match.isLocal ? match.rivalNombre : match.equipoNombre,
            escudoUrl: match.isLocal ? match.escudoRival : match.escudoEquipo,
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

/// Marcador para partido en vivo
class _LiveScore extends StatelessWidget {
  const _LiveScore({required this.match});

  final MatchWithStatus match;

  @override
  Widget build(BuildContext context) {
    final localGoals = match.isLocal ? match.goles : match.golesrival;
    final awayGoals = match.isLocal ? match.golesrival : match.goles;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${localGoals ?? 0}',
            style: AppTypography.h2.copyWith(
              color: match.isLocal ? AppColors.primary : AppColors.gray700,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '-',
            style: AppTypography.h3.copyWith(
              color: AppColors.gray300,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${awayGoals ?? 0}',
            style: AppTypography.h2.copyWith(
              color: match.isLocal ? AppColors.gray700 : AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
