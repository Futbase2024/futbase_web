import 'package:flutter/material.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../domain/report_types.dart';
import '../../domain/report_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Panel de filtros para generar informes
class ReportFilterPanel extends StatelessWidget {
  const ReportFilterPanel({
    super.key,
    required this.selectedType,
    required this.filter,
    required this.availableTeams,
    required this.availableCategories,
    required this.availablePlayers,
    required this.availableMatches,
    required this.userRole,
    required this.user,
    required this.onFilterChanged,
    required this.onGenerateReport,
  });

  final ReportType selectedType;
  final ReportFilter filter;
  final List<Map<String, dynamic>> availableTeams;
  final List<Map<String, dynamic>> availableCategories;
  final List<Map<String, dynamic>> availablePlayers;
  final List<Map<String, dynamic>> availableMatches;
  final String userRole;
  final UsuariosEntity user;
  final ValueChanged<ReportFilter> onFilterChanged;
  final VoidCallback onGenerateReport;

  bool get isEntrenador => userRole == 'entrenador';
  bool get canSelectTeam => !isEntrenador && availableTeams.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Configurar informe',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _buildFilters(),
          ),
          const SizedBox(height: 24),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  List<Widget> _buildFilters() {
    final filters = <Widget>[];

    // Filtro de equipo (solo para club/coordinador)
    if (canSelectTeam) {
      filters.add(_buildTeamDropdown());
    }

    // Filtros específicos por tipo de informe
    switch (selectedType) {
      case ReportType.player:
        filters.add(_buildPlayerDropdown());
        filters.add(_buildPeriodDropdown());
        break;
      case ReportType.match:
        filters.add(_buildMatchDropdown());
        break;
      case ReportType.convocatoria:
        filters.add(_buildMatchDropdown());
        break;
      case ReportType.attendanceMonthly:
        filters.add(_buildMonthYearPicker());
        break;
      case ReportType.teamStats:
        filters.add(_buildPeriodDropdown());
        break;
    }

    return filters;
  }

  Widget _buildTeamDropdown() {
    final teamIds = availableTeams.map((t) => t['id'] as int).toList();
    final validTeamId = filter.teamId != null && teamIds.contains(filter.teamId)
        ? filter.teamId
        : null;

    return _FilterField(
      label: 'Equipo',
      child: DropdownButtonFormField<int>(
        initialValue: validTeamId,
        decoration: _inputDecoration('Seleccionar equipo'),
        items: availableTeams.map((team) {
          return DropdownMenuItem<int>(
            value: team['id'] as int,
            child: Text(team['equipo'] as String),
          );
        }).toList(),
        onChanged: (value) {
          onFilterChanged(filter.copyWith(
            teamId: value,
            clearTeamId: value == null,
            clearPlayerId: true,
            clearMatchId: true,
          ));
        },
      ),
    );
  }

  Widget _buildPlayerDropdown() {
    // teamId se usa para determinar qué jugadores mostrar
    // Para entrenadores se usa el equipo del usuario, para otros roles el equipo seleccionado
    final players = availablePlayers;
    final playerIds = players.map((p) => p['id'] as int).toList();
    final validPlayerId = filter.playerId != null && playerIds.contains(filter.playerId)
        ? filter.playerId
        : null;

    return _FilterField(
      label: 'Jugador',
      child: DropdownButtonFormField<int>(
        initialValue: validPlayerId,
        decoration: _inputDecoration('Seleccionar jugador'),
        items: players.map((player) {
          final name = '${player['nombre']} ${player['apellidos']}';
          final dorsal = player['dorsal'];
          return DropdownMenuItem<int>(
            value: player['id'] as int,
            child: Text(dorsal != null ? '#$dorsal $name' : name),
          );
        }).toList(),
        onChanged: (value) {
          onFilterChanged(filter.copyWith(
            playerId: value,
            clearPlayerId: value == null,
          ));
        },
      ),
    );
  }

  Widget _buildMatchDropdown() {
    final matches = availableMatches;
    final matchIds = matches.map((m) => m['id'] as int).toList();
    final validMatchId = filter.matchId != null && matchIds.contains(filter.matchId)
        ? filter.matchId
        : null;

    return _FilterField(
      label: 'Partido',
      child: DropdownButtonFormField<int>(
        initialValue: validMatchId,
        decoration: _inputDecoration('Seleccionar partido'),
        items: matches.map((match) {
          final rival = match['rival'] as String? ?? 'Rival';
          final fecha = match['fecha'] != null
              ? DateTime.tryParse(match['fecha'].toString())
              : null;
          final fechaStr = fecha != null
              ? '${fecha.day}/${fecha.month}/${fecha.year}'
              : '';
          final goles = match['goles'] as int?;
          final golesRival = match['golesrival'] as int?;
          final local = match['local'] == 1;

          String resultado = '';
          if (goles != null && golesRival != null) {
            if (local) {
              resultado = ' ($goles-$golesRival)';
            } else {
              resultado = ' ($golesRival-$goles)';
            }
          }

          return DropdownMenuItem<int>(
            value: match['id'] as int,
            child: Text('vs $rival - $fechaStr$resultado'),
          );
        }).toList(),
        onChanged: (value) {
          onFilterChanged(filter.copyWith(
            matchId: value,
            clearMatchId: value == null,
          ));
        },
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return _FilterField(
      label: 'Período',
      child: DropdownButtonFormField<ReportPeriod>(
        initialValue: filter.period,
        decoration: _inputDecoration('Seleccionar período'),
        items: ReportPeriod.values.map((period) {
          return DropdownMenuItem<ReportPeriod>(
            value: period,
            child: Text(period.label),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onFilterChanged(filter.copyWith(period: value));
          }
        },
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    final now = DateTime.now();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterField(
          label: 'Mes',
          width: 150,
          child: DropdownButtonFormField<int>(
            initialValue: now.month,
            decoration: _inputDecoration(''),
            items: List.generate(12, (index) {
              const months = [
                'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
              ];
              return DropdownMenuItem<int>(
                value: index + 1,
                child: Text(months[index]),
              );
            }),
            onChanged: (value) {
              // Handle month change
            },
          ),
        ),
        const SizedBox(width: 16),
        _FilterField(
          label: 'Año',
          width: 120,
          child: DropdownButtonFormField<int>(
            initialValue: now.year,
            decoration: _inputDecoration(''),
            items: List.generate(3, (index) {
              final year = now.year - index;
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              // Handle year change
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = _canGenerateReport();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? onGenerateReport : null,
        icon: const Icon(Icons.assessment_outlined, size: 20),
        label: const Text('Generar Informe'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.gray200,
          disabledForegroundColor: AppColors.gray500,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  bool _canGenerateReport() {
    final teamId = isEntrenador ? user.idequipo : filter.teamId;

    switch (selectedType) {
      case ReportType.player:
        return filter.playerId != null && teamId != null;
      case ReportType.match:
        return filter.matchId != null && teamId != null;
      case ReportType.convocatoria:
        return filter.matchId != null && teamId != null;
      case ReportType.attendanceMonthly:
        return teamId != null;
      case ReportType.teamStats:
        return teamId != null;
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.gray400),
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.child,
    this.width = 250,
  });

  final String label;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
