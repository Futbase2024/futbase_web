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

/// Diálogo para gestionar asistencia de jugadores
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
    _MotiveColumn(id: 1, label: 'A', color: AppColors.primary, tooltip: 'Asiste'),
    _MotiveColumn(id: 0, label: 'F', color: AppColors.error, tooltip: 'Falta no justificada'),
    _MotiveColumn(id: 2, label: 'E', color: AppColors.info, tooltip: 'Estudios'),
    _MotiveColumn(id: 3, label: 'EN', color: Colors.orange, tooltip: 'Enfermo'),
    _MotiveColumn(id: 4, label: 'LE', color: Colors.deepOrange, tooltip: 'Lesionado'),
    _MotiveColumn(id: 5, label: 'TR', color: Colors.blue, tooltip: 'Trabajo'),
    _MotiveColumn(id: 6, label: 'SL', color: Colors.redAccent, tooltip: 'Se lesionó'),
    _MotiveColumn(id: 7, label: 'V', color: Colors.purple, tooltip: 'Vacaciones'),
    _MotiveColumn(id: 8, label: 'J', color: AppColors.greenOlive, tooltip: 'Justificada'),
    _MotiveColumn(id: 9, label: 'R', color: Colors.amber, tooltip: 'Retraso'),
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
      return DateFormat('EEEE d MMMM yyyy', 'es_ES').format(date).toUpperCase();
    } catch (_) {
      return dateStr;
    }
  }

  void _onMotiveTap(int idJugador, int motiveId, bool presente) {
    _attendanceBloc.add(AttendanceMarkRequested(
      identrenamiento: widget.identrenamiento,
      idjugador: idJugador,
      idmotivo: motiveId,
      presente: presente,
    ));
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
              width: 1000,
              constraints: const BoxConstraints(maxHeight: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _AttendanceHeader(
                    formattedDate: _formatDate(widget.trainingDate),
                    state: state,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const Divider(height: 1),

                  // Content
                  Expanded(
                    child: switch (state) {
                      AttendanceState(
                        :final players,
                        :final selectedMotive,
                      ) =>
                        _PlayersList(
                          players: players,
                          selectedMotive: selectedMotive,
                          motiveColumns: _motiveColumns,
                          onMotiveTap: _onMotiveTap,
                        ),
                      TrainingsLoading() => const _LoadingView(message: 'Cargando asistencia...'),
                      TrainingsError(:final message) => _ErrorView(message: message),
                      TrainingsInitial() => const _LoadingView(message: 'Iniciando...'),
                      _ => const _ErrorView(message: 'Estado no reconocido'),
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
}

/// Header del diálogo de asistencia
class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({
    required this.formattedDate,
    required this.state,
    required this.onClose,
  });

  final String formattedDate;
  final TrainingsState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASISTENCIA',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  formattedDate,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Estadísticas
          if (state is AttendanceState) ...[
            _AttendanceStats(state: state as AttendanceState),
            AppSpacing.hSpaceMd,
          ],
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: AppColors.gray400,
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}

/// Estadísticas de asistencia en el header
class _AttendanceStats extends StatelessWidget {
  const _AttendanceStats({required this.state});

  final AttendanceState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 18,
            color: AppColors.gray500,
          ),
          AppSpacing.hSpaceXs,
          Text(
            '${state.presentCount}/${state.players.length}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.hSpaceSm,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: state.attendancePercentage >= 80
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : state.attendancePercentage >= 50
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${state.attendancePercentage.toStringAsFixed(0)}%',
              style: AppTypography.labelSmall.copyWith(
                color: state.attendancePercentage >= 80
                    ? AppColors.primary
                    : state.attendancePercentage >= 50
                        ? AppColors.warning
                        : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de jugadores con sus botones de asistencia
class _PlayersList extends StatelessWidget {
  const _PlayersList({
    required this.players,
    required this.selectedMotive,
    required this.motiveColumns,
    required this.onMotiveTap,
  });

  final List<Map<String, dynamic>> players;
  final Map<int, int?> selectedMotive;
  final List<_MotiveColumn> motiveColumns;
  final void Function(int idJugador, int motiveId, bool presente) onMotiveTap;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      children: [
        // Header de la tabla
        _TableHeader(motiveColumns: motiveColumns),

        // Filas de jugadores
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final id = player['id'] as int;
              final currentMotive = selectedMotive[id];

              return _PlayerRow(
                player: player,
                currentMotive: currentMotive,
                motiveColumns: motiveColumns,
                onMotiveTap: (motiveId, presente) => onMotiveTap(id, motiveId, presente),
                isEven: index % 2 == 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Header de la tabla de asistencia
class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.motiveColumns});

  final List<_MotiveColumn> motiveColumns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: [
          // Columna JUGADOR
          const SizedBox(width: 56), // Espacio del avatar
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'JUGADOR',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Columna ESTADO DE ASISTENCIA
          SizedBox(
            width: motiveColumns.length * 44.0,
            child: Center(
              child: Text(
                'ESTADO DE ASISTENCIA',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de jugador con foto, nombre y botones de asistencia
class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.currentMotive,
    required this.motiveColumns,
    required this.onMotiveTap,
    required this.isEven,
  });

  final Map<String, dynamic> player;
  final int? currentMotive;
  final List<_MotiveColumn> motiveColumns;
  final void Function(int motiveId, bool presente) onMotiveTap;
  final bool isEven;

  bool get isPortero => player['idposicion'] == 1;

  @override
  Widget build(BuildContext context) {
    final nombre = player['nombre']?.toString() ?? '';
    final apellidos = player['apellidos']?.toString() ?? '';
    final dorsal = player['dorsal']?.toString() ?? '';
    final foto = player['foto']?.toString() ?? '';
    final nombreCompleto = '$nombre $apellidos'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          // Foto del jugador
          SizedBox(
            width: 56,
            child: _PlayerAvatar(foto: foto, dorsal: dorsal, isPortero: isPortero),
          ),

          // Nombre
          Expanded(
            flex: 2,
            child: Text(
              nombreCompleto,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Botones de asistencia
          ...motiveColumns.map((col) {
            // Tratar null como 0 (Falta)
            final effectiveMotive = currentMotive ?? 0;
            final isSelected = effectiveMotive == col.id;

            return _MotiveButton(
              column: col,
              isSelected: isSelected,
              onTap: () => onMotiveTap(col.id, col.id == 1),
            );
          }),
        ],
      ),
    );
  }
}

/// Avatar del jugador con foto o placeholder
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.foto,
    required this.dorsal,
    required this.isPortero,
  });

  final String foto;
  final String dorsal;
  final bool isPortero;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gray100,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            image: foto.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(foto),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: foto.isEmpty
              ? Center(
                  child: Text(
                    dorsal.isNotEmpty ? dorsal : '?',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.gray400,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
        // Badge de portero
        if (isPortero)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// Botón de motivo de asistencia clickeable
class _MotiveButton extends StatelessWidget {
  const _MotiveButton({
    required this.column,
    required this.isSelected,
    required this.onTap,
  });

  final _MotiveColumn column;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: column.tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 40,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? column.color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? column.color : AppColors.gray300,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: column.color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white.withValues(alpha: 0.5) : AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      column.label,
                      style: TextStyle(
                        fontSize: column.label.length > 1 ? 9 : 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : column.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CELoading.inline(),
          AppSpacing.vSpaceMd,
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
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

/// Vista vacía
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
}

/// Modelo para las columnas de motivos
class _MotiveColumn {
  const _MotiveColumn({
    required this.id,
    required this.label,
    required this.color,
    required this.tooltip,
  });

  final int id;
  final String label;
  final Color color;
  final String tooltip;
}
