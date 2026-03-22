import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/config/app_config_cubit.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'bloc/player_profile_bloc.dart';
import 'bloc/player_profile_event.dart';
import 'bloc/player_profile_state.dart';
import 'widgets/player_profile_header.dart';
import 'widgets/player_profile_tabs.dart';
import 'widgets/sections/player_cuotas_section.dart';
import 'widgets/sections/player_estadisticas_section.dart';
import 'widgets/sections/player_partidos_section.dart';
import 'widgets/sections/player_entrenamientos_section.dart';
import 'widgets/sections/player_asistencias_section.dart';
import 'widgets/sections/player_tallapeso_section.dart';
import 'widgets/sections/player_lesiones_section.dart';
import 'widgets/sections/player_ficha_section.dart';
import 'widgets/sections/player_deuda_section.dart';
import 'widgets/sections/player_tutores_section.dart';
import 'widgets/sections/player_carnets_section.dart';
import 'widgets/sections/coming_soon_section.dart';

/// Diálogo de perfil de jugador que ocupa el 90% de la pantalla
/// Sigue el estilo del proyecto antiguo (FutbaseWeb/futbaseweb2025)
class PlayerProfileDialog extends StatefulWidget {
  const PlayerProfileDialog({
    super.key,
    required this.playerId,
    required this.playerData,
  });

  final int playerId;
  final Map<String, dynamic> playerData;

  /// Muestra el diálogo de perfil de jugador
  /// Retorna el jugador actualizado si hubo cambios (ej: nota modificada)
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required int playerId,
    required Map<String, dynamic> playerData,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlayerProfileDialog(
        playerId: playerId,
        playerData: playerData,
      ),
    );
  }

  @override
  State<PlayerProfileDialog> createState() => _PlayerProfileDialogState();
}

class _PlayerProfileDialogState extends State<PlayerProfileDialog> {
  late final PlayerProfileBloc _bloc;
  Map<String, dynamic>? _updatedPlayer;

  @override
  void initState() {
    super.initState();
    _bloc = PlayerProfileBloc();
    _loadProfile();
  }

  void _loadProfile() {
    final appConfig = context.read<AppConfigCubit>();
    final state = appConfig.state;

    _bloc.add(PlayerProfileLoadRequested(
      playerId: widget.playerId,
      playerData: widget.playerData,
      activeSeasonId: state.activeSeasonId,
    ));
  }

