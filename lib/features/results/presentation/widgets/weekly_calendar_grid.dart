import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../bloc/results_bloc.dart';
import '../../bloc/results_event.dart';
import '../../bloc/results_state.dart';

/// Selector de días de la semana (Lunes-Domingo)
/// Al hacer clic en un día, muestra los partidos debajo
class WeeklyCalendarGrid extends StatelessWidget {
  const WeeklyCalendarGrid({
    super.key,
    required this.groupedMatches,
    required this.weekStart,
  });

  final List<ResultsGroupedByDate> groupedMatches;
  final DateTime weekStart;

  /// Nombres de los días de la semana
  static const _dayNames = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    // Crear mapa de partidos por fecha
    final matchesByDate = <DateTime, ResultsGroupedByDate>{};
    for (final group in groupedMatches) {
      final dateKey = DateTime(group.date.year, group.date.month, group.date.day);
      matchesByDate[dateKey] = group;
    }

    // Generar los 7 días de la semana
    final weekDays = List.generate(7, (index) {
      return weekStart.add(Duration(days: index));
    });

    return BlocBuilder<ResultsBloc, ResultsState>(
      buildWhen: (prev, curr) => curr is ResultsLoaded,
      builder: (context, state) {
        final selectedDate = state is ResultsLoaded ? state.effectiveSelectedDate : null;

        return Row(
          children: weekDays.map((day) {
            final dateKey = DateTime(day.year, day.month, day.day);
            final dayData = matchesByDate[dateKey];
            final isToday = _isToday(day);
            final isSelected = selectedDate != null &&
                dateKey.isAtSameMomentAs(selectedDate);
            final dayName = _dayNames[day.weekday - 1];

            return Expanded(
              child: _DaySelector(
                dayName: dayName,
                dayNumber: day.day,
                isToday: isToday,
                isSelected: isSelected,
                matchCount: dayData?.matches.length ?? 0,
                liveCount: dayData?.liveCount ?? 0,
                onTap: () {
                  context.read<ResultsBloc>().add(ResultsSelectDate(date: dateKey));
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Selector de día individual (clickeable)
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.dayName,
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
    required this.matchCount,
    required this.liveCount,
    required this.onTap,
  });

  final String dayName;
  final int dayNumber;
  final bool isToday;
  final bool isSelected;
  final int matchCount;
  final int liveCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isToday
                    ? AppColors.primary
                    : AppColors.gray100,
            width: isToday ? 2 : 1,
          ),
          boxShadow: isSelected || isToday
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nombre del día
            Text(
              dayName,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : isToday
                        ? AppColors.primary
                        : AppColors.gray500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Número del día
            Text(
              dayNumber.toString(),
              style: AppTypography.h3.copyWith(
                color: isSelected
                    ? AppColors.white
                    : isToday
                        ? AppColors.primary
                        : AppColors.gray900,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            // Indicadores
            if (matchCount > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge de cantidad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.2)
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$matchCount',
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.gray600,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  // Indicador de live
                  if (liveCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.white : AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lista de partidos del día seleccionado
class SelectedDayMatchesList extends StatelessWidget {
  const SelectedDayMatchesList({
    super.key,
    required this.matches,
  });

  final List<MatchWithStatus> matches;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return _EmptyDayMessage();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _MatchListItem(match: matches[index]);
      },
    );
  }
}

/// Mensaje cuando no hay partidos
class _EmptyDayMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: AppColors.gray300,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay partidos este día',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de partido en la lista
class _MatchListItem extends StatelessWidget {
  const _MatchListItem({required this.match});

  final MatchWithStatus match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;
    final isFinished = match.status == MatchStatus.finished;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.accent.withValues(alpha: 0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? AppColors.accent.withValues(alpha: 0.3)
              : AppColors.gray100,
        ),
      ),
      child: Row(
        children: [
          // Hora y estado
          SizedBox(
            width: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  match.hora ?? '--:--',
                  style: AppTypography.labelMedium.copyWith(
                    color: isLive ? AppColors.accent : AppColors.gray700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (isFinished)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FIN',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Equipos y resultado
          Expanded(
            child: _buildScoreRow(isFinished),
          ),

          const SizedBox(width: 12),

          // Categoría
          if (match.categoria != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                match.categoria!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(bool isFinished) {
    final goles = match.goles;
    final golesrival = match.golesrival;
    final hasScore = goles != null && golesrival != null;

    // Determinar colores según resultado
    Color? homeColor;
    Color? awayColor;
    if (isFinished && hasScore) {
      if (match.isLocal) {
        homeColor = goles > golesrival ? AppColors.success :
                    goles < golesrival ? AppColors.error : AppColors.gray500;
        awayColor = goles < golesrival ? AppColors.success :
                    goles > golesrival ? AppColors.error : AppColors.gray500;
      } else {
        awayColor = golesrival > goles ? AppColors.success :
                    golesrival < goles ? AppColors.error : AppColors.gray500;
        homeColor = golesrival < goles ? AppColors.success :
                    golesrival > goles ? AppColors.error : AppColors.gray500;
      }
    }

    return Row(
      children: [
        // Escudo y nombre equipo local
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TeamShield(
                escudoUrl: match.isLocal ? match.match['escudo'] : match.match['escudorival'],
                size: 28,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  match.isLocal ? match.equipoNombre : match.rivalNombre,
                  style: AppTypography.bodySmall.copyWith(
                    color: homeColor ?? AppColors.gray900,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Marcador
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: hasScore ? AppColors.gray100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            hasScore ? '$goles - $golesrival' : 'vs',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Escudo y nombre equipo visitante
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  match.isLocal ? match.rivalNombre : match.equipoNombre,
                  style: AppTypography.bodySmall.copyWith(
                    color: awayColor ?? AppColors.gray900,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              _TeamShield(
                escudoUrl: match.isLocal ? match.match['escudorival'] : match.match['escudo'],
                size: 28,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Escudo del equipo
class _TeamShield extends StatelessWidget {
  const _TeamShield({
    required this.escudoUrl,
    required this.size,
  });

  final String? escudoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (escudoUrl == null || escudoUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.sports_soccer,
          size: size * 0.6,
          color: AppColors.gray400,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        escudoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer,
              size: size * 0.6,
              color: AppColors.gray400,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.gray400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
