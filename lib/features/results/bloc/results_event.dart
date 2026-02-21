import 'package:equatable/equatable.dart';

import 'results_state.dart';

/// Eventos del BLoC de Resultados
abstract class ResultsEvent extends Equatable {
  const ResultsEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar resultados de una semana específica
class ResultsLoadWeekRequested extends ResultsEvent {
  final DateTime weekStart;
  final int idtemporada;
  final int? idclub;

  const ResultsLoadWeekRequested({
    required this.weekStart,
    required this.idtemporada,
    this.idclub,
  });

  @override
  List<Object?> get props => [weekStart, idtemporada, idclub];
}

/// Navegar a la semana anterior
class ResultsPreviousWeek extends ResultsEvent {
  const ResultsPreviousWeek();
}

/// Navegar a la siguiente semana
class ResultsNextWeek extends ResultsEvent {
  const ResultsNextWeek();
}

/// Ir a la semana actual (Hoy)
class ResultsGoToToday extends ResultsEvent {
  const ResultsGoToToday();
}

/// Refrescar datos de la semana actual (pull-to-refresh)
class ResultsRefreshRequested extends ResultsEvent {
  const ResultsRefreshRequested();
}

/// Cambiar alcance del filtro (todos o mi club)
class ResultsFilterByScope extends ResultsEvent {
  final ResultsScope scope;

  const ResultsFilterByScope({required this.scope});

  @override
  List<Object?> get props => [scope];
}

/// Filtrar por estado del partido (live, scheduled, finished)
class ResultsFilterByStatus extends ResultsEvent {
  final MatchStatusFilter? status;

  const ResultsFilterByStatus({this.status});

  @override
  List<Object?> get props => [status];
}

/// Limpiar todos los filtros
class ResultsClearFilters extends ResultsEvent {
  const ResultsClearFilters();
}

/// Toggle modo live (activa/desactiva actualizacion automatica)
class ResultsToggleLiveMode extends ResultsEvent {
  const ResultsToggleLiveMode();
}

/// Seleccionar un día del calendario
class ResultsSelectDate extends ResultsEvent {
  final DateTime date;

  const ResultsSelectDate({required this.date});

  @override
  List<Object?> get props => [date];
}
