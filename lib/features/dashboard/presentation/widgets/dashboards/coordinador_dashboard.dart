import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Dashboard para Coordinadores con estadísticas de las categorías que coordina
class CoordinadorDashboard extends StatefulWidget {
  const CoordinadorDashboard({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<CoordinadorDashboard> createState() => _CoordinadorDashboardState();
}

class _CoordinadorDashboardState extends State<CoordinadorDashboard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;

  // Datos
  String _clubName = '';
  int _totalEquipos = 0;
  int _totalJugadores = 0;
  int _totalEntrenadores = 0;
  int _entrenamientosSemana = 0;
  int _partidosProximos = 0;

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
          .eq('idclub', idclub)
          .order('idcategoria');

      final equipoIds = (equiposData as List)
          .map((e) => e['id'] as int)
          .toList();

      // Contar jugadores
      int totalJugadores = 0;
      if (equipoIds.isNotEmpty) {
        final jugadoresData = await _supabase
            .from('tjugadores')
            .select('id')
            .inFilter('idequipo', equipoIds);
        totalJugadores = jugadoresData.length;
      }

      // Contar entrenadores del club
      final entrenadoresData = await _supabase
          .from('tusuarios')
          .select('id')
          .eq('idclub', idclub)
          .inFilter('permisos', [2, 9]); // Entrenadores y coordinadores

      // Contar entrenamientos de la semana
      int entrenamientosSemana = 0;
      if (equipoIds.isNotEmpty) {
        final hace7Dias = DateTime.now().subtract(const Duration(days: 7));
        final entrenamientosData = await _supabase
            .from('tentrenamientos')
            .select('id')
            .inFilter('idequipo', equipoIds)
            .gte('fecha', hace7Dias.toIso8601String());
        entrenamientosSemana = entrenamientosData.length;
      }

      // Contar partidos próximos
      int partidosProximos = 0;
      if (equipoIds.isNotEmpty) {
        final partidosData = await _supabase
            .from('tpartidos')
            .select('id, fecha')
            .inFilter('idequipo', equipoIds);

        final ahora = DateTime.now();
        partidosProximos = (partidosData as List).where((p) {
          final fecha = DateTime.tryParse(p['fecha']?.toString() ?? '');
          return fecha != null && fecha.isAfter(ahora);
        }).length;
      }

      setState(() {
        _clubName = clubData?['club'] ?? 'Club';
        _totalEquipos = equiposData.length;
        _totalJugadores = totalJugadores;
        _totalEntrenadores = entrenadoresData.length;
        _entrenamientosSemana = entrenamientosSemana;
        _partidosProximos = partidosProximos;
        _equipos = List<Map<String, dynamic>>.from(equiposData);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading Coordinador dashboard: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_alt,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              AppSpacing.hSpaceMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_clubName, style: AppTypography.h4),
                  Text(
                    'Panel de Coordinación',
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

          // Resumen y equipos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildEquiposCard()),
              AppSpacing.hSpaceLg,
              Expanded(child: _buildResumenCard()),
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
          icon: Icons.sports,
          title: 'Entrenadores',
          value: _totalEntrenadores.toString(),
          color: AppColors.info,
        ),
        _buildKpiCard(
          icon: Icons.fitness_center,
          title: 'Entrenamientos',
          value: _entrenamientosSemana.toString(),
          subtitle: 'esta semana',
          color: AppColors.warning,
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
      width: 220,
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
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
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquiposCard() {
    // Agrupar equipos por categoría
    final categorias = <int, List<Map<String, dynamic>>>{};
    for (final equipo in _equipos) {
      final cat = equipo['idcategoria'] as int? ?? 0;
      categorias.putIfAbsent(cat, () => []).add(equipo);
    }

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
              Text('Equipos por Categoría', style: AppTypography.h6),
              Text(
                '${categorias.length} categorías',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          if (categorias.isEmpty)
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
            ...categorias.entries.map((entry) {
              final catId = entry.key;
              final equiposCat = entry.value;

              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Categoría $catId',
                  style: AppTypography.labelMedium,
                ),
                subtitle: Text(
                  '${equiposCat.length} equipos',
                  style: AppTypography.caption,
                ),
                children: equiposCat.map((equipo) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 16),
                    leading: const Icon(
                      Icons.sports_soccer,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      equipo['equipo'] ?? 'Sin nombre',
                      style: AppTypography.labelSmall,
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () {},
                  );
                }).toList(),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
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
          Text('Resumen de Actividad', style: AppTypography.h6),
          AppSpacing.vSpaceMd,
          _buildResumenItem(
            icon: Icons.event,
            title: 'Próximos partidos',
            value: _partidosProximos.toString(),
            color: AppColors.warning,
          ),
          AppSpacing.vSpaceMd,
          _buildResumenItem(
            icon: Icons.fitness_center,
            title: 'Entrenamientos semanales',
            value: _entrenamientosSemana.toString(),
            color: AppColors.success,
          ),
          AppSpacing.vSpaceMd,
          _buildResumenItem(
            icon: Icons.people,
            title: 'Total deportistas',
            value: _totalJugadores.toString(),
            color: AppColors.info,
          ),
          AppSpacing.vSpaceMd,
          _buildResumenItem(
            icon: Icons.sports,
            title: 'Cuerpo técnico',
            value: _totalEntrenadores.toString(),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem({
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
