import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Grid de tarjetas de jugadores
class PlayersGrid extends StatelessWidget {
  const PlayersGrid({
    super.key,
    required this.players,
    required this.positions,
    required this.onPlayerTap,
  });

  final List<Map<String, dynamic>> players;
  final Map<int, String> positions;
  final void Function(Map<String, dynamic> player) onPlayerTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return PlayerCard(
          player: player,
          position: _getPositionName(player['idposicion']),
          onTap: () => onPlayerTap(player),
        );
      },
    );
  }

  String _getPositionName(dynamic idposicion) {
    if (idposicion == null) return '';
    final id = idposicion is int ? idposicion : int.tryParse(idposicion.toString());
    if (id == null) return '';
    return positions[id] ?? '';
  }
}

/// Tarjeta individual de jugador con diseño profesional
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.position,
    required this.onTap,
  });

  final Map<String, dynamic> player;
  final String position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dorsal = player['dorsal']?.toString() ?? '-';
    final nombre = player['nombre']?.toString() ?? '';
    final apellidos = player['apellidos']?.toString() ?? '';
    final foto = player['foto']?.toString();
    final nombreCompleto = '$nombre $apellidos'.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección superior con dorsal y avatar
              Expanded(
                child: Stack(
                  children: [
                    // Fondo con gradiente
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.08),
                            AppColors.primary.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    ),

                    // Número de dorsal grande de fondo
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Text(
                        dorsal,
                        style: AppTypography.display.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),

                    // Avatar del jugador centrado
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 3,
                          ),
                          image: foto != null && foto.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(foto),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: foto == null || foto.isEmpty
                            ? Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: AppColors.primary.withValues(alpha: 0.4),
                              )
                            : null,
                      ),
                    ),

                    // Badge del dorsal
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            dorsal,
                            style: AppTypography.h6.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Información del jugador
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Column(
                  children: [
                    // Nombre del jugador
                    Text(
                      nombreCompleto,
                      style: AppTypography.h6.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (position.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // Badge de posición
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          position,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
