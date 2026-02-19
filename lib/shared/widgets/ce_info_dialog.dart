import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Tipos de diálogo de información
enum CeInfoDialogType {
  info,
  success,
  warning,
  error,
}

/// Diálogo de información reutilizable para toda la aplicación
///
/// Uso:
/// ```dart
/// await CeInfoDialog.show(
///   context,
///   type: CeInfoDialogType.warning,
///   title: 'Dorsal duplicado',
///   message: 'El dorsal 10 ya está asignado a otro jugador',
/// );
/// ```
class CeInfoDialog extends StatelessWidget {
  const CeInfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = CeInfoDialogType.info,
    this.buttonText = 'Entendido',
  });

  final String title;
  final String message;
  final CeInfoDialogType type;
  final String buttonText;

  /// Muestra el diálogo de información
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    CeInfoDialogType type = CeInfoDialogType.info,
    String buttonText = 'Entendido',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CeInfoDialog(
        title: title,
        message: message,
        type: type,
        buttonText: buttonText,
      ),
    );
  }

  /// Muestra un diálogo de error
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: CeInfoDialogType.error,
      buttonText: buttonText,
    );
  }

  /// Muestra un diálogo de advertencia
  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: CeInfoDialogType.warning,
      buttonText: buttonText,
    );
  }

  /// Muestra un diálogo de éxito
  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: CeInfoDialogType.success,
      buttonText: buttonText,
    );
  }

  /// Muestra un diálogo de información
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: CeInfoDialogType.info,
      buttonText: buttonText,
    );
  }

  IconData get _icon => switch (type) {
        CeInfoDialogType.info => Icons.info_outline,
        CeInfoDialogType.success => Icons.check_circle_outline,
        CeInfoDialogType.warning => Icons.warning_amber_rounded,
        CeInfoDialogType.error => Icons.error_outline,
      };

  Color get _color => switch (type) {
        CeInfoDialogType.info => AppColors.info,
        CeInfoDialogType.success => AppColors.success,
        CeInfoDialogType.warning => AppColors.warning,
        CeInfoDialogType.error => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 48,
                color: _color,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              title,
              style: AppTypography.h6.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de confirmación con acciones Sí/No
class CeConfirmDialog extends StatelessWidget {
  const CeConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.type = CeInfoDialogType.warning,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final CeInfoDialogType type;

  /// Muestra el diálogo de confirmación
  /// Retorna true si el usuario confirma, false si cancela
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    CeInfoDialogType type = CeInfoDialogType.warning,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CeConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        type: type,
      ),
    );
    return result ?? false;
  }

  IconData get _icon => switch (type) {
        CeInfoDialogType.info => Icons.info_outline,
        CeInfoDialogType.success => Icons.check_circle_outline,
        CeInfoDialogType.warning => Icons.warning_amber_rounded,
        CeInfoDialogType.error => Icons.error_outline,
      };

  Color get _color => switch (type) {
        CeInfoDialogType.info => AppColors.info,
        CeInfoDialogType.success => AppColors.success,
        CeInfoDialogType.warning => AppColors.warning,
        CeInfoDialogType.error => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 48,
                color: _color,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              title,
              style: AppTypography.h6.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray700,
                      side: BorderSide(color: AppColors.gray300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
