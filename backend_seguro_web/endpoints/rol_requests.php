<?php
/**
 * Endpoint: rol_requests.php
 * Descripción: Gestión de solicitudes de cambio de rol de usuarios
 * Fecha: 2025-10-25
 *
 * Operaciones:
 * - count: Contar todas las solicitudes
 * - countPending: Contar solicitudes pendientes (por club)
 * - countPendingEntrenador: Contar solicitudes pendientes (por equipo)
 * - hasPendingRequest: Verificar si existe solicitud pendiente
 * - createRolRequest: Crear nueva solicitud
 * - createNewFanRol: Crear rol de fan directamente
 * - getAllRolRequests: Obtener todas las solicitudes
 * - getRolRequestsByState: Obtener solicitudes por estado
 * - getRolRequestsByUser: Obtener solicitudes de un usuario
 * - getRolRequestsById: Obtener solicitud por ID
 * - removeRolRequest: Eliminar solicitud
 * - removeValidatedRolRequest: Eliminar solicitud validada con lógica específica para tutores
 * - changeTemporadaPublicRol: Cambiar temporada de rol público
 * - updateRolRequestState: Aprobar/Rechazar solicitud y asignar rol
 * - createFanRol: Crear rol de fan
 * - isPlayerAssigned: Verificar si jugador está asignado
 * - assignPlayerToRole: Asignar jugador a rol de tutor
 * - updateRolRequest: Actualizar solicitud
 * - getRequestAllowedRoles: Obtener roles permitidos para solicitar
 */

// Cargar configuración global (manejo de errores, timezone, etc.)

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

// Inicializar servicios
$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché por defecto
$rateLimiter = new RateLimiter();

// Autenticar usuario con rate limiting de lectura
$userData = $middleware->protect();

// Obtener acción
$action = $_GET['action'] ?? null;

if (!$action) {
    respondError('Acción no especificada', 400);
}

// Rate limiting según el tipo de operación
$writingActions = ['createRolRequest', 'updateRolRequest', 'removeRolRequest', 'removeValidatedRolRequest', 'updateRolRequestState', 'assignPlayerToRole'];
if (in_array($action, $writingActions)) {
    // Crear rate limiter específico para escritura (50 req/min)
    $writeRateLimiter = new RateLimiter(50, 60);
    if (!$writeRateLimiter->isAllowed($userData['uid'])) {
        respondError('Demasiadas peticiones. Por favor, intenta más tarde.', 429);
    }
} else {
    // Rate limiter para lectura (100 req/min)
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        respondError('Demasiadas peticiones. Por favor, intenta más tarde.', 429);
    }
}

// Ejecutar acción
switch ($action) {
    case 'count':
        $result = countAllRequests($db, $cache, $userData);
        break;
    case 'countPending':
        $result = countPending($db, $cache, $userData);
        break;
    case 'countPendingEntrenador':
        $result = countPendingEntrenador($db, $cache, $userData);
        break;
    case 'hasPendingRequest':
        $result = hasPendingRequest($db, $cache, $userData);
        break;
    case 'createRolRequest':
        $result = createRolRequest($db, $cache, $userData);
        break;
    case 'createNewFanRol':
        $result = createNewFanRol($db, $cache, $userData);
        break;
    case 'getAllRolRequests':
        $result = getAllRolRequests($db, $cache, $userData);
        break;
    case 'getRolRequestsByState':
        $result = getRolRequestsByState($db, $cache, $userData);
        break;
    case 'getRolRequestsByUser':
        $result = getRolRequestsByUser($db, $cache, $userData);
        break;
    case 'getRolRequestsById':
        $result = getRolRequestsById($db, $cache, $userData);
        break;
    case 'removeRolRequest':
        $result = removeRolRequest($db, $cache, $userData);
        break;
    case 'removeValidatedRolRequest':
        $result = removeValidatedRolRequest($db, $cache, $userData);
        break;
    case 'changeTemporadaPublicRol':
        $result = changeTemporadaPublicRol($db, $cache, $userData);
        break;
    case 'updateRolRequestState':
        $result = updateRolRequestState($db, $cache, $userData);
        break;
    case 'createFanRol':
        $result = createFanRol($db, $cache, $userData);
        break;
    case 'isPlayerAssigned':
        $result = isPlayerAssigned($db, $cache, $userData);
        break;
    case 'assignPlayerToRole':
        $result = assignPlayerToRole($db, $cache, $userData);
        break;
    case 'updateRolRequest':
        $result = updateRolRequest($db, $cache, $userData);
        break;
    case 'getRequestAllowedRoles':
        $result = getRequestAllowedRoles($db, $cache, $userData);
        break;
    default:
        respondError('Acción no válida', 400);
}

