import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Navegación de tabs del perfil de jugador
/// Sigue el estilo del proyecto antiguo (ModernTabNavigation)
class PlayerProfileTabs extends StatefulWidget {
  const PlayerProfileTabs({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
    required this.isAdmin,
  });

  final int activeTabIndex;
  final ValueChanged<int> onTabChanged;
  final bool isAdmin;

  @override
  State<PlayerProfileTabs> createState() => _PlayerProfileTabsState();
}

class _PlayerProfileTabsState extends State<PlayerProfileTabs> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTab(int index) {
    if (_scrollController.hasClients) {
      const double tabWidth = 180.0 + 8.0;
      final double containerWidth = MediaQuery.of(context).size.width - 48;
      final double targetPosition = (tabWidth * index) - (containerWidth / 2) + (tabWidth / 2);

      _scrollController.animateTo(
        targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<_TabItem> _buildTabs() {
    final tabs = <_TabItem>[];

    // Tabs de administrador (solo si isAdmin)
    if (widget.isAdmin) {
      tabs.addAll([
        _TabItem(name: 'Cuotas', icon: Icons.payments),
        _TabItem(name: 'Deuda Temporada', icon: Icons.account_balance_wallet),
        _TabItem(name: 'Tutores', icon: Icons.family_restroom),
        _TabItem(name: 'Carnets', icon: Icons.badge),
      ]);
    }

    // Tabs comunes
    tabs.addAll([
      _TabItem(name: 'Ficha Federativa', icon: Icons.description),
      _TabItem(name: 'Estadísticas', icon: Icons.analytics),
      _TabItem(name: 'Entrenamientos', icon: Icons.fitness_center),
      _TabItem(name: 'Partidos', icon: Icons.sports_soccer),
      _TabItem(name: 'Talla & Peso', icon: Icons.straighten),
      _TabItem(name: 'Lesiones', icon: Icons.healing),
      _TabItem(name: 'Asistencias', icon: Icons.check_circle),
      _TabItem(name: 'Vista Completa', icon: Icons.view_module),
    ]);

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = index == widget.activeTabIndex;

            return _buildTab(tab, index, isActive);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(_TabItem tab, int index, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onTabChanged(index);
            _scrollToTab(index);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 180,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tab.icon,
                  size: 18,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: Text(
                    tab.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? Colors.white : AppColors.primary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _TabItem {
  final String name;
  final IconData icon;

  const _TabItem({required this.name, required this.icon});
}
