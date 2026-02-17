import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Botón genérico reutilizable para toda la aplicación FutBase
///
/// Estándar de diseño:
/// - Border radius pequeño (6px) para aspecto cuadrado
/// - Padding consistente: horizontal 20, vertical 12
/// - Primary: fondo verde oscuro (#00554E) con texto blanco
/// - Secondary: fondo blanco con borde gris
/// - Outline: transparente con borde
class CEButton extends StatelessWidget {
  const CEButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = CEButtonType.primary,
    this.icon,
    this.iconPosition = CEButtonIconPosition.left,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final CEButtonType type;
  final IconData? icon;
  final CEButtonIconPosition iconPosition;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;

  /// Border radius estándar: 6px (cuadrado con esquinas suaves)
  static const double borderRadius = 6.0;

  /// Padding estándar horizontal
  static const double paddingHorizontal = 20.0;

  /// Padding estándar vertical
  static const double paddingVertical = 12.0;

  /// Altura estándar del botón
  static const double standardHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    switch (type) {
      case CEButtonType.primary:
        return _buildPrimaryButton(effectiveOnPressed);
      case CEButtonType.secondary:
        return _buildSecondaryButton(effectiveOnPressed);
      case CEButtonType.outline:
        return _buildOutlineButton(effectiveOnPressed);
      case CEButtonType.ghost:
        return _buildGhostButton(effectiveOnPressed);
      case CEButtonType.dark:
        return _buildDarkButton(effectiveOnPressed);
      case CEButtonType.outlineDark:
        return _buildOutlineDarkButton(effectiveOnPressed);
    }
  }

  /// Primary: Fondo verde oscuro (#00554E) con texto blanco
  Widget _buildPrimaryButton(VoidCallback? onPressed) {
    return SizedBox(
      width: width,
      height: height ?? standardHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Secondary: Fondo blanco con borde gris
  Widget _buildSecondaryButton(VoidCallback? onPressed) {
    return SizedBox(
      width: width,
      height: height ?? standardHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textLightMain,
          disabledBackgroundColor: AppColors.gray100,
          disabledForegroundColor: AppColors.gray400,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isEnabled ? AppColors.borderLight : AppColors.gray200,
              width: 1,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Outline: Transparente con borde
  Widget _buildOutlineButton(VoidCallback? onPressed) {
    return SizedBox(
      width: width,
      height: height ?? standardHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textLightMain,
          disabledForegroundColor: AppColors.gray400,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(
            color: isEnabled ? AppColors.textLightMain : AppColors.gray300,
            width: 1.5,
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Ghost: Sin fondo ni borde, solo texto (color oscuro para landing page)
  Widget _buildGhostButton(VoidCallback? onPressed) {
    return SizedBox(
      width: width,
      height: height ?? standardHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gray700,
          disabledForegroundColor: AppColors.gray400,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Dark: Fondo oscuro con texto blanco (para CTA sobre fondo verde)
  Widget _buildDarkButton(VoidCallback? onPressed) {
    return SizedBox(
      width: width,
      height: height ?? standardHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textLightMain,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.gray400,
          disabledForegroundColor: AppColors.gray200,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Outline Dark: Borde oscuro transparente (para CTA sobre fondo verde)
  Widget _buildOutlineDarkButton(VoidCallback? onPressed) {
    return SizedBox(
      width: width,
      height: height ?? standardHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textLightMain,
          disabledForegroundColor: AppColors.gray400,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(
            color: isEnabled ? AppColors.textLightMain : AppColors.gray300,
            width: 1.5,
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == CEButtonType.primary
                ? AppColors.textLightMain
                : AppColors.textLightMain,
          ),
        ),
      );
    }

    final textWidget = Text(
      label,
      style: AppTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(icon, size: 18);

    if (iconPosition == CEButtonIconPosition.left) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          const SizedBox(width: 8),
          iconWidget,
        ],
      );
    }
  }
}

/// Tipos de botón disponibles
enum CEButtonType {
  /// Botón principal: fondo verde con texto negro
  primary,

  /// Botón secundario: fondo blanco con borde
  secondary,

  /// Botón outline: transparente con borde oscuro
  outline,

  /// Botón ghost: sin fondo ni borde
  ghost,

  /// Botón dark: fondo oscuro con texto blanco (para CTA sobre fondo verde)
  dark,

  /// Botón outline dark: borde oscuro transparente (para CTA sobre fondo verde)
  outlineDark,
}

/// Posición del icono en el botón
enum CEButtonIconPosition {
  left,
  right,
}
