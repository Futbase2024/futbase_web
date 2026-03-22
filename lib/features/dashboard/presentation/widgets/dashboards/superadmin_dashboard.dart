import 'package:flutter/material.dart';
import '../../../../../core/datasources/datasource_factory.dart';
import '../../../../../core/datasources/app_datasource.dart';
import '../../../../../core/datasources/api_response.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/shared_widgets.dart';

/// Dashboard para SuperAdmin con estadísticas globales del sistema
class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final AppDataSource _dataSource = DataSourceFactory.instance;

  bool _isLoading = true;
  String? _error;

  // Estadísticas globales
  int _totalClubs = 0;
  int _totalUsuarios = 0;
  int _totalEquipos = 0;
  int _totalJugadores = 0;
  int _totalEntrenamientos = 0;
  int _totalPartidos = 0;
  int _totalCuotas = 0;

  // Datos por categoría
  List<Map<String, dynamic>> _equiposPorCategoria = [];
  List<Map<String, dynamic>> _usuariosPorPermiso = [];

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

      // Cargar estadísticas globales en paralelo
      final results = await Future.wait([
        _dataSource.getGlobalCountClubs(),
        _dataSource.getGlobalCountUsuarios(),
        _dataSource.getGlobalCountEquipos(),
        _dataSource.getGlobalCountJugadores(),
        _dataSource.getGlobalCountEntrenamientos(),
        _dataSource.getGlobalCountPartidos(),
        _dataSource.getGlobalCountCuotas(),
        _dataSource.getEquiposPorCategoriaGlobal(),
        _dataSource.getUsuariosPorPermisoGlobal(),
      ]);

      final clubsResponse = results[0] as ApiResponse<int>;
      final usuariosResponse = results[1] as ApiResponse<int>;
      final equiposResponse = results[2] as ApiResponse<int>;
      final jugadoresResponse = results[3] as ApiResponse<int>;
      final entrenamientosResponse = results[4] as ApiResponse<int>;
      final partidosResponse = results[5] as ApiResponse<int>;
      final cuotasResponse = results[6] as ApiResponse<int>;
      final equiposCategoriaResponse = results[7] as ApiResponse<List<Map<String, dynamic>>>;
      final usuariosPermisoResponse = results[8] as ApiResponse<List<Map<String, dynamic>>>;

      setState(() {
        _totalClubs = clubsResponse.success ? clubsResponse.data ?? 0 : 0;
        _totalUsuarios = usuariosResponse.success ? usuariosResponse.data ?? 0 : 0;
        _totalEquipos = equiposResponse.success ? equiposResponse.data ?? 0 : 0;
        _totalJugadores = jugadoresResponse.success ? jugadoresResponse.data ?? 0 : 0;
        _totalEntrenamientos = entrenamientosResponse.success ? entrenamientosResponse.data ?? 0 : 0;
        _totalPartidos = partidosResponse.success ? partidosResponse.data ?? 0 : 0;
        _totalCuotas = cuotasResponse.success ? cuotasResponse.data ?? 0 : 0;
        _equiposPorCategoria = equiposCategoriaResponse.success
            ? equiposCategoriaResponse.data ?? <Map<String, dynamic>>[]
            : <Map<String, dynamic>>[];
        _usuariosPorPermiso = usuariosPermisoResponse.success
            ? usuariosPermisoResponse.data ?? <Map<String, dynamic>>[]
            : <Map<String, dynamic>>[];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading SuperAdmin dashboard: $e');
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              AppSpacing.hSpaceMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel de Super Administrador', style: AppTypography.h4),
                  Text(
                    'Estadísticas globales del sistema',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vSpaceXl,

          // KPIs principales
          _buildKpiGrid(),
          AppSpacing.vSpaceXl,

          // Gráficos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildUsuariosPorRolCard()),
              AppSpacing.hSpaceLg,
              Expanded(child: _buildEquiposPorCategoriaCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
            _buildKpiCard(
              icon: Icons.business,
              title: 'Clubs',
              value: _totalClubs.toString(),
              color: AppColors.primary,
            ),
            _buildKpiCard(
              icon: Icons.people,
              title: 'Usuarios',
              value: _totalUsuarios.toString(),
              color: AppColors.info,
            ),
            _buildKpiCard(
              icon: Icons.groups,
              title: 'Equipos',
              value: _totalEquipos.toString(),
              color: AppColors.success,
            ),
            _buildKpiCard(
              icon: Icons.person,
              title: 'Jugadores',
              value: _totalJugadores.toString(),
              color: AppColors.warning,
            ),
            _buildKpiCard(
              icon: Icons.fitness_center,
              title: 'Entrenamientos',
              value: _totalEntrenamientos.toString(),
              color: AppColors.primary,
            ),
            _buildKpiCard(
              icon: Icons.sports_soccer,
              title: 'Partidos',
              value: _totalPartidos.toString(),
              color: AppColors.success,
            ),
            _buildKpiCard(
              icon: Icons.payments,
              title: 'Cuotas',
              value: _totalCuotas.toString(),
              color: AppColors.warning,
            ),
          ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.h3.copyWith(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsuariosPorRolCard() {
    final rolesMap = {
      1: 'SuperAdmin',
      2: 'Entrenador',
      3: 'Club',
      10: 'Coordinador',
      16: 'Jugador/Familiar',
    };

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
          Text('Usuarios por Rol', style: AppTypography.h6),
          AppSpacing.vSpaceMd,
          ..._usuariosPorPermiso.take(5).map((item) {
            final permiso = item['permiso'] as int;
            final total = item['total'] as int;
            final percentage = _totalUsuarios > 0
                ? (total / _totalUsuarios * 100).toStringAsFixed(1)
                : '0';
            final roleName = rolesMap[permiso] ?? 'Rol $permiso';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(roleName, style: AppTypography.labelSmall),
                        AppSpacing.vSpaceXs,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total / (_totalUsuarios > 0 ? _totalUsuarios : 1),
                            backgroundColor: AppColors.gray100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Text(
                    '$total ($percentage%)',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEquiposPorCategoriaCard() {
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
          Text('Equipos por Categoría', style: AppTypography.h6),
          AppSpacing.vSpaceMd,
          ..._equiposPorCategoria.take(6).map((item) {
            final categoria = item['categoria'] as int;
            final total = item['total'] as int;
            final percentage = _totalEquipos > 0
                ? (total / _totalEquipos * 100).toStringAsFixed(1)
                : '0';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoría $categoria',
                          style: AppTypography.labelSmall,
                        ),
                        AppSpacing.vSpaceXs,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total / (_totalEquipos > 0 ? _totalEquipos : 1),
                            backgroundColor: AppColors.gray100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.success,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Text(
                    '$total ($percentage%)',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            );
          }),
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
