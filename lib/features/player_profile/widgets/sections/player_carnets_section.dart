import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de carnets del jugador
class PlayerCarnetsSection extends StatelessWidget {
  const PlayerCarnetsSection({
    super.key,
    required this.carnets,
    this.isLoading = false,
    this.onCreate,
    this.onView,
    this.onDownload,
  });

  final List<Map<String, dynamic>> carnets;
  final bool isLoading;
  final VoidCallback? onCreate;
  final void Function(Map<String, dynamic> carnet)? onView;
  final void Function(Map<String, dynamic> carnet)? onDownload;

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
                label: const Text('Crear carnet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        // Lista o empty state
        Expanded(
          child: carnets.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: carnets.length,
                  itemBuilder: (context, index) => _buildCarnetCard(carnets[index]),
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
                Icons.badge_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin carnets',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay carnets registrados para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarnetCard(Map<String, dynamic> carnet) {
    final temporada = carnet['temporada']?.toString() ?? 'Temporada';
    final fecha = carnet['fecha']?.toString() ?? '';
    final estado = carnet['estado']?.toString() ?? 'pendiente';
    final foto = carnet['foto']?.toString();

    // Determinar estado
    Color estadoColor;
    String estadoTexto;
    IconData estadoIcon;

    switch (estado.toLowerCase()) {
      case 'activo':
      case 'vigente':
        estadoColor = AppColors.success;
        estadoTexto = 'Vigente';
        estadoIcon = Icons.verified;
        break;
      case 'vencido':
      case 'caducado':
        estadoColor = AppColors.error;
        estadoTexto = 'Vencido';
        estadoIcon = Icons.error_outline;
        break;
      default:
        estadoColor = AppColors.warning;
        estadoTexto = 'Pendiente';
        estadoIcon = Icons.pending_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Foto o placeholder
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: foto != null && foto.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carnet $temporada',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vSpaceXs,
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Text(
                            fecha.isNotEmpty ? fecha : 'Sin fecha',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                          ),
                        ],
                      ),
                      AppSpacing.vSpaceSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(estadoIcon, size: 14, color: estadoColor),
                            const SizedBox(width: 4),
                            Text(
                              estadoTexto,
                              style: AppTypography.labelSmall.copyWith(
                                color: estadoColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Acciones
            AppSpacing.vSpaceMd,
            Row(
              children: [
                if (onView != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onView!(carnet),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Ver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.gray300),
                      ),
                    ),
                  ),
                if (onView != null && onDownload != null) AppSpacing.hSpaceSm,
                if (onDownload != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onDownload!(carnet),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Descargar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.gray300),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.person_outline,
        size: 30,
        color: AppColors.gray300,
      ),
    );
  }
}
