import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de estadísticas del jugador
class PlayerEstadisticasSection extends StatelessWidget {
  const PlayerEstadisticasSection({
    super.key,
    required this.estadisticas,
    this.isLoading = false,
  });

  final List<Map<String, dynamic>> estadisticas;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (estadisticas.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de estadísticas
          _buildSummaryCards(),
          AppSpacing.vSpaceMd,
          // Detalle por partido
          Text(
            'Detalle por partido',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vSpaceSm,
          ...estadisticas.map((stat) => _buildStatCard(stat)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin estadísticas',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay estadísticas registradas para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Calcular totales
    int totalGoles = 0;
    int totalAsistencias = 0;
    int totalTarjetasAmarillas = 0;
    int totalTarjetasRojas = 0;
    int totalMinutos = 0;
    int partidosJugados = estadisticas.length;

    for (final stat in estadisticas) {
      totalGoles += (stat['goles'] as int?) ?? 0;
      totalAsistencias += (stat['asistencias'] as int?) ?? 0;
      totalTarjetasAmarillas += (stat['tarjetas_amarillas'] as int?) ?? 0;
      totalTarjetasRojas += (stat['tarjetas_rojas'] as int?) ?? 0;
      totalMinutos += (stat['minutos_jugados'] as int?) ?? 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de temporada',
          style: AppTypography.h6.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vSpaceSm,
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSummaryCard(
              icon: Icons.sports_soccer,
              label: 'Partidos',
              value: partidosJugados.toString(),
              color: AppColors.primary,
            ),
            _buildSummaryCard(
              icon: Icons.flag,
              label: 'Goles',
              value: totalGoles.toString(),
              color: AppColors.success,
            ),
            _buildSummaryCard(
              icon: Icons.assistant_direction,
              label: 'Asistencias',
              value: totalAsistencias.toString(),
              color: AppColors.info,
            ),
            _buildSummaryCard(
              icon: Icons.timer,
              label: 'Minutos',
              value: totalMinutos.toString(),
              color: AppColors.warning,
            ),
            _buildSummaryCard(
              icon: Icons.square,
              label: 'T. Amarillas',
              value: totalTarjetasAmarillas.toString(),
              color: AppColors.warning,
            ),
            _buildSummaryCard(
              icon: Icons.square,
              label: 'T. Rojas',
              value: totalTarjetasRojas.toString(),
              color: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          AppSpacing.vSpaceXs,
          Text(
            value,
            style: AppTypography.h5.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final fecha = stat['fecha']?.toString() ?? '';
    final rival = stat['rival']?.toString() ?? 'Rival';
    final goles = stat['goles'] as int? ?? 0;
    final asistencias = stat['asistencias'] as int? ?? 0;
    final minutos = stat['minutos_jugados'] as int? ?? 0;
    final tarjetasAmarillas = stat['tarjetas_amarillas'] as int? ?? 0;
    final tarjetasRojas = stat['tarjetas_rojas'] as int? ?? 0;
    final local = stat['local'] as bool? ?? true;
    final golesLocal = stat['goles_local'] as int?;
    final golesVisitante = stat['goles_visitante'] as int?;
    final resultado = golesLocal != null && golesVisitante != null
        ? '$golesLocal - $golesVisitante'
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Info partido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: local
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        local ? 'Casa' : 'Fuera',
                        style: AppTypography.labelSmall.copyWith(
                          color: local ? AppColors.primary : AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppSpacing.hSpaceSm,
                    Expanded(
                      child: Text(
                        'vs $rival',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vSpaceXs,
                Text(
                  '$fecha • $resultado',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
          // Estadísticas
          Row(
            children: [
              if (goles > 0) _buildStatBadge(Icons.sports_soccer, goles.toString(), AppColors.success),
              if (asistencias > 0) _buildStatBadge(Icons.assistant_direction, asistencias.toString(), AppColors.info),
              if (tarjetasAmarillas > 0)
                _buildStatBadge(Icons.square, tarjetasAmarillas.toString(), AppColors.warning),
              if (tarjetasRojas > 0)
                _buildStatBadge(Icons.square, tarjetasRojas.toString(), AppColors.error),
              _buildStatBadge(Icons.timer, '$minutos\'', AppColors.gray600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
