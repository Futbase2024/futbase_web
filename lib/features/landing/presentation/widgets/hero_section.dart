import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/ce_button.dart';

/// Hero Section - Sección principal de la landing page
///
/// Diseño basado en Stitch con modo claro:
/// - Badge animado "Gestión de Clubes de Nueva Generación"
/// - Título con "como un profesional" en primario (#00554E)
/// - CTAs con estilo del diseño
/// - Trust badges: VELOX, STRIKE, APEX
/// - Imagen con floating card de estadísticas
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: Responsive.value(
          context,
          mobile: 600,
          tablet: 700,
          desktop: 800,
        ),
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Stack(
        children: [
          // ========== GRADIENTE RADIAL DE FONDO ==========
          _buildBackgroundGradient(),

          // ========== CONTENIDO ==========
          Responsive.constrainedContent(
            maxWidth: 1280,
            child: Responsive.builder(
              mobile: (context) => _buildMobileLayout(context),
              tablet: (context) => _buildTabletLayout(context),
              desktop: (context) => _buildDesktopLayout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: Responsive.padding(context).copyWith(
        top: 120,
        bottom: AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextContent(context, isDesktop: false),
          AppSpacing.vSpaceXxxl,
          _buildIllustration(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: Responsive.padding(context).copyWith(
        top: 120,
        bottom: AppSpacing.huge,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextContent(context, isDesktop: false),
          AppSpacing.vSpaceHuge,
          _buildIllustration(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: Responsive.padding(context).copyWith(
        top: 120,
        bottom: AppSpacing.huge,
      ),
      child: Row(
        children: [
          // Contenido de texto (izquierda)
          Expanded(
            flex: 5,
            child: _buildTextContent(context, isDesktop: true),
          ),
          AppSpacing.hSpaceHuge,
          // Ilustración (derecha)
          Expanded(
            flex: 5,
            child: _buildIllustration(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        // ========== BADGE ANIMADO ==========
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: _buildAnimatedBadge(),
        ),

        AppSpacing.vSpaceXl,

        // ========== TÍTULO PRINCIPAL ==========
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: _buildTitle(context, isDesktop),
        ),

        AppSpacing.vSpaceXl,

        // ========== SUBTÍTULO ==========
        FadeInDown(
          delay: const Duration(milliseconds: 400),
          child: _buildSubtitle(context, isDesktop),
        ),

        AppSpacing.vSpaceXxl,

        // ========== CTAs ==========
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          child: _buildCtas(context, isDesktop),
        ),

        AppSpacing.vSpaceXxl,

        // ========== TRUST BADGES ==========
        FadeInUp(
          delay: const Duration(milliseconds: 800),
          child: _buildTrustBadges(context, isDesktop),
        ),
      ],
    );
  }

  Widget _buildAnimatedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Punto animado (ping effect)
          _AnimatedDot(),
          const SizedBox(width: 8),
          Text(
            'GESTIÓN DE CLUBES DE NUEVA GENERACIÓN',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDesktop) {
    final textStyle = Responsive.value(
      context,
      mobile: AppTypography.h3,
      tablet: AppTypography.h2,
      desktop: AppTypography.h1,
    );

    return RichText(
      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
      text: TextSpan(
        style: textStyle.copyWith(
          color: AppColors.textLightMain,
          height: 1.1,
        ),
        children: [
          const TextSpan(text: 'Gestiona tu club\n'),
          TextSpan(
            text: 'como un profesional.',
            style: textStyle.copyWith(
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, bool isDesktop) {
    return Text(
      'La plataforma integral de gestión para academias de fútbol modernas. '
      'Rastrea estadísticas, automatiza cuotas y optimiza el desarrollo de jugadores en un solo lugar.',
      style: Responsive.value(
        context,
        mobile: AppTypography.bodyMedium,
        tablet: AppTypography.bodyLarge,
        desktop: AppTypography.bodyLarge,
      ).copyWith(
        color: AppColors.gray500,
        height: 1.6,
      ),
      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
    );
  }

  Widget _buildCtas(BuildContext context, bool isDesktop) {
    final primaryButton = CEButton(
      label: 'Prueba Gratis',
      type: CEButtonType.primary,
      icon: Icons.arrow_forward,
      iconPosition: CEButtonIconPosition.right,
      onPressed: () => context.go(AppRouter.dashboard),
    );

    final secondaryButton = CEButton(
      label: 'Ver Demo',
      type: CEButtonType.secondary,
      onPressed: () => context.go(AppRouter.login),
    );

    if (!isDesktop) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: primaryButton),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: secondaryButton),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        primaryButton,
        const SizedBox(width: 16),
        secondaryButton,
      ],
    );
  }

  Widget _buildTrustBadges(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'CONFIADO POR ACADEMIAS LÍDERES',
          style: AppTypography.caption.copyWith(
            color: AppColors.gray400,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: isDesktop
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            _TrustBadge(icon: Icons.shield, label: 'VELOX'),
            const SizedBox(width: 24),
            _TrustBadge(icon: Icons.bolt, label: 'STRIKE'),
            const SizedBox(width: 24),
            _TrustBadge(icon: Icons.token, label: 'APEX'),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final imageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuDDDKxPRwk1lGcIiEz-WXX2q3FCZmFQCUxNg66dVG2_YO38uxj0WnlJqnVpDXzby5oy4S5RUmbmdl3C20bH46pUfJoZNA65dBuJdBbYzcQwUaI5qmoJT70GoCbQa7JOFA0XtnjR6PAoCxo42SzLVLUNteeAkRdT3lHlJlK2YRsU0rxZtoiOI945QMcxMPondG3ncP5dS0aBMZM11NprvdHmIoxq79BT5jZw-sc_hytkjqVd-yRBH2RUh-CzTnrNsBbySNYVhIdENQ';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow de fondo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Card principal con imagen
        Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.value(
              context,
              mobile: 300,
              tablet: 400,
              desktop: 500,
            ),
            maxHeight: Responsive.value(
              context,
              mobile: 400,
              tablet: 500,
              desktop: 500,
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.borderRadiusXl,
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppSpacing.borderRadiusXl,
            child: Stack(
              children: [
                // Imagen del héroe
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: AppColors.gray100,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.gray100,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Floating card con estadísticas
                Positioned(
                  bottom: 40,
                  left: -24,
                  child: _buildFloatingDataCard(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingDataCard(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precisión en Pases',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '+12%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mini chart de barras
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniBar(0.5),
              _buildMiniBar(0.75),
              _buildMiniBar(1.0),
              _buildMiniBar(0.65),
              _buildMiniBar(0.35),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pico de Optimización',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textLightMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBar(double height) {
    return Expanded(
      child: Container(
        height: 48 * height,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2 + height * 0.6),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
    );
  }
}

/// Punto animado con efecto ping
class _AnimatedDot extends StatefulWidget {
  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        children: [
          // Ping effect
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: _animation.value * 0.75),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          // Dot estático
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary.withValues(alpha: 0.6),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
