import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'match_list_header.dart';
import 'result_style.dart';

/// Lista de resultados recientes con diseño de scorecard
class RecentResultsList extends StatelessWidget {
  const RecentResultsList({
    super.key,
    required this.matches,
    required this.competitions,
    this.onTap,
    this.onVerHistorial,
    this.showAll = false,
  });

  final List<Map<String, dynamic>> matches;
  final Map<int, String> competitions;
  final void Function(Map<String, dynamic>)? onTap;
  final VoidCallback? onVerHistorial;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección usando widget estandarizado
        MatchListHeader.recentResults(
          count: matches.isNotEmpty ? matches.length : null,
        ),
        AppSpacing.vSpaceMd,

        // Lista de scorecards
        if (matches.isEmpty)
          _buildEmptyState()
        else
          ...matches.map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ScoreCard(
                  match: match,
                  onTap: onTap != null ? () => onTap!(match) : null,
                ),
              )),

        // Botón ver historial (solo si no se están mostrando todos)
        if (matches.isNotEmpty && !showAll)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerHistorial,
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Ver todo el Historial'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.gray100),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.sports_soccer_outlined,
              size: 48,
              color: AppColors.gray300,
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No hay resultados recientes',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.match,
    this.onTap,
  });

  final Map<String, dynamic> match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rival = match['rival']?.toString() ?? 'Sin rival';
    final casafuera = match['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);
    final goles = _toInt(match['goles']);
    final golesrival = _toInt(match['golesrival']);
    final fecha = _parseDate(match['fecha']);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
            boxShadow: AppColors.cardShadowLight,
          ),
          child: Column(
            children: [
              // Fecha y badge de resultado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fecha != null
                        ? DateFormat('dd/MM/yyyy').format(fecha)
                        : '--/--/----',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  _buildResultBadge(goles: goles, golesrival: golesrival),
                ],
              ),
              const SizedBox(height: 16),

              // Equipos y marcador
              Row(
                children: [
                  // Equipo Local
                  Expanded(
                    child: Column(
                      children: [
                        _TeamShield(
                          isMyTeam: local,
                          rivalName: rival,
                          escudoUrl: local
                              ? match['escudo']?.toString()
                              : match['escudorival']?.toString(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          local
                              ? (match['ncortoequipo']?.toString() ?? match['equipo']?.toString() ?? 'Mi Equipo')
                              : rival,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Marcador (formato: Goles Local - Goles Visitante)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${local ? goles : golesrival ?? '-'}',
                          style: AppTypography.h3.copyWith(
                            color: local ? AppColors.primary : AppColors.gray500,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '-',
                          style: AppTypography.h4.copyWith(
                            color: AppColors.gray200,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${local ? golesrival : goles ?? '-'}',
                          style: AppTypography.h3.copyWith(
                            color: !local ? AppColors.primary : AppColors.gray500,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Equipo Visitante
                  Expanded(
                    child: Column(
                      children: [
                        _TeamShield(
                          isMyTeam: !local,
                          rivalName: rival,
                          escudoUrl: !local
                              ? match['escudo']?.toString()
                              : match['escudorival']?.toString(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          !local
                              ? (match['ncortoequipo']?.toString() ?? match['equipo']?.toString() ?? 'Mi Equipo')
                              : rival,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Badge de resultado usando ResultStyle para colores consistentes
  Widget _buildResultBadge({
    required int? goles,
    required int? golesrival,
  }) {
    if (goles == null || golesrival == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'PENDIENTE',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray500,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      );
    }

    final style = ResultStyle.fromScore(goles: goles, golesrival: golesrival);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.text.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: style.color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    return DateTime.tryParse(dateValue.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class _TeamShield extends StatelessWidget {
  const _TeamShield({
    required this.isMyTeam,
    required this.rivalName,
    this.escudoUrl,
  });

  final bool isMyTeam;
  final String rivalName;
  final String? escudoUrl;

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
              errorBuilder: (context, error, stackTrace) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gray100),
                ),
                child: Icon(
                  isMyTeam ? Icons.shield : Icons.shield_outlined,
                  size: 24,
                  color: isMyTeam ? AppColors.primary : AppColors.gray400,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMyTeam ? Icons.shield : Icons.shield_outlined,
                    size: 24,
                    color: AppColors.gray300,
                  ),
                );
              },
            )
          : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gray100),
              ),
              child: Icon(
                isMyTeam ? Icons.shield : Icons.shield_outlined,
                size: 24,
                color: isMyTeam ? AppColors.primary : AppColors.gray400,
              ),
            ),
    );
  }
}
