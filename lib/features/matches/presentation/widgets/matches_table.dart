import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// Note: DataTable2, DataColumn2, DataRow2, ColumnSize are defined at the end of this file

/// Tabla de partidos
class MatchesTable extends StatelessWidget {
  const MatchesTable({
    super.key,
    required this.matches,
    required this.competitions,
    required this.onEdit,
    required this.onDelete,
    required this.onLineup,
  });

  final List<Map<String, dynamic>> matches;
  final Map<int, String> competitions;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onLineup;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadowLight,
        border: Border.all(color: AppColors.gray100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable2(
          columnSpacing: 16,
          horizontalMargin: 20,
          headingRowColor: WidgetStateProperty.all(AppColors.gray50),
          headingTextStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.gray600,
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.gray700,
          ),
          columns: const [
            DataColumn2(
              label: Text('FECHA / HORA'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('RIVAL'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('COMPETICIÓN'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('RESULTADO'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('ESTADO'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('ACCIONES'),
              size: ColumnSize.M,
              numeric: true,
            ),
          ],
          rows: matches.map((match) {
            return DataRow2(
              cells: [
                // Fecha / Hora
                DataCell(_buildDateCell(match)),
                // Rival
                DataCell(_buildRivalCell(match)),
                // Competición
                DataCell(_buildCompetitionCell(match)),
                // Resultado
                DataCell(_buildResultCell(match)),
                // Estado
                DataCell(_buildStatusBadge(match)),
                // Acciones
                DataCell(_buildActions(match)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateCell(Map<String, dynamic> match) {
    final fecha = _parseDate(match['fecha']);
    // Campo 'hora' de vpartido (ej: "10:00")
    final hora = match['hora']?.toString() ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : '--/--/----',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (hora.isNotEmpty)
          Text(
            hora,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
      ],
    );
  }

  Widget _buildRivalCell(Map<String, dynamic> match) {
    final rival = match['rival']?.toString() ?? 'Sin rival';
    // casafuera: 1 = visitante, 0 o null = local (campo de vpartido)
    final casafuera = match['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          local ? Icons.home : Icons.flight_takeoff,
          size: 16,
          color: local ? AppColors.success : AppColors.info,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                local ? 'vs $rival' : '@ $rival',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                local ? 'Local' : 'Visitante',
                style: AppTypography.labelSmall.copyWith(
                  color: local ? AppColors.success : AppColors.info,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitionCell(Map<String, dynamic> match) {
    // Usar idjornada y jornada de vpartido
    final idJornada = match['idjornada'] as int?;
    // Preferir el campo jornada directamente del match, sino buscar en el map
    final jornada = match['jornada']?.toString() ??
        (idJornada != null ? competitions[idJornada] : null);

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            jornada ?? 'Sin competición',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCell(Map<String, dynamic> match) {
    // Campos de vpartido: goles (nuestros), golesrival (del rival), finalizado
    final goles = _toInt(match['goles']);
    final golesrival = _toInt(match['golesrival']);
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;

    if (!finalizado || goles == null || golesrival == null) {
      return Text(
        '-',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.gray400,
        ),
      );
    }

    // goles = nuestros goles, golesrival = goles del rival
    final nuestrosGoles = goles;
    final susGoles = golesrival;
    final resultado = '$goles - $golesrival';

    Color resultColor;
    if (nuestrosGoles > susGoles) {
      resultColor = AppColors.success;
    } else if (nuestrosGoles < susGoles) {
      resultColor = AppColors.error;
    } else {
      resultColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        resultado,
        style: AppTypography.labelMedium.copyWith(
          color: resultColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Widget _buildStatusBadge(Map<String, dynamic> match) {
    final fecha = _parseDate(match['fecha']);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // finalizado en vpartido es int: 1 = finalizado, 0 = no finalizado
    final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;

    String status;
    Color bgColor;
    Color textColor;

    if (finalizado) {
      status = 'Finalizado';
      bgColor = AppColors.gray500.withValues(alpha: 0.1);
      textColor = AppColors.gray500;
    } else if (fecha != null &&
        fecha.year == today.year &&
        fecha.month == today.month &&
        fecha.day == today.day) {
      status = 'Hoy';
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
    } else if (fecha != null && fecha.isAfter(today)) {
      status = 'Programado';
      bgColor = AppColors.info.withValues(alpha: 0.1);
      textColor = AppColors.info;
    } else {
      status = 'Pendiente';
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> match) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Alineación
        Tooltip(
          message: 'Alineación',
          child: IconButton(
            onPressed: () => onLineup(match),
            icon: const Icon(Icons.group),
            iconSize: 18,
            color: AppColors.info,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ),
        // Editar
        Tooltip(
          message: 'Editar',
          child: IconButton(
            onPressed: () => onEdit(match),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 18,
            color: AppColors.gray500,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ),
        // Eliminar
        Tooltip(
          message: 'Eliminar',
          child: IconButton(
            onPressed: () => onDelete(match),
            icon: const Icon(Icons.delete_outline),
            iconSize: 18,
            color: AppColors.error,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    return DateTime.tryParse(dateValue.toString());
  }
}

/// DataColumn2 con soporte para tamaño
enum ColumnSize { S, M, L }

class DataColumn2 extends DataColumn {
  const DataColumn2({
    required super.label,
    this.size = ColumnSize.M,
    super.tooltip,
    super.numeric = false,
    super.onSort,
  });

  final ColumnSize size;
}

/// DataRow2 para uso con DataTable2
class DataRow2 extends DataRow {
  const DataRow2({
    required super.cells,
    super.selected = false,
    super.onSelectChanged,
    super.color,
  });
}

/// DataTable2 con columnas de tamaño variable
class DataTable2 extends StatelessWidget {
  const DataTable2({
    super.key,
    required this.columns,
    required this.rows,
    this.columnSpacing = 16,
    this.horizontalMargin = 20,
    this.headingRowColor,
    this.headingTextStyle,
    this.dataTextStyle,
  });

  final List<DataColumn2> columns;
  final List<DataRow2> rows;
  final double columnSpacing;
  final double horizontalMargin;
  final WidgetStateProperty<Color?>? headingRowColor;
  final TextStyle? headingTextStyle;
  final TextStyle? dataTextStyle;

  double _getColumnWidth(ColumnSize size) {
    return switch (size) {
      ColumnSize.S => 80.0,
      ColumnSize.M => 140.0,
      ColumnSize.L => 200.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Calcular ancho total de la tabla
    final totalWidth = columns.fold<double>(
      0,
      (sum, col) => sum + _getColumnWidth(col.size) + horizontalMargin,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth.clamp(constraints.maxWidth, double.infinity),
            child: Table(
              defaultColumnWidth: const FlexColumnWidth(),
              columnWidths: {
                for (int i = 0; i < columns.length; i++)
                  i: FixedColumnWidth(_getColumnWidth(columns[i].size)),
              },
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: headingRowColor?.resolve({}),
                  ),
                  children: columns.map((col) {
                    return Container(
                      height: 48,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalMargin / 2,
                      ),
                      alignment: col.numeric
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: DefaultTextStyle(
                        style: headingTextStyle ?? AppTypography.labelSmall,
                        child: col.label,
                      ),
                    );
                  }).toList(),
                ),
                // Data rows
                ...rows.map((row) {
                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.gray100,
                          width: 1,
                        ),
                      ),
                    ),
                    children: row.cells.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final cell = entry.value;
                      return Container(
                        height: 64,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalMargin / 2,
                          vertical: 8,
                        ),
                        alignment: columns[idx].numeric
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: DefaultTextStyle(
                          style: dataTextStyle ?? AppTypography.bodySmall,
                          child: cell.child,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
