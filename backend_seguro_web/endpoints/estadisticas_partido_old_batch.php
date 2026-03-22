<?php
/**
 * 📊 Endpoint: estadisticas_partido.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ob_start();

register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        ob_clean();
        header('Content-Type: application/json');
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Error fatal: ' . $error['message']]);
        exit;
    }
});

set_exception_handler(function($e) {
    ob_clean();
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Excepción: ' . $e->getMessage()]);
    exit;
});

set_error_handler(function($errno, $errstr, $errfile, $errline) {
    error_log("PHP Error [$errno]: $errstr");
    return true;
});

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();
$db = Database::getInstance();
$cache = new CacheManager(300);

$action = $_GET['action'] ?? null;

switch ($action) {
    case 'getEstadisticasPartido':
        getEstadisticasPartido($db, $cache);
        break;
    case 'getEstadisticaPartido':
        getEstadisticaPartido($db, $cache);
        break;
    case 'getEstadisticasPartidoByEquipo':
        getEstadisticasPartidoByEquipo($db, $cache);
        break;
    default:
        ResponseHelper::error('Acción no válida', 400);
}

function getEstadisticasPartido($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;
    if (!$idPartido) {
        ResponseHelper::error('idpartido requerido', 400);
    }

    $cacheKey = "stats_partido_{$idPartido}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached);
    }

    $sql = 'SELECT * FROM testadisticaspartido WHERE idpartido = ?';
    $stats = $db->select($sql, [$idPartido]);

    $cache->set($cacheKey, $stats, 300);
    ResponseHelper::success($stats);
}

function getEstadisticaPartido($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;
    if (!$idPartido) {
        ResponseHelper::error('idpartido requerido', 400);
    }

    $cacheKey = "stat_partido_{$idPartido}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached);
    }

    $sql = 'SELECT * FROM testadisticaspartido WHERE idpartido = ? LIMIT 1';
    $stat = $db->selectOne($sql, [$idPartido]);

    if (!$stat) {
        ResponseHelper::success(['id' => 0]);
    }

    $cache->set($cacheKey, $stat, 300);
    ResponseHelper::success($stat);
}

function getEstadisticasPartidoByEquipo($db, $cache) {
    $idEquipo = $_GET['idequipo'] ?? null;
    if (!$idEquipo) {
        ResponseHelper::error('idequipo requerido', 400);
    }

    $cacheKey = "stats_equipo_{$idEquipo}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached);
    }

    $sql = 'SELECT * FROM testadisticaspartido WHERE idequipo = ?';
    $stats = $db->select($sql, [$idEquipo]);

    $cache->set($cacheKey, $stats, 300);
    ResponseHelper::success($stats);
}
