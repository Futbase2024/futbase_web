import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de resumen de asistencias del jugador
class PlayerAsistenciasSection extends StatelessWidget {
  const PlayerAsistenciasSection({
    super.key,
    required this.entrenamientos,
    this.asistenciaStats,
    this.isLoading = false,
  });

  final List<Map<String, dynamic>> entrenamientos;
  final Map<String, dynamic>? asistenciaStats;
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

    if (entrenamientos.isEmpty) {
      return _buildEmptyState();
    }

    // Agrupar entrenamientos por mes
    final entrenamientosPorMes = _agruparPorMes(entrenamientos);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          if (asistenciaStats != null) _buildResumenGeneral(),
          AppSpacing.vSpaceLg,
          // Asistencias por mes
          Text(
            'Asistencias por mes',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vSpaceSm,
          ...entrenamientosPorMes.entries.map((entry) => _buildMesCard(entry.key, entry.value)),
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
                Icons.event_available_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin datos de asistencia',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay entrenamientos registrados para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenGeneral() {
    final total = asistenciaStats!['total'] as int? ?? 0;
    final asistidos = asistenciaStats!['asistidos'] as int? ?? 0;
    final porcentajeStr = asistenciaStats!['porcentaje']?.toString() ?? '0';
    final porcentaje = double.tryParse(porcentajeStr) ?? 0;
    final faltas = total - asistidos;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Porcentaje principal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: porcentaje / 100,
                        strokeWidth: 10,
                        backgroundColor: AppColors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${porcentaje.toStringAsFixed(0)}%',
                          style: AppTypography.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          Text(
            'Asistencia General',
            style: AppTypography.h6.copyWith(color: Colors.white),
          ),
          AppSpacing.vSpaceMd,
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Entrenamientos', total.toString(), Icons.event_note),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildStatItem('Asistidos', asistidos.toString(), Icons.check_circle_outline),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildStatItem('Faltas', faltas.toString(), Icons.cancel_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        AppSpacing.vSpaceXs,
        Text(
          value,
          style: AppTypography.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _agruparPorMes(List<Map<String, dynamic>> entrenos) {
    final resultado = <String, List<Map<String, dynamic>>>{};

    for (final entreno in entrenos) {
      final fechaStr = entreno['fecha']?.toString() ?? '';
      if (fechaStr.isEmpty) continue;

      // Extraer mes-año
      String mesKey;
      try {
        if (fechaStr.contains('-')) {
          final parts = fechaStr.split('-');
          if (parts.length >= 2) {
            final mes = int.tryParse(parts[1]) ?? 1;
            final anio = parts[0];
            final nombresMes = [
              'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
              'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
            ];
            mesKey = '${nombresMes[mes - 1]} $anio';
          } else {
            mesKey = fechaStr;
          }
        } else {
          mesKey = fechaStr;
        }
      } catch (e) {
        mesKey = fechaStr;
      }

      resultado.putIfAbsent(mesKey, () => []);
      resultado[mesKey]!.add(entreno);
    }

    return resultado;
  }

  Widget _buildMesCard(String mes, List<Map<String, dynamic>> entrenos) {
    final total = entrenos.length;
    final asistidos = entrenos.where((e) => e['asistio'] == true).length;
    final porcentaje = total > 0 ? (asistidos / total * 100) : 0.0;

    Color porcentajeColor;
    if (porcentaje >= 80) {
      porcentajeColor = AppColors.success;
    } else if (porcentaje >= 60) {
      porcentajeColor = AppColors.warning;
    } else {
      porcentajeColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mes,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: porcentajeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${porcentaje.toStringAsFixed(0)}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: porcentajeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceSm,
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              backgroundColor: AppColors.gray100,
              valueColor: AlwaysStoppedAnimation<Color>(porcentajeColor),
              minHeight: 6,
            ),
          ),
          AppSpacing.vSpaceSm,
          // Detalle
          Row(
            children: [
              _buildMiniStat(Icons.check_circle_outline, AppColors.success, 'Asistió', asistidos),
              AppSpacing.hSpaceMd,
              _buildMiniStat(Icons.cancel_outlined, AppColors.error, 'Faltó', total - asistidos),
              AppSpacing.hSpaceMd,
              _buildMiniStat(Icons.event_note, AppColors.gray500, 'Total', total),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }
}
