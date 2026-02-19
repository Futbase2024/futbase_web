import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';
import '../../bloc/matches_state.dart';
import 'matches_kpis.dart';
import 'next_match_card.dart';
import 'competition_calendar.dart';
import 'recent_results_list.dart';
import 'match_form_dialog.dart';
import 'match_lineup_dialog.dart';
import 'match_convocatoria_dialog.dart';
import 'match_report_dialog.dart';

/// Contenido principal de la página de partidos con diseño renovado
class MatchesContent extends StatefulWidget {
  const MatchesContent({
    super.key,
    required this.user,
    required this.idTemporada,
  });

  final UsuariosEntity user;
  final int idTemporada;

  @override
  State<MatchesContent> createState() => _MatchesContentState();
}

class _MatchesContentState extends State<MatchesContent> {
  late final MatchesBloc _matchesBloc;

  @override
  void initState() {
    super.initState();
    _matchesBloc = MatchesBloc();
    _loadMatches();
  }

  @override
  void dispose() {
    _matchesBloc.close();
    super.dispose();
  }

  void _loadMatches() {
    final idequipo = widget.user.idequipo;
    if (idequipo > 0) {
      _matchesBloc.add(MatchesLoadRequested(
        idequipo: idequipo,
        idTemporada: widget.idTemporada,
      ));
    }
  }

