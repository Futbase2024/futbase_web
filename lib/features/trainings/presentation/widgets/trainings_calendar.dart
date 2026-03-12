import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Vista de calendario para entrenamientos
class TrainingsCalendar extends StatelessWidget {
  const TrainingsCalendar({
    super.key,
    required this.trainings,
    required this.onTrainingTap,
    required this.onDateSelected,
    this.selectedDate,
    this.attendanceByTeam,
  });

  final List<Map<String, dynamic>> trainings;
  final void Function(Map<String, dynamic>) onTrainingTap;
  final void Function(DateTime) onDateSelected;
  final DateTime? selectedDate;
  final Map<int, double>? attendanceByTeam;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = selectedDate ?? now;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Calcular el día de la semana del primer día (1 = lunes, 7 = domingo)
    final startWeekday = firstDayOfMonth.weekday;

    // Días del mes anterior para rellenar
    final daysFromPrevMonth = startWeekday - 1;

    // Generar lista de días a mostrar
    final days = <_CalendarDay>[];

    // Días del mes anterior
    final prevMonth = DateTime(currentMonth.year, currentMonth.month, 0);
    for (var i = daysFromPrevMonth; i > 0; i--) {
      final day = prevMonth.day - i + 1;
      days.add(_CalendarDay(
        date: DateTime(prevMonth.year, prevMonth.month, day),
        isCurrentMonth: false,
        trainings: [],
      ));
    }

    // Días del mes actual
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final dayTrainings = _getTrainingsForDate(date);
      days.add(_CalendarDay(
        date: date,
        isCurrentMonth: true,
        trainings: dayTrainings,
      ));
    }

    // Días del siguiente mes para completar la última semana
    final remainingDays = 42 - days.length; // 6 semanas * 7 días
    for (var day = 1; day <= remainingDays; day++) {
      final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, day);
      days.add(_CalendarDay(
        date: nextMonth,
        isCurrentMonth: false,
        trainings: [],
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadowLight,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del calendario
          _buildCalendarHeader(currentMonth),

          // Nombres de días de la semana
          _buildWeekdayHeaders(),

          // Grid de días - se expande para llenar el espacio disponible
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: List.generate(6, (rowIndex) {
                  final startIdx = rowIndex * 7;
                  final weekDays = days.sublist(startIdx, startIdx + 7);
                  return Expanded(
                    child: Row(
                      children: weekDays.asMap().entries.map((entry) {
                        final colIndex = entry.key;
                        final day = entry.value;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: colIndex < 6 ? 4 : 0,
                              bottom: rowIndex < 5 ? 4 : 0,
                            ),
                            child: _buildDayCell(day, now, context),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(DateTime currentMonth) {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onDateSelected(DateTime(currentMonth.year, currentMonth.month - 1)),
            icon: const Icon(Icons.chevron_left),
            color: AppColors.gray600,
          ),
          Text(
            '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
            ),
          ),
          IconButton(
            onPressed: () => onDateSelected(DateTime(currentMonth.year, currentMonth.month + 1)),
            icon: const Icon(Icons.chevron_right),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayCell(_CalendarDay day, DateTime now, BuildContext context) {
    final isToday = day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day;

    final hasTrainings = day.trainings.isNotEmpty;
    final trainingCount = day.trainings.length;

    return GestureDetector(
      onTap: () {
        if (hasTrainings && day.trainings.length == 1) {
          onTrainingTap(day.trainings.first);
        } else if (hasTrainings) {
          _showTrainingsForDay(context, day);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.1)
              : hasTrainings
                  ? AppColors.success.withValues(alpha: 0.08)
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.date.day}',
              style: AppTypography.bodyLarge.copyWith(
                color: day.isCurrentMonth
                    ? AppColors.gray900
                    : AppColors.gray300,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (hasTrainings) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$trainingCount',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTrainingsForDay(BuildContext context, _CalendarDay day) {
    final dayName = _getDayName(day.date.weekday);
    final formattedDate = '$dayName, ${day.date.day} de ${_getMonthName(day.date.month)} ${day.date.year}';

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del diálogo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.gray200),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entrenamientos del día',
                            style: AppTypography.h5.copyWith(
                              color: AppColors.gray900,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${day.trainings.length}',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ),

              // Grid de entrenamientos
              Flexible(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: day.trainings.length,
                  itemBuilder: (context, index) {
                    final training = day.trainings[index];
                    final idequipo = training['idequipo'] as int?;
                    final asistencia = attendanceByTeam != null && idequipo != null
                        ? attendanceByTeam![idequipo]
                        : null;
                    return _TrainingCard(
                      training: training,
                      asistenciaEquipo: asistencia,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onTrainingTap(training);
                      },
                    );
                  },
                ),
              ),

              // Botón cerrar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  border: Border(
                    top: BorderSide(color: AppColors.gray200),
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cerrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gray200,
                      foregroundColor: AppColors.gray700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

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
}

class _CalendarDay {
  const _CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.trainings,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final List<Map<String, dynamic>> trainings;
}

/// Tarjeta de entrenamiento elegante y minimalista
class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.training,
    required this.onTap,
    this.asistenciaEquipo,
  });

  final Map<String, dynamic> training;
  final VoidCallback onTap;
  final double? asistenciaEquipo;

  @override
  Widget build(BuildContext context) {
    final equipo = training['nombre_equipo']?.toString() ?? 'Sin equipo';
    final hinicio = training['hinicio']?.toString() ?? '--:--';
    final hfin = training['hfin']?.toString() ?? '--:--';
    final asistenciaPorcentaje = asistenciaEquipo != null ? (asistenciaEquipo! * 100).round() : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColors.gray50.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hora destacada
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$hinicio - $hfin',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Equipo
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        equipo,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.gray800,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Asistencia
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asistencia',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (asistenciaPorcentaje ?? 0) / 100,
                              backgroundColor: AppColors.gray200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getAssistenciaColor(asistenciaPorcentaje),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getAssistenciaColor(asistenciaPorcentaje).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${asistenciaPorcentaje ?? '--'}%',
                        style: AppTypography.labelLarge.copyWith(
                          color: _getAssistenciaColor(asistenciaPorcentaje),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAssistenciaColor(int? porcentaje) {
    if (porcentaje == null) return AppColors.gray400;
    if (porcentaje >= 70) return AppColors.green; // Verde primary oscuro #00554E
    if (porcentaje >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