respondSuccess($result);

// ==================== FUNCIONES ====================

/**
 * Cuenta todas las solicitudes de rol
 */
function countAllRequests($db, $cache, $userData) {
    $cacheKey = "rol_requests_count_all";

    return $cache->remember($cacheKey, function() use ($db) {
        $sql = 'SELECT COUNT(*) as total FROM vrolpeticion';
        $result = $db->selectOne($sql);
        return (int)($result['total'] ?? 0);
    }, 300);
}

/**
 * Cuenta solicitudes pendientes por club
 */
function countPending($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $clubid = Validator::validateInt($input['clubId'] ?? null);

    $sql = 'SELECT COUNT(*) as count FROM vrolpeticion WHERE estado = 0';
    $params = [];

    if ($clubid !== null) {
        $sql .= ' AND idclub = ?';
        $params[] = $clubid;
    } else {
        $sql .= ' AND idclub = 0';
    }

    $cacheKey = "rol_requests_pending_club_{$clubid}";

    return $cache->remember($cacheKey, function() use ($db, $sql, $params) {
        $result = $db->selectOne($sql, $params);
        return (int)($result['count'] ?? 0);
    }, 60);
}

/**
 * Cuenta solicitudes pendientes por equipo
 */
function countPendingEntrenador($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $teamid = Validator::validateInt($input['teamId'] ?? null);

    $sql = 'SELECT COUNT(*) as count FROM vrolpeticion WHERE estado = 0';
    $params = [];

    if ($teamid !== null) {
        $sql .= ' AND idequipo = ?';
        $params[] = $teamid;
    } else {
        $sql .= ' AND idequipo = 0';
    }

    $cacheKey = "rol_requests_pending_team_{$teamid}";

    return $cache->remember($cacheKey, function() use ($db, $sql, $params) {
        $result = $db->selectOne($sql, $params);
        return (int)($result['count'] ?? 0);
    }, 60);
}

/**
 * Verifica si existe una solicitud pendiente
 */
function hasPendingRequest($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idusuario = Validator::validateInt($input['idusuario'] ?? null);
    $roletype = Validator::validateInt($input['roleType'] ?? null);
    $clubid = Validator::validateInt($input['clubId'] ?? null);
    $teamid = Validator::validateInt($input['teamId'] ?? null);
    $jugadorid = Validator::validateInt($input['jugadorId'] ?? null);

    if (!$idusuario || !$roletype) {
        respondError('Parámetros incompletos: idusuario y roleType son requeridos', 400);
    }

    $sql = 'SELECT * FROM vrolpeticion WHERE idusuario = ? AND tipo = ? AND estado IN (0, 1)';
    $params = [$idusuario, $roletype];

    if ($clubid !== null) {
        $sql .= ' AND idclub = ?';
        $params[] = $clubid;
    } else {
        $sql .= ' AND idclub = 0';
    }

    if ($teamid !== null) {
        $sql .= ' AND idequipo = ?';
        $params[] = $teamid;
    } else {
        $sql .= ' AND idequipo = 0';
    }

    if ($jugadorid !== null) {
        $sql .= ' AND idjugador = ?';
        $params[] = $jugadorid;
    } else {
        $sql .= ' AND idjugador = 0';
    }

    $results = $db->select($sql, $params);
    return count($results) > 0;
}

/**
 * Crea una nueva solicitud de rol
 */
