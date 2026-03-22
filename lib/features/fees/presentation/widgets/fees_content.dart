import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../bloc/fees_bloc.dart';
import '../../bloc/fees_event.dart';
import '../../bloc/fees_state.dart';
import 'fees_summary_card.dart';
import 'fees_fee_card.dart';
import 'payment_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/config/app_config_cubit.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Contenido de la página de gestión de cuotas
class FeesContent extends StatefulWidget {
  const FeesContent({
    super.key,
    required this.user,
  });

  final UsuariosEntity user;

  @override
  State<FeesContent> createState() => _FeesContentState();
}

class _FeesContentState extends State<FeesContent> {
  late final FeesBloc _feesBloc;

  @override
  void initState() {
    super.initState();
    _feesBloc = FeesBloc();
    _loadFees();
  }

  @override
  void dispose() {
    _feesBloc.close();
    super.dispose();
  }

  void _loadFees() {
    final idclub = widget.user.idclub;
    if (idclub > 0) {
      final appConfigCubit = context.read<AppConfigCubit>();
      final activeSeasonId = appConfigCubit.activeSeasonId;

      debugPrint('💰 [FEES] Cargando cuotas: idclub=$idclub, temporada=$activeSeasonId');

      _feesBloc.add(FeesLoadRequested(
        idclub: idclub,
        activeSeasonId: activeSeasonId,
      ));
    }
  }

  Future<void> _onPayTap(Map<String, dynamic> fee) async {
    final confirmed = await PaymentDialog.show(context, fee: fee);
    if (confirmed == true && mounted) {
      final cantidadRaw = fee['cantidad'];
      final cantidad = cantidadRaw is int
          ? cantidadRaw.toDouble()
          : (cantidadRaw as num?)?.toDouble() ?? 0.0;

      _feesBloc.add(PaymentRegisterRequested(
        idCuota: fee['id'] as int,
        cantidad: cantidad,
        metodoPago: 'Efectivo',
      ));
    }
  }

