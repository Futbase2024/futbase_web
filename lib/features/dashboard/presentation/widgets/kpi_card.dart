import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Card de KPI para el dashboard
/// Diseño basado en dashboard_principal_futbase (code.html)
/// Soporta dos estilos: primario (verde) y secundario (blanco)
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trendValue,
    this.isPrimary = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? trendValue;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: AppColors.gray100),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Contenido principal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono y trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPrimary
                              ? AppColors.white.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: isPrimary ? AppColors.white : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      if (trendValue != null) _buildTrendBadge(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Título
                  Text(
                    title,
                    style: AppTypography.bodySmall.copyWith(
                      color: isPrimary
                          ? AppColors.white.withValues(alpha: 0.6)
                          : AppColors.gray400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Valor
                  Text(
                    value,
                    style: AppTypography.statLarge.copyWith(
                      color: isPrimary ? AppColors.white : AppColors.primary,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
              // Icono decorativo de fondo (solo en primario)
              if (isPrimary)
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Icon(
                    icon,
                    size: 96,
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.white.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        trendValue!,
        style: AppTypography.labelSmall.copyWith(
          color: isPrimary ? AppColors.white : AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Datos de ejemplo para los KPIs
class KpiData {
  const KpiData({
    required this.icon,
    required this.title,
    required this.value,
    this.trendValue,
    this.isPrimary = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? trendValue;
  final bool isPrimary;

  /// KPIs de ejemplo para el dashboard según el diseño
  static List<KpiData> get sampleData => [
        KpiData(
          icon: Icons.groups,
          title: 'Total Jugadores',
          value: '124',
          trendValue: '+12% MES',
          isPrimary: true,
        ),
        KpiData(
          icon: Icons.calendar_today,
          title: 'Entrenamientos Hoy',
          value: '4 Sesiones',
          trendValue: 'HOY: 18:00',
          isPrimary: true,
        ),
        KpiData(
          icon: Icons.trending_up,
          title: 'Asistencia Media',
          value: '92%',
          isPrimary: false,
        ),
        KpiData(
          icon: Icons.account_balance_wallet,
          title: 'Ingresos Mensuales',
          value: '3.450€',
          isPrimary: false,
        ),
      ];
}
