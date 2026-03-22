import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';
import '../../bloc/fees_bloc.dart';
import '../../bloc/fees_event.dart';
import '../../bloc/fees_state.dart';
import '../widgets/fees_summary_card.dart';
import '../widgets/fees_filter_bar.dart';
import '../widgets/fees_fee_card.dart';
import '../widgets/payment_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/config/app_config_cubit.dart';

/// Página de gestión de cuotas del club
class FeesPage extends StatelessWidget {
  const FeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UsuariosEntity>();
    final appConfig = context.read<AppConfigCubit>();

    if (user.idclub == 0) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              AppSpacing.vSpaceMd,
              Text('No tienes un club asignado', style: AppTypography.h6),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => FeesBloc()
        ..add(FeesLoadRequested(
          idclub: user.idclub,
          activeSeasonId: appConfig.activeSeasonId,
        )),
      child: const _FeesView(),
    );
  }
}

class _FeesView extends StatelessWidget {
  const _FeesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: BlocConsumer<FeesBloc, FeesState>(
          listener: _onStateListener,
          builder: _buildContent,
        ),
      ),
    );
  }

  void _onStateListener(BuildContext context, FeesState state) {
    if (state is FeesError) {
      CeInfoDialog.error(
        context,
        title: 'Error',
        message: state.message,
      );
    }
  }

  Widget _buildContent(BuildContext context, FeesState state) {
    if (state is FeesInitial || state is FeesLoading) {
      return const CELoading.inline();
    }

    if (state is FeesError) {
      return _ErrorView(message: state.message);
    }

    if (state is FeesLoaded) {
      return _LoadedView(state: state);
    }

    return const SizedBox.shrink();
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final FeesLoaded state;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppConfigCubit, AppConfigState>(
      listenWhen: (prev, curr) => prev.activeSeasonId != curr.activeSeasonId,
      listener: (context, appState) {
        context.read<FeesBloc>().add(FeesRefreshRequested(
          idclub: state.idclub,
          activeSeasonId: appState.activeSeasonId,
        ));
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<FeesBloc>().add(FeesRefreshRequested(
            idclub: state.idclub,
            activeSeasonId: state.activeSeasonId,
          ));
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.euro,
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
                            'Gestión de Cuotas',
                            style: AppTypography.h5.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                          Text(
                            'Control de pagos y estado de cuotas',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // KPIs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: FeesSummaryCard(
                  totalEsperado: state.totalEsperado,
                  totalPagado: state.totalPagado,
                  totalPendiente: state.totalPendiente,
                  totalVencido: state.totalVencido,
                  countPagado: state.countPagado,
                  countPendiente: state.countPendiente,
                  countVencido: state.countVencido,
                ),
              ),
            ),
            // Chart + Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: SizedBox(
                  height: 340,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pie Chart
                      Expanded(child: _FeesChartCard(state: state)),
                      AppSpacing.hSpaceMd,
                      // Filters
                      Expanded(
                        flex: 2,
                        child: _FiltersCard(state: state),
                      ),
                    ],
                  ),
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
                          context.read<FeesBloc>().add(const FeesClearFilters());
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
                      onPayTap: () => _onPayTap(context, fee),
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
      ),
    );
  }

  Future<void> _onPayTap(BuildContext context, Map<String, dynamic> fee) async {
    final confirmed = await PaymentDialog.show(context, fee: fee);
    if (confirmed == true && context.mounted) {
      final cantidadRaw = fee['cantidad'];
      final cantidad = cantidadRaw is int
          ? cantidadRaw.toDouble()
          : (cantidadRaw as num?)?.toDouble() ?? 0.0;

      context.read<FeesBloc>().add(PaymentRegisterRequested(
        idCuota: fee['id'] as int,
        cantidad: cantidad,
        metodoPago: 'Efectivo',
      ));
    }
  }
}

class _FeesChartCard extends StatelessWidget {
  const _FeesChartCard({required this.state});

  final FeesLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        children: [
          Text(
            'Estado de Cuotas',
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (state.countPagado > 0)
                    PieChartSectionData(
                      value: state.countPagado.toDouble(),
                      color: AppColors.success,
                      title: '${state.countPagado}',
                      titleStyle: AppTypography.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      radius: 20,
                    ),
                  if (state.countPendiente > 0)
                    PieChartSectionData(
                      value: state.countPendiente.toDouble(),
                      color: AppColors.warning,
                      title: '${state.countPendiente}',
                      titleStyle: AppTypography.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      radius: 20,
                    ),
                  if (state.countVencido > 0)
                    PieChartSectionData(
                      value: state.countVencido.toDouble(),
                      color: AppColors.error,
                      title: '${state.countVencido}',
                      titleStyle: AppTypography.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      radius: 20,
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${state.percentageCollected.toStringAsFixed(0)}%',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            'COBRADO',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray400,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.state});

  final FeesLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          Text(
            'Filtros',
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          AppSpacing.vSpaceMd,
          Expanded(
            child: FeesFilterBar(
              teams: state.teams,
              selectedMonth: state.filterByMonth,
              selectedYear: state.filterByYear,
              selectedTeam: state.filterByTeam,
              selectedStatus: state.filterByStatus,
              searchQuery: state.searchQuery,
              onMonthChanged: (month) {
                context.read<FeesBloc>().add(FeesFilterByMonth(
                  month: month,
                  year: state.filterByYear,
                ));
              },
              onTeamChanged: (team) {
                context.read<FeesBloc>().add(FeesFilterByTeam(idEquipo: team));
              },
              onStatusChanged: (status) {
                context.read<FeesBloc>().add(FeesFilterByStatus(idEstado: status));
              },
              onSearchChanged: (query) {
                context.read<FeesBloc>().add(FeesSearchRequested(query: query));
              },
              onClearFilters: () {
                context.read<FeesBloc>().add(const FeesClearFilters());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            AppSpacing.vSpaceMd,
            Text('Error al cargar cuotas', style: AppTypography.h6),
            AppSpacing.vSpaceSm,
            Text(message, style: AppTypography.bodySmall, textAlign: TextAlign.center),
            AppSpacing.vSpaceMd,
            ElevatedButton(
              onPressed: () {
                final user = context.read<UsuariosEntity>();
                final appConfig = context.read<AppConfigCubit>();
                context.read<FeesBloc>().add(FeesLoadRequested(
                  idclub: user.idclub,
                  activeSeasonId: appConfig.activeSeasonId,
                ));
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
