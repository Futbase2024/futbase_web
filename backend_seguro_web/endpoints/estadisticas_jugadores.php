<?php
/**
 * 📊 Endpoint: estadisticas_jugadores.php
 * Estadísticas de jugadores
 * Fecha: 2025-10-26
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
        case 'getStatsByJugadorTemporada':
            getStatsByJugadorTemporada($db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in estadisticas_jugadores.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtener estadísticas de un jugador en una temporada
 */
function getStatsByJugadorTemporada($db, $cache) {
    $idJugador = $_GET['idjugador'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idJugador || !$idTemporada) {
        respondError('Parámetros incompletos: idjugador y idtemporada son requeridos', 400);
    }

    $cacheKey = "stats_jugador_{$idJugador}_{$idTemporada}";

    $stats = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        $sql = 'SELECT * FROM testadisticasjugador
                WHERE idjugador = ? AND idtemporada = ? AND visible = 1
                LIMIT 1';
        return $db->selectOne($sql, [$idJugador, $idTemporada]);
    }, 300);

    if (!$stats) {
        // Retornar estadísticas vacías
        respondSuccess(['id' => 0]);
        return;
    }

    respondSuccess($stats);
}
