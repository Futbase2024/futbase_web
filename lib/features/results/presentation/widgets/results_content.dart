import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/results_bloc.dart';
import '../../bloc/results_event.dart';
import '../../bloc/results_state.dart';
import 'match_detail_dialog.dart';
import 'weekly_navigation.dart';
import 'weekly_calendar_grid.dart';
import 'results_empty_state.dart';

/// Contenido principal de resultados para integrar en Dashboard
/// Vista de calendario semanal con navegación entre semanas
class ResultsContent extends StatefulWidget {
  const ResultsContent({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<ResultsContent> createState() => _ResultsContentState();
}

class _ResultsContentState extends State<ResultsContent> {
  late final ResultsBloc _resultsBloc;

  @override
  void initState() {
    super.initState();
    _resultsBloc = ResultsBloc();
    _loadCurrentWeek();
  }

  @override
  void dispose() {
    _resultsBloc.close();
    super.dispose();
  }

  void _loadCurrentWeek() {
    final authState = context.read<AuthBloc>().state;
    final idtemporada = authState.idTemporada ?? 0;
    final idclub = widget.user.idclub;

    _resultsBloc.add(ResultsLoadWeekRequested(
      weekStart: DateTime.now(),
      idtemporada: idtemporada,
      idclub: idclub,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _resultsBloc,
      child: BlocBuilder<ResultsBloc, ResultsState>(
        builder: (context, state) {
          return switch (state) {
            ResultsInitial() => const CELoading.inline(),
            ResultsLoading() => CELoading.inline(message: state.message),
            ResultsLoaded() => _buildLoadedContent(state),
            ResultsError(:final message) => _buildErrorWidget(message),
            _ => const CELoading.inline(),
          };
        },
      ),
    );
  }

  Widget _buildLoadedContent(ResultsLoaded state) {
    return SafeArea(
      child: Column(
        children: [
          // Barra unificada: navegación semanal + filtros + Live
          WeeklyNavigation(
            weekLabel: state.weekLabel,
            weekNumber: state.weekNumber,
            isCurrentWeek: state.isCurrentWeek,
            isLiveMode: state.isLiveMode,
            liveCount: state.liveMatchesCount,
            onPrevious: () => _resultsBloc.add(const ResultsPreviousWeek()),
            onNext: () => _resultsBloc.add(const ResultsNextWeek()),
            onToday: () => _resultsBloc.add(const ResultsGoToToday()),
            onToggleLive: () => _resultsBloc.add(const ResultsToggleLiveMode()),
          ),

          // Selector de días (calendario)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            color: const Color(0xFFF8FAFB),
            child: WeeklyCalendarGrid(
              groupedMatches: state.groupedMatches,
              weekStart: state.currentWeekStart,
            ),
          ),

          // Header del día seleccionado
          _SelectedDayHeader(
            selectedDate: state.effectiveSelectedDate,
            matchCount: state.selectedDayMatches.length,
          ),

          // Lista de partidos del día seleccionado en GridView
          Expanded(
            child: state.groupedMatches.isEmpty
                ? const ResultsEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      _resultsBloc.add(const ResultsRefreshRequested());
                    },
                    child: state.selectedDayMatches.isEmpty
                        ? _EmptyDayState()
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 320,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.4,
                            ),
                            itemCount: state.selectedDayMatches.length,
                            itemBuilder: (context, index) {
                              return _ProfessionalMatchCard(match: state.selectedDayMatches[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
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
            'Error al cargar resultados',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
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
          CEButton(
            label: 'Reintentar',
            icon: Icons.refresh,
            type: CEButtonType.primary,
            onPressed: _loadCurrentWeek,
          ),
        ],
      ),
    );
  }
}

/// Header del día seleccionado
class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({
    required this.selectedDate,
    required this.matchCount,
  });

  final DateTime selectedDate;
  final int matchCount;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${dayNames[selectedDate.weekday - 1]} ${selectedDate.day} ${monthNames[selectedDate.month - 1]}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$matchCount partidos',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío para el día seleccionado
class _EmptyDayState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: AppColors.gray300,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay partidos este día',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta profesional de partido para el GridView
/// Diseño estilo Livescore/Flashscore con acento lateral
class _ProfessionalMatchCard extends StatelessWidget {
  const _ProfessionalMatchCard({required this.match});

  final MatchWithStatus match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;
    final isFinished = match.status == MatchStatus.finished;
    final goles = match.goles;
    final golesrival = match.golesrival;
    final hasScore = goles != null && golesrival != null;
    final minuto = match.minuto;

    // Color del acento lateral según estado
    Color accentColor;
    Color accentColorLight;
    if (isLive) {
      accentColor = AppColors.accent; // Verde limón
      accentColorLight = AppColors.accent.withValues(alpha: 0.08);
    } else if (isFinished) {
      accentColor = AppColors.error; // Rojo
      accentColorLight = AppColors.error.withValues(alpha: 0.05);
    } else {
      accentColor = AppColors.gray300; // Gris
      accentColorLight = AppColors.gray50;
    }

    return GestureDetector(
      onTap: () => _showMatchDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray900.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
            // Barra de acento lateral (4px)
            Container(
              width: 4,
              height: double.infinity,
              decoration: BoxDecoration(
                color: accentColor,
                boxShadow: isLive
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),

            // Contenido principal
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: accentColorLight,
                ),
                child: Column(
                  children: [
                    // Header con hora y estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.gray100,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Hora con icono
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.gray400,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                match.hora ?? '--:--',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.gray700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          // Badge estado
                          if (isLive)
                            _LiveBadge(minuto: minuto)
                          else if (isFinished)
                            _StatusBadge.finished(minuto: minuto)
                          else
                            _StatusBadge.scheduled(),
                        ],
                      ),
                    ),

                    // Cuerpo con equipos
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            // Equipo local
                            Expanded(
                              child: _TeamColumn(
                                escudoUrl: match.isLocal ? match.match['escudo'] : match.match['escudorival'],
                                nombre: match.isLocal ? match.equipoNombre : match.rivalNombre,
                              ),
                            ),

                            // Separador VS / Marcador
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: hasScore ? AppColors.primary : AppColors.gray100,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: hasScore
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                hasScore ? '$goles - $golesrival' : 'VS',
                                style: AppTypography.h4.copyWith(
                                  color: hasScore ? AppColors.white : AppColors.gray500,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),

                            // Equipo visitante
                            Expanded(
                              child: _TeamColumn(
                                escudoUrl: match.isLocal ? match.match['escudorival'] : match.match['escudo'],
                                nombre: match.isLocal ? match.rivalNombre : match.equipoNombre,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer con categoría
                    if (match.categoria != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.gray100,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 12,
                              color: AppColors.gray400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              match.categoria!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.gray500,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showMatchDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => MatchDetailDialog(match: match),
    );
  }
}

/// Columna de equipo (escudo + nombre)
class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.escudoUrl,
    required this.nombre,
  });

  final String? escudoUrl;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Escudo con sombra sutil
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _TeamShield(
            escudoUrl: escudoUrl,
            size: 48,
          ),
        ),
        const SizedBox(height: 8),
        // Nombre
        Text(
          nombre,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Badge de estado del partido
class _StatusBadge extends StatelessWidget {
  const _StatusBadge._({required this.label, required this.color, this.minuto, this.icon});

  factory _StatusBadge.finished({int? minuto}) => _StatusBadge._(
        label: (minuto != null && minuto > 0) ? "$minuto'" : 'FIN',
        color: AppColors.error,
        minuto: minuto,
        icon: Icons.check_circle_outline,
      );
  factory _StatusBadge.scheduled() => _StatusBadge._(
        label: 'PRG',
        color: AppColors.info,
        icon: Icons.schedule,
      );

  final String label;
  final Color color;
  final int? minuto;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge para partidos en vivo con animación pulsante
class _LiveBadge extends StatefulWidget {
  const _LiveBadge({this.minuto});

  final int? minuto;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador pulsante
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: _pulseAnimation.value * 0.6),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Minuto o LIVE
          Text(
            (widget.minuto != null && widget.minuto! > 0) ? "${widget.minuto}'" : 'LIVE',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Escudo del equipo (sin recorte circular)
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
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.gray100,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.sports_soccer_outlined,
          size: size * 0.5,
          color: AppColors.gray300,
        ),
      );
    }

    return Image.network(
      escudoUrl!,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.gray100,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.sports_soccer_outlined,
            size: size * 0.5,
            color: AppColors.gray300,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gray300,
              ),
            ),
          ),
        );
      },
    );
  }
}
