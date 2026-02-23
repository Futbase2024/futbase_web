import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/scouting_bloc.dart';
import '../../bloc/scouting_event.dart';
import '../../bloc/scouting_state.dart';
import 'scouting_comparison_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Barra inferior para comparar jugadores
class ScoutingComparisonBar extends StatelessWidget {
  const ScoutingComparisonBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoutingBloc, ScoutingState>(
      builder: (context, state) {
        if (state is! ScoutingLoaded) return const SizedBox.shrink();

        final comparisonPlayers = state.comparisonPlayers;
        if (comparisonPlayers.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Título
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comparador',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${comparisonPlayers.length}/3 jugadores',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Jugadores seleccionados
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: comparisonPlayers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final player = comparisonPlayers[index];
                        return _buildPlayerChip(context, player);
                      },
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Botones de acción
                  if (comparisonPlayers.length >= 2)
                    ElevatedButton.icon(
                      onPressed: () => _showComparisonDialog(context, comparisonPlayers),
                      icon: const Icon(Icons.compare, size: 18),
                      label: const Text('Comparar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.gray400,
                    onPressed: () {
                      context.read<ScoutingBloc>().add(const ScoutingClearComparison());
                    },
                    tooltip: 'Limpiar comparador',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerChip(BuildContext context, Map<String, dynamic> player) {
    final nombre = player['nombre'] as String? ?? '';
    final apodo = player['apodo'] as String?;
    final foto = player['foto'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              image: foto != null && foto.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(foto),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: foto == null || foto.isEmpty
                ? Center(
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          // Nombre
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              apodo ?? nombre,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Quitar
          InkWell(
            onTap: () {
              context.read<ScoutingBloc>().add(
                    ScoutingRemoveFromComparison(jugadorId: player['id'] as int),
                  );
            },
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  void _showComparisonDialog(BuildContext context, List<Map<String, dynamic>> players) {
    showDialog(
      context: context,
      builder: (dialogContext) => ScoutingComparisonDialog(players: players),
    );
  }
}
