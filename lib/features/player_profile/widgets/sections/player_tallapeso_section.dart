import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de historial de talla y peso del jugador
class PlayerTallaPesoSection extends StatelessWidget {
  const PlayerTallaPesoSection({
    super.key,
    required this.tallaPeso,
    this.isLoading = false,
    this.onCreate,
    this.onEdit,
    this.onDelete,
  });

  final List<Map<String, dynamic>> tallaPeso;
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
                label: const Text('Añadir medición'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        // Lista o empty state
        Expanded(
          child: tallaPeso.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tallaPeso.length,
                  itemBuilder: (context, index) => _buildTallaPesoCard(tallaPeso[index]),
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
                Icons.monitor_weight_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin mediciones',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay registros de talla y peso para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTallaPesoCard(Map<String, dynamic> item) {
    final fecha = item['fecha']?.toString() ?? '';
    final talla = item['talla'] as double? ?? 0;
    final peso = item['peso'] as double? ?? 0;
    final id = item['id'] as int?;
    final imc = talla > 0 ? peso / ((talla / 100) * (talla / 100)) : 0.0;

    // Calcular IMC categoría
    String imcCategoria;
    Color imcColor;
    if (imc < 18.5) {
      imcCategoria = 'Bajo peso';
      imcColor = AppColors.warning;
    } else if (imc < 25) {
      imcCategoria = 'Normal';
      imcColor = AppColors.success;
    } else if (imc < 30) {
      imcCategoria = 'Sobrepeso';
      imcColor = AppColors.warning;
    } else {
      imcCategoria = 'Obesidad';
      imcColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
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
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.gray400),
                    AppSpacing.hSpaceSm,
                    Text(
                      fecha,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (id != null && (onEdit != null || onDelete != null))
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.gray400),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!(item);
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
            // Métricas
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.height,
                    label: 'Talla',
                    value: '${talla.toStringAsFixed(0)} cm',
                    color: AppColors.info,
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso',
                    value: '${peso.toStringAsFixed(1)} kg',
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.analytics_outlined,
                    label: 'IMC',
                    value: imc.toStringAsFixed(1),
                    subtitle: imcCategoria,
                    color: imcColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          AppSpacing.vSpaceXs,
          Text(
            value,
            style: AppTypography.h6.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(color: color),
            )
          else
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
            ),
        ],
      ),
    );
  }
}
