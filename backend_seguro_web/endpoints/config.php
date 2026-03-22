<?php
/**
 * Endpoint de Configuración
 * Gestiona configuraciones globales de la aplicación
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
        case 'gettemporada':
            getTemporadaActiva($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in config.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene la temporada activa global
 * Como no hay columna 'activa', devuelve la temporada más reciente
 */
function getTemporadaActiva($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $idclub = isset($_GET['idclub']) ? (int)$_GET['idclub'] : null;

    // Si hay idclub, obtener la temporada más reciente de ese club
    if ($idclub) {
        $cacheKey = "config_temporada_club_{$idclub}";

        $temporada = $cache->remember($cacheKey, function() use ($db, $idclub) {
            $sql = "SELECT DISTINCT t.id, t.idtemporada, t.temporada
                    FROM ttemporadas t
                    INNER JOIN tequipos e ON e.idtemporada = t.idtemporada
                    WHERE e.idclub = ?
                    ORDER BY t.id DESC
                    LIMIT 1";
            return $db->selectOne($sql, [$idclub]);
        }, 300);

        if ($temporada) {
            respondSuccess(['idtemporada' => $temporada['idtemporada'], 'temporada' => $temporada]);
        }
    }

    // Fallback: obtener la temporada más reciente global
    $cacheKey = "config_temporada_global";

    $temporada = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT id, idtemporada, temporada
                FROM ttemporadas
                ORDER BY id DESC
                LIMIT 1";
        return $db->selectOne($sql);
    }, 300);

    if (!$temporada) {
        respondSuccess(['idtemporada' => null]);
    }

    respondSuccess(['idtemporada' => $temporada['idtemporada'], 'temporada' => $temporada]);
}