function createRolRequest($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $uid = Validator::validateString($input['uid'] ?? null);
    $idusuario = Validator::validateInt($input['idusuario'] ?? null);
    $idtemporada = Validator::validateInt($input['idtemporada'] ?? null);
    $tipo = Validator::validateInt($input['tipo'] ?? null);
    $fecha = $input['fecha'] ?? date('Y-m-d H:i:s');
    $estado = Validator::validateInt($input['estado'] ?? 0);
    $idclub = Validator::validateInt($input['idclub'] ?? 0);
    $idequipo = Validator::validateInt($input['idequipo'] ?? 0);
    $idjugador = Validator::validateInt($input['idjugador'] ?? 0);

    if (!$uid || !$idusuario || !$tipo) {
        respondError('Parámetros incompletos: uid, idusuario y tipo son requeridos', 400);
    }

    $sql = 'INSERT INTO trolpeticion (uid, idusuario, idtemporada, tipo, fecha, estado, idclub, idequipo, idjugador)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';

    $id = $db->insert($sql, [$uid, $idusuario, $idtemporada, $tipo, $fecha, $estado, $idclub, $idequipo, $idjugador]);

    if (!$id) {
        respondError('Error al crear solicitud de rol', 500);
    }

    // Invalidar cachés relevantes
    $cache->delete("rol_requests_all");
    $cache->delete("rol_requests_user_{$uid}");
    $cache->delete("rol_requests_pending_club_{$idclub}");
    $cache->delete("rol_requests_pending_team_{$idequipo}");

    // Obtener la solicitud creada
    $getSql = 'SELECT * FROM vrolpeticion WHERE id = ?';
    $request = $db->selectOne($getSql, [$id]);

    return $request;
}

/**
 * Crea un nuevo rol de fan directamente (aprobado automáticamente)
 */
function createNewFanRol($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $uid = Validator::validateString($input['uid'] ?? null);
    $idusuario = Validator::validateInt($input['idusuario'] ?? null);
    $idtemporada = Validator::validateInt($input['idtemporada'] ?? null);
    $tipo = Validator::validateInt($input['tipo'] ?? null);
    $fecha = $input['fecha'] ?? date('Y-m-d H:i:s');
    $idclub = Validator::validateInt($input['idclub'] ?? 0);
    $idequipo = Validator::validateInt($input['idequipo'] ?? 0);
    $idjugador = Validator::validateInt($input['idjugador'] ?? 0);

    if (!$uid || !$idusuario || !$tipo) {
        respondError('Parámetros incompletos: uid, idusuario y tipo son requeridos', 400);
    }

    $db->beginTransaction();

    try {
        // Insertar solicitud aprobada (estado = 1)
        $sqlPeticion = 'INSERT INTO trolpeticion (uid, idusuario, idtemporada, tipo, fecha, estado, idclub, idequipo, idjugador)
                        VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?)';

        $db->insert($sqlPeticion, [$uid, $idusuario, $idtemporada, $tipo, $fecha, $idclub, $idequipo, $idjugador]);

        // Insertar rol directamente
        $sqlRol = 'INSERT INTO troles (uid, idusuario, idtemporada, tipo, selectedrol, idclub, idequipo)
                   VALUES (?, ?, ?, ?, 0, ?, ?)';

        $db->insert($sqlRol, [$uid, $idusuario, $idtemporada, $tipo, $idclub, $idequipo]);

        $db->commit();

        // Invalidar cachés
        $cache->delete("rol_requests_all");
        $cache->delete("rol_requests_user_{$uid}");
        $cache->delete("roles_user_{$uid}");

        return true;
    } catch (Exception $e) {
        $db->rollback();
        respondError('Error al crear rol de fan: ' . $e->getMessage(), 500);
    }
}

/**
 * Obtiene todas las solicitudes de rol
 */
function getAllRolRequests($db, $cache, $userData) {
    $cacheKey = "rol_requests_all";

    try {
        return $cache->remember($cacheKey, function() use ($db) {
            $sql = 'SELECT * FROM vrolpeticion ORDER BY fecha DESC';
            return $db->select($sql);
        }, 300);
    } catch (Exception $e) {
        error_log("Error en getAllRolRequests: " . $e->getMessage());
        return [];
    }
}

/**
 * Obtiene solicitudes por estado
 */
function getRolRequestsByState($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $statename = Validator::validateString($input['stateName'] ?? null);

    if (!$statename) {
        respondError('Estado requerido', 400);
    }

    // Mapeo de estados
    $stateMap = [
        'submitted' => 0,
        'approved' => 1,
        'rejected' => 2,
        'cancelled' => 3,
    ];

    $estadoid = $stateMap[$statename] ?? null;

    if ($estadoid === null) {
        return [];
    }

    $cacheKey = "rol_requests_state_{$statename}";

    try {
        return $cache->remember($cacheKey, function() use ($db, $estadoid) {
            $sql = 'SELECT * FROM vrolpeticion WHERE estado = ? ORDER BY fecha DESC';
            return $db->select($sql, [$estadoid]);
        }, 300);
    } catch (Exception $e) {
        error_log("Error en getRolRequestsByState: " . $e->getMessage());
        return [];
    }
}

