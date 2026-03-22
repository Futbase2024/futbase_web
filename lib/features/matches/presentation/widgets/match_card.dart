import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'match_result_badge.dart';

/// Tarjeta de partido con diseño profesional
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onEdit,
    this.onLineup,
    this.showActions = true,
    this.compact = false,
  });

  final Map<String, dynamic> match;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onLineup;
  final bool showActions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rival = match['rival']?.toString() ?? 'Sin rival';
    final casafuera = match['casafuera'];
    final esVisitante = casafuera == 1 || casafuera == true;
    final fecha = _parseDate(match['fecha']);
    final campo = match['campo']?.toString();
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;
    final goles = _toInt(match['goles']);
    final golesrival = _toInt(match['golesrival']);
    final idjornada = match['idjornada'];
    final jcorta = match['jcorta']?.toString();
    final esLiga = idjornada != null;
    final competicionText = esLiga ? (jcorta ?? 'LIGA') : 'AMISTOSO';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Competición + Estado
              _buildHeader(competicionText, esLiga, fecha, finalizado),
              AppSpacing.vSpaceSm,

              // Cuerpo principal
              _buildBody(rival, esVisitante, goles, golesrival, finalizado),

              if (!compact) ...[
                AppSpacing.vSpaceSm,
                // Ubicación
                _buildLocation(campo),
              ],

              if (showActions && (onEdit != null || onLineup != null)) ...[
                AppSpacing.vSpaceSm,
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String competicion, bool esLiga, DateTime? fecha, bool finalizado) {
    return Row(
      children: [
        // Badge competición
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: esLiga ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            competicion,
            style: AppTypography.labelSmall.copyWith(
              color: esLiga ? AppColors.primary : AppColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        // Fecha
        if (fecha != null)
          Text(
            DateFormat('dd/MM/yyyy').format(fecha),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
      ],
    );
  }

  Widget _buildBody(String rival, bool esVisitante, int? goles, int? golesrival, bool finalizado) {
    return Row(
      children: [
        // Icono casa/fuera
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: esVisitante
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            esVisitante ? Icons.flight_takeoff : Icons.home,
            size: 20,
            color: esVisitante ? AppColors.error : AppColors.primary,
          ),
        ),
        AppSpacing.hSpaceMd,

        // Rival
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esVisitante ? '@ $rival' : 'vs $rival',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                esVisitante ? 'Visitante' : 'Local',
                style: AppTypography.labelSmall.copyWith(
                  color: esVisitante ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Resultado
        if (finalizado && goles != null && golesrival != null)
          MatchResultBadge(
            goles: goles,
            golesrival: golesrival,
            size: MatchResultBadgeSize.medium,
          ),
      ],
    );
  }

  Widget _buildLocation(String? campo) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14, color: AppColors.gray400),
        const SizedBox(width: 4),
        Text(
          campo ?? 'Por definir',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onLineup != null)
          TextButton.icon(
            onPressed: onLineup,
            icon: const Icon(Icons.group_outlined, size: 18),
            label: const Text('Alineación'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.info,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray500,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
