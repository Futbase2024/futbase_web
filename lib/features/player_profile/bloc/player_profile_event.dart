import 'package:equatable/equatable.dart';

/// Eventos del BLoC de perfil de jugador
abstract class PlayerProfileEvent extends Equatable {
  const PlayerProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el perfil de un jugador
/// Puede recibir los datos del jugador directamente para evitar consultas adicionales
class PlayerProfileLoadRequested extends PlayerProfileEvent {
  final int playerId;
  final Map<String, dynamic>? playerData;
  final int? idclub;
  final int? idequipo;
  final int? activeSeasonId;

  const PlayerProfileLoadRequested({
    required this.playerId,
    this.playerData,
    this.idclub,
    this.idequipo,
    this.activeSeasonId,
  });

  @override
  List<Object?> get props => [playerId, playerData, idclub, idequipo, activeSeasonId];
}

/// Evento para cambiar el tab activo
class PlayerProfileTabChanged extends PlayerProfileEvent {
  final int tabIndex;

  const PlayerProfileTabChanged({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

/// Evento para refrescar datos del perfil
class PlayerProfileRefreshRequested extends PlayerProfileEvent {
  const PlayerProfileRefreshRequested();
}

// ========================================
// EVENTOS DE NOTAS
// ========================================

/// Evento para actualizar la nota de un jugador
class PlayerProfileNotaUpdateRequested extends PlayerProfileEvent {
  final int idjugador;
  final String nota;

  const PlayerProfileNotaUpdateRequested({
    required this.idjugador,
    required this.nota,
  });

  @override
  List<Object?> get props => [idjugador, nota];
}

// ========================================
// EVENTOS DE ESTADÍSTICAS
// ========================================

/// Evento para cargar estadísticas del jugador
class PlayerProfileLoadEstadisticas extends PlayerProfileEvent {
  final int idjugador;
  final int idtemporada;

  const PlayerProfileLoadEstadisticas({
    required this.idjugador,
    required this.idtemporada,
  });

  @override
  List<Object?> get props => [idjugador, idtemporada];
}

// ========================================
// EVENTOS DE PARTIDOS
// ========================================

/// Evento para cargar partidos del jugador
class PlayerProfileLoadPartidos extends PlayerProfileEvent {
  final int idjugador;
  final int idtemporada;

  const PlayerProfileLoadPartidos({
    required this.idjugador,
    required this.idtemporada,
  });

  @override
  List<Object?> get props => [idjugador, idtemporada];
}

// ========================================
// EVENTOS DE ENTRENAMIENTOS
// ========================================

/// Evento para cargar entrenamientos del jugador
class PlayerProfileLoadEntrenamientos extends PlayerProfileEvent {
  final int idjugador;
  final int idtemporada;

  const PlayerProfileLoadEntrenamientos({
    required this.idjugador,
    required this.idtemporada,
  });

  @override
  List<Object?> get props => [idjugador, idtemporada];
}

// ========================================
// EVENTOS DE LESIONES
// ========================================

/// Evento para cargar lesiones del jugador
class PlayerProfileLoadLesiones extends PlayerProfileEvent {
  final int idjugador;

  const PlayerProfileLoadLesiones({required this.idjugador});

  @override
  List<Object?> get props => [idjugador];
}

/// Evento para crear una lesión
class PlayerProfileCreateLesion extends PlayerProfileEvent {
  final int idjugador;
  final String lesion;
  final DateTime fechainicio;
  final DateTime? fechafin;
  final String? observaciones;

  const PlayerProfileCreateLesion({
    required this.idjugador,
    required this.lesion,
    required this.fechainicio,
    this.fechafin,
    this.observaciones,
  });

  @override
  List<Object?> get props => [idjugador, lesion, fechainicio, fechafin, observaciones];
}

/// Evento para actualizar una lesión
class PlayerProfileUpdateLesion extends PlayerProfileEvent {
  final int id;
  final String? lesion;
  final DateTime? fechainicio;
  final DateTime? fechafin;
  final String? observaciones;

  const PlayerProfileUpdateLesion({
    required this.id,
    this.lesion,
    this.fechainicio,
    this.fechafin,
    this.observaciones,
  });

  @override
  List<Object?> get props => [id, lesion, fechainicio, fechafin, observaciones];
}

/// Evento para eliminar una lesión
class PlayerProfileDeleteLesion extends PlayerProfileEvent {
  final int id;

  const PlayerProfileDeleteLesion({required this.id});

  @override
  List<Object?> get props => [id];
}

// ========================================
// EVENTOS DE TALLA/PESO
// ========================================

/// Evento para cargar historial de talla/peso
class PlayerProfileLoadTallaPeso extends PlayerProfileEvent {
  final int idjugador;

  const PlayerProfileLoadTallaPeso({required this.idjugador});

  @override
  List<Object?> get props => [idjugador];
}

/// Evento para crear registro de talla/peso
class PlayerProfileCreateTallaPeso extends PlayerProfileEvent {
  final int idjugador;
  final DateTime fecha;
  final double talla;
  final double peso;

  const PlayerProfileCreateTallaPeso({
    required this.idjugador,
    required this.fecha,
    required this.talla,
    required this.peso,
  });

  @override
  List<Object?> get props => [idjugador, fecha, talla, peso];
}

/// Evento para actualizar registro de talla/peso
class PlayerProfileUpdateTallaPeso extends PlayerProfileEvent {
  final int id;
  final DateTime fecha;
  final double talla;
  final double peso;

  const PlayerProfileUpdateTallaPeso({
    required this.id,
    required this.fecha,
    required this.talla,
    required this.peso,
  });

  @override
  List<Object?> get props => [id, fecha, talla, peso];
}

/// Evento para eliminar registro de talla/peso
class PlayerProfileDeleteTallaPeso extends PlayerProfileEvent {
  final int id;

  const PlayerProfileDeleteTallaPeso({required this.id});

  @override
  List<Object?> get props => [id];
}

// ========================================
// EVENTOS DE DEUDA
// ========================================

/// Evento para cargar control de deuda
class PlayerProfileLoadDeuda extends PlayerProfileEvent {
  final int idjugador;
  final int idtemporada;

  const PlayerProfileLoadDeuda({
    required this.idjugador,
    required this.idtemporada,
  });

  @override
  List<Object?> get props => [idjugador, idtemporada];
}

/// Evento para crear recibo de pago
class PlayerProfileCreateReciboDeuda extends PlayerProfileEvent {
  final int idjugador;
  final int idtemporada;
  final double cantidad;
  final String concepto;
  final String metodopago;
  final DateTime fechapago;

  const PlayerProfileCreateReciboDeuda({
    required this.idjugador,
    required this.idtemporada,
    required this.cantidad,
    required this.concepto,
    required this.metodopago,
    required this.fechapago,
  });

  @override
  List<Object?> get props => [idjugador, idtemporada, cantidad, concepto, metodopago, fechapago];
}

/// Evento para actualizar recibo de pago
class PlayerProfileUpdateReciboDeuda extends PlayerProfileEvent {
  final int id;
  final double? cantidad;
  final String? concepto;
  final String? metodopago;
  final DateTime? fechapago;

  const PlayerProfileUpdateReciboDeuda({
    required this.id,
    this.cantidad,
    this.concepto,
    this.metodopago,
    this.fechapago,
  });

  @override
  List<Object?> get props => [id, cantidad, concepto, metodopago, fechapago];
}

/// Evento para eliminar recibo de pago
class PlayerProfileDeleteReciboDeuda extends PlayerProfileEvent {
  final int id;

  const PlayerProfileDeleteReciboDeuda({required this.id});

  @override
  List<Object?> get props => [id];
}

// ========================================
// EVENTOS DE TUTORES
// ========================================

/// Evento para cargar tutores del jugador
class PlayerProfileLoadTutores extends PlayerProfileEvent {
  final int idjugador;

  const PlayerProfileLoadTutores({required this.idjugador});

  @override
  List<Object?> get props => [idjugador];
}

/// Evento para crear tutor
class PlayerProfileCreateTutor extends PlayerProfileEvent {
  final int idjugador;
  final String nombre;
  final String apellidos;
  final String? telefono;
  final String? email;
  final String? parentesco;

  const PlayerProfileCreateTutor({
    required this.idjugador,
    required this.nombre,
    required this.apellidos,
    this.telefono,
    this.email,
    this.parentesco,
  });

  @override
  List<Object?> get props => [idjugador, nombre, apellidos, telefono, email, parentesco];
}

/// Evento para actualizar tutor
class PlayerProfileUpdateTutor extends PlayerProfileEvent {
  final int id;
  final String? nombre;
  final String? apellidos;
  final String? telefono;
  final String? email;
  final String? parentesco;

  const PlayerProfileUpdateTutor({
    required this.id,
    this.nombre,
    this.apellidos,
    this.telefono,
    this.email,
    this.parentesco,
  });

  @override
  List<Object?> get props => [id, nombre, apellidos, telefono, email, parentesco];
}

/// Evento para eliminar tutor
class PlayerProfileDeleteTutor extends PlayerProfileEvent {
  final int idjugador;
  final int idtutor;

  const PlayerProfileDeleteTutor({
    required this.idjugador,
    required this.idtutor,
  });

  @override
  List<Object?> get props => [idjugador, idtutor];
}

// ========================================
// EVENTOS DE CARNETS
// ========================================

/// Evento para cargar carnets del jugador
class PlayerProfileLoadCarnets extends PlayerProfileEvent {
  final int idjugador;

  const PlayerProfileLoadCarnets({required this.idjugador});

  @override
  List<Object?> get props => [idjugador];
}

/// Evento para crear carnet
class PlayerProfileCreateCarnet extends PlayerProfileEvent {
  final int idjugador;
  final int idtemporada;
  final String? foto;

  const PlayerProfileCreateCarnet({
    required this.idjugador,
    required this.idtemporada,
    this.foto,
  });

  @override
  List<Object?> get props => [idjugador, idtemporada, foto];
}

// ========================================
// EVENTOS DE FICHA FEDERATIVA
// ========================================

/// Evento para cargar ficha federativa
class PlayerProfileLoadFichaFederativa extends PlayerProfileEvent {
  final int idjugador;

  const PlayerProfileLoadFichaFederativa({required this.idjugador});

  @override
  List<Object?> get props => [idjugador];
}

/// Evento para actualizar ficha federativa
class PlayerProfileUpdateFichaFederativa extends PlayerProfileEvent {
  final int idjugador;
  final String? ficha;
  final DateTime? fechaficha;

  const PlayerProfileUpdateFichaFederativa({
    required this.idjugador,
    this.ficha,
    this.fechaficha,
  });

  @override
  List<Object?> get props => [idjugador, ficha, fechaficha];
}
