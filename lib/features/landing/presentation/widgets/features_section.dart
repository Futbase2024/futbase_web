import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Sección de características principales
/// Diseño modo claro basado en landing-blanco.html
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.bar_chart,
        title: 'Análisis y Estadísticas',
        description: 'Profundiza en métricas de rendimiento. Rastrea precisión de pases, distancia recorrida y goles en cada grupo de edad.',
        highlights: ['Mapas de calor', 'Gráficos de crecimiento'],
      ),
      _Feature(
        icon: Icons.payments,
        title: 'Gestión de Cobros',
        description: 'Facturación y seguimiento de pagos automatizados. Olvida las hojas de cálculo manuales y las cuotas vencidas.',
        highlights: ['Integración con Stripe', 'Recordatorios automáticos'],
      ),
      _Feature(
        icon: Icons.group,
        title: 'Gestión de Plantillas',
        description: 'Administra equipos, jugadores y cuerpo técnico en una base de datos centralizada. Control de asistencia en vivo.',
        highlights: ['Fichas Digitales', 'Historial de traspasos'],
      ),
      _Feature(
        icon: Icons.fitness_center,
        title: 'Planes de Entrenamiento',
        description: 'Planifica ejercicios y sesiones para cada nivel. Comparte materiales de entrenamiento con el staff al instante.',
        highlights: null,
      ),
      _Feature(
        icon: Icons.emoji_events,
        title: 'Informes de Partidos',
        description: 'Resultados en tiempo real, actas digitales e informes de rendimiento. Sincronización directa con clasificaciones.',
        highlights: null,
      ),
      _Feature(
        icon: Icons.account_balance_wallet,
        title: 'Contabilidad del Club',
        description: 'Transparencia financiera total. Gestiona gastos, inscripciones a torneos e ingresos por patrocinios fácilmente.',
        highlights: null,
      ),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: Responsive.padding(context).copyWith(
        top: AppSpacing.huge,
        bottom: AppSpacing.huge,
      ),
      child: Responsive.constrainedContent(
        maxWidth: 1280,
        child: Column(
          children: [
            // ========== HEADER ==========
            _buildHeader(context),

            AppSpacing.vSpaceXxxl,

            // ========== GRID DE FEATURES ==========
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = Responsive.gridColumns(context);
                return Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.xl,
                  children: features.map((feature) {
                    return SizedBox(
                      width: (constraints.maxWidth - (AppSpacing.xl * (columns - 1))) / columns,
                      child: _FeatureCard(feature: feature),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LA PLATAFORMA',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Todo lo que necesitas\npara liderar tu liga.',
                      style: Responsive.value(
                        context,
                        mobile: AppTypography.h4,
                        desktop: AppTypography.h3,
                      ).copyWith(
                        color: AppColors.textLightMain,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xxxl),
                  child: Text(
                    'Potentes funciones diseñadas específicamente para academias juveniles. Optimiza operaciones y enfócate en lo que importa: desarrollar talento.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LA PLATAFORMA',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.oliveDark,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Todo lo que necesitas\npara liderar tu liga.',
              style: AppTypography.h4.copyWith(
                color: AppColors.textLightMain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Potentes funciones diseñadas específicamente para academias juveniles. Optimiza operaciones y enfócate en lo que importa: desarrollar talento.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              feature.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 24),

          // Título
          Text(
            feature.title,
            style: AppTypography.h6.copyWith(
              color: AppColors.textLightMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Descripción
          Text(
            feature.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
              height: 1.6,
            ),
          ),

          // Highlights
          if (feature.highlights != null) ...[
            const SizedBox(height: 24),
            ...feature.highlights!.map((highlight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        highlight,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final List<String>? highlights;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    this.highlights,
  });
}
