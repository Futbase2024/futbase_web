import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';

/// Diálogo para crear/editar partido
class MatchFormDialog extends StatefulWidget {
  const MatchFormDialog({
    super.key,
    required this.idequipo,
    required this.idTemporada,
    this.match,
    required this.competitions,
    required this.onSaved,
  });

  final int idequipo;
  final int idTemporada;
  final Map<String, dynamic>? match;
  final Map<int, String> competitions;
  final VoidCallback onSaved;

  bool get isEditing => match != null;

  @override
  State<MatchFormDialog> createState() => _MatchFormDialogState();
}

class _MatchFormDialogState extends State<MatchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  late TextEditingController _rivalController;
  bool _local = true;
  int? _idCompeticion;
  late TextEditingController _observacionesController;
  int? _golesLocal;
  int? _golesVisitante;
  bool _finalizado = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fecha = widget.match != null
        ? DateTime.tryParse(widget.match!['fecha']?.toString() ?? '') ?? DateTime.now()
        : DateTime.now();

    if (widget.match?['hinicio'] != null) {
      final parts = widget.match!['hinicio'].toString().split(':');
      if (parts.length >= 2) {
        _horaInicio = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (widget.match?['hfin'] != null) {
      final parts = widget.match!['hfin'].toString().split(':');
      if (parts.length >= 2) {
        _horaFin = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    _rivalController = TextEditingController(text: widget.match?['rival']?.toString() ?? '');
    // casafuera: 1 = visitante, 0 o null = local
    final casafuera = widget.match?['casafuera'];
    _local = !(casafuera == 1 || casafuera == true);
    _idCompeticion = widget.match?['idcompeticion'] as int?;
    _observacionesController = TextEditingController(
      text: widget.match?['observaciones']?.toString() ?? '',
    );
    _golesLocal = widget.match?['goleslocal'] as int?;
    _golesVisitante = widget.match?['golesvisitante'] as int?;
    // finalizado: 1 = finalizado, 0 o null = no finalizado
    final finalizadoValue = widget.match?['finalizado'];
    _finalizado = finalizadoValue == 1 || finalizadoValue == true;
  }

  @override
  void dispose() {
    _rivalController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final horaInicioStr = _horaInicio != null
        ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
        : null;

    final horaFinStr = _horaFin != null
        ? '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}'
        : null;

    if (widget.isEditing) {
      context.read<MatchesBloc>().add(
            MatchUpdateRequested(
              id: widget.match!['id'] as int,
              idequipo: widget.idequipo,
              idTemporada: widget.idTemporada,
              fecha: _fecha,
              horaInicio: horaInicioStr,
              horaFin: horaFinStr,
              rival: _rivalController.text.trim(),
              local: _local,
              idcompeticion: _idCompeticion,
              observaciones: _observacionesController.text.trim().isEmpty
                  ? null
                  : _observacionesController.text.trim(),
              golesLocal: _golesLocal,
              golesVisitante: _golesVisitante,
              finalizado: _finalizado,
            ),
          );
    } else {
      context.read<MatchesBloc>().add(
            MatchCreateRequested(
              idequipo: widget.idequipo,
              idTemporada: widget.idTemporada,
              fecha: _fecha,
              horaInicio: horaInicioStr,
              horaFin: horaFinStr,
              rival: _rivalController.text.trim(),
              local: _local,
              idcompeticion: _idCompeticion,
              observaciones: _observacionesController.text.trim().isEmpty
                  ? null
                  : _observacionesController.text.trim(),
            ),
          );
    }

    widget.onSaved();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _selectTime(TimeOfDay? currentTime, void Function(TimeOfDay) onSelected) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isEditing ? Icons.edit : Icons.add,
                    color: AppColors.primary,
                  ),
                  AppSpacing.hSpaceSm,
                  Text(
                    widget.isEditing ? 'Editar Partido' : 'Nuevo Partido',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      _buildLabel('Fecha'),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: AppSpacing.borderRadiusMd,
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.gray500),
                              AppSpacing.hSpaceSm,
                              Text(
                                DateFormat('dd/MM/yyyy').format(_fecha),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.gray900,
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
                                InkWell(
                                  onTap: () => _selectTime(_horaInicio, (t) {
                                    setState(() => _horaInicio = t);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gray50,
                                      borderRadius: AppSpacing.borderRadiusMd,
                                      border: Border.all(color: AppColors.gray200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 18, color: AppColors.gray500),
                                        AppSpacing.hSpaceSm,
                                        Text(
                                          _horaInicio != null
                                              ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
                                              : 'Seleccionar',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: _horaInicio != null ? AppColors.gray900 : AppColors.gray400,
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
                                InkWell(
                                  onTap: () => _selectTime(_horaFin, (t) {
                                    setState(() => _horaFin = t);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gray50,
                                      borderRadius: AppSpacing.borderRadiusMd,
                                      border: Border.all(color: AppColors.gray200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 18, color: AppColors.gray500),
                                        AppSpacing.hSpaceSm,
                                        Text(
                                          _horaFin != null
                                              ? '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}'
                                              : 'Seleccionar',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: _horaFin != null ? AppColors.gray900 : AppColors.gray400,
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

                      // Rival
                      _buildLabel('Rival *'),
                      TextFormField(
                        controller: _rivalController,
                        decoration: _buildInputDecoration('Nombre del equipo rival'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El rival es obligatorio';
                          }
                          return null;
                        },
                      ),

                      AppSpacing.vSpaceMd,

                      // Local/Visitante
                      _buildLabel('Condición'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVenueOption(true, 'Local', Icons.home),
                          ),
                          AppSpacing.hSpaceSm,
                          Expanded(
                            child: _buildVenueOption(false, 'Visitante', Icons.flight_takeoff),
                          ),
                        ],
                      ),

                      AppSpacing.vSpaceMd,

                      // Competición
                      _buildLabel('Competición'),
                      DropdownButtonFormField<int?>(
                        initialValue: _idCompeticion,
                        decoration: _buildInputDecoration('Seleccionar competición'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Sin competición')),
                          ...widget.competitions.entries.map(
                            (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _idCompeticion = value);
                        },
                      ),

                      AppSpacing.vSpaceMd,

                      // Observaciones
                      _buildLabel('Observaciones'),
                      TextFormField(
                        controller: _observacionesController,
                        decoration: _buildInputDecoration('Notas adicionales'),
                        maxLines: 2,
                      ),

                      // Si está editando, mostrar opciones de resultado
                      if (widget.isEditing) ...[
                        AppSpacing.vSpaceMd,
                        const Divider(),
                        AppSpacing.vSpaceMd,

                        // Resultado
                        _buildLabel('Resultado'),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _golesLocal?.toString() ?? '',
                                decoration: _buildInputDecoration('Goles local'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _golesLocal = int.tryParse(value);
                                },
                              ),
                            ),
                            AppSpacing.hSpaceMd,
                            Expanded(
                              child: TextFormField(
                                initialValue: _golesVisitante?.toString() ?? '',
                                decoration: _buildInputDecoration('Goles visitante'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _golesVisitante = int.tryParse(value);
                                },
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.vSpaceMd,

                        // Finalizado
                        Row(
                          children: [
                            Checkbox(
                              value: _finalizado,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() => _finalizado = value ?? false);
                              },
                            ),
                            Text(
                              'Partido finalizado',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.gray700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  AppSpacing.hSpaceSm,
                  ElevatedButton(
                    onPressed: _isSaving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isSaving
                        ? const CELoading.button()
                        : Text(widget.isEditing ? 'Guardar cambios' : 'Crear partido'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.gray700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.gray400),
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildVenueOption(bool isLocal, String label, IconData icon) {
    final isSelected = _local == isLocal;

    return InkWell(
      onTap: () => setState(() => _local = isLocal),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLocal ? AppColors.success : AppColors.info).withValues(alpha: 0.1)
              : AppColors.gray50,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? (isLocal ? AppColors.success : AppColors.info)
                : AppColors.gray200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isLocal ? AppColors.success : AppColors.info)
                  : AppColors.gray400,
            ),
            AppSpacing.vSpaceXs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? (isLocal ? AppColors.success : AppColors.info)
                    : AppColors.gray500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
