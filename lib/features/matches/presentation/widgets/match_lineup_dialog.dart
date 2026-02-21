import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';
import '../../bloc/matches_state.dart';

/// Diálogo para gestionar la alineación de un partido con campo visual y drag & drop
class MatchLineupDialog extends StatefulWidget {
  const MatchLineupDialog({
    super.key,
    required this.idpartido,
    required this.idequipo,
    required this.matchInfo,
    required this.onSaved,
    this.readOnly = false,
  });

  final int idpartido;
  final int idequipo;
  final Map<String, dynamic> matchInfo;
  final VoidCallback onSaved;

  /// Si es true, el diálogo es solo lectura (sin drag & drop ni edición)
  final bool readOnly;

  @override
  State<MatchLineupDialog> createState() => _MatchLineupDialogState();
}

class _MatchLineupDialogState extends State<MatchLineupDialog> {
  late final MatchesBloc _lineupBloc;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _lineupBloc = MatchesBloc();
    _lineupBloc.add(LineupLoadRequested(
      idpartido: widget.idpartido,
      idequipo: widget.idequipo,
    ));
  }

  @override
  void dispose() {
    _lineupBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rival = widget.matchInfo['rival'] as String? ?? 'Rival';
    final casafuera = widget.matchInfo['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 750, // Más estrecho
        constraints: const BoxConstraints(maxHeight: 650),
        child: BlocProvider.value(
          value: _lineupBloc,
          child: BlocBuilder<MatchesBloc, MatchesState>(
            builder: (context, state) {
              // Calcular número de titulares
              int titularesCount = 0;
              if (state is LineupState) {
                titularesCount = state.lineup.values.where((v) => v).length;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(rival, local, titularesCount: titularesCount),
                  Flexible(child: _buildContent(state)),
                  if (state is LineupState) _buildActions(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String rival, bool local, {int titularesCount = 0}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.group, color: AppColors.primary),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Alineación',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.readOnly) ...[
                      AppSpacing.hSpaceSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Solo lectura',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  local ? 'vs $rival' : '@ $rival',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
          // Contador de titulares
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group, size: 16, color: Colors.white),
                AppSpacing.hSpaceXs,
                Text(
                  'Titulares: $titularesCount',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSpaceSm,
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: AppColors.gray500,
          ),
        ],
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
      return _buildError(state);
    }

    if (state is LineupState) {
      return _buildMainContent(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildError(MatchesError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          AppSpacing.vSpaceMd,
          Text(
            'Error al cargar alineación',
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
                  _lineupBloc.add(LineupLoadRequested(
                    idpartido: widget.idpartido,
                    idequipo: widget.idequipo,
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

  Widget _buildMainContent(LineupState state) {
    final players = state.players;

    if (players.isEmpty) {
      return _buildEmptyState();
    }

    final titulares = players.where((p) => state.lineup[p['id']] == true).toList();
    final suplentes = players.where((p) => state.lineup[p['id']] != true).toList();

    // 📍 LOG DE POSICIONES EN UI
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📍 [LINEUP DIALOG] ESTADO ACTUAL:');
    debugPrint('  Total jugadores: ${players.length}');
    debugPrint('  Titulares: ${titulares.length}');
    debugPrint('  Suplentes: ${suplentes.length}');
    debugPrint('');
    debugPrint('📍 [LINEUP DIALOG] POSICIONES DE TITULARES:');
    for (final player in titulares) {
      final id = player['id'] as int;
      final nombre = player['nombre'] as String? ?? '?';
      final dorsal = player['dorsal'] as int?;
      final posicion = player['posicion'] as String?;
      final pX = state.posX[id];
      final pY = state.posY[id];
      debugPrint('  👤 #$dorsal $nombre | id=$id | posición táctica: $posicion | posX=$pX | posY=$pY');
    }
    debugPrint('');
    debugPrint('📍 [LINEUP DIALOG] POSICIONES DE SUPLENTES:');
    for (final player in suplentes) {
      final id = player['id'] as int;
      final nombre = player['nombre'] as String? ?? '?';
      final dorsal = player['dorsal'] as int?;
      final posicion = player['posicion'] as String?;
      final pX = state.posX[id];
      final pY = state.posY[id];
      debugPrint('  👤 #$dorsal $nombre | id=$id | posición táctica: $posicion | posX=$pX | posY=$pY');
    }
    debugPrint('═══════════════════════════════════════════════════════════');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Panel izquierdo: Suplentes
        Expanded(
          flex: 2,
          child: _buildSuplentesPanel(suplentes),
        ),
        // Panel derecho: Campo de fútbol (más estrecho)
        Expanded(
          flex: 3,
          child: _buildFootballField(state, titulares),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_add_outlined, size: 48, color: AppColors.warning),
          AppSpacing.vSpaceMd,
          Text(
            'No hay jugadores convocados',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.vSpaceXs,
          Text(
            'Primero debes hacer la convocatoria',
            style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildSuplentesPanel(List<Map<String, dynamic>> suplentes) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_seat, size: 18, color: AppColors.gray600),
                AppSpacing.hSpaceSm,
                Text(
                  'SUPLENTES',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.hSpaceSm,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${suplentes.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: suplentes.isEmpty
                ? Center(
                    child: Text(
                      'Todos son titulares',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.gray400),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: suplentes.length,
                    itemBuilder: (context, index) {
                      return _buildSuplenteTile(suplentes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuplenteTile(Map<String, dynamic> player) {
    final playerId = player['id'] as int;
    final nombre = player['nombre'] as String? ?? '';
    final dorsal = player['dorsal'] as int?;
    final posicion = player['posicion'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.gray200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Center(
            child: Text(
              dorsal?.toString() ?? '?',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: Text(
          nombre,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: posicion != null
            ? Text(
                posicion,
                style: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
              )
            : null,
        trailing: widget.readOnly
            ? null
            : Tooltip(
                message: 'Arrastra al campo',
                child: Icon(Icons.drag_indicator, size: 20, color: AppColors.gray400),
              ),
        onTap: widget.readOnly
            ? null
            : () {
                // Al tocar, hacer titular con posición por defecto
                _lineupBloc.add(LineupPlayerMarkRequested(
                  idpartido: widget.idpartido,
                  idjugador: playerId,
                  titular: true,
                ));
              },
      ),
    );
  }

  /// Proporción del campo (1:1.40)
  static const double _fieldAspectRatio = 1 / 1.40; // ≈ 0.7143

  /// Sistema de coordenadas BD:
  /// - X: 0 (izquierda) a 1 (derecha)
  /// - Y: 0 (abajo) a 1 (arriba)
  /// Se usan directamente los valores de la BD sin conversión.

  Widget _buildFootballField(LineupState state, List<Map<String, dynamic>> titulares) {
    return Center(
      child: AspectRatio(
        aspectRatio: _fieldAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.gray900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Campo de fútbol
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FootballFieldPainter(),
                  ),
                ),
                // Zona de drop para todo el campo
                Positioned.fill(
                  child: _buildDropZone(state, titulares),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone(LineupState state, List<Map<String, dynamic>> titulares) {
    return LayoutBuilder(
      builder: (context, fieldConstraints) {
        final fieldWidth = fieldConstraints.maxWidth;
        final fieldHeight = fieldConstraints.maxHeight;

        // 📐 LOG DE DIMENSIONES DEL CAMPO
        debugPrint('📐 CAMPO: ${fieldWidth.toStringAsFixed(1)} x ${fieldHeight.toStringAsFixed(1)} px | Aspect: ${_fieldAspectRatio.toStringAsFixed(4)} | Titulares: ${titulares.length}');

        // Si es solo lectura, no permitir drag & drop
        if (widget.readOnly) {
          return Stack(
            key: _fieldKey,
            children: titulares.map((player) {
              final playerId = player['id'] as int;
              final posX = state.posX[playerId];
              final posY = state.posY[playerId];

              return _buildDraggablePlayer(
                state,
                player,
                fieldWidth: fieldWidth,
                fieldHeight: fieldHeight,
                posX: posX,
                posY: posY,
              );
            }).toList(),
          );
        }

        // Modo editable: con DragTarget
        return DragTarget<Map<String, dynamic>>(
          key: _fieldKey,
          onWillAcceptWithDetails: (details) => true,
          onAcceptWithDetails: (details) {
            final player = details.data;
            final playerId = player['id'] as int;

            // Obtener posición del campo usando la GlobalKey
            final fieldRenderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
            if (fieldRenderBox == null) return;

            final fieldOrigin = fieldRenderBox.localToGlobal(Offset.zero);
            final dropOffset = details.offset;

            // Calcular posición relativa (0.0 - 1.0)
            final relativeX = ((dropOffset.dx - fieldOrigin.dx) / fieldWidth).clamp(0.05, 0.95);
            final relativeY = ((dropOffset.dy - fieldOrigin.dy) / fieldHeight).clamp(0.05, 0.95);

            // Marcar como titular y establecer posición
            _lineupBloc.add(LineupPlayerMarkRequested(
              idpartido: widget.idpartido,
              idjugador: playerId,
              titular: true,
            ));
            _lineupBloc.add(LineupPositionUpdateRequested(
              idpartido: widget.idpartido,
              idjugador: playerId,
              posX: relativeX,
              posY: relativeY,
            ));
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: titulares.map((player) {
                final playerId = player['id'] as int;
                final posX = state.posX[playerId];
                final posY = state.posY[playerId];

                return _buildDraggablePlayer(
                  state,
                  player,
                  fieldWidth: fieldWidth,
                  fieldHeight: fieldHeight,
                  posX: posX,
                  posY: posY,
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildDraggablePlayer(
    LineupState state,
    Map<String, dynamic> player, {
    required double fieldWidth,
    required double fieldHeight,
    double? posX,
    double? posY,
  }) {
    final playerId = player['id'] as int;
    final nombre = player['nombre'] as String? ?? '';
    final dorsal = player['dorsal'] as int?;
    final posicion = player['posicion'] as String?;

    // Determinar si es portero por la posición táctica
    final isPortero = posicion?.toLowerCase().contains('portero') ?? false;

    // Obtener URL de la camiseta según si es portero o no
    final camisetaUrl = state.getCamisetaUrl(isPortero);
    final dorsalColor = state.dorsalColor;

    // Usar posiciones reales de BD directamente (0-1)
    final effectiveX = posX ?? 0.5;
    final effectiveY = posY ?? _getDefaultYPosition(posicion);

    // Calcular posición en píxeles directamente desde BD
    const playerWidth = 55.0;
    const playerHeight = 75.0;

    // Offset para ajustar posición visual (más abajo y más a la derecha)
    const offsetX = 0.03; // 3% a la derecha
    const offsetY = 0.05; // 5% más abajo

    // Posición con offset
    final left = (effectiveX + offsetX) * fieldWidth;
    final top = (effectiveY + offsetY) * fieldHeight;

    // 📍 LOG DE POSICIÓN: BD vs Web
    debugPrint('📍 #$dorsal $nombre | BD: X=$posX, Y=$posY | Web: X=$effectiveX, Y=$effectiveY | Campo: ${fieldWidth.toStringAsFixed(1)}x${fieldHeight.toStringAsFixed(1)}px');

    // Widget del jugador
    final playerWidget = _buildPlayerWidget(
      dorsal,
      nombre,
      isPortero: isPortero,
      camisetaUrl: camisetaUrl,
      dorsalColor: dorsalColor,
    );

    // Si es solo lectura, mostrar sin interactividad
    if (widget.readOnly) {
      return Positioned(
        left: left.clamp(0.0, fieldWidth - playerWidth),
        top: top.clamp(0.0, fieldHeight - playerHeight),
        width: playerWidth,
        height: playerHeight,
        child: Tooltip(
          message: nombre,
          child: playerWidget,
        ),
      );
    }

    // Modo editable: con drag & drop
    return Positioned(
      left: left.clamp(0.0, fieldWidth - playerWidth),
      top: top.clamp(0.0, fieldHeight - playerHeight),
      width: playerWidth,
      height: playerHeight,
      child: Draggable<Map<String, dynamic>>(
        data: player,
        feedback: Material(
          color: Colors.transparent,
          child: _buildPlayerWidget(
            dorsal,
            nombre,
            isDragging: true,
            isPortero: isPortero,
            camisetaUrl: camisetaUrl,
            dorsalColor: dorsalColor,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildPlayerWidget(
            dorsal,
            nombre,
            isPortero: isPortero,
            camisetaUrl: camisetaUrl,
            dorsalColor: dorsalColor,
          ),
        ),
        onDragEnd: (details) {
          // Obtener posición del campo usando la GlobalKey (no el context del draggable)
          final fieldRenderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
          if (fieldRenderBox != null) {
            final fieldOrigin = fieldRenderBox.localToGlobal(Offset.zero);

            // Calcular posición relativa centrada en el jugador
            final relativeX = ((details.offset.dx - fieldOrigin.dx + playerWidth / 2) / fieldWidth).clamp(0.05, 0.95);
            final relativeY = ((details.offset.dy - fieldOrigin.dy + playerHeight / 2) / fieldHeight).clamp(0.05, 0.95);

            debugPrint('🔵 Drag end: offset=${details.offset}, origin=$fieldOrigin, relX=$relativeX, relY=$relativeY');

            _lineupBloc.add(LineupPositionUpdateRequested(
              idpartido: widget.idpartido,
              idjugador: playerId,
              posX: relativeX,
              posY: relativeY,
            ));
          }
        },
        child: GestureDetector(
          onTap: () {
            _lineupBloc.add(LineupPlayerMarkRequested(
              idpartido: widget.idpartido,
              idjugador: playerId,
              titular: false,
            ));
          },
          child: Tooltip(
            message: '$nombre - Arrastra para mover, toca para quitar',
            child: playerWidget,
          ),
        ),
      ),
    );
  }

  /// Obtiene el color del dorsal según idcolor de la BD
  /// 0=blanco, 1=negro, 2=naranja, 3=rosa
  Color _getDorsalColor(int dorsalColor) {
    switch (dorsalColor) {
      case 1:
        return Colors.black;
      case 2:
        return Colors.orange;
      case 3:
        return const Color(0xFFE91E63); // Rosa
      default:
        return Colors.white;
    }
  }

  Widget _buildPlayerWidget(
    int? dorsal,
    String nombre, {
    bool isDragging = false,
    bool isPortero = false,
    String? camisetaUrl,
    int dorsalColor = 0,
  }) {
    // Color del dorsal según BD
    final textColor = _getDorsalColor(dorsalColor);

    return SizedBox(
      width: 55,
      height: 75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camiseta con dorsal
          SizedBox(
            width: 45,
            height: 45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Imagen de la camiseta (desde URL o asset local)
                if (camisetaUrl != null && camisetaUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: camisetaUrl,
                    width: 45,
                    height: 45,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPortero ? AppColors.gray900 : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildFallbackCamiseta(isPortero, isDragging),
                  )
                else
                  _buildFallbackCamiseta(isPortero, isDragging),
                // Dorsal encima de la camiseta
                Positioned(
                  top: 12,
                  child: Text(
                    dorsal?.toString() ?? '?',
                    style: AppTypography.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: textColor == Colors.white
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Nombre del jugador - sin truncar, con ajuste automático
          SizedBox(
            width: 55,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                nombre,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback a camiseta local cuando no hay URL
  Widget _buildFallbackCamiseta(bool isPortero, bool isDragging) {
    final camisetaAsset = isPortero
        ? 'assets/camisetas/camisetaNegra.png'
        : 'assets/camisetas/camisetaNumero.png';

    return Image.asset(
      camisetaAsset,
      width: 45,
      height: 45,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback final al círculo si no encuentra la imagen
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPortero
                ? AppColors.gray900
                : (isDragging ? AppColors.primaryDark : AppColors.primary),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      },
    );
  }

  double _getDefaultYPosition(String? posicion) {
    if (posicion == null) return 0.5;
    final pos = posicion.toLowerCase();
    // Portero en la portería de abajo (el área pequeña va de 0.94 a 1.0)
    if (pos.contains('portero') || pos.contains('goalkeeper')) return 0.94;
    if (pos.contains('defen') || pos.contains('lateral') || pos.contains('central')) return 0.70;
    if (pos.contains('centro') || pos.contains('medio') || pos.contains('pivot')) return 0.45;
    if (pos.contains('delan') || pos.contains('extrem') || pos.contains('wing')) return 0.25;
    return 0.5;
  }

  Widget _buildActions(LineupState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildStatChip('Titulares', state.startersCount, AppColors.primary),
              AppSpacing.hSpaceSm,
              _buildStatChip('Suplentes', state.substitutesCount, AppColors.gray500),
            ],
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.hSpaceXs,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Pintor del campo de fútbol (más estrecho)
class _FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5016)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, paint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Línea central
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      linePaint,
    );

    // Círculo central
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.15,
      linePaint,
    );

    // Áreas
    _drawPenaltyArea(canvas, size, linePaint, isTop: false);
    _drawPenaltyArea(canvas, size, linePaint, isTop: true);
    _drawGoalArea(canvas, size, linePaint, isTop: false);
    _drawGoalArea(canvas, size, linePaint, isTop: true);

    // Borde del campo
    canvas.drawRect(Offset.zero & size, linePaint);
  }

  void _drawPenaltyArea(Canvas canvas, Size size, Paint paint, {required bool isTop}) {
    final areaWidth = size.width * 0.75;
    final areaHeight = size.height * 0.16;
    final left = (size.width - areaWidth) / 2;
    final top = isTop ? 0.0 : size.height - areaHeight;

    canvas.drawRect(
      Rect.fromLTWH(left, top, areaWidth, areaHeight),
      paint,
    );

    final penaltyY = isTop ? areaHeight + size.height * 0.04 : size.height - areaHeight - size.height * 0.04;
    canvas.drawCircle(
      Offset(size.width * 0.5, penaltyY),
      3,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;
  }

  void _drawGoalArea(Canvas canvas, Size size, Paint paint, {required bool isTop}) {
    final areaWidth = size.width * 0.4;
    final areaHeight = size.height * 0.06;
    final left = (size.width - areaWidth) / 2;
    final top = isTop ? 0.0 : size.height - areaHeight;

    canvas.drawRect(
      Rect.fromLTWH(left, top, areaWidth, areaHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
