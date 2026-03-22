import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de entrenamientos del jugador con asistencia
class PlayerEntrenamientosSection extends StatelessWidget {
  const PlayerEntrenamientosSection({
    super.key,
    required this.entrenamientos,
    required this.asistenciaStats,
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

    return Column(
      children: [
        // Resumen de asistencia
        if (asistenciaStats != null) _buildAsistenciaSummary(),
        // Lista de entrenamientos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entrenamientos.length,
            itemBuilder: (context, index) => _buildEntrenamientoCard(entrenamientos[index]),
          ),
        ),
      ],
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
                Icons.fitness_center_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin entrenamientos',
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

  Widget _buildAsistenciaSummary() {
    final total = asistenciaStats!['total'] as int? ?? 0;
    final asistidos = asistenciaStats!['asistidos'] as int? ?? 0;
    final porcentaje = double.tryParse(asistenciaStats!['porcentaje']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Total', total.toString(), Icons.event_note),
              _buildStatColumn('Asistidos', asistidos.toString(), Icons.check_circle_outline),
              _buildStatColumn('Faltas', (total - asistidos).toString(), Icons.cancel_outlined),
            ],
          ),
          AppSpacing.vSpaceMd,
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Porcentaje de asistencia',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
                  ),
                  Text(
                    '${porcentaje.toStringAsFixed(1)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              AppSpacing.vSpaceXs,
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: porcentaje / 100,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    porcentaje >= 80
                        ? AppColors.success
                        : porcentaje >= 60
                            ? AppColors.warning
                            : AppColors.error,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        AppSpacing.vSpaceXs,
        Text(
          value,
          style: AppTypography.h5.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildEntrenamientoCard(Map<String, dynamic> entrenamiento) {
    final fecha = entrenamiento['fecha']?.toString() ?? '';
    final hinicio = entrenamiento['hinicio']?.toString() ?? '';
    final hfin = entrenamiento['hfin']?.toString() ?? '';
    final equipo = entrenamiento['equipo']?.toString() ?? '';
    final observaciones = entrenamiento['observaciones']?.toString() ?? '';
    final asistio = entrenamiento['asistio'] as bool? ?? false;
    final motivo = entrenamiento['motivo']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: asistio
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Indicador de asistencia
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: asistio ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.hSpaceMd,
            // Info del entrenamiento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fecha,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: asistio
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          asistio ? 'ASISTIÓ' : 'NO ASISTIÓ',
                          style: AppTypography.labelSmall.copyWith(
                            color: asistio ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSpaceXs,
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        '$hinicio - $hfin',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                      ),
                    ],
                  ),
                  if (equipo.isNotEmpty) ...[
                    AppSpacing.vSpaceXs,
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 14, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Text(
                          equipo,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ],
                  if (!asistio && motivo.isNotEmpty) ...[
                    AppSpacing.vSpaceXs,
                    Text(
                      'Motivo: $motivo',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (observaciones.isNotEmpty) ...[
                    AppSpacing.vSpaceXs,
                    Text(
                      observaciones,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.gray400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
