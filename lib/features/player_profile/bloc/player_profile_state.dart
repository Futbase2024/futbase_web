import 'package:equatable/equatable.dart';

/// Estado del BLoC de perfil de jugador
class PlayerProfileState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? player;
  final Map<int, String> positions;
  final int activeTabIndex;

  // ========================================
  // DATOS DE SECCIONES
  // ========================================

  /// Cuotas del jugador
  final List<Map<String, dynamic>> cuotas;

  /// Entrenamientos del jugador con asistencia
  final List<Map<String, dynamic>> entrenamientos;

  /// Partidos del jugador
  final List<Map<String, dynamic>> partidos;

  /// Estadísticas del jugador
  final List<Map<String, dynamic>> estadisticas;

  /// Estadísticas de asistencia resumidas
  final Map<String, dynamic>? asistenciaStats;

  /// Historial de lesiones
  final List<Map<String, dynamic>> lesiones;

  /// Historial de talla y peso
  final List<Map<String, dynamic>> tallaPeso;

  /// Control de deuda
  final Map<String, dynamic>? controlDeuda;

  /// Recibos de pago
  final List<Map<String, dynamic>> recibos;

  /// Tutores del jugador
  final List<Map<String, dynamic>> tutores;

  /// Carnets del jugador
  final List<Map<String, dynamic>> carnets;

  /// Ficha federativa
  final Map<String, dynamic>? fichaFederativa;

  // ========================================
  // ESTADOS DE CARGA POR SECCIÓN
  // ========================================

  final bool isLoadingEstadisticas;
  final bool isLoadingPartidos;
  final bool isLoadingEntrenamientos;
  final bool isLoadingLesiones;
  final bool isLoadingTallaPeso;
  final bool isLoadingDeuda;
  final bool isLoadingTutores;
  final bool isLoadingCarnets;
  final bool isLoadingFicha;

  // ========================================
  // MENSAJES DE ERROR POR SECCIÓN
  // ========================================

  final String? errorEstadisticas;
  final String? errorPartidos;
  final String? errorEntrenamientos;
  final String? errorLesiones;
  final String? errorTallaPeso;
  final String? errorDeuda;
  final String? errorTutores;
  final String? errorCarnets;
  final String? errorFicha;

  const PlayerProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.player,
    this.positions = const {},
    this.activeTabIndex = 0,
    this.cuotas = const [],
    this.entrenamientos = const [],
    this.partidos = const [],
    this.estadisticas = const [],
    this.asistenciaStats,
    this.lesiones = const [],
    this.tallaPeso = const [],
    this.controlDeuda,
    this.recibos = const [],
    this.tutores = const [],
    this.carnets = const [],
    this.fichaFederativa,
    this.isLoadingEstadisticas = false,
    this.isLoadingPartidos = false,
    this.isLoadingEntrenamientos = false,
    this.isLoadingLesiones = false,
    this.isLoadingTallaPeso = false,
    this.isLoadingDeuda = false,
    this.isLoadingTutores = false,
    this.isLoadingCarnets = false,
    this.isLoadingFicha = false,
    this.errorEstadisticas,
    this.errorPartidos,
    this.errorEntrenamientos,
    this.errorLesiones,
    this.errorTallaPeso,
    this.errorDeuda,
    this.errorTutores,
    this.errorCarnets,
    this.errorFicha,
  });

  bool get isLoaded => player != null && !isLoading;

  String get playerName {
    if (player == null) return '';
    final nombre = player!['nombre']?.toString() ?? '';
    final apellidos = player!['apellidos']?.toString() ?? '';
    return '$nombre $apellidos'.trim();
  }

  String get position {
    if (player == null) return '';
    final idposicion = player!['idposicion'];
    if (idposicion == null) return '';
    final id = idposicion is int ? idposicion : int.tryParse(idposicion.toString());
    if (id == null) return '';
    return positions[id] ?? '';
  }

  /// ID del jugador como int
  int? get playerId {
    if (player == null) return null;
    final id = player!['id'];
    if (id == null) return null;
    return id is int ? id : int.tryParse(id.toString());
  }

  /// ID del club como int
  int? get clubId {
    if (player == null) return null;
    final id = player!['idclub'];
    if (id == null) return null;
    return id is int ? id : int.tryParse(id.toString());
  }

  /// ID de la temporada activa
  int? get seasonId {
    if (player == null) return null;
    final id = player!['idtemporada'];
    if (id == null) return null;
    return id is int ? id : int.tryParse(id.toString());
  }

  PlayerProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? player,
    Map<int, String>? positions,
    int? activeTabIndex,
    List<Map<String, dynamic>>? cuotas,
    List<Map<String, dynamic>>? entrenamientos,
    List<Map<String, dynamic>>? partidos,
    List<Map<String, dynamic>>? estadisticas,
    Map<String, dynamic>? asistenciaStats,
    List<Map<String, dynamic>>? lesiones,
    List<Map<String, dynamic>>? tallaPeso,
    Map<String, dynamic>? controlDeuda,
    List<Map<String, dynamic>>? recibos,
    List<Map<String, dynamic>>? tutores,
    List<Map<String, dynamic>>? carnets,
    Map<String, dynamic>? fichaFederativa,
    bool? isLoadingEstadisticas,
    bool? isLoadingPartidos,
    bool? isLoadingEntrenamientos,
    bool? isLoadingLesiones,
    bool? isLoadingTallaPeso,
    bool? isLoadingDeuda,
    bool? isLoadingTutores,
    bool? isLoadingCarnets,
    bool? isLoadingFicha,
    String? errorEstadisticas,
    String? errorPartidos,
    String? errorEntrenamientos,
    String? errorLesiones,
    String? errorTallaPeso,
    String? errorDeuda,
    String? errorTutores,
    String? errorCarnets,
    String? errorFicha,
    bool clearErrorMessage = false,
    bool clearAsistenciaStats = false,
    bool clearControlDeuda = false,
    bool clearFichaFederativa = false,
  }) {
    return PlayerProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      player: player ?? this.player,
      positions: positions ?? this.positions,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      cuotas: cuotas ?? this.cuotas,
      entrenamientos: entrenamientos ?? this.entrenamientos,
      partidos: partidos ?? this.partidos,
      estadisticas: estadisticas ?? this.estadisticas,
      asistenciaStats: clearAsistenciaStats ? null : (asistenciaStats ?? this.asistenciaStats),
      lesiones: lesiones ?? this.lesiones,
      tallaPeso: tallaPeso ?? this.tallaPeso,
      controlDeuda: clearControlDeuda ? null : (controlDeuda ?? this.controlDeuda),
      recibos: recibos ?? this.recibos,
      tutores: tutores ?? this.tutores,
      carnets: carnets ?? this.carnets,
      fichaFederativa: clearFichaFederativa ? null : (fichaFederativa ?? this.fichaFederativa),
      isLoadingEstadisticas: isLoadingEstadisticas ?? this.isLoadingEstadisticas,
      isLoadingPartidos: isLoadingPartidos ?? this.isLoadingPartidos,
      isLoadingEntrenamientos: isLoadingEntrenamientos ?? this.isLoadingEntrenamientos,
      isLoadingLesiones: isLoadingLesiones ?? this.isLoadingLesiones,
      isLoadingTallaPeso: isLoadingTallaPeso ?? this.isLoadingTallaPeso,
      isLoadingDeuda: isLoadingDeuda ?? this.isLoadingDeuda,
      isLoadingTutores: isLoadingTutores ?? this.isLoadingTutores,
      isLoadingCarnets: isLoadingCarnets ?? this.isLoadingCarnets,
      isLoadingFicha: isLoadingFicha ?? this.isLoadingFicha,
      errorEstadisticas: errorEstadisticas ?? this.errorEstadisticas,
      errorPartidos: errorPartidos ?? this.errorPartidos,
      errorEntrenamientos: errorEntrenamientos ?? this.errorEntrenamientos,
      errorLesiones: errorLesiones ?? this.errorLesiones,
      errorTallaPeso: errorTallaPeso ?? this.errorTallaPeso,
      errorDeuda: errorDeuda ?? this.errorDeuda,
      errorTutores: errorTutores ?? this.errorTutores,
      errorCarnets: errorCarnets ?? this.errorCarnets,
      errorFicha: errorFicha ?? this.errorFicha,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        player,
        positions,
        activeTabIndex,
        cuotas,
        entrenamientos,
        partidos,
        estadisticas,
        asistenciaStats,
        lesiones,
        tallaPeso,
        controlDeuda,
        recibos,
        tutores,
        carnets,
        fichaFederativa,
        isLoadingEstadisticas,
        isLoadingPartidos,
        isLoadingEntrenamientos,
        isLoadingLesiones,
        isLoadingTallaPeso,
        isLoadingDeuda,
        isLoadingTutores,
        isLoadingCarnets,
        isLoadingFicha,
        errorEstadisticas,
        errorPartidos,
        errorEntrenamientos,
        errorLesiones,
        errorTallaPeso,
        errorDeuda,
        errorTutores,
        errorCarnets,
        errorFicha,
      ];
}
