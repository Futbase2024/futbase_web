import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Gráfico financiero de barras para el dashboard
/// Diseño modo claro basado en dashboard-blanco.html
/// Muestra ingresos vs gastos por mes
class FinancialChart extends StatelessWidget {
  const FinancialChart({
    super.key,
    List<FinancialData>? data,
  }) : data = data ?? _defaultData;

  static const List<FinancialData> _defaultData = [
    FinancialData(month: 'ENE', incomePercent: 60, expensePercent: 30),
    FinancialData(month: 'FEB', incomePercent: 80, expensePercent: 40),
    FinancialData(month: 'MAR', incomePercent: 70, expensePercent: 45),
    FinancialData(month: 'ABR', incomePercent: 95, expensePercent: 25),
    FinancialData(month: 'MAY', incomePercent: 65, expensePercent: 55),
    FinancialData(month: 'JUN', incomePercent: 85, expensePercent: 40),
  ];

  final List<FinancialData> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.gray100),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen Financiero',
                    style: AppTypography.h6.copyWith(
                      color: context.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Análisis de rendimiento mensual',
                    style: AppTypography.caption.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              // Leyenda
              Row(
                children: [
                  _buildLegendItem(
                    context: context,
                    color: context.primaryColor,
                    label: 'Ingresos',
                  ),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    context: context,
                    color: AppColors.gray300,
                    label: 'Gastos',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Gráfico
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) => _buildBarGroup(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBarGroup(BuildContext context, FinancialData data) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Barras
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Barra de ingresos
                _buildBar(
                  height: data.incomePercent * 1.6,
                  color: context.primaryColor,
                  isPrimary: true,
                ),
                const SizedBox(width: 4),
                // Barra de gastos
                _buildBar(
                  height: data.expensePercent * 1.6,
                  color: AppColors.gray200,
                  isPrimary: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Mes
          Text(
            data.month,
            style: AppTypography.caption.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required double height,
    required Color color,
    required bool isPrimary,
  }) {
    return Container(
      width: 16,
      height: height.clamp(4.0, 160.0),
      decoration: BoxDecoration(
        color: isPrimary ? color.withValues(alpha: 0.8) : color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

/// Datos para el gráfico financiero
class FinancialData {
  const FinancialData({
    required this.month,
    required this.incomePercent,
    required this.expensePercent,
  });

  final String month;
  final double incomePercent;
  final double expensePercent;

  /// Datos de ejemplo
  static const List<FinancialData> sampleData = [
    FinancialData(month: 'ENE', incomePercent: 60, expensePercent: 30),
    FinancialData(month: 'FEB', incomePercent: 80, expensePercent: 40),
    FinancialData(month: 'MAR', incomePercent: 70, expensePercent: 45),
    FinancialData(month: 'ABR', incomePercent: 95, expensePercent: 25),
    FinancialData(month: 'MAY', incomePercent: 65, expensePercent: 55),
    FinancialData(month: 'JUN', incomePercent: 85, expensePercent: 40),
  ];
}