/**
 * Obtiene solicitudes de un usuario
 */
function getRolRequestsByUser($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $uid = Validator::validateString($input['uid'] ?? null);

    if (!$uid) {
        respondError('UID requerido', 400);
    }

    $cacheKey = "rol_requests_user_{$uid}";

    try {
        return $cache->remember($cacheKey, function() use ($db, $uid) {
            $sql = 'SELECT * FROM vrolpeticion WHERE uid = ? ORDER BY fecha DESC';
            return $db->select($sql, [$uid]);
        }, 300);
    } catch (Exception $e) {
        error_log("Error en getRolRequestsByUser: " . $e->getMessage());
        return [];
    }
}

/**
 * Obtiene solicitud por ID
 */
function getRolRequestsById($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('ID requerido', 400);
    }

    $sql = 'SELECT * FROM vrolpeticion WHERE id = ?';
    $request = $db->selectOne($sql, [$id]);

    if (!$request) {
        respondError('Solicitud no encontrada', 404);
    }

    return $request;
}

/**
 * Elimina una solicitud de rol
 */
function removeRolRequest($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('ID requerido', 400);
    }

    // Obtener la solicitud antes de eliminarla para invalidar cachés
    $sql = 'SELECT * FROM vrolpeticion WHERE id = ?';
    $request = $db->selectOne($sql, [$id]);

    if (!$request) {
        respondError('Solicitud no encontrada', 404);
    }

    $deleteSql = 'DELETE FROM trolpeticion WHERE id = ?';
    $result = $db->execute($deleteSql, [$id]);

    if (!$result) {
        respondError('Error al eliminar solicitud', 500);
    }

    // Invalidar cachés
    $cache->delete("rol_requests_all");
    $cache->delete("rol_requests_user_{$request['uid']}");
    $cache->delete("rol_requests_pending_club_{$request['idclub']}");
    $cache->delete("rol_requests_pending_team_{$request['idequipo']}");

    return true;
}

/**
 * Elimina una solicitud validada con lógica específica para tutores
 */
