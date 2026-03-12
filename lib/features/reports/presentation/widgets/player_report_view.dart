import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/report_data.dart';
import '../../domain/report_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Vista del informe de jugador
class PlayerReportView extends StatelessWidget {
  const PlayerReportView({
    super.key,
    required this.data,
    required this.filter,
    required this.availablePlayers,
    required this.onBack,
    required this.onExportPdf,
    required this.onExportExcel,
  });

  final PlayerReportData data;
  final ReportFilter filter;
  final List<Map<String, dynamic>> availablePlayers;
  final VoidCallback onBack;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header con acciones
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        // Contenido principal
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info del jugador
                _buildPlayerInfoCard(),
                const SizedBox(height: 24),

                // Stats grid
                _buildStatsGrid(),
                const SizedBox(height: 24),

                // Gráfico de rendimiento
                _buildPerformanceChart(),
                const SizedBox(height: 24),

                // Asistencia a entrenamientos
                _buildAttendanceCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.gray700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Informe de Jugador',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onExportExcel,
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                data.dorsal?.toString() ?? '?',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.fullName,
                  style: AppTypography.h5.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (data.position != null) ...[
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
                          data.position!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (data.teamName != null)
                      Text(
                        data.teamName!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              icon: Icons.sports_soccer,
              label: 'Partidos',
              value: data.totalMatches.toString(),
              color: AppColors.primary,
            ),
            _StatCard(
              icon: Icons.timer_outlined,
              label: 'Minutos',
              value: data.totalMinutes.toString(),
              color: AppColors.info,
            ),
            _StatCard(
              icon: Icons.sports_score,
              label: 'Goles',
              value: data.goals.toString(),
              color: AppColors.success,
            ),
            _StatCard(
              icon: Icons.assistant_direction,
              label: 'Asistencias',
              value: data.assists.toString(),
              color: AppColors.accent,
            ),
            _StatCard(
              icon: Icons.warning_amber,
              label: 'Amarillas',
              value: data.yellowCards.toString(),
              color: AppColors.warning,
            ),
            _StatCard(
              icon: Icons.dangerous,
              label: 'Rojas',
              value: data.redCards.toString(),
              color: AppColors.error,
            ),
            _StatCard(
              icon: Icons.access_time,
              label: 'Min/Partido',
              value: data.averageMinutesPerMatch.toStringAsFixed(0),
              color: AppColors.gray600,
            ),
            _StatCard(
              icon: Icons.trending_up,
              label: '% Asistencia',
              value: '${data.attendancePercentage.toStringAsFixed(0)}%',
              color: AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de estadísticas',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: [
                  data.goals.toDouble(),
                  data.assists.toDouble(),
                  data.yellowCards.toDouble(),
                  data.redCards.toDouble(),
                ].reduce((a, b) => a > b ? a : b) + 2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Goles', 'Asist.', 'Amar.', 'Rojas'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()],
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, data.goals.toDouble(), AppColors.success),
                  _makeBarGroup(1, data.assists.toDouble(), AppColors.accent),
                  _makeBarGroup(2, data.yellowCards.toDouble(), AppColors.warning),
                  _makeBarGroup(3, data.redCards.toDouble(), AppColors.error),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Asistencia a entrenamientos',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStat(
                  'Total',
                  data.totalTrainings.toString(),
                  AppColors.gray700,
                ),
              ),
              Expanded(
                child: _buildAttendanceStat(
                  'Asistidos',
                  data.attendedTrainings.toString(),
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildAttendanceStat(
                  'Faltas',
                  (data.totalTrainings - data.attendedTrainings).toString(),
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _buildAttendanceStat(
                  'Porcentaje',
                  '${data.attendancePercentage.toStringAsFixed(0)}%',
                  AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.attendancePercentage / 100,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                data.attendancePercentage >= 80
                    ? AppColors.success
                    : data.attendancePercentage >= 60
                        ? AppColors.warning
                        : AppColors.error,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h5.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
