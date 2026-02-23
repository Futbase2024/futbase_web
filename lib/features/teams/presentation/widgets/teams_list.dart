import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Lista de equipos en formato grid
class TeamsList extends StatelessWidget {
  const TeamsList({
    super.key,
    required this.teams,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> teams;
  final Future<void> Function(Map<String, dynamic> team) onEdit;
  final Future<void> Function(Map<String, dynamic> team) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return TeamCard(
            team: team,
            onEdit: () => onEdit(team),
            onDelete: () => onDelete(team),
          );
        },
      ),
    );
  }
}

/// Tarjeta individual de equipo
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final escudo = team['escudo'] as String?;
    final equipo = team['equipo'] as String? ?? 'Sin nombre';
    final ncorto = team['ncorto'] as String?;
    final categoria = team['categoria'] as String?;
    final temporada = team['temporada'] as String?;
    final jugadores = team['jugadores'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con escudo y nombre
                Row(
                  children: [
                    // Escudo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: escudo != null && escudo.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                escudo,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.shield_outlined,
                                  size: 28,
                                  color: AppColors.gray400,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.shield_outlined,
                              size: 28,
                              color: AppColors.gray400,
                            ),
                    ),
                    AppSpacing.hSpaceMd,

                    // Nombre y categoría
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipo,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (ncorto != null && ncorto.isNotEmpty) ...[
                            AppSpacing.vSpaceXs,
                            Text(
                              ncorto,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Menú de acciones
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.gray400,
                        size: 20,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Eliminar',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Tags de categoría y temporada
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (categoria != null)
                      _buildBadge(
                        icon: Icons.category_outlined,
                        label: categoria,
                        color: AppColors.primary,
                      ),
                    if (temporada != null)
                      _buildBadge(
                        icon: Icons.calendar_today_outlined,
                        label: temporada,
                        color: AppColors.success,
                      ),
                  ],
                ),

                AppSpacing.vSpaceSm,

                // Footer con número de jugadores
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                    AppSpacing.hSpaceXs,
                    Text(
                      '$jugadores jugadores',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.overline.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
