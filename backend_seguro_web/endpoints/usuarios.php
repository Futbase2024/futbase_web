<?php
/**
 * Endpoint de Usuarios
 * Operaciones CRUD de usuarios
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Inicializar dependencias
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché
$auth = new FirebaseAuthMiddleware();

// Proteger endpoint con autenticación y rate limiting
$userData = $auth->protect(100, 60); // 100 requests/min

// Obtener acción
$action = $_GET['action'] ?? '';

// Enrutamiento de acciones
try {
    switch ($action) {
        case 'getAllUsers':
            getAllUsers($db, $cache, $userData);
            break;

        case 'getAppUserById':
            getUserById($db, $cache, $userData);
            break;

        case 'getAppUserByUid':
            getUserByUid($db, $cache, $userData);
            break;

        case 'getUsersByClubRoles':
            getUsersByClubRoles($db, $cache, $userData);
            break;

        case 'getUsersByClubRolesTutores':
            getUsersByClubRolesTutores($db, $cache, $userData);
            break;

        case 'getUsersByTipoRolclub':
            getUsersByTipoRolclub($db, $cache, $userData);
            break;

        case 'getUsersByClub':
            getUsersByClub($db, $cache, $userData);
            break;

        case 'getUsersByTeam':
            getUsersByTeam($db, $cache, $userData);
            break;

        case 'getTutores':
            getTutores($db, $cache, $userData);
            break;

        case 'getJugador':
            getJugador($db, $cache, $userData);
            break;

        case 'getUserJugador':
            getUserJugador($db, $cache, $userData);
            break;

        case 'getIdRolJugador':
            getIdRolJugador($db, $cache, $userData);
            break;

        case 'getTutor':
            getTutor($db, $cache, $userData);
            break;

        case 'createAppUser':
            createUser($db, $cache, $userData);
            break;

        case 'updateAppUser':
            updateUser($db, $cache, $userData);
            break;

        case 'deleteAppUser':
            deleteUser($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in usuarios.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene todos los usuarios de una temporada
 */
function getAllUsers($db, $cache, $userData) {
    $idTemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idTemporada) {
        respondError('idtemporada es requerido', 400);
    }

    $cacheKey = "usuarios_temporada_{$idTemporada}";

    $usuarios = $cache->remember($cacheKey, function() use ($db, $idTemporada) {
        $sql = "SELECT id, uid, email, nombre, apellidos, telefono, user, permisos,
                       idclub, idequipo, idtemporada, photourl, observaciones
                FROM tusuarios
                WHERE idtemporada = ?
                ORDER BY nombre, apellidos";

        return $db->select($sql, [$idTemporada]);
    }, 300);

    respondSuccess($usuarios);
}

/**
 * Obtiene un usuario por ID
 */
function getUserById($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('ID es requerido', 400);
    }

    $cacheKey = "usuario_id_{$id}";

    $usuario = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT *
                FROM tusuarios
                WHERE id = ?
                LIMIT 1";

        return $db->selectOne($sql, [$id]);
    }, 300);

    if (!$usuario) {
        respondNotFound('Usuario no encontrado');
    }

    respondSuccess($usuario);
}

/**
 * Obtiene un usuario por UID de Firebase
 */
function getUserByUid($db, $cache, $userData) {
    $uid = Validator::validateUID($_GET['uid'] ?? '');

    if (!$uid) {
        respondError('UID es requerido y debe ser válido', 400);
    }

    $cacheKey = "usuario_uid_{$uid}";

    $usuario = $cache->remember($cacheKey, function() use ($db, $uid) {
        $sql = "SELECT id, uid, email, nombre, apellidos, telefono, user, permisos,
                       idclub, idequipo, idtemporada, photourl, observaciones
                FROM tusuarios
                WHERE uid = ?
                LIMIT 1";

        return $db->selectOne($sql, [$uid]);
    }, 300);

    if (!$usuario) {
        respondNotFound('Usuario no encontrado');
    }

    respondSuccess($usuario);
}

