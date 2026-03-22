import 'package:futbase_web_3/core/datasources/api_response.dart';

/// Interfaz común para fuentes de datos
///
/// Permite cambiar entre Supabase y backend_seguro_web
/// modificando solo [AppConfig.useBackendSeguro]
abstract class AppDataSource {
  // ========================================
  // CUOTAS
  // ========================================

  /// Obtiene las cuotas de un club y temporada
  Future<ApiResponse<List<Map<String, dynamic>>>> getCuotas({
    required int idclub,
    required int idtemporada,
  });

  /// Actualiza el estado de una cuota
  Future<ApiResponse<void>> updateCuotaEstado({
    required int idCuota,
    required int idEstado,
  });

  /// Crea un registro de recibo de pago
  Future<ApiResponse<void>> createReciboPago({
    required int idclub,
    required int idjugador,
    required int idtemporada,
    required double cantidad,
    required String concepto,
    required String metodoPago,
  });

  // ========================================
  // ENTRENAMIENTOS
  // ========================================

  /// Obtiene entrenamientos de un equipo
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientos({
    required int idequipo,
    required int idtemporada,
  });

  /// Obtiene entrenamientos de todos los equipos de un club
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientosByClub({
    required int idclub,
    required int idtemporada,
  });

  /// Crea un nuevo entrenamiento
  Future<ApiResponse<void>> createEntrenamiento({
    required int idequipo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    String? observaciones,
  });

  /// Actualiza un entrenamiento existente
  Future<ApiResponse<void>> updateEntrenamiento({
    required int id,
    required int idequipo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    String? observaciones,
  });

  /// Elimina un entrenamiento
  Future<ApiResponse<void>> deleteEntrenamiento({
    required int id,
  });

  // ========================================
  // ASISTENCIA A ENTRENAMIENTOS
  // ========================================

  /// Obtiene los motivos de asistencia disponibles
  Future<ApiResponse<List<Map<String, dynamic>>>> getMotivosAsistencia();

  /// Obtiene la asistencia de un entrenamiento
  Future<ApiResponse<List<Map<String, dynamic>>>> getAsistenciaEntrenamiento({
    required int identrenamiento,
  });

  /// Guarda la asistencia de un entrenamiento
  Future<ApiResponse<void>> saveAsistenciaEntrenamiento({
    required int identrenamiento,
    required int idequipo,
    required int idclub,
    required List<Map<String, dynamic>> asistencia,
  });

  /// Obtiene estadísticas de asistencia por club
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasAsistencia({
    required int idclub,
    required int idtemporada,
  });

  // ========================================
  // EQUIPOS
  // ========================================

  /// Obtiene los equipos de un club
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquipos({
    required int idclub,
    required int idtemporada,
  });

  /// Obtiene IDs de equipos de un club
  Future<ApiResponse<List<int>>> getEquiposIds({
    required int idclub,
    required int idtemporada,
  });

  /// Obtiene información de equipos por IDs
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquiposInfo({
    required List<int> ids,
  });

  /// Obtiene las categorías disponibles
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategorias();

  /// Crea un nuevo equipo
  Future<ApiResponse<void>> createEquipo({
    required int idclub,
    required int idcategoria,
    required int idtemporada,
    required String equipo,
    String? ncorto,
    int? titulares,
    int? minutos,
  });

  /// Actualiza un equipo existente
  Future<ApiResponse<void>> updateEquipo({
    required int id,
    required int idcategoria,
    required int idtemporada,
    required String equipo,
    String? ncorto,
    int? titulares,
    int? minutos,
  });

  /// Elimina un equipo
  Future<ApiResponse<void>> deleteEquipo({
    required int id,
  });

  // ========================================
  // JUGADORES
  // ========================================

  /// Obtiene jugadores de un equipo
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresEquipo({
    required int idequipo,
    int? idclub,
    int? idtemporada,
  });

  /// Obtiene jugadores de un club (vista vjugadores)
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresByClub({
    required int idclub,
    required int idtemporada,
    bool soloActivos = true,
  });

  /// Obtiene datos adicionales de jugadores (dorsal, foto, posición)
  Future<ApiResponse<List<Map<String, dynamic>>>> getJugadoresDatos({
    required List<int> ids,
  });

  /// Obtiene las posiciones disponibles
  Future<ApiResponse<List<Map<String, dynamic>>>> getPosiciones();

  // ========================================
  // PARTIDOS
  // ========================================

