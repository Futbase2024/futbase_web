<?php
/**
 * 📊 Endpoint: estadisticas_jugadores.php
 * Estadísticas de jugadores
 * Fecha: 2025-10-26
 */

// ⚠️ Manejo robusto de errores
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
        echo json_encode([
            'success' => false,
            'message' => 'Error fatal del servidor: ' . $error['message'],
            'file' => basename($error['file']),
            'line' => $error['line']
        ]);
        exit;
    }
});

set_exception_handler(function($exception) {
    ob_clean();
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Excepción no capturada: ' . $exception->getMessage(),
        'file' => basename($exception->getFile()),
        'line' => $exception->getLine()
    ]);
    exit;
});

set_error_handler(function($errno, $errstr, $errfile, $errline) {
    error_log("PHP Error [$errno]: $errstr in " . basename($errfile) . " on line $errline");
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

// Autenticación Firebase
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Conexión a base de datos
$db = Database::getInstance();
$cache = new CacheManager(300);

// Router de acciones
$action = $_GET['action'] ?? $_POST['action'] ?? null;

switch ($action) {
    case 'getStatsByJugadorTemporada':
        getStatsByJugadorTemporada($db, $cache, $userData);
        break;

    default:
        ResponseHelper::error('Acción no válida', 400);
}

/**
 * Obtener estadísticas de un jugador en una temporada
 */
function getStatsByJugadorTemporada($db, $cache, $userData) {
    $idJugador = $_GET['idjugador'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idJugador || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos', 400);
    }

    $cacheKey = "stats_jugador_{$idJugador}_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        ResponseHelper::success($cached);
    }

    $sql = 'SELECT * FROM testadisticasjugador
            WHERE idjugador = ? AND idtemporada = ? AND visible = 1
            LIMIT 1';

    $stats = $db->selectOne($sql, [$idJugador, $idTemporada]);

    if (!$stats) {
        // Retornar estadísticas vacías
        ResponseHelper::success(['id' => 0]);
    }

    $cache->set($cacheKey, $stats, 300);
    ResponseHelper::success($stats);
}
