import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:futbase_web_3/core/datasources/datasources.dart';

import 'fees_event.dart';
import 'fees_state.dart';

/// BLoC para gestión de cuotas del club
class FeesBloc extends Bloc<FeesEvent, FeesState> {
  final AppDataSource _datasource;

  FeesBloc({AppDataSource? datasource})
      : _datasource = datasource ?? DataSourceFactory.instance,
        super(const FeesInitial()) {
    on<FeesLoadRequested>(_onLoadRequested);
    on<FeesRefreshRequested>(_onRefreshRequested);
    on<FeesFilterByMonth>(_onFilterByMonth);
    on<FeesFilterByTeam>(_onFilterByTeam);
    on<FeesFilterByStatus>(_onFilterByStatus);
    on<FeesFilterByPaymentMethod>(_onFilterByPaymentMethod);
    on<FeesSearchRequested>(_onSearchRequested);
    on<FeesClearFilters>(_onClearFilters);
    on<PaymentRegisterRequested>(_onPaymentRegisterRequested);
  }

  /// Carga inicial de cuotas
  Future<void> _onLoadRequested(
    FeesLoadRequested event,
    Emitter<FeesState> emit,
  ) async {
    debugPrint('🔵 [FeesBloc] Cargando cuotas del club: ${event.idclub}');
    emit(const FeesLoading());

    try {
      final data = await _loadFeesData(
        event.idclub,
        event.activeSeasonId,
      );

      emit(FeesLoaded(
        fees: data['fees'],
        filteredFees: data['filteredFees'],
        teams: data['teams'],
        players: data['players'],
        totalEsperado: data['totalEsperado'],
        totalPagado: data['totalPagado'],
        totalPendiente: data['totalPendiente'],
        totalVencido: data['totalVencido'],
        countPagado: data['countPagado'],
        countPendiente: data['countPendiente'],
        countVencido: data['countVencido'],
        idclub: event.idclub,
        activeSeasonId: event.activeSeasonId,
      ));
    } catch (e) {
      debugPrint('❌ [FeesBloc] Error al cargar cuotas: $e');
      emit(FeesError(message: e.toString()));
    }
  }

