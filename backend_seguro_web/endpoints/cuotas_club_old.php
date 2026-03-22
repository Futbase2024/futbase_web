<?php
/**
 * Endpoint: cuotas_club.php
 * Configuración de tipos de cuotas del club
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

    // Log para depuración
    error_log("🔍 [cuotas_club.php] Action recibida: " . ($action ?? 'NULL'));
    error_log("🔍 [cuotas_club.php] GET params: " . json_encode($_GET));
    error_log("🔍 [cuotas_club.php] POST params: " . json_encode($_POST));

    if (!$action) {
        ResponseHelper::error('Acción no especificada', 400);
    }

    switch ($action) {
        case 'getCuota':
            handleGetCuota($db, $cache, $userData);
            break;

        case 'getCuotas':
            handleGetCuotas($db, $cache, $userData);
            break;

        case 'getCuotasByClub':
            handleGetCuotasByClub($db, $cache, $userData);
            break;

        case 'createCuota':
            handleCreateCuota($db, $cache, $userData);
            break;

        case 'updateCuota':
            handleUpdateCuota($db, $cache, $userData);
            break;

        case 'deleteCuota':
            handleDeleteCuota($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en cuotas_club.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener una cuota específica por tipo
 */
function handleGetCuota($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $tipo = $_GET['tipo'] ?? null;
    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$tipo || !$idClub || !$idTemporada) {
        ResponseHelper::error('tipo, idClub e idTemporada son obligatorios', 400);
    }

    $cacheKey = "cuota_club_tipo_{$tipo}_club_{$idClub}_temp_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Cuota obtenida (cache)');
    }

    $sql = "SELECT * FROM tconfigcuotas WHERE tipo = ? AND idclub = ? AND idtemporada = ? LIMIT 1";
    $cuota = $db->selectOne($sql, [$tipo, $idClub, $idTemporada]);

    if (!$cuota) {
        ResponseHelper::success(['id' => 0], 'Cuota no encontrada');
    }

    $cache->set($cacheKey, $cuota, 600);
    ResponseHelper::success($cuota, 'Cuota obtenida');
}

/**
 * GET: Obtener todas las cuotas de una temporada
 */
function handleGetCuotas($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idTemporada = $_GET['idTemporada'] ?? null;
    if (!$idTemporada) {
        ResponseHelper::error('idTemporada es obligatorio', 400);
    }

    $cacheKey = "cuotas_club_temporada_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Cuotas obtenidas (cache)');
    }

    $sql = "SELECT * FROM tconfigcuotas WHERE idtemporada = ? ORDER BY tipo ASC";
    $cuotas = $db->select($sql, [$idTemporada]);

    $cache->set($cacheKey, $cuotas, 600);
    ResponseHelper::success($cuotas, 'Cuotas obtenidas');
}

/**
 * GET: Obtener cuotas de un club específico
 */
function handleGetCuotasByClub($db, $cache, $userData) {
    try {
        error_log("🔍 [cuotas_club] Iniciando handleGetCuotasByClub");

        $rateLimiter = new RateLimiter(100, 60);
        if (!$rateLimiter->isAllowed($userData['uid'])) {
            error_log("❌ [cuotas_club] Rate limit excedido para UID: " . $userData['uid']);
            ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
        }

        $idClub = $_GET['idClub'] ?? null;
        $idTemporada = $_GET['idTemporada'] ?? null;

        error_log("🔍 [cuotas_club] idClub: $idClub, idTemporada: $idTemporada");

        if (!$idClub || !$idTemporada) {
            error_log("❌ [cuotas_club] Faltan parámetros requeridos");
            ResponseHelper::error('idClub e idTemporada son obligatorios', 400);
        }

        $cacheKey = "cuotas_club_club_{$idClub}_temp_{$idTemporada}";
        $cached = $cache->get($cacheKey);
        if ($cached !== null) {
            error_log("✅ [cuotas_club] Datos en caché encontrados");
            ResponseHelper::success($cached, 'Cuotas obtenidas (cache)');
        }

        error_log("🔍 [cuotas_club] Ejecutando query SQL...");
        $sql = "SELECT * FROM tconfigcuotas WHERE idclub = ? AND idtemporada = ? ORDER BY tipo ASC";
        $cuotas = $db->select($sql, [$idClub, $idTemporada]);

        error_log("✅ [cuotas_club] Query ejecutada. Resultados: " . count($cuotas));

        $cache->set($cacheKey, $cuotas, 600);
        ResponseHelper::success($cuotas, 'Cuotas obtenidas');
    } catch (Exception $e) {
        error_log("❌ [cuotas_club] Exception en handleGetCuotasByClub: " . $e->getMessage());
        error_log("❌ [cuotas_club] Stack trace: " . $e->getTraceAsString());
        ResponseHelper::error('Error al obtener cuotas: ' . $e->getMessage(), 500);
    }
}

/**
 * POST: Crear nueva cuota
 */
function handleCreateCuota($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $idclub = $input['idclub'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $cantidad = $input['cantidad'] ?? 0;
    $idtemporada = $input['idtemporada'] ?? null;

    if (!$idclub || !$tipo || !$idtemporada) {
        ResponseHelper::error('idclub, tipo e idtemporada son obligatorios', 400);
    }

    // Verificar si ya existe
    $sqlCheck = "SELECT id FROM tconfigcuotas WHERE idclub = ? AND tipo = ? AND idtemporada = ? LIMIT 1";
    $existing = $db->selectOne($sqlCheck, [$idclub, $tipo, $idtemporada]);

    if ($existing) {
        ResponseHelper::error('Ya existe una cuota de este tipo para este club y temporada', 409);
    }

    $sql = "INSERT INTO tconfigcuotas (idclub, tipo, cantidad, idtemporada) VALUES (?, ?, ?, ?)";
    $cuotaId = $db->insert($sql, [$idclub, $tipo, $cantidad, $idtemporada]);

    if (!$cuotaId) {
        ResponseHelper::error('Error al crear la cuota', 500);
    }

    // Obtener la cuota creada
    $sqlCuota = "SELECT * FROM tconfigcuotas WHERE id = ? LIMIT 1";
    $cuotaCreada = $db->selectOne($sqlCuota, [$cuotaId]);

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success([
        'cuota' => $cuotaCreada,
        'message' => 'Cuota creada correctamente'
    ], 'Cuota creada');
}

/**
 * POST: Actualizar cuota existente
 */
function handleUpdateCuota($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID de la cuota es obligatorio', 400);
    }

    $tipo = $input['tipo'] ?? null;
    $cantidad = $input['cantidad'] ?? null;

    $sql = "UPDATE tconfigcuotas SET tipo = ?, cantidad = ? WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$tipo, $cantidad, $id]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Cuota no encontrada o sin cambios', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Cuota actualizada correctamente');
}

/**
 * POST: Eliminar cuota
 */
function handleDeleteCuota($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID de la cuota es obligatorio', 400);
    }

    $sql = "DELETE FROM tconfigcuotas WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$id]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Cuota no encontrada', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Cuota eliminada correctamente');
}
