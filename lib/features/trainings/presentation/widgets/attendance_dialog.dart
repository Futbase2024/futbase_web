import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/trainings_bloc.dart';
import '../../bloc/trainings_event.dart';
import '../../bloc/trainings_state.dart';

/// Diálogo para CONSULTAR asistencia de jugadores (solo lectura)
class AttendanceDialog extends StatefulWidget {
  const AttendanceDialog({
    super.key,
    required this.identrenamiento,
    required this.idequipo,
    required this.trainingDate,
  });

  final int identrenamiento;
  final int idequipo;
  final String trainingDate;

  @override
  State<AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  late final TrainingsBloc _attendanceBloc;

  /// Definición de columnas de estado
  /// 0=No Justificado, 1=Asiste, 2=Estudios, 3=Enfermo, 4=Lesionado
  /// 5=Trabajo, 6=Se lesionó, 7=Vacaciones, 8=Justificada, 9=Retraso
  static const List<_MotiveColumn> _motiveColumns = [
    _MotiveColumn(id: 1, label: 'A', color: AppColors.primary), // Asiste
    _MotiveColumn(id: 0, label: 'F', color: AppColors.error), // No Justificado
    _MotiveColumn(id: 2, label: 'E', color: AppColors.info), // Estudios
    _MotiveColumn(id: 3, label: 'EN', color: Colors.orange), // Enfermo@
    _MotiveColumn(id: 4, label: 'LE', color: Colors.deepOrange), // Lesionad@
    _MotiveColumn(id: 5, label: 'TR', color: Colors.blue), // Trabajo
    _MotiveColumn(id: 6, label: 'SL', color: Colors.redAccent), // Se ha lesionado
    _MotiveColumn(id: 7, label: 'V', color: Colors.purple), // Vacaciones
    _MotiveColumn(id: 8, label: 'J', color: AppColors.greenOlive), // Justificada
    _MotiveColumn(id: 9, label: 'R', color: Colors.amber), // Retraso
  ];

  @override
  void initState() {
    super.initState();
    _attendanceBloc = TrainingsBloc();
    _attendanceBloc.add(AttendanceLoadRequested(
      identrenamiento: widget.identrenamiento,
      idequipo: widget.idequipo,
    ));
  }

  @override
  void dispose() {
    _attendanceBloc.close();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'es_ES').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: BlocProvider.value(
        value: _attendanceBloc,
        child: BlocBuilder<TrainingsBloc, TrainingsState>(
          builder: (context, state) {
            return Container(
              width: 900,
              constraints: const BoxConstraints(maxHeight: 650),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(state),
                  const Divider(height: 1),

                  // Content
                  Expanded(
                    child: switch (state) {
                      AttendanceState(
                        :final players,
                        :final selectedMotive,
                      ) =>
                        _buildPlayersTable(players, selectedMotive),
                      TrainingsLoading() => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CELoading.inline(),
                              SizedBox(height: 16),
                              Text(
                                'Cargando asistencia...',
                                style: TextStyle(color: AppColors.gray500),
                              ),
                            ],
                          ),
                        ),
                      TrainingsError(:final message) => _buildError(message),
                      TrainingsInitial() => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CELoading.inline(),
                              SizedBox(height: 16),
                              Text(
                                'Iniciando...',
                                style: TextStyle(color: AppColors.gray500),
                              ),
                            ],
                          ),
                        ),
                      _ => const Center(
                          child: Text(
                            'Estado no reconocido',
                            style: TextStyle(color: AppColors.gray500),
                          ),
                        ),
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(TrainingsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fact_check,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulta de Asistencia',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  _formatDate(widget.trainingDate),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          // Estadísticas
          if (state is AttendanceState) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  AppSpacing.hSpaceXs,
                  Text(
                    '${state.presentCount}/${state.players.length}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                  AppSpacing.hSpaceSm,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: state.attendancePercentage >= 80
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : state.attendancePercentage >= 50
                              ? AppColors.warning.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${state.attendancePercentage.toStringAsFixed(0)}%',
                      style: AppTypography.labelSmall.copyWith(
                        color: state.attendancePercentage >= 80
                            ? AppColors.primary
                            : state.attendancePercentage >= 50
                                ? AppColors.warning
                                : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hSpaceMd,
          ],
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: AppColors.gray500,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersTable(
    List<Map<String, dynamic>> players,
    Map<int, int?> selectedMotive,
  ) {
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.gray400,
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No hay jugadores en el equipo',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header de la tabla
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            border: Border(
              bottom: BorderSide(color: AppColors.gray200),
            ),
          ),
          child: Row(
            children: [
              // Columna dorsal
              const SizedBox(width: 50),
              // Columna nombre
              const Expanded(
                child: Text(
                  'Jugador',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                    fontSize: 12,
                  ),
                ),
              ),
              // Columnas de estados
              ..._motiveColumns.map((col) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        col.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: col.color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // Filas de jugadores
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final id = player['id'] as int;
              final nombre = player['nombre']?.toString() ?? '';
              final apellidos = player['apellidos']?.toString() ?? '';
              final currentMotive = selectedMotive[id];

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.white : AppColors.gray50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    // Nombre
                    Expanded(
                      child: Text(
                        '$nombre $apellidos',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                    ),

                    // Columnas de estados (checkmarks)
                    // Si idmotivo = 1 → Asiste (A) → check (✓)
                    // Si idmotivo es otro → X (✗) en la columna del motivo
                    ..._motiveColumns.map((col) {
                      // Tratar null como 0 (Falta)
                      final effectiveMotive = currentMotive ?? 0;
                      final isSelected = effectiveMotive == col.id;
                      final isAssist = col.id == 1; // Columna A = Asiste
                      return SizedBox(
                        width: 40,
                        height: 32,
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected ? col.color.withValues(alpha: 0.15) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? col.color : Colors.transparent,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    isAssist ? Icons.check : Icons.close,
                                    size: 18,
                                    color: col.color,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          AppSpacing.vSpaceMd,
          Text(
            'Error al cargar asistencia',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
          ),
          AppSpacing.vSpaceSm,
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Modelo para las columnas de motivos
class _MotiveColumn {
  const _MotiveColumn({
    required this.id,
    required this.label,
    required this.color,
  });

  final int id;
  final String label;
  final Color color;
}