  /// Refrescar datos manteniendo filtros
  Future<void> _onRefreshRequested(
    FeesRefreshRequested event,
    Emitter<FeesState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    int? currentMonth;
    int? currentYear;
    int? currentTeam;
    int? currentStatus;

    if (currentState is FeesLoaded) {
      currentSearch = currentState.searchQuery;
      currentMonth = currentState.filterByMonth;
      currentYear = currentState.filterByYear;
      currentTeam = currentState.filterByTeam;
      currentStatus = currentState.filterByStatus;
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      final data = await _loadFeesData(
        event.idclub,
        event.activeSeasonId,
      );

      var filteredFees = data['fees'] as List<Map<String, dynamic>>;

      // Reaplicar filtros anteriores
      if (currentSearch.isNotEmpty) {
        filteredFees = _filterBySearch(filteredFees, currentSearch);
      }
      if (currentMonth != null) {
        filteredFees = _filterByMonthValue(filteredFees, currentMonth, currentYear);
      }
      if (currentTeam != null) {
        filteredFees = _filterByTeamId(filteredFees, currentTeam);
      }
      if (currentStatus != null) {
        filteredFees = _filterByStatusValue(filteredFees, currentStatus);
      }

      emit(FeesLoaded(
        fees: data['fees'],
        filteredFees: filteredFees,
        teams: data['teams'],
        players: data['players'],
        searchQuery: currentSearch,
        filterByMonth: currentMonth,
        filterByYear: currentYear,
        filterByTeam: currentTeam,
        filterByStatus: currentStatus,
        totalEsperado: data['totalEsperado'],
        totalPagado: data['totalPagado'],
        totalPendiente: data['totalPendiente'],
        totalVencido: data['totalVencido'],
        countPagado: data['countPagado'],
        countPendiente: data['countPendiente'],
        countVencido: data['countVencido'],
        idclub: event.idclub,
        activeSeasonId: event.activeSeasonId,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(FeesError(message: e.toString()));
    }
  }

  /// Filtrar por mes
  void _onFilterByMonth(
    FeesFilterByMonth event,
    Emitter<FeesState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    var filteredFees = currentState.fees;

    if (event.month != null) {
      filteredFees = _filterByMonthValue(filteredFees, event.month!, event.year);
    }

    // Mantener otros filtros
    if (currentState.searchQuery.isNotEmpty) {
      filteredFees = _filterBySearch(filteredFees, currentState.searchQuery);
    }
    if (currentState.filterByTeam != null) {
      filteredFees = _filterByTeamId(filteredFees, currentState.filterByTeam!);
    }
    if (currentState.filterByStatus != null) {
      filteredFees = _filterByStatusValue(filteredFees, currentState.filterByStatus!);
    }

    emit(currentState.copyWith(
      filteredFees: filteredFees,
      filterByMonth: event.month,
      filterByYear: event.year,
    ));
  }

  /// Filtrar por equipo
  void _onFilterByTeam(
    FeesFilterByTeam event,
    Emitter<FeesState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    var filteredFees = currentState.fees;

    if (event.idEquipo != null) {
      filteredFees = _filterByTeamId(filteredFees, event.idEquipo!);
    }

    // Mantener otros filtros
    if (currentState.searchQuery.isNotEmpty) {
      filteredFees = _filterBySearch(filteredFees, currentState.searchQuery);
    }
    if (currentState.filterByMonth != null) {
      filteredFees = _filterByMonthValue(
        filteredFees,
        currentState.filterByMonth!,
        currentState.filterByYear,
      );
    }
    if (currentState.filterByStatus != null) {
      filteredFees = _filterByStatusValue(filteredFees, currentState.filterByStatus!);
    }

    emit(currentState.copyWith(
      filteredFees: filteredFees,
      filterByTeam: event.idEquipo,
    ));
  }

  /// Filtrar por estado
  void _onFilterByStatus(
    FeesFilterByStatus event,
    Emitter<FeesState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    var filteredFees = currentState.fees;

    if (event.idEstado != null) {
      filteredFees = _filterByStatusValue(filteredFees, event.idEstado!);
    }

    // Mantener otros filtros
    if (currentState.searchQuery.isNotEmpty) {
      filteredFees = _filterBySearch(filteredFees, currentState.searchQuery);
    }
    if (currentState.filterByMonth != null) {
      filteredFees = _filterByMonthValue(
        filteredFees,
        currentState.filterByMonth!,
        currentState.filterByYear,
      );
    }
    if (currentState.filterByTeam != null) {
      filteredFees = _filterByTeamId(filteredFees, currentState.filterByTeam!);
    }
    if (currentState.filterByPaymentMethod != null) {
      filteredFees = _filterByPaymentMethodValue(filteredFees, currentState.filterByPaymentMethod!);
    }

    emit(currentState.copyWith(
      filteredFees: filteredFees,
      filterByStatus: event.idEstado,
    ));
  }

  /// Filtrar por método de pago
  void _onFilterByPaymentMethod(
    FeesFilterByPaymentMethod event,
    Emitter<FeesState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    var filteredFees = currentState.fees;

    if (event.idPaymentMethod != null) {
      filteredFees = _filterByPaymentMethodValue(filteredFees, event.idPaymentMethod!);
    }

    // Mantener otros filtros
    if (currentState.searchQuery.isNotEmpty) {
      filteredFees = _filterBySearch(filteredFees, currentState.searchQuery);
    }
    if (currentState.filterByMonth != null) {
      filteredFees = _filterByMonthValue(
        filteredFees,
        currentState.filterByMonth!,
        currentState.filterByYear,
      );
    }
    if (currentState.filterByTeam != null) {
      filteredFees = _filterByTeamId(filteredFees, currentState.filterByTeam!);
    }
    if (currentState.filterByStatus != null) {
      filteredFees = _filterByStatusValue(filteredFees, currentState.filterByStatus!);
    }

    emit(currentState.copyWith(
      filteredFees: filteredFees,
      filterByPaymentMethod: event.idPaymentMethod,
    ));
  }

  /// Búsqueda de jugador
  void _onSearchRequested(
    FeesSearchRequested event,
    Emitter<FeesState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    var filteredFees = currentState.fees;

    if (event.query.isNotEmpty) {
      filteredFees = _filterBySearch(filteredFees, event.query);
    }

    // Mantener otros filtros
    if (currentState.filterByMonth != null) {
      filteredFees = _filterByMonthValue(
        filteredFees,
        currentState.filterByMonth!,
        currentState.filterByYear,
      );
    }
    if (currentState.filterByTeam != null) {
      filteredFees = _filterByTeamId(filteredFees, currentState.filterByTeam!);
    }
    if (currentState.filterByStatus != null) {
      filteredFees = _filterByStatusValue(filteredFees, currentState.filterByStatus!);
    }

    emit(currentState.copyWith(
      filteredFees: filteredFees,
      searchQuery: event.query,
    ));
  }

  /// Limpiar filtros
  void _onClearFilters(
    FeesClearFilters event,
    Emitter<FeesState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    emit(currentState.copyWith(
      filteredFees: currentState.fees,
      searchQuery: '',
      filterByMonth: null,
      filterByYear: null,
      filterByTeam: null,
      filterByStatus: null,
    ));
  }

  /// Registrar pago
  Future<void> _onPaymentRegisterRequested(
    PaymentRegisterRequested event,
    Emitter<FeesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FeesLoaded) return;

    emit(currentState.copyWith(isProcessingPayment: true));

    try {
      // Obtener idjugador de la cuota
      final idJugador = _getPlayerIdFromCuota(currentState.fees, event.idCuota);

      // 1. Actualizar estado de la cuota a "Pagado" (idestado = 1)
      final updateResult = await _datasource.updateCuotaEstado(
        idCuota: event.idCuota,
        idEstado: 1,
      );

      if (!updateResult.success) {
        throw Exception(updateResult.message);
      }

      // 2. Insertar registro en recibos_pagos
      final reciboResult = await _datasource.createReciboPago(
        idclub: currentState.idclub,
        idjugador: idJugador ?? 0,
        idtemporada: currentState.activeSeasonId,
        cantidad: event.cantidad,
        concepto: event.concepto ?? 'Pago de cuota',
        metodoPago: event.metodoPago,
      );

      if (!reciboResult.success) {
        throw Exception(reciboResult.message);
      }

      debugPrint('✅ [FeesBloc] Pago registrado: ${event.idCuota}');

      // 3. Refrescar datos
      add(FeesRefreshRequested(
        idclub: currentState.idclub,
        activeSeasonId: currentState.activeSeasonId,
      ));
    } catch (e) {
      debugPrint('❌ [FeesBloc] Error al registrar pago: $e');
      emit(currentState.copyWith(isProcessingPayment: false));
      emit(FeesError(message: 'Error al registrar pago: $e'));
    }
  }

  /// Carga los datos de cuotas usando el datasource
  Future<Map<String, dynamic>> _loadFeesData(
    int idclub,
    int activeSeasonId,
  ) async {
    final response = await _datasource.getCuotas(
      idclub: idclub,
      idtemporada: activeSeasonId,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.message ?? 'Error al cargar cuotas');
    }

    final fees = response.data!;

    // Crear mapa de equipos únicos desde las cuotas
    final teamsMap = <int, String>{};
    for (final fee in fees) {
      final idequipo = fee['idequipo'] as int?;
      final equipo = fee['equipo'] as String?;
      if (idequipo != null && equipo != null) {
        teamsMap[idequipo] = equipo;
      }
    }

    // Crear mapa de jugadores únicos desde las cuotas
    final playersMap = <int, String>{};
    for (final fee in fees) {
      final idjugador = fee['idjugador'] as int?;
      final nombre = '${fee['nombre'] ?? ''} ${fee['apellidos'] ?? ''}'.trim();
      if (idjugador != null) {
        playersMap[idjugador] = nombre;
      }
      // Añadir campo jugador_nombre para compatibilidad
      fee['jugador_nombre'] = nombre;
      fee['equipo_nombre'] = fee['equipo'] ?? '-';
    }

    // Calcular totales
    double totalEsperado = 0;
    double totalPagado = 0;
    double totalPendiente = 0;
    double totalVencido = 0;
    int countPagado = 0;
    int countPendiente = 0;
    int countVencido = 0;

    for (final fee in fees) {
      final cantidadRaw = fee['cantidad'];
      final cantidad = cantidadRaw is int
          ? cantidadRaw.toDouble()
          : (cantidadRaw as num?)?.toDouble() ?? 0.0;
      final idestado = fee['idestado'] as int?;

      totalEsperado += cantidad;

      switch (idestado) {
        case 1: // Pagado
          totalPagado += cantidad;
          countPagado++;
          break;
        case 2: // Pendiente
          totalPendiente += cantidad;
          countPendiente++;
          break;
        case 3: // Vencido
          totalVencido += cantidad;
          countVencido++;
          break;
      }
    }

    // Por defecto mostrar solo pendientes (2) y vencidas (3)
    final filteredFees = fees.where((fee) {
      final idestado = fee['idestado'] as int?;
      return idestado == 2 || idestado == 3;
    }).toList();

    return {
      'fees': fees,
      'filteredFees': filteredFees,
      'teams': teamsMap,
      'players': playersMap,
      'totalEsperado': totalEsperado,
      'totalPagado': totalPagado,
      'totalPendiente': totalPendiente,
      'totalVencido': totalVencido,
      'countPagado': countPagado,
      'countPendiente': countPendiente,
      'countVencido': countVencido,
    };
  }

