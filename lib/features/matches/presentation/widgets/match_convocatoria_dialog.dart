import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';
import '../../bloc/matches_state.dart';

/// Diálogo para gestionar la convocatoria de jugadores del club
class MatchConvocatoriaDialog extends StatefulWidget {
  const MatchConvocatoriaDialog({
    super.key,
    required this.idpartido,
    required this.idclub,
    required this.idTemporada,
    required this.idequipo,
    required this.matchInfo,
    required this.onSaved,
  });

  final int idpartido;
  final int idclub;
  final int idTemporada;
  final int idequipo;
  final Map<String, dynamic> matchInfo;
  final VoidCallback onSaved;

  /// Captura el tiempo de click para medir rendimiento
  static void captureClickTime() {
    _MatchConvocatoriaDialogState._clickTime = DateTime.now();
    debugPrint('🔴 [TIMING] ⏱️ CLICK capturado - ${_MatchConvocatoriaDialogState._clickTime!.millisecondsSinceEpoch}');
  }

  @override
  State<MatchConvocatoriaDialog> createState() => _MatchConvocatoriaDialogState();
}

class _MatchConvocatoriaDialogState extends State<MatchConvocatoriaDialog> {
  late final MatchesBloc _convocatoriaBloc;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  static DateTime? _clickTime;

  @override
  void initState() {
    super.initState();
    debugPrint('🔴 [TIMING] ⏱️ Dialog initState START - ${DateTime.now().millisecondsSinceEpoch}');

    _convocatoriaBloc = MatchesBloc();
    debugPrint('🔴 [TIMING] ⏱️ Dialog Bloc creado - +${DateTime.now().difference(_clickTime ?? DateTime.now()).inMilliseconds}ms');

    _convocatoriaBloc.add(ConvocatoriaLoadRequested(
      idpartido: widget.idpartido,
      idclub: widget.idclub,
      idTemporada: widget.idTemporada,
    ));
    debugPrint('🔴 [TIMING] ⏱️ Dialog Event enviado - +${DateTime.now().difference(_clickTime ?? DateTime.now()).inMilliseconds}ms');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _convocatoriaBloc.close();
    super.dispose();
  }