  void _onCreateMatch() {
    final idequipo = widget.user.idequipo;
    if (idequipo <= 0) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MatchFormDialog(
        idequipo: idequipo,
        idTemporada: widget.idTemporada,
        competitions: _getCompetitions(),
        onSaved: () {
          Navigator.of(dialogContext).pop();
          _matchesBloc.add(MatchesRefreshRequested(
            idequipo: idequipo,
            idTemporada: widget.idTemporada,
          ));
        },
      ),
    );
  }

  void _onEditMatch(Map<String, dynamic> match) {
    final idequipo = widget.user.idequipo;
    if (idequipo <= 0) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MatchFormDialog(
        idequipo: idequipo,
        idTemporada: widget.idTemporada,
        match: match,
        competitions: _getCompetitions(),
        onSaved: () {
          Navigator.of(dialogContext).pop();
          _matchesBloc.add(MatchesRefreshRequested(
            idequipo: idequipo,
            idTemporada: widget.idTemporada,
          ));
        },
      ),
    );
  }

  void _onLineup(Map<String, dynamic> match) {
    final idequipo = widget.user.idequipo;
    if (idequipo <= 0) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MatchLineupDialog(
        idpartido: match['id'] as int,
        idequipo: idequipo,
        matchInfo: match,
        onSaved: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showMatchReport(Map<String, dynamic> match, Map<int, String> competitions) {
    final idjornada = match['idjornada'] as int?;
    final competition = idjornada != null ? competitions[idjornada] : null;

    showDialog(
      context: context,
      builder: (context) => MatchReportDialog(
        match: match,
        competition: competition,
      ),
    );
  }

  void _onConvocatoria(Map<String, dynamic> match) {
    // Capturar tiempo de click para medir rendimiento
    MatchConvocatoriaDialog.captureClickTime();

    final idequipo = widget.user.idequipo;
    final idclub = match['idclub'] as int?;
    if (idequipo <= 0 || idclub == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return MatchConvocatoriaDialog(
          idpartido: match['id'] as int,
          idclub: idclub,
          idTemporada: widget.idTemporada,
          idequipo: idequipo,
          matchInfo: match,
          onSaved: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  Map<int, String> _getCompetitions() {
    final state = _matchesBloc.state;
    if (state is MatchesLoaded) {
      return state.competitions;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchesBloc,
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          return switch (state) {
            MatchesInitial() => const CELoading.inline(),
            MatchesLoading() => const CELoading.inline(message: 'Cargando partidos...'),
            MatchesLoaded() => _buildLoadedContent(state),
            MatchesError(:final message) => _buildErrorWidget(message),
            LineupState() => const CELoading.inline(),
            _ => const CELoading.inline(),
          };
        },
      ),
    );
  }

  Widget _buildLoadedContent(MatchesLoaded state) {
    // Separar partidos en categorías
    final nextMatch = _getNextMatch(state.matches);
    final allMatchesSorted = _getAllMatchesSorted(state.matches);
    final recentResults = _getRecentResults(state.matches);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(state.totalMatches),
          ),

          // KPIs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
              child: MatchesKpis(
                totalMatches: state.totalMatches,
                wins: state.wins,
                losses: state.losses,
                draws: state.draws,
                completedMatches: state.completedMatches,
              ),
            ),
          ),

          // Próximo Encuentro (destacado)
          if (nextMatch != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: NextMatchCard(
                  match: nextMatch,
                  competition: state.competitions[nextMatch['idcompeticion'] as int?],
                  onConvocatoria: () => _onConvocatoria(nextMatch),
                  onLineup: () => _onLineup(nextMatch),
                  onEdit: () => _onEditMatch(nextMatch),
                ),
              ),
            ),

          // Dos columnas: Calendario y Resultados
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendario de Competición (más ancho)
                  Expanded(
                    flex: 3,
                    child: CompetitionCalendar(
                      matches: allMatchesSorted,
                      competitions: state.competitions,
                      onEdit: _onEditMatch,
                      onLineup: _onLineup,
                    ),
                  ),
                  AppSpacing.hSpaceLg,

                  // Resultados Recientes (más estrecho)
                  Expanded(
                    flex: 2,
                    child: RecentResultsList(
                      matches: recentResults.take(5).toList(),
                      competitions: state.competitions,
                      onTap: (match) => _showMatchReport(match, state.competitions),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalMatches) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título
          Text(
            'Partidos',
            style: AppTypography.h4.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Botones de acción
          Row(
            children: [
              // Botón Filtros
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.gray200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              AppSpacing.hSpaceMd,

              // Botón Nuevo Encuentro
              ElevatedButton.icon(
                onPressed: _onCreateMatch,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo Encuentro'),
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
        ],
      ),
    );
  }

  /// Obtiene el próximo partido (el más cercano a hoy que no ha pasado)
  Map<String, dynamic>? _getNextMatch(List<Map<String, dynamic>> matches) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingMatches = matches.where((m) {
      final fecha = DateTime.tryParse(m['fecha']?.toString() ?? '');
      if (fecha == null) return false;
      final matchDate = DateTime(fecha.year, fecha.month, fecha.day);
      return !matchDate.isBefore(today);
    }).toList();

    upcomingMatches.sort((a, b) {
      final fechaA = DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime.now();
      final fechaB = DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime.now();
      return fechaA.compareTo(fechaB);
    });

    return upcomingMatches.isNotEmpty ? upcomingMatches.first : null;
  }

  /// Obtiene TODOS los partidos ordenados de más antiguo a más moderno
  List<Map<String, dynamic>> _getAllMatchesSorted(List<Map<String, dynamic>> matches) {
    final sortedMatches = List<Map<String, dynamic>>.from(matches);

    sortedMatches.sort((a, b) {
      final fechaA = DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime(1970);
      final fechaB = DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime(1970);
      return fechaA.compareTo(fechaB); // Más antiguos primero
    });

    return sortedMatches;
  }

  /// Obtiene los resultados recientes (partidos finalizados)
  List<Map<String, dynamic>> _getRecentResults(List<Map<String, dynamic>> matches) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final completed = matches.where((m) {
      final fecha = DateTime.tryParse(m['fecha']?.toString() ?? '');
      if (fecha == null) return false;
      final matchDate = DateTime(fecha.year, fecha.month, fecha.day);
      // finalizado puede ser int (0 o 1) o bool
      final finalizado = m['finalizado'];
      final isFinalizado = finalizado == 1 || finalizado == true;
      return matchDate.isBefore(today) || isFinalizado;
    }).toList();

    completed.sort((a, b) {
      final fechaA = DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime.now();
      final fechaB = DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime.now();
      return fechaB.compareTo(fechaA); // Más recientes primero
    });

    return completed;
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          AppSpacing.vSpaceMd,
          Text(
            'Error al cargar partidos',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
            ),
          ),
          AppSpacing.vSpaceXs,
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSpaceMd,
          CEButton(
            label: 'Reintentar',
            icon: Icons.refresh,
            onPressed: _loadMatches,
          ),
        ],
      ),
    );
  }
}
