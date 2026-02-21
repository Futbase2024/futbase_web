import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/results_bloc.dart';
import '../../bloc/results_event.dart';
import '../../bloc/results_state.dart';

/// Barra unificada con navegación semanal y filtros con botones estilo web
class WeeklyNavigation extends StatelessWidget {
  const WeeklyNavigation({
    super.key,
    required this.weekLabel,
    required this.weekNumber,
    required this.isCurrentWeek,
    required this.isLiveMode,
    required this.liveCount,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onToggleLive,
  });

  final String weekLabel;
  final int weekNumber;
  final bool isCurrentWeek;
  final bool isLiveMode;
  final int liveCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onToggleLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          // Navegación de semana
          _NavigationControls(
            weekLabel: weekLabel,
            weekNumber: weekNumber,
            isCurrentWeek: isCurrentWeek,
            onPrevious: onPrevious,
            onNext: onNext,
            onToday: onToday,
          ),

          AppSpacing.hSpaceLg,

          // Botones de filtro scope (Todos / Mi club)
          _ScopeFilterButtons(),

          AppSpacing.hSpaceMd,

          // Botones de filtro por estado
          _StatusFilterButtons(),

          const Spacer(),

          // Botón Live Mode
          _LiveModeButton(
            isLiveMode: isLiveMode,
            liveCount: liveCount,
            onPressed: onToggleLive,
          ),
        ],
      ),
    );
  }
}

/// Botones de filtro de alcance (Todos / Mi club)
class _ScopeFilterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultsBloc, ResultsState>(
      buildWhen: (prev, curr) => curr is ResultsLoaded,
      builder: (context, state) {
        final currentScope = state is ResultsLoaded ? state.filterScope : ResultsScope.all;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterButton(
              label: 'Todos',
              isSelected: currentScope == ResultsScope.all,
              onPressed: () {
                context.read<ResultsBloc>().add(
                  const ResultsFilterByScope(scope: ResultsScope.all),
                );
              },
            ),
            const SizedBox(width: 6),
            _FilterButton(
              label: 'Mi club',
              isSelected: currentScope == ResultsScope.myClub,
              onPressed: () {
                context.read<ResultsBloc>().add(
                  const ResultsFilterByScope(scope: ResultsScope.myClub),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Botones de filtro por estado del partido
class _StatusFilterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultsBloc, ResultsState>(
      buildWhen: (prev, curr) => curr is ResultsLoaded,
      builder: (context, state) {
        final currentStatus = state is ResultsLoaded ? state.filterByStatus : null;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterButton(
              label: 'Live',
              isSelected: currentStatus == MatchStatusFilter.live,
              color: AppColors.accent,
              onPressed: () {
                _toggleStatusFilter(context, currentStatus, MatchStatusFilter.live);
              },
            ),
            const SizedBox(width: 6),
            _FilterButton(
              label: 'Sin comenzar',
              isSelected: currentStatus == MatchStatusFilter.scheduled,
              color: AppColors.info,
              onPressed: () {
                _toggleStatusFilter(context, currentStatus, MatchStatusFilter.scheduled);
              },
            ),
            const SizedBox(width: 6),
            _FilterButton(
              label: 'Finalizados',
              isSelected: currentStatus == MatchStatusFilter.finished,
              color: AppColors.gray500,
              onPressed: () {
                _toggleStatusFilter(context, currentStatus, MatchStatusFilter.finished);
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleStatusFilter(
    BuildContext context,
    MatchStatusFilter? currentStatus,
    MatchStatusFilter status,
  ) {
    final bloc = context.read<ResultsBloc>();
    if (currentStatus == status) {
      bloc.add(const ResultsFilterByStatus(status: null));
    } else {
      bloc.add(ResultsFilterByStatus(status: status));
    }
  }
}

/// Botón de filtro estilo web (cuadrado con borde redondeado)
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? buttonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? buttonColor : AppColors.gray300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.white : AppColors.gray700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Controles de navegación (< Semana X > Hoy)
class _NavigationControls extends StatelessWidget {
  const _NavigationControls({
    required this.weekLabel,
    required this.weekNumber,
    required this.isCurrentWeek,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final String weekLabel;
  final int weekNumber;
  final bool isCurrentWeek;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón anterior
        _NavButton(icon: Icons.chevron_left, onPressed: onPrevious),
        const SizedBox(width: 4),

        // Etiqueta de semana
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'S$weekNumber',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                weekLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),

        // Botón siguiente
        _NavButton(icon: Icons.chevron_right, onPressed: onNext),

        // Botón Hoy
        if (!isCurrentWeek) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Hoy',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Botón de navegación individual
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Icon(icon, size: 16, color: AppColors.gray700),
      ),
    );
  }
}

/// Botón de modo Live
class _LiveModeButton extends StatelessWidget {
  const _LiveModeButton({
    required this.isLiveMode,
    required this.liveCount,
    required this.onPressed,
  });

  final bool isLiveMode;
  final int liveCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hasLive = liveCount > 0;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isLiveMode
              ? AppColors.accent.withValues(alpha: 0.1)
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isLiveMode ? AppColors.accent : AppColors.gray200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: hasLive ? AppColors.accent : AppColors.gray400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isLiveMode ? 'LIVE' : 'Live',
              style: AppTypography.labelSmall.copyWith(
                color: isLiveMode ? AppColors.accent : AppColors.gray600,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            if (hasLive) ...[
              const SizedBox(width: 4),
              Text(
                '($liveCount)',
                style: AppTypography.labelSmall.copyWith(
                  color: isLiveMode ? AppColors.accent : AppColors.gray500,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