function removeValidatedRolRequest($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $id = Validator::validateInt($input['id'] ?? null);
    $tipo = Validator::validateInt($input['tipo'] ?? null);
    $idusuario = Validator::validateInt($input['idusuario'] ?? null);
    $idjugador = Validator::validateInt($input['idjugador'] ?? null);
    $uid = Validator::validateString($input['uid'] ?? null);

    if (!$id) {
        respondError('ID requerido', 400);
    }

    // Obtener información del rol antes de eliminarlo para invalidar cachés correctamente
    $getRoleSql = 'SELECT idclub, idtemporada, idequipo FROM troles WHERE id = ? LIMIT 1';
    $roleInfo = $db->selectOne($getRoleSql, [$id]);
    $idclub = $roleInfo['idclub'] ?? null;
    $idtemporada = $roleInfo['idtemporada'] ?? null;
    $idequipo = $roleInfo['idequipo'] ?? null;

    $db->beginTransaction();

    try {
        // 1. Eliminar de trolpeticion
        $deletePeticionSql = 'DELETE FROM trolpeticion WHERE id = ?';
        $db->execute($deletePeticionSql, [$id]);

        // 2. Para tutores (tipo 4), manejar la tabla troles de manera específica
        if ($tipo == 4 && $idjugador !== null && $idusuario !== null) {
            // Buscar el registro en troles para este tutor
            $findRoleSql = 'SELECT id, idjugador, idjugador2, idjugador3, idjugador4
                           FROM troles
                           WHERE idusuario = ? AND tipo = ? AND uid = ?';

            $role = $db->selectOne($findRoleSql, [$idusuario, $tipo, $uid]);

            if ($role) {
                $roleId = $role['id'];
                $fieldToUpdate = null;

                // Buscar en qué campo está el jugador
                for ($i = 1; $i <= 4; $i++) {
                    $field = $i == 1 ? 'idjugador' : "idjugador{$i}";
                    $fieldValue = (int)($role[$field] ?? 0);

                    if ($fieldValue == $idjugador) {
                        $fieldToUpdate = $field;
                        break;
                    }
                }

                if ($fieldToUpdate) {
                    // Actualizar solo el campo específico del jugador a 0
                    $updateRoleSql = "UPDATE troles SET {$fieldToUpdate} = 0 WHERE id = ?";
                    $db->execute($updateRoleSql, [$roleId]);

                    // Verificar si todos los campos de jugador están en 0
                    $checkSql = 'SELECT idjugador, idjugador2, idjugador3, idjugador4 FROM troles WHERE id = ?';
                    $updatedRole = $db->selectOne($checkSql, [$roleId]);

                    $allZero = true;
                    for ($i = 1; $i <= 4; $i++) {
                        $field = $i == 1 ? 'idjugador' : "idjugador{$i}";
                        if ((int)($updatedRole[$field] ?? 0) != 0) {
                            $allZero = false;
                            break;
                        }
                    }

                    // Si todos están en 0, eliminar el registro completo
                    if ($allZero) {
                        $deleteRoleSql = 'DELETE FROM troles WHERE id = ?';
                        $db->execute($deleteRoleSql, [$roleId]);
                    }
                }
            }
        } else if ($tipo != 4) {
            // Para otros tipos, eliminar completamente de troles
            $deleteRoleSql = 'DELETE FROM troles WHERE idusuario = ? AND tipo = ? AND uid = ?';
            $db->execute($deleteRoleSql, [$idusuario, $tipo, $uid]);
        }

        $db->commit();

        // Invalidar cachés de solicitudes de rol
        $cache->delete("rol_requests_all");
        $cache->delete("rol_requests_user_{$uid}");
        $cache->delete("roles_user_{$uid}");

        // Invalidar cachés de usuarios y roles por club/equipo
        if ($idclub) {
            $cache->delete("roles_club_{$idclub}_temporada_{$idtemporada}");
            $cache->delete("usuarios_club_{$idclub}_temporada_{$idtemporada}");
            $cache->delete("roles_tutores_club_{$idclub}_temporada_{$idtemporada}");
        }
        if ($idequipo) {
            $cache->delete("usuarios_equipo_{$idequipo}_temporada_{$idtemporada}");
        }
        if ($tipo && $idclub && $idtemporada) {
            $cache->delete("roles_tipo_{$tipo}_club_{$idclub}_temporada_{$idtemporada}");
        }

        return true;
    } catch (Exception $e) {
        $db->rollback();
        respondError('Error al eliminar solicitud validada: ' . $e->getMessage(), 500);
    }
}

/**
 * Cambia la temporada de un rol público
 */
function changeTemporadaPublicRol($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $selectedrolid = Validator::validateInt($input['selectedRolId'] ?? null);
    $idtemporada = Validator::validateInt($input['idtemporada'] ?? null);

    if (!$selectedrolid || !$idtemporada) {
        respondError('Parámetros incompletos: selectedRolId e idtemporada son requeridos', 400);
    }

    $sql = 'UPDATE troles SET idtemporada = ? WHERE id = ?';
    $result = $db->execute($sql, [$idtemporada, $selectedrolid]);

    if (!$result) {
        respondError('Error al actualizar temporada', 500);
    }

    // Invalidar caché de roles
    $cache->delete("roles_user_{$userData['uid']}");

    return true;
}

/**
 * Actualiza el estado de una solicitud y asigna el rol si es aprobado
 */
function updateRolRequestState($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $requestid = Validator::validateInt($input['requestId'] ?? null);
    $newstate = Validator::validateInt($input['newState'] ?? null);
    $comment = $input['comment'] ?? null;
    $request = $input['request'] ?? null;

    if ($requestid === null || $newstate === null) {
        respondError('Parámetros incompletos: requestId y newState son requeridos', 400);
    }

    $db->beginTransaction();

    try {
        // Si es aprobado (estado = 1), asignar rol primero
        if ($newstate == 1 && $request) {
            $asignado = asignarRol($db, $request);
            if (!$asignado) {
                throw new Exception('No se pudo asignar el rol');
            }
        }

        // Actualizar estado de la solicitud
        $sql = 'UPDATE trolpeticion SET estado = ?';
        $params = [$newstate];

        if ($comment) {
            $sql .= ', comentario = ?';
            $params[] = $comment;
        }

        $sql .= ' WHERE id = ?';
        $params[] = $requestid;

        $result = $db->execute($sql, $params);

        if (!$result) {
            throw new Exception('Error al actualizar estado de solicitud');
        }

        $db->commit();

        // Invalidar cachés
        $cache->delete("rol_requests_all");
        if (isset($request['uid'])) {
            $cache->delete("rol_requests_user_{$request['uid']}");
            $cache->delete("roles_user_{$request['uid']}");
        }

        return true;
    } catch (Exception $e) {
        $db->rollback();
        respondError('Error al actualizar estado: ' . $e->getMessage(), 500);
    }
}