  List<Map<String, dynamic>> _filterPlayers(List<Map<String, dynamic>> players) {
    if (_searchQuery.isEmpty) return players;

    final filterStart = DateTime.now();
    final query = _searchQuery.toLowerCase();
    final filtered = players.where((p) {
      final nombre = (p['nombre'] as String? ?? '').toLowerCase();
      final apellidos = (p['apellidos'] as String? ?? '').toLowerCase();
      final apodo = (p['apodo'] as String? ?? '').toLowerCase();
      final dorsal = (p['dorsal']?.toString() ?? '').toLowerCase();

      return nombre.contains(query) ||
          apellidos.contains(query) ||
          apodo.contains(query) ||
          dorsal.contains(query);
    }).toList();

    final filterDuration = DateTime.now().difference(filterStart).inMicroseconds;
    debugPrint('🔍 [Convocatoria] ⏱️ Filtro "$query": ${filtered.length}/${players.length} jugadores en $filterDurationμs');

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final buildStart = DateTime.now();
    if (_clickTime != null) {
      debugPrint('🔴 [TIMING] ⏱️ Dialog build() START - +${buildStart.difference(_clickTime!).inMilliseconds}ms desde click');
    }

    final rival = widget.matchInfo['rival'] as String? ?? 'Rival';
    final casafuera = widget.matchInfo['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);

    // Medir cuando se complete el frame actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_clickTime != null) {
        final frameTime = DateTime.now();
        debugPrint('🔴 [TIMING] ⏱️ Dialog PRIMER FRAME completo - +${frameTime.difference(_clickTime!).inMilliseconds}ms TOTAL');
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        child: BlocProvider.value(
          value: _convocatoriaBloc,
          child: BlocConsumer<MatchesBloc, MatchesState>(
            listener: (context, state) {
              if (state is ConvocatoriaState && !state.isSaving) {
                // Si acabamos de guardar (isSaving pasó de true a false), cerramos
                // Pero solo si antes estaba guardando
              }
            },
            builder: (context, state) {
              // Log cuando el estado cambia a ConvocatoriaState (datos cargados)
              if (state is ConvocatoriaState && _clickTime != null) {
                debugPrint('🔴 [TIMING] ⏱️ ConvocatoriaState renderizado - +${DateTime.now().difference(_clickTime!).inMilliseconds}ms');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_alt,
                          color: AppColors.primary,
                        ),
                        AppSpacing.hSpaceSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Convocatoria',
                                style: AppTypography.h6.copyWith(
                                  color: AppColors.gray900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                local ? 'vs $rival' : '@ $rival',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón cerrar siempre visible
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                          color: AppColors.gray500,
                          tooltip: 'Cerrar',
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: _buildContent(state),
                  ),

                  // Actions
                  if (state is ConvocatoriaState)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Stats
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.borderRadiusSm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${state.totalConvocados}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                AppSpacing.hSpaceXs,
                                Text(
                                  'convocados',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MatchesState state) {
    if (state is MatchesLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: CELoading.inline(message: 'Cargando jugadores...'),
      );
    }

    if (state is MatchesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            AppSpacing.vSpaceMd,
            Text(
              'Error al cargar jugadores',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gray700),
            ),
            AppSpacing.vSpaceMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
                AppSpacing.hSpaceSm,
                ElevatedButton(
                  onPressed: () {
                    _convocatoriaBloc.add(ConvocatoriaLoadRequested(
                      idpartido: widget.idpartido,
                      idclub: widget.idclub,
                      idTemporada: widget.idTemporada,
                    ));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (state is ConvocatoriaState) {
      return _buildPlayersList(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlayersList(ConvocatoriaState state) {
    final listStart = DateTime.now();
    if (_clickTime != null) {
      debugPrint('🔴 [TIMING] ⏱️ _buildPlayersList START - +${listStart.difference(_clickTime!).inMilliseconds}ms');
    }

    if (state.clubPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, size: 48, color: AppColors.gray400),
            AppSpacing.vSpaceMd,
            Text(
              'No hay jugadores en el club',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    // Separar jugadores de mi equipo y otros equipos
    final separateStart = DateTime.now();
    final myTeamPlayers = state.clubPlayers
        .where((p) => p['idequipo'] == widget.idequipo)
        .toList();
    final otherTeamPlayers = state.clubPlayers
        .where((p) => p['idequipo'] != widget.idequipo)
        .toList();
    debugPrint('🔴 [TIMING] ⏱️ Separar jugadores: ${DateTime.now().difference(separateStart).inMilliseconds}ms (${myTeamPlayers.length} mi equipo, ${otherTeamPlayers.length} otros)');

    // Aplicar filtro de búsqueda
    final filteredMyTeam = _filterPlayers(myTeamPlayers);
    final filteredOtherTeams = _filterPlayers(otherTeamPlayers);

    // Agrupar otros equipos
    final otherTeamsMap = <int, List<Map<String, dynamic>>>{};
    for (final player in filteredOtherTeams) {
      final idequipo = player['idequipo'] as int? ?? 0;
      otherTeamsMap.putIfAbsent(idequipo, () => []).add(player);
    }

    // Log antes de construir widgets
    if (_clickTime != null) {
      debugPrint('🔴 [TIMING] ⏱️ Construyendo ${state.clubPlayers.length} player tiles - +${DateTime.now().difference(_clickTime!).inMilliseconds}ms');
    }

    final result = Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              final searchStart = DateTime.now();
              setState(() {
                _searchQuery = value;
              });
              final searchDuration = DateTime.now().difference(searchStart).inMilliseconds;
              debugPrint('🔍 [Convocatoria] ⏱️ setState búsqueda: ${searchDuration}ms');
            },
            decoration: InputDecoration(
              hintText: 'Buscar jugador por nombre o dorsal...',
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.gray400),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear, size: 18, color: AppColors.gray400),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.gray50,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
          ),
        ),

        // Lista de jugadores con construcción lazy
        Expanded(
          child: _buildLazyPlayersList(
            state,
            myTeamPlayers,
            otherTeamPlayers,
            filteredMyTeam,
            filteredOtherTeams,
            otherTeamsMap,
          ),
        ),
      ],
    );

    // Log después de construir el widget
    if (_clickTime != null) {
      debugPrint('🔴 [TIMING] ⏱️ Column widget creado - +${DateTime.now().difference(_clickTime!).inMilliseconds}ms');
      // Medir cuando el frame con la lista se pinte
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔴 [TIMING] ⏱️ ===== LISTA PINTADA EN PANTALLA - +${DateTime.now().difference(_clickTime!).inMilliseconds}ms =====');
      });
    }

    return result;
  }

  /// Lista con construcción lazy usando ListView.builder
  Widget _buildLazyPlayersList(
    ConvocatoriaState state,
    List<Map<String, dynamic>> myTeamPlayers,
    List<Map<String, dynamic>> otherTeamPlayers,
    List<Map<String, dynamic>> filteredMyTeam,
    List<Map<String, dynamic>> filteredOtherTeams,
    Map<int, List<Map<String, dynamic>>> otherTeamsMap,
  ) {
    // Crear lista plana de items para el ListView.builder
    final items = <_ListItem>[];

    // Separar convocados del resto
    final allPlayers = [...filteredMyTeam, ...filteredOtherTeams];
    final convocadosList = allPlayers
        .where((p) => state.convocados.contains(p['id']))
        .toList();

    // Sección CONVOCADOS (al principio)
    if (convocadosList.isNotEmpty) {
      items.add(_ListItem(
        type: _ListItemType.convocadosHeader,
        total: convocadosList.length,
        convocados: convocadosList.length,
      ));
      for (final player in convocadosList) {
        items.add(_ListItem(type: _ListItemType.convocadoPlayer, player: player));
      }
      items.add(const _ListItem(type: _ListItemType.spacing));
    }

    // Mi equipo (solo NO convocados)
    final myTeamNoConvocados = filteredMyTeam
        .where((p) => !state.convocados.contains(p['id']))
        .toList();

    if (myTeamPlayers.isNotEmpty) {
      items.add(_ListItem(
        type: _ListItemType.myTeamHeader,
        teamName: state.equipos[widget.idequipo] ?? 'Mi Equipo',
        total: myTeamPlayers.length,
        convocados: myTeamPlayers.where((p) => state.convocados.contains(p['id'])).length,
      ));
      if (myTeamNoConvocados.isEmpty) {
        items.add(const _ListItem(type: _ListItemType.allConvocados));
      } else {
        for (final player in myTeamNoConvocados) {
          items.add(_ListItem(type: _ListItemType.myTeamPlayer, player: player));
        }
      }
      items.add(const _ListItem(type: _ListItemType.spacing));
    }

    // Otros equipos (solo NO convocados)
    if (otherTeamPlayers.isNotEmpty) {
      items.add(const _ListItem(type: _ListItemType.otherTeamsHeader));
      if (filteredOtherTeams.isEmpty) {
        items.add(const _ListItem(type: _ListItemType.noResults));
      } else {
        for (final entry in otherTeamsMap.entries) {
          // Filtrar solo NO convocados de este equipo
          final teamNoConvocados = entry.value
              .where((p) => !state.convocados.contains(p['id']))
              .toList();

          if (teamNoConvocados.isNotEmpty || entry.value.any((p) => state.convocados.contains(p['id']))) {
            items.add(_ListItem(
              type: _ListItemType.teamHeader,
              teamName: state.equipos[entry.key] ?? 'Sin equipo',
              total: entry.value.length,
              convocados: entry.value.where((p) => state.convocados.contains(p['id'])).length,
            ));
            if (teamNoConvocados.isEmpty) {
              items.add(const _ListItem(type: _ListItemType.allConvocados));
            } else {
              for (final player in teamNoConvocados) {
                items.add(_ListItem(type: _ListItemType.otherTeamPlayer, player: player));
              }
            }
            items.add(const _ListItem(type: _ListItemType.teamSpacing));
          }
        }
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        switch (item.type) {
          case _ListItemType.convocadosHeader:
            return _buildConvocadosHeader(item.total!, state);
          case _ListItemType.convocadoPlayer:
            return _buildPlayerTile(state, item.player!, isMyTeam: true);
          case _ListItemType.myTeamHeader:
            return _buildMyTeamHeader(item.teamName!, item.total!, item.convocados!);
          case _ListItemType.teamHeader:
            return _buildTeamHeader(item.teamName!, item.total!, item.convocados!);
          case _ListItemType.myTeamPlayer:
            return _buildPlayerTile(state, item.player!, isMyTeam: true);
          case _ListItemType.otherTeamPlayer:
            return _buildPlayerTile(state, item.player!);
          case _ListItemType.otherTeamsHeader:
            return _buildOtherTeamsHeader();
          case _ListItemType.noResults:
            return _buildNoResults();
          case _ListItemType.allConvocados:
            return _buildAllConvocadosInfo();
          case _ListItemType.spacing:
            return AppSpacing.vSpaceLg;
          case _ListItemType.teamSpacing:
            return AppSpacing.vSpaceMd;
        }
      },
    );
  }

  /// Header para sección de convocados
  Widget _buildConvocadosHeader(int count, ConvocatoriaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: AppColors.primary,
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Text(
              'CONVOCADOS',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Info cuando todos los jugadores de un equipo están convocados
  Widget _buildAllConvocadosInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Todos los jugadores están convocados',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMyTeamHeader(String teamName, int total, int convocados) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            size: 18,
            color: AppColors.primary,
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Text(
              teamName.toUpperCase(),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: convocados > 0 ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$convocados/$total',
              style: AppTypography.labelSmall.copyWith(
                color: convocados > 0 ? AppColors.primary : AppColors.gray500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTeamsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16,
            color: AppColors.gray500,
          ),
          AppSpacing.hSpaceXs,
          Text(
            'Jugadores de otros equipos (usa el buscador)',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(String teamName, int total, int convocados) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.gray600,
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Text(
              teamName.toUpperCase(),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: convocados > 0 ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$convocados/$total',
              style: AppTypography.labelSmall.copyWith(
                color: convocados > 0 ? AppColors.primary : AppColors.gray500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No se encontraron jugadores',
          style: AppTypography.bodySmall.copyWith(color: AppColors.gray400),
        ),
      ),
    );
  }

  Widget _buildPlayerTile(ConvocatoriaState state, Map<String, dynamic> player, {bool isMyTeam = false}) {
    final playerId = player['id'] as int;
    final nombre = player['nombre'] as String? ?? '';
    final apellidos = player['apellidos'] as String? ?? '';
    final apodo = player['apodo'] as String?;
    final dorsal = player['dorsal'] as int?;
    final idequipo = player['idequipo'] as int? ?? widget.idequipo;
    final isConvocado = state.convocados.contains(playerId);

    final displayName = (apodo != null && apodo.isNotEmpty)
        ? apodo
        : '$nombre $apellidos';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isConvocado
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.gray50,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isConvocado ? AppColors.primary.withValues(alpha: 0.3) : AppColors.gray200,
        ),
      ),
      child: ListTile(
        leading: Tooltip(
          message: 'Clic para editar dorsal',
          child: InkWell(
            onTap: () => _showDorsalDialog(playerId, dorsal, displayName, state),
            borderRadius: AppSpacing.borderRadiusSm,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isConvocado
                    ? AppColors.primary
                    : (isMyTeam ? AppColors.primary.withValues(alpha: 0.5) : AppColors.gray300),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Center(
                child: Text(
                  dorsal?.toString() ?? '?',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          displayName,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.gray900,
            fontWeight: isMyTeam ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: Tooltip(
          message: isConvocado ? 'Quitar convocatoria' : 'Convocar',
          child: IconButton(
            onPressed: () {
              _convocatoriaBloc.add(ConvocatoriaPlayerToggleRequested(
                idjugador: playerId,
                idequipo: idequipo,
                convocado: !isConvocado,
              ));
            },
            icon: Icon(
              isConvocado ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isConvocado ? AppColors.primary : AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo para editar el dorsal de un jugador
  void _showDorsalDialog(int playerId, int? currentDorsal, String playerName, ConvocatoriaState state) {
    final controller = TextEditingController(text: currentDorsal?.toString() ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Editar dorsal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playerName,
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
            ),
            AppSpacing.vSpaceMd,
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 2,
              decoration: InputDecoration(
                labelText: 'Dorsal',
                hintText: '1-99',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              final newDorsal = value.isEmpty ? null : int.tryParse(value);

              // Validar rango
              if (newDorsal != null && (newDorsal < 1 || newDorsal > 99)) {
                Navigator.of(dialogContext).pop();
                await CeInfoDialog.warning(
                  context,
                  title: 'Dorsal inválido',
                  message: 'El dorsal debe estar entre 1 y 99',
                );
                return;
              }

              // Verificar duplicados en el estado local
              final isDuplicate = state.clubPlayers.any((p) =>
                  p['id'] != playerId &&
                  p['dorsal'] == newDorsal &&
                  state.convocados.contains(p['id']));

              if (isDuplicate) {
                Navigator.of(dialogContext).pop();
                await CeInfoDialog.warning(
                  context,
                  title: 'Dorsal duplicado',
                  message: 'El dorsal $newDorsal ya está asignado a otro jugador convocado',
                );
                return;
              }

              _convocatoriaBloc.add(ConvocatoriaDorsalUpdateRequested(
                idjugador: playerId,
                dorsal: newDorsal,
              ));

              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

/// Tipos de items en la lista
enum _ListItemType {
  convocadosHeader,
  convocadoPlayer,
  myTeamHeader,
  teamHeader,
  myTeamPlayer,
  otherTeamPlayer,
  otherTeamsHeader,
  noResults,
  allConvocados,
  spacing,
  teamSpacing,
}

/// Item para ListView.builder
class _ListItem {
  final _ListItemType type;
  final String? teamName;
  final int? total;
  final int? convocados;
  final Map<String, dynamic>? player;

  const _ListItem({
    required this.type,
    this.teamName,
    this.total,
    this.convocados,
    this.player,
  });
}
