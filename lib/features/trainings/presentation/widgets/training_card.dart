import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Tarjeta individual de entrenamiento
class TrainingCard extends StatelessWidget {
  const TrainingCard({
    super.key,
    required this.training,
    required this.typeName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAttendance,
    this.attendancePercentage,
  });

  final Map<String, dynamic> training;
  final String? typeName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAttendance;
  final double? attendancePercentage;

  @override
  Widget build(BuildContext context) {
    final fecha = _parseDate(training['fecha']);
    final horaInicio = training['hinicio']?.toString() ?? '';
    final horaFin = training['hfin']?.toString() ?? '';
    final observaciones = training['observaciones']?.toString() ?? '';
    final isPast = fecha != null && fecha.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadowLight,
        border: Border.all(
          color: isPast ? AppColors.gray200 : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Indicador de fecha
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.gray100
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        fecha != null ? DateFormat('MMM').format(fecha).toUpperCase() : '--',
                        style: AppTypography.labelSmall.copyWith(
                          color: isPast ? AppColors.gray500 : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fecha != null ? fecha.day.toString() : '--',
                        style: AppTypography.h4.copyWith(
                          color: isPast ? AppColors.gray600 : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSpaceMd,
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Tipo de entrenamiento
                          if (typeName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                typeName!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const Spacer(),
                          // Hora
                          if (horaInicio.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColors.gray500,
                                ),
                                AppSpacing.hSpaceXs,
                                Text(
                                  horaFin.isNotEmpty
                                      ? '$horaInicio - $horaFin'
                                      : horaInicio,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (observaciones.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          observaciones,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Asistencia
                      if (attendancePercentage != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: AppColors.gray500,
                            ),
                            AppSpacing.hSpaceXs,
                            Text(
                              '${attendancePercentage!.toStringAsFixed(0)}% asistencia',
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
                AppSpacing.hSpaceMd,
                // Acciones
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón asistencia
                    Tooltip(
                      message: 'Asistencia',
                      child: IconButton(
                        onPressed: onAttendance,
                        icon: const Icon(Icons.fact_check_outlined),
                        iconSize: 20,
                        color: AppColors.primary,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    // Botón editar
                    Tooltip(
                      message: 'Editar',
                      child: IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20,
                        color: AppColors.gray500,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    // Botón eliminar
                    Tooltip(
                      message: 'Eliminar',
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        color: AppColors.error,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    return DateTime.tryParse(dateValue.toString());
  }
}
