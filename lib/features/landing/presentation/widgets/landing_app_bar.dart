import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/ce_button.dart';

/// AppBar profesional para la Landing Page
/// Diseño modo claro con glassmorphism basado en landing-blanco.html
class LandingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackground;

  const LandingAppBar({
    super.key,
    this.showBackground = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: showBackground
            ? AppColors.white.withValues(alpha: 0.95)
            : AppColors.white.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: showBackground ? AppColors.borderLight : Colors.transparent,
          ),
        ),
        boxShadow: showBackground
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Padding(
              padding: Responsive.horizontalPadding(context).copyWith(
                top: AppSpacing.lg,
                bottom: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  // ========== LOGO ==========
                  _buildLogo(context),

                  const Spacer(),

                  // ========== NAVEGACIÓN ==========
                  if (context.isDesktop) ...[
                    _buildNavLinks(context),
                    AppSpacing.hSpaceXl,
                  ],

                  // ========== CTA BUTTONS ==========
                  _buildCtaButtons(context),

                  // ========== MENU MÓVIL ==========
                  if (!context.isDesktop) ...[
                    AppSpacing.hSpaceMd,
                    _buildMobileMenu(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      children: [
        // Logo oficial de FutBase
        Image.asset(
          'lib/assets/icons/icono.png',
          height: 40,
          width: 40,
          fit: BoxFit.contain,
        ),
        AppSpacing.hSpaceSm,
        // Nombre de la app
        Text(
          'FutBase',
          style: AppTypography.h6.copyWith(
            color: AppColors.textLightMain,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildNavLinks(BuildContext context) {
    final links = [
      _NavLink('Funciones', '#features'),
      _NavLink('Estadísticas', '#statistics'),
      _NavLink('Precios', '#pricing'),
      _NavLink('Sobre nosotros', '#about'),
    ];

    return Row(
      children: links.map((link) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextButton(
            onPressed: () {
              // TODO: Scroll to section
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray600,
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              link.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCtaButtons(BuildContext context) {
    if (context.isMobile) {
      // Solo botón primary en móvil
      return CEButton(
        label: 'Solicitar Demo',
        type: CEButtonType.primary,
        onPressed: () => context.go(AppRouter.dashboard),
      );
    }

    // Dos botones en tablet/desktop
    return Row(
      children: [
        // Log In - Botón simple con texto oscuro
        TextButton(
          onPressed: () => context.go(AppRouter.login),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textLightMain,
          ),
          child: Text(
            'Iniciar Sesión',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textLightMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppSpacing.hSpaceMd,
        // Request Demo
        CEButton(
          label: 'Solicitar Demo',
          type: CEButtonType.primary,
          onPressed: () => context.go(AppRouter.dashboard),
        ),
      ],
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showMobileMenu(context);
      },
      icon: const Icon(
        Icons.menu,
        color: AppColors.textLightMain,
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => Container(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star, color: AppColors.primary),
              title: Text(
                'Funcionalidades',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textLightMain,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: AppColors.primary),
              title: Text(
                'Estadísticas',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textLightMain,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: AppColors.primary),
              title: Text(
                'Precios',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textLightMain,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: AppColors.borderLight),
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.primary),
              title: Text(
                'Iniciar Sesión',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textLightMain,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink {
  final String label;
  final String anchor;

  const _NavLink(this.label, this.anchor);
}
