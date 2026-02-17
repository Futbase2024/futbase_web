import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/user_roles.dart';
import '../widgets/widgets.dart';
import '../widgets/dashboards/dashboards.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';

/// Página principal del Dashboard
///
/// Layout completo con sidebar, header y contenido principal
/// Muestra diferentes dashboards según el rol del usuario
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedNavItem = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final role = authState.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Row(
        children: [
          // Sidebar
          DashboardSidebar(
            selectedItem: _selectedNavItem,
            onItemTap: (item) {
              setState(() => _selectedNavItem = item);
            },
            onLogout: () => _handleLogout(context),
            userName: user?.nombreCompleto ?? 'Usuario',
            userEmail: user?.email ?? '',
            userAvatarUrl: user?.photourl,
            userRole: role,
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                DashboardHeader(
                  title: _getHeaderTitle(role),
                ),
                // Content - Dashboard según rol
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFB),
                    child: _buildDashboardContent(role, user),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle(UserRole? role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Panel de Administración';
      case UserRole.club:
        return 'Panel del Club';
      case UserRole.coordinador:
        return 'Panel de Coordinación';
      case UserRole.entrenador:
        return 'Mi Equipo';
      default:
        return 'Panel Principal';
    }
  }

  Widget _buildDashboardContent(UserRole? role, dynamic user) {
    // Si no está en dashboard, mostrar placeholder
    if (_selectedNavItem != 'dashboard') {
      return _buildPlaceholderContent();
    }

    // Mostrar dashboard según rol
    switch (role) {
      case UserRole.superAdmin:
        return const SuperAdminDashboard();
      case UserRole.club:
        return ClubDashboard(user: user);
      case UserRole.coordinador:
        return CoordinadorDashboard(user: user);
      case UserRole.entrenador:
        return EntrenadorDashboard(user: user);
      default:
        // Fallback al dashboard de entrenador para roles desconocidos
        return EntrenadorDashboard(user: user);
    }
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForItem(_selectedNavItem),
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getTitleForItem(_selectedNavItem),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta sección estará disponible próximamente',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForItem(String item) {
    switch (item) {
      case 'teams':
        return Icons.groups;
      case 'players':
        return Icons.person;
      case 'training':
        return Icons.fitness_center;
      case 'matches':
        return Icons.sports_soccer;
      case 'fees':
        return Icons.payments;
      case 'clothing':
        return Icons.checkroom;
      case 'accounting':
        return Icons.account_balance;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  String _getTitleForItem(String item) {
    switch (item) {
      case 'teams':
        return 'Gestión de Equipos';
      case 'players':
        return 'Jugadores';
      case 'training':
        return 'Entrenamientos';
      case 'matches':
        return 'Partidos';
      case 'fees':
        return 'Cuotas';
      case 'clothing':
        return 'Ropa';
      case 'accounting':
        return 'Contabilidad';
      case 'settings':
        return 'Configuración';
      default:
        return 'Panel Principal';
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
