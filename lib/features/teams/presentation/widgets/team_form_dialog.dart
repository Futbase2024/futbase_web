import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Diálogo para crear o editar un equipo
class TeamFormDialog extends StatefulWidget {
  const TeamFormDialog({
    super.key,
    required this.idclub,
    required this.categories,
    required this.seasons,
    this.initialData,
    this.isEditing = false,
  });

  final int idclub;
  final Map<int, String> categories;
  final Map<int, String> seasons;
  final Map<String, dynamic>? initialData;
  final bool isEditing;

  @override
  State<TeamFormDialog> createState() => _TeamFormDialogState();
}

class _TeamFormDialogState extends State<TeamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _equipoController;
  late final TextEditingController _ncortoController;
  late final TextEditingController _titularesController;
  late final TextEditingController _minutosController;

  int? _selectedCategory;
  int? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _equipoController = TextEditingController(
      text: widget.initialData?['equipo'] as String? ?? '',
    );
    _ncortoController = TextEditingController(
      text: widget.initialData?['ncorto'] as String? ?? '',
    );
    _titularesController = TextEditingController(
      text: (widget.initialData?['titulares'] as int?)?.toString() ?? '11',
    );
    _minutosController = TextEditingController(
      text: (widget.initialData?['minutos'] as int?)?.toString() ?? '45',
    );

    // Seleccionar categoría y temporada si hay datos iniciales
    if (widget.initialData != null) {
      _selectedCategory = widget.initialData!['idcategoria'] as int?;
      _selectedSeason = widget.initialData!['idtemporada'] as int?;
    } else {
      // Seleccionar primera temporada por defecto (la más reciente)
      if (widget.seasons.isNotEmpty) {
        _selectedSeason = widget.seasons.keys.first;
      }
    }
  }

  @override
  void dispose() {
    _equipoController.dispose();
    _ncortoController.dispose();
    _titularesController.dispose();
    _minutosController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'equipo': _equipoController.text.trim(),
        'ncorto': _ncortoController.text.trim().isEmpty
            ? null
            : _ncortoController.text.trim(),
        'idcategoria': _selectedCategory,
        'idtemporada': _selectedSeason,
        'titulares': int.tryParse(_titularesController.text) ?? 11,
        'minutos': int.tryParse(_minutosController.text) ?? 45,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.isEditing ? Icons.edit : Icons.add,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Text(
                    widget.isEditing ? 'Editar Equipo' : 'Nuevo Equipo',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del equipo
                      _buildTextField(
                        controller: _equipoController,
                        label: 'Nombre del equipo',
                        hint: 'Ej: SENIOR, CADETE A, JUVENIL B',
                        icon: Icons.groups_outlined,
                        isRequired: true,
                      ),
                      AppSpacing.vSpaceMd,

                      // Nombre corto
                      _buildTextField(
                        controller: _ncortoController,
                        label: 'Nombre corto (opcional)',
                        hint: 'Ej: SEN, CAD-A, JUV-B',
                        icon: Icons.short_text,
                      ),
                      AppSpacing.vSpaceMd,

                      // Categoría
                      _buildDropdown(
                        label: 'Categoría',
                        value: _selectedCategory,
                        items: widget.categories,
                        icon: Icons.category_outlined,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                      AppSpacing.vSpaceMd,

                      // Temporada
                      _buildDropdown(
                        label: 'Temporada',
                        value: _selectedSeason,
                        items: widget.seasons,
                        icon: Icons.calendar_today_outlined,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() => _selectedSeason = value);
                        },
                      ),
                      AppSpacing.vSpaceMd,

                      // Titulares y minutos
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _titularesController,
                              label: 'Titulares',
                              hint: '11',
                              icon: Icons.people_outline,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          AppSpacing.hSpaceMd,
                          Expanded(
                            child: _buildTextField(
                              controller: _minutosController,
                              label: 'Minutos/parte',
                              hint: '45',
                              icon: Icons.timer_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer con botones
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(
                      widget.isEditing ? Icons.save : Icons.add,
                      size: 18,
                    ),
                    label: Text(widget.isEditing ? 'Guardar' : 'Crear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.gray400),
            AppSpacing.hSpaceXs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        AppSpacing.vSpaceXs,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.gray900,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required Map<int, String> items,
    required IconData icon,
    required bool isRequired,
    required void Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.gray400),
            AppSpacing.hSpaceXs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        AppSpacing.vSpaceXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Seleccionar $label',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
              ),
              items: items.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.gray400,
              ),
              borderRadius: BorderRadius.circular(10),
              dropdownColor: Colors.white,
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }
}
