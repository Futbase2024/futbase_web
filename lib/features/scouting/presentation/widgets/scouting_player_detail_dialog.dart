import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../bloc/scouting_bloc.dart';
import '../../bloc/scouting_event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo profesional de detalle de jugador con layout compacto
class ScoutingPlayerDetailDialog extends StatelessWidget {
  const ScoutingPlayerDetailDialog({
    super.key,
    required this.player,
    this.playerHistory,
  });

  final Map<String, dynamic> player;
  final List<Map<String, dynamic>>? playerHistory;

  @override
  Widget build(BuildContext context) {
    final nombre = player['nombre'] as String? ?? '';
    final apellidos = player['apellidos'] as String? ?? '';
    final apodo = player['apodo'] as String?;
    final foto = player['foto'] as String?;
    final dorsal = player['dorsal'] as int?;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header compacto
            _buildHeader(context, nombre, apellidos, apodo, foto, dorsal),

            // Contenido en dos columnas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna izquierda: Info
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                          // KPIs compactos
                          _buildCompactKpis(),
                          const SizedBox(height: AppSpacing.lg),

                          // Información
                          _buildSectionTitle('Información'),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCompactInfoGrid(),
                          const SizedBox(height: AppSpacing.lg),

                          // Estadísticas detalladas
                          _buildSectionTitle('Estadísticas Detalladas'),
                          const SizedBox(height: AppSpacing.sm),
                          _buildDetailedStats(),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.lg),

                    // Columna derecha: Gráficos
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gráfico de evolución
                          _buildSectionTitle('Evolución por Temporada'),
                          const SizedBox(height: AppSpacing.sm),
                          Expanded(
                            child: _buildEvolutionChart(),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Gráfico de estadísticas
                          _buildSectionTitle('Distribución'),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            height: 120,
                            child: _buildStatsChart(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String nombre, String apellidos, String? apodo, String? foto, int? dorsal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  image: foto != null && foto.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(foto),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                child: foto == null || foto.isEmpty
                    ? Center(
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                          style: AppTypography.h5.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
              ),
              if (dorsal != null && dorsal > 0)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$dorsal',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apodo ?? '$nombre $apellidos',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${player['posicion'] ?? ''} · ${player['categoria'] ?? ''} · ${player['equipo'] ?? ''}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Cerrar
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactKpis() {
    return Row(
      children: [
        _buildMiniKpi('${player['pj'] ?? 0}', 'PJ'),
        const SizedBox(width: AppSpacing.sm),
        _buildMiniKpi('${player['goles'] ?? 0}', 'Goles'),
        const SizedBox(width: AppSpacing.sm),
        _buildMiniKpi('${player['minutos'] ?? 0}', 'Min'),
        const SizedBox(width: AppSpacing.sm),
        _buildMiniKpi('${player['valoracion'] ?? 0}', 'Val', highlight: true),
      ],
    );
  }

  Widget _buildMiniKpi(String value, String label, {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.h6.copyWith(
                color: highlight ? AppColors.primary : AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.gray700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCompactInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          _buildInfoRow('Club', player['club'] as String?),
          _buildInfoRow('Equipo', player['equipo'] as String?),
          _buildInfoRow('Pie', player['pie'] as String?),
          _buildInfoRow('Altura', player['altura'] != null ? '${player['altura']} cm' : null),
          _buildInfoRow('Peso', player['peso'] != null ? '${player['peso']} kg' : null),
          _buildInfoRow('Temporada', player['temporada'] as String?),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
          ),
          Text(
            value ?? '-',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    final pj = player['pj'] as int? ?? 0;
    final ptitular = player['ptitular'] as int? ?? 0;
    final goles = player['goles'] as int? ?? 0;
    final ta = player['ta'] as int? ?? 0;
    final tr = player['tr'] as int? ?? 0;
    final minutos = player['minutos'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          _buildInfoRow('Partidos Jugados', '$pj'),
          _buildInfoRow('Titularidades', '$ptitular'),
          _buildInfoRow('Goles', '$goles'),
          _buildInfoRow('Tarjetas Amarillas', '$ta'),
          _buildInfoRow('Tarjetas Rojas', '$tr'),
          _buildInfoRow('Minutos Totales', '$minutos'),
        ],
      ),
    );
  }

  Widget _buildEvolutionChart() {
    if (playerHistory == null || playerHistory!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, color: AppColors.gray300, size: 32),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No hay datos históricos',
                style: AppTypography.labelSmall.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    final seasonLabels = <String>[];

    for (var i = 0; i < playerHistory!.length; i++) {
      final history = playerHistory![i];
      final valoracion = (history['valoracion'] as int?) ?? 0;
      final temporada = history['temporada'] as String? ?? '';

      spots.add(FlSpot(i.toDouble(), valoracion.toDouble()));
      seasonLabels.add(temporada.replaceAll('20', "'"));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.gray100, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= seasonLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    seasonLabels[index],
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray500,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray400,
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (playerHistory!.length - 1).toDouble().clamp(0, double.infinity),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
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
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChart() {
    final pj = (player['pj'] as int?) ?? 0;
    final goles = (player['goles'] as int?) ?? 0;
    final ta = (player['ta'] as int?) ?? 0;
    final tr = (player['tr'] as int?) ?? 0;
    final tarjetas = ta + tr;

    final maxValue = [pj.toDouble(), goles.toDouble(), tarjetas.toDouble()]
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, double.infinity) *
        1.3;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxValue,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final labels = ['PJ', 'Goles', 'Ttarj.'];
                if (value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[value.toInt()],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray500,
                        fontSize: 9,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeGroupData(0, pj.toDouble(), AppColors.primary),
          _makeGroupData(1, goles.toDouble(), AppColors.success),
          _makeGroupData(2, tarjetas.toDouble(), AppColors.warning),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              context.read<ScoutingBloc>().add(ScoutingAddToComparison(player: player));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.compare_arrows, size: 16),
            label: const Text('Comparar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
          ),
          const Spacer(),
          Text(
            '${player['club'] ?? ''} · Temporada ${player['temporada'] ?? ''}',
            style: AppTypography.labelSmall.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
