import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo profesional con el informe completo del partido
/// Diseño optimizado para web con layout de 2 columnas
class MatchReportDialog extends StatefulWidget {
  const MatchReportDialog({
    super.key,
    required this.match,
    required this.competition,
  });

  final Map<String, dynamic> match;
  final String? competition;

  @override
  State<MatchReportDialog> createState() => _MatchReportDialogState();
}

class _MatchReportDialogState extends State<MatchReportDialog> {
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _camisetaUrl;
  String? _camisetaPorteroUrl;

  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
  }

  Future<void> _loadMatchDetails() async {
    try {
      final idpartido = widget.match['id'] as int;

      // Cargar jugadores convocados y eventos en paralelo
      final futures = await Future.wait([
        Supabase.instance.client
            .from('vpartidosjugadores')
            .select('idjugador, titular, mentra, apodo, dorsal, posicion, foto, convocado, posx, posy')
            .eq('idpartido', idpartido)
            .eq('convocado', 1)
            .order('titular', ascending: false)
            .order('dorsal'),
        Supabase.instance.client
            .from('veventos')
            .select('*')
            .eq('idpartido', idpartido)
            .order('minuto'),
      ]);

      // Obtener URLs de camisetas desde el partido
      final camisetaUrl = widget.match['camiseta']?.toString();
      final camisetaPorteroUrl = widget.match['camisetapor']?.toString();

      setState(() {
        _players = (futures[0] as List).cast<Map<String, dynamic>>();
        _events = (futures[1] as List).cast<Map<String, dynamic>>();
        _camisetaUrl = camisetaUrl;
        _camisetaPorteroUrl = camisetaPorteroUrl;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando detalles del partido: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final rival = match['rival']?.toString() ?? 'Sin rival';
    final casafuera = match['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);
    final goles = _toInt(match['goles']);
    final golesrival = _toInt(match['golesrival']);
    final fecha = _parseDate(match['fecha']);
    final hora = match['hora']?.toString();
    final campo = match['campo']?.toString();
    final categoria = match['categoria']?.toString();
    final temporada = match['temporada']?.toString();
    final observaciones = match['observaciones']?.toString();
    final ncortoEquipo = match['ncortoclub']?.toString() ?? 'Mi Equipo';
    // Obtener nombre del rival: si ncortorival/ncortoclubrival son '0' (idrival=14), usar el campo 'rival'
    final ncortoRivalValue = match['ncortorival']?.toString();
    final ncortoClubRivalValue = match['ncortoclubrival']?.toString();
    final ncortoRival = (ncortoRivalValue != null && ncortoRivalValue != '0')
        ? ncortoRivalValue
        : (ncortoClubRivalValue != null && ncortoClubRivalValue != '0')
            ? ncortoClubRivalValue
            : rival;

    // Determinar resultado
    String resultText;
    Color resultColor;
    Color resultBgColor;

    if (goles != null && golesrival != null) {
      if (goles > golesrival) {
        resultText = 'VICTORIA';
        resultColor = const Color(0xFF078830);
        resultBgColor = const Color(0xFFEAF7EF);
      } else if (goles < golesrival) {
        resultText = 'DERROTA';
        resultColor = AppColors.error;
        resultBgColor = const Color(0xFFFEF2F2);
      } else {
        resultText = 'EMPATE';
        resultColor = AppColors.gray600;
        resultBgColor = AppColors.gray100;
      }
    } else {
      resultText = 'PENDIENTE';
      resultColor = AppColors.gray500;
      resultBgColor = AppColors.gray100;
    }

    // Separar titulares y suplentes
    final titulares = _players.where((p) => p['titular'] == 1).toList();
    final suplentes = _players.where((p) => p['titular'] != 1).toList();

    // Calcular estadísticas de eventos
    final golesEquipo = _events.where((e) => e['gol'] == 1 || e['gol'] == true).length;
    final golesRival = _events.where((e) => e['golencajado'] == 1 || e['golencajado'] == true).length;
    final tarjetasAmarillas = _events.where((e) => (e['tam'] == 1 || e['tam'] == true) || (e['tam2'] == 1 || e['tam2'] == true)).length;
    // Tarjetas rojas: tro (equipo) + troriv (rival)
    final tarjetasRojas = _events.where((e) =>
        (e['tro'] == 1 || e['tro'] == true) ||
        (e['troriv'] == 1 || e['troriv'] == true)
    ).length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 920,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== HEADER GRANDE =====
            _buildHeroHeader(
              local: local,
              ncortoEquipo: ncortoEquipo,
              ncortoRival: ncortoRival,
              goles: goles,
              golesrival: golesrival,
              escudo: match['escudo']?.toString(),
              escudorival: match['escudorival']?.toString(),
              resultText: resultText,
              resultColor: resultColor,
              resultBgColor: resultBgColor,
              competition: widget.competition,
              fecha: fecha,
              hora: hora,
              campo: campo,
              categoria: categoria,
              temporada: temporada,
            ),

            // ===== CONTENIDO PRINCIPAL (2 COLUMNAS) =====
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== COLUMNA IZQUIERDA: Alineación =====
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Estadísticas rápidas
                          _buildQuickStats(
                            golesEquipo: golesEquipo,
                            golesRival: golesRival,
                            tarjetasAmarillas: tarjetasAmarillas,
                            tarjetasRojas: tarjetasRojas,
                          ),

                          AppSpacing.vSpaceLg,

                          // Alineación
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_players.isEmpty)
                            _buildEmptyPlayers()
                          else
                            _buildLineupSection(titulares, suplentes),

                          // Observaciones
                          if (observaciones != null && observaciones.isNotEmpty) ...[
                            AppSpacing.vSpaceLg,
                            _buildObservations(observaciones),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ===== SEPARADOR VERTICAL =====
                  Container(
                    width: 1,
                    color: AppColors.gray100,
                  ),

                  // ===== COLUMNA DERECHA: Timeline de eventos =====
                  Expanded(
                    flex: 5,
                    child: _events.isEmpty
                        ? _buildEmptyEvents()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: _buildEventsTimeline(),
                          ),
                  ),
                ],
              ),
            ),

            // ===== FOOTER =====
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Header grande y impactante con escudos, marcador y toda la info del partido
  Widget _buildHeroHeader({
    required bool local,
    required String ncortoEquipo,
    required String ncortoRival,
    required int? goles,
    required int? golesrival,
    required String? escudo,
    required String? escudorival,
    required String resultText,
    required Color resultColor,
    required Color resultBgColor,
    required String? competition,
    required DateTime? fecha,
    required String? hora,
    required String? campo,
    required String? categoria,
    required String? temporada,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.gray100, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Fila superior: Toda la info del partido
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              if (fecha != null)
                _buildHeaderChip(
                  icon: Icons.calendar_today_outlined,
                  label: DateFormat('dd/MM/yyyy').format(fecha),
                ),
              if (hora != null && hora.isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.access_time,
                  label: hora,
                ),
              if (competition != null)
                _buildHeaderChip(
                  icon: Icons.emoji_events_outlined,
                  label: competition,
                  isHighlighted: true,
                ),
              if (categoria != null && categoria.isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.category_outlined,
                  label: categoria,
                ),
              if (campo != null && campo.isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.stadium_outlined,
                  label: campo,
                ),
              if (temporada != null && temporada.isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.date_range_outlined,
                  label: temporada,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Escudos y marcador principal
          Row(
            children: [
              // Equipo Local
              Expanded(
                child: Column(
                  children: [
                    _buildLargeTeamShield(
                      escudoUrl: local ? escudo : escudorival,
                      isMyTeam: local,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      local ? ncortoEquipo : ncortoRival,
                      style: AppTypography.h6.copyWith(
                        fontWeight: FontWeight.w700,
                        color: local ? AppColors.primary : AppColors.gray700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Marcador central
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Marcador grande
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildScoreNumber(
                          local ? (goles ?? 0) : (golesrival ?? 0),
                          isMyTeam: local,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '-',
                            style: AppTypography.h1.copyWith(
                              color: AppColors.gray300,
                              fontWeight: FontWeight.w300,
                              fontSize: 48,
                            ),
                          ),
                        ),
                        _buildScoreNumber(
                          local ? (golesrival ?? 0) : (goles ?? 0),
                          isMyTeam: !local,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Badge de resultado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: resultBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: resultColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        resultText,
                        style: AppTypography.labelMedium.copyWith(
                          color: resultColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Equipo Visitante
              Expanded(
                child: Column(
                  children: [
                    _buildLargeTeamShield(
                      escudoUrl: !local ? escudo : escudorival,
                      isMyTeam: !local,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      !local ? ncortoEquipo : ncortoRival,
                      style: AppTypography.h6.copyWith(
                        fontWeight: FontWeight.w700,
                        color: !local ? AppColors.primary : AppColors.gray700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? AppColors.primary.withValues(alpha: 0.3) : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? AppColors.primary : AppColors.gray500,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isHighlighted ? AppColors.primary : AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTeamShield({
    required String? escudoUrl,
    required bool isMyTeam,
  }) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        shape: BoxShape.circle,
        border: Border.all(
          color: isMyTeam ? AppColors.primary.withValues(alpha: 0.4) : AppColors.gray200,
          width: 3,
        ),
        boxShadow: isMyTeam
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: escudoUrl != null && escudoUrl.isNotEmpty
            ? Image.network(
                escudoUrl,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildDefaultShieldLarge(isMyTeam),
                loadingBuilder: (_, child, ___) => child,
              )
            : _buildDefaultShieldLarge(isMyTeam),
      ),
    );
  }

  Widget _buildDefaultShieldLarge(bool isMyTeam) {
    return Icon(
      Icons.shield,
      size: 48,
      color: isMyTeam ? AppColors.primary : AppColors.gray400,
    );
  }

  Widget _buildScoreNumber(int score, {required bool isMyTeam}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 72),
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: isMyTeam ? AppColors.primary : AppColors.gray500,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Estadísticas rápidas del partido
  Widget _buildQuickStats({
    required int golesEquipo,
    required int golesRival,
    required int tarjetasAmarillas,
    required int tarjetasRojas,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 18, color: AppColors.gray500),
              const SizedBox(width: 8),
              Text(
                'Resumen',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.sports_soccer,
                  'Goles',
                  '$golesEquipo',
                  const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.sports_soccer_outlined,
                  'Encajados',
                  '$golesRival',
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.square,
                  'Amarillas',
                  '$tarjetasAmarillas',
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.square,
                  'Rojas',
                  '$tarjetasRojas',
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.h5.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlayers() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.group_off_outlined, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(
              'Sin convocatoria registrada',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEvents() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: AppColors.gray200),
          const SizedBox(height: 16),
          Text(
            'Sin eventos registrados',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupSection(List<Map<String, dynamic>> titulares, List<Map<String, dynamic>> suplentes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titulares con campo de fútbol
          if (titulares.isNotEmpty) ...[
            _buildSectionHeader(
              icon: Icons.star_outline,
              title: 'Alineación Titular',
              count: titulares.length,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildFootballField(titulares),
          ],

          // Suplentes - Banquillo visual
          if (suplentes.isNotEmpty) ...[
            if (titulares.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
            ],
            _buildSectionHeader(
              icon: Icons.chair_outlined,
              title: 'Banquillo',
              count: suplentes.length,
              color: AppColors.gray500,
            ),
            const SizedBox(height: 12),
            _buildBench(suplentes),
          ],
        ],
      ),
    );
  }

  /// Proporción del campo (1:1.40)
  static const double _fieldAspectRatio = 1 / 1.40;

  /// Campo de fútbol con los titulares posicionados
  Widget _buildFootballField(List<Map<String, dynamic>> titulares) {
    return Center(
      child: AspectRatio(
        aspectRatio: _fieldAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.gray900,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Campo de fútbol pintado
                const Positioned.fill(
                  child: CustomPaint(
                    painter: _FootballFieldPainter(),
                  ),
                ),
                // Jugadores posicionados
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: titulares.map((player) {
                          return _buildFieldPlayer(
                            player,
                            fieldWidth: constraints.maxWidth,
                            fieldHeight: constraints.maxHeight,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Jugador posicionado en el campo
  Widget _buildFieldPlayer(
    Map<String, dynamic> player, {
    required double fieldWidth,
    required double fieldHeight,
  }) {
    final dorsal = player['dorsal'] as int?;
    final nombre = player['apodo']?.toString() ?? '';
    final posicion = player['posicion']?.toString();
    final posX = player['posx'] as double?;
    final posY = player['posy'] as double?;
    final idjugador = player['idjugador'] as int?;

    // Determinar si es portero
    final isPortero = posicion?.toLowerCase().contains('portero') ?? false;

    // URL de la camiseta según si es portero o no
    final camisetaUrl = isPortero ? _camisetaPorteroUrl : _camisetaUrl;

    // Posición en el campo (usar BD o calcular por defecto)
    final effectiveX = posX ?? 0.5;
    final effectiveY = posY ?? _getDefaultYPosition(posicion);

    // Dimensiones del jugador
    const playerWidth = 55.0;
    const playerHeight = 85.0;

    // Offset para ajustar posición visual
    const offsetX = 0.03;
    const offsetY = 0.05;

    // Posición en píxeles
    final left = ((effectiveX + offsetX) * fieldWidth).clamp(0.0, fieldWidth - playerWidth);
    final top = ((effectiveY + offsetY) * fieldHeight).clamp(0.0, fieldHeight - playerHeight);

    return Positioned(
      left: left,
      top: top,
      width: playerWidth,
      height: playerHeight,
      child: Tooltip(
        message: nombre,
        child: _buildFieldPlayerWidget(
          dorsal,
          nombre,
          isPortero: isPortero,
          camisetaUrl: camisetaUrl,
          idjugador: idjugador,
        ),
      ),
    );
  }

  /// Widget del jugador para el campo (camiseta + dorsal + nombre + eventos)
  Widget _buildFieldPlayerWidget(
    int? dorsal,
    String nombre, {
    bool isPortero = false,
    String? camisetaUrl,
    int? idjugador,
  }) {
    final playerEvents = _getPlayerEvents(idjugador);

    return SizedBox(
      width: 55,
      height: 85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camiseta con dorsal
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Imagen de la camiseta
                if (camisetaUrl != null && camisetaUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: camisetaUrl,
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => _buildFallbackJersey(isPortero),
                    errorWidget: (context, url, error) => _buildAssetJersey(isPortero),
                  )
                else
                  _buildAssetJersey(isPortero),
                // Dorsal encima de la camiseta
                Positioned(
                  top: 11,
                  child: Text(
                    dorsal?.toString() ?? '?',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
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
          // Indicadores de eventos
          _buildEventIndicators(playerEvents, isDark: true),
          const SizedBox(height: 2),
          // Nombre del jugador
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

  /// Posición Y por defecto según la posición táctica
  double _getDefaultYPosition(String? posicion) {
    if (posicion == null) return 0.5;
    final pos = posicion.toLowerCase();
    // Portero en la portería de abajo
    if (pos.contains('portero') || pos.contains('goalkeeper')) return 0.88;
    if (pos.contains('defen') || pos.contains('lateral') || pos.contains('central')) return 0.68;
    if (pos.contains('centro') || pos.contains('medio') || pos.contains('pivot')) return 0.45;
    if (pos.contains('delan') || pos.contains('extrem') || pos.contains('wing')) return 0.25;
    return 0.5;
  }

  /// Obtiene los eventos de un jugador específico
  Map<String, dynamic> _getPlayerEvents(int? idjugador) {
    if (idjugador == null) return {};

    int goles = 0;
    int asistencias = 0;
    int tarjetasAmarillas = 0;
    int tarjetasRojas = 0;

    for (final event in _events) {
      final eventJugadorId = event['idjugador'] as int?;
      if (eventJugadorId != idjugador) continue;

      // Goles
      if (event['gol'] == 1 || event['gol'] == true) {
        goles++;
      }
      // Asistencias (golasistencia)
      if (event['golasistencia'] == 1 || event['golasistencia'] == true) {
        asistencias++;
      }
      // Tarjetas amarillas (tam o tam2)
      if ((event['tam'] == 1 || event['tam'] == true) ||
          (event['tam2'] == 1 || event['tam2'] == true)) {
        tarjetasAmarillas++;
      }
      // Tarjetas rojas (tro)
      if (event['tro'] == 1 || event['tro'] == true) {
        tarjetasRojas++;
      }
    }

    return {
      'goles': goles,
      'asistencias': asistencias,
      'amarillas': tarjetasAmarillas,
      'rojas': tarjetasRojas,
    };
  }

  /// Widget de indicadores de eventos (goles, tarjetas, etc.)
  Widget _buildEventIndicators(Map<String, dynamic> playerEvents, {bool isDark = true}) {
    final goles = playerEvents['goles'] as int? ?? 0;
    final asistencias = playerEvents['asistencias'] as int? ?? 0;
    final amarillas = playerEvents['amarillas'] as int? ?? 0;
    final rojas = playerEvents['rojas'] as int? ?? 0;

    if (goles == 0 && asistencias == 0 && amarillas == 0 && rojas == 0) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      alignment: WrapAlignment.center,
      children: [
        // Goles
        if (goles > 0)
          _buildEventBadge(
            icon: Icons.sports_soccer,
            count: goles,
            color: AppColors.success,
            isDark: isDark,
          ),
        // Asistencias
        if (asistencias > 0)
          _buildEventBadge(
            icon: Icons.arrow_forward,
            count: asistencias,
            color: AppColors.info,
            isDark: isDark,
          ),
        // Tarjetas amarillas
        if (amarillas > 0)
          _buildEventBadge(
            icon: Icons.square,
            count: amarillas,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            isCard: true,
          ),
        // Tarjetas rojas
        if (rojas > 0)
          _buildEventBadge(
            icon: Icons.square,
            count: rojas,
            color: AppColors.error,
            isDark: isDark,
            isCard: true,
          ),
      ],
    );
  }

  /// Badge individual de evento
  /// - Goles/Asistencias: fondo blanco/verde según isDark, iconos y texto en verde AppColors.primary
  /// - Tarjetas: fondo blanco, icono y texto del color de la tarjeta (amarillo/rojo)
  Widget _buildEventBadge({
    required IconData icon,
    required int count,
    required Color color,
    bool isDark = true,
    bool isCard = false,
  }) {
    // Para tarjetas: fondo blanco, iconos y texto del color de la tarjeta
    // Para goles/asistencias: fondo blanco/verde según isDark
    final bgColor = isCard
        ? Colors.white
        : (isDark ? Colors.white : AppColors.primary);
    final iconColor = isCard
        ? color
        : (isDark ? AppColors.primary : Colors.white);
    final textColor = isCard
        ? color
        : (isDark ? AppColors.primary : Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: iconColor,
          ),
          if (count > 1) ...[
            const SizedBox(width: 2),
            Text(
              'x$count',
              style: AppTypography.labelSmall.copyWith(
                color: textColor,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Banquillo visual con suplentes
  Widget _buildBench(List<Map<String, dynamic>> suplentes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gray100,
            AppColors.gray200.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          // Fila de suplentes en el banquillo (con scroll horizontal si es necesario)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: suplentes.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildBenchPlayer(player, index),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // El banco (asiento)
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.gray400,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray900.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Jugador suplente sentado en el banquillo
  Widget _buildBenchPlayer(Map<String, dynamic> player, int index) {
    final dorsal = player['dorsal']?.toString() ?? '?';
    final nombre = player['apodo']?.toString() ?? 'Sin nombre';
    final posicion = player['posicion']?.toString() ?? '';
    final mentra = player['mentra'] as int?;
    final idjugador = player['idjugador'] as int?;
    final isPortero = posicion.toLowerCase().contains('portero');
    final camisetaUrl = isPortero ? _camisetaPorteroUrl : _camisetaUrl;

    // Obtener eventos del jugador
    final playerEvents = _getPlayerEvents(idjugador);
    final tieneEventos = (playerEvents['goles'] as int? ?? 0) > 0 ||
        (playerEvents['asistencias'] as int? ?? 0) > 0 ||
        (playerEvents['amarillas'] as int? ?? 0) > 0 ||
        (playerEvents['rojas'] as int? ?? 0) > 0;

    return Tooltip(
      message: mentra != null ? '$nombre ($mentra\')' : nombre,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de minuto entrada (si jugó) - Verde AppColors.primary
          if (mentra != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward, size: 10, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    "$mentra'",
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          // Camiseta del suplente
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (camisetaUrl != null && camisetaUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: camisetaUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => _buildFallbackJersey(isPortero),
                    errorWidget: (context, url, error) => _buildAssetJerseySmall(isPortero),
                  )
                else
                  _buildAssetJerseySmall(isPortero),
                // Dorsal
                Positioned(
                  top: 10,
                  child: Text(
                    dorsal,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
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
          // Indicadores de eventos
          if (tieneEventos)
            _buildEventIndicators(playerEvents, isDark: false),
          const SizedBox(height: 2),
          // Nombre corto
          SizedBox(
            width: 55,
            child: Text(
              nombre.split(' ').first,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Camiseta pequeña para banquillo
  Widget _buildAssetJerseySmall(bool isPortero) {
    return Image.asset(
      isPortero
          ? 'assets/camisetas/camisetaNegra.png'
          : 'assets/camisetas/camisetaNumero.png',
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallbackJersey(isPortero),
    );
  }

  /// Camiseta desde asset local
  Widget _buildAssetJersey(bool isPortero) {
    return Image.asset(
      isPortero
          ? 'assets/camisetas/camisetaNegra.png'
          : 'assets/camisetas/camisetaNumero.png',
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallbackJersey(isPortero),
    );
  }

  /// Fallback a círculo si no hay imagen
  Widget _buildFallbackJersey(bool isPortero) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isPortero ? AppColors.gray900 : AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  /// Línea de tiempo de eventos del partido (versión mejorada)
  Widget _buildEventsTimeline() {
    final casafuera = widget.match['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);

    // Separar eventos por tipo
    final teamEvents = <Map<String, dynamic>>[];
    final rivalEvents = <Map<String, dynamic>>[];
    final timeEvents = <Map<String, dynamic>>[];

    for (final event in _events) {
      final isTimeEvent = (event['inicio'] == 1 || event['inicio'] == true) ||
          (event['descanso'] == 1 || event['descanso'] == true) ||
          (event['segundamitad'] == 1 || event['segundamitad'] == true) ||
          (event['fin'] == 1 || event['fin'] == true);

      if (isTimeEvent) {
        timeEvents.add(event);
        continue;
      }

      final idjugador = event['idjugador'] as int?;
      final isRivalById = idjugador == 1;

      final gol = event['gol'] == 1 || event['gol'] == true;
      final golPropio = event['golpropiopuerta'] == 1 || event['golpropiopuerta'] == true;
      final tam = event['tam'] == 1 || event['tam'] == true;
      final tam2 = event['tam2'] == 1 || event['tam2'] == true;
      final tro = event['tro'] == 1 || event['tro'] == true; // Tarjeta roja del equipo
      final tamriv = event['tamriv'] == 1 || event['tamriv'] == true;
      final troriv = event['troriv'] == 1 || event['troriv'] == true;
      final golencajado = event['golencajado'] == 1 || event['golencajado'] == true;

      final isRivalEvent = isRivalById || tamriv || troriv || golencajado;

      if (isRivalEvent) {
        rivalEvents.add(event);
      } else if (gol || golPropio || tam || tam2 || tro) {
        teamEvents.add(event);
      }
    }

    // Ordenar por minuto
    teamEvents.sort((a, b) {
      final minA = _parseInt(a['minuto']) ?? 0;
      final minB = _parseInt(b['minuto']) ?? 0;
      return minA.compareTo(minB);
    });
    rivalEvents.sort((a, b) {
      final minA = _parseInt(a['minuto']) ?? 0;
      final minB = _parseInt(b['minuto']) ?? 0;
      return minA.compareTo(minB);
    });

    final allEvents = [...teamEvents, ...rivalEvents, ...timeEvents];
    if (allEvents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección
        _buildSectionHeader(
          icon: Icons.timeline,
          title: 'Crónica del Partido',
          count: allEvents.length,
          color: AppColors.primary,
        ),

        const SizedBox(height: 16),

        // Headers de equipos
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.gray100),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  local ? (widget.match['ncortoclub']?.toString() ?? 'Mi Equipo') : (widget.match['rival']?.toString() ?? 'Rival'),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: Text(
                  !local ? (widget.match['ncortoclub']?.toString() ?? 'Mi Equipo') : (widget.match['rival']?.toString() ?? 'Rival'),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Timeline de eventos
        ..._buildTimelineRows(teamEvents, rivalEvents, local),
      ],
    );
  }

  List<Widget> _buildTimelineRows(
    List<Map<String, dynamic>> teamEvents,
    List<Map<String, dynamic>> rivalEvents,
    bool isLocal,
  ) {
    final rows = <Widget>[];

    final timeEventsList = <Map<String, dynamic>>[];
    for (final event in _events) {
      final isTimeEvent = (event['inicio'] == 1 || event['inicio'] == true) ||
          (event['descanso'] == 1 || event['descanso'] == true) ||
          (event['segundamitad'] == 1 || event['segundamitad'] == true) ||
          (event['fin'] == 1 || event['fin'] == true);
      if (isTimeEvent) {
        timeEventsList.add(event);
      }
    }

    final allEventsWithTypes = <({Map<String, dynamic> event, String type, int minute})>[];

    for (final e in teamEvents) {
      allEventsWithTypes.add((event: e, type: 'team', minute: _parseInt(e['minuto']) ?? 0));
    }
    for (final e in rivalEvents) {
      allEventsWithTypes.add((event: e, type: 'rival', minute: _parseInt(e['minuto']) ?? 0));
    }
    for (final e in timeEventsList) {
      int minute;
      if (e['inicio'] == 1 || e['inicio'] == true) {
        minute = 0;
      } else if (e['descanso'] == 1 || e['descanso'] == true) {
        minute = 45;
      } else if (e['segundamitad'] == 1 || e['segundamitad'] == true) {
        minute = 46;
      } else if (e['fin'] == 1 || e['fin'] == true) {
        minute = 90;
      } else {
        minute = _parseInt(e['minuto']) ?? 0;
      }
      allEventsWithTypes.add((event: e, type: 'time', minute: minute));
    }

    allEventsWithTypes.sort((a, b) => a.minute.compareTo(b.minute));

    final groupedEvents = <int, List<({Map<String, dynamic> event, String type})>>{};
    for (final item in allEventsWithTypes) {
      groupedEvents.putIfAbsent(item.minute, () => []);
      groupedEvents[item.minute]!.add((event: item.event, type: item.type));
    }

    final sortedMinutes = groupedEvents.keys.toList()..sort();

    for (final minute in sortedMinutes) {
      final eventsAtMinute = groupedEvents[minute]!;

      Map<String, dynamic>? teamEvent;
      Map<String, dynamic>? rivalEvent;
      Map<String, dynamic>? timeEvent;

      for (final e in eventsAtMinute) {
        if (e.type == 'team') {
          teamEvent = e.event;
        } else if (e.type == 'rival') {
          rivalEvent = e.event;
        } else if (e.type == 'time') {
          timeEvent = e.event;
        }
      }

      if (timeEvent != null) {
        rows.add(_buildTimeEventRow(timeEvent));
      }

      if (teamEvent != null || rivalEvent != null) {
        rows.add(_buildTimelineRow(
          teamEvent: isLocal ? teamEvent : rivalEvent,
          rivalEvent: isLocal ? rivalEvent : teamEvent,
          isLocal: isLocal,
          minute: minute,
        ));
      }
    }

    return rows;
  }

  Widget _buildTimeEventRow(Map<String, dynamic> event) {
    final inicio = event['inicio'] == 1 || event['inicio'] == true;
    final descanso = event['descanso'] == 1 || event['descanso'] == true;
    final segundaMitad = event['segundamitad'] == 1 || event['segundamitad'] == true;
    final fin = event['fin'] == 1 || event['fin'] == true;

    String label;
    IconData icon;
    Color bgColor;
    Color iconColor;
    int minute;

    if (inicio) {
      label = 'Inicio';
      icon = Icons.play_arrow_rounded;
      bgColor = AppColors.primary.withValues(alpha: 0.1);
      iconColor = AppColors.primary;
      minute = 0;
    } else if (descanso) {
      label = 'Descanso';
      icon = Icons.pause_rounded;
      bgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFF59E0B);
      minute = 45;
    } else if (segundaMitad) {
      label = '2ª Parte';
      icon = Icons.play_arrow_rounded;
      bgColor = AppColors.primary.withValues(alpha: 0.1);
      iconColor = AppColors.primary;
      minute = 46;
    } else if (fin) {
      label = 'Final';
      icon = Icons.flag_rounded;
      bgColor = const Color(0xFFEAF7EF);
      iconColor = const Color(0xFF16A34A);
      minute = 90;
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(height: 1, color: AppColors.gray200)),
          Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$minute'",
                    style: AppTypography.labelSmall.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(height: 1, color: AppColors.gray200)),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required Map<String, dynamic>? teamEvent,
    required Map<String, dynamic>? rivalEvent,
    required bool isLocal,
    int? minute,
  }) {
    final teamMin = teamEvent != null ? _parseInt(teamEvent['minuto']) : null;
    final rivalMin = rivalEvent != null ? _parseInt(rivalEvent['minuto']) : null;
    final showMinute = minute ?? teamMin ?? rivalMin;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: teamEvent != null
                ? _buildTimelineEventItem(teamEvent, isTeamEvent: true)
                : const SizedBox(),
          ),
          SizedBox(
            width: 56,
            child: showMinute != null
                ? Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "$showMinute'",
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          Expanded(
            child: rivalEvent != null
                ? _buildTimelineEventItem(rivalEvent, isTeamEvent: false)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEventItem(Map<String, dynamic> event, {required bool isTeamEvent}) {
    final idjugador = event['idjugador'] as int?;
    final apodo = event['apodo']?.toString();

    final gol = event['gol'] == 1 || event['gol'] == true;
    final golPropio = event['golpropiopuerta'] == 1 || event['golpropiopuerta'] == true;
    final tam = event['tam'] == 1 || event['tam'] == true;
    final tam2 = event['tam2'] == 1 || event['tam2'] == true;
    final tro = event['tro'] == 1 || event['tro'] == true; // Tarjeta roja del equipo
    final tamriv = event['tamriv'] == 1 || event['tamriv'] == true;
    final troriv = event['troriv'] == 1 || event['troriv'] == true;
    final golencajado = event['golencajado'] == 1 || event['golencajado'] == true;

    final isRivalEvent = idjugador == 1 || tamriv || troriv || golencajado;

    Map<String, dynamic>? playerData;
    if (!isRivalEvent && idjugador != null && idjugador != 1) {
      playerData = _players.where((p) => p['idjugador'] == idjugador).firstOrNull;
    }

    final eventDorsal = event['dorsal'];
    String? dorsal;
    if (eventDorsal != null) {
      final dorsalStr = eventDorsal.toString();
      if (dorsalStr.isNotEmpty && dorsalStr != '0') {
        dorsal = dorsalStr;
      }
    }
    if (dorsal == null && playerData != null && playerData['dorsal'] != null) {
      final playerDorsal = playerData['dorsal'].toString();
      if (playerDorsal.isNotEmpty && playerDorsal != '0') {
        dorsal = playerDorsal;
      }
    }

    final dorsalValido = dorsal != null && dorsal.isNotEmpty;

    String jugador;
    if (golencajado) {
      jugador = dorsalValido ? 'Dorsal Nº $dorsal' : 'Rival';
    } else if (isRivalEvent) {
      jugador = apodo ?? 'Rival';
    } else {
      jugador = playerData?['apodo']?.toString() ?? apodo ?? '';
    }

    IconData icon;
    Color bgColor;
    Color iconColor;

    if (gol || golencajado) {
      icon = Icons.sports_soccer;
      bgColor = const Color(0xFFEAF7EF);
      iconColor = const Color(0xFF16A34A);
    } else if (golPropio) {
      icon = Icons.cancel_outlined;
      bgColor = const Color(0xFFFEF2F2);
      iconColor = AppColors.error;
    } else if (tam || tam2 || tamriv) {
      icon = Icons.square;
      bgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFF59E0B);
    } else if (tro || troriv) {
      icon = Icons.square;
      bgColor = const Color(0xFFFEF2F2);
      iconColor = AppColors.error;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              golencajado
                  ? jugador
                  : dorsalValido
                      ? (jugador.isNotEmpty ? '$dorsal. $jugador' : 'Dorsal $dorsal')
                      : jugador,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray800,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservations(String observaciones) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, size: 18, color: AppColors.gray600),
              const SizedBox(width: 8),
              Text(
                'Observaciones',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            observaciones,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.gray100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cerrar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    return DateTime.tryParse(dateValue.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    final str = value.toString();
    if (str.contains(':')) {
      final parts = str.split(':');
      if (parts.isNotEmpty) {
        return int.tryParse(parts[0]);
      }
    }
    return int.tryParse(str);
  }
}

/// Pintor del campo de fútbol
class _FootballFieldPainter extends CustomPainter {
  const _FootballFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo verde del campo
    final grassPaint = Paint()
      ..color = const Color(0xFF2D5016)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, grassPaint);

    // Líneas blancas
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Línea central horizontal
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

    // Punto central
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      3,
      linePaint..style = PaintingStyle.fill,
    );
    linePaint.style = PaintingStyle.stroke;

    // Áreas de penalty
    _drawPenaltyArea(canvas, size, linePaint, isTop: false);
    _drawPenaltyArea(canvas, size, linePaint, isTop: true);

    // Áreas pequeñas (portería)
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

    // Punto de penalty
    final penaltyY = isTop
        ? areaHeight + size.height * 0.04
        : size.height - areaHeight - size.height * 0.04;
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
