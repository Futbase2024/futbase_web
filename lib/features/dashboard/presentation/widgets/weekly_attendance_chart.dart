import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Gráfico semanal de asistencia a entrenamientos
/// Diseño basado en dashboard_principal_futbase (code.html)
/// Muestra un gráfico de línea con la asistencia por día de la semana
class WeeklyAttendanceChart extends StatefulWidget {
  const WeeklyAttendanceChart({
    super.key,
    this.data = const [],
    this.onPeriodChanged,
  });

  final List<AttendancePoint> data;
  final ValueChanged<String>? onPeriodChanged;

  @override
  State<WeeklyAttendanceChart> createState() => _WeeklyAttendanceChartState();
}

class _WeeklyAttendanceChartState extends State<WeeklyAttendanceChart> {
  String _selectedPeriod = 'ESTA SEMANA';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen Semanal',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Asistencia a entrenamientos por día',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
              // Period selector
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 40),
          // Chart
          SizedBox(
            height: 224,
            child: _buildChart(),
          ),
          const SizedBox(height: 24),
          // X-axis labels
          _buildDayLabels(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        isDense: true,
        underline: const SizedBox.shrink(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.gray500,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        items: const [
          DropdownMenuItem(value: 'ESTA SEMANA', child: Text('ESTA SEMANA')),
          DropdownMenuItem(value: 'SEMANA PASADA', child: Text('SEMANA PASADA')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedPeriod = value);
            widget.onPeriodChanged?.call(value);
          }
        },
      ),
    );
  }

  Widget _buildChart() {
    final chartData = widget.data.isNotEmpty ? widget.data : AttendancePoint.sampleData;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.gray50,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: const FlTitlesData(
          show: false,
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.percentage);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}%',
                  const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayLabels() {
    const days = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          return Text(
            day,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray400,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Punto de datos de asistencia
class AttendancePoint {
  const AttendancePoint({
    required this.day,
    required this.percentage,
  });

  final String day;
  final double percentage;

  /// Datos de ejemplo
  static const List<AttendancePoint> sampleData = [
    AttendancePoint(day: 'LUN', percentage: 80),
    AttendancePoint(day: 'MAR', percentage: 93),
    AttendancePoint(day: 'MIE', percentage: 73),
    AttendancePoint(day: 'JUE', percentage: 53),
    AttendancePoint(day: 'VIE', percentage: 47),
    AttendancePoint(day: 'SAB', percentage: 87),
    AttendancePoint(day: 'DOM', percentage: 13),
  ];
}
