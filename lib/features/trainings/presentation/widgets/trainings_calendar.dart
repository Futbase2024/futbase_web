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
  });

  final List<Map<String, dynamic>> trainings;
  final void Function(Map<String, dynamic>) onTrainingTap;
  final void Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

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
        children: [
          // Header del calendario
          _buildCalendarHeader(currentMonth),

          // Nombres de días de la semana
          _buildWeekdayHeaders(),

          // Grid de días
          _buildDaysGrid(days, now),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildDaysGrid(List<_CalendarDay> days, DateTime now) {
    return Builder(builder: (gridContext) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          return _buildDayCell(day, now, gridContext);
        },
      );
    });
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Entrenamientos del ${day.date.day}/${day.date.month}/${day.date.year}',
          style: AppTypography.h6,
        ),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: day.trainings.length,
            itemBuilder: (context, index) {
              final training = day.trainings[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center, color: AppColors.primary),
                title: Text(training['nombre']?.toString() ?? 'Sin título'),
                subtitle: Text(
                  '${training['hinicio']?.toString() ?? ''} - ${training['hfin']?.toString() ?? ''}',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onTrainingTap(training);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
