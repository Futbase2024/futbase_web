import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Widget de asistencia de jugadores por equipo
/// Diseño modo claro basado en dashboard-blanco.html
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    this.teams = const [],
  });

  final List<TeamAttendance> teams;

  @override
  Widget build(BuildContext context) {
    final avgAttendance = teams.isEmpty
        ? 0.0
        : teams.map((t) => t.percentage).reduce((a, b) => a + b) / teams.length;
    final totalInactive = teams.fold<int>(0, (sum, t) => sum + t.inactiveCount);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.gray100),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asistencia de Jugadores',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Dropdown simulado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Semanal',
                      style: AppTypography.caption.copyWith(
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.textSecondaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress bars
          ...teams.map((team) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AttendanceProgress(team: team),
              )),
          const SizedBox(height: 8),
          // Summary
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.borderColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context: context,
                    value: '${avgAttendance.round()}%',
                    label: 'Asistencia Promedio',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.borderColor,
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context: context,
                    value: totalInactive.toString(),
                    label: 'Enfermos/Lesionados',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.statMedium.copyWith(
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(
            color: context.textSecondaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AttendanceProgress extends StatelessWidget {
  const _AttendanceProgress({required this.team});

  final TeamAttendance team;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              team.name,
              style: AppTypography.labelSmall.copyWith(
                color: context.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${team.percentage.round()}%',
              style: AppTypography.labelSmall.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: team.percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modelo de asistencia por equipo
class TeamAttendance {
  const TeamAttendance({
    required this.name,
    required this.percentage,
    this.inactiveCount = 0,
  });

  final String name;
  final double percentage;
  final int inactiveCount;

  /// Datos de ejemplo
  static const List<TeamAttendance> sampleData = [
    TeamAttendance(name: 'U17 Élite', percentage: 94, inactiveCount: 2),
    TeamAttendance(name: 'U15 Desarrollo', percentage: 82, inactiveCount: 4),
    TeamAttendance(name: 'U13 Futuras Estrellas', percentage: 88, inactiveCount: 3),
    TeamAttendance(name: 'U11 Iniciación', percentage: 75, inactiveCount: 3),
  ];
}
