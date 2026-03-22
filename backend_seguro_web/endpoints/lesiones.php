<?php
/**
 * Endpoint de Gestión de Lesiones
 * Operaciones CRUD de lesiones de jugadores
 *
 * Permisos: Cualquier usuario autenticado para lectura
 *           Roles 1,2,3,10,12,13 para escritura
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$db = Database::getInstance();
$cache = new CacheManager(300);
$auth = new FirebaseAuthMiddleware();
$userData = $auth->protect(100, 60);

$action = $_GET['action'] ?? $_POST['action'] ?? null;

try {
    switch ($action) {
        case 'getlesiones':
            getLesiones($db, $cache, $userData);
            break;
        case 'grabarlesion':
            grabarLesion($db, $cache, $userData);
            break;
        case 'updatelesion':
            updateLesion($db, $cache, $userData);
            break;
        case 'deletelesion':
            deleteLesion($db, $cache, $userData);
            break;
        default:
            respondError('❌ Acción no válida', 400);
            break;
    }
} catch (Exception $e) {
    error_log("Error in lesiones.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Función auxiliar para debug prints
 */
function debugPrint($message) {
    error_log($message);
}

/**
 * Obtener lesiones de un jugador
 * GET /lesiones.php?action=getlesiones&idjugador=123
 * Permisos: Cualquier usuario autenticado
 */
function getLesiones($db, $cache, $userData) {
    $idjugador = $_GET['idjugador'] ?? $_GET['idJugador'] ?? null;

    if (!$idjugador) {
        respondError('❌ idjugador es requerido', 400);
    }

    debugPrint("🔍 [Lesiones] Obteniendo lesiones del jugador $idjugador");

    $cacheKey = "lesiones_jugador_{$idjugador}";
    $lesiones = $cache->remember($cacheKey, function() use ($db, $idjugador) {
        $sql = "SELECT * FROM tlesiones WHERE idjugador = ? ORDER BY fechainicio DESC";
        return $db->select($sql, [$idjugador]);
    }, 300);

    debugPrint("✅ [Lesiones] Se encontraron " . count($lesiones) . " lesiones");
    respondSuccess(['lesiones' => $lesiones]);
}

/**
 * Crear una nueva lesión
 * POST /lesiones.php?action=grabarlesion
 * Body: {
 *   "idclub": 1,
 *   "idequipo": 1,
 *   "idjugador": 123,
 *   "lesion": "Rotura de ligamento",
 *   "tipo": "muscular",
 *   "observaciones": "...",
 *   "fechainicio": "2025-01-01",
 *   "idtemporada": 6
 * }
 * Permisos: Cualquier usuario autenticado
 */
