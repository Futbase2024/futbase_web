<?php
/**
 * Endpoint de Estadísticas Globales
 * Proporciona estadísticas globales del sistema (superadmin)
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
        case 'count':
            getCount($db, $cache, $auth);
            break;

        case 'equipos_por_categoria':
            getEquiposPorCategoria($db, $cache, $auth);
            break;

        case 'usuarios_por_permiso':
            getUsuariosPorPermiso($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in stats.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene conteo de registros de una tabla
 */
function getCount($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $table = $_GET['table'] ?? '';

    $validTables = [
        'clubs' => 'tclub',
        'usuarios' => 'tusuarios',
        'equipos' => 'tequipos',
        'jugadores' => 'tjugador',
        'entrenamientos' => 'tentrenamientos',
        'partidos' => 'tpartidos',
        'cuotas' => 'tcuotas'
    ];

    if (!isset($validTables[$table])) {
        respondError('Tabla no válida', 400);
    }

    $tableName = $validTables[$table];
    $cacheKey = "stats_count_{$table}";

    $count = $cache->remember($cacheKey, function() use ($db, $tableName) {
        $sql = "SELECT COUNT(*) as count FROM {$tableName}";
        $result = $db->selectOne($sql);
        return (int)($result['count'] ?? 0);
    }, 300);

    respondSuccess(['count' => $count]);
}

/**
 * Obtiene distribución de equipos por categoría
 */
function getEquiposPorCategoria($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $cacheKey = "stats_equipos_por_categoria";

    $data = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT c.categoria, COUNT(e.id) as count
                FROM tcategorias c
                LEFT JOIN tequipos e ON e.idcategoria = c.id
                GROUP BY c.id, c.categoria
                ORDER BY c.orden ASC, c.categoria ASC";
        return $db->select($sql);
    }, 300);

    respondSuccess($data);
}

/**
 * Obtiene distribución de usuarios por permiso
 */
function getUsuariosPorPermiso($db, $cache, $auth) {
    $userData = $auth->protect(100, 60);

    $cacheKey = "stats_usuarios_por_permiso";

    $data = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT
                    CASE tipo
                        WHEN 1 THEN 'Superadmin'
                        WHEN 2 THEN 'Club'
                        WHEN 3 THEN 'Coordinador'
                        WHEN 4 THEN 'Entrenador'
                        WHEN 5 THEN 'Jugador'
                        WHEN 6 THEN 'Padre/Tutor'
                        ELSE 'Otro'
                    END as permiso,
                    tipo,
                    COUNT(*) as count
                FROM troles
                GROUP BY tipo
                ORDER BY tipo ASC";
        return $db->select($sql);
    }, 300);

    respondSuccess($data);
}

/**
 * Respuesta de éxito
 */
function respondSuccess($data) {
    http_response_code(200);
    echo json_encode($data);
    exit;
}

/**
 * Respuesta de error
 */
function respondError($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'error' => true,
        'message' => $message,
        'code' => $code
    ]);
    exit;
}
