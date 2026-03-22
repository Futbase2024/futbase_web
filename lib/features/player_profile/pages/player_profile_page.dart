import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_config_cubit.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import '../widgets/player_profile_header.dart';
import '../widgets/player_profile_tabs.dart';
import '../widgets/sections/player_cuotas_section.dart';
import '../widgets/sections/coming_soon_section.dart';

/// Página de perfil de jugador con información detallada
class PlayerProfilePage extends StatefulWidget {
  const PlayerProfilePage({
    super.key,
    required this.playerId,
  });

  final int playerId;

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  late final PlayerProfileBloc _bloc;
  Map<String, dynamic>? _playerData;

  @override
  void initState() {
    super.initState();
    _bloc = PlayerProfileBloc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar datos al entrar a la página
    _loadProfile();
  }

  void _loadProfile() {
    final appConfig = context.read<AppConfigCubit>();
    final state = appConfig.state;

    // Obtener datos del jugador si vienen en extra
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      _playerData = extra;
    }

    _bloc.add(PlayerProfileLoadRequested(
      playerId: widget.playerId,
      playerData: _playerData,
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        appBar: _buildAppBar(),
        body: BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
        builder: (context, state) {
          return Text(
            state.playerName.isNotEmpty ? state.playerName : 'Perfil de Jugador',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.gray600),
          onPressed: () {
            // TODO: Editar jugador
          },
          tooltip: 'Editar',
        ),
        AppSpacing.hSpaceSm,
      ],
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
    );
  }

  Widget _buildContent(PlayerProfileState state) {
    return Column(
      children: [
        // Header con datos del jugador
        PlayerProfileHeader(
          player: state.player!,
          position: state.position,
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
      1 => const ComingSoonSection(
          title: 'Deuda Temporada',
          icon: Icons.account_balance_wallet_outlined,
        ),
      // Tutores
      2 => const ComingSoonSection(
          title: 'Tutores',
          icon: Icons.family_restroom_outlined,
        ),
      // Carnets
      3 => const ComingSoonSection(
          title: 'Carnets',
          icon: Icons.badge_outlined,
        ),
      // Ficha Federativa
      4 => const ComingSoonSection(
          title: 'Ficha Federativa',
          icon: Icons.description_outlined,
        ),
      // Estadísticas
      5 => const ComingSoonSection(
          title: 'Estadísticas',
          icon: Icons.bar_chart_outlined,
        ),
      // Entrenamientos
      6 => const ComingSoonSection(
          title: 'Entrenamientos',
          icon: Icons.fitness_center_outlined,
        ),
      // Partidos
      7 => const ComingSoonSection(
          title: 'Partidos',
          icon: Icons.sports_soccer_outlined,
        ),
      // Talla y Peso
      8 => const ComingSoonSection(
          title: 'Talla y Peso',
          icon: Icons.monitor_weight_outlined,
        ),
      // Lesiones
      9 => const ComingSoonSection(
          title: 'Lesiones',
          icon: Icons.healing_outlined,
        ),
      // Asistencias
      10 => const ComingSoonSection(
          title: 'Asistencias',
          icon: Icons.event_available_outlined,
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