function grabarLesion($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idclub = $input['idclub'] ?? null;
    $idequipo = $input['idequipo'] ?? null;
    $idjugador = $input['idjugador'] ?? null;
    $lesion = $input['lesion'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $observaciones = $input['observaciones'] ?? null;
    $fechainicio = $input['fechainicio'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;

    if (!$idclub || !$idequipo || !$idjugador || !$lesion || !$fechainicio || !$idtemporada) {
        respondError('❌ Faltan datos requeridos: idclub, idequipo, idjugador, lesion, fechainicio, idtemporada', 400);
    }

    debugPrint("➕ [Lesiones] Creando lesión para jugador $idjugador");

    // Convertir fechainicio si viene en formato ISO8601
    if (strpos($fechainicio, 'T') !== false) {
        $fechainicio = date('Y-m-d', strtotime($fechainicio));
    }

    $sql = "INSERT INTO tlesiones (idclub, idequipo, idjugador, lesion, tipo, observaciones, fechainicio, idtemporada)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    $insertId = $db->insert($sql, [$idclub, $idequipo, $idjugador, $lesion, $tipo, $observaciones, $fechainicio, $idtemporada]);

    if ($insertId) {
        // Invalidar cache
        $cache->forget("lesiones_jugador_{$idjugador}");

        debugPrint("✅ [Lesiones] Lesión creada con ID: " . $insertId);
        respondSuccess([
            'success' => true,
            'id' => $insertId
        ]);
    } else {
        debugPrint("❌ [Lesiones] Error al crear lesión");
        respondInternalError('❌ Error al crear lesión');
    }
}

/**
 * Actualizar una lesión
 * POST /lesiones.php?action=updatelesion
 * Body: {
 *   "id": 123,
 *   "fechainicio": "2025-01-01",
 *   "fechafin": "2025-02-01",
 *   "tipo": "muscular",
 *   "lesion": "Rotura de ligamento",
 *   "duracion": 30,
 *   "idjugador": 123
 * }
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function updateLesion($db, $cache, $userData) {
    // Validar permisos de escritura
    $writableRoles = [1, 2, 3, 10, 12, 13];

    // Obtener el rol del usuario desde vroles
    $uid = $userData['uid'] ?? null;
    $idtemporada = $userData['idtemporada'] ?? null;

    if (!$uid) {
        respondError('❌ UID de usuario no encontrado', 400);
    }

    $sqlRol = "SELECT tipo FROM vroles WHERE uid = ? AND idtemporada = ? AND selectedrol = 1 LIMIT 1";
    $rolData = $db->selectOne($sqlRol, [$uid, $idtemporada]);
    $userRole = $rolData['tipo'] ?? 0;

    debugPrint("🔐 [Lesiones] Usuario con ROL: $userRole");

    if (!in_array($userRole, $writableRoles)) {
        respondError('🔒 No tienes permisos para actualizar lesiones', 403);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    $fechainicio = $input['fechainicio'] ?? null;
    $fechafin = $input['fechafin'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $lesion = $input['lesion'] ?? null;
    $duracion = $input['duracion'] ?? 0;
    $idjugador = $input['idjugador'] ?? null;

    if (!$id || !$idjugador) {
        respondError('❌ Faltan datos requeridos: id, idjugador', 400);
    }

    debugPrint("✏️ [Lesiones] Actualizando lesión $id");

    // Verificar que la lesión existe
    $sqlCheck = "SELECT * FROM tlesiones WHERE id = ?";
    $existing = $db->selectOne($sqlCheck, [$id]);

    if (!$existing) {
        debugPrint("❌ [Lesiones] Lesión $id no encontrada");
        respondError('❌ La lesión no existe', 404);
    }

    // Convertir fechas si vienen en formato ISO8601
    if ($fechainicio && strpos($fechainicio, 'T') !== false) {
        $fechainicio = date('Y-m-d', strtotime($fechainicio));
    }
    if ($fechafin && strpos($fechafin, 'T') !== false) {
        $fechafin = date('Y-m-d', strtotime($fechafin));
    }

    // Construir SQL dinámicamente según los campos presentes
    $updateFields = [];
    $params = [];

    if ($fechainicio !== null) {
        $updateFields[] = "fechainicio = ?";
        $params[] = $fechainicio;
    }
    if ($fechafin !== null) {
        $updateFields[] = "fechafin = ?";
        $params[] = $fechafin;
    }
    if ($tipo !== null) {
        $updateFields[] = "tipo = ?";
        $params[] = $tipo;
    }
    if ($lesion !== null) {
        $updateFields[] = "lesion = ?";
        $params[] = $lesion;
    }
    if ($duracion !== null) {
        $updateFields[] = "duracion = ?";
        $params[] = $duracion;
    }

    $params[] = $id;

    $sql = "UPDATE tlesiones SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $result = $db->update($sql, $params);

    if ($result) {
        // Invalidar cache
        $cache->forget("lesiones_jugador_{$idjugador}");

        debugPrint("✅ [Lesiones] Lesión actualizada correctamente");
        respondSuccess(['success' => true]);
    } else {
        debugPrint("❌ [Lesiones] Error al actualizar lesión");
        respondInternalError('❌ Error al actualizar lesión');
    }
}

/**
 * Eliminar una lesión
 * POST /lesiones.php?action=deletelesion
 * Body: {"id": 123, "idjugador": 123}
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function deleteLesion($db, $cache, $userData) {
    // Validar permisos de escritura
    $writableRoles = [1, 2, 3, 10, 12, 13];

    // Obtener el rol del usuario desde vroles
    $uid = $userData['uid'] ?? null;
    $idtemporada = $userData['idtemporada'] ?? null;

    if (!$uid) {
        respondError('❌ UID de usuario no encontrado', 400);
    }

    $sqlRol = "SELECT tipo FROM vroles WHERE uid = ? AND idtemporada = ? AND selectedrol = 1 LIMIT 1";
    $rolData = $db->selectOne($sqlRol, [$uid, $idtemporada]);
    $userRole = $rolData['tipo'] ?? 0;

    debugPrint("🔐 [Lesiones] Usuario con ROL: $userRole");

    if (!in_array($userRole, $writableRoles)) {
        respondError('🔒 No tienes permisos para eliminar lesiones', 403);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    $idjugador = $input['idjugador'] ?? null;

    if (!$id) {
        respondError('❌ id es requerido', 400);
    }

    debugPrint("🗑️ [Lesiones] Eliminando lesión $id");

    $sql = "DELETE FROM tlesiones WHERE id = ?";
    $result = $db->delete($sql, [$id]);

    if ($result) {
        // Invalidar cache solo si tenemos el idjugador
        if ($idjugador) {
            $cache->forget("lesiones_jugador_{$idjugador}");
        }

        debugPrint("✅ [Lesiones] Lesión eliminada correctamente");
        respondSuccess(['success' => true]);
    } else {
        debugPrint("❌ [Lesiones] Error al eliminar lesión");
        respondInternalError('❌ Error al eliminar lesión');
    }
}
