import 'package:equatable/equatable.dart';

/// Eventos del BLoC de gestión de cuotas
abstract class FeesEvent extends Equatable {
  const FeesEvent();

  @override
  List<Object?> get props => [];
}

/// Carga inicial de cuotas
class FeesLoadRequested extends FeesEvent {
  final int idclub;
  final int activeSeasonId;

  const FeesLoadRequested({
    required this.idclub,
    required this.activeSeasonId,
  });

  @override
  List<Object?> get props => [idclub, activeSeasonId];
}

/// Refrescar datos manteniendo filtros
class FeesRefreshRequested extends FeesEvent {
  final int idclub;
  final int activeSeasonId;

  const FeesRefreshRequested({
    required this.idclub,
    required this.activeSeasonId,
  });

  @override
  List<Object?> get props => [idclub, activeSeasonId];
}

/// Filtrar por mes
class FeesFilterByMonth extends FeesEvent {
  final int? month;
  final int? year;

  const FeesFilterByMonth({
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

/// Filtrar por equipo
class FeesFilterByTeam extends FeesEvent {
  final int? idEquipo;

  const FeesFilterByTeam({this.idEquipo});

  @override
  List<Object?> get props => [idEquipo];
}

/// Filtrar por estado de pago
class FeesFilterByStatus extends FeesEvent {
  final int? idEstado;

  const FeesFilterByStatus({this.idEstado});

  @override
  List<Object?> get props => [idEstado];
}

/// Filtrar por método de pago
class FeesFilterByPaymentMethod extends FeesEvent {
  final int? idPaymentMethod;

  const FeesFilterByPaymentMethod({this.idPaymentMethod});

  @override
  List<Object?> get props => [idPaymentMethod];
}

/// Búsqueda de jugador
class FeesSearchRequested extends FeesEvent {
  final String query;

  const FeesSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Limpiar todos los filtros
class FeesClearFilters extends FeesEvent {
  const FeesClearFilters();
}

/// Registrar un pago
class PaymentRegisterRequested extends FeesEvent {
  final int idCuota;
  final double cantidad;
  final String metodoPago;
  final String? concepto;

  const PaymentRegisterRequested({
    required this.idCuota,
    required this.cantidad,
    required this.metodoPago,
    this.concepto,
  });

  @override
  List<Object?> get props => [idCuota, cantidad, metodoPago, concepto];
}
