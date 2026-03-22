import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:futbase_web_3/core/datasources/datasource_factory.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';

import 'player_profile_event.dart';
import 'player_profile_state.dart';

/// BLoC para gestión del perfil de jugador
class PlayerProfileBloc extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  final AppDataSource _dataSource;

  PlayerProfileBloc({AppDataSource? dataSource})
      : _dataSource = dataSource ?? DataSourceFactory.instance,
        super(const PlayerProfileState()) {
    // Eventos principales
    on<PlayerProfileLoadRequested>(_onLoadRequested);
    on<PlayerProfileTabChanged>(_onTabChanged);
    on<PlayerProfileRefreshRequested>(_onRefreshRequested);
    on<PlayerProfileNotaUpdateRequested>(_onNotaUpdateRequested);

    // Eventos de estadísticas
    on<PlayerProfileLoadEstadisticas>(_onLoadEstadisticas);

    // Eventos de partidos
    on<PlayerProfileLoadPartidos>(_onLoadPartidos);

    // Eventos de entrenamientos
    on<PlayerProfileLoadEntrenamientos>(_onLoadEntrenamientos);

    // Eventos de lesiones
    on<PlayerProfileLoadLesiones>(_onLoadLesiones);
    on<PlayerProfileCreateLesion>(_onCreateLesion);
    on<PlayerProfileUpdateLesion>(_onUpdateLesion);
    on<PlayerProfileDeleteLesion>(_onDeleteLesion);

    // Eventos de talla/peso
    on<PlayerProfileLoadTallaPeso>(_onLoadTallaPeso);
    on<PlayerProfileCreateTallaPeso>(_onCreateTallaPeso);
    on<PlayerProfileUpdateTallaPeso>(_onUpdateTallaPeso);
    on<PlayerProfileDeleteTallaPeso>(_onDeleteTallaPeso);

    // Eventos de deuda
    on<PlayerProfileLoadDeuda>(_onLoadDeuda);
    on<PlayerProfileCreateReciboDeuda>(_onCreateReciboDeuda);
    on<PlayerProfileUpdateReciboDeuda>(_onUpdateReciboDeuda);
    on<PlayerProfileDeleteReciboDeuda>(_onDeleteReciboDeuda);

    // Eventos de tutores
    on<PlayerProfileLoadTutores>(_onLoadTutores);
    on<PlayerProfileCreateTutor>(_onCreateTutor);
    on<PlayerProfileUpdateTutor>(_onUpdateTutor);
    on<PlayerProfileDeleteTutor>(_onDeleteTutor);

    // Eventos de carnets
    on<PlayerProfileLoadCarnets>(_onLoadCarnets);
    on<PlayerProfileCreateCarnet>(_onCreateCarnet);

    // Eventos de ficha federativa
    on<PlayerProfileLoadFichaFederativa>(_onLoadFichaFederativa);
    on<PlayerProfileUpdateFichaFederativa>(_onUpdateFichaFederativa);
  }

  // ========================================
  // CARGA INICIAL DEL PERFIL
  // ========================================

  Future<void> _onLoadRequested(
    PlayerProfileLoadRequested event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      Map<String, dynamic>? player = event.playerData;

      // Si no tenemos los datos del jugador, cargarlos
      if (player == null) {
        final idclub = event.idclub ?? 0;
        final idequipo = event.idequipo;

        if (idequipo != null && idequipo > 0) {
          final response = await _dataSource.getJugadoresEquipo(
            idequipo: idequipo,
            idclub: idclub,
            idtemporada: event.activeSeasonId,
          );
          if (response.success && response.data != null) {
            player = response.data!.firstWhere(
              (p) => p['id'] == event.playerId,
              orElse: () => <String, dynamic>{},
            );
          }
        } else if (idclub > 0 && event.activeSeasonId != null) {
          final response = await _dataSource.getJugadoresByClub(
            idclub: idclub,
            idtemporada: event.activeSeasonId!,
            soloActivos: false,
          );
          if (response.success && response.data != null) {
            player = response.data!.firstWhere(
              (p) => p['id'] == event.playerId,
              orElse: () => <String, dynamic>{},
            );
          }
        }
      }

      if (player == null || player.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No se encontró el jugador',
        ));
        return;
      }

      // Cargar posiciones
      final positionsResponse = await _dataSource.getPosiciones();
      final positionsMap = <int, String>{};
      if (positionsResponse.success && positionsResponse.data != null) {
        for (final pos in positionsResponse.data!) {
          positionsMap[pos['id'] as int] = pos['posicion'] as String;
        }
      }

      // Cargar cuotas del jugador
      List<Map<String, dynamic>> cuotas = [];
      final playerClubId = player['idclub'];
      final playerSeasonId = event.activeSeasonId ?? player['idtemporada'];
      if (playerClubId != null && playerSeasonId != null) {
        try {
          final clubId = playerClubId is int ? playerClubId : int.tryParse(playerClubId.toString()) ?? 0;
          final seasonId = playerSeasonId is int ? playerSeasonId : int.tryParse(playerSeasonId.toString()) ?? 0;
          if (clubId > 0 && seasonId > 0) {
            final cuotasResponse = await _dataSource.getCuotas(
              idclub: clubId,
              idtemporada: seasonId,
            );
            if (cuotasResponse.success && cuotasResponse.data != null) {
              cuotas = cuotasResponse.data!
                  .where((c) => c['idjugador'] == event.playerId)
                  .toList();
            }
          }
        } catch (e) {
          debugPrint('Error cargando cuotas: $e');
        }
      }

      emit(state.copyWith(
        isLoading: false,
        player: player,
        positions: positionsMap,
        cuotas: cuotas,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Cambiar tab activo
  void _onTabChanged(
    PlayerProfileTabChanged event,
    Emitter<PlayerProfileState> emit,
  ) {
    emit(state.copyWith(activeTabIndex: event.tabIndex));

    // Cargar datos según el tab seleccionado
    final playerId = state.playerId;
    final seasonId = state.seasonId;

    if (playerId == null) return;

    switch (event.tabIndex) {
      case 1: // Deuda Temporada
        if (seasonId != null) {
          add(PlayerProfileLoadDeuda(idjugador: playerId, idtemporada: seasonId));
        }
        break;
      case 2: // Tutores
        add(PlayerProfileLoadTutores(idjugador: playerId));
        break;
      case 3: // Carnets
        add(PlayerProfileLoadCarnets(idjugador: playerId));
        break;
      case 4: // Ficha Federativa
        add(PlayerProfileLoadFichaFederativa(idjugador: playerId));
        break;
      case 5: // Estadísticas
        if (seasonId != null) {
          add(PlayerProfileLoadEstadisticas(idjugador: playerId, idtemporada: seasonId));
        }
        break;
      case 6: // Entrenamientos
        if (seasonId != null) {
          add(PlayerProfileLoadEntrenamientos(idjugador: playerId, idtemporada: seasonId));
        }
        break;
      case 7: // Partidos
        if (seasonId != null) {
          add(PlayerProfileLoadPartidos(idjugador: playerId, idtemporada: seasonId));
        }
        break;
      case 8: // Talla y Peso
        add(PlayerProfileLoadTallaPeso(idjugador: playerId));
        break;
      case 9: // Lesiones
        add(PlayerProfileLoadLesiones(idjugador: playerId));
        break;
      case 10: // Asistencias
        if (seasonId != null) {
          add(PlayerProfileLoadEntrenamientos(idjugador: playerId, idtemporada: seasonId));
        }
        break;
    }
  }

  /// Refrescar datos
  Future<void> _onRefreshRequested(
    PlayerProfileRefreshRequested event,
    Emitter<PlayerProfileState> emit,
  ) async {
    debugPrint('Refrescando perfil de jugador');
  }

  /// Actualizar nota del jugador
  Future<void> _onNotaUpdateRequested(
    PlayerProfileNotaUpdateRequested event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.updateNotaJugador(
        idjugador: event.idjugador,
        nota: event.nota,
      );

      // Actualizar el player en el estado
      if (state.player != null) {
        final updatedPlayer = Map<String, dynamic>.from(state.player!);
        updatedPlayer['nota'] = event.nota;
        emit(state.copyWith(player: updatedPlayer));
      }
    } catch (e) {
      debugPrint('Error actualizando nota: $e');
    }
  }

  // ========================================
  // ESTADÍSTICAS
  // ========================================

  Future<void> _onLoadEstadisticas(
    PlayerProfileLoadEstadisticas event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingEstadisticas: true));

    try {
      final response = await _dataSource.getEstadisticasJugador(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          estadisticas: response.data!,
          isLoadingEstadisticas: false,
        ));
      } else {
        emit(state.copyWith(isLoadingEstadisticas: false));
      }
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      emit(state.copyWith(isLoadingEstadisticas: false));
    }
  }

  // ========================================
  // PARTIDOS
  // ========================================

  Future<void> _onLoadPartidos(
    PlayerProfileLoadPartidos event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingPartidos: true));

    try {
      final response = await _dataSource.getPartidosJugador(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          partidos: response.data!,
          isLoadingPartidos: false,
        ));
      } else {
        emit(state.copyWith(isLoadingPartidos: false));
      }
    } catch (e) {
      debugPrint('Error cargando partidos: $e');
      emit(state.copyWith(isLoadingPartidos: false));
    }
  }

  // ========================================
  // ENTRENAMIENTOS
  // ========================================

  Future<void> _onLoadEntrenamientos(
    PlayerProfileLoadEntrenamientos event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingEntrenamientos: true));

    try {
      final response = await _dataSource.getEntrenamientosJugador(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
      );

      if (response.success && response.data != null) {
        // Calcular estadísticas de asistencia
        final entrenamientos = response.data!;
        final total = entrenamientos.length;
        final asistidos = entrenamientos.where((e) => e['asistio'] == true).length;
        final porcentaje = total > 0 ? (asistidos / total * 100).toStringAsFixed(1) : '0';

        emit(state.copyWith(
          entrenamientos: entrenamientos,
          asistenciaStats: {
            'total': total,
            'asistidos': asistidos,
            'porcentaje': porcentaje,
          },
          isLoadingEntrenamientos: false,
        ));
      } else {
        emit(state.copyWith(isLoadingEntrenamientos: false));
      }
    } catch (e) {
      debugPrint('Error cargando entrenamientos: $e');
      emit(state.copyWith(isLoadingEntrenamientos: false));
    }
  }

  // ========================================
  // LESIONES
  // ========================================

  Future<void> _onLoadLesiones(
    PlayerProfileLoadLesiones event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingLesiones: true));

    try {
      final response = await _dataSource.getLesionesJugador(
        idjugador: event.idjugador,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          lesiones: response.data!,
          isLoadingLesiones: false,
        ));
      } else {
        emit(state.copyWith(isLoadingLesiones: false));
      }
    } catch (e) {
      debugPrint('Error cargando lesiones: $e');
      emit(state.copyWith(isLoadingLesiones: false));
    }
  }

  Future<void> _onCreateLesion(
    PlayerProfileCreateLesion event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.createLesion(
        idjugador: event.idjugador,
        lesion: event.lesion,
        fechainicio: event.fechainicio,
        fechafin: event.fechafin,
        observaciones: event.observaciones,
      );

      // Recargar lesiones
      add(PlayerProfileLoadLesiones(idjugador: event.idjugador));
    } catch (e) {
      debugPrint('Error creando lesión: $e');
    }
  }

  Future<void> _onUpdateLesion(
    PlayerProfileUpdateLesion event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.updateLesion(
        id: event.id,
        lesion: event.lesion,
        fechainicio: event.fechainicio,
        fechafin: event.fechafin,
        observaciones: event.observaciones,
      );

      // Recargar lesiones si tenemos el playerId
      if (state.playerId != null) {
        add(PlayerProfileLoadLesiones(idjugador: state.playerId!));
      }
    } catch (e) {
      debugPrint('Error actualizando lesión: $e');
    }
  }

  Future<void> _onDeleteLesion(
    PlayerProfileDeleteLesion event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.deleteLesion(id: event.id);

      // Recargar lesiones si tenemos el playerId
      if (state.playerId != null) {
        add(PlayerProfileLoadLesiones(idjugador: state.playerId!));
      }
    } catch (e) {
      debugPrint('Error eliminando lesión: $e');
    }
  }

  // ========================================
  // TALLA Y PESO
  // ========================================

  Future<void> _onLoadTallaPeso(
    PlayerProfileLoadTallaPeso event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingTallaPeso: true));

    try {
      final response = await _dataSource.getTallaPesoJugador(
        idjugador: event.idjugador,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          tallaPeso: response.data!,
          isLoadingTallaPeso: false,
        ));
      } else {
        emit(state.copyWith(isLoadingTallaPeso: false));
      }
    } catch (e) {
      debugPrint('Error cargando talla/peso: $e');
      emit(state.copyWith(isLoadingTallaPeso: false));
    }
  }

  Future<void> _onCreateTallaPeso(
    PlayerProfileCreateTallaPeso event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.createTallaPeso(
        idjugador: event.idjugador,
        fecha: event.fecha,
        talla: event.talla,
        peso: event.peso,
      );

      // Recargar talla/peso
      add(PlayerProfileLoadTallaPeso(idjugador: event.idjugador));
    } catch (e) {
      debugPrint('Error creando talla/peso: $e');
    }
  }

  Future<void> _onUpdateTallaPeso(
    PlayerProfileUpdateTallaPeso event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.updateTallaPeso(
        id: event.id,
        fecha: event.fecha,
        talla: event.talla,
        peso: event.peso,
      );

      // Recargar si tenemos playerId
      if (state.playerId != null) {
        add(PlayerProfileLoadTallaPeso(idjugador: state.playerId!));
      }
    } catch (e) {
      debugPrint('Error actualizando talla/peso: $e');
    }
  }

  Future<void> _onDeleteTallaPeso(
    PlayerProfileDeleteTallaPeso event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.deleteTallaPeso(id: event.id);

      // Recargar si tenemos playerId
      if (state.playerId != null) {
        add(PlayerProfileLoadTallaPeso(idjugador: state.playerId!));
      }
    } catch (e) {
      debugPrint('Error eliminando talla/peso: $e');
    }
  }

  // ========================================
  // DEUDA
  // ========================================

  Future<void> _onLoadDeuda(
    PlayerProfileLoadDeuda event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingDeuda: true));

    try {
      final response = await _dataSource.getControlDeuda(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          controlDeuda: response.data,
          isLoadingDeuda: false,
        ));
      } else {
        emit(state.copyWith(isLoadingDeuda: false));
      }
    } catch (e) {
      debugPrint('Error cargando deuda: $e');
      emit(state.copyWith(isLoadingDeuda: false));
    }
  }

  Future<void> _onCreateReciboDeuda(
    PlayerProfileCreateReciboDeuda event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.createReciboDeuda(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
        cantidad: event.cantidad,
        concepto: event.concepto,
        metodopago: event.metodopago,
        fechapago: event.fechapago,
      );

      // Recargar deuda
      add(PlayerProfileLoadDeuda(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
      ));
    } catch (e) {
      debugPrint('Error creando recibo: $e');
    }
  }

  Future<void> _onUpdateReciboDeuda(
    PlayerProfileUpdateReciboDeuda event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.updateReciboDeuda(
        id: event.id,
        cantidad: event.cantidad,
        concepto: event.concepto,
        metodopago: event.metodopago,
        fechapago: event.fechapago,
      );

      // Recargar si tenemos datos
      if (state.playerId != null && state.seasonId != null) {
        add(PlayerProfileLoadDeuda(
          idjugador: state.playerId!,
          idtemporada: state.seasonId!,
        ));
      }
    } catch (e) {
      debugPrint('Error actualizando recibo: $e');
    }
  }

  Future<void> _onDeleteReciboDeuda(
    PlayerProfileDeleteReciboDeuda event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.deleteReciboDeuda(id: event.id);

      // Recargar si tenemos datos
      if (state.playerId != null && state.seasonId != null) {
        add(PlayerProfileLoadDeuda(
          idjugador: state.playerId!,
          idtemporada: state.seasonId!,
        ));
      }
    } catch (e) {
      debugPrint('Error eliminando recibo: $e');
    }
  }

  // ========================================
  // TUTORES
  // ========================================

  Future<void> _onLoadTutores(
    PlayerProfileLoadTutores event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingTutores: true));

    try {
      final response = await _dataSource.getTutoresJugador(
        idjugador: event.idjugador,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          tutores: response.data!,
          isLoadingTutores: false,
        ));
      } else {
        emit(state.copyWith(isLoadingTutores: false));
      }
    } catch (e) {
      debugPrint('Error cargando tutores: $e');
      emit(state.copyWith(isLoadingTutores: false));
    }
  }

  Future<void> _onCreateTutor(
    PlayerProfileCreateTutor event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.createTutor(
        idjugador: event.idjugador,
        nombre: event.nombre,
        apellidos: event.apellidos,
        telefono: event.telefono,
        email: event.email,
        parentesco: event.parentesco,
      );

      // Recargar tutores
      add(PlayerProfileLoadTutores(idjugador: event.idjugador));
    } catch (e) {
      debugPrint('Error creando tutor: $e');
    }
  }

  Future<void> _onUpdateTutor(
    PlayerProfileUpdateTutor event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.updateTutor(
        id: event.id,
        nombre: event.nombre,
        apellidos: event.apellidos,
        telefono: event.telefono,
        email: event.email,
        parentesco: event.parentesco,
      );

      // Recargar si tenemos playerId
      if (state.playerId != null) {
        add(PlayerProfileLoadTutores(idjugador: state.playerId!));
      }
    } catch (e) {
      debugPrint('Error actualizando tutor: $e');
    }
  }

  Future<void> _onDeleteTutor(
    PlayerProfileDeleteTutor event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.deleteTutor(
        idjugador: event.idjugador,
        idtutor: event.idtutor,
      );

      // Recargar tutores
      add(PlayerProfileLoadTutores(idjugador: event.idjugador));
    } catch (e) {
      debugPrint('Error eliminando tutor: $e');
    }
  }

  // ========================================
  // CARNETS
  // ========================================

  Future<void> _onLoadCarnets(
    PlayerProfileLoadCarnets event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingCarnets: true));

    try {
      final response = await _dataSource.getCarnetsJugador(
        idjugador: event.idjugador,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          carnets: response.data!,
          isLoadingCarnets: false,
        ));
      } else {
        emit(state.copyWith(isLoadingCarnets: false));
      }
    } catch (e) {
      debugPrint('Error cargando carnets: $e');
      emit(state.copyWith(isLoadingCarnets: false));
    }
  }

  Future<void> _onCreateCarnet(
    PlayerProfileCreateCarnet event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.createCarnet(
        idjugador: event.idjugador,
        idtemporada: event.idtemporada,
        foto: event.foto,
      );

      // Recargar carnets
      add(PlayerProfileLoadCarnets(idjugador: event.idjugador));
    } catch (e) {
      debugPrint('Error creando carnet: $e');
    }
  }

  // ========================================
  // FICHA FEDERATIVA
  // ========================================

  Future<void> _onLoadFichaFederativa(
    PlayerProfileLoadFichaFederativa event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingFicha: true));

    try {
      final response = await _dataSource.getFichaFederativa(
        idjugador: event.idjugador,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          fichaFederativa: response.data,
          isLoadingFicha: false,
        ));
      } else {
        emit(state.copyWith(isLoadingFicha: false));
      }
    } catch (e) {
      debugPrint('Error cargando ficha federativa: $e');
      emit(state.copyWith(isLoadingFicha: false));
    }
  }

  Future<void> _onUpdateFichaFederativa(
    PlayerProfileUpdateFichaFederativa event,
    Emitter<PlayerProfileState> emit,
  ) async {
    try {
      await _dataSource.updateFichaFederativa(
        idjugador: event.idjugador,
        ficha: event.ficha,
        fechaficha: event.fechaficha,
      );

      // Recargar ficha
      add(PlayerProfileLoadFichaFederativa(idjugador: event.idjugador));
    } catch (e) {
      debugPrint('Error actualizando ficha federativa: $e');
    }
  }
}