/**
 * Crea un nuevo usuario
 */
function createUser($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos', 400);
    }

    // Validar campos requeridos
    $required = ['email', 'nombre', 'apellidos', 'user', 'password', 'idtemporada', 'idclub'];
    $errors = Validator::validateRequired($input, $required);

    if ($errors) {
        respondValidationError($errors);
    }

    // Validar que no exista otro usuario con el mismo email
    $checkEmail = $db->selectOne(
        "SELECT COUNT(*) as count FROM tusuarios WHERE email = ? AND idtemporada = ?",
        [$input['email'], $input['idtemporada']]
    );

    if ($checkEmail && $checkEmail['count'] > 0) {
        respondError('Ya existe un usuario con este email', 400);
    }

    // Validar que no exista otro usuario con el mismo username
    $checkUser = $db->selectOne(
        "SELECT COUNT(*) as count FROM tusuarios WHERE user = ? AND idtemporada = ?",
        [$input['user'], $input['idtemporada']]
    );

    if ($checkUser && $checkUser['count'] > 0) {
        respondError('Ya existe un usuario con este nombre de usuario', 400);
    }

    // Iniciar transacción
    $db->beginTransaction();

    try {
        // Insertar usuario
        $sql = "INSERT INTO tusuarios (
            idclub, idequipo, idtemporada, uid, email, nombre, apellidos,
            telefono, user, password, permisos, photourl, observaciones
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $idUsuario = $db->insert($sql, [
            Validator::validateInt($input['idclub']),
            Validator::validateInt($input['idequipo'] ?? 0),
            Validator::validateInt($input['idtemporada']),
            $input['uid'] ?? null,
            $input['email'],
            $input['nombre'],
            $input['apellidos'],
            $input['telefono'] ?? '',
            $input['user'],
            password_hash($input['password'], PASSWORD_DEFAULT), // Hash seguro
            Validator::validateInt($input['permisos'] ?? 0),
            $input['photourl'] ?? null,
            $input['observaciones'] ?? null
        ]);

        $db->commit();

        // Limpiar caché
        $cache->clear("usuarios_*");

        // Obtener el usuario creado
        $usuarioCreado = $db->selectOne(
            "SELECT * FROM tusuarios WHERE id = ?",
            [$idUsuario]
        );

        respondSuccess($usuarioCreado, 'Usuario creado exitosamente');

    } catch (Exception $e) {
        $db->rollback();
        error_log("Error al crear usuario: " . $e->getMessage());
        respondInternalError('Error al crear usuario');
    }
}

/**
 * Actualiza un usuario existente
 */