  Future<void> _showFiltersDialog(FeesLoaded state) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _FiltersDialog(
        state: state,
        bloc: _feesBloc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.idclub == 0) {
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
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No tienes un club asignado',
              style: AppTypography.h6.copyWith(color: AppColors.gray900),
            ),
          ],
        ),
      );
    }

    return BlocProvider.value(
      value: _feesBloc,
      child: BlocListener<AppConfigCubit, AppConfigState>(
        listenWhen: (previous, current) =>
            previous.activeSeasonId != current.activeSeasonId,
        listener: (context, configState) {
          debugPrint('💰 [FEES] Temporada cambiada a: ${configState.activeSeasonName}');
          _loadFees();
        },
        child: BlocConsumer<FeesBloc, FeesState>(
          listener: (context, state) {
            if (state is FeesError) {
              CeInfoDialog.error(
                context,
                title: 'Error',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFB),
              body: SafeArea(
                child: _buildContent(state),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(FeesState state) {
    if (state is FeesInitial || state is FeesLoading) {
      return const CELoading.inline();
    }

    if (state is FeesError) {
      return _buildErrorWidget(state.message);
    }

    if (state is FeesLoaded) {
      return _buildLoadedContent(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadedContent(FeesLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _feesBloc.add(FeesRefreshRequested(
          idclub: state.idclub,
          activeSeasonId: state.activeSeasonId,
        ));
      },
      child: CustomScrollView(
        slivers: [
          // Header con KPIs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  // KPIs en fila horizontal (como estaban antes)
                  FeesSummaryCard(
                    totalEsperado: state.totalEsperado,
                    totalPagado: state.totalPagado,
                    totalPendiente: state.totalPendiente,
                    totalVencido: state.totalVencido,
                    countPagado: state.countPagado,
                    countPendiente: state.countPendiente,
                    countVencido: state.countVencido,
                  ),
                  AppSpacing.vSpaceSm,
                  // Botón de filtros
                  Row(
                    children: [
                      // Indicador de filtros activos
                      if (state.hasActiveFilters) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_list, size: 14, color: AppColors.primary),
                              AppSpacing.hSpaceXs,
                              Text(
                                'Filtros activos',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hSpaceSm,
                      ],
                      const Spacer(),
                      // Botón de filtros
                      OutlinedButton.icon(
                        onPressed: () => _showFiltersDialog(state),
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text('Filtrar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gray700,
                          side: BorderSide(color: AppColors.gray300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // List header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Cuotas (${state.filteredFees.length})',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const Spacer(),
                  if (state.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        _feesBloc.add(const FeesClearFilters());
                      },
                      child: Text(
                        'Limpiar filtros',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final fee = state.filteredFees[index];
                  return FeesFeeCard(
                    fee: fee,
                    onPayTap: () => _onPayTap(fee),
                  );
                },
                childCount: state.filteredFees.length,
              ),
            ),
          ),
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'Error al cargar cuotas',
              style: AppTypography.h6.copyWith(color: AppColors.gray900),
            ),
            AppSpacing.vSpaceSm,
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceMd,
            ElevatedButton.icon(
              onPressed: _loadFees,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de filtros profesional
class _FiltersDialog extends StatefulWidget {
  const _FiltersDialog({
    required this.state,
    required this.bloc,
  });

  final FeesLoaded state;
  final FeesBloc bloc;

  @override
  State<_FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<_FiltersDialog> {
  late int? _selectedMonth;
  late int? _selectedYear;
  late int? _selectedTeam;
  late int? _selectedStatus;
  late String _searchQuery;

  static const List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  // Filtros de estado: Pendiente (2) y Pagado (todos los demás)
  static const Map<int, String> _statusNames = {
    2: 'Pendiente',
    1: 'Pagado',
  };

  // Métodos de pago
  static const Map<int, String> _paymentMethodNames = {
    1: 'Efectivo',
    3: 'Tarjeta',
    4: 'Transferencia',
    5: 'Bizum',
  };

  late int? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.state.filterByMonth;
    _selectedYear = widget.state.filterByYear;
    _selectedTeam = widget.state.filterByTeam;
    _selectedStatus = widget.state.filterByStatus;
    _selectedPaymentMethod = widget.state.filterByPaymentMethod;
    _searchQuery = widget.state.searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
                  ),
                  AppSpacing.hSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtros de Cuotas',
                          style: AppTypography.h6.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        Text(
                          'Filtra las cuotas por diferentes criterios',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Búsqueda
                    Text(
                      'Buscar jugador',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    TextField(
                      onChanged: (value) => _searchQuery = value,
                      controller: TextEditingController(text: _searchQuery)
                        ..selection = TextSelection.collapsed(offset: _searchQuery.length),
                      decoration: InputDecoration(
                        hintText: 'Nombre o equipo...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                        filled: true,
                        fillColor: AppColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    AppSpacing.vSpaceMd,
                    // Mes
                    Text(
                      'Mes',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: 'Todos',
                          selected: _selectedMonth == null,
                          onSelected: () => setState(() => _selectedMonth = null),
                        ),
                        ...List.generate(12, (i) => _buildChoiceChip(
                          label: _monthNames[i].substring(0, 3),
                          selected: _selectedMonth == i + 1,
                          onSelected: () => setState(() => _selectedMonth = i + 1),
                        )),
                      ],
                    ),
                    AppSpacing.vSpaceMd,
                    // Equipo
                    Text(
                      'Equipo',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: 'Todos',
                          selected: _selectedTeam == null,
                          onSelected: () => setState(() => _selectedTeam = null),
                        ),
                        ...widget.state.teams.entries.map((e) => _buildChoiceChip(
                          label: e.value,
                          selected: _selectedTeam == e.key,
                          onSelected: () => setState(() => _selectedTeam = e.key),
                        )),
                      ],
                    ),
                    AppSpacing.vSpaceMd,
                    // Estado
                    Text(
                      'Estado',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: 'Todos',
                          selected: _selectedStatus == null,
                          onSelected: () => setState(() => _selectedStatus = null),
                        ),
                        ..._statusNames.entries.map((e) => _buildChoiceChip(
                          label: e.value,
                          selected: _selectedStatus == e.key,
                          onSelected: () => setState(() => _selectedStatus = e.key),
                          color: _getStatusColor(e.key),
                        )),
                      ],
                    ),
                    AppSpacing.vSpaceMd,
                    // Tipo de cobro
                    Text(
                      'Tipo de cobro',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: 'Todos',
                          selected: _selectedPaymentMethod == null,
                          onSelected: () => setState(() => _selectedPaymentMethod = null),
                        ),
                        ..._paymentMethodNames.entries.map((e) => _buildChoiceChip(
                          label: e.value,
                          selected: _selectedPaymentMethod == e.key,
                          onSelected: () => setState(() => _selectedPaymentMethod = e.key),
                          color: AppColors.primary,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = null;
                          _selectedYear = null;
                          _selectedTeam = null;
                          _selectedStatus = null;
                          _searchQuery = '';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray700,
                        side: BorderSide(color: AppColors.gray300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Aplicar filtros'),
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

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.1) : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : AppColors.gray200,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: selected ? chipColor : AppColors.gray600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: return AppColors.primary; // Pagado
      case 2: return AppColors.warning; // Pendiente
      default: return AppColors.gray400;
    }
  }

  void _applyFilters() {
    // Aplicar búsqueda
    if (_searchQuery != widget.state.searchQuery) {
      widget.bloc.add(FeesSearchRequested(query: _searchQuery));
    }

    // Aplicar filtro de mes
    if (_selectedMonth != widget.state.filterByMonth) {
      widget.bloc.add(FeesFilterByMonth(month: _selectedMonth, year: _selectedYear));
    }

    // Aplicar filtro de equipo
    if (_selectedTeam != widget.state.filterByTeam) {
      widget.bloc.add(FeesFilterByTeam(idEquipo: _selectedTeam));
    }

    // Aplicar filtro de estado
    if (_selectedStatus != widget.state.filterByStatus) {
      widget.bloc.add(FeesFilterByStatus(idEstado: _selectedStatus));
    }

    // Aplicar filtro de método de pago
    if (_selectedPaymentMethod != widget.state.filterByPaymentMethod) {
      widget.bloc.add(FeesFilterByPaymentMethod(idPaymentMethod: _selectedPaymentMethod));
    }

    Navigator.of(context).pop();
  }
}
