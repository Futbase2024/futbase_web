<?php
// ⚽ Endpoint: eventos_partido.php - Eventos durante partidos
error_reporting(E_ALL); ini_set('display_errors', 0); ini_set('log_errors', 1); ob_start();
register_shutdown_function(function() { $e = error_get_last(); if ($e && in_array($e['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) { ob_clean(); header('Content-Type: application/json'); http_response_code(500); echo json_encode(['success' => false, 'message' => 'Error: ' . $e['message']]); exit; }});
set_exception_handler(function($e) { ob_clean(); header('Content-Type: application/json'); http_response_code(500); echo json_encode(['success' => false, 'message' => $e->getMessage()]); exit; });
set_error_handler(function($n, $s, $f, $l) { error_log("Error [$n]: $s"); return true; });

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();
$db = Database::getInstance();
$cache = new CacheManager(300);

$action = $_GET['action'] ?? null;

switch ($action) {
    case 'getEventosPartidosOrdenados': getEventosPartidosOrdenados($db, $cache); break;
    default: ResponseHelper::error('Acción no válida', 400);
}

function getEventosPartidosOrdenados($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;
    if (!$idPartido) ResponseHelper::error('idpartido requerido', 400);

    $cacheKey = "eventos_partido_{$idPartido}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) ResponseHelper::success($cached);

    $sql = 'SELECT * FROM teventospartido WHERE idpartido = ? ORDER BY minuto ASC, id ASC';
    $eventos = $db->select($sql, [$idPartido]);

    $cache->set($cacheKey, $eventos, 300);
    ResponseHelper::success($eventos);
}
