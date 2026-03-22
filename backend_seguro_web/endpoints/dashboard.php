<?php
/**
 * Endpoint de Dashboard
 * Proporciona estadísticas y resúmenes para el dashboard
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
$cache = new CacheManager(300);
$auth = new FirebaseAuthMiddleware();

// Obtener acción
$action = $_GET['action'] ?? '';

// Enrutamiento de acciones
try {
    switch ($action) {
        case 'asistencia':
            getAsistencia($db, $cache, $auth);
            break;

        case 'proximos':
            getProximosPartidos($db, $cache, $auth);
            break;

        case 'resultados':
            getResultadosRecientes($db, $cache, $auth);
            break;

        case 'conteo_jugadores':
            getConteoJugadores($db, $cache, $auth);
            break;

        case 'conteo_equipos':
            getConteoEquipos($db, $cache, $auth);
            break;

        case 'conteo_partidos':
            getConteoPartidos($db, $cache, $auth);
            break;

        case 'conteo_entrenamientos':
            getConteoEntrenamientos($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in dashboard.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene estadísticas de asistencia
 */
function getAsistencia($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_asistencia_{$idclub}_{$idtemporada}";

    $data = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada) {
        // Estadísticas de asistencia por equipo
        $sql = "SELECT
                    e.id as idequipo,
                    e.equipo,
                    COUNT(DISTINCT ej.identrenamiento) as total_entrenamientos,
                    COUNT(ej.id) as total_asistencias,
                    ROUND(COUNT(ej.id) * 100.0 / NULLIF(COUNT(DISTINCT ej.identrenamiento) * (SELECT COUNT(*) FROM tjugador j WHERE j.idequipo = e.id), 0), 1) as porcentaje
                FROM tequipos e
                LEFT JOIN tentrenamientos t ON t.idequipo = e.id
                LEFT JOIN tentrenos_jugadores ej ON ej.identrenamiento = t.id AND ej.asistio = 1
                WHERE e.idclub = ? AND e.idtemporada = ?
                GROUP BY e.id, e.equipo
                ORDER BY e.equipo";
        return $db->select($sql, [$idclub, $idtemporada]);
    }, 300);

    respondSuccess($data);
}

/**
 * Obtiene próximos partidos
 */
function getProximosPartidos($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;
    $idequipo = isset($_GET['idequipo']) ? (int)$_GET['idequipo'] : null;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 5;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_proximos_{$idclub}_{$idtemporada}_{$idequipo}_{$limit}";

    $data = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada, $idequipo, $limit) {
        $sql = "SELECT p.*, e.equipo, e.ncorto, c.categoria, r.nombre as rival_nombre
                FROM tpartidos p
                INNER JOIN tequipos e ON e.id = p.idequipo
                INNER JOIN tcategorias c ON c.id = e.idcategoria
                LEFT JOIN trivales r ON r.id = p.idrival
                WHERE e.idclub = ?
                    AND p.idtemporada = ?
                    AND p.finalizado = 0
                    AND p.fecha >= CURDATE()"
                . ($idequipo ? " AND p.idequipo = ?" : "") . "
                ORDER BY p.fecha ASC, p.hora ASC
                LIMIT ?";

        $params = [$idclub, $idtemporada];
        if ($idequipo) {
            $params[] = $idequipo;
        }
        $params[] = $limit;

        return $db->select($sql, $params);
    }, 300);

    respondSuccess($data);
}

/**
 * Obtiene resultados recientes
 */
