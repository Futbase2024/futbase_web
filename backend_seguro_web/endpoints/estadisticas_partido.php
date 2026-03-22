<?php
/**
 * 📊 Endpoint: estadisticas_partido.php
 * Estadísticas de partidos
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$db = Database::getInstance();
$cache = new CacheManager(300);
$auth = new FirebaseAuthMiddleware();
$userData = $auth->protect(100, 60);

$action = $_GET['action'] ?? '';

try {
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
        case 'getEstadisticasPartidoByIds':
            getEstadisticasPartidoByIds($db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in estadisticas_partido.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

function getEstadisticasPartido($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;

    if (!$idPartido) {
        respondError('idpartido requerido', 400);
    }

    $cacheKey = "stats_partido_{$idPartido}";

    $stats = $cache->remember($cacheKey, function() use ($db, $idPartido) {
        $sql = 'SELECT * FROM testadisticaspartido WHERE idpartido = ?';
        return $db->select($sql, [$idPartido]);
    }, 300);

    respondSuccess($stats);
}

function getEstadisticaPartido($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;

    if (!$idPartido) {
        respondError('idpartido requerido', 400);
    }

    $cacheKey = "stat_partido_{$idPartido}";

    $stat = $cache->remember($cacheKey, function() use ($db, $idPartido) {
        $sql = 'SELECT * FROM testadisticaspartido WHERE idpartido = ? LIMIT 1';
        return $db->selectOne($sql, [$idPartido]);
    }, 300);

    if (!$stat) {
        respondSuccess(['id' => 0]);
        return;
    }

    respondSuccess($stat);
}

function getEstadisticasPartidoByEquipo($db, $cache) {
    $idEquipo = $_GET['idequipo'] ?? null;

    if (!$idEquipo) {
        respondError('idequipo requerido', 400);
    }

    $cacheKey = "stats_equipo_{$idEquipo}";

    $stats = $cache->remember($cacheKey, function() use ($db, $idEquipo) {
        $sql = 'SELECT * FROM testadisticaspartido WHERE idequipo = ?';
        return $db->select($sql, [$idEquipo]);
    }, 300);

    respondSuccess($stats);
}

/**
 * Obtiene estadísticas de múltiples partidos por IDs
 */
function getEstadisticasPartidoByIds($db, $cache) {
    $ids = $_GET['ids'] ?? '';

    if (empty($ids)) {
        respondSuccess([]);
    }

    // Validar que sean IDs válidos
    $idArray = explode(',', $ids);
    $idArray = array_filter($idArray, function($id) {
        return is_numeric(trim($id));
    });

    if (empty($idArray)) {
        respondSuccess([]);
    }

    $idList = implode(',', array_map('intval', $idArray));
    $cacheKey = "estadisticas_partidos_" . md5($idList);

    $stats = $cache->remember($cacheKey, function() use ($db, $idList) {
        $sql = "SELECT * FROM testadisticaspartido WHERE idpartido IN ({$idList})";
        return $db->select($sql);
    }, 300);

    respondSuccess($stats);
}
