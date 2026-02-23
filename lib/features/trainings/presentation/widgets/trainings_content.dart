import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/trainings_bloc.dart';
import '../../bloc/trainings_event.dart';
import '../../bloc/trainings_state.dart';
import 'trainings_table.dart';
import 'trainings_calendar.dart';
import 'trainings_weekly_calendar.dart';
import 'trainings_stats_panel.dart';
import 'attendance_trend_chart.dart';
import 'trainings_filter_bar.dart';
import 'trainings_empty_state.dart';
import 'trainings_kpis.dart';
import 'training_form_dialog.dart';
import 'attendance_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/constants/user_roles.dart';

/// Widget principal de entrenamientos (SIN Scaffold para integrar en Dashboard)
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
  String _searchQuery = '';
  DateTime _selectedMonth = DateTime.now();

  /// Determina si es vista de club/coordinador
  bool get _isClubView {
    final role = widget.userRole;
    return role == UserRole.club || role == UserRole.coordinador;
  }

  @override
  void initState() {
    super.initState();
    _trainingsBloc = TrainingsBloc();
    _loadTrainings();
  }

  @override
  void dispose() {
    _trainingsBloc.close();
    super.dispose();
  }

  void _loadTrainings() {
    if (_isClubView) {
      // Para Club/Coordinador: cargar todos los equipos del club
      final idclub = widget.user.idclub;
      if (idclub > 0) {
        _trainingsBloc.add(TrainingsLoadByClubRequested(idclub: idclub));
      } else {
        // Si no tiene club asignado, emitir estado vacío
        debugPrint('⚠️ [TrainingsContent] Usuario sin club asignado (idclub=$idclub)');
        _trainingsBloc.add(const TrainingsLoadByClubRequested(idclub: -1));
      }
    } else {
      // Para Entrenador: cargar solo su equipo
      final idequipo = widget.user.idequipo;
      if (idequipo > 0) {
        _trainingsBloc.add(TrainingsLoadRequested(idequipo: idequipo));
      } else {
        // Si no tiene equipo asignado, emitir estado vacío
        debugPrint('⚠️ [TrainingsContent] Usuario sin equipo asignado (idequipo=$idequipo)');
        _trainingsBloc.add(const TrainingsLoadRequested(idequipo: -1));
      }
    }
  }

  void _onCreateTraining() {
    showDialog(
      context: context,
      builder: (context) => TrainingFormDialog(
        idequipo: widget.user.idequipo,
        trainingTypes: _getCurrentTrainingTypes(),
        onSaved: () {
          if (_isClubView) {
            _trainingsBloc.add(TrainingsLoadByClubRequested(idclub: widget.user.idclub));
          } else {
            _trainingsBloc.add(TrainingsRefreshRequested(idequipo: widget.user.idequipo));
          }
        },
      ),
    );
  }

  void _onEditTraining(Map<String, dynamic> training) {
    final idequipo = training['idequipo'] as int? ?? widget.user.idequipo;
    showDialog(
      context: context,
      builder: (context) => TrainingFormDialog(
        idequipo: idequipo,
        training: training,
        trainingTypes: _getCurrentTrainingTypes(),
        onSaved: () {
          if (_isClubView) {
            _trainingsBloc.add(TrainingsLoadByClubRequested(idclub: widget.user.idclub));
          } else {
            _trainingsBloc.add(TrainingsRefreshRequested(idequipo: idequipo));
          }
        },
      ),
    );
  }

  void _onDeleteTraining(Map<String, dynamic> training) {
    final idequipo = training['idequipo'] as int? ?? widget.user.idequipo;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar entrenamiento'),
        content: const Text('¿Estás seguro de que deseas eliminar este entrenamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _trainingsBloc.add(TrainingDeleteRequested(
                id: training['id'] as int,
                idequipo: idequipo,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
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
    return BlocProvider.value(
      value: _trainingsBloc,
      child: BlocBuilder<TrainingsBloc, TrainingsState>(
        builder: (context, state) {
          return switch (state) {
            TrainingsInitial() => _buildLoadingState(),
            TrainingsLoading() => _buildLoadingState(),
            TrainingsLoaded() => _buildLoadedContent(state),
            TrainingsError(:final message) => _buildErrorWidget(message),
            AttendanceState() || _ => _buildLoadingState(),
          };
        },
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
    final trainings = state.trainings;
    final filteredTrainings = state.filteredTrainings;

    // Filtrar localmente por búsqueda
    final searchFiltered = _searchQuery.isEmpty
        ? filteredTrainings
        : filteredTrainings.where((t) {
            final nombre = t['nombre']?.toString().toLowerCase() ?? '';
            final obs = t['observaciones']?.toString().toLowerCase() ?? '';
            final equipo = t['nombre_equipo']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return nombre.contains(query) || obs.contains(query) || equipo.contains(query);
          }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToobiAdapter(
            child: _buildHeader(state),
          ),

          // Contenido específico según rol
          if (_isClubView) ...[
            // Panel de estadísticas para Club/Coordinador
            SliverToobiAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                child: TrainingsStatsPanel(
                  teams: state.teams,
                  attendanceByTeam: state.attendanceByTeam,
                  overallAttendance: state.overallAttendance,
                  trainingsByTimeSlot: state.trainingsByTimeSlot,
                  trainingsByField: state.trainingsByField,
                  trainingsByTeam: state.trainingsByTeam,
                ),
              ),
            ),

            // Gráfico de tendencia
            SliverToobiAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                child: AttendanceTrendChart(
                  weeklyData: _generateTrendData(state),
                  height: 180,
                ),
              ),
            ),
          ] else ...[
            // KPIs para Entrenador
            SliverToobiAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                child: TrainingsKpis(
                  todayTrainings: _calculateTodayTrainings(trainings),
                  averageAttendance: state.overallAttendance,
                  completedThisWeek: _calculateCompletedThisWeek(trainings),
                  upcomingThisWeek: _calculateUpcomingThisWeek(trainings),
                ),
              ),
            ),
          ],

          // Barra de filtros
          SliverToobiAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: TrainingsFilterBar(
                searchQuery: _searchQuery,
                onSearchChanged: (query) {
                  setState(() => _searchQuery = query);
                },
              ),
            ),
          ),

          // Indicador de búsqueda activa (solo en vista lista)
          if (_searchQuery.isNotEmpty && state.viewMode == 'list')
            SliverToobiAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${searchFiltered.length} de ${trainings.length} entrenamientos',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Limpiar búsqueda'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Contenido según vista
          _buildViewContent(state, searchFiltered),

          // Espacio final
          const SliverToobiAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido según la vista seleccionada
  Widget _buildViewContent(TrainingsLoaded state, List<Map<String, dynamic>> trainings) {
    switch (state.viewMode) {
      case 'week':
        return _buildWeeklyView(state);
      case 'month':
        return _buildMonthView(state.trainings);
      case 'list':
      default:
        return _buildListView(trainings, state);
    }
  }

  /// Vista de calendario semanal
  Widget _buildWeeklyView(TrainingsLoaded state) {
    return SliverToobiAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
          height: 500,
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
              _trainingsBloc.add(CalendarViewChanged(viewMode: 'week'));
            },
          ),
        ),
      ),
    );
  }

  /// Vista de calendario mensual
  Widget _buildMonthView(List<Map<String, dynamic>> trainings) {
    return SliverToobiAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TrainingsCalendar(
          trainings: trainings,
          selectedDate: _selectedMonth,
          onTrainingTap: _onAttendance,
          onDateSelected: (date) {
            setState(() => _selectedMonth = date);
          },
        ),
      ),
    );
  }

  /// Vista de lista/tabla
  Widget _buildListView(List<Map<String, dynamic>> trainings, TrainingsLoaded state) {
    if (trainings.isEmpty) {
      return SliverFillRemaining(
        child: TrainingsEmptyState(
          hasFilters: _searchQuery.isNotEmpty,
          onClearFilters: () {
            setState(() => _searchQuery = '');
          },
          onCreateTraining: _isClubView ? null : _onCreateTraining,
        ),
      );
    }

    return SliverToobiAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TrainingsTable(
          trainings: trainings,
          onEdit: _isClubView ? null : _onEditTraining,
          onDelete: _isClubView ? null : _onDeleteTraining,
          onAttendance: _onAttendance,
          showTeamColumn: _isClubView,
        ),
      ),
    );
  }

  Widget _buildHeader(TrainingsLoaded state) {
    final totalTrainings = state.trainings.length;
    final viewMode = state.viewMode;

    String title = _isClubView
        ? 'Entrenamientos del Club'
        : 'Gestión de Entrenamientos';

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
                  title,
                  style: AppTypography.h5.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                if (_isClubView && state.teams.isNotEmpty)
                  Text(
                    '${state.teams.length} equipos',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),

          // Toggle de vistas
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewToggleButton(
                  label: 'Semana',
                  icon: Icons.view_week_outlined,
                  isSelected: viewMode == 'week',
                  onTap: () => _trainingsBloc.add(const CalendarViewChanged(viewMode: 'week')),
                ),
                _ViewToggleButton(
                  label: 'Mes',
                  icon: Icons.calendar_today_outlined,
                  isSelected: viewMode == 'month',
                  onTap: () => _trainingsBloc.add(const CalendarViewChanged(viewMode: 'month')),
                ),
                _ViewToggleButton(
                  label: 'Lista',
                  icon: Icons.list_alt,
                  isSelected: viewMode == 'list',
                  onTap: () => _trainingsBloc.add(const CalendarViewChanged(viewMode: 'list')),
                ),
              ],
            ),
          ),
          AppSpacing.hSpaceMd,

          // Contador de sesiones
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

          // Botón Nueva Sesión (solo para entrenadores)
          if (!_isClubView) ...[
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

  /// Genera datos de tendencia simulados (en producción vendrían de la BD)
  List<AttendanceWeekData> _generateTrendData(TrainingsLoaded state) {
    // TODO: Obtener datos reales de tendencia desde Supabase
    // Por ahora generamos datos de ejemplo basados en la asistencia actual
    final now = DateTime.now();
    final data = <AttendanceWeekData>[];

    for (var i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekNumber = _getWeekNumber(weekStart);

      // Simular variación basada en la asistencia actual
      final baseAttendance = state.overallAttendance;
      final variation = (i - 4) * 2.5; // Tendencia hacia arriba
      final simulatedAttendance = (baseAttendance + variation).clamp(50.0, 100.0);

      data.add(AttendanceWeekData(
        weekNumber: weekNumber,
        startDate: weekStart,
        percentage: double.parse(simulatedAttendance.toStringAsFixed(1)),
        totalTrainings: (state.teams.length * (8 - i) / 2).round().clamp(1, 20),
        totalPresent: 0,
      ));
    }

    return data;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Calcula entrenamientos de hoy
  int _calculateTodayTrainings(List<Map<String, dynamic>> trainings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;

      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else {
        fecha = DateTime.tryParse(fechaRaw?.toString() ?? '');
      }

      if (fecha == null) return false;
      final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
      return fechaSolo == today;
    }).length;
  }

  /// Calcula completados esta semana
  int _calculateCompletedThisWeek(List<Map<String, dynamic>> trainings) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekClean = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekClean.add(const Duration(days: 7));

    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;

      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else {
        fecha = DateTime.tryParse(fechaRaw?.toString() ?? '');
      }

      if (fecha == null) return false;
      final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
      return fechaSolo.isAfter(startOfWeekClean.subtract(const Duration(days: 1))) &&
          fechaSolo.isBefore(endOfWeek) &&
          fechaSolo.isBefore(DateTime(now.year, now.month, now.day).add(const Duration(days: 1)));
    }).length;
  }

  /// Calcula próximos esta semana
  int _calculateUpcomingThisWeek(List<Map<String, dynamic>> trainings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - now.weekday + 1));

    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;

      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else {
        fecha = DateTime.tryParse(fechaRaw?.toString() ?? '');
      }

      if (fecha == null) return false;
      final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
      return !fechaSolo.isBefore(today) && fechaSolo.isBefore(endOfWeek);
    }).length;
  }
}

/// Adaptador para sliver
class SliverToobiAdapter extends SliverToBoxAdapter {
  const SliverToobiAdapter({super.key, required super.child});
}

/// Botón de toggle para cambiar entre vistas
class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gray900.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primary : AppColors.gray500,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
