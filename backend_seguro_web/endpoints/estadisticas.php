<?php
/**
 * Endpoint de Estadísticas
 * Proporciona estadísticas de partidos y jugadores
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
        case 'by_partidos':
            getByPartidos($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in estadisticas.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene estadísticas por lista de partidos
 */
function getByPartidos($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $ids = $_GET['ids'] ?? '';

    if (empty($ids)) {
        respondSuccess([]);
    }

    // Validar que sean IDs válidos
    $idArray = explode(',', $ids);
    $idArray = array_filter($idArray, function($id) {
        return is_numeric(trim($id));
    });

    if (empty($idArray)) {
        respondSuccess([]);
    }

    $idList = implode(',', array_map('intval', $idArray));
    $cacheKey = "estadisticas_partidos_" . md5($idList);

    $data = $cache->remember($cacheKey, function() use ($db, $idList) {
        // Estadísticas de jugadores en los partidos
        $sql = "SELECT
                    ep.*,
                    j.nombre, j.apellidos, j.dorsal,
                    e.equipo, e.ncorto
                FROM testadisticas_partido ep
                INNER JOIN tjugador j ON j.id = ep.idjugador
                INNER JOIN tequipos e ON e.id = j.idequipo
                WHERE ep.idpartido IN ({$idList})
                ORDER BY ep.idpartido, j.apellidos, j.nombre";

        return $db->select($sql);
    }, 300);

    respondSuccess($data);
}