  void _close() {
    Navigator.of(context).pop(_updatedPlayer);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width * 0.95;
    final dialogHeight = size.height * 0.95;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all((size.width - dialogWidth) / 2),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BlocProvider.value(
            value: _bloc,
            child: Column(
              children: [
                // AppBar personalizado
                _buildAppBar(),
                // Contenido
                Expanded(
                  child: BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const CELoading.inline();
                      }

                      if (state.errorMessage != null) {
                        return _buildError(state.errorMessage!);
                      }

                      if (state.player == null) {
                        return const CELoading.inline();
                      }

                      return _buildContent(state);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final nombre = widget.playerData['nombre']?.toString() ?? '';
    final apellidos = widget.playerData['apellidos']?.toString() ?? '';
    final playerName = '$nombre $apellidos'.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón cerrar
          IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Cerrar',
          ),
          AppSpacing.hSpaceSm,
          // Título
          Expanded(
            child: Text(
              'Ficha del Jugador $playerName',
              style: AppTypography.h5.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Badge de cuota
          _buildCuotaBadge(),
        ],
      ),
    );
  }

  Widget _buildCuotaBadge() {
    final idtipocuota = widget.playerData['idtipocuota'];

    if (idtipocuota == null || idtipocuota == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Sin cuota',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Si tiene cuota, mostrar información
    final cantidad = widget.playerData['cantidad_cuota'];
    final tipo = widget.playerData['tipo_cuota'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.euro, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          if (cantidad != null)
            Text(
              cantidad.toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 4),
          if (tipo.isNotEmpty)
            Text(
              tipo,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Error al cargar el perfil',
              style: AppTypography.h6.copyWith(color: AppColors.gray900),
            ),
            AppSpacing.vSpaceSm,
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceMd,
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PlayerProfileState state) {
    final screenSize = MediaQuery.of(context).size;
    final headerHeight = screenSize.height * 0.20; // 20% de la pantalla

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.02),
            AppColors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header con datos del jugador - altura fija 20% pantalla
            SizedBox(
              height: headerHeight,
              child: PlayerProfileHeader(
                player: state.player!,
                position: state.position,
                onNoteChanged: (nota) {
                  final playerId = state.playerId;
                  if (playerId != null) {
                    _bloc.add(PlayerProfileNotaUpdateRequested(
                      idjugador: playerId,
                      nota: nota,
                    ));
                    // Guardar el jugador actualizado
                    _updatedPlayer = Map<String, dynamic>.from(state.player!);
                    _updatedPlayer!['nota'] = nota;
                  }
                },
              ),
            ),
            AppSpacing.vSpaceMd,
            // Navegación de tabs
            PlayerProfileTabs(
              activeTabIndex: state.activeTabIndex,
              isAdmin: _isAdmin(),
              onTabChanged: (index) {
                _bloc.add(PlayerProfileTabChanged(tabIndex: index));
              },
            ),
            AppSpacing.vSpaceMd,
            // Contenido del tab activo
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(state.activeTabIndex),
                      padding: const EdgeInsets.all(20),
                      child: _buildTabContent(state),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verifica si el usuario es administrador
  bool _isAdmin() {
    // TODO: Obtener del auth bloc o del contexto
    return true; // Por defecto mostrar tabs de admin
  }

  Widget _buildTabContent(PlayerProfileState state) {
    return switch (state.activeTabIndex) {
      // Cuotas
      0 => PlayerCuotasSection(cuotas: state.cuotas),
      // Deuda Temporada
      1 => PlayerDeudaSection(
          controlDeuda: state.controlDeuda,
          isLoading: state.isLoadingDeuda,
          onAddRecibo: () {
            // TODO: Mostrar diálogo para añadir recibo
          },
        ),
      // Tutores
      2 => PlayerTutoresSection(
          tutores: state.tutores,
          isLoading: state.isLoadingTutores,
          onCreate: () {
            // TODO: Mostrar diálogo para crear tutor
          },
          onEdit: (tutor) {
            // TODO: Mostrar diálogo para editar tutor
          },
          onDelete: (idjugador, idtutor) {
            _bloc.add(PlayerProfileDeleteTutor(
              idjugador: idjugador,
              idtutor: idtutor,
            ));
          },
        ),
      // Carnets
      3 => PlayerCarnetsSection(
          carnets: state.carnets,
          isLoading: state.isLoadingCarnets,
          onCreate: () {
            final seasonId = state.seasonId;
            final playerId = state.playerId;
            if (playerId != null && seasonId != null) {
              _bloc.add(PlayerProfileCreateCarnet(
                idjugador: playerId,
                idtemporada: seasonId,
              ));
            }
          },
          onView: (carnet) {
            // TODO: Mostrar carnet en detalle
          },
          onDownload: (carnet) {
            // TODO: Descargar carnet
          },
        ),
      // Ficha Federativa
      4 => PlayerFichaSection(
          fichaFederativa: state.fichaFederativa,
          isLoading: state.isLoadingFicha,
          onUpdate: () {
            // TODO: Mostrar diálogo para actualizar ficha
          },
        ),
      // Estadísticas
      5 => PlayerEstadisticasSection(
          estadisticas: state.estadisticas,
          isLoading: state.isLoadingEstadisticas,
        ),
      // Entrenamientos
      6 => PlayerEntrenamientosSection(
          entrenamientos: state.entrenamientos,
          asistenciaStats: state.asistenciaStats,
          isLoading: state.isLoadingEntrenamientos,
        ),
      // Partidos
      7 => PlayerPartidosSection(
          partidos: state.partidos,
          isLoading: state.isLoadingPartidos,
        ),
      // Talla y Peso
      8 => PlayerTallaPesoSection(
          tallaPeso: state.tallaPeso,
          isLoading: state.isLoadingTallaPeso,
          onCreate: () {
            // TODO: Mostrar diálogo para añadir medición
          },
          onEdit: (item) {
            // TODO: Mostrar diálogo para editar medición
          },
          onDelete: (id) {
            _bloc.add(PlayerProfileDeleteTallaPeso(id: id));
          },
        ),
      // Lesiones
      9 => PlayerLesionesSection(
          lesiones: state.lesiones,
          isLoading: state.isLoadingLesiones,
          onCreate: () {
            // TODO: Mostrar diálogo para añadir lesión
          },
          onEdit: (item) {
            // TODO: Mostrar diálogo para editar lesión
          },
          onDelete: (id) {
            _bloc.add(PlayerProfileDeleteLesion(id: id));
          },
        ),
      // Asistencias
      10 => PlayerAsistenciasSection(
          entrenamientos: state.entrenamientos,
          asistenciaStats: state.asistenciaStats,
          isLoading: state.isLoadingEntrenamientos,
        ),
      // Vista Completa
      11 => const ComingSoonSection(
          title: 'Vista Completa',
          icon: Icons.fullscreen_outlined,
        ),
      _ => const ComingSoonSection(
          title: 'Sección no disponible',
          icon: Icons.help_outline,
        ),
    };
  }
}
