import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/trainings_bloc.dart';
import '../../bloc/trainings_event.dart';
import '../../bloc/trainings_state.dart';
import 'trainings_table.dart';
import 'trainings_calendar.dart';
import 'trainings_filter_bar.dart';
import 'trainings_empty_state.dart';
import 'trainings_kpis.dart';
import 'training_form_dialog.dart';
import 'attendance_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Widget principal de entrenamientos (SIN Scaffold para integrar en Dashboard)
class TrainingsContent extends StatefulWidget {
  const TrainingsContent({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<TrainingsContent> createState() => _TrainingsContentState();
}

class _TrainingsContentState extends State<TrainingsContent> {
  late final TrainingsBloc _trainingsBloc;
  String _viewMode = 'lista'; // 'lista' o 'calendario'
  String _searchQuery = '';
  DateTime _selectedMonth = DateTime.now();

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
    final idequipo = widget.user.idequipo;
    if (idequipo > 0) {
      _trainingsBloc.add(TrainingsLoadRequested(idequipo: idequipo));
    }
  }

  void _onCreateTraining() {
    showDialog(
      context: context,
      builder: (context) => TrainingFormDialog(
        idequipo: widget.user.idequipo,
        trainingTypes: _getCurrentTrainingTypes(),
        onSaved: () {
          _trainingsBloc.add(TrainingsRefreshRequested(idequipo: widget.user.idequipo));
        },
      ),
    );
  }

  void _onEditTraining(Map<String, dynamic> training) {
    showDialog(
      context: context,
      builder: (context) => TrainingFormDialog(
        idequipo: widget.user.idequipo,
        training: training,
        trainingTypes: _getCurrentTrainingTypes(),
        onSaved: () {
          _trainingsBloc.add(TrainingsRefreshRequested(idequipo: widget.user.idequipo));
        },
      ),
    );
  }

  void _onDeleteTraining(Map<String, dynamic> training) {
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
                idequipo: widget.user.idequipo,
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
    showDialog(
      context: context,
      builder: (context) => AttendanceDialog(
        identrenamiento: training['id'] as int,
        idequipo: widget.user.idequipo,
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
            TrainingsLoaded(
              :final trainings,
              :final filteredTrainings,
            ) =>
              _buildLoadedContent(
                trainings: trainings,
                filteredTrainings: filteredTrainings,
              ),
            TrainingsError(:final message) => _buildErrorWidget(message),
            _ => _buildLoadingState(),
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

  Widget _buildLoadedContent({
    required List<Map<String, dynamic>> trainings,
    required List<Map<String, dynamic>> filteredTrainings,
  }) {
    // Filtrar localmente por búsqueda
    final searchFiltered = _searchQuery.isEmpty
        ? filteredTrainings
        : filteredTrainings.where((t) {
            final nombre = t['nombre']?.toString().toLowerCase() ?? '';
            final obs = t['observaciones']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return nombre.contains(query) || obs.contains(query);
          }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(trainings.length),
          ),

          // KPIs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
              child: TrainingsKpis(
                todayTrainings: _calculateTodayTrainings(trainings),
                averageAttendance: _calculateAverageAttendance(trainings),
                completedThisWeek: _calculateCompletedThisWeek(trainings),
                upcomingThisWeek: _calculateUpcomingThisWeek(trainings),
              ),
            ),
          ),

          // Barra de filtros
          SliverToBoxAdapter(
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
          if (_searchQuery.isNotEmpty && _viewMode == 'lista')
            SliverToBoxAdapter(
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
          _viewMode == 'calendario'
              ? _buildCalendarView(trainings)
              : _buildListView(searchFiltered),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// Vista de calendario
  Widget _buildCalendarView(List<Map<String, dynamic>> trainings) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TrainingsCalendar(
          trainings: trainings,
          selectedDate: _selectedMonth,
          onTrainingTap: (training) {
            _onAttendance(training);
          },
          onDateSelected: (date) {
            setState(() => _selectedMonth = date);
          },
        ),
      ),
    );
  }

  /// Vista de lista/tabla
  Widget _buildListView(List<Map<String, dynamic>> trainings) {
    if (trainings.isEmpty) {
      return SliverFillRemaining(
        child: TrainingsEmptyState(
          hasFilters: _searchQuery.isNotEmpty,
          onClearFilters: () {
            setState(() => _searchQuery = '');
          },
          onCreateTraining: _onCreateTraining,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TrainingsTable(
          trainings: trainings,
          onEdit: _onEditTraining,
          onDelete: _onDeleteTraining,
          onAttendance: _onAttendance,
        ),
      ),
    );
  }

  Widget _buildHeader(int totalTrainings) {
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
          Text(
            'Gestión de Entrenamientos',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),

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
                  label: 'Vista Calendario',
                  icon: Icons.calendar_today_outlined,
                  isSelected: _viewMode == 'calendario',
                  onTap: () => setState(() => _viewMode = 'calendario'),
                ),
                _ViewToggleButton(
                  label: 'Vista Lista',
                  icon: Icons.list_alt,
                  isSelected: _viewMode == 'lista',
                  onTap: () => setState(() => _viewMode = 'lista'),
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
          AppSpacing.hSpaceMd,

          // Botón Nueva Sesión
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

  /// Calcula entrenamientos de hoy
  int _calculateTodayTrainings(List<Map<String, dynamic>> trainings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;

      // Intentar parsear directamente si es DateTime
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

  double _calculateAverageAttendance(List<Map<String, dynamic>> trainings) {
    // TODO: Calcular basado en datos de asistencia real
    // Por ahora retorna 0
    return 0.0;
  }
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.gray500,
            ),
            AppSpacing.hSpaceXs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
