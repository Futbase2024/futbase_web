import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Sección de tutores del jugador
class PlayerTutoresSection extends StatelessWidget {
  const PlayerTutoresSection({
    super.key,
    required this.tutores,
    this.isLoading = false,
    this.onCreate,
    this.onEdit,
    this.onDelete,
    this.onContact,
  });

  final List<Map<String, dynamic>> tutores;
  final bool isLoading;
  final VoidCallback? onCreate;
  final void Function(Map<String, dynamic> tutor)? onEdit;
  final void Function(int idjugador, int idtutor)? onDelete;
  final void Function(Map<String, dynamic> tutor)? onContact;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        // Botón añadir
        if (onCreate != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Añadir tutor'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        // Lista o empty state
        Expanded(
          child: tutores.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tutores.length,
                  itemBuilder: (context, index) => _buildTutorCard(tutores[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Sin tutores',
              style: AppTypography.h6.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No hay tutores registrados para este jugador',
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorCard(Map<String, dynamic> tutor) {
    final nombre = tutor['nombre']?.toString() ?? '';
    final apellidos = tutor['apellidos']?.toString() ?? '';
    final nombreCompleto = '$nombre $apellidos'.trim();
    final telefono = tutor['telefono']?.toString() ?? '';
    final email = tutor['email']?.toString() ?? '';
    final parentesco = tutor['parentesco']?.toString() ?? '';
    final idtutor = tutor['idtutor'] as int?;
    final idjugador = tutor['idjugador'] as int?;

    // Icono según parentesco
    IconData parentescoIcon = Icons.person_outline;
    if (parentesco.toLowerCase().contains('padre') || parentesco.toLowerCase().contains('madre')) {
      parentescoIcon = Icons.family_restroom_outlined;
    } else if (parentesco.toLowerCase().contains('abuel')) {
      parentescoIcon = Icons.elderly_outlined;
    } else if (parentesco.toLowerCase().contains('tutor')) {
      parentescoIcon = Icons.supervisor_account_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(parentescoIcon, color: AppColors.primary, size: 24),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreCompleto.isNotEmpty ? nombreCompleto : 'Sin nombre',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (parentesco.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            parentesco,
                            style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
                          ),
                        ),
                    ],
                  ),
                ),
                if (idtutor != null && idjugador != null && (onEdit != null || onDelete != null))
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.gray400),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!(tutor);
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!(idjugador, idtutor);
                      } else if (value == 'contact' && onContact != null) {
                        onContact!(tutor);
                      }
                    },
                    itemBuilder: (context) => [
                      if (onContact != null)
                        const PopupMenuItem(
                          value: 'contact',
                          child: Row(
                            children: [
                              Icon(Icons.message_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Contactar'),
                            ],
                          ),
                        ),
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            // Contacto
            if (telefono.isNotEmpty || email.isNotEmpty) ...[
              AppSpacing.vSpaceMd,
              Row(
                children: [
                  if (telefono.isNotEmpty) ...[
                    Icon(Icons.phone_outlined, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 6),
                    Text(
                      telefono,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
                    ),
                    AppSpacing.hSpaceMd,
                  ],
                  if (email.isNotEmpty) ...[
                    Icon(Icons.email_outlined, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        email,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.gray600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
