import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_config_cubit.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import 'player_profile_header.dart';
import 'player_profile_tabs.dart';
import 'sections/player_cuotas_section.dart';
import 'sections/player_estadisticas_section.dart';
import 'sections/player_partidos_section.dart';
import 'sections/player_entrenamientos_section.dart';
import 'sections/player_asistencias_section.dart';
import 'sections/player_tallapeso_section.dart';
import 'sections/player_lesiones_section.dart';
import 'sections/player_ficha_section.dart';
import 'sections/player_deuda_section.dart';
import 'sections/player_tutores_section.dart';
import 'sections/player_carnets_section.dart';
import 'sections/coming_soon_section.dart';

/// Contenido del perfil de jugador para integrar dentro del dashboard
class PlayerProfileContent extends StatefulWidget {
  const PlayerProfileContent({
    super.key,
    required this.playerId,
    required this.playerData,
    required this.onBack,
  });

  final int playerId;
  final Map<String, dynamic> playerData;
  final VoidCallback onBack;

  @override
  State<PlayerProfileContent> createState() => _PlayerProfileContentState();
}

class _PlayerProfileContentState extends State<PlayerProfileContent> {
  late final PlayerProfileBloc _bloc;

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

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Column(
        children: [
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
    );
  }

  Widget _buildError(String message) {
    return Center(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
              AppSpacing.hSpaceSm,
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
        ],
      ),
    );
  }

  Widget _buildContent(PlayerProfileState state) {
    return Column(
      children: [
        // Header con datos del jugador
        PlayerProfileHeader(
          player: state.player!,
          position: state.position,
          onBack: widget.onBack,
          onNoteChanged: (nota) {
            final playerId = state.playerId;
            if (playerId != null) {
              _bloc.add(PlayerProfileNotaUpdateRequested(
                idjugador: playerId,
                nota: nota,
              ));
            }
          },
        ),

        // Navegación de tabs
        PlayerProfileTabs(
          activeTabIndex: state.activeTabIndex,
          isAdmin: true, // TODO: Obtener del contexto de autenticación
          onTabChanged: (index) {
            _bloc.add(PlayerProfileTabChanged(tabIndex: index));
          },
        ),

        // Contenido del tab activo
        Expanded(
          child: _buildTabContent(state),
        ),
      ],
    );
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
