import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo profesional de comparación de jugadores
class ScoutingComparisonDialog extends StatelessWidget {
  const ScoutingComparisonDialog({
    super.key,
    required this.players,
  });

  final List<Map<String, dynamic>> players;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Headers de jugadores
                    _buildPlayerHeaders(),
                    const SizedBox(height: AppSpacing.xl),

                    // KPIs comparativos
                    _buildSectionTitle('Estadísticas Clave'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildKpisComparison(),
                    const SizedBox(height: AppSpacing.xl),

                    // Gráfico de barras comparativo
                    _buildSectionTitle('Comparativa de Estadísticas'),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 200,
                      child: _buildComparisonChart(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Gráfico de valoración
                    _buildSectionTitle('Valoración'),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 120,
                      child: _buildRatingChart(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Tabla detallada
                    _buildSectionTitle('Detalle Completo'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildDetailedTable(),
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

  Widget _buildHeader(BuildContext context) {
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
          const Icon(Icons.compare_arrows, color: AppColors.white),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Comparación de Jugadores',
            style: AppTypography.h6.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${players.length} jugadores',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHeaders() {
    return Row(
      children: players.map((player) {
        return Expanded(
          child: _buildPlayerHeaderCard(player),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerHeaderCard(Map<String, dynamic> player) {
    final nombre = player['nombre'] as String? ?? '';
    final apodo = player['apodo'] as String?;
    final foto = player['foto'] as String?;
    final dorsal = player['dorsal'] as int?;
    final posicion = player['posicion'] as String?;
    final categoria = player['categoria'] as String?;
    final equipo = player['equipo'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          // Avatar y dorsal
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  image: foto != null && foto.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(foto),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: foto == null || foto.isEmpty
                    ? Center(
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                          style: AppTypography.h5.copyWith(
                            color: AppColors.primary,
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$dorsal',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Nombre
          Text(
            apodo ?? nombre,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Posición y categoría
          Text(
            posicion ?? '-',
            style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
          ),
          if (categoria != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                categoria,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (equipo != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                equipo,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray400,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
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

  Widget _buildKpisComparison() {
    final kpis = [
      ('PJ', 'pj'),
      ('Goles', 'goles'),
      ('Min', 'minutos'),
      ('Val', 'valoracion'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: kpis.map((kpi) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Label
                SizedBox(
                  width: 60,
                  child: Text(
                    kpi.$1,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Valores de cada jugador
                ...players.map((player) {
                  final value = player[kpi.$2] ?? 0;
                  final maxValue = players.fold<int>(0, (max, p) {
                    final v = (p[kpi.$2] as int?) ?? 0;
                    return v > max ? v : max;
                  }).clamp(1, double.infinity).toInt();

                  final percentage = (value as int) / maxValue;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$value',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: percentage.toDouble(),
                              backgroundColor: AppColors.gray200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getColorForPlayer(players.indexOf(player)),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonChart() {
    final stats = [
      ('PJ', 'pj'),
      ('Goles', 'goles'),
      ('Tit.', 'ptitular'),
    ];

    final maxValue = players.fold<double>(0, (max, player) {
      for (final stat in stats) {
        final v = (player[stat.$2] as int?) ?? 0;
        if (v.toDouble() > max) max = v.toDouble();
      }
      return max;
    }).clamp(1, double.infinity) * 1.2;

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
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < stats.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      stats[index].$1,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray500,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.gray100, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(stats),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<(String, String)> stats) {
    return List.generate(stats.length, (statIndex) {
      final rods = players.asMap().entries.map((entry) {
        final playerIndex = entry.key;
        final player = entry.value;
        final value = ((player[stats[statIndex].$2] as int?) ?? 0).toDouble();

        return BarChartRodData(
          toY: value,
          color: _getColorForPlayer(playerIndex),
          width: 20,
          borderRadius: BorderRadius.circular(4),
        );
      }).toList();

      return BarChartGroupData(
        x: statIndex,
        barRods: rods,
        barsSpace: 4,
      );
    });
  }

  Widget _buildRatingChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
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
                if (index < players.length) {
                  final player = players[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      player['apodo'] ?? player['nombre'] ?? 'Jugador',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray500,
                        fontSize: 9,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.gray100, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final valoracion = ((player['valoracion'] as int?) ?? 0).toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: valoracion,
                color: _getRatingColor(valoracion.toInt()),
                width: 50,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForPlayer(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      default:
        return AppColors.gray500;
    }
  }

  Color _getRatingColor(int value) {
    if (value >= 80) return AppColors.success;
    if (value >= 60) return AppColors.primary;
    if (value >= 40) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildDetailedTable() {
    final stats = [
      ('Partidos Jugados', 'pj'),
      ('Titularidades', 'ptitular'),
      ('Goles', 'goles'),
      ('Penaltis', 'penalti'),
      ('Tarj. Amarillas', 'ta'),
      ('Tarj. Rojas', 'tr'),
      ('Minutos', 'minutos'),
      ('Altura (cm)', 'altura'),
      ('Peso (kg)', 'peso'),
      ('Pie', 'pie'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.gray50),
          headingTextStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.gray700,
          ),
          columnSpacing: 16,
          horizontalMargin: 16,
          columns: [
            const DataColumn(label: Text('Estadística')),
            ...players.map((p) => DataColumn(
                  label: Text(
                    p['apodo'] ?? p['nombre'] ?? 'Jugador',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
          rows: stats.map((stat) {
            return DataRow(
              cells: [
                DataCell(Text(stat.$1)),
                ...players.map((p) => DataCell(
                      Text('${p[stat.$2] ?? '-'}'),
                    )),
              ],
            );
          }).toList(),
        ),
      ),
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
          Text(
            'Temporada: ${players.first['temporada'] ?? '-'}',
            style: AppTypography.labelSmall.copyWith(color: AppColors.gray400),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Cerrar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
