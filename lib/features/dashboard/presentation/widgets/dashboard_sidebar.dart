import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/user_roles.dart';

/// Sidebar del dashboard con navegación
/// Diseño basado en dashboard_principal_futbase (code.html)
class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    this.selectedItem = 'dashboard',
    this.onItemTap,
    this.onLogout,
    this.userName = 'Admin FutBase',
    this.userEmail = 'admin@futbase.com',
    this.userAvatarUrl,
    this.userRole,
  });

  final String selectedItem;
  final void Function(String item)? onItemTap;
  final VoidCallback? onLogout;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;
  final UserRole? userRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          right: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(32),
            child: _buildLogo(context),
          ),
          // Role badge
          if (userRole != null) _buildRoleBadge(context),
          // Navigation
          Expanded(
            child: _buildNavigation(context),
          ),
          // Bottom section - User profile
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.sports_soccer,
            color: AppColors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
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
        return AppColors.warning;
      case UserRole.entrenador:
        return AppColors.success;
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
      // Settings is always visible
      if (item.id == 'settings') return true;

      switch (item.id) {
        case 'dashboard':
          return true; // Dashboard visible for all
        case 'teams':
          return role.canManageTeams;
        case 'players':
          return role.canManageTeams;
        case 'training':
          return role.canManageTrainings;
        case 'matches':
          return role.canManageMatches;
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

    // Separar items principales de configuración
    final mainItems = navItems.where((item) => item.id != 'settings').toList();
    final settingsItem = navItems.where((item) => item.id == 'settings').firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          // Main navigation items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: mainItems.map((item) => _NavItem(
                  item: item,
                  isSelected: selectedItem == item.id,
                  onTap: () => onItemTap?.call(item.id),
                )).toList(),
              ),
            ),
          ),
          // Separator and settings
          if (settingsItem != null)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.gray50),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _NavItem(
                    item: settingsItem,
                    isSelected: selectedItem == settingsItem.id,
                    onTap: () => onItemTap?.call(settingsItem.id),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB).withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: AppColors.gray50),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.white, width: 2),
              image: userAvatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(userAvatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: userAvatarUrl == null
                ? Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userEmail,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray400,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Logout button
          InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.logout,
                color: AppColors.primary.withValues(alpha: 0.4),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// All possible navigation items
  static const List<_NavItemData> _allNavItems = [
    _NavItemData(id: 'dashboard', icon: Icons.grid_view, label: 'Panel Principal'),
    _NavItemData(id: 'teams', icon: Icons.groups, label: 'Equipos'),
    _NavItemData(id: 'players', icon: Icons.person, label: 'Jugadores'),
    _NavItemData(id: 'training', icon: Icons.fitness_center, label: 'Entrenamientos'),
    _NavItemData(id: 'matches', icon: Icons.sports_soccer, label: 'Partidos'),
    _NavItemData(id: 'fees', icon: Icons.payments, label: 'Cuotas'),
    _NavItemData(id: 'clothing', icon: Icons.checkroom, label: 'Ropa'),
    _NavItemData(id: 'accounting', icon: Icons.account_balance, label: 'Contabilidad'),
    _NavItemData(id: 'settings', icon: Icons.settings, label: 'Configuración'),
  ];
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    this.onTap,
  });

  final _NavItemData item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
