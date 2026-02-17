import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Sección de "Decisiones basadas en datos"
/// Diseño modo claro basado en landing-blanco.html (líneas 241-310)
/// Muestra mockup del dashboard con gráfico de rendimiento
class DataInsightsSection extends StatelessWidget {
  const DataInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceLight,
      padding: Responsive.padding(context).copyWith(
        top: AppSpacing.huge,
        bottom: AppSpacing.huge,
      ),
      child: Responsive.constrainedContent(
        maxWidth: 1280,
        child: Responsive.builder(
          mobile: (ctx) => _buildMobileLayout(ctx),
          desktop: (ctx) => _buildDesktopLayout(ctx),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildContent(context),
        const SizedBox(height: 48),
        _buildMockup(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mockup (izquierda en desktop)
        Expanded(
          flex: 5,
          child: _buildMockup(context),
        ),
        const SizedBox(width: 80),
        // Contenido (derecha en desktop)
        Expanded(
          flex: 5,
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Decisiones basadas en datos, del campo a la oficina.',
          style: Responsive.value(
            context,
            mobile: AppTypography.h4,
            desktop: AppTypography.h3,
          ).copyWith(
            color: AppColors.textLightMain,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'FutBase no es solo una base de datos. Es un motor inteligente que procesa cada partido, entrenamiento y pago para darte una visión de 360 grados de la salud y desarrollo de tu club.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.gray500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        // Features
        _buildFeatureItem(
          icon: Icons.analytics,
          title: 'Rendimiento Predictivo',
          description: 'Identifica talentos prematuramente usando datos históricos y comparativas.',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.timeline,
          title: 'Finanzas en Tiempo Real',
          description: 'Rastrea cada céntimo con contabilidad automatizada y proyecciones de ingresos.',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textLightMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockup(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Window header (traffic lights)
          _buildWindowHeader(),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMockupContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowHeader() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockupContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        if (!isWide) {
          return _buildStackedLayout();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar mock
            Expanded(
              flex: 3,
              child: _buildSidebarMock(),
            ),
            const SizedBox(width: 16),
            // Main content mock
            Expanded(
              flex: 9,
              child: _buildMainContentMock(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStackedLayout() {
    return Column(
      children: [
        _buildMainContentMock(),
        const SizedBox(height: 16),
        _buildSidebarMock(),
      ],
    );
  }

  Widget _buildSidebarMock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 16, width: 48, color: AppColors.gray200),
        const SizedBox(height: 16),
        Container(height: 16, width: double.infinity, color: AppColors.gray100),
        const SizedBox(height: 8),
        Container(height: 16, width: 32, color: AppColors.gray100),
        const SizedBox(height: 16),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentMock() {
    return Column(
      children: [
        // KPI cards row
        Row(
          children: [
            Expanded(
              child: _buildKpiMock(
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKpiMock(isPrimary: false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart mock
        _buildChartMock(),
      ],
    );
  }

  Widget _buildKpiMock({required bool isPrimary}) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.gray50,
        border: Border.all(
          color: isPrimary
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.gray200,
        ),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 12,
            width: 48,
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.gray300,
          ),
          const SizedBox(height: 8),
          Container(
            height: 24,
            width: 72,
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.gray400,
          ),
        ],
      ),
    );
  }

  Widget _buildChartMock() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Stack(
        children: [
          // SVG-like curve using CustomPainter
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _CurvePainter(),
          ),
          // Label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: AppColors.white,
              child: Text(
                'PANEL DE CONTROL: RENDIMIENTO',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final strokePath = Path();

    // Create bezier curve path
    final w = size.width;
    final h = size.height;

    // Fill path (area under curve)
    path.moveTo(0, h);
    path.cubicTo(w * 0.125, h * 0.93, w * 0.25, h * 0.13, w * 0.375, h * 0.53);
    path.cubicTo(w * 0.5, h * 0.07, w * 0.625, h * 0.07, w * 0.75, h * 0.33);
    path.cubicTo(w * 0.875, h * 0.33, w, 0, w, 0);
    path.lineTo(w, h);
    path.close();

    // Stroke path (just the curve)
    strokePath.moveTo(0, h);
    strokePath.cubicTo(w * 0.125, h * 0.93, w * 0.25, h * 0.13, w * 0.375, h * 0.53);
    strokePath.cubicTo(w * 0.5, h * 0.07, w * 0.625, h * 0.07, w * 0.75, h * 0.33);
    strokePath.cubicTo(w * 0.875, h * 0.33, w, 0, w, 0);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
