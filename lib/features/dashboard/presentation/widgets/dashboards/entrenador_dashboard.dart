import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/shared_widgets.dart';
import '../dashboard_sidebar.dart';

/// Dashboard para Entrenadores con estadísticas de su equipo
class EntrenadorDashboard extends StatefulWidget {
  const EntrenadorDashboard({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<EntrenadorDashboard> createState() => _EntrenadorDashboardState();
}

class _EntrenadorDashboardState extends State<EntrenadorDashboard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;

  // Datos del equipo
  int _totalJugadores = 0;
  int _entrenamientosMes = 0;
  int _partidosJugados = 0;

  // Estadísticas de partidos
  int _partidosGanados = 0;
  int _partidosEmpatados = 0;
  int _partidosPerdidos = 0;

  // Estadísticas avanzadas del equipo
  int _totalFaltasFavor = 0;
  int _totalFaltasContra = 0;
  int _totalCornersFavor = 0;
  int _totalCornersContra = 0;
  int _totalDisparosFavor = 0;
  int _totalDisparosContra = 0;
  int _totalDisparosPuertaFavor = 0;
  int _totalDisparosPuertaContra = 0;
  int _totalFueraJuegoFavor = 0;
  int _totalFueraJuegoContra = 0;
  int _totalLlegadasFavor = 0;
  int _totalLlegadasContra = 0;
  int _totalOcasionesFavor = 0;
  int _totalOcasionesContra = 0;

  // Jugadores por posición
  Map<String, int> _jugadoresPorPosicion = {};

  // Total de goles
  int _totalGolesFavor = 0;
  int _totalGolesContra = 0;

  // Escudo del club local
  String _escudoLocal = '';

  // Nombre del equipo local
  String _nombreEquipoLocal = '';

  // Próximos partidos
  List<Map<String, dynamic>> _proximosPartidos = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().millisecondsSinceEpoch;
    if (dashboardClickTimestamp != null) {
      final elapsed = now - dashboardClickTimestamp!;
      debugPrint('⏱️ [TIMING] 📦 EntrenadorDashboard.initState: $now ms | ⚡ Transcurrido: ${elapsed}ms');
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final idequipo = widget.user.idequipo;

      if (idequipo == 0) {
        setState(() {
          _error = 'No tienes un equipo asignado';
          _isLoading = false;
        });
        return;
      }

      // Obtener jugadores del equipo con posición
      final jugadoresData = await _supabase
          .from('tjugadores')
          .select('id, nombre, apellidos, dorsal, idposicion')
          .eq('idequipo', idequipo);

      debugPrint('EntrenadorDashboard: Jugadores encontrados: ${jugadoresData.length}');

      // Obtener posiciones
      final posicionesData = await _supabase
          .from('tposiciones')
          .select('id, posicion');

      debugPrint('EntrenadorDashboard: Posiciones encontradas: ${posicionesData.length}');

      final posicionesMap = <int, String>{};
      for (final pos in posicionesData as List) {
        posicionesMap[pos['id'] as int] = pos['posicion'] as String;
      }

      // Contar jugadores por posición
      final jugadoresPorPosicion = <String, int>{};
      for (final jugador in jugadoresData as List) {
        // Manejar idposicion que puede ser int, String o null
        final idposicionRaw = jugador['idposicion'];
        int? idposicion;
        if (idposicionRaw is int) {
          idposicion = idposicionRaw;
        } else if (idposicionRaw != null) {
          idposicion = int.tryParse(idposicionRaw.toString());
        }
        final posicion = idposicion != null ? (posicionesMap[idposicion] ?? 'Sin posición') : 'Sin posición';
        jugadoresPorPosicion[posicion] = (jugadoresPorPosicion[posicion] ?? 0) + 1;
      }
      debugPrint('EntrenadorDashboard: Jugadores por posición: $jugadoresPorPosicion');
      debugPrint('EntrenadorDashboard: Mapa de posiciones: $posicionesMap');

      // Obtener entrenamientos del mes
      final inicioMes = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final entrenamientosData = await _supabase
          .from('tentrenamientos')
          .select('id')
          .eq('idequipo', idequipo)
          .gte('fecha', inicioMes.toIso8601String());

      // Obtener partidos desde la vista vpartido (incluye hora, campo, escudos, etc.)
      final partidosData = await _supabase
          .from('vpartido')
          .select('id, fecha, hora, rival, goles, golesrival, finalizado, escudorival, casafuera, escudo, campo, equipo')
          .eq('idequipo', idequipo)
          .order('fecha');

      // Obtener escudo y nombre del equipo local
      String escudoLocal = '';
      String nombreEquipoLocal = '';
      try {
        final equipoData = await _supabase
            .from('tequipos')
            .select('idclub, equipo')
            .eq('id', idequipo)
            .single();

        nombreEquipoLocal = equipoData['equipo']?.toString() ?? 'Mi Equipo';

        if (equipoData['idclub'] != null) {
          final clubInfo = await _supabase
              .from('tclubes')
              .select('escudo')
              .eq('id', equipoData['idclub'])
              .single();
          escudoLocal = clubInfo['escudo']?.toString() ?? '';
        }
      } catch (e) {
        debugPrint('EntrenadorDashboard: Error obteniendo escudo local: $e');
      }

      debugPrint('EntrenadorDashboard: Partidos encontrados: ${partidosData.length}');

      // Clasificar partidos por estado de finalizado
      // Solo los partidos FINALIZADOS (finalizado == 1 o true) se consideran para KPIs y gráficas
      final jugados = (partidosData as List).where((p) {
        final finalizado = p['finalizado'];
        // Un partido está "jugado" solo si está marcado como finalizado
        return finalizado == 1 || finalizado == true;
      }).toList();

      // Partidos próximos: NO finalizados (finalizado == 0, false o null)
      final proximos = (partidosData).where((p) {
        final finalizado = p['finalizado'];
        // Un partido es "próximo" si NO está marcado como finalizado
        final esNoFinalizado = finalizado == 0 || finalizado == false || finalizado == null;
        return esNoFinalizado;
      }).toList();

      debugPrint('EntrenadorDashboard: Partidos FINALIZADOS: ${jugados.length}, PRÓXIMOS: ${proximos.length}');

      // Calcular estadísticas de partidos y goles
      // Usar todos los partidos que ya pasaron y tienen goles registrados
      int ganados = 0;
      int empatados = 0;
      int perdidos = 0;
      int golesFavor = 0;
      int golesContra = 0;

      debugPrint('EntrenadorDashboard: Total partidos jugados: ${jugados.length}');

      for (final partido in jugados) {
        // Manejar goles que pueden ser int, String o null
        final golesRaw = partido['goles'];
        final golesRivalRaw = partido['golesrival'];

        int? goles;
        int? golesRival;

        if (golesRaw is int) {
          goles = golesRaw;
        } else if (golesRaw != null) {
          goles = int.tryParse(golesRaw.toString());
        }

        if (golesRivalRaw is int) {
          golesRival = golesRivalRaw;
        } else if (golesRivalRaw != null) {
          golesRival = int.tryParse(golesRivalRaw.toString());
        }

        debugPrint('EntrenadorDashboard: Partido golesRaw=$golesRaw, golesRivalRaw=$golesRivalRaw -> goles=$goles, golesRival=$golesRival');

        // Solo contar partidos que tengan goles registrados (no null)
        if (goles != null && golesRival != null) {
          golesFavor += goles;
          golesContra += golesRival;

          if (goles > golesRival) {
            ganados++;
          } else if (goles < golesRival) {
            perdidos++;
          } else {
            empatados++;
          }
        }
      }

      debugPrint('EntrenadorDashboard: Ganados:$ganados, Empatados:$empatados, Perdidos:$perdidos, Goles F:$golesFavor C:$golesContra');

      // Obtener estadísticas avanzadas
      int totalFaltasFavor = 0;
      int totalFaltasContra = 0;
      int totalCornersFavor = 0;
      int totalCornersContra = 0;
      int totalDisparosFavor = 0;
      int totalDisparosContra = 0;
      int totalDisparosPuertaFavor = 0;
      int totalDisparosPuertaContra = 0;
      int totalFueraJuegoFavor = 0;
      int totalFueraJuegoContra = 0;
      int totalLlegadasFavor = 0;
      int totalLlegadasContra = 0;
      int totalOcasionesFavor = 0;
      int totalOcasionesContra = 0;

      try {
        // Usar solo los partidos finalizados para las estadísticas
        final partidosIds = jugados
            .map((p) => p['id'] as int?)
            .whereType<int>()
            .toList();

        debugPrint('EntrenadorDashboard: Cargando estadísticas para ${partidosIds.length} partidos finalizados');

        if (partidosIds.isNotEmpty) {
          final estadisticasData = await _supabase
              .from('testadisticaspartido')
              .select('faltaf, faltac, cornerf, cornerc, disparosf, disparosc, disparosfap, disparoscap, fjuegof, fjuegoc, llegadasf, llegadasc, ocasionesf, ocasionesc')
              .inFilter('idpartido', partidosIds);

          debugPrint('EntrenadorDashboard: Encontradas ${estadisticasData.length} estadísticas');

          for (final stat in estadisticasData as List) {
            // Helper para convertir a int de forma segura
            int toInt(dynamic value) {
              if (value is int) return value;
              if (value != null) return int.tryParse(value.toString()) ?? 0;
              return 0;
            }

            totalFaltasFavor += toInt(stat['faltaf']);
            totalFaltasContra += toInt(stat['faltac']);
            totalCornersFavor += toInt(stat['cornerf']);
            totalCornersContra += toInt(stat['cornerc']);
            totalDisparosFavor += toInt(stat['disparosf']);
            totalDisparosContra += toInt(stat['disparosc']);
            totalDisparosPuertaFavor += toInt(stat['disparosfap']);
            totalDisparosPuertaContra += toInt(stat['disparoscap']);
            totalFueraJuegoFavor += toInt(stat['fjuegof']);
            totalFueraJuegoContra += toInt(stat['fjuegoc']);
            totalLlegadasFavor += toInt(stat['llegadasf']);
            totalLlegadasContra += toInt(stat['llegadasc']);
            totalOcasionesFavor += toInt(stat['ocasionesf']);
            totalOcasionesContra += toInt(stat['ocasionesc']);
          }

          debugPrint('EntrenadorDashboard: Disparos F:$totalDisparosFavor C:$totalDisparosContra, Corners F:$totalCornersFavor C:$totalCornersContra, Faltas F:$totalFaltasFavor C:$totalFaltasContra');
        }
      } catch (e) {
        debugPrint('EntrenadorDashboard: Error loading advanced stats: $e');
      }

      debugPrint('EntrenadorDashboard: Asignando valores al estado...');
      debugPrint('  - _totalJugadores: ${jugadoresData.length}');
      debugPrint('  - _jugadoresPorPosicion: $jugadoresPorPosicion');
      debugPrint('  - _partidosJugados: ${jugados.length}');
      debugPrint('  - Ganados:$ganados, Empatados:$empatados, Perdidos:$perdidos');
      debugPrint('  - Goles F:$golesFavor, C:$golesContra');
      debugPrint('  - Próximos: ${proximos.length}');

      setState(() {
        _totalJugadores = jugadoresData.length;
        _entrenamientosMes = entrenamientosData.length;
        _partidosJugados = jugados.length;
        _partidosGanados = ganados;
        _partidosEmpatados = empatados;
        _partidosPerdidos = perdidos;
        _totalGolesFavor = golesFavor;
        _totalGolesContra = golesContra;
        _totalFaltasFavor = totalFaltasFavor;
        _totalFaltasContra = totalFaltasContra;
        _totalCornersFavor = totalCornersFavor;
        _totalCornersContra = totalCornersContra;
        _totalDisparosFavor = totalDisparosFavor;
        _totalDisparosContra = totalDisparosContra;
        _totalDisparosPuertaFavor = totalDisparosPuertaFavor;
        _totalDisparosPuertaContra = totalDisparosPuertaContra;
        _totalFueraJuegoFavor = totalFueraJuegoFavor;
        _totalFueraJuegoContra = totalFueraJuegoContra;
        _totalLlegadasFavor = totalLlegadasFavor;
        _totalLlegadasContra = totalLlegadasContra;
        _totalOcasionesFavor = totalOcasionesFavor;
        _totalOcasionesContra = totalOcasionesContra;
        _jugadoresPorPosicion = Map<String, int>.from(jugadoresPorPosicion);
        _proximosPartidos = List<Map<String, dynamic>>.from(proximos.take(3).toList());
        _escudoLocal = escudoLocal;
        _nombreEquipoLocal = nombreEquipoLocal;
        _isLoading = false;
      });

      debugPrint('EntrenadorDashboard: Estado actualizado. _jugadoresPorPosicion=$_jugadoresPorPosicion');
    } catch (e) {
      debugPrint('Error loading Entrenador dashboard: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CELoading.inline();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs superiores
          _buildKpiRow(),
          AppSpacing.vSpaceMd,
          // Grid de gráficos
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Columna izquierda - 2 gráficos
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildResultadosCard()),
                            AppSpacing.hSpaceMd,
                            Expanded(child: _buildGolesCard()),
                          ],
                        ),
                      ),
                      AppSpacing.vSpaceMd,
                      Expanded(child: _buildEstadisticasAvanzadasCard()),
                    ],
                  ),
                ),
                AppSpacing.hSpaceMd,
                // Columna derecha - Jugadores por posición y próximos partidos
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _buildJugadoresPosicionCard()),
                      AppSpacing.vSpaceMd,
                      Expanded(child: _buildProximosPartidosCard()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildKpiCard(Icons.people, 'Jugadores', _totalJugadores.toString())),
          AppSpacing.hSpaceMd,
          Expanded(child: _buildKpiCard(Icons.fitness_center, 'Entrenamientos', _entrenamientosMes.toString(), subtitle: 'este mes')),
          AppSpacing.hSpaceMd,
          Expanded(child: _buildKpiCard(Icons.sports_soccer, 'Partidos', _partidosJugados.toString())),
          AppSpacing.hSpaceMd,
          Expanded(child: _buildKpiCard(Icons.emoji_events, 'Victorias', _partidosGanados.toString())),
        ],
      ),
    );
  }

  Widget _buildKpiCard(IconData icon, String title, String value, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: AppTypography.h4.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w700)),
                Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.gray500)),
                if (subtitle != null) Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosCard() {
    final total = _partidosGanados + _partidosEmpatados + _partidosPerdidos;

    // Colores: verde de la web (ganados), gris (empatados), rojo suave (perdidos)
    final colorGanados = AppColors.primary;
    const colorEmpatados = Color(0xFF9CA3AF); // gray-400
    const colorPerdidos = Color(0xFFE57373); // rojo suave (red-300)

    // Mensaje más descriptivo según el estado
    String emptyMessage;
    if (_partidosJugados == 0) {
      emptyMessage = 'No hay partidos registrados';
    } else if (total == 0) {
      emptyMessage = 'Registra goles en los $_partidosJugados partidos';
    } else {
      emptyMessage = '';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: total == 0
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_soccer_outlined, size: 48, color: AppColors.gray300),
                  AppSpacing.vSpaceSm,
                  Text(emptyMessage, style: AppTypography.bodySmall.copyWith(color: AppColors.gray400), textAlign: TextAlign.center),
                ],
              ),
            )
          : Column(
              children: [
                // Header - flex 1
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Resultados', style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        if (_partidosJugados > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
                            child: Text('$_partidosJugados', style: AppTypography.caption.copyWith(color: AppColors.gray600, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                ),
                // Gráfico - flex 8 (sin padding extra)
                Flexible(
                  flex: 8,
                  fit: FlexFit.tight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calcular el radio máximo basado en las dimensiones disponibles
                      final minDimension = constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                      // Radio del centro (30% del tamaño disponible)
                      final centerRadius = minDimension * 0.25;
                      // Radio del gráfico: (minDimension / 2) - centerRadius - margen
                      final chartRadius = (minDimension / 2) - centerRadius - 4;

                      return PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: centerRadius,
                          sections: [
                            PieChartSectionData(
                              value: _partidosGanados.toDouble(),
                              color: colorGanados,
                              title: '$_partidosGanados',
                              titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                              radius: chartRadius,
                            ),
                            PieChartSectionData(
                              value: _partidosEmpatados.toDouble(),
                              color: colorEmpatados,
                              title: '$_partidosEmpatados',
                              titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                              radius: chartRadius,
                            ),
                            PieChartSectionData(
                              value: _partidosPerdidos.toDouble(),
                              color: colorPerdidos,
                              title: '$_partidosPerdidos',
                              titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                              radius: chartRadius,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Leyenda - flex 1
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem('Ganados', _partidosGanados, colorGanados),
                        _buildLegendItem('Empatados', _partidosEmpatados, colorEmpatados),
                        _buildLegendItem('Perdidos', _partidosPerdidos, colorPerdidos),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        AppSpacing.hSpaceXs,
        Text('$label: $value', style: AppTypography.labelSmall.copyWith(color: AppColors.gray700, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildGolesCard() {
    final colorFavor = AppColors.primary;
    const colorContra = Color(0xFFE57373); // rojo suave (red-300)

    // Calcular medias de goles por partido
    final mediaFavor = _partidosJugados > 0 ? _totalGolesFavor / _partidosJugados : 0.0;
    final mediaContra = _partidosJugados > 0 ? _totalGolesContra / _partidosJugados : 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
            child: Row(
              children: [
                Icon(Icons.sports_soccer, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Goles', style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Goles grandes y expandidos dinámicamente
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcular el tamaño del círculo basado en el espacio disponible
                // Cada círculo ocupa la mitad del ancho (menos el divisor)
                // y debe caber en la altura disponible (menos el texto de etiqueta y media)
                final availableWidth = (constraints.maxWidth - 20) / 2; // -20 por el divisor
                final availableHeight = constraints.maxHeight - 50; // -50 por la etiqueta y media
                final circleSize = availableWidth < availableHeight
                    ? availableWidth * 0.8
                    : availableHeight * 0.8;
                // Tamaño de fuente proporcional al círculo (más grande)
                final fontSize = (circleSize * 0.6).clamp(28.0, 56.0);

                return Row(
                  children: [
                    // A Favor
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: colorFavor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_totalGolesFavor',
                                style: AppTypography.h1.copyWith(color: colorFavor, fontWeight: FontWeight.w800, fontSize: fontSize),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('A FAVOR', style: AppTypography.labelSmall.copyWith(color: colorFavor, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(
                            '${mediaFavor.toStringAsFixed(2)}/partido',
                            style: AppTypography.caption.copyWith(color: colorFavor.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Divisor
                    Container(width: 1, height: constraints.maxHeight * 0.6, color: AppColors.gray200),
                    // En Contra
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: colorContra.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_totalGolesContra',
                                style: AppTypography.h1.copyWith(color: colorContra, fontWeight: FontWeight.w800, fontSize: fontSize),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('EN CONTRA', style: AppTypography.labelSmall.copyWith(color: colorContra, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(
                            '${mediaContra.toStringAsFixed(2)}/partido',
                            style: AppTypography.caption.copyWith(color: colorContra.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasAvanzadasCard() {
    const colorFavor = AppColors.primary;
    const colorContra = Color(0xFFE57373);

    // Lista de estadísticas con sus valores
    final estadisticas = [
      ('Disparos', _totalDisparosFavor, _totalDisparosContra),
      ('T. Puerta', _totalDisparosPuertaFavor, _totalDisparosPuertaContra),
      ('Corners', _totalCornersFavor, _totalCornersContra),
      ('Faltas', _totalFaltasFavor, _totalFaltasContra),
      ('F. Juego', _totalFueraJuegoFavor, _totalFueraJuegoContra),
      ('Llegadas', _totalLlegadasFavor, _totalLlegadasContra),
      ('Ocasiones', _totalOcasionesFavor, _totalOcasionesContra),
    ];

    // Verificar si hay datos
    final hayDatos = estadisticas.any((e) => e.$2 > 0 || e.$3 > 0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Estadísticas Avanzadas', style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendDot('Favor', colorFavor),
                    const SizedBox(width: 8),
                    _buildLegendDot('Contra', colorContra),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Lista de estadísticas
          Expanded(
            child: !hayDatos
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics_outlined, size: 40, color: AppColors.gray300),
                        AppSpacing.vSpaceSm,
                        Text('Registra estadísticas en los partidos', style: AppTypography.bodySmall.copyWith(color: AppColors.gray400), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: estadisticas.length,
                    itemBuilder: (context, index) {
                      final stat = estadisticas[index];
                      return _buildStatRow(stat.$1, stat.$2, stat.$3, colorFavor, colorContra);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int favor, int contra, Color colorFavor, Color colorContra) {
    final maxVal = [favor, contra].reduce((a, b) => a > b ? a : b);
    final showBars = maxVal > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.gray600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          // Barras y valores
          Row(
            children: [
              // Valor Favor
              SizedBox(
                width: 28,
                child: Text('$favor', style: AppTypography.labelSmall.copyWith(color: colorFavor, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
              ),
              const SizedBox(width: 4),
              // Barra Favor
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorFavor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: showBars ? (favor / maxVal) : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorFavor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Barra Contra
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorContra.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: showBars ? (contra / maxVal) : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorContra,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Valor Contra
              SizedBox(
                width: 28,
                child: Text('$contra', style: AppTypography.labelSmall.copyWith(color: colorContra, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJugadoresPosicionCard() {
    final entries = _jugadoresPorPosicion.entries.toList();
    final colors = [AppColors.primary, AppColors.primaryLight, AppColors.accent, AppColors.oliveDark, AppColors.info, AppColors.warning];

    // Mensaje más descriptivo según el estado
    String emptyMessage;
    if (_totalJugadores == 0) {
      emptyMessage = 'Sin jugadores en el equipo';
    } else if (entries.isEmpty) {
      emptyMessage = 'Asigna posiciones a los $_totalJugadores jugadores';
    } else {
      emptyMessage = '';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Jugadores por Posición', style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_totalJugadores > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('$_totalJugadores total', style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 40, color: AppColors.gray300),
                        AppSpacing.vSpaceSm,
                        Text(emptyMessage, style: AppTypography.bodySmall.copyWith(color: AppColors.gray400), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // El gráfico ocupa la mitad izquierda, la leyenda la mitad derecha
                      final chartAreaWidth = constraints.maxWidth / 2;
                      final chartAreaHeight = constraints.maxHeight;

                      // Calcular dimensiones del gráfico
                      final minDimension = chartAreaWidth < chartAreaHeight
                          ? chartAreaWidth
                          : chartAreaHeight;
                      // Radio del centro (25% del tamaño disponible)
                      final centerRadius = minDimension * 0.22;
                      // Radio del gráfico
                      final chartRadius = (minDimension / 2) - centerRadius - 4;

                      return Row(
                        children: [
                          // Gráfico
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: centerRadius,
                                sections: entries.asMap().entries.map((e) {
                                  return PieChartSectionData(
                                    value: e.value.value.toDouble(),
                                    color: colors[e.key % colors.length],
                                    title: '',
                                    radius: chartRadius,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          // Leyenda
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: entries.asMap().entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                                      AppSpacing.hSpaceXs,
                                      Expanded(child: Text(e.value.key, style: AppTypography.caption.copyWith(color: AppColors.gray600), overflow: TextOverflow.ellipsis)),
                                      Text(e.value.value.toString(), style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximosPartidosCard() {
    // Si no hay próximos partidos, mostrar mensaje
    if (_proximosPartidos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.event, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Próximo Partido', style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 40, color: AppColors.gray300),
                    const SizedBox(height: 8),
                    Text('No hay partidos programados', style: AppTypography.bodySmall.copyWith(color: AppColors.gray400), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final partido = _proximosPartidos.first;
    final fecha = DateTime.tryParse(partido['fecha']?.toString() ?? '');
    final rival = partido['rival']?.toString() ?? 'Rival';
    final escudoRival = partido['escudorival']?.toString() ?? '';

    // Campo hora directamente de vpartido (ej: "10:00")
    final horaStr = partido['hora']?.toString() ?? '--:--';

    // Campo campo directamente de vpartido
    final campoPartido = partido['campo']?.toString() ?? 'Por definir';

    // Determinar si es casa o fuera
    final casafueraRaw = partido['casafuera'];
    final bool esVisitante = casafueraRaw == 1 || casafueraRaw == true;

    // Si es visitante, el "local" es el rival
    final escudoLocal = esVisitante ? escudoRival : _escudoLocal;
    final nombreLocal = esVisitante ? rival : _nombreEquipoLocal;
    final nombreVisitante = esVisitante ? _nombreEquipoLocal : rival;
    final escudoVisitante = esVisitante ? _escudoLocal : escudoRival;

    // Formatear fecha
    String diaStr = 'Por definir';
    if (fecha != null) {
      final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      diaStr = '${dias[fecha.weekday - 1]} ${fecha.day}/${fecha.month}/${fecha.year}';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header - Flex 1
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event, color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'PRÓXIMO PARTIDO',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Escudos - Flex 4
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Escudo Local
                  Expanded(
                    child: _buildEscudoWidget(escudoLocal, isLocal: true),
                  ),
                  // VS con hora debajo - MÁS GRANDE Y VISIBLE
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'VS',
                          style: AppTypography.h6.copyWith(
                            color: AppColors.gray700,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Hora destacada - MÁS GRANDE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, color: AppColors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              horaStr,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Escudo Visitante
                  Expanded(
                    child: _buildEscudoWidget(escudoVisitante, isLocal: false),
                  ),
                ],
              ),
            ),
          ),
          // Nombres equipos - Flex 2
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nombreLocal.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: Text(
                      nombreVisitante.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Día - Flex 2
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    diaStr,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Campo - Flex 2
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      campoPartido,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscudoWidget(String escudoUrl, {required bool isLocal}) {
    final placeholderIcon = isLocal
        ? Icon(Icons.shield, color: AppColors.primary, size: 48)
        : Icon(Icons.shield_outlined, color: AppColors.gray400, size: 48);

    if (escudoUrl.isEmpty) {
      return Center(child: placeholderIcon);
    }

    return Center(
      child: Image.network(
        escudoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => placeholderIcon,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLocal ? AppColors.primary : AppColors.gray400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        AppSpacing.hSpaceXs,
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.gray600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          AppSpacing.vSpaceMd,
          Text('Error al cargar datos', style: AppTypography.h6),
          AppSpacing.vSpaceSm,
          Text(_error ?? 'Error desconocido', style: AppTypography.bodySmall),
          AppSpacing.vSpaceMd,
          ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
