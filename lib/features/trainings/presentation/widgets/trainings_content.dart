import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/trainings_bloc.dart';
import '../../../../core/constants/user_roles.dart';
import '../../bloc/trainings_event.dart';
import '../../bloc/trainings_state.dart';
import 'trainings_weekly_calendar.dart';
import 'training_form_dialog.dart';
import 'attendance_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/config/app_config_cubit.dart';

/// Widget principal de entrenamientos - Plan semanal simplificado
class TrainingsContent extends StatefulWidget {
  const TrainingsContent({
    super.key,
    required this.user,
    this.userRole,
  });

  final UsuariosEntity user;
  final UserRole? userRole;

  @override
  State<TrainingsContent> createState() => _TrainingsContentState();
}

class _TrainingsContentState extends State<TrainingsContent> {
  late final TrainingsBloc _trainingsBloc;
  late final Stopwatch _initStopwatch;

  @override
  void initState() {
    super.initState();
    _initStopwatch = Stopwatch()..start();
    debugPrint('🏋️⏱️ [CONTENT] INIT STATE - Creando TrainingsBloc');
    _trainingsBloc = TrainingsBloc();
    debugPrint('🏋️⏱️ [CONTENT] TrainingsBloc creado, iniciando _loadTrainings()');
    _loadTrainings();
  }

  @override
  void dispose() {
    _trainingsBloc.close();
    super.dispose();
  }

  void _loadTrainings() {
    debugPrint('🏋️⏱️ [CONTENT] _loadTrainings() INICIO - +${_initStopwatch.elapsedMilliseconds}ms desde initState');

    // Obtener la temporada activa del AppConfigCubit global
    final appConfigCubit = context.read<AppConfigCubit>();
    final activeSeasonId = appConfigCubit.activeSeasonId;
    debugPrint('🏋️⏱️ [CONTENT] AppConfigCubit leído - +${_initStopwatch.elapsedMilliseconds}ms');

    // Cargar entrenamientos del club del usuario
    final idclub = widget.user.idclub;
    debugPrint('🏋️⏱️ [CONTENT] Disparando TrainingsLoadByClubRequested - +${_initStopwatch.elapsedMilliseconds}ms');
    if (idclub > 0) {
      _trainingsBloc.add(TrainingsLoadByClubRequested(
        idclub: idclub,
        activeSeasonId: activeSeasonId,
      ));
    } else {
      // Si no tiene club asignado, emitir estado vacío
      debugPrint('⚠️ [TrainingsContent] Usuario sin club asignado (idclub=$idclub)');
      _trainingsBloc.add(TrainingsLoadByClubRequested(
        idclub: -1,
        activeSeasonId: activeSeasonId,
      ));
    }
    debugPrint('🏋️⏱️ [CONTENT] _loadTrainings() FIN - +${_initStopwatch.elapsedMilliseconds}ms');
  }

  void _onCreateTraining() {
    final appConfigCubit = context.read<AppConfigCubit>();
    final activeSeasonId = appConfigCubit.activeSeasonId;

    showDialog(
      context: context,
      builder: (context) => TrainingFormDialog(
        idequipo: widget.user.idequipo,
        trainingTypes: _getCurrentTrainingTypes(),
        onSaved: () {
          _trainingsBloc.add(TrainingsLoadByClubRequested(
            idclub: widget.user.idclub,
            activeSeasonId: activeSeasonId,
          ));
        },
      ),
    );
  }

  void _onAttendance(Map<String, dynamic> training) {
    final idequipo = training['idequipo'] as int? ?? widget.user.idequipo;
    showDialog(
      context: context,
      builder: (context) => AttendanceDialog(
        identrenamiento: training['id'] as int,
        idequipo: idequipo,
        trainingDate: training['fecha']?.toString() ?? '',
      ),
    );
  }

  Map<int, String> _getCurrentTrainingTypes() {
    final state = _trainingsBloc.state;
    if (state is TrainingsLoaded) {
      return state.trainingTypes;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏋️⏱️ [CONTENT] BUILD - +${_initStopwatch.elapsedMilliseconds}ms desde initState');
    return BlocProvider.value(
      value: _trainingsBloc,
      child: BlocListener<AppConfigCubit, AppConfigState>(
        listenWhen: (previous, current) =>
            previous.activeSeasonId != current.activeSeasonId,
        listener: (context, configState) {
          debugPrint('🗓️ [TrainingsContent] Temporada cambió, recargando entrenamientos');
          _loadTrainings();
        },
        child: BlocBuilder<TrainingsBloc, TrainingsState>(
          builder: (context, state) {
            if (state is TrainingsLoaded) {
              debugPrint('🏋️⏱️ [CONTENT] ⭐ RENDERIZANDO TrainingsLoaded - +${_initStopwatch.elapsedMilliseconds}ms TOTAL');
            }
            return switch (state) {
              TrainingsInitial() => _buildLoadingState(),
              TrainingsLoading() => _buildLoadingState(),
              TrainingsLoaded() => _buildLoadedContent(state),
              TrainingsError(:final message) => _buildErrorWidget(message),
              AttendanceState() || _ => _buildLoadingState(),
            };
          },
        ),
      ),
    );
  }

  /// Widget de loading centrado con constraints adecuados
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Center(
          child: const CELoading.inline(),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(TrainingsLoaded state) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(state),

          // Calendario semanal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: TrainingsWeeklyCalendar(
                trainings: state.getWeekTrainings(),
                teams: state.teams,
                focusedWeek: state.focusedWeek,
                onTrainingTap: _onAttendance,
                onPreviousWeek: () {
                  _trainingsBloc.add(WeekNavigationRequested(
                    focusedWeek: state.focusedWeek,
                    goToNext: false,
                  ));
                },
                onNextWeek: () {
                  _trainingsBloc.add(WeekNavigationRequested(
                    focusedWeek: state.focusedWeek,
                    goToNext: true,
                  ));
                },
                onToday: () {
                  _trainingsBloc.add(const CalendarViewChanged(viewMode: 'week'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TrainingsLoaded state) {
    final totalTrainings = state.trainings.length;
    final weekTrainings = state.getWeekTrainings();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Semanal de Entrenamientos',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                if (state.teams.isNotEmpty)
                  Text(
                    '${state.teams.length} equipos • ${weekTrainings.length} sesiones esta semana',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),

          // Contador de sesiones total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                AppSpacing.hSpaceXs,
                Text(
                  '$totalTrainings sesiones',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Botón Nueva Sesión
          AppSpacing.hSpaceMd,
          ElevatedButton.icon(
            onPressed: _onCreateTraining,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nueva Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return SafeArea(
      child: Center(
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
              'Error al cargar entrenamientos',
              style: AppTypography.h6.copyWith(
                color: AppColors.gray900,
              ),
            ),
            AppSpacing.vSpaceSm,
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceMd,
            ElevatedButton.icon(
              onPressed: _loadTrainings,
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
}
