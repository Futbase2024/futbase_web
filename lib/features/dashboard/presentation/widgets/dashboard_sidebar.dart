import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/user_roles.dart';

/// Variable global para medir el tiempo de carga de Jugadores
/// Se establece al hacer click en el botón de Jugadores
int? playersClickTimestamp;

/// Variable global para medir el tiempo de carga del Dashboard/Inicio
/// Se establece al hacer click en el botón de Inicio
int? dashboardClickTimestamp;

/// Sidebar del dashboard con navegación colapsable
/// Diseño basado en dashboard_principal_futbase (code.html)
class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    this.selectedItem = 'dashboard',
    this.onItemTap,
    this.userRole,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  final String selectedItem;
  final void Function(String item)? onItemTap;
  final UserRole? userRole;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  static const double _expandedWidth = 288.0;
  static const double _collapsedWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isCollapsed ? _collapsedWidth : _expandedWidth,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          right: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Column(
        children: [
          // Logo y toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildLogo(context),
          ),
          // Role badge
          if (userRole != null && !isCollapsed) _buildRoleBadge(context),
          // Navigation
          Expanded(
            child: _buildNavigation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    if (isCollapsed) {
      // Versión colapsada: logo centrado con toggle abajo
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/icons/icono.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          IconButton(
            onPressed: onToggleCollapse,
            icon: Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Expandir',
          ),
        ],
      );
    }

    // Versión expandida
    return Row(
      children: [
        Image.asset(
          'lib/assets/icons/icono.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FutBase',
                style: AppTypography.h6.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'GESTIÓN DEPORTIVA',
                style: AppTypography.overline.copyWith(
                  color: AppColors.gray400,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onToggleCollapse,
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.gray400,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          tooltip: 'Colapsar',
        ),
      ],
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getRoleColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getRoleColor().withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              _getRoleIcon(),
              size: 16,
              color: _getRoleColor(),
            ),
            const SizedBox(width: 8),
            Text(
              userRole!.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: _getRoleColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (userRole) {
      case UserRole.superAdmin:
        return AppColors.error;
      case UserRole.club:
        return AppColors.primary;
      case UserRole.coordinador:
        return AppColors.primary;
      case UserRole.entrenador:
        return AppColors.primary;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getRoleIcon() {
    switch (userRole) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.club:
        return Icons.business;
      case UserRole.coordinador:
        return Icons.people_alt;
      case UserRole.entrenador:
        return Icons.sports;
      default:
        return Icons.person;
    }
  }

  /// Get navigation items filtered by user role
  List<_NavItemData> _getNavItemsForRole() {
    final role = userRole ?? UserRole.entrenador;

    return _allNavItems.where((item) {
      switch (item.id) {
        case 'dashboard':
          return true; // Dashboard visible for all
        case 'teams':
          return role == UserRole.club || role == UserRole.coordinador;
        case 'players':
          return role.canManageTeams;
        case 'training':
          return role.canManageTrainings;
        case 'matches':
          return role.canManageMatches;
        case 'results':
          return role.canViewResults;
        case 'reports':
          return role.canViewReports;
        case 'scouting':
          return role.canViewReports; // Scouting visible para quienes pueden ver informes
        case 'season':
          return role.canChangeSeason;
        case 'fees':
          return role.canViewGlobalStats;
        case 'clothing':
          return role.canViewGlobalStats;
        case 'accounting':
          return role.canManageUsers || role.hasFullDashboard;
        default:
          return false;
      }
    }).toList();
  }

  Widget _buildNavigation(BuildContext context) {
    final navItems = _getNavItemsForRole();

    return Padding(
      padding: EdgeInsets.only(left: isCollapsed ? 8 : 16),
      child: SingleChildScrollView(
        child: Column(
          children: navItems.map((item) => _NavItem(
            item: item,
            isSelected: selectedItem == item.id,
            isCollapsed: isCollapsed,
            onTap: () => onItemTap?.call(item.id),
          )).toList(),
        ),
      ),
    );
  }

  /// All possible navigation items (sin Configuración - ahora en AppBar)
  static const List<_NavItemData> _allNavItems = [
    _NavItemData(id: 'dashboard', icon: Icons.home, label: 'Inicio'),
    _NavItemData(id: 'teams', icon: Icons.groups, label: 'Equipos'),
    _NavItemData(id: 'players', icon: Icons.person, label: 'Jugadores'),
    _NavItemData(id: 'training', icon: Icons.fitness_center, label: 'Entrenamientos'),
    _NavItemData(id: 'matches', icon: Icons.sports_soccer, label: 'Partidos'),
    _NavItemData(id: 'results', icon: Icons.emoji_events, label: 'Resultados'),
    _NavItemData(id: 'reports', icon: Icons.assessment, label: 'Informes'),
    _NavItemData(id: 'scouting', icon: Icons.analytics, label: 'Scouting'),
    _NavItemData(id: 'season', icon: Icons.calendar_today, label: 'Cambio de Temporada'),
    _NavItemData(id: 'fees', icon: Icons.payments, label: 'Cuotas'),
    _NavItemData(id: 'clothing', icon: Icons.checkroom, label: 'Ropa'),
    _NavItemData(id: 'accounting', icon: Icons.account_balance, label: 'Contabilidad'),
  ];
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    this.onTap,
  });

  final _NavItemData item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback? onTap;

  void _handleTap() {
    // Log de timing: click en el botón de Jugadores o Inicio
    if (item.id == 'players') {
      playersClickTimestamp = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] 🖱️ CLICK en Jugadores: $playersClickTimestamp ms');
    } else if (item.id == 'dashboard') {
      dashboardClickTimestamp = DateTime.now().millisecondsSinceEpoch;
      debugPrint('⏱️ [TIMING] 🖱️ CLICK en Inicio: $dashboardClickTimestamp ms');
    }
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      // Versión colapsada: solo icono con tooltip
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE9F2F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 24,
                    color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Versión expandida
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE9F2F1) : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              border: isSelected
                  ? Border(
                      right: BorderSide(color: AppColors.primary, width: 4),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 16),
                Text(
                  item.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;
}
