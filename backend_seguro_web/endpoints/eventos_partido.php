<?php
/**
 * ⚽ Endpoint: eventos_partido.php
 * Eventos durante partidos
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
        case 'getEventosPartidosOrdenados':
            getEventosPartidosOrdenados($db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in eventos_partido.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

function getEventosPartidosOrdenados($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;

    if (!$idPartido) {
        respondError('idpartido requerido', 400);
    }

    $cacheKey = "eventos_partido_{$idPartido}";

    $eventos = $cache->remember($cacheKey, function() use ($db, $idPartido) {
        $sql = 'SELECT * FROM teventospartido WHERE idpartido = ? ORDER BY minuto ASC, id ASC';
        return $db->select($sql, [$idPartido]);
    }, 300);

    respondSuccess($eventos);
}
