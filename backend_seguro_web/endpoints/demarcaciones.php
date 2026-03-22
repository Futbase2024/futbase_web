<?php
/**
 * Endpoint de Gestión de Demarcaciones
 * Operaciones CRUD de demarcaciones
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/PermissionHelpers.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(300); // Caché de 5 minutos

try {
    // Intentar obtener action de varias fuentes
    $action = $_GET['action'] ?? null;

    // Si no está en GET, intentar leer del body JSON
    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;
    }

    // Normalizar action a lowercase
    $action = strtolower($action ?? '');

    // 🔓 Acciones públicas que NO requieren autenticación
    $publicActions = ['getdemarcaciones'];

    // Solo autenticar si la acción NO es pública
    $userData = null;
    if (!in_array($action, $publicActions)) {
        // 🔐 Autenticar con Firebase y aplicar rate limit
        $userData = $middleware->protect(100, 60, true);
    }

    switch ($action) {
        case 'getdemarcacion':
            getDemarcacion($db, $cache, $userData);
            break;

        case 'getdemarcaciones':
            getDemarcaciones($db, $cache, $userData);
            break;

        case 'getdemarcacionesbyclub':
            getDemarcacionesByClub($db, $cache, $userData);
            break;

        case 'createDemarcacion':
            createDemarcacion($db, $cache, $userData);
            break;

        case 'updateDemarcacion':
            updateDemarcacion($db, $cache, $userData);
            break;

        case 'deleteDemarcacion':
            deleteDemarcacion($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
            break;
    }

} catch (Exception $e) {
    error_log("Demarcaciones error: " . $e->getMessage());
    respondError('Error interno del servidor', 500);
}

// ========== OPERACIONES DE DEMARCACIONES ==========

/**
 * Obtener demarcación por ID
 */
function getDemarcacion($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$id || !$idTemporada) {
        respondError('id e idTemporada son requeridos', 400);
    }

    $cacheKey = "demarcacion_{$id}_{$idTemporada}";
    $demarcacion = $cache->remember($cacheKey, function() use ($db, $id, $idTemporada) {
        $sql = "SELECT id, demarcacion as posicion, '' as photourl FROM tdemarcaciones WHERE id = ? AND idtemporada = ?";
        return $db->selectOne($sql, [$id, $idTemporada]);
    });

    if (!$demarcacion) {
        respondError('Demarcación no encontrada', 404);
    }

    respondSuccess(['demarcacion' => $demarcacion]);
}

/**
 * Obtener todas las demarcaciones (posiciones)
 * Acción pública - no requiere autenticación
 */
function getDemarcaciones($db, $cache, $userData) {
    $cacheKey = "demarcaciones_all";
    $demarcaciones = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT id, posicion, photourl FROM tposiciones ORDER BY id ASC";
        return $db->select($sql);
    });

    // Devolver array directo para compatibilidad con Flutter
    respondSuccess($demarcaciones);
}

/**
 * Obtener demarcaciones por club
 */
function getDemarcacionesByClub($db, $cache, $userData) {
    $idClub = Validator::validateInt($_GET['idClub'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idTemporada'] ?? null);

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "demarcaciones_club_{$idClub}_{$idTemporada}";
    $demarcaciones = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT DISTINCT d.id, d.demarcacion as posicion, '' as photourl
                FROM tdemarcaciones d
                INNER JOIN tjugador j ON j.iddemarcacion = d.id
                WHERE j.idclub = ? AND d.idtemporada = ?
                ORDER BY d.demarcacion ASC";
        return $db->select($sql, [$idClub, $idTemporada]);
    });

    respondSuccess(['demarcaciones' => $demarcaciones]);
}

/**
 * Crear nueva demarcación
 */
function createDemarcacion($db, $cache, $userData) {
    requireWritePermission($userData, 'demarcaciones', 'create');

    $demarcacion = Validator::validateString($_POST['demarcacion'] ?? '', 1, 100);
    $idTemporada = Validator::validateInt($_POST['idTemporada'] ?? null);

    if (!$demarcacion || !$idTemporada) {
        respondError('demarcacion e idTemporada son requeridos', 400);
    }

    // Insertar demarcación
    $sql = "INSERT INTO tdemarcaciones (demarcacion, idtemporada) VALUES (?, ?)";
    $idDemarcacion = $db->insert($sql, [$demarcacion, $idTemporada]);

    // Limpiar caché
    $cache->clear("demarcaciones_*");

    respondSuccess([
        'id' => $idDemarcacion,
        'message' => 'Demarcación creada exitosamente'
    ]);
}

/**
 * Actualizar demarcación
 */
function updateDemarcacion($db, $cache, $userData) {
    requireWritePermission($userData, 'demarcaciones', 'update');
    $id = Validator::validateInt($_POST['id'] ?? null);
    $demarcacion = Validator::validateString($_POST['demarcacion'] ?? '', 1, 100);

    if (!$id || !$demarcacion) {
        respondError('id y demarcacion son requeridos', 400);
    }

    // Actualizar demarcación
    $sql = "UPDATE tdemarcaciones SET demarcacion = ? WHERE id = ?";
    $affected = $db->execute($sql, [$demarcacion, $id]);

    // Limpiar caché
    $cache->clear("demarcaciones_*");
    $cache->clear("demarcacion_{$id}_*");

    respondSuccess([
        'affected_rows' => $affected,
        'message' => 'Demarcación actualizada exitosamente'
    ]);
}

/**
 * Eliminar demarcación
 */
function deleteDemarcacion($db, $cache, $userData) {
    requireWritePermission($userData, 'demarcaciones', 'delete');
    $id = Validator::validateInt($_POST['id'] ?? null);

    if (!$id) {
        respondError('id es requerido', 400);
    }

    // Verificar que no tenga jugadores asociados
    $sql = "SELECT COUNT(*) as count FROM tjugador WHERE iddemarcacion = ?";
    $result = $db->selectOne($sql, [$id]);

    if ($result['count'] > 0) {
        respondError('No se puede eliminar la demarcación porque tiene jugadores asociados', 400);
    }

    // Eliminar demarcación
    $sql = "DELETE FROM tdemarcaciones WHERE id = ?";
    $affected = $db->execute($sql, [$id]);

    // Limpiar caché
    $cache->clear("demarcaciones_*");
    $cache->clear("demarcacion_{$id}_*");

    respondSuccess([
        'affected_rows' => $affected,
        'message' => 'Demarcación eliminada exitosamente'
    ]);
}

/**
 * Respuesta de éxito
 */
function respondSuccess($data) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $data
    ]);
    exit;
}

/**
 * Respuesta de error
 */
function respondError($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'error' => true,
        'message' => $message,
        'code' => $code
    ]);
    exit;
}
