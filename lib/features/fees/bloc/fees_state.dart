import 'package:equatable/equatable.dart';

/// Estados del BLoC de gestión de cuotas
abstract class FeesState extends Equatable {
  const FeesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FeesInitial extends FeesState {
  const FeesInitial();
}

/// Estado de carga
class FeesLoading extends FeesState {
  const FeesLoading();
}

/// Estado con datos cargados
class FeesLoaded extends FeesState {
  final List<Map<String, dynamic>> fees;
  final List<Map<String, dynamic>> filteredFees;
  final Map<int, String> teams;
  final Map<int, String> players;

  // Filtros activos
  final String searchQuery;
  final int? filterByMonth;
  final int? filterByYear;
  final int? filterByTeam;
  final int? filterByStatus;
  final int? filterByPaymentMethod;

  // Resumen financiero
  final double totalEsperado;
  final double totalPagado;
  final double totalPendiente;
  final double totalVencido;

  // Contadores
  final int countPagado;
  final int countPendiente;
  final int countVencido;

  final int idclub;
  final int activeSeasonId;
  final bool isRefreshing;
  final bool isProcessingPayment;

  const FeesLoaded({
    required this.fees,
    required this.filteredFees,
    required this.teams,
    required this.players,
    required this.totalEsperado,
    required this.totalPagado,
    required this.totalPendiente,
    required this.totalVencido,
    required this.countPagado,
    required this.countPendiente,
    required this.countVencido,
    required this.idclub,
    required this.activeSeasonId,
    this.searchQuery = '',
    this.filterByMonth,
    this.filterByYear,
    this.filterByTeam,
    this.filterByStatus,
    this.filterByPaymentMethod,
    this.isRefreshing = false,
    this.isProcessingPayment = false,
  });

  @override
  List<Object?> get props => [
        fees,
        filteredFees,
        teams,
        players,
        searchQuery,
        filterByMonth,
        filterByYear,
        filterByTeam,
        filterByStatus,
        filterByPaymentMethod,
        totalEsperado,
        totalPagado,
        totalPendiente,
        totalVencido,
        countPagado,
        countPendiente,
        countVencido,
        idclub,
        activeSeasonId,
        isRefreshing,
        isProcessingPayment,
      ];

  /// Porcentaje de cuotas cobradas
  double get percentageCollected =>
      totalEsperado > 0 ? (totalPagado / totalEsperado) * 100 : 0;

  /// Verifica si hay filtros activos
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      filterByMonth != null ||
      filterByTeam != null ||
      filterByStatus != null ||
      filterByPaymentMethod != null;

  /// Copia con nuevos valores
  FeesLoaded copyWith({
    List<Map<String, dynamic>>? fees,
    List<Map<String, dynamic>>? filteredFees,
    Map<int, String>? teams,
    Map<int, String>? players,
    String? searchQuery,
    int? filterByMonth,
    int? filterByYear,
    int? filterByTeam,
    int? filterByStatus,
    int? filterByPaymentMethod,
    double? totalEsperado,
    double? totalPagado,
    double? totalPendiente,
    double? totalVencido,
    int? countPagado,
    int? countPendiente,
    int? countVencido,
    int? idclub,
    int? activeSeasonId,
    bool? isRefreshing,
    bool? isProcessingPayment,
  }) {
    return FeesLoaded(
      fees: fees ?? this.fees,
      filteredFees: filteredFees ?? this.filteredFees,
      teams: teams ?? this.teams,
      players: players ?? this.players,
      searchQuery: searchQuery ?? this.searchQuery,
      filterByMonth: filterByMonth ?? this.filterByMonth,
      filterByYear: filterByYear ?? this.filterByYear,
      filterByTeam: filterByTeam ?? this.filterByTeam,
      filterByStatus: filterByStatus ?? this.filterByStatus,
      filterByPaymentMethod: filterByPaymentMethod ?? this.filterByPaymentMethod,
      totalEsperado: totalEsperado ?? this.totalEsperado,
      totalPagado: totalPagado ?? this.totalPagado,
      totalPendiente: totalPendiente ?? this.totalPendiente,
      totalVencido: totalVencido ?? this.totalVencido,
      countPagado: countPagado ?? this.countPagado,
      countPendiente: countPendiente ?? this.countPendiente,
      countVencido: countVencido ?? this.countVencido,
      idclub: idclub ?? this.idclub,
      activeSeasonId: activeSeasonId ?? this.activeSeasonId,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
    );
  }
}

/// Estado de error
class FeesError extends FeesState {
  final String message;

  const FeesError({required this.message});

  @override
  List<Object?> get props => [message];
}
