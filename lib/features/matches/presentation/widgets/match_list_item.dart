import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'competition_badge.dart';
import 'home_away_indicator.dart';
import 'match_result_badge.dart';

/// Fila de partido reutilizable que combina todos los widgets
class MatchListItem extends StatelessWidget {
  const MatchListItem({
    super.key,
    required this.match,
    this.onTap,
    this.onEdit,
    this.onLineup,
    this.showResult = true,
    this.showActions = true,
    this.compact = false,
  });

  final Map<String, dynamic> match;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onLineup;
  final bool showResult;
  final bool showActions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rival = match['rival']?.toString() ?? 'Sin rival';
    final fecha = _parseDate(match['fecha']);
    final campo = match['campo']?.toString();
    final goles = _toInt(match['goles']);
    final golesrival = _toInt(match['golesrival']);
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray100),
            boxShadow: AppColors.cardShadowLight,
          ),
          child: Row(
            children: [
              // Indicador Casa/Fuera
              HomeAwayIndicator.fromMatch(match: match),
              AppSpacing.hSpaceMd,

              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rival
                    Text(
                      rival,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
                      AppSpacing.vSpaceXs,
                      // Fecha y campo
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Text(
                            fecha != null
                                ? DateFormat('dd/MM/yyyy').format(fecha)
                                : 'Por definir',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                          if (campo != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_outlined, size: 12, color: AppColors.gray400),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                campo,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.gray500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Badge de competición
              CompetitionBadge.fromMatch(match: match, size: CompetitionBadgeSize.small),
              AppSpacing.hSpaceMd,

              // Resultado
              if (showResult && finalizado && goles != null && golesrival != null)
                MatchResultBadge(
                  goles: goles,
                  golesrival: golesrival,
                  size: MatchResultBadgeSize.small,
                )
              else if (showResult)
                Text(
                  '-',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                ),

              // Acciones
              if (showActions) ...[
                AppSpacing.hSpaceMd,
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onLineup != null)
          Tooltip(
            message: 'Alineación',
            child: InkWell(
              onTap: onLineup,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.group_outlined, size: 18, color: AppColors.info),
              ),
            ),
          ),
        if (onEdit != null)
          Tooltip(
            message: 'Editar',
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.edit_outlined, size: 18, color: AppColors.gray400),
              ),
            ),
          ),
      ],
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

/// Versión compacta del MatchListItem para listas densas
class MatchListItemCompact extends StatelessWidget {
  const MatchListItemCompact({
    super.key,
    required this.match,
    this.onTap,
  });

  final Map<String, dynamic> match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MatchListItem(
      match: match,
      onTap: onTap,
      showActions: false,
      compact: true,
    );
  }
}
