import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Panel de estadísticas de entrenamientos para Club/Coordinador
class TrainingsStatsPanel extends StatelessWidget {
  const TrainingsStatsPanel({
    super.key,
    required this.teams,
    required this.attendanceByTeam,
    required this.overallAttendance,
    required this.trainingsByTimeSlot,
    required this.trainingsByField,
    required this.trainingsByTeam,
  });

  final List<Map<String, dynamic>> teams;
  final Map<int, double> attendanceByTeam;
  final double overallAttendance;
  final Map<String, int> trainingsByTimeSlot;
  final Map<String, int> trainingsByField;
  final Map<int, int> trainingsByTeam;

  /// Ordena equipos por asistencia (mayor a menor)
  List<Map<String, dynamic>> get _sortedTeams {
    final sorted = List<Map<String, dynamic>>.from(teams);
    sorted.sort((a, b) {
      final idA = a['id'] as int?;
      final idB = b['id'] as int?;
      final attA = idA != null ? attendanceByTeam[idA] ?? 0 : 0;
      final attB = idB != null ? attendanceByTeam[idB] ?? 0 : 0;
      return attB.compareTo(attA);
    });
    return sorted;
  }

  /// Equipos con baja asistencia (<70%)
  List<Map<String, dynamic>> get _lowAttendanceTeams {
    return teams.where((team) {
      final id = team['id'] as int?;
      if (id == null) return false;
      final attendance = attendanceByTeam[id] ?? 0;
      return attendance < 70 && attendance > 0;
    }).toList();
  }

  Color _getAttendanceColor(double attendance) {
    if (attendance >= 85) return AppColors.success;
    if (attendance >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Header
          _buildHeader(),

          // Alertas de baja asistencia
          if (_lowAttendanceTeams.isNotEmpty) _buildLowAttendanceAlert(),

          // Contenido en tabs/columnas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ranking de equipos
                Expanded(
                  flex: 2,
                  child: _buildTeamRanking(),
                ),
                AppSpacing.hSpaceMd,

                // Distribución
                Expanded(
                  child: _buildDistribution(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: AppColors.gray100),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas de Entrenamientos',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Análisis de asistencia y distribución',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          // Asistencia media global
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getAttendanceColor(overallAttendance).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getAttendanceColor(overallAttendance).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${overallAttendance.toStringAsFixed(1)}%',
                  style: AppTypography.h5.copyWith(
                    color: _getAttendanceColor(overallAttendance),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Asistencia Media',
                  style: AppTypography.caption.copyWith(
                    color: _getAttendanceColor(overallAttendance),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowAttendanceAlert() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          AppSpacing.hSpaceSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equipos con baja asistencia',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _lowAttendanceTeams.map((t) => t['ncorto'] ?? t['equipo']).join(', '),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRanking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 16,
              color: AppColors.gray500,
            ),
            AppSpacing.hSpaceXs,
            Text(
              'Ranking por Asistencia',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.vSpaceSm,

        // Lista de equipos con barras de progreso
        ..._sortedTeams.take(6).map((team) {
          final id = team['id'] as int?;
          final name = team['ncorto']?.toString() ?? team['equipo']?.toString() ?? 'Sin nombre';
          final categoria = team['categoria']?.toString() ?? '';
          final attendance = id != null ? attendanceByTeam[id] ?? 0.0 : 0.0;
          final weeklyCount = id != null ? trainingsByTeam[id] ?? 0 : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TeamAttendanceRow(
              name: name,
              categoria: categoria,
              attendance: attendance,
              weeklyTrainings: weeklyCount,
              color: _getAttendanceColor(attendance),
            ),
          );
        }),

        if (_sortedTeams.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${_sortedTeams.length - 6} equipos más',
              style: AppTypography.caption.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDistribution() {
    final morning = trainingsByTimeSlot['mañana'] ?? 0;
    final afternoon = trainingsByTimeSlot['tarde'] ?? 0;
    final total = morning + afternoon;

    // Top 3 campos
    final sortedFields = trainingsByField.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFields = sortedFields.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Distribución por horario
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: AppColors.gray500,
            ),
            AppSpacing.hSpaceXs,
            Text(
              'Por Horario',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.vSpaceSm,

        Row(
          children: [
            Expanded(
              child: _DistributionCard(
                icon: Icons.wb_sunny_outlined,
                label: 'Mañana',
                value: morning,
                percentage: total > 0 ? (morning / total * 100).toStringAsFixed(0) : '0',
                color: const Color(0xFFFFA726),
              ),
            ),
            AppSpacing.hSpaceSm,
            Expanded(
              child: _DistributionCard(
                icon: Icons.nights_stay_outlined,
                label: 'Tarde',
                value: afternoon,
                percentage: total > 0 ? (afternoon / total * 100).toStringAsFixed(0) : '0',
                color: const Color(0xFF5C6BC0),
              ),
            ),
          ],
        ),

        AppSpacing.vSpaceMd,

        // Campos más utilizados
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 16,
              color: AppColors.gray500,
            ),
            AppSpacing.hSpaceXs,
            Text(
              'Campos',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.vSpaceSm,

        if (topFields.isEmpty)
          Text(
            'Sin datos de campos',
            style: AppTypography.caption.copyWith(
              color: AppColors.gray400,
            ),
          )
        else
          ...topFields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hSpaceSm,
                  Expanded(
                    child: Text(
                      field.key,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${field.value}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

/// Fila de equipo con barra de asistencia
class _TeamAttendanceRow extends StatelessWidget {
  const _TeamAttendanceRow({
    required this.name,
    required this.categoria,
    required this.attendance,
    required this.weeklyTrainings,
    required this.color,
  });

  final String name;
  final String categoria;
  final double attendance;
  final int weeklyTrainings;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (categoria.isNotEmpty) ...[
                    AppSpacing.hSpaceXs,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        categoria,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.gray500,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.hSpaceSm,
            Text(
              '${attendance.toStringAsFixed(0)}%',
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Barra de progreso
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: attendance / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tarjeta de distribución
class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final String percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$percentage%',
            style: AppTypography.h6.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
          Text(
            '$value sesiones',
            style: AppTypography.caption.copyWith(
              color: AppColors.gray500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
