<?php
/**
 * Endpoint de Camisetas
 * Gestión de camisetas de equipos
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
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
$cache = new CacheManager(3600); // 1 hora de caché para camisetas (datos estáticos)
$auth = new FirebaseAuthMiddleware();

// Proteger endpoint con autenticación y rate limiting
$userData = $auth->protect(100, 60); // 100 requests/min

// Obtener acción
$action = $_GET['action'] ?? '';

// Enrutamiento de acciones
try {
    switch ($action) {
        case 'cargarCamisetas':
            cargarCamisetas($db, $cache, $userData);
            break;

        case 'getCamiseta':
            getCamiseta($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in camisetas.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Carga todas las camisetas disponibles
 */
function cargarCamisetas($db, $cache, $userData) {
    $cacheKey = "camisetas_all";

    $camisetas = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tcamisetas ORDER BY id ASC";
        return $db->select($sql);
    }, 3600); // Cache largo (1 hora)

    respondSuccess($camisetas);
}

/**
 * Obtiene una camiseta específica por ID
 */
function getCamiseta($db, $cache, $userData) {
    $id = $_GET['id'] ?? null;

    if (!$id) {
        respondError('ID de camiseta es obligatorio', 400);
    }

    $cacheKey = "camiseta_{$id}";

    $camiseta = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM tcamisetas WHERE id = ? LIMIT 1";
        return $db->selectOne($sql, [$id]);
    }, 3600);

    if (!$camiseta) {
        respondSuccess(['id' => 0], 'Camiseta no encontrada');
    }

    respondSuccess($camiseta);
}
