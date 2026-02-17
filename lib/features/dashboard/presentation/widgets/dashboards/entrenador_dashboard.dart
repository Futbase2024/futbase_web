import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

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
  String _equipoName = '';
  String _clubName = '';
  int _totalJugadores = 0;
  int _entrenamientosMes = 0;
  int _partidosProximos = 0;
  int _partidosJugados = 0;

  // Lista de jugadores
  List<Map<String, dynamic>> _jugadores = [];

  // Próximos partidos
  List<Map<String, dynamic>> _proximosPartidos = [];

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

      final idequipo = widget.user.idequipo;
      if (idequipo == 0) {
        setState(() {
          _error = 'No tienes un equipo asignado';
          _isLoading = false;
        });
        return;
      }

      // Obtener datos del equipo
      final equipoData = await _supabase
          .from('tequipos')
          .select('id, equipo, idclub')
          .eq('id', idequipo)
          .maybeSingle();

      if (equipoData == null) {
        setState(() {
          _error = 'Equipo no encontrado';
          _isLoading = false;
        });
        return;
      }

      // Obtener nombre del club
      final clubData = await _supabase
          .from('tclubes')
          .select('club')
          .eq('id', equipoData['idclub'])
          .maybeSingle();

      // Obtener jugadores del equipo
      final jugadoresData = await _supabase
          .from('tjugadores')
          .select('id, nombre, apellidos, dorsal, posicion')
          .eq('idequipo', idequipo)
          .order('nombre');

      // Obtener entrenamientos del mes
      final inicioMes = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final entrenamientosData = await _supabase
          .from('tentrenamientos')
          .select('id')
          .eq('idequipo', idequipo)
          .gte('fecha', inicioMes.toIso8601String());

      // Obtener partidos
      final partidosData = await _supabase
          .from('tpartidos')
          .select('id, fecha, rival, local')
          .eq('idequipo', idequipo)
          .order('fecha');

      final ahora = DateTime.now();
      final proximos = (partidosData as List).where((p) {
        final fecha = DateTime.tryParse(p['fecha']?.toString() ?? '');
        return fecha != null && fecha.isAfter(ahora);
      }).toList();

      final jugados = (partidosData as List).where((p) {
        final fecha = DateTime.tryParse(p['fecha']?.toString() ?? '');
        return fecha != null && fecha.isBefore(ahora);
      }).toList();

      setState(() {
        _equipoName = equipoData['equipo'] ?? 'Equipo';
        _clubName = clubData?['club'] ?? 'Club';
        _totalJugadores = jugadoresData.length;
        _entrenamientosMes = entrenamientosData.length;
        _partidosProximos = proximos.length;
        _partidosJugados = jugados.length;
        _jugadores = List<Map<String, dynamic>>.from(jugadoresData);
        _proximosPartidos = List<Map<String, dynamic>>.from(proximos.take(5).toList());
        _isLoading = false;
      });
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              AppSpacing.hSpaceMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_equipoName, style: AppTypography.h4),
                  Text(
                    '$_clubName • Tu equipo',
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

          // Plantilla y próximos partidos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPlantillaCard()),
              AppSpacing.hSpaceLg,
              Expanded(child: _buildProximosPartidosCard()),
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
          icon: Icons.person,
          title: 'Jugadores',
          value: _totalJugadores.toString(),
          color: AppColors.primary,
        ),
        _buildKpiCard(
          icon: Icons.fitness_center,
          title: 'Entrenamientos',
          value: _entrenamientosMes.toString(),
          subtitle: 'este mes',
          color: AppColors.success,
        ),
        _buildKpiCard(
          icon: Icons.sports_soccer,
          title: 'Partidos jugados',
          value: _partidosJugados.toString(),
          color: AppColors.info,
        ),
        _buildKpiCard(
          icon: Icons.event,
          title: 'Próximos partidos',
          value: _partidosProximos.toString(),
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

  Widget _buildPlantillaCard() {
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
              Text('Plantilla', style: AppTypography.h6),
              Text(
                '$_totalJugadores jugadores',
                style: AppTypography.caption.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceMd,
          if (_jugadores.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.gray300,
                    ),
                    AppSpacing.vSpaceMd,
                    Text(
                      'No hay jugadores en la plantilla',
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
              itemCount: _jugadores.length > 8 ? 8 : _jugadores.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final jugador = _jugadores[index];
                final dorsal = jugador['dorsal']?.toString() ?? '-';
                final posicion = jugador['posicion']?.toString() ?? '';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        dorsal,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${jugador['nombre'] ?? ''} ${jugador['apellidos'] ?? ''}',
                    style: AppTypography.labelMedium,
                  ),
                  subtitle: posicion.isNotEmpty
                      ? Text(posicion, style: AppTypography.caption)
                      : null,
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {},
                );
              },
            ),
          if (_jugadores.length > 8)
            TextButton(
              onPressed: () {},
              child: const Text('Ver todos los jugadores'),
            ),
        ],
      ),
    );
  }

  Widget _buildProximosPartidosCard() {
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
          Text('Próximos Partidos', style: AppTypography.h6),
          AppSpacing.vSpaceMd,
          if (_proximosPartidos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 40,
                      color: AppColors.gray300,
                    ),
                    AppSpacing.vSpaceSm,
                    Text(
                      'No hay partidos programados',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_proximosPartidos.map((partido) {
              final fecha = DateTime.tryParse(partido['fecha']?.toString() ?? '');
              final fechaStr = fecha != null
                  ? '${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
                  : 'Por definir';
              final rival = partido['rival']?.toString() ?? 'Rival';
              final local = partido['local'] == true || partido['local'] == 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: local
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        local ? 'CASA' : 'FUERA',
                        style: AppTypography.overline.copyWith(
                          color: local ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppSpacing.hSpaceSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs $rival',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            fechaStr,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })),
        ],
      ),
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