/**
 * Función auxiliar para asignar rol cuando se aprueba una solicitud
 */
function asignarRol($db, $request) {
    $uid = Validator::validateString($request['uid'] ?? null);
    $tipo = Validator::validateInt($request['tipo'] ?? null);
    $idusuario = Validator::validateInt($request['idusuario'] ?? null);
    $idtemporada = Validator::validateInt($request['idtemporada'] ?? null);
    $idclub = Validator::validateInt($request['idclub'] ?? 0);
    $idequipo = Validator::validateInt($request['idequipo'] ?? 0);
    $idjugador = Validator::validateInt($request['idjugador'] ?? 0);

    if (!$uid || !$tipo || !$idusuario) {
        return false;
    }

    // Verificar si ya existe rol para este uid, tipo
    $checkSql = 'SELECT id FROM troles WHERE uid = ? AND tipo = ?';
    $checkParams = [$uid, $tipo];

    // Solo filtrar por equipo/club si NO es tutor (tipo 4)
    if ($tipo != 4) {
        if ($tipo == 2) {
            // Entrenadores: por equipo
            $checkSql .= ' AND idequipo = ?';
            $checkParams[] = $idequipo;
        } elseif (in_array($tipo, [3, 10])) {
            // Coordinadores y admin: por club
            $checkSql .= ' AND idclub = ?';
            $checkParams[] = $idclub;
        }
    }

    $existingRole = $db->selectOne($checkSql, $checkParams);

    if ($existingRole) {
        $roleId = $existingRole['id'];
        // Actualizar el rol existente
        $updateSql = 'UPDATE troles SET idtemporada = ?, selectedrol = 1, idjugador = ? WHERE id = ?';
        $db->execute($updateSql, [$idtemporada, $idjugador, $roleId]);
    } else {
        // Crear nuevo rol con selectedrol = 1
        $insertSql = 'INSERT INTO troles (tipo, idusuario, idtemporada, uid, selectedrol, idclub, idequipo, idjugador)
                      VALUES (?, ?, ?, ?, 1, ?, ?, ?)';

        $roleId = $db->insert($insertSql, [$tipo, $idusuario, $idtemporada, $uid, $idclub, $idequipo, $idjugador]);

        if (!$roleId) {
            return false;
        }
    }

    // Actualizar selectedrol: poner este en 1 y el resto en 0
    $updateOthersSql = 'UPDATE troles SET selectedrol = 0 WHERE uid = ? AND id != ?';
    $db->execute($updateOthersSql, [$uid, $roleId]);

    return true;
}

/**
 * Crea un rol de fan
 */
function createFanRol($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $request = $input['request'] ?? null;

    if (!$request) {
        respondError('Solicitud requerida', 400);
    }

    $idusuario = Validator::validateInt($request['idusuario'] ?? null);
    $tipo = Validator::validateInt($request['tipo'] ?? null);
    $idclub = Validator::validateInt($request['idclub'] ?? 0);
    $idequipo = Validator::validateInt($request['idequipo'] ?? 0);
    $idjugador = Validator::validateInt($request['idjugador'] ?? 0);

    // Verificar si ya existe
    $selectSql = 'SELECT * FROM troles
                  WHERE idusuario = ? AND tipo = ? AND idclub = ? AND idequipo = ? AND idjugador = ?';

    $existing = $db->selectOne($selectSql, [$idusuario, $tipo, $idclub, $idequipo, $idjugador]);

    if ($existing) {
        respondError('El rol ya existe', 400);
    }

    $uid = Validator::validateString($request['uid'] ?? null);
    $idtemporada = Validator::validateInt($request['idtemporada'] ?? null);

    $insertSql = 'INSERT INTO troles (tipo, idusuario, idtemporada, uid, selectedrol, idclub, idequipo, idjugador)
                  VALUES (?, ?, ?, ?, 1, ?, ?, ?)';

    $roleId = $db->insert($insertSql, [$tipo, $idusuario, $idtemporada, $uid, $idclub, $idequipo, $idjugador]);

    if (!$roleId) {
        respondError('Error al crear rol de fan', 500);
    }

    // Poner otros roles en selectedrol = 0
    $updateSql = 'UPDATE troles SET selectedrol = 0 WHERE uid = ? AND id != ?';
    $db->execute($updateSql, [$uid, $roleId]);

    // Invalidar caché
    $cache->delete("roles_user_{$uid}");

    return true;
}