function updateUser($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos inválidos', 400);
    }

    $id = Validator::validateInt($input['id']);

    if (!$id) {
        respondError('ID inválido', 400);
    }

    // Verificar que el usuario existe
    $usuarioExiste = $db->selectOne("SELECT id FROM tusuarios WHERE id = ?", [$id]);

    if (!$usuarioExiste) {
        respondNotFound('Usuario no encontrado');
    }

    // Construir query de actualización dinámicamente
    $fields = [];
    $params = [];

    if (isset($input['nombre'])) {
        $fields[] = "nombre = ?";
        $params[] = $input['nombre'];
    }
    if (isset($input['apellidos'])) {
        $fields[] = "apellidos = ?";
        $params[] = $input['apellidos'];
    }
    if (isset($input['telefono'])) {
        $fields[] = "telefono = ?";
        $params[] = $input['telefono'];
    }
    if (isset($input['email'])) {
        $fields[] = "email = ?";
        $params[] = $input['email'];
    }
    if (isset($input['permisos'])) {
        $fields[] = "permisos = ?";
        $params[] = Validator::validateInt($input['permisos']);
    }
    if (isset($input['photourl'])) {
        $fields[] = "photourl = ?";
        $params[] = $input['photourl'];
    }
    if (isset($input['observaciones'])) {
        $fields[] = "observaciones = ?";
        $params[] = $input['observaciones'];
    }
    if (isset($input['estadisticas'])) {
        $fields[] = "estadisticas = ?";
        $params[] = Validator::validateInt($input['estadisticas']);
    }
    if (isset($input['entrenamientos'])) {
        $fields[] = "entrenamientos = ?";
        $params[] = Validator::validateInt($input['entrenamientos']);
    }
    if (isset($input['partidos'])) {
        $fields[] = "partidos = ?";
        $params[] = Validator::validateInt($input['partidos']);
    }
    if (isset($input['tallapeso'])) {
        $fields[] = "tallapeso = ?";
        $params[] = Validator::validateInt($input['tallapeso']);
    }
    if (isset($input['lesiones'])) {
        $fields[] = "lesiones = ?";
        $params[] = Validator::validateInt($input['lesiones']);
    }
    if (isset($input['cuotas'])) {
        $fields[] = "cuotas = ?";
        $params[] = Validator::validateInt($input['cuotas']);
    }
    if (isset($input['hacerfotos'])) {
        $fields[] = "hacerfotos = ?";
        $params[] = Validator::validateInt($input['hacerfotos']);
    }
    if (isset($input['perfil'])) {
        $fields[] = "perfil = ?";
        $params[] = $input['perfil'];
    }

    if (empty($fields)) {
        respondError('No hay campos para actualizar', 400);
    }

    $params[] = $id;
    $sql = "UPDATE tusuarios SET " . implode(', ', $fields) . " WHERE id = ?";

    try {
        $db->execute($sql, $params);

        // Limpiar caché
        $cache->clear("usuarios_*");
        $cache->delete("usuario_id_{$id}");

        // Obtener el usuario actualizado
        $usuarioActualizado = $db->selectOne(
            "SELECT * FROM tusuarios WHERE id = ?",
            [$id]
        );

        respondSuccess($usuarioActualizado, 'Usuario actualizado exitosamente');

    } catch (Exception $e) {
        error_log("Error al actualizar usuario: " . $e->getMessage());
        respondInternalError('Error al actualizar usuario');
    }
}

/**
 * Elimina un usuario
 */
function deleteUser($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('ID es requerido', 400);
    }

    // Verificar que el usuario existe
    $usuarioExiste = $db->selectOne("SELECT id FROM tusuarios WHERE id = ?", [$id]);

    if (!$usuarioExiste) {
        respondNotFound('Usuario no encontrado');
    }

    try {
        $db->execute("DELETE FROM tusuarios WHERE id = ?", [$id]);

        // Limpiar caché
        $cache->clear("usuarios_*");
        $cache->delete("usuario_id_{$id}");

        respondSuccess(null, 'Usuario eliminado exitosamente');

    } catch (Exception $e) {
        error_log("Error al eliminar usuario: " . $e->getMessage());
        respondInternalError('Error al eliminar usuario');
    }
}

/**
 * Obtiene roles de usuarios por club
 */
