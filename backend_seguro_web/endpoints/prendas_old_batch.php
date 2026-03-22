<?php
/**
 * Endpoint: prendas.php
 * Gestión de prendas (garments) del club
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
        case 'getPrendasByClub':
            handleGetPrendasByClub($db, $cache, $userData);
            break;

        case 'createPrenda':
            handleCreatePrenda($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en prendas.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener prendas por club y temporada
 */
function handleGetPrendasByClub($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        ResponseHelper::error('idClub e idTemporada son obligatorios', 400);
    }

    $cacheKey = "prendas_club_{$idClub}_temp_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Prendas obtenidas (cache)');
    }

    $sql = "SELECT * FROM tprendas WHERE idclub = ? AND idtemporada = ? ORDER BY descripcion ASC";
    $prendas = $db->select($sql, [$idClub, $idTemporada]);

    $cache->set($cacheKey, $prendas, 600);
    ResponseHelper::success($prendas, 'Prendas obtenidas');
}

/**
 * POST: Crear nueva prenda
 */
function handleCreatePrenda($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $idclub = $input['idclub'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $descripcion = $input['descripcion'] ?? null;
    $pvp = $input['pvp'] ?? 0;

    if (!$idclub || !$idtemporada || !$descripcion) {
        ResponseHelper::error('idclub, idtemporada y descripcion son obligatorios', 400);
    }

    // Insertar prenda
    $sql = "INSERT INTO tprendas (idclub, idtemporada, descripcion, pvp) VALUES (?, ?, ?, ?)";
    $prendaId = $db->insert($sql, [$idclub, $idtemporada, $descripcion, $pvp]);

    if (!$prendaId) {
        ResponseHelper::error('Error al crear la prenda', 500);
    }

    // Obtener la prenda creada
    $sqlPrenda = "SELECT * FROM tprendas WHERE idprenda = ? LIMIT 1";
    $prendaCreada = $db->selectOne($sqlPrenda, [$prendaId]);

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success([
        'prenda' => $prendaCreada,
        'message' => 'Prenda creada correctamente'
    ], 'Prenda creada');
}
