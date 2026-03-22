<?php
/**
 * Endpoint de Temporadas
 * Gestiona las temporadas del club
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
        case 'getall':
            getAll($db, $cache, $auth);
            break;

        case 'getactiva':
            getActiva($db, $cache, $auth);
            break;

        case 'getbyid':
            getById($db, $cache, $auth);
            break;

        case 'getbyclub':
            getByClub($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in temporadas.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene todas las temporadas
 */
function getAll($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $cacheKey = "temporadas_all";

    $temporadas = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT id, idtemporada, temporada
                FROM ttemporadas
                ORDER BY id DESC";
        return $db->select($sql);
    }, 300);

    respondSuccess($temporadas);
}

/**
 * Obtiene la temporada activa de un club
 * Como no hay columna 'activa', devuelve la temporada más reciente del club
 */
function getActiva($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;

    if (!$idclub) {
        // Intentar obtener el idclub del usuario autenticado
        $uid = $userData['uid'] ?? null;
        if ($uid) {
            $userSql = "SELECT idclub FROM tusuarios WHERE uid = ? LIMIT 1";
            $user = $db->selectOne($userSql, [$uid]);
            $idclub = $user['idclub'] ?? null;
        }
    }

    if (!$idclub) {
        respondError('idclub es requerido', 400);
    }

    $cacheKey = "temporada_activa_club_{$idclub}";

    $temporada = $cache->remember($cacheKey, function() use ($db, $idclub) {
        // Devolver la temporada más reciente del club (sin columna activa)
        $sql = "SELECT DISTINCT t.id, t.idtemporada, t.temporada
                FROM ttemporadas t
                INNER JOIN tequipos e ON e.idtemporada = t.idtemporada
                WHERE e.idclub = ?
                ORDER BY t.id DESC
                LIMIT 1";
        return $db->selectOne($sql, [$idclub]);
    }, 300);

    if (!$temporada) {
        // Si no hay temporadas para el club, devolver la más reciente global
        $sql = "SELECT id, idtemporada, temporada FROM ttemporadas ORDER BY id DESC LIMIT 1";
        $temporada = $db->selectOne($sql);
    }

    if (!$temporada) {
        respondNotFound('No hay temporadas');
    }

    respondSuccess($temporada);
}

/**
 * Obtiene una temporada por ID
 */
function getById($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $id = isset($_GET['id']) ? (int)$_GET['id'] : null;

    if (!$id) {
        respondError('id es requerido', 400);
    }

    $cacheKey = "temporada_{$id}";

    $temporada = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT id, idtemporada, temporada
                FROM ttemporadas
                WHERE id = ?
                LIMIT 1";
        return $db->selectOne($sql, [$id]);
    }, 300);

    if (!$temporada) {
        respondNotFound('Temporada no encontrada');
    }

    respondSuccess($temporada);
}

/**
 * Obtiene todas las temporadas de un club
 */
function getByClub($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;

    if (!$idclub) {
        respondError('idclub es requerido', 400);
    }

    $cacheKey = "temporadas_club_{$idclub}";

    $temporadas = $cache->remember($cacheKey, function() use ($db, $idclub) {
        $sql = "SELECT DISTINCT t.id, t.idtemporada, t.temporada
                FROM ttemporadas t
                INNER JOIN tequipos e ON e.idtemporada = t.idtemporada
                WHERE e.idclub = ?
                ORDER BY t.id DESC";
        return $db->select($sql, [$idclub]);
    }, 300);

    respondSuccess($temporadas);
}