function getUsersByClubRoles($db, $cache, $userData) {
    $idClub = Validator::validateInt($_GET['idClub'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "roles_club_{$idClub}_temporada_{$idTemporada}";

    $roles = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT * FROM vroles WHERE idclub = ? AND idtemporada = ? ORDER BY nombre, apellidos";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 300);

    respondSuccess($roles);
}

/**
 * Obtiene tutores por club (roles de tipo tutor/padre)
 */
function getUsersByClubRolesTutores($db, $cache, $userData) {
    $idClub = Validator::validateInt($_GET['idClub'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "roles_tutores_club_{$idClub}_temporada_{$idTemporada}";

    $tutores = $cache->remember($cacheKey, function() use ($db, $idTemporada) {
        $sql = "SELECT * FROM vrolesCarnet WHERE idtemporada = ? ORDER BY nombre, apellidos";
        return $db->select($sql, [$idTemporada]);
    }, 300);

    respondSuccess($tutores);
}

/**
 * Obtiene usuarios por tipo de rol
 */
function getUsersByTipoRolclub($db, $cache, $userData) {
    $idClub = Validator::validateInt($_GET['idClub'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);
    $tipoUsuario = Validator::validateInt($_GET['tipoUsuario'] ?? null);

    if (!$idClub || !$idTemporada || !$tipoUsuario) {
        respondError('idClub, idTemporada y tipoUsuario son requeridos', 400);
    }

    $cacheKey = "roles_tipo_{$tipoUsuario}_club_{$idClub}_temporada_{$idTemporada}";

    $roles = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada, $tipoUsuario) {
        $sql = "SELECT * FROM vroles WHERE idclub = ? AND idtemporada = ? AND tipo = ? ORDER BY nombre, apellidos";
        return $db->select($sql, [$idClub, $idTemporada, $tipoUsuario]);
    }, 300);

    respondSuccess($roles);
}

/**
 * Obtiene usuarios por club
 */
function getUsersByClub($db, $cache, $userData) {
    $idClub = Validator::validateInt($_GET['idClub'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "usuarios_club_{$idClub}_temporada_{$idTemporada}";

    $usuarios = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT id, uid, email, nombre, apellidos, telefono, user, permisos,
                       idclub, idequipo, idtemporada, photourl, observaciones
                FROM tusuarios
                WHERE idclub = ? AND idtemporada = ?
                ORDER BY nombre, apellidos";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 300);

    respondSuccess($usuarios);
}

/**
 * Obtiene usuarios por equipo
 */
function getUsersByTeam($db, $cache, $userData) {
    $idTeam = Validator::validateInt($_GET['idTeam'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idTeam || !$idTemporada) {
        respondError('idTeam e idTemporada son requeridos', 400);
    }

    $cacheKey = "usuarios_equipo_{$idTeam}_temporada_{$idTemporada}";

    $usuarios = $cache->remember($cacheKey, function() use ($db, $idTeam, $idTemporada) {
        $sql = "SELECT id, uid, email, nombre, apellidos, telefono, user, permisos,
                       idclub, idequipo, idtemporada, photourl, observaciones
                FROM tusuarios
                WHERE idequipo = ? AND idtemporada = ?
                ORDER BY nombre, apellidos";
        return $db->select($sql, [$idTeam, $idTemporada]);
    }, 300);

    respondSuccess($usuarios);
}

/**
 * Obtiene tutores de un jugador
 */
function getTutores($db, $cache, $userData) {
    $idJugador = Validator::validateInt($_GET['idJugador'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idJugador || !$idTemporada) {
        respondError('idJugador e idTemporada son requeridos', 400);
    }

    $cacheKey = "tutores_jugador_{$idJugador}_temporada_{$idTemporada}";

    $tutores = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        $sql = "SELECT u.id, u.uid, u.email, u.nombre, u.apellidos, u.telefono, u.user, u.permisos,
                       u.idclub, u.idequipo, u.idtemporada, u.photourl, u.observaciones
                FROM tusuarios u
                INNER JOIN troles r ON r.idusuario = u.id
                WHERE (r.idjugador = ? OR r.idjugador2 = ? OR r.idjugador3 = ? OR r.idjugador4 = ?)
                  AND u.idtemporada = ?
                  AND r.tipo = 3
                GROUP BY u.id
                ORDER BY u.nombre, u.apellidos";
        return $db->select($sql, [$idJugador, $idJugador, $idJugador, $idJugador, $idTemporada]);
    }, 300);

    respondSuccess($tutores);
}

/**
 * Obtiene el usuario asociado a un jugador
 */
function getJugador($db, $cache, $userData) {
    $idJugador = Validator::validateInt($_GET['idJugador'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idJugador || !$idTemporada) {
        respondError('idJugador e idTemporada son requeridos', 400);
    }

    $cacheKey = "usuario_jugador_{$idJugador}_temporada_{$idTemporada}";

    $usuario = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        $sql = "SELECT u.id, u.uid, u.email, u.nombre, u.apellidos, u.telefono, u.user, u.permisos,
                       u.idclub, u.idequipo, u.idtemporada, u.photourl, u.observaciones
                FROM tusuarios u
                INNER JOIN troles r ON r.idusuario = u.id
                WHERE r.idjugador = ?
                  AND u.idtemporada = ?
                  AND r.tipo = 4
                LIMIT 1";
        return $db->selectOne($sql, [$idJugador, $idTemporada]);
    }, 300);

    if (!$usuario) {
        respondNotFound('Usuario jugador no encontrado');
    }

    respondSuccess($usuario);
}

/**
 * Obtiene el usuario asociado a un jugador por ID de jugador
 */
function getUserJugador($db, $cache, $userData) {
    $idJugador = Validator::validateInt($_GET['idJugador'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idJugador || !$idTemporada) {
        respondError('idJugador e idTemporada son requeridos', 400);
    }

    $cacheKey = "usuario_jugador_id_{$idJugador}_temporada_{$idTemporada}";

    $usuario = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        $sql = "SELECT u.id, u.uid, u.email, u.nombre, u.apellidos, u.telefono, u.user, u.permisos,
                       u.idclub, u.idequipo, u.idtemporada, u.photourl, u.observaciones
                FROM tusuarios u
                INNER JOIN troles r ON r.idusuario = u.id
                WHERE r.idjugador = ?
                  AND u.idtemporada = ?
                  AND r.tipo = 4
                LIMIT 1";
        return $db->selectOne($sql, [$idJugador, $idTemporada]);
    }, 300);

    if (!$usuario) {
        respondNotFound('Usuario jugador no encontrado');
    }

    respondSuccess($usuario);
}

/**
 * Obtiene los IDs de roles de un jugador (de troles) para enviar mensajes
 */
function getIdRolJugador($db, $cache, $userData) {
    $idJugador = Validator::validateInt($_GET['idJugador'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idJugador || !$idTemporada) {
        respondError('idJugador e idTemporada son requeridos', 400);
    }

    $cacheKey = "idrol_jugador_{$idJugador}_temporada_{$idTemporada}";

    $roles = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        $sql = "SELECT r.id as idrol
                FROM troles r
                WHERE r.idjugador = ?
                  AND r.idtemporada = ?
                  AND r.tipo = 5";
        return $db->select($sql, [$idJugador, $idTemporada]);
    }, 300);

    if (empty($roles)) {
        respondNotFound('No se encontraron roles para este jugador');
    }

    respondSuccess($roles);
}

/**
 * Obtiene un tutor por ID
 */
function getTutor($db, $cache, $userData) {
    $idTutor = Validator::validateInt($_GET['idTutor'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idTutor || !$idTemporada) {
        respondError('idTutor e idTemporada son requeridos', 400);
    }

    $cacheKey = "tutor_{$idTutor}_temporada_{$idTemporada}";

    $tutor = $cache->remember($cacheKey, function() use ($db, $idTutor, $idTemporada) {
        $sql = "SELECT u.id, u.uid, u.email, u.nombre, u.apellidos, u.telefono, u.user, u.permisos,
                       u.idclub, u.idequipo, u.idtemporada, u.photourl, u.observaciones
                FROM tusuarios u
                WHERE u.id = ?
                  AND u.idtemporada = ?
                LIMIT 1";
        return $db->selectOne($sql, [$idTutor, $idTemporada]);
    }, 300);

    if (!$tutor) {
        respondNotFound('Tutor no encontrado');
    }

    respondSuccess($tutor);
}
