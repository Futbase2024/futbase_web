<?php
/**
 * Endpoint: camisetas.php
 * Gestión de camisetas de equipos
 */

// Configuración de errores
error_reporting(E_ALL);
ini_set('display_errors', 0);
ob_start();

// Manejador de errores fatales
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
        header('Content-Type: application/json');
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error fatal del servidor: ' . $error['message'],
            'file' => basename($error['file']),
            'line' => $error['line']
        ]);
        exit;
    }
});

// Manejador de excepciones
set_exception_handler(function($exception) {
    if (ob_get_level() > 0) {
        ob_clean();
    }
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Excepción: ' . $exception->getMessage(),
        'file' => basename($exception->getFile()),
        'line' => $exception->getLine()
    ]);
    exit;
});

// Manejador de errores no fatales
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $auth = new FirebaseAuthMiddleware();
    $db = Database::getInstance();
    $cache = new CacheManager();

    // Verificar autenticación
    $userData = $auth->authenticate();

    // Determinar action
    $action = $_GET['action'] ?? $_POST['action'] ?? null;

    if (!$action) {
        ResponseHelper::error('Acción no especificada', 400);
    }

    switch ($action) {
        case 'cargarCamisetas':
            handleCargarCamisetas($db, $cache, $userData);
            break;

        case 'getCamiseta':
            handleGetCamiseta($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en camisetas.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Cargar todas las camisetas
 */
function handleCargarCamisetas($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $cacheKey = "camisetas_all";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Camisetas obtenidas (cache)');
    }

    $sql = "SELECT * FROM tcamisetas ORDER BY id ASC";
    $camisetas = $db->select($sql);

    $cache->set($cacheKey, $camisetas, 3600); // Cache largo (1 hora)
    ResponseHelper::success($camisetas, 'Camisetas obtenidas');
}

/**
 * GET: Obtener una camiseta específica
 */
function handleGetCamiseta($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $id = $_GET['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID de camiseta es obligatorio', 400);
    }

    $cacheKey = "camiseta_{$id}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Camiseta obtenida (cache)');
    }

    $sql = "SELECT * FROM tcamisetas WHERE id = ? LIMIT 1";
    $camiseta = $db->selectOne($sql, [$id]);

    if (!$camiseta) {
        ResponseHelper::success(['id' => 0], 'Camiseta no encontrada');
    }

    $cache->set($cacheKey, $camiseta, 3600);
    ResponseHelper::success($camiseta, 'Camiseta obtenida');
}
