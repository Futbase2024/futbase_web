<?php
/**
 * Endpoint de Escudos
 * Gestión de escudos de equipos
 */

// Suprimir todos los errores PHP para evitar contaminación del JSON
error_reporting(0);
ini_set('display_errors', '0');

// Limpiar cualquier output buffer previo
if (ob_get_level()) {
    ob_clean();
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Obtiene todos los escudos
 */
function getEscudos($db, $cache, $userData) {
    debugPrint("🔍 [Escudos] Obteniendo todos los escudos...");

    $cacheKey = "escudos_all";

    $escudos = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tescudos ORDER BY equipo";
        return $db->select($sql, []);
    });

    debugPrint("✅ [Escudos] Se encontraron " . count($escudos) . " escudos");
    ResponseHelper::success(['escudos' => $escudos]);
}

/**
 * Obtiene un escudo por ID
 */
function getEscudo($db, $cache, $userData) {
    $id = $_GET['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('id es requerido', 400);
    }

    debugPrint("🔍 [Escudos] Obteniendo escudo $id...");

    $cacheKey = "escudo_id_{$id}";

    $escudo = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM tescudos WHERE id = ?";
        $result = $db->select($sql, [$id]);
        return $result[0] ?? null;
    });

    if ($escudo) {
        debugPrint("✅ [Escudos] Escudo encontrado");
        ResponseHelper::success(['escudo' => $escudo]);
    } else {
        debugPrint("❌ [Escudos] Escudo no encontrado");
        ResponseHelper::error('Escudo no encontrado', 404);
    }
}

/**
 * Inserta un nuevo escudo
 */
function insertEscudo($db, $cache, $userData) {
    try {
        $rawInput = file_get_contents('php://input');
        $data = json_decode($rawInput, true);

        $equipo = $data['equipo'] ?? null;
        $url = $data['url'] ?? null;

        if (!$equipo || !$url) {
            ResponseHelper::error('equipo y url son requeridos', 400);
        }

        debugPrint("➕ [Escudos] Creando escudo para equipo: $equipo");

        // Verificar permisos: Admin(3), Entrenador(2), Coordinador(10), Delegado(12), Analista(13)
        $rolesPermitidos = [2, 3, 10, 12, 13];
        if (!in_array($userData['tipo'], $rolesPermitidos)) {
            debugPrint("❌ [Escudos] Usuario sin permisos");
            ResponseHelper::error('No tienes permisos para insertar escudos', 403);
        }

        // Insertar escudo
        $sql = "INSERT INTO tescudos (equipo, url) VALUES (?, ?)";
        $insertId = $db->insert($sql, [$equipo, $url]);

        if (!$insertId) {
            debugPrint("❌ [Escudos] Error al insertar escudo");
            ResponseHelper::error('Error al insertar el escudo', 500);
        }

        // Obtener el escudo recién insertado por ID
        $sqlGet = "SELECT * FROM tescudos WHERE id = ?";
        $escudo = $db->selectOne($sqlGet, [$insertId]);

        if (!$escudo) {
            debugPrint("❌ [Escudos] Error al obtener escudo creado");
            ResponseHelper::error('Error al obtener el escudo creado', 500);
        }

        // Invalidar caché de escudos
        $cache->forget("escudos_all");

        debugPrint("✅ [Escudos] Escudo creado con ID: $insertId");
        ResponseHelper::success(['escudo' => $escudo]);

    } catch (Exception $e) {
        debugPrint("❌ [Escudos] Exception: " . $e->getMessage());
        ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
    }
}

/**
 * Función auxiliar para debug prints
 */
function debugPrint($message) {
    error_log($message);
}

// Ejecución principal
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Rate limiting: 100 peticiones por 60 segundos
$rateLimiter = new RateLimiter();
$rateLimiter->check($userData['uid'], 100, 60);

$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché

try {
    $action = $_GET['action'] ?? null;
    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;
    }

    if (!$action) {
        ResponseHelper::error('Acción no especificada', 400);
    }

    switch ($action) {
        case 'getEscudos':
            getEscudos($db, $cache, $userData);
            break;

        case 'getEscudo':
            getEscudo($db, $cache, $userData);
            break;

        case 'insertEscudo':
            insertEscudo($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida', 400);
            break;
    }

} catch (Exception $e) {
    debugPrint("❌ [Escudos] Exception: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}
