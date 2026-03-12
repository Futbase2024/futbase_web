import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import 'package:intl/intl.dart';

import '../../bloc/reports_bloc.dart';
import '../../bloc/reports_event.dart';
import '../../bloc/reports_state.dart';
import '../../domain/saved_report_entity.dart';
import 'pdf_viewer_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/config/app_config_cubit.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Contenido de informes para integrar en el dashboard
class ReportsContent extends StatefulWidget {
  const ReportsContent({
    super.key,
    required this.user,
    required this.userRole,
  });

  final UsuariosEntity user;
  final UserRole userRole;

  @override
  State<ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends State<ReportsContent> {
  late final ReportsBloc _reportsBloc;

  @override
  void initState() {
    super.initState();
    _reportsBloc = ReportsBloc();
    _initializeReports();
  }

  @override
  void dispose() {
    _reportsBloc.close();
    super.dispose();
  }

  void _initializeReports() {
    final appConfigCubit = context.read<AppConfigCubit>();
    final activeSeasonId = appConfigCubit.activeSeasonId;
    final userRoleName = widget.userRole.name;

    _reportsBloc.add(ReportsInitialized(
      activeSeasonId: activeSeasonId,
      clubId: widget.user.idclub,
      teamId: widget.user.idequipo,
      userRole: userRoleName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reportsBloc,
      child: BlocListener<AppConfigCubit, AppConfigState>(
        listenWhen: (previous, current) =>
            previous.activeSeasonId != current.activeSeasonId,
        listener: (context, configState) {
          _initializeReports();
        },
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            return switch (state) {
              ReportsInitial() => const CELoading.inline(),
              ReportsLoading() => const CELoading.inline(),
              SavedReportsLoaded(
                :final reports,
                :final filterType,
                :final userRole,
                :final clubId,
                :final teamId,
              ) =>
                _buildReportsList(
                  reports: reports,
                  filterType: filterType,
                  userRole: userRole,
                  clubId: clubId,
                  teamId: teamId,
                ),
              ReportsError(:final message) => _buildErrorWidget(message),
              _ => const CELoading.inline(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildReportsList({
    required List<SavedReportEntity> reports,
    required SavedReportType? filterType,
    required String userRole,
    required int? clubId,
    required int? teamId,
  }) {
    final filteredReports = filterType == null
        ? reports
        : reports.where((r) => r.reportType == filterType).toList();

    return Column(
      children: [
        // Header con filtros
        _buildHeaderWithFilters(filterType, userRole),

        // Lista de informes
        Expanded(
          child: filteredReports.isEmpty
              ? _buildEmptyState()
              : _buildReportsListView(filteredReports),
        ),
      ],
    );
  }

  Widget _buildHeaderWithFilters(SavedReportType? filterType, String userRole) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Título
          Text(
            'Informes',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(width: 24),

          // Filtros por tipo
          Expanded(
            child: _ReportTypeFilters(
              selectedType: filterType,
              onTypeSelected: (type) {
                _reportsBloc.add(FilterSavedReports(filterType: type));
              },
            ),
          ),

          // Indicador de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getRoleIcon(),
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getRoleLabel(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsListView(List<SavedReportEntity> reports) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 180,
        ),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _ReportCard(
            report: report,
            onView: () => _viewReport(report),
            onDelete: () => _confirmDelete(report),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay informes guardados',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los informes generados aparecerán aquí',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  void _viewReport(SavedReportEntity report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(report: report),
      ),
    );
  }

  void _confirmDelete(SavedReportEntity report) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Eliminar informe'),
        content: Text('¿Estás seguro de que quieres eliminar "${report.informe}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _reportsBloc.add(DeleteSavedReport(reportId: report.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    return switch (widget.userRole) {
      UserRole.club => Icons.business,
      UserRole.coordinador => Icons.supervisor_account,
      UserRole.entrenador => Icons.sports_soccer,
      UserRole.superAdmin => Icons.admin_panel_settings,
    };
  }

  String _getRoleLabel() {
    return switch (widget.userRole) {
      UserRole.club => 'Vista Club',
      UserRole.coordinador => 'Vista Coordinador',
      UserRole.entrenador => 'Mi Equipo',
      UserRole.superAdmin => 'Super Admin',
    };
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error al cargar informes',
            style: AppTypography.h6.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeReports,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtros de tipo de informe
class _ReportTypeFilters extends StatelessWidget {
  const _ReportTypeFilters({
    required this.selectedType,
    required this.onTypeSelected,
  });

  final SavedReportType? selectedType;
  final ValueChanged<SavedReportType?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SavedReportType.values.map((type) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _FilterButton(
            type: type,
            isSelected: selectedType == type,
            onTap: () => onTypeSelected(selectedType == type ? null : type),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final SavedReportType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 120,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.gray500,
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.gray700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de informe elegante para grid
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onView,
    required this.onDelete,
  });

  final SavedReportEntity report;
  final VoidCallback onView;
  final VoidCallback onDelete;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con gradiente y icono
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        typeColor.withValues(alpha: 0.1),
                        typeColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: typeColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        report.reportType.icon,
                        size: 28,
                        color: typeColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de tipo
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          report.reportType.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Título del informe
                      Text(
                        report.informe,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      // Fecha y acciones
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _dateFormat.format(report.fechaSubida),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.gray500,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Botón eliminar
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 14,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    return switch (report.reportType) {
      SavedReportType.partidos => AppColors.primary,
      SavedReportType.entrenamientos => AppColors.success,
      SavedReportType.jugadores => AppColors.info,
      SavedReportType.convocatorias => AppColors.warning,
    };
  }
}
