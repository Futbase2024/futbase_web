import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/shared_widgets.dart';

/// Dashboard para administradores de Club con estadísticas agregadas de todos sus equipos
class ClubDashboard extends StatefulWidget {
  const ClubDashboard({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<ClubDashboard> createState() => _ClubDashboardState();
}

class _ClubDashboardState extends State<ClubDashboard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;

  // Datos del club
  String _clubName = '';
  int _totalEquipos = 0;
  int _totalJugadores = 0;
  int _totalEntrenamientos = 0;
  int _totalPartidos = 0;

  // Estadísticas de partidos (agregadas de todos los equipos)
  int _partidosGanados = 0;
  int _partidosEmpatados = 0;
  int _partidosPerdidos = 0;

  // Total de goles
  int _totalGolesFavor = 0;
  int _totalGolesContra = 0;

  // Lista de equipos del club
  List<Map<String, dynamic>> _equipos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final idclub = widget.user.idclub;
      if (idclub == 0) {
        setState(() {
          _error = 'No tienes un club asignado';
          _isLoading = false;
        });
        return;
      }

      // Obtener nombre del club
      final clubData = await _supabase
          .from('tclubes')
          .select('club')
          .eq('id', idclub)
          .maybeSingle();

      // Obtener equipos del club
      final equiposData = await _supabase
          .from('tequipos')
          .select('id, equipo, idcategoria')
          .eq('idclub', idclub);

      // Obtener IDs de equipos para consultas relacionadas
      final equipoIds = (equiposData as List)
          .map((e) => e['id'] as int)
          .toList();

      if (equipoIds.isEmpty) {
        setState(() {
          _clubName = clubData?['club'] ?? 'Club desconocido';
          _totalEquipos = 0;
          _totalJugadores = 0;
          _totalEntrenamientos = 0;
          _totalPartidos = 0;
          _equipos = [];
          _isLoading = false;
        });
        return;
      }

      // Contar jugadores de todos los equipos (incluye idequipo para agrupar)
      final jugadoresData = await _supabase
          .from('tjugadores')
          .select('id, idequipo')
          .inFilter('idequipo', equipoIds);

      // Contar jugadores por equipo
      final jugadoresPorEquipo = <int, int>{};
      for (final jugador in jugadoresData as List) {
        final idequipo = jugador['idequipo'] as int;
        jugadoresPorEquipo[idequipo] = (jugadoresPorEquipo[idequipo] ?? 0) + 1;
      }

      // Obtener entrenamientos de todos los equipos
      final entrenamientosData = await _supabase
          .from('tentrenamientos')
          .select('id')
          .inFilter('idequipo', equipoIds);

      // Obtener partidos de todos los equipos desde la vista vpartido
      final partidosData = await _supabase
          .from('vpartido')
          .select('id, goles, golesrival, finalizado')
          .inFilter('idequipo', equipoIds);

      // Clasificar partidos: solo los finalizados cuentan para estadísticas
      final jugados = (partidosData as List).where((p) {
        final finalizado = p['finalizado'];
        return finalizado == 1 || finalizado == true;
      }).toList();

      // Calcular estadísticas de partidos y goles
      int ganados = 0;
      int empatados = 0;
      int perdidos = 0;
      int golesFavor = 0;
      int golesContra = 0;

      for (final partido in jugados) {
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

        // Solo contar partidos que tengan goles registrados
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

      // Obtener categorías para mostrar en la lista de equipos
      final categoriasData = await _supabase
          .from('tcategorias')
          .select('id, categoria');

      final categoriasMap = <int, String>{};
      for (final cat in categoriasData as List) {
        categoriasMap[cat['id'] as int] = cat['categoria'] as String;
      }

      // Enriquecer lista de equipos con nombre de categoría y número de jugadores
      final equiposEnriquecidos = equiposData.map((e) {
        final equipoId = e['id'] as int;
        final idCategoria = e['idcategoria'] as int?;
        return {
          'id': equipoId,
          'equipo': e['equipo'],
          'categoria': idCategoria != null ? categoriasMap[idCategoria] ?? '-' : '-',
          'numJugadores': jugadoresPorEquipo[equipoId] ?? 0,
        };
      }).toList();

      setState(() {
        _clubName = clubData?['club'] ?? 'Club desconocido';
        _totalEquipos = equiposData.length;
        _totalJugadores = jugadoresData.length;
        _totalEntrenamientos = entrenamientosData.length;
        _totalPartidos = jugados.length;
        _partidosGanados = ganados;
        _partidosEmpatados = empatados;
        _partidosPerdidos = perdidos;
        _totalGolesFavor = golesFavor;
        _totalGolesContra = golesContra;
        _equipos = List<Map<String, dynamic>>.from(equiposEnriquecidos);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading Club dashboard: $e');
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
          // Fila de gráficos y resumen (misma altura)
          SizedBox(
            height: 280,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Resultados
                Expanded(child: _buildResultadosCard()),
                AppSpacing.hSpaceMd,
                // Goles
                Expanded(child: _buildGolesCard()),
                AppSpacing.hSpaceMd,
                // Resumen del club (misma altura que Resultados y Goles)
                Expanded(child: _buildResumenClubCard()),
              ],
            ),
          ),
          AppSpacing.vSpaceMd,
          // Equipos del club - Todo el ancho (solo lectura)
          Expanded(child: _buildEquiposListCard()),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildKpiCard(Icons.groups, 'Equipos', _totalEquipos.toString())),
          AppSpacing.hSpaceMd,
          Expanded(child: _buildKpiCard(Icons.people, 'Jugadores', _totalJugadores.toString())),
          AppSpacing.hSpaceMd,
          Expanded(child: _buildKpiCard(Icons.fitness_center, 'Entrenamientos', _totalEntrenamientos.toString())),
          AppSpacing.hSpaceMd,
          Expanded(child: _buildKpiCard(Icons.sports_soccer, 'Partidos', _totalPartidos.toString())),
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

    final colorGanados = AppColors.primary;
    const colorEmpatados = Color(0xFF9CA3AF);
    const colorPerdidos = Color(0xFFE57373);

    String emptyMessage;
    if (_totalPartidos == 0) {
      emptyMessage = 'No hay partidos registrados';
    } else if (total == 0) {
      emptyMessage = 'Registra goles en los $_totalPartidos partidos';
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
                        if (_totalPartidos > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
                            child: Text('$_totalPartidos', style: AppTypography.caption.copyWith(color: AppColors.gray600, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 8,
                  fit: FlexFit.tight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final minDimension = constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                      final centerRadius = minDimension * 0.25;
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
    const colorContra = Color(0xFFE57373);

    final mediaFavor = _totalPartidos > 0 ? _totalGolesFavor / _totalPartidos : 0.0;
    final mediaContra = _totalPartidos > 0 ? _totalGolesContra / _totalPartidos : 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
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
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = (constraints.maxWidth - 20) / 2;
                final availableHeight = constraints.maxHeight - 50;
                final circleSize = availableWidth < availableHeight
                    ? availableWidth * 0.8
                    : availableHeight * 0.8;
                final fontSize = (circleSize * 0.6).clamp(28.0, 56.0);

                return Row(
                  children: [
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
                    Container(width: 1, height: constraints.maxHeight * 0.6, color: AppColors.gray200),
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

  Widget _buildEquiposListCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups_outlined, color: AppColors.primary, size: 18),
              ),
              AppSpacing.hSpaceSm,
              Text('Equipos del Club', style: AppTypography.labelLarge.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalEquipos ${_totalEquipos == 1 ? 'equipo' : 'equipos'}',
                  style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          // Grid de equipos
          Expanded(
            child: _equipos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups_outlined, size: 48, color: AppColors.gray300),
                        AppSpacing.vSpaceSm,
                        Text('No hay equipos registrados', style: AppTypography.bodySmall.copyWith(color: AppColors.gray400), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: _equipos.length,
                    itemBuilder: (context, index) {
                      final equipo = _equipos[index];
                      return _buildEquipoCard(equipo);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoCard(Map<String, dynamic> equipo) {
    final nombreEquipo = equipo['equipo']?.toString() ?? 'Sin nombre';
    final categoria = equipo['categoria']?.toString() ?? '-';
    final numJugadores = equipo['numJugadores'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          // Flex 7: Icono + Nombre y Categoría
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.sports_soccer, color: AppColors.primary, size: 16),
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nombreEquipo,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        categoria,
                        style: AppTypography.caption.copyWith(color: AppColors.gray500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Línea de separación
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: AppColors.gray200,
          ),
          // Flex 3: Nº Jugadores
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Nº Jugadores: $numJugadores',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenClubCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.gray900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre del club
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: AppColors.primary, size: 18),
              ),
              AppSpacing.hSpaceSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_clubName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                    Text('Panel de administración', style: AppTypography.caption.copyWith(color: AppColors.gray500)),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          // Resumen de actividad
          Text('Resumen de Actividad', style: AppTypography.labelSmall.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
          AppSpacing.vSpaceSm,
          _buildResumenItem(
            icon: Icons.groups,
            label: 'Total Equipos',
            value: _totalEquipos.toString(),
            color: AppColors.primary,
          ),
          AppSpacing.vSpaceXs,
          _buildResumenItem(
            icon: Icons.people,
            label: 'Total Jugadores',
            value: _totalJugadores.toString(),
            color: AppColors.success,
          ),
          AppSpacing.vSpaceXs,
          _buildResumenItem(
            icon: Icons.fitness_center,
            label: 'Entrenamientos',
            value: _totalEntrenamientos.toString(),
            color: AppColors.info,
          ),
          AppSpacing.vSpaceXs,
          _buildResumenItem(
            icon: Icons.sports_soccer,
            label: 'Partidos Jugados',
            value: _totalPartidos.toString(),
            color: AppColors.warning,
          ),
          // Ratio victorias
          if (_totalPartidos > 0) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ratio Victorias', style: AppTypography.labelSmall.copyWith(color: AppColors.gray500)),
                Text(
                  '${(_partidosGanados / _totalPartidos * 100).toStringAsFixed(0)}%',
                  style: AppTypography.h6.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        AppSpacing.hSpaceSm,
        Expanded(
          child: Text(label, style: AppTypography.caption.copyWith(color: AppColors.gray600)),
        ),
        Text(value, style: AppTypography.labelMedium.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w600)),
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
