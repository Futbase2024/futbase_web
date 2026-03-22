import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de historial de lesiones del jugador
class PlayerLesionesSection extends StatelessWidget {
  const PlayerLesionesSection({
    super.key,
    required this.lesiones,
    this.isLoading = false,
    this.onCreate,
    this.onEdit,
    this.onDelete,
  });

  final List<Map<String, dynamic>> lesiones;
  final bool isLoading;
  final VoidCallback? onCreate;
  final void Function(Map<String, dynamic> item)? onEdit;
  final void Function(int id)? onDelete;

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

    return Column(
      children: [
        // Botón añadir
        if (onCreate != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Añadir lesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
        // Lista o empty state
        Expanded(
          child: lesiones.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lesiones.length,
                  itemBuilder: (context, index) => _buildLesionCard(lesiones[index]),
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
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.health_and_safety_outlined,
                size: 48,
                color: AppColors.success,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin lesiones',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay lesiones registradas para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLesionCard(Map<String, dynamic> lesion) {
    final lesionNombre = lesion['lesion']?.toString() ?? 'Lesión';
    final fechainicio = lesion['fechainicio']?.toString() ?? '';
    final fechafin = lesion['fechafin']?.toString();
    final observaciones = lesion['observaciones']?.toString() ?? '';
    final id = lesion['id'] as int?;

    // Determinar si está activa
    bool activa = true;
    if (fechafin != null && fechafin.isNotEmpty && fechafin != 'null') {
      activa = false;
    }

    // Calcular días de baja
    int diasBaja = 0;
    try {
      DateTime inicio;
      if (fechainicio.contains('-')) {
        inicio = DateTime.parse(fechainicio);
      } else {
        inicio = DateTime.now();
      }

      DateTime fin;
      if (fechafin != null && fechafin.isNotEmpty && fechafin != 'null') {
        if (fechafin.contains('-')) {
          fin = DateTime.parse(fechafin);
        } else {
          fin = DateTime.now();
        }
      } else {
        fin = DateTime.now();
      }

      diasBaja = fin.difference(inicio).inDays;
    } catch (e) {
      diasBaja = 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activa ? AppColors.error.withValues(alpha: 0.3) : AppColors.gray200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activa
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activa ? Icons.healing : Icons.check_circle_outline,
                          size: 20,
                          color: activa ? AppColors.error : AppColors.success,
                        ),
                      ),
                      AppSpacing.hSpaceSm,
                      Expanded(
                        child: Text(
                          lesionNombre,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: activa
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    activa ? 'ACTIVA' : 'RECUPERADO',
                    style: AppTypography.labelSmall.copyWith(
                      color: activa ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (id != null && (onEdit != null || onDelete != null))
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.gray400),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!(lesion);
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!(id);
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            AppSpacing.vSpaceMd,
            // Fechas
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    icon: Icons.event,
                    label: 'Inicio',
                    value: fechainicio,
                  ),
                ),
                if (fechafin != null && fechafin.isNotEmpty && fechafin != 'null') ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateInfo(
                      icon: Icons.event_available,
                      label: 'Fin',
                      value: fechafin,
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$diasBaja',
                        style: AppTypography.h6.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'días',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (observaciones.isNotEmpty) ...[
              AppSpacing.vSpaceSm,
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note_outlined, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        observaciones,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gray400),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
            ),
            Text(
              value,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
