import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/trainings_bloc.dart';
import '../../bloc/trainings_event.dart';

/// Diálogo para crear/editar entrenamiento
class TrainingFormDialog extends StatefulWidget {
  const TrainingFormDialog({
    super.key,
    required this.idequipo,
    this.training,
    required this.trainingTypes,
    required this.onSaved,
  });

  final int idequipo;
  final Map<String, dynamic>? training; // null = crear, no null = editar
  final Map<int, String> trainingTypes;
  final VoidCallback onSaved;

  @override
  State<TrainingFormDialog> createState() => _TrainingFormDialogState();
}

class _TrainingFormDialogState extends State<TrainingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _observacionesController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  int? _selectedType;
  bool _isSaving = false;

  bool get isEditing => widget.training != null;

  @override
  void initState() {
    super.initState();
    _observacionesController = TextEditingController();

    // Si es edición, cargar datos
    if (widget.training != null) {
      final t = widget.training!;
      _selectedDate = DateTime.tryParse(t['fecha']?.toString() ?? '') ?? DateTime.now();

      final horaInicioStr = t['hinicio']?.toString() ?? '';
      if (horaInicioStr.isNotEmpty) {
        _horaInicio = _parseTimeOfDay(horaInicioStr);
      }

      final horaFinStr = t['hfin']?.toString() ?? '';
      if (horaFinStr.isNotEmpty) {
        _horaFin = _parseTimeOfDay(horaFinStr);
      }

      // El campo nombre se usa como título del entrenamiento
      _observacionesController.text = t['nombre']?.toString() ?? t['observaciones']?.toString() ?? '';
      _observacionesController.text = t['observaciones']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  void _selectDate() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header con botones
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                border: Border(bottom: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Hecho',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // DatePicker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime(2020),
                maximumDate: DateTime(2030),
                onDateTimeChanged: (date) {
                  _selectedDate = date;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(bool isStart) {
    final initial = isStart
        ? (_horaInicio ?? const TimeOfDay(hour: 18, minute: 0))
        : (_horaFin ?? const TimeOfDay(hour: 19, minute: 30));

    DateTime tempDateTime = DateTime(
      2024,
      1,
      1,
      initial.hour,
      initial.minute,
    );

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header con botones
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                border: Border(bottom: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  Expanded(
                    child: Text(
                      isStart ? 'Hora de inicio' : 'Hora de fin',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        if (isStart) {
                          _horaInicio = TimeOfDay(
                            hour: tempDateTime.hour,
                            minute: tempDateTime.minute,
                          );
                        } else {
                          _horaFin = TimeOfDay(
                            hour: tempDateTime.hour,
                            minute: tempDateTime.minute,
                          );
                        }
                      });
                    },
                    child: Text(
                      'Hecho',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // TimePicker 24H
            Expanded(
              child: MediaQuery(
                data: const MediaQueryData(alwaysUse24HourFormat: true),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(2024, 1, 1, initial.hour, initial.minute),
                  onDateTimeChanged: (dateTime) {
                    tempDateTime = dateTime;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Obtener el BLoC del contexto padre
    final bloc = context.read<TrainingsBloc>();

    final horaInicioStr = _horaInicio != null
        ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
        : null;

    final horaFinStr = _horaFin != null
        ? '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}'
        : null;

    if (isEditing) {
      bloc.add(TrainingUpdateRequested(
        id: widget.training!['id'] as int,
        idequipo: widget.idequipo,
        fecha: _selectedDate,
        horaInicio: horaInicioStr,
        horaFin: horaFinStr,
        idtipo: _selectedType,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      ));
    } else {
      bloc.add(TrainingCreateRequested(
        idequipo: widget.idequipo,
        fecha: _selectedDate,
        horaInicio: horaInicioStr,
        horaFin: horaFinStr,
        idtipo: _selectedType,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      ));
    }

    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Text(
                    isEditing ? 'Editar entrenamiento' : 'Nuevo entrenamiento',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
              AppSpacing.vSpaceXl,

              // Fecha
              _buildLabel('Fecha'),
              AppSpacing.vSpaceSm,
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.gray500),
                      AppSpacing.hSpaceSm,
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(_selectedDate),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vSpaceMd,

              // Hora inicio y fin
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hora inicio'),
                        AppSpacing.vSpaceSm,
                        InkWell(
                          onTap: () => _selectTime(true),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 20, color: AppColors.gray500),
                                AppSpacing.hSpaceSm,
                                Text(
                                  _horaInicio != null
                                      ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
                                      : 'Seleccionar',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: _horaInicio != null
                                        ? AppColors.gray700
                                        : AppColors.gray400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hora fin'),
                        AppSpacing.vSpaceSm,
                        InkWell(
                          onTap: () => _selectTime(false),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 20, color: AppColors.gray500),
                                AppSpacing.hSpaceSm,
                                Text(
                                  _horaFin != null
                                      ? '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}'
                                      : 'Seleccionar',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: _horaFin != null
                                        ? AppColors.gray700
                                        : AppColors.gray400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.vSpaceMd,

              // Tipo de entrenamiento
              _buildLabel('Tipo de entrenamiento'),
              AppSpacing.vSpaceSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _selectedType,
                    isExpanded: true,
                    hint: const Text('Seleccionar tipo'),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.gray700),
                    items: widget.trainingTypes.entries
                        .map((e) => DropdownMenuItem<int?>(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                    },
                  ),
                ),
              ),
              AppSpacing.vSpaceMd,

              // Observaciones
              _buildLabel('Observaciones (opcional)'),
              AppSpacing.vSpaceSm,
              TextFormField(
                controller: _observacionesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notas sobre el entrenamiento...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              AppSpacing.vSpaceXl,

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  AppSpacing.hSpaceMd,
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CELoading.button(),
                          )
                        : Text(isEditing ? 'Guardar cambios' : 'Crear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.gray700,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
