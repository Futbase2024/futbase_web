<?php
/**
 * 🏃 Endpoint: entrenos_jugadores.php
 * Asistencia a entrenamientos
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

// Normalizar action a lowercase
$action = strtolower($_GET['action'] ?? '');

error_log("🔍 entrenos_jugadores.php - Action recibida: '$action'");

// Definir acciones públicas (sin autenticación requerida)
$publicActions = ['test'];

// Proteger solo si la acción no es pública
if (!in_array($action, $publicActions)) {
    $userData = $auth->protect(100, 60);
} else {
    $userData = null;
    error_log("✅ Acción pública, sin autenticación requerida");
}

try {
    switch ($action) {
        case 'getentrenosjugadorbytemporada':
            error_log("✅ Ejecutando getEntrenosJugadorByTemporada");
            getEntrenosJugadorByTemporada($db, $cache);
            break;
        case 'getasistenciasentreno':
            error_log("✅ Ejecutando getAsistenciasEntreno");
            getAsistenciasEntreno($db, $cache);
            break;
        case 'test':
            error_log("✅ Test endpoint");
            ResponseHelper::success([], 'Test OK');
            break;
        default:
            error_log("❌ Acción no válida: '$action'");
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("❌ Error in entrenos_jugadores.php: " . $e->getMessage());
    error_log("❌ Stack trace: " . $e->getTraceAsString());
    respondInternalError('Error al procesar la solicitud');
}

function getEntrenosJugadorByTemporada($db, $cache) {
    $idJugador = $_GET['idjugador'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idJugador || !$idTemporada) {
        respondError('Parámetros incompletos: idjugador y idtemporada son requeridos', 400);
    }

    $cacheKey = "entrenos_jugador_{$idJugador}_{$idTemporada}";

    $entrenos = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        // ✅ Usar vista ventrenojugador para obtener datos completos
        $sql = 'SELECT * FROM ventrenojugador WHERE idjugador = ? AND idtemporada = ? ORDER BY fecha DESC';
        return $db->select($sql, [$idJugador, $idTemporada]);
    }, 300);

    respondSuccess($entrenos);
}

function getAsistenciasEntreno($db, $cache) {
    try {
        error_log("🔍 getAsistenciasEntreno llamada");

        $idEntreno = $_GET['identreno'] ?? null;
        error_log("🔍 idEntreno recibido: " . ($idEntreno ?? 'NULL'));

        if (!$idEntreno) {
            error_log("❌ idEntreno es NULL o vacío");
            respondError('identreno requerido', 400);
            return;
        }

        error_log("🔍 Ejecutando query SQL directamente (sin caché)...");

        // ✅ Sin caché para debugging - igual que en entrenamientos.php línea 522
        $sql = 'SELECT * FROM ventrenojugador WHERE identrenamiento = ? ORDER BY nombre';
        error_log("🔍 SQL: $sql con parámetro: $idEntreno");

        $asistencias = $db->select($sql, [$idEntreno]);
        error_log("✅ Query ejecutada, resultados: " . count($asistencias));

        respondSuccess($asistencias, '✅ ' . count($asistencias) . ' asistencias obtenidas');
    } catch (Exception $e) {
        error_log("❌ Error en getAsistenciasEntreno: " . $e->getMessage());
        error_log("❌ Stack trace: " . $e->getTraceAsString());
        throw $e;
    }
}
