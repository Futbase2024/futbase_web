<?php
/**
 * Endpoint: documentos.php
 * Gestión de documentos e informes
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
        case 'getDocumentosPorClub':
            handleGetDocumentosPorClub($db, $cache, $userData);
            break;

        case 'getDocumentosPorEquipo':
            handleGetDocumentosPorEquipo($db, $cache, $userData);
            break;

        case 'getDocumentosPorUsuario':
            handleGetDocumentosPorUsuario($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en documentos.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener documentos por club
 */
function handleGetDocumentosPorClub($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        ResponseHelper::error('idClub e idTemporada son obligatorios', 400);
    }

    $cacheKey = "documentos_club_{$idClub}_temp_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Documentos obtenidos (cache)');
    }

    // Obtener fechas de la temporada
    $sqlTemp = "SELECT fechaini, fechafin FROM ttemporadas WHERE id = ? LIMIT 1";
    $temporada = $db->selectOne($sqlTemp, [$idTemporada]);

    if (!$temporada) {
        ResponseHelper::error('Temporada no encontrada', 404);
    }

    $sql = "SELECT d.*, e.nombre as equipo
            FROM tdocumentos d
            LEFT JOIN tequipos e ON d.idequipo = e.id
            WHERE d.idclub = ?
            AND d.fechasubida BETWEEN ? AND ?
            ORDER BY d.fechasubida DESC";

    $documentos = $db->select($sql, [
        $idClub,
        $temporada['fechaini'],
        $temporada['fechafin']
    ]);

    $cache->set($cacheKey, $documentos, 300);
    ResponseHelper::success($documentos, 'Documentos obtenidos');
}

/**
 * GET: Obtener documentos por equipo
 */
function handleGetDocumentosPorEquipo($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idEquipo = $_GET['idEquipo'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idEquipo || !$idTemporada) {
        ResponseHelper::error('idEquipo e idTemporada son obligatorios', 400);
    }

    $cacheKey = "documentos_equipo_{$idEquipo}_temp_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Documentos obtenidos (cache)');
    }

    // Obtener fechas de la temporada
    $sqlTemp = "SELECT fechaini, fechafin FROM ttemporadas WHERE id = ? LIMIT 1";
    $temporada = $db->selectOne($sqlTemp, [$idTemporada]);

    if (!$temporada) {
        ResponseHelper::error('Temporada no encontrada', 404);
    }

    $sql = "SELECT d.*, e.nombre as equipo
            FROM tdocumentos d
            LEFT JOIN tequipos e ON d.idequipo = e.id
            WHERE d.idequipo = ?
            AND d.fechasubida BETWEEN ? AND ?
            ORDER BY d.fechasubida DESC";

    $documentos = $db->select($sql, [
        $idEquipo,
        $temporada['fechaini'],
        $temporada['fechafin']
    ]);

    $cache->set($cacheKey, $documentos, 300);
    ResponseHelper::success($documentos, 'Documentos obtenidos');
}

/**
 * GET: Obtener documentos por usuario
 */
function handleGetDocumentosPorUsuario($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idUsuario = $_GET['idUsuario'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idUsuario || !$idTemporada) {
        ResponseHelper::error('idUsuario e idTemporada son obligatorios', 400);
    }

    $cacheKey = "documentos_usuario_{$idUsuario}_temp_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Documentos obtenidos (cache)');
    }

    // Obtener fechas de la temporada
    $sqlTemp = "SELECT fechaini, fechafin FROM ttemporadas WHERE id = ? LIMIT 1";
    $temporada = $db->selectOne($sqlTemp, [$idTemporada]);

    if (!$temporada) {
        ResponseHelper::error('Temporada no encontrada', 404);
    }

    $sql = "SELECT d.*, e.nombre as equipo
            FROM tdocumentos d
            LEFT JOIN tequipos e ON d.idequipo = e.id
            WHERE d.idusuario = ?
            AND d.fechasubida BETWEEN ? AND ?
            ORDER BY d.fechasubida DESC";

    $documentos = $db->select($sql, [
        $idUsuario,
        $temporada['fechaini'],
        $temporada['fechafin']
    ]);

    $cache->set($cacheKey, $documentos, 300);
    ResponseHelper::success($documentos, 'Documentos obtenidos');
}
