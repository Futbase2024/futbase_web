<?php
/**
 * Endpoint: pagos_personal.php
 * Gestión de pagos al personal del club
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
        case 'getPagosByUser':
            handleGetPagosByUser($db, $cache, $userData);
            break;

        case 'getPagosByClub':
            handleGetPagosByClub($db, $cache, $userData);
            break;

        case 'createPago':
            handleCreatePago($db, $cache, $userData);
            break;

        case 'updatePago':
            handleUpdatePago($db, $cache, $userData);
            break;

        case 'deletePago':
            handleDeletePago($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en pagos_personal.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener pagos por usuario
 */
function handleGetPagosByUser($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idUser = $_GET['idUser'] ?? null;
    $idClub = $_GET['idClub'] ?? null;

    if (!$idUser || !$idClub) {
        ResponseHelper::error('idUser e idClub son obligatorios', 400);
    }

    $cacheKey = "pagos_personal_user_{$idUser}_club_{$idClub}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Pagos obtenidos (cache)');
    }

    $sql = "SELECT * FROM tpagopersonal WHERE iduser = ? AND idclub = ? ORDER BY fecha DESC";
    $pagos = $db->select($sql, [$idUser, $idClub]);

    $cache->set($cacheKey, $pagos, 300);
    ResponseHelper::success($pagos, 'Pagos obtenidos');
}

/**
 * GET: Obtener pagos por club y temporada
 */
function handleGetPagosByClub($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        ResponseHelper::error('idClub e idTemporada son obligatorios', 400);
    }

    $cacheKey = "pagos_personal_club_{$idClub}_temporada_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Pagos obtenidos (cache)');
    }

    $sql = "SELECT * FROM tpagopersonal WHERE idclub = ? AND idtemporada = ? ORDER BY fecha DESC";
    $pagos = $db->select($sql, [$idClub, $idTemporada]);

    $cache->set($cacheKey, $pagos, 300);
    ResponseHelper::success($pagos, 'Pagos obtenidos');
}

/**
 * POST: Crear nuevo pago
 */
function handleCreatePago($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $iduser = $input['iduser'] ?? null;
    $idclub = $input['idclub'] ?? null;
    $idequipo = $input['idequipo'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $concepto = $input['concepto'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $importe = $input['importe'] ?? null;
    $fecha = $input['fecha'] ?? null;

    if (!$iduser || !$idclub || $importe === null) {
        ResponseHelper::error('iduser, idclub e importe son obligatorios', 400);
    }

    $sql = "INSERT INTO tpagopersonal (iduser, idclub, idequipo, idtemporada, concepto, tipo, importe, fecha)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    $pagoId = $db->insert($sql, [
        $iduser,
        $idclub,
        $idequipo,
        $idtemporada,
        $concepto,
        $tipo,
        $importe,
        $fecha
    ]);

    if (!$pagoId) {
        ResponseHelper::error('Error al crear el pago', 500);
    }

    // Obtener el pago creado
    $sqlPago = "SELECT * FROM tpagopersonal WHERE id = ? LIMIT 1";
    $pagoCreado = $db->selectOne($sqlPago, [$pagoId]);

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success([
        'pago' => $pagoCreado,
        'message' => 'Pago creado correctamente'
    ], 'Pago creado');
}

/**
 * POST: Actualizar pago existente
 */
function handleUpdatePago($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID del pago es obligatorio', 400);
    }

    $iduser = $input['iduser'] ?? null;
    $idclub = $input['idclub'] ?? null;
    $idequipo = $input['idequipo'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $concepto = $input['concepto'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $importe = $input['importe'] ?? null;
    $fecha = $input['fecha'] ?? null;

    $sql = "UPDATE tpagopersonal SET
            iduser = ?,
            idclub = ?,
            idequipo = ?,
            idtemporada = ?,
            concepto = ?,
            tipo = ?,
            importe = ?,
            fecha = ?
            WHERE id = ?";

    $rowsAffected = $db->execute($sql, [
        $iduser,
        $idclub,
        $idequipo,
        $idtemporada,
        $concepto,
        $tipo,
        $importe,
        $fecha,
        $id
    ]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Pago no encontrado o sin cambios', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Pago actualizado correctamente');
}

/**
 * POST: Eliminar pago
 */
function handleDeletePago($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID del pago es obligatorio', 400);
    }

    $sql = "DELETE FROM tpagopersonal WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$id]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Pago no encontrado', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Pago eliminado correctamente');
}
