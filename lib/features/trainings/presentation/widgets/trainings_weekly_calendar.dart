import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Calendario semanal profesional estilo agenda para entrenamientos
class TrainingsWeeklyCalendar extends StatelessWidget {
  const TrainingsWeeklyCalendar({
    super.key,
    required this.trainings,
    required this.teams,
    required this.focusedWeek,
    required this.onTrainingTap,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onToday,
  });

  final List<Map<String, dynamic>> trainings;
  final List<Map<String, dynamic>> teams;
  final DateTime focusedWeek;
  final void Function(Map<String, dynamic>) onTrainingTap;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;

  // Horario de 08:00 a 21:00
  static const int _startHour = 8;
  static const int _endHour = 21;
  static const double _hourRowHeight = 60.0;
  static const double _timeColumnWidth = 60.0;

  // Colores para equipos por índice
  static final List<Color> _teamColors = [
    AppColors.primary,
    const Color(0xFF2196F3), // Azul
    const Color(0xFFFF9800), // Naranja
    const Color(0xFF9C27B0), // Púrpura
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFE91E63), // Rosa
    const Color(0xFF4CAF50), // Verde
    const Color(0xFFFF5722), // Naranja profundo
    const Color(0xFF607D8B), // Gris azulado
    const Color(0xFF795548), // Marrón
  ];

  Color _getTeamColor(int? idequipo) {
    if (idequipo == null) return AppColors.gray400;
    final index = teams.indexWhere((t) => t['id'] == idequipo);
    return _teamColors[index % _teamColors.length];
  }

  /// Obtiene el nombre corto del equipo
  String _getTeamShortName(int? idequipo) {
    if (idequipo == null) return '';
    final team = teams.firstWhere(
      (t) => t['id'] == idequipo,
      orElse: () => <String, dynamic>{},
    );
    return team['ncorto']?.toString() ?? team['equipo']?.toString() ?? '';
  }

  /// Obtiene los días de la semana
  List<DateTime> _getWeekDays() {
    final monday = focusedWeek.subtract(Duration(days: focusedWeek.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Obtiene entrenamientos de un día específico
  List<Map<String, dynamic>> _getTrainingsForDate(DateTime date) {
    return trainings.where((t) {
      final fechaRaw = t['fecha'];
      DateTime? fecha;
      if (fechaRaw is DateTime) {
        fecha = fechaRaw;
      } else {
        fecha = DateTime.tryParse(fechaRaw?.toString() ?? '');
      }
      if (fecha == null) return false;
      return fecha.year == date.year &&
          fecha.month == date.month &&
          fecha.day == date.day;
    }).toList();
  }

  /// Parsea hora de string "HH:mm" a minutos desde medianoche
  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    return hours * 60 + minutes;
  }

  /// Calcula la posición vertical (top) de un entrenamiento
  double _calculateTop(int startMinutes) {
    final startOffset = _startHour * 60;
    final relativeMinutes = startMinutes - startOffset;
    return (relativeMinutes / 60) * _hourRowHeight;
  }

  /// Calcula la altura de un entrenamiento
  double _calculateHeight(int startMinutes, int endMinutes) {
    final duration = endMinutes - startMinutes;
    return (duration / 60) * _hourRowHeight;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final now = DateTime.now();
    final isCurrentWeek = weekDays.any((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con navegación
          _buildHeader(weekDays, isCurrentWeek),

          // Nombres de días
          _buildDayHeaders(weekDays, now),

          // Grid de calendario
          Expanded(
            child: _buildCalendarGrid(weekDays, now),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<DateTime> weekDays, bool isCurrentWeek) {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    final startMonth = monthNames[weekDays.first.month - 1];
    final endMonth = monthNames[weekDays.last.month - 1];
    final year = weekDays.first.year;

    String dateRange;
    if (weekDays.first.month == weekDays.last.month) {
      dateRange = '$startMonth $year';
    } else {
      dateRange = '$startMonth - $endMonth $year';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          // Navegación anterior
          IconButton(
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.gray600,
            tooltip: 'Semana anterior',
          ),

          // Título con rango de fechas
          Expanded(
            child: Column(
              children: [
                Text(
                  dateRange,
                  style: AppTypography.h6.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${weekDays.first.day} - ${weekDays.last.day}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // Navegación siguiente
          IconButton(
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.gray600,
            tooltip: 'Semana siguiente',
          ),

          AppSpacing.hSpaceSm,

          // Botón Hoy
          if (!isCurrentWeek)
            TextButton.icon(
              onPressed: onToday,
              icon: const Icon(Icons.today, size: 16),
              label: const Text('Hoy'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders(List<DateTime> weekDays, DateTime now) {
    const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Container(
      padding: const EdgeInsets.only(left: _timeColumnWidth),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: weekDays.asMap().entries.map((entry) {
          final i = entry.key;
          final day = entry.value;
          final isToday = day.year == now.year &&
              day.month == now.month &&
              day.day == now.day;
          final isWeekend = i >= 5;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                border: i > 0
                    ? Border(left: BorderSide(color: AppColors.gray100))
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    dayNames[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: isWeekend ? AppColors.gray400 : AppColors.gray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: AppTypography.labelMedium.copyWith(
                          color: isToday
                              ? Colors.white
                              : isWeekend
                                  ? AppColors.gray400
                                  : AppColors.gray900,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(List<DateTime> weekDays, DateTime now) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna de horas
          _buildTimeColumn(),

          // Columnas de días con entrenamientos
          ...weekDays.asMap().entries.map((entry) {
            final i = entry.key;
            final day = entry.value;
            final dayTrainings = _getTrainingsForDate(day);

            return Expanded(
              child: _buildDayColumn(i, day, dayTrainings, now),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: _timeColumnWidth,
      child: Column(
        children: List.generate(_endHour - _startHour + 1, (i) {
          final hour = _startHour + i;
          final isHourEven = hour % 2 == 0;

          return Container(
            height: _hourRowHeight,
            padding: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.gray100,
                  style: isHourEven ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(
    int dayIndex,
    DateTime day,
    List<Map<String, dynamic>> dayTrainings,
    DateTime now,
  ) {
    final isWeekend = dayIndex >= 5;
    final isToday = day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;

    return Container(
      height: (_endHour - _startHour + 1) * _hourRowHeight,
      decoration: BoxDecoration(
        color: isWeekend ? AppColors.gray50 : null,
        border: Border(
          left: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Stack(
        children: [
          // Líneas de hora
          ...List.generate(_endHour - _startHour + 1, (i) {
            final hour = _startHour + i;
            final isHourEven = hour % 2 == 0;

            return Positioned(
              top: i * _hourRowHeight,
              left: 0,
              right: 0,
              child: Container(
                height: _hourRowHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isHourEven ? AppColors.gray100 : AppColors.gray50,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Indicador de hora actual (si es hoy)
          if (isToday) _buildCurrentTimeIndicator(now),

          // Bloques de entrenamiento
          ...dayTrainings.map((training) {
            return _buildTrainingBlock(training);
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeIndicator(DateTime now) {
    final minutesFromStart = now.hour * 60 + now.minute - _startHour * 60;
    final top = (minutesFromStart / 60) * _hourRowHeight;

    if (top < 0 || top > (_endHour - _startHour) * _hourRowHeight) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingBlock(Map<String, dynamic> training) {
    final hinicio = training['hinicio']?.toString() ?? '';
    final hfin = training['hfin']?.toString() ?? '';
    final idequipo = training['idequipo'] as int?;

    final startMinutes = _parseTimeToMinutes(hinicio);
    final endMinutes = _parseTimeToMinutes(hfin);

    if (startMinutes == null || endMinutes == null) {
      return const SizedBox.shrink();
    }

    // Verificar que esté en el rango visible
    if (startMinutes < _startHour * 60 || startMinutes >= _endHour * 60) {
      return const SizedBox.shrink();
    }

    final top = _calculateTop(startMinutes);
    final height = _calculateHeight(startMinutes, endMinutes).clamp(30.0, 200.0);
    final color = _getTeamColor(idequipo);
    final teamName = _getTeamShortName(idequipo);
    final campo = training['campo']?.toString() ?? '';

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      child: GestureDetector(
        onTap: () => onTrainingTap(training),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hora
              Text(
                '$hinicio - $hfin',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              // Nombre del equipo
              Expanded(
                child: Text(
                  teamName,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Campo (si hay espacio)
              if (height > 50 && campo.isNotEmpty)
                Text(
                  campo,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
