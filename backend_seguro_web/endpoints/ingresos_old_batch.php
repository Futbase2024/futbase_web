<?php
/**
 * Endpoint: ingresos.php
 * Gestión de ingresos del club
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
        case 'getIngresos':
            handleGetIngresos($db, $cache, $userData);
            break;

        case 'getIngreso':
            handleGetIngreso($db, $cache, $userData);
            break;

        case 'grabarIngreso':
            handleGrabarIngreso($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en ingresos.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener todos los ingresos del club
 */
function handleGetIngresos($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        ResponseHelper::error('Usuario sin club asignado', 403);
    }

    $cacheKey = "ingresos_club_{$idClub}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Ingresos obtenidos (cache)');
    }

    $sql = "SELECT * FROM tingresos WHERE idclub = ? ORDER BY concepto ASC";
    $ingresos = $db->select($sql, [$idClub]);

    $cache->set($cacheKey, $ingresos, 300);
    ResponseHelper::success($ingresos, 'Ingresos obtenidos');
}

/**
 * GET: Obtener un ingreso por concepto
 */
function handleGetIngreso($db, $cache, $userData) {
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

    $cacheKey = "ingreso_club_{$idClub}_concepto_" . md5($concepto);
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Ingreso obtenido (cache)');
    }

    $sql = "SELECT * FROM tingresos WHERE idclub = ? AND concepto = ? LIMIT 1";
    $ingreso = $db->selectOne($sql, [$idClub, $concepto]);

    if (!$ingreso) {
        ResponseHelper::success(['id' => 0], 'Ingreso no encontrado');
    }

    $cache->set($cacheKey, $ingreso, 300);
    ResponseHelper::success($ingreso, 'Ingreso obtenido');
}

/**
 * POST: Grabar nuevo ingreso
 */
function handleGrabarIngreso($db, $cache, $userData) {
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
    $sqlCheck = "SELECT id FROM tingresos WHERE idclub = ? AND concepto = ? LIMIT 1";
    $existing = $db->selectOne($sqlCheck, [$idClub, $concepto]);

    if ($existing) {
        ResponseHelper::error('Ya existe un ingreso con ese concepto', 409);
    }

    // Insertar nuevo ingreso
    $sql = "INSERT INTO tingresos (idclub, concepto) VALUES (?, ?)";
    $ingresoId = $db->insert($sql, [$idClub, $concepto]);

    if (!$ingresoId) {
        ResponseHelper::error('Error al crear el ingreso', 500);
    }

    // Obtener el ingreso creado
    $sqlIngreso = "SELECT * FROM tingresos WHERE id = ? LIMIT 1";
    $ingresoCreado = $db->selectOne($sqlIngreso, [$ingresoId]);

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success([
        'ingreso' => $ingresoCreado,
        'message' => 'Ingreso creado correctamente'
    ], 'Ingreso creado');
}
