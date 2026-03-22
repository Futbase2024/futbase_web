import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Card de resumen con KPIs financieros de cuotas
class FeesSummaryCard extends StatelessWidget {
  const FeesSummaryCard({
    super.key,
    required this.totalEsperado,
    required this.totalPagado,
    required this.totalPendiente,
    required this.totalVencido,
    this.countPagado = 0,
    this.countPendiente = 0,
    this.countVencido = 0,
  });

  final double totalEsperado;
  final double totalPagado;
  final double totalPendiente;
  final double totalVencido;
  final int countPagado;
  final int countPendiente;
  final int countVencido;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KpiCard(
              icon: Icons.euro,
              title: 'Total Esperado',
              value: _formatCurrency(totalEsperado),
              subtitle: '${countPagado + countPendiente + countVencido} cuotas',
              color: AppColors.gray500,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: _KpiCard(
              icon: Icons.check_circle_outline,
              title: 'Pagado',
              value: _formatCurrency(totalPagado),
              subtitle: '$countPagado cuotas',
              color: AppColors.success,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: _KpiCard(
              icon: Icons.pending_outlined,
              title: 'Pendiente',
              value: _formatCurrency(totalPendiente),
              subtitle: '$countPendiente cuotas',
              color: AppColors.warning,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: _KpiCard(
              icon: Icons.error_outline,
              title: 'Vencido',
              value: _formatCurrency(totalVencido),
              subtitle: '$countVencido cuotas',
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0)}€';
  }
}

/// Widget interno para cada KPI
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
