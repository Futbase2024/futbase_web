import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

/// Header del dashboard con búsqueda y acciones
/// Diseño basado en dashboard_principal_futbase (code.html)
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.title = 'Panel Principal',
    this.searchHint = 'Buscar jugadores, equipos...',
    this.onSearchChanged,
    this.onNotificationsTap,
    this.onSettingsTap,
  });

  final String title;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          // Title
          Text(
            title,
            style: AppTypography.h6.copyWith(
              color: AppColors.gray800,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Search
          _buildSearchField(context),
          const SizedBox(width: 24),
          // Actions
          _buildActions(context),
          const SizedBox(width: 16),
          // User menu
          _buildUserMenu(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      width: 288,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: AppTypography.bodySmall.copyWith(color: AppColors.gray900),
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.gray400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.gray400,
            size: 20,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // Notifications
        Stack(
          children: [
            _ActionButton(
              icon: Icons.notifications,
              onTap: onNotificationsTap,
            ),
            // Notification dot
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Settings
        _ActionButton(
          icon: Icons.settings,
          onTap: onSettingsTap,
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final userName = user?.nombreCompleto ?? 'Usuario';
        final userEmail = user?.email ?? '';

        return PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Mi Perfil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Configuración'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout(context);
            } else if (value == 'settings') {
              onSettingsTap?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userName.split(' ').first,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        );
      },
    );
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.gray400,
            size: 24,
          ),
        ),
      ),
    );
  }
}
