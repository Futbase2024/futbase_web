import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Gráfico de tendencia de asistencia (últimas 8 semanas)
class AttendanceTrendChart extends StatelessWidget {
  const AttendanceTrendChart({
    super.key,
    required this.weeklyData,
    this.height = 200,
  });

  /// Datos semanales: lista de [semana, porcentaje_asistencia]
  final List<AttendanceWeekData> weeklyData;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tendencia de Asistencia',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Últimas 8 semanas',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico
          SizedBox(
            height: height,
            child: weeklyData.isEmpty
                ? _buildEmptyState()
                : _buildChart(),
          ),

          // Leyenda
          if (weeklyData.isNotEmpty) _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: AppColors.gray300,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin datos de tendencia',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray400,
            ),
          ),
          Text(
            'Los datos aparecerán cuando haya entrenamientos registrados',
            style: AppTypography.caption.copyWith(
              color: AppColors.gray400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = <FlSpot>[];
    final bottomTitles = <String>[];

    for (var i = 0; i < weeklyData.length; i++) {
      final data = weeklyData[i];
      spots.add(FlSpot(i.toDouble(), data.percentage));
      bottomTitles.add(_getWeekLabel(data.weekNumber));
    }

    // Añadir punto extra para visualización si hay pocos datos
    if (spots.length < 2) {
      spots.add(FlSpot(1, spots.first.y));
      bottomTitles.add('');
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.gray100,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= bottomTitles.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    bottomTitles[index],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gray500,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.gray200),
            left: BorderSide(color: AppColors.gray200),
          ),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.gray900,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                String weekLabel = '';
                if (index >= 0 && index < weeklyData.length) {
                  weekLabel = 'Semana ${weeklyData[index].weekNumber}';
                }
                return LineTooltipItem(
                  '$weekLabel\n${spot.y.toStringAsFixed(1)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final value = spot.y;
                Color dotColor = AppColors.success;
                if (value < 70) dotColor = AppColors.error;
                if (value < 85 && value >= 70) dotColor = AppColors.warning;

                return FlDotCirclePainter(
                  radius: 4,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Línea de objetivo 85%
            HorizontalLine(
              y: 85,
              color: AppColors.success.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontSize: 9,
                ),
                labelResolver: (_) => 'Objetivo 85%',
              ),
            ),
            // Línea de alerta 70%
            HorizontalLine(
              y: 70,
              color: AppColors.error.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                  fontSize: 9,
                ),
                labelResolver: (_) => 'Alerta 70%',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: AppColors.success, label: '≥85%'),
          const SizedBox(width: 16),
          _LegendItem(color: AppColors.warning, label: '70-84%'),
          const SizedBox(width: 16),
          _LegendItem(color: AppColors.error, label: '<70%'),
        ],
      ),
    );
  }

  String _getWeekLabel(int weekNumber) {
    return 'S$weekNumber';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.gray600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Datos de asistencia semanal
class AttendanceWeekData {
  final int weekNumber;
  final DateTime startDate;
  final double percentage;
  final int totalTrainings;
  final int totalPresent;

  const AttendanceWeekData({
    required this.weekNumber,
    required this.startDate,
    required this.percentage,
    required this.totalTrainings,
    required this.totalPresent,
  });
}
