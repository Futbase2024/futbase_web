<?php
/**
 * Endpoint: gastos.php
 * Gestión de gastos del club
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
        case 'getGastos':
            handleGetGastos($db, $cache, $userData);
            break;

        case 'getGasto':
            handleGetGasto($db, $cache, $userData);
            break;

        case 'grabarGasto':
            handleGrabarGasto($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en gastos.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener todos los gastos del club
 */
function handleGetGastos($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        ResponseHelper::error('Usuario sin club asignado', 403);
    }

    $cacheKey = "gastos_club_{$idClub}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Gastos obtenidos (cache)');
    }

    $sql = "SELECT * FROM tgastos WHERE idclub = ? ORDER BY concepto ASC";
    $gastos = $db->select($sql, [$idClub]);

    $cache->set($cacheKey, $gastos, 300);
    ResponseHelper::success($gastos, 'Gastos obtenidos');
}

/**
 * GET: Obtener un gasto por concepto
 */
function handleGetGasto($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $concepto = $_GET['concepto'] ?? null;
    if (!$concepto) {
        ResponseHelper::error('Concepto no especificado', 400);
    }

    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        ResponseHelper::error('Usuario sin club asignado', 403);
    }

    $cacheKey = "gasto_club_{$idClub}_concepto_" . md5($concepto);
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Gasto obtenido (cache)');
    }

    $sql = "SELECT * FROM tgastos WHERE idclub = ? AND concepto = ? LIMIT 1";
    $gasto = $db->selectOne($sql, [$idClub, $concepto]);

    if (!$gasto) {
        ResponseHelper::success(['id' => 0], 'Gasto no encontrado');
    }

    $cache->set($cacheKey, $gasto, 300);
    ResponseHelper::success($gasto, 'Gasto obtenido');
}

/**
 * POST: Grabar nuevo gasto
 */
function handleGrabarGasto($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        ResponseHelper::error('Usuario sin club asignado', 403);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $concepto = $input['concepto'] ?? null;

    if (!$concepto) {
        ResponseHelper::error('Concepto es obligatorio', 400);
    }

    // Verificar si ya existe
    $sqlCheck = "SELECT id FROM tgastos WHERE idclub = ? AND concepto = ? LIMIT 1";
    $existing = $db->selectOne($sqlCheck, [$idClub, $concepto]);

    if ($existing) {
        ResponseHelper::error('Ya existe un gasto con ese concepto', 409);
    }

    // Insertar nuevo gasto
    $sql = "INSERT INTO tgastos (idclub, concepto) VALUES (?, ?)";
    $gastoId = $db->insert($sql, [$idClub, $concepto]);

    if (!$gastoId) {
        ResponseHelper::error('Error al crear el gasto', 500);
    }

    // Obtener el gasto creado
    $sqlGasto = "SELECT * FROM tgastos WHERE id = ? LIMIT 1";
    $gastoCreado = $db->selectOne($sqlGasto, [$gastoId]);

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success([
        'gasto' => $gastoCreado,
        'message' => 'Gasto creado correctamente'
    ], 'Gasto creado');
}
