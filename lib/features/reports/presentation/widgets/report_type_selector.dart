import 'package:flutter/material.dart';

import '../../domain/report_types.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget para seleccionar el tipo de informe
class ReportTypeSelector extends StatelessWidget {
  const ReportTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final ReportType selectedType;
  final ValueChanged<ReportType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el tipo de informe',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        // Primera fila: 3 tarjetas
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ReportTypeCard(
                  type: ReportType.player,
                  isSelected: selectedType == ReportType.player,
                  onTap: () => onTypeSelected(ReportType.player),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportTypeCard(
                  type: ReportType.match,
                  isSelected: selectedType == ReportType.match,
                  onTap: () => onTypeSelected(ReportType.match),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportTypeCard(
                  type: ReportType.convocatoria,
                  isSelected: selectedType == ReportType.convocatoria,
                  onTap: () => onTypeSelected(ReportType.convocatoria),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Segunda fila: 2 tarjetas centradas
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ReportTypeCard(
                  type: ReportType.attendanceMonthly,
                  isSelected: selectedType == ReportType.attendanceMonthly,
                  onTap: () => onTypeSelected(ReportType.attendanceMonthly),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportTypeCard(
                  type: ReportType.teamStats,
                  isSelected: selectedType == ReportType.teamStats,
                  onTap: () => onTypeSelected(ReportType.teamStats),
                ),
              ),
              // Espacio vacío para mantener 2 tarjetas centradas visualmente
              // en caso de querer 3 columnas simétricas, quitar este Expanded
              // y ajustar el Row a mainAxisSize: MainAxisSize.center
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportTypeCard extends StatelessWidget {
  const _ReportTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ReportType type;
  final bool isSelected;
  final VoidCallback onTap;

  IconData _getIcon() {
    return switch (type) {
      ReportType.player => Icons.person_outline,
      ReportType.match => Icons.sports_soccer,
      ReportType.convocatoria => Icons.groups_outlined,
      ReportType.attendanceMonthly => Icons.calendar_today_outlined,
      ReportType.teamStats => Icons.bar_chart_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(),
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.gray500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                type.title,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.gray900,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
