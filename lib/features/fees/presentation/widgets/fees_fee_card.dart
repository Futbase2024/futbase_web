import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Card individual de cuota de un jugador
class FeesFeeCard extends StatelessWidget {
  const FeesFeeCard({
    super.key,
    required this.fee,
    this.onTap,
    this.onPayTap,
  });

  final Map<String, dynamic> fee;
  final VoidCallback? onTap;
  final VoidCallback? onPayTap;

  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final jugadorNombre = fee['jugador_nombre'] as String? ?? '-';
    final equipoNombre = fee['equipo_nombre'] as String? ?? '-';
    final mes = fee['mes'] as int?;
    final year = fee['year'] as int?;
    final cantidadRaw = fee['cantidad'];
    final cantidad = cantidadRaw is int
        ? cantidadRaw.toDouble()
        : (cantidadRaw as num?)?.toDouble() ?? 0.0;
    final idestado = fee['idestado'] as int?;
    final estado = fee['estado'] as String? ?? '';

    final statusInfo = _getStatusInfo(idestado, estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: statusInfo.color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar con inicial
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusInfo.color.withValues(alpha: 0.15),
                        statusInfo.color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      jugadorNombre.isNotEmpty ? jugadorNombre[0].toUpperCase() : '?',
                      style: AppTypography.h6.copyWith(
                        color: statusInfo.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                AppSpacing.hSpaceMd,
                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              jugadorNombre,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.gray900,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 14,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              equipoNombre,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.gray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSpaceMd,
                // Período y cantidad
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getPeriodLabel(mes, year),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cantidad.toStringAsFixed(0)}€',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AppSpacing.hSpaceMd,
                // Badge de estado
                _buildStatusBadge(statusInfo, estado),
                // Botón de pagar (solo si está pendiente o vencido)
                if (idestado == 2 || idestado == 3) ...[
                  AppSpacing.hSpaceSm,
                  _buildPayButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_StatusInfo statusInfo, String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: 14,
            color: statusInfo.color,
          ),
          const SizedBox(width: 6),
          Text(
            estado.isNotEmpty ? estado : statusInfo.label,
            style: AppTypography.labelSmall.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Tooltip(
      message: 'Registrar pago',
      child: GestureDetector(
        onTap: onPayTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.payment,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel(int? mes, int? year) {
    if (mes == null || year == null) return '-';
    final monthName = mes >= 1 && mes <= 12 ? _monthNames[mes - 1] : '-';
    return '$monthName $year';
  }

  _StatusInfo _getStatusInfo(int? idestado, String? estadoName) {
    // idestado = 2 es "NO PAGADO", el resto son métodos de pago (pagado)
    if (idestado == 2) {
      return _StatusInfo(
        label: 'Pendiente',
        icon: Icons.schedule,
        color: AppColors.warning,
      );
    }

    // Para el resto, mostrar el método de pago (EFECTIVO, TARJETA, etc.)
    switch (idestado) {
      case 1:
        return _StatusInfo(
          label: estadoName ?? 'Efectivo',
          icon: Icons.payments_outlined,
          color: AppColors.primary,
        );
      case 3:
        return _StatusInfo(
          label: estadoName ?? 'Tarjeta',
          icon: Icons.credit_card_outlined,
          color: AppColors.primary,
        );
      case 4:
        return _StatusInfo(
          label: estadoName ?? 'Transferencia',
          icon: Icons.account_balance_outlined,
          color: AppColors.primary,
        );
      case 5:
        return _StatusInfo(
          label: estadoName ?? 'Bizum',
          icon: Icons.phone_android_outlined,
          color: AppColors.primary,
        );
      default:
        return _StatusInfo(
          label: estadoName ?? 'Pagado',
          icon: Icons.check_circle_outline,
          color: AppColors.primary,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}