/**
 * Verifica si un jugador está asignado a un rol
 */
function isPlayerAssigned($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $userid = Validator::validateInt($input['userId'] ?? null);
    $roletype = Validator::validateInt($input['roleType'] ?? null);
    $playerid = Validator::validateInt($input['playerId'] ?? null);
    $clubid = Validator::validateInt($input['clubId'] ?? null);
    $teamid = Validator::validateInt($input['teamId'] ?? null);

    if (!$userid || !$roletype || !$playerid) {
        respondError('Parámetros incompletos: userId, roleType y playerId son requeridos', 400);
    }

    $sql = 'SELECT
                CASE
                    WHEN idjugador = ? THEN "idjugador"
                    WHEN idjugador2 = ? THEN "idjugador2"
                    WHEN idjugador3 = ? THEN "idjugador3"
                    WHEN idjugador4 = ? THEN "idjugador4"
                    ELSE NULL
                END as campo_asignado
            FROM troles
            WHERE idusuario = ? AND tipo = ? AND estado = 1';

    $params = [$playerid, $playerid, $playerid, $playerid, $userid, $roletype];

    if ($clubid !== null) {
        $sql .= ' AND idclub = ?';
        $params[] = $clubid;
    } else {
        $sql .= ' AND (idclub IS NULL OR idclub = 0)';
    }

    if ($teamid !== null) {
        $sql .= ' AND idequipo = ?';
        $params[] = $teamid;
    } else {
        $sql .= ' AND (idequipo IS NULL OR idequipo = 0)';
    }

    $result = $db->selectOne($sql, $params);
    return $result['campo_asignado'] ?? null;
}

/**
 * Asigna un jugador a un rol de tutor
 */
function assignPlayerToRole($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $userid = Validator::validateInt($input['userId'] ?? null);
    $roletype = Validator::validateInt($input['roleType'] ?? null);
    $playerid = Validator::validateInt($input['playerId'] ?? null);
    $temporadaid = Validator::validateInt($input['temporadaId'] ?? null);
    $uid = Validator::validateString($input['uid'] ?? null);
    $clubid = Validator::validateInt($input['clubId'] ?? null);
    $teamid = Validator::validateInt($input['teamId'] ?? null);
    $emailtutor = Validator::validateString($input['emailTutor'] ?? '');

    if (!$userid || !$roletype || !$playerid || !$uid) {
        respondError('Parámetros incompletos: userId, roleType, playerId y uid son requeridos', 400);
    }

    $db->beginTransaction();

    try {
        // Verificar si ya existe registro para este uid y tipo
        $checkSql = 'SELECT id, idjugador, idjugador2, idjugador3, idjugador4
                     FROM troles WHERE uid = ? AND tipo = ?';

        $existing = $db->selectOne($checkSql, [$uid, $roletype]);

        if ($existing) {
            // Verificar si el jugador ya está asignado
            $jugadores = [
                (int)($existing['idjugador'] ?? 0),
                (int)($existing['idjugador2'] ?? 0),
                (int)($existing['idjugador3'] ?? 0),
                (int)($existing['idjugador4'] ?? 0),
            ];

            if (in_array($playerid, $jugadores)) {
                $db->commit();
                return 'already_assigned';
            }

            // Buscar primer campo disponible
            $fieldToUpdate = null;
            if (!$existing['idjugador'] || $existing['idjugador'] == 0) {
                $fieldToUpdate = 'idjugador';
            } elseif (!$existing['idjugador2'] || $existing['idjugador2'] == 0) {
                $fieldToUpdate = 'idjugador2';
            } elseif (!$existing['idjugador3'] || $existing['idjugador3'] == 0) {
                $fieldToUpdate = 'idjugador3';
            } elseif (!$existing['idjugador4'] || $existing['idjugador4'] == 0) {
                $fieldToUpdate = 'idjugador4';
            }

            if (!$fieldToUpdate) {
                $db->rollback();
                respondError('No hay campos disponibles para asignar más jugadores', 400);
            }

            // Actualizar
            $updateSql = "UPDATE troles SET {$fieldToUpdate} = ?, selectedrol = 1 WHERE id = ?";
            $db->execute($updateSql, [$playerid, $existing['id']]);

            // Actualizar tutor en tjugadores
            actualizarTutorEnJugador($db, $playerid, $userid, $emailtutor);

            $db->commit();

            // Invalidar caché
            $cache->delete("roles_user_{$uid}");

            return $fieldToUpdate;
        } else {
            // Crear nuevo registro
            $insertSql = 'INSERT INTO troles (tipo, idusuario, idtemporada, uid, idjugador, idclub, idequipo, selectedrol)
                          VALUES (?, ?, ?, ?, ?, ?, ?, 1)';

            $db->insert($insertSql, [$roletype, $userid, $temporadaid, $uid, $playerid, $clubid ?? 0, $teamid ?? 0]);

            // Actualizar tutor en tjugadores
            actualizarTutorEnJugador($db, $playerid, $userid, $emailtutor);

            $db->commit();

            // Invalidar caché
            $cache->delete("roles_user_{$uid}");

            return 'idjugador';
        }
    } catch (Exception $e) {
        $db->rollback();
        respondError('Error al asignar jugador al rol: ' . $e->getMessage(), 500);
    }
}

