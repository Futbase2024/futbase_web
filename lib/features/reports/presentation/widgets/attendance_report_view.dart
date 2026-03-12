import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/report_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Vista del informe de asistencia mensual
class AttendanceReportView extends StatelessWidget {
  const AttendanceReportView({
    super.key,
    required this.data,
    required this.teamId,
    required this.onBack,
    required this.onExportPdf,
    required this.onExportExcel,
  });

  final AttendanceReportData data;
  final int teamId;
  final VoidCallback onBack;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildAttendanceChart(),
                const SizedBox(height: 24),
                _buildPlayersTable(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistencia Mensual',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  '${data.monthName} ${data.year} - ${data.teamName}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.event,
            label: 'Entrenamientos',
            value: data.totalTrainings.toString(),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            icon: Icons.people,
            label: 'Jugadores',
            value: data.playersAttendance.length.toString(),
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            icon: Icons.percent,
            label: 'Media Asistencia',
            value: '${data.averageAttendance.toStringAsFixed(0)}%',
            color: _getAttendanceColor(data.averageAttendance),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceChart() {
    if (data.playersAttendance.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tomar los primeros 10 jugadores para el gráfico
    final topPlayers = data.playersAttendance.take(10).toList();

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
                Icons.bar_chart,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Asistencia por jugador (Top 10)',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final player = topPlayers[groupIndex.toInt()];
                      return BarTooltipItem(
                        '${player.fullName}\n${player.attendancePercentage.toStringAsFixed(0)}%',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= topPlayers.length) {
                          return const SizedBox.shrink();
                        }
                        final player = topPlayers[value.toInt()];
                        final name = player.playerName.split(' ').first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            name,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.gray500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.gray400,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
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
                borderData: FlBorderData(show: false),
                barGroups: topPlayers.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.attendancePercentage,
                        color: _getAttendanceColor(entry.value.attendancePercentage),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersTable() {
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
                Icons.table_rows,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Detalle por jugador',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.gray50),
              columns: [
                DataColumn(
                  label: Text(
                    '#',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Jugador',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Entrenamientos',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Asistidos',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Faltas',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '% Asistencia',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
              rows: data.playersAttendance.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final player = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(index.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (player.dorsal != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${player.dorsal}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(player.fullName),
                        ],
                      ),
                    ),
                    DataCell(Text(player.totalTrainings.toString())),
                    DataCell(
                      Text(
                        player.attended.toString(),
                        style: TextStyle(color: AppColors.success),
                      ),
                    ),
                    DataCell(
                      Text(
                        player.absences.toString(),
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getAttendanceColor(player.attendancePercentage)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${player.attendancePercentage.toStringAsFixed(0)}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: _getAttendanceColor(player.attendancePercentage),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.h4.copyWith(
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
