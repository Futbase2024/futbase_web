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

  // Horario de 08:00 a 23:00
  static const int _startHour = 8;
  static const int _endHour = 23;
  static const double _hourRowHeight = 60.0;
  static const double _timeColumnWidth = 56.0;
  static const double _minBlockWidth = 90.0; // Ancho mínimo para mostrar info completa
  static const double _emptyDayWidth = 40.0; // Ancho para días sin entrenamientos

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

  /// Calcula cuántas columnas virtuales se necesitan para un día
  int _calculateColumnsNeeded(List<Map<String, dynamic>> dayTrainings) {
    if (dayTrainings.isEmpty) return 0;

    // Ordenar por hora de inicio
    final sorted = List<Map<String, dynamic>>.from(dayTrainings);
    sorted.sort((a, b) {
      final aStart = _parseTimeToMinutes(a['hinicio']?.toString()) ?? 0;
      final bStart = _parseTimeToMinutes(b['hinicio']?.toString()) ?? 0;
      return aStart.compareTo(bStart);
    });

    // Algoritmo para encontrar el máximo de columnas paralelas
    final columnEndTimes = <int>[];

    for (final training in sorted) {
      final start = _parseTimeToMinutes(training['hinicio']?.toString()) ?? 0;
      final end = _parseTimeToMinutes(training['hfin']?.toString()) ?? 1440;

      // Buscar una columna libre
      int? freeColumn;
      for (var i = 0; i < columnEndTimes.length; i++) {
        if (columnEndTimes[i] <= start) {
          freeColumn = i;
          break;
        }
      }

      if (freeColumn != null) {
        columnEndTimes[freeColumn] = end;
      } else {
        columnEndTimes.add(end);
      }
    }

    return columnEndTimes.length;
  }

  /// Asigna columna a cada entrenamiento
  List<({Map<String, dynamic> training, int column})> _assignColumns(
    List<Map<String, dynamic>> dayTrainings,
  ) {
    if (dayTrainings.isEmpty) return [];

    // Ordenar por hora de inicio
    final sorted = List<Map<String, dynamic>>.from(dayTrainings);
    sorted.sort((a, b) {
      final aStart = _parseTimeToMinutes(a['hinicio']?.toString()) ?? 0;
      final bStart = _parseTimeToMinutes(b['hinicio']?.toString()) ?? 0;
      return aStart.compareTo(bStart);
    });

    final columnEndTimes = <int>[];
    final result = <({Map<String, dynamic> training, int column})>[];

    for (final training in sorted) {
      final start = _parseTimeToMinutes(training['hinicio']?.toString()) ?? 0;
      final end = _parseTimeToMinutes(training['hfin']?.toString()) ?? 1440;

      // Buscar una columna libre
      int? freeColumn;
      for (var i = 0; i < columnEndTimes.length; i++) {
        if (columnEndTimes[i] <= start) {
          freeColumn = i;
          break;
        }
      }

      if (freeColumn != null) {
        columnEndTimes[freeColumn] = end;
        result.add((training: training, column: freeColumn));
      } else {
        columnEndTimes.add(end);
        result.add((training: training, column: columnEndTimes.length - 1));
      }
    }

    return result;
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

          // Grid de calendario con scroll horizontal
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

  Widget _buildCalendarGrid(List<DateTime> weekDays, DateTime now) {
    // Calcular columnas necesarias por día
    final columnsPerDay = <int, int>{};
    for (var i = 0; i < 7; i++) {
      final day = weekDays[i];
      final dayTrainings = _getTrainingsForDate(day);
      columnsPerDay[i] = _calculateColumnsNeeded(dayTrainings);
    }

    // Verificar si hay algún entrenamiento en la semana
    final hasAnyTraining = columnsPerDay.values.any((v) => v > 0);

    // Calcular ancho total necesario
    double totalWidth = _timeColumnWidth;
    for (var i = 0; i < 7; i++) {
      final cols = columnsPerDay[i] ?? 0;
      if (cols == 0) {
        totalWidth += _emptyDayWidth;
      } else {
        totalWidth += cols * _minBlockWidth;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final needsScroll = totalWidth > availableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: needsScroll ? null : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: needsScroll ? totalWidth : availableWidth,
            child: Column(
              children: [
                // Headers de días
                _buildDayHeadersRow(weekDays, now, columnsPerDay, needsScroll, availableWidth, hasAnyTraining),

                // Grid con horas y entrenamientos
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: needsScroll ? totalWidth : availableWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Columna de horas
                          _buildTimeColumn(),

                          // Columnas de días
                          ...List.generate(7, (i) {
                            final day = weekDays[i];
                            final dayTrainings = _getTrainingsForDate(day);
                            final cols = columnsPerDay[i] ?? 0;

                            double dayWidth;
                            if (!hasAnyTraining) {
                              // Sin entrenamientos: distribuir equitativamente
                              dayWidth = (availableWidth - _timeColumnWidth) / 7;
                            } else if (cols == 0) {
                              dayWidth = _emptyDayWidth;
                            } else {
                              if (needsScroll) {
                                dayWidth = cols * _minBlockWidth;
                              } else {
                                // Distribuir espacio disponible
                                final totalTrainingsCols = columnsPerDay.values.fold(0, (a, b) => a + b);
                                final emptyDays = columnsPerDay.values.where((v) => v == 0).length;
                                final remainingSpace = availableWidth - _timeColumnWidth - (emptyDays * _emptyDayWidth);
                                dayWidth = (remainingSpace / totalTrainingsCols) * cols;
                              }
                            }

                            return _buildDayColumn(
                              i,
                              day,
                              dayTrainings,
                              now,
                              cols,
                              dayWidth,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayHeadersRow(
    List<DateTime> weekDays,
    DateTime now,
    Map<int, int> columnsPerDay,
    bool needsScroll,
    double availableWidth,
    bool hasAnyTraining,
  ) {
    const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: [
          // Espacio para columna de horas
          SizedBox(width: _timeColumnWidth),

          // Headers de días
          ...List.generate(7, (i) {
            final day = weekDays[i];
            final isToday = day.year == now.year &&
                day.month == now.month &&
                day.day == now.day;
            final isWeekend = i >= 5;
            final cols = columnsPerDay[i] ?? 0;
            final hasNoTrainings = cols == 0;

            double dayWidth;
            if (!hasAnyTraining) {
              // Sin entrenamientos: distribuir equitativamente
              dayWidth = (availableWidth - _timeColumnWidth) / 7;
            } else if (cols == 0) {
              dayWidth = _emptyDayWidth;
            } else {
              if (needsScroll) {
                dayWidth = cols * _minBlockWidth;
              } else {
                final totalTrainingsCols = columnsPerDay.values.fold(0, (a, b) => a + b);
                final emptyDays = columnsPerDay.values.where((v) => v == 0).length;
                final remainingSpace = availableWidth - _timeColumnWidth - (emptyDays * _emptyDayWidth);
                dayWidth = (remainingSpace / totalTrainingsCols) * cols;
              }
            }

            return Container(
              width: dayWidth,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: hasNoTrainings
                    ? AppColors.gray100
                    : isToday
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : null,
                border: Border(
                  left: BorderSide(color: AppColors.gray200),
                  bottom: BorderSide(color: AppColors.gray200),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayNames[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: hasNoTrainings
                          ? AppColors.gray400
                          : isWeekend
                              ? AppColors.gray400
                              : AppColors.gray500,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isToday
                              ? Colors.white
                              : hasNoTrainings
                                  ? AppColors.gray400
                                  : isWeekend
                                      ? AppColors.gray400
                                      : AppColors.gray900,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

          return Container(
            height: _hourRowHeight,
            padding: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray100),
              ),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray400,
                  fontSize: 10,
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
    int totalColumns,
    double dayWidth,
  ) {
    final isWeekend = dayIndex >= 5;
    final isToday = day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
    final hasNoTrainings = dayTrainings.isEmpty;

    // Asignar columnas a entrenamientos
    final trainingsWithColumns = _assignColumns(dayTrainings);

    return Container(
      width: dayWidth,
      height: (_endHour - _startHour + 1) * _hourRowHeight,
      decoration: BoxDecoration(
        color: hasNoTrainings
            ? AppColors.gray100
            : isWeekend
                ? AppColors.gray50
                : null,
        border: Border(
          left: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Stack(
        children: [
          // Líneas de hora
          ...List.generate(_endHour - _startHour + 1, (i) {
            return Positioned(
              top: i * _hourRowHeight,
              left: 0,
              right: 0,
              child: Container(
                height: _hourRowHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: hasNoTrainings
                          ? AppColors.gray200
                          : AppColors.gray100,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Indicador de hora actual (si es hoy)
          if (isToday) _buildCurrentTimeIndicator(now),

          // Bloques de entrenamiento
          ...trainingsWithColumns.map((item) {
            return _buildTrainingBlock(
              item.training,
              columnIndex: item.column,
              totalColumns: totalColumns,
              columnWidth: dayWidth / totalColumns,
            );
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

  Widget _buildTrainingBlock(
    Map<String, dynamic> training, {
    required int columnIndex,
    required int totalColumns,
    required double columnWidth,
  }) {
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
    final height = _calculateHeight(startMinutes, endMinutes).clamp(40.0, 200.0);
    final color = _getTeamColor(idequipo);
    final teamName = _getTeamShortName(idequipo);
    final campo = training['campo']?.toString() ?? '';

    // Posición horizontal: cada entrenamiento en su columna asignada
    const gap = 2.0;
    final left = columnIndex * columnWidth + gap / 2;
    final width = columnWidth - gap;

    return Positioned(
      top: top,
      left: left,
      width: width.clamp(50.0, 200.0),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hora
              Text(
                '$hinicio - $hfin',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Nombre del equipo
              Expanded(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Campo (si hay espacio)
              if (height > 60 && campo.isNotEmpty)
                Text(
                  campo,
                  style: TextStyle(
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
