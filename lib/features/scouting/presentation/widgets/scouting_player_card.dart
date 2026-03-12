import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/scouting_bloc.dart';
import '../../bloc/scouting_event.dart';
import '../../bloc/scouting_state.dart';
import 'scouting_player_detail_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Card profesional de jugador para Scouting
class ScoutingPlayerCard extends StatelessWidget {
  const ScoutingPlayerCard({
    super.key,
    required this.player,
    this.isComparing = false,
    this.showClub = false,
  });

  final Map<String, dynamic> player;
  final bool isComparing;
  final bool showClub;

  @override
  Widget build(BuildContext context) {
    final nombre = player['nombre'] as String? ?? '';
    final apellidos = player['apellidos'] as String? ?? '';
    final apodo = player['apodo'] as String?;
    final foto = player['foto'] as String?;
    final dorsal = player['dorsal'] as int?;
    final posicion = player['posicion'] as String?;
    final categoria = player['categoria'] as String?;
    final pj = player['pj'] as int? ?? 0;
    final goles = player['goles'] as int? ?? 0;
    final minutos = player['minutos'] as int? ?? 0;
    final valoracion = player['valoracion'] as int?;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.gray200, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => _showPlayerDetailDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Dorsal + Compare button
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          image: foto != null && foto.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(foto),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: foto == null || foto.isEmpty
                            ? Center(
                                child: Text(
                                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                                  style: AppTypography.h5.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      // Badge dorsal
                      if (dorsal != null && dorsal > 0)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$dorsal',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Botón comparar
                  IconButton(
                    icon: Icon(
                      isComparing ? Icons.check_circle : Icons.compare_arrows_outlined,
                      color: isComparing ? AppColors.success : AppColors.gray400,
                      size: 22,
                    ),
                    tooltip: isComparing ? 'Quitar del comparador' : 'Añadir al comparador',
                    onPressed: () => _toggleComparison(context),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Nombre
              Text(
                apodo ?? '$nombre $apellidos',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Posición y categoría
              Row(
                children: [
                  if (posicion != null)
                    Expanded(
                      child: Text(
                        posicion,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (categoria != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        categoria,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Club (solo para superAdmin)
              if (showClub) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 12,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        player['club'] as String? ?? '',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Stats row
              Row(
                children: [
                  _buildMiniStat('PJ', pj.toString()),
                  _buildMiniStat('G', goles.toString()),
                  _buildMiniStat('Min', minutos.toString()),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Valoración bar
              _buildRatingBar(valoracion),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int? valoracion) {
    final value = valoracion ?? 0;
    final percentage = value / 100;
    // Convertir a escala de 5 (80 -> 4.0)
    final ratingOutOf5 = (value / 20).toStringAsFixed(1);

    Color color;
    if (value >= 80) {
      color = AppColors.success;
    } else if (value >= 60) {
      color = AppColors.primary;
    } else if (value >= 40) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.gray100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          ratingOutOf5,
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showPlayerDetailDialog(BuildContext context) {
    final bloc = context.read<ScoutingBloc>();

    // Cargar historial del jugador
    bloc.add(ScoutingLoadPlayerHistory(jugadorId: player['id'] as int));

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<ScoutingBloc, ScoutingState>(
          builder: (context, blocState) {
            List<Map<String, dynamic>>? history;
            if (blocState is ScoutingLoaded) {
              // Solo mostrar historial si corresponde al jugador actual
              if (blocState.selectedPlayer?['id'] == player['id']) {
                history = blocState.playerHistory;
              }
            }
            return ScoutingPlayerDetailDialog(
              player: player,
              playerHistory: history,
            );
          },
        ),
      ),
    );
  }

  void _toggleComparison(BuildContext context) {
    final bloc = context.read<ScoutingBloc>();
    if (isComparing) {
      bloc.add(ScoutingRemoveFromComparison(jugadorId: player['id'] as int));
    } else {
      bloc.add(ScoutingAddToComparison(player: player));
    }
  }
}
