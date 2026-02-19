import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo profesional con el informe completo del partido
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
            .select('idjugador, titular, mentra, apodo, dorsal, posicion, foto, convocado')
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

      setState(() {
        _players = (futures[0] as List).cast<Map<String, dynamic>>();
        _events = (futures[1] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });

      // Debug: mostrar estructura de eventos
      if (_events.isNotEmpty) {
        debugPrint('📊 [MatchReport] Estructura de veventos: ${_events.first.keys.toList()}');
        debugPrint('📊 [MatchReport] Total eventos: ${_events.length}');
      }
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
    final jornada = match['jornada']?.toString() ?? match['jcorta']?.toString();
    final ncortoEquipo = match['ncortoclub']?.toString() ?? 'Mi Equipo';
    final ncortoRival = match['ncortorival']?.toString() ?? match['ncortoclubrival']?.toString() ?? rival;

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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== HEADER =====
            _buildHeader(
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
            ),

            // ===== CONTENIDO SCROLLABLE =====
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de competición y resultado
                    _buildCompetitionBadge(jornada, widget.competition, resultText, resultBgColor, resultColor),

                    AppSpacing.vSpaceLg,

                    // Información del partido
                    _buildInfoSection(
                      fecha: fecha,
                      hora: hora,
                      campo: campo,
                      categoria: categoria,
                      temporada: temporada,
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

                    // Crónica del Partido (Eventos)
                    if (_events.isNotEmpty) ...[
                      AppSpacing.vSpaceLg,
                      _buildEventsTimeline(),
                    ],

                    // Observaciones
                    if (observaciones != null && observaciones.isNotEmpty) ...[
                      AppSpacing.vSpaceLg,
                      _buildObservations(observaciones),
                    ],
                  ],
                ),
              ),
            ),

            // ===== FOOTER =====
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
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
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.gray100, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Escudos y marcador
          Row(
            children: [
              // Equipo Local
              Expanded(
                child: Column(
                  children: [
                    _buildTeamShield(
                      escudoUrl: local ? escudo : escudorival,
                      isMyTeam: local,
                      rivalName: ncortoRival,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      local ? ncortoEquipo : ncortoRival,
                      style: AppTypography.labelMedium.copyWith(
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

              // Marcador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${local ? (goles ?? '-') : (golesrival ?? '-')}',
                          style: AppTypography.h1.copyWith(
                            fontWeight: FontWeight.w800,
                            color: local ? AppColors.primary : AppColors.gray600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '-',
                          style: AppTypography.h2.copyWith(
                            color: AppColors.gray300,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${local ? (golesrival ?? '-') : (goles ?? '-')}',
                          style: AppTypography.h1.copyWith(
                            fontWeight: FontWeight.w800,
                            color: !local ? AppColors.primary : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: resultBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        resultText,
                        style: AppTypography.labelSmall.copyWith(
                          color: resultColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
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
                    _buildTeamShield(
                      escudoUrl: !local ? escudo : escudorival,
                      isMyTeam: !local,
                      rivalName: ncortoRival,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      !local ? ncortoEquipo : ncortoRival,
                      style: AppTypography.labelMedium.copyWith(
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

  Widget _buildTeamShield({
    required String? escudoUrl,
    required bool isMyTeam,
    required String rivalName,
  }) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        shape: BoxShape.circle,
        border: Border.all(
          color: isMyTeam ? AppColors.primary.withValues(alpha: 0.3) : AppColors.gray100,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: escudoUrl != null && escudoUrl.isNotEmpty
            ? Image.network(
                escudoUrl,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildDefaultShield(isMyTeam),
                loadingBuilder: (_, child, ___) => child,
              )
            : _buildDefaultShield(isMyTeam),
      ),
    );
  }

  Widget _buildDefaultShield(bool isMyTeam) {
    return Icon(
      Icons.shield,
      size: 32,
      color: isMyTeam ? AppColors.primary : AppColors.gray400,
    );
  }

  Widget _buildCompetitionBadge(
    String? jornada,
    String? competition,
    String resultText,
    Color resultBgColor,
    Color resultColor,
  ) {
    return Row(
      children: [
        if (jornada != null || competition != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray100),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.gray500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      competition ?? jornada ?? 'Competición',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection({
    required DateTime? fecha,
    required String? hora,
    required String? campo,
    required String? categoria,
    required String? temporada,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Partido',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              if (fecha != null)
                _buildInfoItem(
                  Icons.calendar_today_outlined,
                  'Fecha',
                  DateFormat('dd/MM/yyyy').format(fecha),
                ),
              if (hora != null && hora.isNotEmpty)
                _buildInfoItem(
                  Icons.access_time,
                  'Hora',
                  hora,
                ),
              if (campo != null && campo.isNotEmpty)
                _buildInfoItem(
                  Icons.stadium_outlined,
                  'Campo',
                  campo,
                ),
              if (categoria != null && categoria.isNotEmpty)
                _buildInfoItem(
                  Icons.category_outlined,
                  'Categoría',
                  categoria,
                ),
              if (temporada != null && temporada.isNotEmpty)
                _buildInfoItem(
                  Icons.date_range_outlined,
                  'Temporada',
                  temporada,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gray400),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlayers() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildLineupSection(List<Map<String, dynamic>> titulares, List<Map<String, dynamic>> suplentes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titulares
        if (titulares.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.star_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Alineación Titular',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${titulares.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: titulares.map((p) => _buildPlayerChip(p, isTitular: true)).toList(),
          ),
        ],

        // Suplentes
        if (suplentes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.chair_outlined, size: 18, color: AppColors.gray500),
              const SizedBox(width: 6),
              Text(
                'Suplentes',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${suplentes.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suplentes.map((p) => _buildPlayerChip(p, isTitular: false)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerChip(Map<String, dynamic> player, {required bool isTitular}) {
    final dorsal = player['dorsal']?.toString() ?? '?';
    final nombre = player['apodo']?.toString() ?? 'Sin nombre';
    final posicion = player['posicion']?.toString() ?? '';
    final mentra = player['mentra'] as int?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isTitular ? AppColors.primary.withValues(alpha: 0.05) : AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTitular ? AppColors.primary.withValues(alpha: 0.2) : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dorsal
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isTitular ? AppColors.primary : AppColors.gray300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dorsal,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Nombre y posición
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nombre,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              if (posicion.isNotEmpty)
                Text(
                  posicion,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: AppColors.gray500,
                  ),
                ),
            ],
          ),
          // Minutos entrada (suplentes que entraron)
          if (!isTitular && mentra != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$mentra'",
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10,
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Línea de tiempo de eventos del partido (goles, tarjetas y tiempos)
  Widget _buildEventsTimeline() {
    final casafuera = widget.match['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);

    // Separar eventos por tipo
    final teamEvents = <Map<String, dynamic>>[];
    final rivalEvents = <Map<String, dynamic>>[];
    final timeEvents = <Map<String, dynamic>>[]; // inicio, descanso, etc.

    for (final event in _events) {
      // Detectar eventos de tiempo del partido
      final isTimeEvent = (event['inicio'] == 1 || event['inicio'] == true) ||
          (event['descanso'] == 1 || event['descanso'] == true) ||
          (event['segundamitad'] == 1 || event['segundamitad'] == true) ||
          (event['fin'] == 1 || event['fin'] == true);

      if (isTimeEvent) {
        timeEvents.add(event);
        continue;
      }

      final idjugador = event['idjugador'] as int?;
      final isRivalById = idjugador == 1; // idjugador = 1 significa jugador del rival

      final gol = event['gol'] == 1 || event['gol'] == true;
      final golPropio = event['golpropiopuerta'] == 1 || event['golpropiopuerta'] == true;
      final tam = event['tam'] == 1 || event['tam'] == true;
      final tam2 = event['tam2'] == 1 || event['tam2'] == true;
      final tamriv = event['tamriv'] == 1 || event['tamriv'] == true;
      final troriv = event['troriv'] == 1 || event['troriv'] == true;
      final golencajado = event['golencajado'] == 1 || event['golencajado'] == true; // Gol del rival (gol encajado)

      // Clasificar por idjugador Y por tipo de evento
      final isRivalEvent = isRivalById || tamriv || troriv || golencajado;

      if (isRivalEvent) {
        rivalEvents.add(event);
      } else if (gol || golPropio || tam || tam2) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Row(
            children: [
              const Text('⚽', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Crónica del Partido',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${allEvents.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Headers de equipos
          Row(
            children: [
              // Equipo local (tu equipo si es local, rival si eres visitante)
              Expanded(
                child: Text(
                  local ? (widget.match['ncortoclub']?.toString() ?? 'Mi Equipo') : (widget.match['rival']?.toString() ?? 'Rival'),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 60),
              // Equipo visitante
              Expanded(
                child: Text(
                  !local ? (widget.match['ncortoclub']?.toString() ?? 'Mi Equipo') : (widget.match['rival']?.toString() ?? 'Rival'),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Timeline de eventos
          Column(
            children: _buildTimelineRows(teamEvents, rivalEvents, local),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineRows(
    List<Map<String, dynamic>> teamEvents,
    List<Map<String, dynamic>> rivalEvents,
    bool isLocal,
  ) {
    final rows = <Widget>[];

    // Recolectar eventos de tiempo ordenados
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

    // Crear lista combinada de todos los eventos con su tipo
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

    // Ordenar por minuto
    allEventsWithTypes.sort((a, b) => a.minute.compareTo(b.minute));

    // Agrupar eventos por minuto
    final groupedEvents = <int, List<({Map<String, dynamic> event, String type})>>{};
    for (final item in allEventsWithTypes) {
      groupedEvents.putIfAbsent(item.minute, () => []);
      groupedEvents[item.minute]!.add((event: item.event, type: item.type));
    }

    // Construir filas
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

      // Si hay evento de tiempo, mostrarlo centrado
      if (timeEvent != null) {
        rows.add(_buildTimeEventRow(timeEvent));
      }

      // Si hay eventos de equipo, mostrarlos en el timeline
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

  /// Fila para evento de tiempo centrado (inicio, descanso, etc.)
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(height: 1, color: AppColors.gray200)),
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Evento del equipo (izquierda)
          Expanded(
            child: teamEvent != null
                ? _buildTimelineEventItem(teamEvent, isTeamEvent: true)
                : const SizedBox(),
          ),

          // Minuto central (circular)
          SizedBox(
            width: 48,
            child: showMinute != null
                ? Center(
                    child: Container(
                      width: 32,
                      height: 32,
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

          // Evento del rival (derecha)
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

    // Verificar tipo de evento
    final gol = event['gol'] == 1 || event['gol'] == true;
    final golPropio = event['golpropiopuerta'] == 1 || event['golpropiopuerta'] == true;
    final tam = event['tam'] == 1 || event['tam'] == true;
    final tam2 = event['tam2'] == 1 || event['tam2'] == true;
    final tamriv = event['tamriv'] == 1 || event['tamriv'] == true;
    final troriv = event['troriv'] == 1 || event['troriv'] == true;
    final golencajado = event['golencajado'] == 1 || event['golencajado'] == true; // Gol del rival

    // Determinar si es evento del rival (idjugador = 1 o por tipo de evento)
    final isRivalEvent = idjugador == 1 || tamriv || troriv || golencajado;

    // Buscar datos del jugador en la lista de convocados (solo para eventos de mi equipo)
    Map<String, dynamic>? playerData;
    if (!isRivalEvent && idjugador != null && idjugador != 1) {
      playerData = _players.where((p) => p['idjugador'] == idjugador).firstOrNull;
    }

    // Obtener dorsal: del evento directamente (tanto mi equipo como rival)
    final eventDorsal = event['dorsal'];
    String? dorsal;
    if (eventDorsal != null) {
      final dorsalStr = eventDorsal.toString();
      if (dorsalStr.isNotEmpty && dorsalStr != '0') {
        dorsal = dorsalStr;
      }
    }
    // Fallback para mi equipo: buscar en lista de convocados
    if (dorsal == null && playerData != null && playerData['dorsal'] != null) {
      final playerDorsal = playerData['dorsal'].toString();
      if (playerDorsal.isNotEmpty && playerDorsal != '0') {
        dorsal = playerDorsal;
      }
    }

    final dorsalValido = dorsal != null && dorsal.isNotEmpty;

    // Nombre del jugador: para goles encajados mostrar "Dorsal Nº X"
    String jugador;
    if (golencajado) {
      // Gol del rival: mostrar "Dorsal Nº X"
      jugador = dorsalValido ? 'Dorsal Nº $dorsal' : 'Rival';
    } else if (isRivalEvent) {
      // Otros eventos del rival: usar apodo del evento
      jugador = apodo ?? 'Rival';
    } else {
      jugador = playerData?['apodo']?.toString() ?? apodo ?? '';
    }

    // Determinar icono y colores
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
    } else if (troriv) {
      icon = Icons.square;
      bgColor = const Color(0xFFFEF2F2);
      iconColor = AppColors.error;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          if (golencajado)
            // Gol encajado: mostrar solo "Dorsal Nº X"
            Text(
              jugador,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray800,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else if (dorsalValido)
            Text(
              jugador.isNotEmpty ? '$dorsal. $jugador' : 'Dorsal $dorsal',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray800,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else if (jugador.isNotEmpty)
            Text(
              jugador,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray800,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, size: 18, color: AppColors.gray600),
              const SizedBox(width: 6),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.gray100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cerrar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gray100,
              foregroundColor: AppColors.gray700,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
    // Si tiene formato "MM:SS", extraer solo los minutos
    if (str.contains(':')) {
      final parts = str.split(':');
      if (parts.isNotEmpty) {
        return int.tryParse(parts[0]);
      }
    }
    return int.tryParse(str);
  }
}