function getResultadosRecientes($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;
    $idequipo = isset($_GET['idequipo']) ? (int)$_GET['idequipo'] : null;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 5;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_resultados_{$idclub}_{$idtemporada}_{$idequipo}_{$limit}";

    $data = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada, $idequipo, $limit) {
        $sql = "SELECT p.*, e.equipo, e.ncorto, c.categoria, r.nombre as rival_nombre
                FROM tpartidos p
                INNER JOIN tequipos e ON e.id = p.idequipo
                INNER JOIN tcategorias c ON c.id = e.idcategoria
                LEFT JOIN trivales r ON r.id = p.idrival
                WHERE e.idclub = ?
                    AND p.idtemporada = ?
                    AND p.finalizado = 1"
                . ($idequipo ? " AND p.idequipo = ?" : "") . "
                ORDER BY p.fecha DESC, p.hora DESC
                LIMIT ?";

        $params = [$idclub, $idtemporada];
        if ($idequipo) {
            $params[] = $idequipo;
        }
        $params[] = $limit;

        return $db->select($sql, $params);
    }, 300);

    respondSuccess($data);
}

/**
 * Obtiene conteo de jugadores
 */
function getConteoJugadores($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;
    $idequipo = isset($_GET['idequipo']) ? (int)$_GET['idequipo'] : null;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_conteo_jugadores_{$idclub}_{$idtemporada}_{$idequipo}";

    $count = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada, $idequipo) {
        $sql = "SELECT COUNT(DISTINCT j.id) as count
                FROM tjugador j
                INNER JOIN tequipos e ON e.id = j.idequipo
                WHERE e.idclub = ? AND e.idtemporada = ?"
                . ($idequipo ? " AND j.idequipo = ?" : "");

        $params = [$idclub, $idtemporada];
        if ($idequipo) {
            $params[] = $idequipo;
        }

        $result = $db->selectOne($sql, $params);
        return (int)($result['count'] ?? 0);
    }, 300);

    respondSuccess($count);
}

/**
 * Obtiene conteo de equipos
 */
function getConteoEquipos($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_conteo_equipos_{$idclub}_{$idtemporada}";

    $count = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada) {
        $sql = "SELECT COUNT(*) as count FROM tequipos WHERE idclub = ? AND idtemporada = ?";
        $result = $db->selectOne($sql, [$idclub, $idtemporada]);
        return (int)($result['count'] ?? 0);
    }, 300);

    respondSuccess($count);
}

/**
 * Obtiene conteo de partidos
 */
function getConteoPartidos($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;
    $idequipo = isset($_GET['idequipo']) ? (int)$_GET['idequipo'] : null;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_conteo_partidos_{$idclub}_{$idtemporada}_{$idequipo}";

    $count = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada, $idequipo) {
        $sql = "SELECT COUNT(*) as count
                FROM tpartidos p
                INNER JOIN tequipos e ON e.id = p.idequipo
                WHERE e.idclub = ? AND p.idtemporada = ?"
                . ($idequipo ? " AND p.idequipo = ?" : "");

        $params = [$idclub, $idtemporada];
        if ($idequipo) {
            $params[] = $idequipo;
        }

        $result = $db->selectOne($sql, $params);
        return (int)($result['count'] ?? 0);
    }, 300);

    respondSuccess($count);
}

/**
 * Obtiene conteo de entrenamientos
 */
function getConteoEntrenamientos($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;
    $idtemporada = isset($_GET['idtemporada']) ? (int)$_GET['idtemporada'] : null;
    $idequipo = isset($_GET['idequipo']) ? (int)$_GET['idequipo'] : null;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "dashboard_conteo_entrenamientos_{$idclub}_{$idtemporada}_{$idequipo}";

    $count = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada, $idequipo) {
        $sql = "SELECT COUNT(*) as count
                FROM tentrenamientos t
                INNER JOIN tequipos e ON e.id = t.idequipo
                WHERE e.idclub = ? AND e.idtemporada = ?"
                . ($idequipo ? " AND t.idequipo = ?" : "");

        $params = [$idclub, $idtemporada];
        if ($idequipo) {
            $params[] = $idequipo;
        }

        $result = $db->selectOne($sql, $params);
        return (int)($result['count'] ?? 0);
    }, 300);

    respondSuccess($count);
}