/**
 * Función auxiliar para actualizar tutor en tabla tjugadores
 */
function actualizarTutorEnJugador($db, $playerid, $userid, $emailtutor) {
    // Obtener tutores actuales
    $checkSql = 'SELECT idtutor1, idtutor2 FROM tjugadores WHERE id = ?';
    $jugador = $db->selectOne($checkSql, [$playerid]);

    if (!$jugador) {
        return;
    }

    $idtutor1 = (int)($jugador['idtutor1'] ?? 0);
    $idtutor2 = (int)($jugador['idtutor2'] ?? 0);

    // Si ya es tutor, no hacer nada
    if ($idtutor1 == $userid || $idtutor2 == $userid) {
        return;
    }

    // Asignar a primer campo disponible
    if ($idtutor1 == 0) {
        $updateSql = 'UPDATE tjugadores SET idtutor1 = ?, emailtutor1 = ? WHERE id = ?';
        $db->execute($updateSql, [$userid, $emailtutor, $playerid]);
    } elseif ($idtutor2 == 0) {
        $updateSql = 'UPDATE tjugadores SET idtutor2 = ?, emailtutor2 = ? WHERE id = ?';
        $db->execute($updateSql, [$userid, $emailtutor, $playerid]);
    }
}

/**
 * Actualiza una solicitud de rol
 */
function updateRolRequest($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $id = Validator::validateInt($input['id'] ?? null);
    $estado = Validator::validateInt($input['estado'] ?? null);
    $comentario = $input['comentario'] ?? '';

    if (!$id || $estado === null) {
        respondError('Parámetros incompletos: id y estado son requeridos', 400);
    }

    $sql = 'UPDATE trolpeticion SET estado = ?, comentario = ? WHERE id = ?';
    $result = $db->execute($sql, [$estado, $comentario, $id]);

    if (!$result) {
        respondError('Error al actualizar solicitud', 500);
    }

    // Invalidar cachés
    $cache->delete("rol_requests_all");

    // Obtener solicitud actualizada
    $getSql = 'SELECT * FROM vrolpeticion WHERE id = ?';
    $request = $db->selectOne($getSql, [$id]);

    return $request;
}

/**
 * Obtiene roles permitidos para solicitar
 */
function getRequestAllowedRoles($db, $cache, $userData) {
    $cacheKey = "request_allowed_roles";

    return $cache->remember($cacheKey, function() use ($db) {
        $sql = 'SELECT * FROM ttiporol WHERE tipo NOT IN (1, 3, 8, 11, 16) ORDER BY tipo ASC';
        return $db->select($sql);
    }, 3600);
}
