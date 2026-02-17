import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Footer de la Landing Page
/// Diseño modo claro basado en landing-blanco.html
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      padding: Responsive.padding(context).copyWith(
        top: AppSpacing.huge,
        bottom: AppSpacing.xl,
      ),
      child: Responsive.constrainedContent(
        maxWidth: 1280,
        child: Column(
          children: [
            // Main footer content
            Responsive.builder(
              mobile: (ctx) => Column(
                children: [
                  _buildLogoAndDescription(ctx),
                  AppSpacing.vSpaceXxl,
                  _buildLinksColumn(ctx),
                ],
              ),
              desktop: (ctx) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo y descripción
                  Expanded(
                    flex: 4,
                    child: _buildLogoAndDescription(ctx),
                  ),
                  AppSpacing.hSpaceHuge,
                  // Links
                  Expanded(
                    flex: 6,
                    child: _buildLinksRow(ctx),
                  ),
                ],
              ),
            ),
            AppSpacing.vSpaceXxl,

            // Divider
            Container(
              height: 1,
              color: AppColors.borderLight,
            ),
            AppSpacing.vSpaceLg,

            // Copyright y redes
            Responsive.builder(
              mobile: (ctx) => Column(
                children: [
                  _buildSocialLinks(ctx),
                  AppSpacing.vSpaceLg,
                  _buildCopyright(ctx),
                ],
              ),
              desktop: (ctx) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCopyright(ctx),
                  _buildFooterInfo(ctx),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo oficial de FutBase
        Row(
          children: [
            Image.asset(
              'lib/assets/icons/icono.png',
              height: 36,
              width: 36,
              fit: BoxFit.contain,
            ),
            AppSpacing.hSpaceSm,
            Text(
              'FutBase',
              style: AppTypography.h6.copyWith(
                color: AppColors.textLightMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        AppSpacing.vSpaceLg,
        Text(
          'El software de gestión de fútbol líder para academias juveniles. Empoderando entrenadores, involucrando padres y desarrollando jugadores de élite.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gray500,
            height: 1.6,
          ),
        ),
        AppSpacing.vSpaceLg,
        _buildSocialLinks(context),
      ],
    );
  }

  Widget _buildLinksColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLinkGroup(context, 'Producto', ['Funciones', 'Integraciones', 'Precios', 'Actualizaciones']),
        const SizedBox(height: 24),
        _buildLinkGroup(context, 'Soporte', ['Documentación', 'Centro de Ayuda', 'Comunidad', 'Estado de la API']),
        const SizedBox(height: 24),
        _buildLinkGroup(context, 'Legal', ['Privacidad', 'Términos de Servicio', 'Cookies']),
      ],
    );
  }

  Widget _buildLinksRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLinkGroup(context, 'Producto', ['Funciones', 'Integraciones', 'Precios', 'Actualizaciones'])),
        Expanded(child: _buildLinkGroup(context, 'Soporte', ['Documentación', 'Centro de Ayuda', 'Comunidad', 'Estado de la API'])),
        Expanded(child: _buildLinkGroup(context, 'Legal', ['Privacidad', 'Términos de Servicio', 'Cookies'])),
      ],
    );
  }

  Widget _buildLinkGroup(BuildContext context, String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textLightMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                link,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      '© 2024 FutBase Platform Inc. Todos los derechos reservados.',
      style: AppTypography.caption.copyWith(
        color: AppColors.gray400,
      ),
    );
  }

  Widget _buildFooterInfo(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 14),
            const SizedBox(width: 4),
            Text(
              'Sistemas Operativos',
              style: AppTypography.caption.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Text(
          'Hecho por y para el deporte rey.',
          style: AppTypography.caption.copyWith(
            color: AppColors.gray400,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SocialIcon(icon: Icons.language, onTap: () {}),
        AppSpacing.hSpaceMd,
        _SocialIcon(icon: Icons.public, onTap: () {}),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
