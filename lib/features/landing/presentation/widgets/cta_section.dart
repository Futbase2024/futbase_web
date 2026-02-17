import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/ce_button.dart';

/// Sección de Call to Action final
/// Basado en el diseño landing.html con fondo primary
class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: Responsive.padding(context).copyWith(
        top: AppSpacing.huge,
        bottom: AppSpacing.huge,
      ),
      child: Responsive.constrainedContent(
        maxWidth: 1280,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppSpacing.borderRadiusXl,
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -48,
                right: -48,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -48,
                left: -48,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Column(
                children: [
                  // Título
                  Text(
                    '¿Listo para transformar\ntu academia?',
                    style: Responsive.value(
                      context,
                      mobile: AppTypography.h4,
                      desktop: AppTypography.h3,
                    ).copyWith(
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Subtítulo
                  Text(
                    'Únete a más de 500 clubes que ya han mejorado su gestión. Empieza tu prueba gratuita de 14 días hoy mismo.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Botones
                  Responsive.builder(
                    mobile: (ctx) => Column(
                      children: [
                        _buildPrimaryButton(ctx),
                        const SizedBox(height: 12),
                        _buildSecondaryButton(ctx),
                      ],
                    ),
                    desktop: (ctx) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPrimaryButton(ctx),
                        const SizedBox(width: 16),
                        _buildSecondaryButton(ctx),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer text
                  Text(
                    'Sin tarjeta de crédito. Cancela cuando quieras.',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return CEButton(
      label: 'Regístrate Ahora',
      type: CEButtonType.dark,
      onPressed: () => context.go(AppRouter.dashboard),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return CEButton(
      label: 'Reservar Demo en Vivo',
      type: CEButtonType.outlineDark,
      onPressed: () => context.go(AppRouter.dashboard),
    );
  }
}
