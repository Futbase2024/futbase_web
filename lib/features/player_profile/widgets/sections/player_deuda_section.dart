import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de control de deuda del jugador
class PlayerDeudaSection extends StatelessWidget {
  const PlayerDeudaSection({
    super.key,
    required this.controlDeuda,
    this.isLoading = false,
    this.onAddRecibo,
  });

  final Map<String, dynamic>? controlDeuda;
  final bool isLoading;
  final VoidCallback? onAddRecibo;

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

    if (controlDeuda == null || controlDeuda!.isEmpty) {
      return _buildEmptyState();
    }

    final deudaTotal = (controlDeuda!['deuda_total'] as num?)?.toDouble() ?? 0.0;
    final pagadoTotal = (controlDeuda!['pagado_total'] as num?)?.toDouble() ?? 0.0;
    final pendienteTotal = (controlDeuda!['pendiente_total'] as num?)?.toDouble() ?? 0.0;
    final recibos = controlDeuda!['recibos'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen financiero
          _buildResumenFinanciero(deudaTotal, pagadoTotal, pendienteTotal),
          AppSpacing.vSpaceLg,
          // Acciones
          if (onAddRecibo != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddRecibo,
                icon: const Icon(Icons.add),
                label: const Text('Añadir recibo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          AppSpacing.vSpaceLg,
          // Lista de recibos
          Text(
            'Historial de pagos',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vSpaceSm,
          if (recibos.isEmpty)
            _buildNoRecibos()
          else
            ...recibos.map((r) => _buildReciboCard(r as Map<String, dynamic>)),
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
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.success,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin deuda',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay registros de deuda para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenFinanciero(double deuda, double pagado, double pendiente) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            pendiente > 0 ? AppColors.error : AppColors.success,
            pendiente > 0
                ? AppColors.error.withValues(alpha: 0.8)
                : AppColors.success.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (pendiente > 0 ? AppColors.error : AppColors.success).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Resumen de temporada',
            style: AppTypography.labelMedium.copyWith(color: Colors.white70),
          ),
          AppSpacing.vSpaceMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMontoColumn('Deuda total', deuda, Icons.trending_up),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildMontoColumn('Pagado', pagado, Icons.check_circle_outline),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildMontoColumn('Pendiente', pendiente, Icons.pending_outlined),
            ],
          ),
          if (pendiente > 0) ...[
            AppSpacing.vSpaceMd,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                  AppSpacing.hSpaceSm,
                  Text(
                    'Tiene pagos pendientes',
                    style: AppTypography.labelSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMontoColumn(String label, double monto, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        AppSpacing.vSpaceXs,
        Text(
          '${monto.toStringAsFixed(0)}€',
          style: AppTypography.h6.copyWith(
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

  Widget _buildNoRecibos() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.gray300),
            AppSpacing.vSpaceSm,
            Text(
              'Sin recibos registrados',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReciboCard(Map<String, dynamic> recibo) {
    final fecha = recibo['fechapago']?.toString() ?? '';
    final cantidad = (recibo['cantidad'] as num?)?.toDouble() ?? 0.0;
    final concepto = recibo['concepto']?.toString() ?? '';
    final metodopago = recibo['metodopago']?.toString() ?? '';

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_outlined, color: AppColors.success, size: 24),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concepto.isNotEmpty ? concepto : 'Recibo de pago',
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
                      fecha,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
                    ),
                    if (metodopago.isNotEmpty) ...[
                      AppSpacing.hSpaceSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          metodopago,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${cantidad.toStringAsFixed(0)}€',
            style: AppTypography.h6.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
