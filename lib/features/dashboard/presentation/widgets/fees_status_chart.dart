import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Gráfico circular de estado de cuotas
/// Diseño basado en dashboard_principal_futbase (code.html)
/// Muestra el porcentaje de cuotas cobradas vs pendientes
class FeesStatusChart extends StatelessWidget {
  const FeesStatusChart({
    super.key,
    this.percentage = 85,
    this.paidAmount = '2.932€',
    this.pendingAmount = '518€',
    this.period = 'Mayo 2024',
  });

  final double percentage;
  final String paidAmount;
  final String pendingAmount;
  final String period;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Text(
            'Estado de Cuotas',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Periodo $period',
            style: AppTypography.caption.copyWith(
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 40),
          // Chart
          SizedBox(
            height: 224,
            child: _buildChart(),
          ),
          const SizedBox(height: 40),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 224,
          height: 224,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: 76,
              sections: [
                PieChartSectionData(
                  value: percentage,
                  color: AppColors.primary,
                  radius: 14,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 100 - percentage,
                  color: AppColors.gray50,
                  radius: 14,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        // Center text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${percentage.toInt()}%',
              style: AppTypography.statLarge.copyWith(
                color: AppColors.gray900,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'COBRADO',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray400,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem(
          color: AppColors.primary,
          label: 'Pagado',
          amount: paidAmount,
        ),
        const SizedBox(height: 16),
        _buildLegendItem(
          color: AppColors.gray100,
          label: 'Pendiente',
          amount: pendingAmount,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String amount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
