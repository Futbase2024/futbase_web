import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/report_data.dart';
import '../../domain/report_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Vista del informe de estadísticas de equipo
class TeamStatsReportView extends StatelessWidget {
  const TeamStatsReportView({
    super.key,
    required this.data,
    required this.filter,
    required this.onBack,
    required this.onExportPdf,
    required this.onExportExcel,
  });

  final TeamStatsReportData data;
  final ReportFilter filter;
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
                _buildResultsSummary(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildResultsPieChart(),
                const SizedBox(height: 24),
                _buildRecentMatches(),
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
                  'Estadísticas de Equipo',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  data.teamName,
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

  Widget _buildResultsSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultItem(
                'Victorias',
                data.wins.toString(),
                Colors.white,
              ),
              _buildResultItem(
                'Empates',
                data.draws.toString(),
                Colors.white70,
              ),
              _buildResultItem(
                'Derrotas',
                data.losses.toString(),
                Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${data.goalsFor} goles a favor',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '•',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${data.goalsAgainst} goles en contra',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
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
              icon: Icons.trending_up,
              label: '% Victorias',
              value: '${data.winPercentage.toStringAsFixed(0)}%',
              color: AppColors.success,
            ),
            _StatCard(
              icon: Icons.calculate,
              label: 'Dif. Goles',
              value: data.goalDifference > 0
                  ? '+${data.goalDifference}'
                  : data.goalDifference.toString(),
              color: data.goalDifference >= 0
                  ? AppColors.success
                  : AppColors.error,
            ),
            _StatCard(
              icon: Icons.stars,
              label: 'Pts/Partido',
              value: data.pointsPerMatch.toStringAsFixed(1),
              color: AppColors.accent,
            ),
            _StatCard(
              icon: Icons.event,
              label: 'Entrenamientos',
              value: data.totalTrainings.toString(),
              color: AppColors.info,
            ),
            _StatCard(
              icon: Icons.percent,
              label: 'Asistencia Media',
              value: '${data.averageAttendance.toStringAsFixed(0)}%',
              color: _getAttendanceColor(data.averageAttendance),
            ),
            _StatCard(
              icon: Icons.sports_score,
              label: 'Goles/Partido',
              value: (data.totalMatches > 0
                      ? data.goalsFor / data.totalMatches
                      : 0)
                  .toStringAsFixed(1),
              color: AppColors.primary,
            ),
            _StatCard(
              icon: Icons.shield,
              label: 'Goles Recibidos/Partido',
              value: (data.totalMatches > 0
                      ? data.goalsAgainst / data.totalMatches
                      : 0)
                  .toStringAsFixed(1),
              color: AppColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultsPieChart() {
    if (data.totalMatches == 0) return const SizedBox.shrink();

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
                Icons.pie_chart,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución de resultados',
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
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: data.wins.toDouble(),
                          title: '${data.wins}',
                          color: AppColors.success,
                          radius: 60,
                          titleStyle: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: data.draws.toDouble(),
                          title: '${data.draws}',
                          color: AppColors.gray400,
                          radius: 60,
                          titleStyle: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: data.losses.toDouble(),
                          title: '${data.losses}',
                          color: AppColors.error,
                          radius: 60,
                          titleStyle: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Victorias', AppColors.success),
                  const SizedBox(height: 8),
                  _buildLegendItem('Empates', AppColors.gray400),
                  const SizedBox(height: 8),
                  _buildLegendItem('Derrotas', AppColors.error),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMatches() {
    if (data.recentMatches.isEmpty) {
      return const SizedBox.shrink();
    }

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
                Icons.history,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Últimos partidos',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.recentMatches.map((match) => _buildMatchItem(match)),
        ],
      ),
    );
  }

  Widget _buildMatchItem(MatchResultSummary match) {
    final resultColor = match.isWin
        ? AppColors.success
        : match.isLoss
            ? AppColors.error
            : AppColors.gray400;

    final resultText = match.isWin
        ? 'V'
        : match.isLoss
            ? 'D'
            : 'E';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                resultText,
                style: AppTypography.labelMedium.copyWith(
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.isHome ? 'vs ${match.rival}' : '@ ${match.rival}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  _formatDate(match.matchDate),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
