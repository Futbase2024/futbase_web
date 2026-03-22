<?php
// 🏃 Endpoint: entrenos_jugadores.php - Asistencia a entrenamientos
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
    case 'getEntrenosJugadorByTemporada': getEntrenosJugadorByTemporada($db, $cache); break;
    case 'getAsistenciasEntreno': getAsistenciasEntreno($db, $cache); break;
    default: ResponseHelper::error('Acción no válida', 400);
}

function getEntrenosJugadorByTemporada($db, $cache) {
    $idJugador = $_GET['idjugador'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;
    if (!$idJugador || !$idTemporada) ResponseHelper::error('Parámetros incompletos', 400);

    $cacheKey = "entrenos_jugador_{$idJugador}_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) ResponseHelper::success($cached);

    $sql = 'SELECT * FROM tentrenosjugadores WHERE idjugador = ? AND idtemporada = ? ORDER BY fecha DESC';
    $entrenos = $db->select($sql, [$idJugador, $idTemporada]);

    $cache->set($cacheKey, $entrenos, 300);
    ResponseHelper::success($entrenos);
}

function getAsistenciasEntreno($db, $cache) {
    $idEntreno = $_GET['identreno'] ?? null;
    if (!$idEntreno) ResponseHelper::error('identreno requerido', 400);

    $cacheKey = "asistencias_entreno_{$idEntreno}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) ResponseHelper::success($cached);

    $sql = 'SELECT * FROM tentrenosjugadores WHERE identreno = ? ORDER BY asistencia DESC';
    $asistencias = $db->select($sql, [$idEntreno]);

    $cache->set($cacheKey, $asistencias, 300);
    ResponseHelper::success($asistencias);
}
