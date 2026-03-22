import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'coming_soon_section.dart';

/// Sección de cuotas del jugador
class PlayerCuotasSection extends StatelessWidget {
  const PlayerCuotasSection({
    super.key,
    required this.cuotas,
  });

  final List<Map<String, dynamic>> cuotas;

  @override
  Widget build(BuildContext context) {
    if (cuotas.isEmpty) {
      return const ComingSoonSection(
        title: 'Cuotas',
        icon: Icons.payments_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cuotas.length,
      itemBuilder: (context, index) {
        final cuota = cuotas[index];
        return _CuotaCard(cuota: cuota);
      },
    );
  }
}

class _CuotaCard extends StatelessWidget {
  const _CuotaCard({required this.cuota});

  final Map<String, dynamic> cuota;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final concepto = cuota['concepto']?.toString() ?? 'Cuota';
    final importe = cuota['importe'] ?? cuota['cantidad'] ?? 0;
    final fecha = cuota['fecha'] ?? cuota['fecha_vencimiento'];
    final estado = cuota['estado']?.toString() ?? cuota['pagada']?.toString() ?? 'pendiente';
    final isPagada = estado == '1' || estado == 'true' || estado == 'pagada';

    final fechaDate = fecha != null
        ? (fecha is DateTime ? fecha : DateTime.tryParse(fecha.toString()))
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de estado
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPagada
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPagada ? Icons.check_circle_outline : Icons.pending_outlined,
              color: isPagada ? AppColors.success : AppColors.warning,
              size: 24,
            ),
          ),

          AppSpacing.hSpaceMd,

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concepto,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.vSpaceXs,
                if (fechaDate != null)
                  Text(
                    _dateFormat.format(fechaDate),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),

          // Importe
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(importe is num ? importe : double.tryParse(importe.toString()) ?? 0),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.vSpaceXs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPagada
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPagada ? 'Pagada' : 'Pendiente',
                  style: AppTypography.caption.copyWith(
                    color: isPagada ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
