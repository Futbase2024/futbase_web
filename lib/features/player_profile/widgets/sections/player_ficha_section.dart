import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de ficha federativa del jugador
class PlayerFichaSection extends StatelessWidget {
  const PlayerFichaSection({
    super.key,
    required this.fichaFederativa,
    this.isLoading = false,
    this.onUpdate,
  });

  final Map<String, dynamic>? fichaFederativa;
  final bool isLoading;
  final VoidCallback? onUpdate;

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

    if (fichaFederativa == null || fichaFederativa!.isEmpty) {
      return _buildEmptyState();
    }

    final ficha = fichaFederativa!['ficha']?.toString() ?? '';
    final fechaficha = fichaFederativa!['fechaficha']?.toString() ?? '';
    final estado = fichaFederativa!['estado']?.toString() ?? 'pendiente';

    // Determinar estado
    bool tieneFicha = ficha.isNotEmpty && ficha != 'null';
    bool fichaVigente = false;
    if (tieneFicha && fechaficha.isNotEmpty && fechaficha != 'null') {
      try {
        final fecha = DateTime.parse(fechaficha);
        fichaVigente = fecha.isAfter(DateTime.now());
      } catch (e) {
        fichaVigente = false;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado de la ficha
          _buildEstadoCard(tieneFicha, fichaVigente, estado),
          AppSpacing.vSpaceLg,
          // Detalles de la ficha
          if (tieneFicha) ...[
            Text(
              'Detalles de la ficha',
              style: AppTypography.h6.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vSpaceSm,
            _buildDetalleCard('Número de ficha', ficha, Icons.badge_outlined),
            if (fechaficha.isNotEmpty && fechaficha != 'null')
              _buildDetalleCard('Fecha de expedición', fechaficha, Icons.calendar_today_outlined),
            AppSpacing.vSpaceLg,
          ],
          // Botón actualizar
          if (onUpdate != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpdate,
                icon: const Icon(Icons.edit_document),
                label: Text(tieneFicha ? 'Actualizar ficha' : 'Registrar ficha'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
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
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 48,
                color: AppColors.warning,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin ficha federativa',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay ficha federativa registrada para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceLg,
            if (onUpdate != null)
              ElevatedButton.icon(
                onPressed: onUpdate,
                icon: const Icon(Icons.add),
                label: const Text('Registrar ficha'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard(bool tieneFicha, bool fichaVigente, String estado) {
    Color estadoColor;
    IconData estadoIcon;
    String estadoTexto;
    String estadoDescripcion;

    if (!tieneFicha) {
      estadoColor = AppColors.warning;
      estadoIcon = Icons.warning_amber_rounded;
      estadoTexto = 'Pendiente';
      estadoDescripcion = 'El jugador no tiene ficha federativa registrada';
    } else if (fichaVigente) {
      estadoColor = AppColors.success;
      estadoIcon = Icons.verified;
      estadoTexto = 'Vigente';
      estadoDescripcion = 'La ficha federativa está vigente';
    } else {
      estadoColor = AppColors.error;
      estadoIcon = Icons.error_outline;
      estadoTexto = 'Vencida';
      estadoDescripcion = 'La ficha federativa ha vencido';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            estadoColor.withValues(alpha: 0.1),
            estadoColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(estadoIcon, size: 32, color: estadoColor),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estadoTexto,
                  style: AppTypography.h5.copyWith(
                    color: estadoColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vSpaceXs,
                Text(
                  estadoDescripcion,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                ),
                AppSpacing.vSpaceXs,
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
