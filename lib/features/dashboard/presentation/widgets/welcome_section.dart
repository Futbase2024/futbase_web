import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Sección de bienvenida del dashboard
/// Muestra saludo, fecha actual y botones de acción rápida
/// Diseño basado en dashboard_principal_futbase (code.html)
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({
    super.key,
    this.onAddPlayer,
    this.onRegisterExpense,
  });

  final VoidCallback? onAddPlayer;
  final VoidCallback? onRegisterExpense;

  /// Nombres de los meses en español
  static const _meses = [
    '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  /// Formatea la fecha en español sin requerir inicialización de locale
  String _formatDate(DateTime date) {
    return '${date.day} de ${_meses[date.month]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saludo y fecha
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola de nuevo!',
              style: AppTypography.h3.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
                fontSize: 30,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Aquí tienes el resumen de hoy, ${_formatDate(now)}.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Botones de acción
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            // Botón Añadir Jugador
            _ActionButton(
              label: 'Añadir Jugador',
              icon: Icons.person_add,
              onPressed: onAddPlayer,
              isPrimary: true,
            ),
            // Botón Registrar Gasto
            _ActionButton(
              label: 'Registrar Gasto',
              icon: Icons.receipt_long,
              onPressed: onRegisterExpense,
              isPrimary: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    required this.isPrimary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : AppColors.white,
        foregroundColor: isPrimary ? AppColors.white : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: isPrimary ? 0 : 0,
        shadowColor: isPrimary ? AppColors.primary.withValues(alpha: 0.2) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
