import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Gráfico circular de estadísticas de entrenamientos
class TrainingsChart extends StatelessWidget {
  const TrainingsChart({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.scheduled,
    this.averageAttendance = 0.0,
  });

  final int completed;
  final int inProgress;
  final int scheduled;
  final double averageAttendance;

  int get total => completed + inProgress + scheduled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadowLight,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.hSpaceSm,
              Text(
                'Resumen de Sesiones',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceLg,
          Row(
            children: [
              // Gráfico circular
              SizedBox(
                width: 160,
                height: 160,
                child: total > 0
                    ? PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 45,
                          sections: _buildSections(),
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              // No action needed for now
                            },
                          ),
                        ),
                      )
                    : _buildEmptyChart(),
              ),
              AppSpacing.hSpaceLg,
              // Leyenda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: AppColors.success,
                      label: 'Completados',
                      value: completed,
                      percentage: total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0',
                    ),
                    AppSpacing.vSpaceSm,
                    _LegendItem(
                      color: AppColors.warning,
                      label: 'En Curso',
                      value: inProgress,
                      percentage: total > 0 ? (inProgress / total * 100).toStringAsFixed(0) : '0',
                    ),
                    AppSpacing.vSpaceSm,
                    _LegendItem(
                      color: AppColors.info,
                      label: 'Programados',
                      value: scheduled,
                      percentage: total > 0 ? (scheduled / total * 100).toStringAsFixed(0) : '0',
                    ),
                    AppSpacing.vSpaceMd,
                    const Divider(),
                    AppSpacing.vSpaceSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        Text(
                          '$total sesiones',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (averageAttendance > 0) ...[
            AppSpacing.vSpaceMd,
            const Divider(),
            AppSpacing.vSpaceSm,
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                AppSpacing.hSpaceSm,
                Text(
                  'Asistencia Media:',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${averageAttendance.toStringAsFixed(0)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: _getAttendanceColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final completedPercent = completed / total;
    final inProgressPercent = inProgress / total;
    final scheduledPercent = scheduled / total;

    return [
      PieChartSectionData(
        color: AppColors.success,
        value: completed.toDouble(),
        title: completedPercent > 0.1 ? '${(completedPercent * 100).toStringAsFixed(0)}%' : '',
        radius: 30,
        titleStyle: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      PieChartSectionData(
        color: AppColors.warning,
        value: inProgress.toDouble(),
        title: inProgressPercent > 0.1 ? '${(inProgressPercent * 100).toStringAsFixed(0)}%' : '',
        radius: 30,
        titleStyle: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      PieChartSectionData(
        color: AppColors.info,
        value: scheduled.toDouble(),
        title: scheduledPercent > 0.1 ? '${(scheduledPercent * 100).toStringAsFixed(0)}%' : '',
        radius: 30,
        titleStyle: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 40,
            color: AppColors.gray300,
          ),
          AppSpacing.vSpaceXs,
          Text(
            'Sin datos',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor() {
    if (averageAttendance >= 80) return AppColors.success;
    if (averageAttendance >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  final Color color;
  final String label;
  final int value;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        AppSpacing.hSpaceSm,
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
