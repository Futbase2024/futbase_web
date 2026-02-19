import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Tabla de sesiones de entrenamiento
class TrainingsTable extends StatelessWidget {
  const TrainingsTable({
    super.key,
    required this.trainings,
    required this.onEdit,
    required this.onDelete,
    required this.onAttendance,
  });

  final List<Map<String, dynamic>> trainings;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onAttendance;

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
              label: Text('LUGAR'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('OBSERVACIONES'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('ESTADO'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('ACCIONES'),
              size: ColumnSize.S,
              numeric: true,
            ),
          ],
          rows: trainings.map((training) {
            return DataRow2(
              cells: [
                // Fecha / Hora
                DataCell(_buildDateCell(training)),
                // Lugar
                DataCell(
                  Text(
                    training['campo']?.toString() ?? 'Sin asignar',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Observaciones
                DataCell(
                  Text(
                    training['observaciones']?.toString() ?? '-',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Estado
                DataCell(_buildStatusBadge(training)),
                // Acciones
                DataCell(_buildActions(training)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateCell(Map<String, dynamic> training) {
    final fecha = _parseDate(training['fecha']);
    final horaInicio = training['hinicio']?.toString() ?? '';
    final horaFin = training['hfin']?.toString() ?? '';

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
        if (horaInicio.isNotEmpty)
          Text(
            horaFin.isNotEmpty ? '$horaInicio - $horaFin' : horaInicio,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> training) {
    final fecha = _parseDate(training['fecha']);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final finalizado = training['finalizado'] == true;

    String status;
    Color bgColor;
    Color textColor;

    if (finalizado || (fecha != null && fecha.isBefore(today))) {
      status = 'Completado';
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
    } else if (fecha != null &&
        fecha.year == today.year &&
        fecha.month == today.month &&
        fecha.day == today.day) {
      status = 'En Curso';
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
    } else {
      status = 'Programado';
      bgColor = AppColors.info.withValues(alpha: 0.1);
      textColor = AppColors.info;
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

  Widget _buildActions(Map<String, dynamic> training) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Asistencia
        Tooltip(
          message: 'Asistencia',
          child: IconButton(
            onPressed: () => onAttendance(training),
            icon: const Icon(Icons.fact_check_outlined),
            iconSize: 18,
            color: AppColors.primary,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ),
        // Editar
        Tooltip(
          message: 'Editar',
          child: IconButton(
            onPressed: () => onEdit(training),
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
            onPressed: () => onDelete(training),
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
