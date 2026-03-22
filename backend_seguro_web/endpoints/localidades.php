<?php
/**
 * Endpoint de Localidades
 * Operaciones de consulta y creación de localidades
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
$cache = new CacheManager(3600); // Caché de 1 hora (datos de catálogo)

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
        case 'getLocalidades':
            getLocalidades($db, $cache, $userData);
            break;

        case 'getLocalidadById':
            getLocalidadById($db, $cache, $userData);
            break;

        case 'getLocalidadByName':
            getLocalidadByName($db, $cache, $userData);
            break;

        case 'createLocalidad':
            createLocalidad($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
    }

} catch (Exception $e) {
    error_log("Error en localidades.php: " . $e->getMessage());
    respondError('Error del servidor', 500);
}

// ========== OPERACIONES DE LOCALIDADES ==========

/**
 * Obtiene todas las localidades
 */
function getLocalidades($db, $cache, $userData) {
    $cacheKey = "localidades_all";

    $localidades = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tlocalidades ORDER BY localidad ASC";
        return $db->select($sql);
    }, 3600); // Cache 1 hora

    respondSuccess(['localidades' => $localidades]);
}

/**
 * Obtiene localidad por ID
 */
function getLocalidadById($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('ID es requerido', 400);
    }

    $cacheKey = "localidad_id_{$id}";

    $localidad = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM tlocalidades WHERE id = ?";
        return $db->selectOne($sql, [$id]);
    }, 3600); // Cache 1 hora

    if (!$localidad) {
        respondError('Localidad no encontrada', 404);
    }

    respondSuccess(['localidad' => $localidad]);
}

/**
 * Obtiene localidad por nombre
 */
function getLocalidadByName($db, $cache, $userData) {
    $localidad = Validator::validateString($_GET['localidad'] ?? '', 1, 100);

    if (!$localidad) {
        respondError('Nombre de localidad es requerido', 400);
    }

    $cacheKey = "localidad_name_" . md5($localidad);

    $result = $cache->remember($cacheKey, function() use ($db, $localidad) {
        $sql = "SELECT * FROM tlocalidades WHERE localidad = ?";
        return $db->selectOne($sql, [$localidad]);
    }, 3600); // Cache 1 hora

    if (!$result) {
        respondError('Localidad no encontrada', 404);
    }

    respondSuccess(['localidad' => $result]);
}

/**
 * Crea nueva localidad
 * NOTA: Requiere permisos de escritura (admin)
 */
function createLocalidad($db, $cache, $userData) {
    // Verificar que el usuario tenga permisos de admin
    // Por ahora, solo verificamos que esté autenticado
    // TODO: Implementar verificación de permisos específicos

    $input = json_decode(file_get_contents('php://input'), true);

    $localidad = Validator::validateString($input['localidad'] ?? '', 1, 100);
    $cpostal = Validator::validateString($input['cpostal'] ?? '', 4, 10);
    $idprovincia = Validator::validateInt($input['idprovincia'] ?? null);
    $provincia = Validator::validateString($input['provincia'] ?? '', 1, 100);

    if (!$localidad || !$cpostal || !$idprovincia || !$provincia) {
        respondError('Parámetros requeridos faltantes', 400);
    }

    // Verificar que no existe
    $checkSql = "SELECT COUNT(*) as count FROM tlocalidades WHERE localidad = ?";
    $exists = $db->selectOne($checkSql, [$localidad]);

    if ($exists && $exists['count'] > 0) {
        respondError('Ya existe una localidad con este nombre', 409);
    }

    // Insertar
    $insertSql = "INSERT INTO tlocalidades (localidad, cpostal, idprovincia, provincia)
                  VALUES (?, ?, ?, ?)";

    $newId = $db->insert($insertSql, [$localidad, $cpostal, $idprovincia, $provincia]);

    // Obtener la localidad creada
    $localidadCreada = $db->selectOne("SELECT * FROM tlocalidades WHERE id = ?", [$newId]);

    // Limpiar caché
    $cache->delete("localidades_all");
    $cache->delete("localidad_name_" . md5($localidad));

    respondSuccess(['localidad' => $localidadCreada]);
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
