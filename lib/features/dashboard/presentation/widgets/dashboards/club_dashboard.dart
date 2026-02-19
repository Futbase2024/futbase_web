import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/shared_widgets.dart';

/// Dashboard para administradores de Club con estadísticas de su club
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
  int _entrenamientosSemana = 0;
  int _partidosProximos = 0;
  int _golesTemporada = 0;
  int _partidosFinalizadosTemporada = 0;
  double _golesPorPartido = 0.0;

  // Lista de equipos
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

      // Contar jugadores del club
      int totalJugadores = 0;
      if (equipoIds.isNotEmpty) {
        final jugadoresData = await _supabase
            .from('tjugadores')
            .select('id')
            .inFilter('idequipo', equipoIds);
        totalJugadores = jugadoresData.length;
      }

      // Contar entrenamientos del club (últimos 30 días)
      int totalEntrenamientos = 0;
      int entrenamientosSemana = 0;
      if (equipoIds.isNotEmpty) {
        final entrenamientosData = await _supabase
            .from('tentrenamientos')
            .select('id, fecha')
            .inFilter('idequipo', equipoIds);
        totalEntrenamientos = entrenamientosData.length;

        // Entrenamientos de la última semana
        final hace7Dias = DateTime.now().subtract(const Duration(days: 7));
        entrenamientosSemana = (entrenamientosData as List).where((e) {
          final fecha = DateTime.tryParse(e['fecha']?.toString() ?? '');
          return fecha != null && fecha.isAfter(hace7Dias);
        }).length;
      }

      // Contar partidos del club
      int totalPartidos = 0;
      int partidosProximos = 0;
      int golesTemporada = 0;
      int partidosFinalizadosTemporada = 0;

      if (equipoIds.isNotEmpty) {
        final partidosData = await _supabase
            .from('vpartido')
            .select('id, fecha')
            .inFilter('idequipo', equipoIds);
        totalPartidos = partidosData.length;

        // Partidos próximos
        final ahora = DateTime.now();
        partidosProximos = (partidosData as List).where((e) {
          final fecha = DateTime.tryParse(e['fecha']?.toString() ?? '');
          return fecha != null && fecha.isAfter(ahora);
        }).length;

        // Obtener temporada actual para calcular goles por partido
        final configData = await _supabase
            .from('tconfig')
            .select('idtemporada')
            .limit(1)
            .maybeSingle();

        if (configData != null) {
          final idTemporadaActual = configData['idtemporada'] as int?;

          if (idTemporadaActual != null) {
            // Obtener partidos finalizados de la temporada actual con datos de goles
            final partidosTemporadaData = await _supabase
                .from('vpartido')
                .select('id, casafuera, goles, golesrival, finalizado')
                .inFilter('idequipo', equipoIds)
                .eq('idtemporada', idTemporadaActual)
                .eq('finalizado', true);

            for (final partido in partidosTemporadaData as List) {
              // En vpartido, 'goles' siempre son los goles del equipo
              // y 'golesrival' los del rival, independientemente de local/visitante
              final golesEquipo = partido['goles'] as int? ?? 0;
              golesTemporada += golesEquipo;
              partidosFinalizadosTemporada++;
            }
          }
        }
      }

      // Calcular goles por partido
      final golesPorPartido = partidosFinalizadosTemporada > 0
          ? golesTemporada / partidosFinalizadosTemporada
          : 0.0;

      setState(() {
        _clubName = clubData?['club'] ?? 'Club desconocido';
        _totalEquipos = equiposData.length;
        _totalJugadores = totalJugadores;
        _totalEntrenamientos = totalEntrenamientos;
        _totalPartidos = totalPartidos;
        _entrenamientosSemana = entrenamientosSemana;
        _partidosProximos = partidosProximos;
        _golesTemporada = golesTemporada;
        _partidosFinalizadosTemporada = partidosFinalizadosTemporada;
        _golesPorPartido = golesPorPartido;
        _equipos = List<Map<String, dynamic>>.from(equiposData);
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              AppSpacing.hSpaceMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_clubName, style: AppTypography.h4),
                  Text(
                    'Panel de administración del club',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vSpaceXl,

          // KPIs
          _buildKpiRow(),
          AppSpacing.vSpaceXl,

          // Equipos y actividad reciente
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildEquiposList()),
              AppSpacing.hSpaceLg,
              Expanded(child: _buildActividadCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildKpiCard(
          icon: Icons.groups,
          title: 'Equipos',
          value: _totalEquipos.toString(),
          color: AppColors.primary,
        ),
        _buildKpiCard(
          icon: Icons.person,
          title: 'Jugadores',
          value: _totalJugadores.toString(),
          color: AppColors.success,
        ),
        _buildKpiCard(
          icon: Icons.fitness_center,
          title: 'Entrenamientos',
          value: _totalEntrenamientos.toString(),
          subtitle: '+$_entrenamientosSemana esta semana',
          color: AppColors.info,
        ),
        _buildKpiCard(
          icon: Icons.sports_soccer,
          title: 'Partidos',
          value: _totalPartidos.toString(),
          subtitle: '$_partidosProximos próximos',
          color: AppColors.warning,
        ),
        _buildKpiCard(
          icon: Icons.sports_score,
          title: 'Goles por Partido',
          value: _golesPorPartido.toStringAsFixed(1),
          subtitle: '$_golesTemporada goles en $_partidosFinalizadosTemporada partidos',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          AppSpacing.hSpaceLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.gray900,
                    height: 1.0,
                  ),
                ),
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquiposList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mis Equipos', style: AppTypography.h6),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo'),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          if (_equipos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 48,
                      color: AppColors.gray300,
                    ),
                    AppSpacing.vSpaceMd,
                    Text(
                      'No hay equipos registrados',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _equipos.length > 10 ? 10 : _equipos.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final equipo = _equipos[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    equipo['equipo'] ?? 'Sin nombre',
                    style: AppTypography.labelMedium,
                  ),
                  subtitle: Text(
                    'Categoría: ${equipo['idcategoria'] ?? '-'}',
                    style: AppTypography.caption,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActividadCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actividad Reciente', style: AppTypography.h6),
          AppSpacing.vSpaceMd,
          _buildActividadItem(
            icon: Icons.fitness_center,
            title: 'Entrenamientos',
            value: '$_entrenamientosSemana esta semana',
            color: AppColors.info,
          ),
          AppSpacing.vSpaceMd,
          _buildActividadItem(
            icon: Icons.sports_soccer,
            title: 'Próximos partidos',
            value: '$_partidosProximos programados',
            color: AppColors.warning,
          ),
          AppSpacing.vSpaceMd,
          _buildActividadItem(
            icon: Icons.people,
            title: 'Jugadores activos',
            value: _totalJugadores.toString(),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActividadItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        AppSpacing.hSpaceMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelSmall),
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
