<?php
// 📊 Endpoint: partidos_jugador.php - Gestión de partidos de jugadores
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

$action = $_GET['action'] ?? $_POST['action'] ?? null;

switch ($action) {
    case 'getPartidoJugadorByTemporada': getPartidoJugadorByTemporada($db, $cache); break;
    case 'getJugadoresPorPartido': getJugadoresPorPartido($db, $cache); break;
    case 'getConvocadosPartido': getConvocadosPartido($db, $cache); break;
    case 'updateConvocatoria': updateConvocatoria($db, $cache); break;
    case 'updateConvocatoriaEquipo': updateConvocatoriaEquipo($db, $cache); break;
    default: ResponseHelper::error('Acción no válida', 400);
}

function getPartidoJugadorByTemporada($db, $cache) {
    $idJugador = $_GET['idjugador'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;
    if (!$idJugador || !$idTemporada) ResponseHelper::error('Parámetros incompletos', 400);

    $cacheKey = "partidos_jugador_{$idJugador}_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) ResponseHelper::success($cached);

    $sql = 'SELECT * FROM vpartidosjugadoresFB WHERE idjugador = ? AND idtemporada = ? ORDER BY fecha DESC';
    $partidos = $db->select($sql, [$idJugador, $idTemporada]);

    $cache->set($cacheKey, $partidos, 300);
    ResponseHelper::success($partidos);
}

function getJugadoresPorPartido($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;
    if (!$idPartido) ResponseHelper::error('idpartido requerido', 400);

    $cacheKey = "jugadores_partido_{$idPartido}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) ResponseHelper::success($cached);

    $sql = 'SELECT * FROM vpartidosjugadoresFB WHERE idpartido = ? ORDER BY apodo';
    $jugadores = $db->select($sql, [$idPartido]);

    $cache->set($cacheKey, $jugadores, 300);
    ResponseHelper::success($jugadores);
}

function getConvocadosPartido($db, $cache) {
    $idPartido = $_GET['idpartido'] ?? null;
    if (!$idPartido) ResponseHelper::error('idpartido requerido', 400);

    $cacheKey = "convocados_partido_{$idPartido}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) ResponseHelper::success($cached);

    $sql = 'SELECT * FROM vpartidosjugadoresFB WHERE idpartido = ? AND convocado = 1 ORDER BY apodo';
    $convocados = $db->select($sql, [$idPartido]);

    $cache->set($cacheKey, $convocados, 300);
    ResponseHelper::success($convocados);
}

function updateConvocatoria($db, $cache) {
    $body = json_decode(file_get_contents('php://input'), true);
    $id = $body['id'] ?? null;
    if (!$id) ResponseHelper::error('ID requerido', 400);

    try {
        $sql = "UPDATE tpartidosjugadores SET convocado = ?, jugando = ?, titular = ?, minutos = ?,
                goles = ?, golpp = ?, tam = ?, tro = ? WHERE id = ?";
        $db->execute($sql, [
            $body['convocado'] ?? 0, $body['jugando'] ?? 0, $body['titular'] ?? 0, $body['minutos'] ?? 0,
            $body['goles'] ?? 0, $body['golpp'] ?? 0, $body['tam'] ?? 0, $body['tro'] ?? 0, $id
        ]);
        $cache->clear();
        ResponseHelper::success(['message' => 'Convocatoria actualizada']);
    } catch (Exception $e) {
        ResponseHelper::error('Error: ' . $e->getMessage(), 500);
    }
}

function updateConvocatoriaEquipo($db, $cache) {
    $body = json_decode(file_get_contents('php://input'), true);
    $idPartido = $body['idpartido'] ?? null;
    $idClub = $body['idclub'] ?? null;
    $idEquipo = $body['idequipo'] ?? null;
    $idTemporada = $body['idtemporada'] ?? null;

    if (!$idPartido || !$idClub || !$idEquipo || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos', 400);
    }

    try {
        // Resetear convocados actuales
        $db->execute("UPDATE tpartidosjugadores SET convocado = 0, jugando = 0, titular = 0
                     WHERE idpartido = ?", [$idPartido]);

        // Convocar jugadores activos
        $sql = "UPDATE tpartidosjugadores pj
                JOIN tjugadores j ON pj.idjugador = j.id
                SET pj.convocado = 1
                WHERE pj.idpartido = ? AND j.idclub = ? AND j.idequipo = ? AND j.convocado = 1 AND j.activo = 1";
        $db->execute($sql, [$idPartido, $idClub, $idEquipo]);

        $cache->clear();
        ResponseHelper::success(['message' => 'Convocatoria del equipo actualizada']);
    } catch (Exception $e) {
        ResponseHelper::error('Error: ' . $e->getMessage(), 500);
    }
}