  /// Obtiene partidos de un equipo
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidos({
    required int idequipo,
    required int idtemporada,
    int? idclub,
  });

  /// Obtiene partidos de múltiples equipos (por club)
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosByClub({
    required int idclub,
    required int idtemporada,
  });

  /// Obtiene partidos por rango de fechas
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosByDateRange({
    required int idtemporada,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtiene un partido específico
  Future<ApiResponse<Map<String, dynamic>>> getPartido({
    required int idpartido,
  });

  /// Crea un nuevo partido
  Future<ApiResponse<void>> createPartido({
    required int idequipo,
    required int idtemporada,
    required DateTime fecha,
    required String rival,
    required bool local,
  });

  /// Actualiza un partido existente
  Future<ApiResponse<void>> updatePartido({
    required int id,
    required int idequipo,
    required int idtemporada,
    required DateTime fecha,
    required String rival,
    required bool local,
    int? golesLocal,
    int? golesVisitante,
    bool? finalizado,
  });

  /// Elimina un partido
  Future<ApiResponse<void>> deletePartido({
    required int id,
  });

  // ========================================
  // ALINEACIÓN Y CONVOCATORIA
  // ========================================

  /// Obtiene la alineación de un partido (vpartidosjugadores)
  Future<ApiResponse<List<Map<String, dynamic>>>> getLineup({
    required int idpartido,
  });

  /// Obtiene camisetas de un partido
  Future<ApiResponse<Map<String, dynamic>>> getPartidoCamisetas({
    required int idpartido,
  });

  /// Elimina la convocatoria de un partido
  Future<ApiResponse<void>> deleteConvocatoria({
    required int idpartido,
  });

  /// Guarda la alineación/convocatoria
  Future<ApiResponse<void>> saveLineup({
    required int idpartido,
    required List<Map<String, dynamic>> lineup,
  });

  /// Upsert de convocatoria (inserta o actualiza)
  Future<ApiResponse<void>> upsertConvocatoria({
    required int idpartido,
    required int idjugador,
    required int idequipo,
    required int idtemporada,
    required bool convocado,
    int? dorsal,
    bool? titular,
    int? minutoEntrada,
    double? posX,
    double? posY,
  });

  /// Obtiene convocatoria existente
  Future<ApiResponse<List<Map<String, dynamic>>>> getConvocatoria({
    required int idpartido,
  });

  /// Actualiza dorsal en convocatoria
  Future<ApiResponse<void>> updateConvocatoriaDorsal({
    required int idpartido,
    required int idjugador,
    int? dorsal,
  });

  // ========================================
  // CLUB
  // ========================================

  /// Obtiene información del club
  Future<ApiResponse<Map<String, dynamic>>> getClub({
    required int idclub,
    int? idtemporada,
  });

  // ========================================
  // TEMPORADAS
  // ========================================

  /// Obtiene la temporada activa de un club
  Future<ApiResponse<Map<String, dynamic>>> getTemporadaActiva({
    required int idclub,
  });

  /// Obtiene todas las temporadas
  Future<ApiResponse<List<Map<String, dynamic>>>> getTemporadas();

  // ========================================
  // AUTENTICACIÓN
  // ========================================

  /// Obtiene el token de autenticación actual
  Future<String?> getAuthToken();

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated;

  /// Obtiene el UID del usuario actual
  String? get currentUserId;

  /// Obtiene el email del usuario actual
  String? get currentUserEmail;

  // ========================================
  // SCOUTING
  // ========================================

  /// Obtiene jugadores para scouting con filtros
  /// Usa la vista vjugadores
  Future<ApiResponse<List<Map<String, dynamic>>>> getScoutingPlayers({
    int? idclub,
    int? idtemporada,
    List<int>? idposiciones,
    List<int>? idcategorias,
    int? idpiedominante,
    String? searchQuery,
  });

  /// Obtiene el historial de un jugador por ID
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlayerHistory({
    required int jugadorId,
  });

  // ========================================
  // USUARIOS Y AUTENTICACIÓN
  // ========================================

  /// Obtiene un usuario por UID
  Future<Map<String, dynamic>?> getUsuarioByUid({
    required String uid,
  });

  /// Obtiene un usuario por email
  Future<Map<String, dynamic>?> getUsuarioByEmail({
    required String email,
  });

  /// Obtiene un usuario por ID
  Future<Map<String, dynamic>?> getUsuarioById({
    required String id,
  });

  /// Actualiza el UID de un usuario en tusuarios y troles
  Future<void> updateUsuarioUid({
    required String userId,
    required String uid,
  });

  /// Crea un nuevo usuario
  Future<Map<String, dynamic>?> createUsuario({
    required String nombre,
    required String apellidos,
    required String email,
    required int idclub,
    required String uid,
  });

  /// Obtiene la temporada actual desde tconfig
  Future<int?> getCurrentTemporada();

  // ========================================
  // AUTENTICACIÓN ESPECÍFICA
  // ========================================

  /// Inicia sesión con email y contraseña
  Future<ApiResponse<Map<String, dynamic>>> signInWithPassword({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<ApiResponse<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    String? nombre,
    String? apellidos,
    int? idclub,
  });

  /// Cierra la sesión
  Future<void> signOut();

  /// Envía email de recuperación de contraseña
  Future<ApiResponse<void>> resetPasswordForEmail({
    required String email,
  });

  // ========================================
  // EVENTOS DE PARTIDO
  // ========================================

  /// Obtiene los eventos de un partido (goles, tarjetas, etc.)
  Future<ApiResponse<List<Map<String, dynamic>>>> getEventosPartido({
    required int idpartido,
  });

  // ========================================
  // USUARIOS (ADICIONAL)
  // ========================================

  /// Obtiene entrenadores de un club (permisos 2 o 9)
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenadoresByClub({
    required int idclub,
  });

  /// Obtiene conteo global de clubs
  Future<ApiResponse<int>> getGlobalCountClubs();

  /// Obtiene conteo global de usuarios
  Future<ApiResponse<int>> getGlobalCountUsuarios();

  /// Obtiene conteo global de equipos
  Future<ApiResponse<int>> getGlobalCountEquipos();

  /// Obtiene conteo global de jugadores
  Future<ApiResponse<int>> getGlobalCountJugadores();

  /// Obtiene conteo global de entrenamientos
  Future<ApiResponse<int>> getGlobalCountEntrenamientos();

  /// Obtiene conteo global de partidos
  Future<ApiResponse<int>> getGlobalCountPartidos();

  /// Obtiene conteo global de cuotas
  Future<ApiResponse<int>> getGlobalCountCuotas();

  /// Obtiene equipos agrupados por categoría (global)
  Future<ApiResponse<List<Map<String, dynamic>>>> getEquiposPorCategoriaGlobal();

  /// Obtiene usuarios agrupados por permiso (global)
  Future<ApiResponse<List<Map<String, dynamic>>>> getUsuariosPorPermisoGlobal();

  // ========================================
  // ESTADÍSTICAS DE PARTIDO
  // ========================================

  /// Obtiene estadísticas avanzadas de partidos por equipo
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasPartido({
    required int idequipo,
  });

  // ========================================
  // DASHBOARDS
  // ========================================

  /// Obtiene estadísticas de asistencia para dashboard
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardAsistencia({
    required int idclub,
    required int idtemporada,
  });

  /// Obtiene próximos partidos para dashboard
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardProximosPartidos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
    int limit,
  });