  /// Filtra por búsqueda de texto
  List<Map<String, dynamic>> _filterBySearch(
    List<Map<String, dynamic>> fees,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return fees.where((fee) {
      final jugador = (fee['jugador_nombre'] ?? '').toString().toLowerCase();
      final equipo = (fee['equipo_nombre'] ?? '').toString().toLowerCase();
      return jugador.contains(lowerQuery) || equipo.contains(lowerQuery);
    }).toList();
  }

  /// Filtra por mes y año
  List<Map<String, dynamic>> _filterByMonthValue(
    List<Map<String, dynamic>> fees,
    int month,
    int? year,
  ) {
    return fees.where((fee) {
      final feeMonth = fee['mes'] as int?;
      final feeYear = fee['year'] as int?;
      if (year != null) {
        return feeMonth == month && feeYear == year;
      }
      return feeMonth == month;
    }).toList();
  }

  /// Filtra por equipo
  List<Map<String, dynamic>> _filterByTeamId(
    List<Map<String, dynamic>> fees,
    int idEquipo,
  ) {
    return fees.where((fee) {
      return fee['idequipo'] == idEquipo;
    }).toList();
  }

  /// Filtra por estado
  /// idEstado = 2 → Pendiente (no pagado)
  /// idEstado = 1 → Pagado (todos los que no sean pendiente)
  List<Map<String, dynamic>> _filterByStatusValue(
    List<Map<String, dynamic>> fees,
    int idEstado,
  ) {
    return fees.where((fee) {
      final estado = fee['idestado'] as int?;
      if (idEstado == 1) {
        // Pagado: cualquier estado que no sea 2 (pendiente)
        return estado != 2;
      } else if (idEstado == 2) {
        // Pendiente: solo estado 2
        return estado == 2;
      }
      return true;
    }).toList();
  }

  /// Filtra por método de pago específico
  /// idPaymentMethod = 1 → Efectivo
  /// idPaymentMethod = 3 → Tarjeta
  /// idPaymentMethod = 4 → Transferencia
  /// idPaymentMethod = 5 → Bizum
  List<Map<String, dynamic>> _filterByPaymentMethodValue(
    List<Map<String, dynamic>> fees,
    int idPaymentMethod,
  ) {
    return fees.where((fee) {
      final estado = fee['idestado'] as int?;
      return estado == idPaymentMethod;
    }).toList();
  }

  /// Obtiene el idjugador de una cuota
  int? _getPlayerIdFromCuota(List<Map<String, dynamic>> fees, int idCuota) {
    for (final fee in fees) {
      if (fee['id'] == idCuota) {
        return fee['idjugador'] as int?;
      }
    }
    return null;
  }
}
