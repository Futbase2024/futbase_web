import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de partidos del jugador
class PlayerPartidosSection extends StatelessWidget {
  const PlayerPartidosSection({
    super.key,
    required this.partidos,
    this.isLoading = false,
  });

  final List<Map<String, dynamic>> partidos;
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

    if (partidos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: partidos.length,
      itemBuilder: (context, index) => _buildPartidoCard(partidos[index]),
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
                Icons.sports_soccer_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin partidos',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay partidos registrados para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartidoCard(Map<String, dynamic> partido) {
    final fecha = partido['fecha']?.toString() ?? '';
    final rival = partido['rival']?.toString() ?? 'Rival';
    final local = partido['local'] as bool? ?? true;
    final golesLocal = partido['goles_local'] as int?;
    final golesVisitante = partido['goles_visitante'] as int?;
    final finalizado = partido['finalizado'] as bool? ?? false;
    final convocado = partido['convocado'] as bool? ?? false;
    final titular = partido['titular'] as bool? ?? false;
    final minutos = partido['minutos'] as int? ?? 0;
    final dorsal = partido['dorsal']?.toString() ?? '-';

    // Determinar resultado
    String resultado = '-';
    Color resultadoColor = AppColors.gray500;
    bool? gano;

    if (finalizado && golesLocal != null && golesVisitante != null) {
      resultado = '$golesLocal - $golesVisitante';
      if (golesLocal > golesVisitante) {
        gano = local ? true : false;
      } else if (golesVisitante > golesLocal) {
        gano = local ? false : true;
      } else {
        gano = null; // Empate
      }
      resultadoColor = gano == true
          ? AppColors.success
          : gano == false
              ? AppColors.error
              : AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Fecha y resultado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: local
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        local ? 'LOCAL' : 'VISITANTE',
                        style: AppTypography.labelSmall.copyWith(
                          color: local ? AppColors.primary : AppColors.gray600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppSpacing.hSpaceSm,
                    Text(
                      fecha,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
                if (finalizado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: resultadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      resultado,
                      style: AppTypography.h6.copyWith(
                        color: resultadoColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Pendiente',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.vSpaceMd,
            // Rival
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: AppColors.gray400,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    'vs $rival',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // Info del jugador en el partido
            if (convocado) ...[
              AppSpacing.vSpaceMd,
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildPlayerStat('Dorsal', dorsal, Icons.tag),
                    AppSpacing.hSpaceMd,
                    _buildPlayerStat('Titular', titular ? 'Sí' : 'No', Icons.star_outline),
                    AppSpacing.hSpaceMd,
                    _buildPlayerStat('Minutos', '$minutos\'', Icons.timer_outlined),
                  ],
                ),
              ),
            ] else if (finalizado) ...[
              AppSpacing.vSpaceMd,
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                    AppSpacing.hSpaceSm,
                    Text(
                      'No convocado',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
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

  Widget _buildPlayerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray400),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
              ),
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