  /// Obtiene resultados recientes para dashboard
  Future<ApiResponse<List<Map<String, dynamic>>>> getDashboardResultadosRecientes({
    required int idclub,
    required int idtemporada,
    int? idequipo,
    int limit,
  });

  /// Obtiene conteo de jugadores por club
  Future<ApiResponse<int>> getConteoJugadores({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  });

  /// Obtiene conteo de equipos por club
  Future<ApiResponse<int>> getConteoEquipos({
    required int idclub,
    required int idtemporada,
  });

  /// Obtiene conteo de partidos por club/equipo
  Future<ApiResponse<int>> getConteoPartidos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  });

  /// Obtiene conteo de entrenamientos por club/equipo
  Future<ApiResponse<int>> getConteoEntrenamientos({
    required int idclub,
    required int idtemporada,
    int? idequipo,
  });

  // ========================================
  // TEMPORADAS (CRUD)
  // ========================================

  /// Crea una nueva temporada
  Future<ApiResponse<void>> createTemporada({
    required String temporada,
    required int idclub,
    bool activa,
  });

  /// Actualiza una temporada
  Future<ApiResponse<void>> updateTemporada({
    required int id,
    required String temporada,
    bool? activa,
  });

  /// Establece la temporada activa
  Future<ApiResponse<void>> setTemporadaActiva({
    required int id,
    required int idclub,
  });

  // ========================================
  // PERFIL DE JUGADOR
  // ========================================

  /// Obtiene las estadísticas de un jugador por temporada
  Future<ApiResponse<List<Map<String, dynamic>>>> getEstadisticasJugador({
    required int idjugador,
    required int idtemporada,
  });

  /// Obtiene los partidos de un jugador
  Future<ApiResponse<List<Map<String, dynamic>>>> getPartidosJugador({
    required int idjugador,
    required int idtemporada,
  });

  /// Obtiene los entrenamientos de un jugador con asistencia
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntrenamientosJugador({
    required int idjugador,
    required int idtemporada,
  });

  /// Obtiene las lesiones de un jugador
  Future<ApiResponse<List<Map<String, dynamic>>>> getLesionesJugador({
    required int idjugador,
  });

  /// Crea una lesión para un jugador
  Future<ApiResponse<void>> createLesion({
    required int idjugador,
    required String lesion,
    required DateTime fechainicio,
    DateTime? fechafin,
    String? observaciones,
  });

  /// Actualiza una lesión
  Future<ApiResponse<void>> updateLesion({
    required int id,
    String? lesion,
    DateTime? fechainicio,
    DateTime? fechafin,
    String? observaciones,
  });

  /// Elimina una lesión
  Future<ApiResponse<void>> deleteLesion({
    required int id,
  });

  /// Obtiene el historial de talla/peso de un jugador
  Future<ApiResponse<List<Map<String, dynamic>>>> getTallaPesoJugador({
    required int idjugador,
  });

  /// Crea un registro de talla/peso
  Future<ApiResponse<void>> createTallaPeso({
    required int idjugador,
    required DateTime fecha,
    required double talla,
    required double peso,
  });

  /// Actualiza un registro de talla/peso
  Future<ApiResponse<void>> updateTallaPeso({
    required int id,
    required DateTime fecha,
    required double talla,
    required double peso,
  });

  /// Elimina un registro de talla/peso
  Future<ApiResponse<void>> deleteTallaPeso({
    required int id,
  });

  /// Obtiene el control de deuda de un jugador
  Future<ApiResponse<Map<String, dynamic>>> getControlDeuda({
    required int idjugador,
    required int idtemporada,
  });

  /// Crea un recibo de pago
  Future<ApiResponse<void>> createReciboDeuda({
    required int idjugador,
    required int idtemporada,
    required double cantidad,
    required String concepto,
    required String metodopago,
    required DateTime fechapago,
  });

  /// Actualiza un recibo de pago
  Future<ApiResponse<void>> updateReciboDeuda({
    required int id,
    double? cantidad,
    String? concepto,
    String? metodopago,
    DateTime? fechapago,
  });

  /// Elimina un recibo de pago
  Future<ApiResponse<void>> deleteReciboDeuda({
    required int id,
  });

  /// Obtiene los tutores de un jugador
  Future<ApiResponse<List<Map<String, dynamic>>>> getTutoresJugador({
    required int idjugador,
  });

  /// Crea un tutor para un jugador
  Future<ApiResponse<void>> createTutor({
    required int idjugador,
    required String nombre,
    required String apellidos,
    String? telefono,
    String? email,
    String? parentesco,
  });

  /// Actualiza un tutor
  Future<ApiResponse<void>> updateTutor({
    required int id,
    String? nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? parentesco,
  });

  /// Elimina un tutor
  Future<ApiResponse<void>> deleteTutor({
    required int idjugador,
    required int idtutor,
  });

  /// Obtiene los carnets de un jugador
  Future<ApiResponse<List<Map<String, dynamic>>>> getCarnetsJugador({
    required int idjugador,
  });

  /// Crea un carnet
  Future<ApiResponse<void>> createCarnet({
    required int idjugador,
    required int idtemporada,
    String? foto,
  });

  /// Actualiza la nota de un jugador
  Future<ApiResponse<void>> updateNotaJugador({
    required int idjugador,
    required String nota,
  });

  /// Obtiene la ficha federativa de un jugador
  Future<ApiResponse<Map<String, dynamic>>> getFichaFederativa({
    required int idjugador,
  });

  /// Actualiza la ficha federativa de un jugador
  Future<ApiResponse<void>> updateFichaFederativa({
    required int idjugador,
    String? ficha,
    DateTime? fechaficha,
  });
}
