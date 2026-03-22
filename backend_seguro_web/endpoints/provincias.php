<?php
/**
 * Endpoint de Gestión de Provincias
 * Operaciones de consulta de provincias
 *
 * Datos de catálogo público con caché largo (1 hora)
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(3600); // Caché de 1 hora (datos estáticos)

// Autenticar con Firebase y aplicar rate limit
$userData = $middleware->protect(100, 60, true);

try {
    // Intentar obtener action de varias fuentes
    $action = $_GET['action'] ?? null;

    // Si no está en GET, intentar leer del body JSON
    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;
    }

    switch ($action) {
        case 'getProvincias':
            getProvincias($db, $cache, $userData);
            break;

        case 'getProvinciaById':
            getProvinciaById($db, $cache, $userData);
            break;

        case 'getProvinciaByName':
            getProvinciaByName($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
            break;
    }

} catch (Exception $e) {
    error_log("Provincias error: " . $e->getMessage());
    respondError('Error interno del servidor', 500);
}

// ========== OPERACIONES DE PROVINCIAS ==========

/**
 * Obtener todas las provincias
 */
function getProvincias($db, $cache, $userData) {
    $cacheKey = "provincias_all";
    $provincias = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tprovincias ORDER BY provincia ASC";
        return $db->select($sql);
    }, 3600); // 1 hora de caché

    respondSuccess(['provincias' => $provincias]);
}

/**
 * Obtener provincia por ID
 */
function getProvinciaById($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('ID es requerido', 400);
    }

    $cacheKey = "provincia_{$id}";
    $provincia = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM tprovincias WHERE id = ?";
        return $db->selectOne($sql, [$id]);
    }, 3600);

    if (!$provincia) {
        respondError('Provincia no encontrada', 404);
    }

    respondSuccess(['provincia' => $provincia]);
}

/**
 * Obtener provincia por nombre
 */
function getProvinciaByName($db, $cache, $userData) {
    $provincia = Validator::validateString($_GET['provincia'] ?? '', 1, 100);

    if (!$provincia) {
        respondError('Nombre de provincia es requerido', 400);
    }

    $cacheKey = "provincia_name_" . md5($provincia);
    $provinciaData = $cache->remember($cacheKey, function() use ($db, $provincia) {
        $sql = "SELECT * FROM tprovincias WHERE provincia = ?";
        return $db->selectOne($sql, [$provincia]);
    }, 3600);

    if (!$provinciaData) {
        respondError('Provincia no encontrada', 404);
    }

    respondSuccess(['provincia' => $provinciaData]);
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
