import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'match_result_badge.dart';

/// Calendario de competición con próximos partidos
class CompetitionCalendar extends StatelessWidget {
  const CompetitionCalendar({
    super.key,
    required this.matches,
    required this.competitions,
    required this.onEdit,
    required this.onLineup,
  });

  final List<Map<String, dynamic>> matches;
  final Map<int, String> competitions;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onLineup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  size: 20,
                  color: AppColors.primary,
                ),
                AppSpacing.hSpaceSm,
                Text(
                  'Calendario de Competición',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (matches.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${matches.length} partidos',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.vSpaceMd,

        // Tabla de calendario
        if (matches.isEmpty)
          _buildEmptyState()
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray100),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // Header de la tabla
                  _buildTableHeader(),
                  // Filas de partidos
                  ...matches.map((match) => _CalendarRow(
                    match: match,
                    onEdit: () => onEdit(match),
                    onLineup: () => onLineup(match),
                  )),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text('C/F', style: _headerStyle)),
          Expanded(flex: 3, child: Text('RIVAL', style: _headerStyle)),
          SizedBox(width: 80, child: Text('COMP.', style: _headerStyle)),
          Expanded(flex: 4, child: Text('FECHA / ESTADIO', style: _headerStyle)),
          SizedBox(width: 90, child: Text('RESULTADO', style: _headerStyle)),
          SizedBox(
            width: 80,
            child: Text(
              'ACCIONES',
              style: _headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => AppTypography.labelSmall.copyWith(
    color: AppColors.gray600,
    fontWeight: FontWeight.w600,
  );

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
            Icon(Icons.event_available_outlined, size: 48, color: AppColors.gray300),
            AppSpacing.vSpaceMd,
            Text('No hay partidos programados', style: AppTypography.bodyMedium.copyWith(color: AppColors.gray500)),
          ],
        ),
      ),
    );
  }
}

/// Fila de partido en el calendario
class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.match,
    required this.onEdit,
    required this.onLineup,
  });

  final Map<String, dynamic> match;
  final VoidCallback onEdit;
  final VoidCallback onLineup;

  @override
  Widget build(BuildContext context) {
    final rival = match['rival']?.toString() ?? 'Sin rival';
    final casafuera = match['casafuera'];
    final esVisitante = casafuera == 1 || casafuera == true;
    final fecha = _parseDate(match['fecha']);
    final idjornada = match['idjornada'];
    final jcorta = match['jcorta']?.toString();
    final campo = match['campo']?.toString();
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;
    final goles = _toInt(match['goles']);
    final golesrival = _toInt(match['golesrival']);
    final esLiga = idjornada != null;
    final competicionText = esLiga ? (jcorta ?? 'LIGA') : 'AMISTOSO';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          // C/F
          SizedBox(
            width: 50,
            child: Icon(
              esVisitante ? Icons.flight_takeoff : Icons.home,
              size: 20,
              color: esVisitante ? AppColors.error : AppColors.primary,
            ),
          ),

          // Rival
          Expanded(
            flex: 3,
            child: Text(
              rival,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Competición
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: esLiga ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    competicionText,
                    style: AppTypography.caption.copyWith(
                      color: esLiga ? AppColors.primary : AppColors.gray600,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Fecha / Estadio
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: AppColors.gray400),
                    const SizedBox(width: 4),
                    Text(
                      fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'Por definir',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: AppColors.gray400),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        campo ?? 'Por definir',
                        style: AppTypography.caption.copyWith(color: AppColors.gray500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resultado
          SizedBox(
            width: 90,
            child: finalizado && goles != null && golesrival != null
                ? MatchResultBadge(goles: goles, golesrival: golesrival)
                : const SizedBox.shrink(),
          ),

          // Acciones
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                if (!finalizado)
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
            ),
          ),
        ],
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
