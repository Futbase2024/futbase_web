<?php
/**
 * Endpoint de Rivales
 * Gestión de equipos rivales
 *
 * NOTA: Los rivales están integrados en los partidos.
 * Este endpoint proporciona funciones auxiliares para gestionar la lista de rivales.
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Autenticación Firebase
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Rate limiting: 100 peticiones por 60 segundos
$rateLimiter = new RateLimiter();
$rateLimiter->check($userData['uid'], 100, 60);

// Conexión a base de datos
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché

// Router de acciones
$action = $_GET['action'] ?? $_POST['action'] ?? null;

switch ($action) {
    case 'getRivales':
        getRivales($db, $cache, $userData);
        break;
    case 'getRival':
        getRival($db, $cache, $userData);
        break;
    case 'searchRivales':
        searchRivales($db, $cache, $userData);
        break;
    default:
        ResponseHelper::error('Acción no válida', 400);
        break;
}

/**
 * Obtener todos los rivales
 * GET /rivales.php?action=getRivales
 * Permisos: Cualquier usuario autenticado
 */
function getRivales($db, $cache, $userData) {
    debugPrint("🔍 [Rivales] Obteniendo todos los rivales...");

    $cacheKey = "rivales_all";
    $rivales = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT DISTINCT
                    id,
                    club,
                    ncortoclub,
                    equipo,
                    ncorto,
                    escudo
                FROM trivales
                ORDER BY club, equipo";
        return $db->select($sql, []);
    });

    debugPrint("✅ [Rivales] Se encontraron " . count($rivales) . " rivales");
    ResponseHelper::success(['rivales' => $rivales]);
}

/**
 * Obtener un rival por ID
 * GET /rivales.php?action=getRival&id=123
 * Permisos: Cualquier usuario autenticado
 */
function getRival($db, $cache, $userData) {
    $id = $_GET['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('id es requerido', 400);
    }

    debugPrint("🔍 [Rivales] Obteniendo rival $id...");

    $cacheKey = "rival_{$id}";
    $rival = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM trivales WHERE id = ?";
        $result = $db->select($sql, [$id]);
        return $result[0] ?? null;
    });

    if ($rival) {
        debugPrint("✅ [Rivales] Rival encontrado");
        ResponseHelper::success(['rival' => $rival]);
    } else {
        debugPrint("❌ [Rivales] Rival no encontrado");
        ResponseHelper::error('Rival no encontrado', 404);
    }
}

/**
 * Buscar rivales por nombre
 * GET /rivales.php?action=searchRivales&query=nombre
 * Permisos: Cualquier usuario autenticado
 */
function searchRivales($db, $cache, $userData) {
    $query = $_GET['query'] ?? '';

    if (empty($query)) {
        ResponseHelper::error('query es requerido', 400);
    }

    debugPrint("🔍 [Rivales] Buscando rivales: $query");

    $cacheKey = "rivales_search_" . md5($query);
    $rivales = $cache->remember($cacheKey, function() use ($db, $query) {
        $searchTerm = "%{$query}%";
        $sql = "SELECT DISTINCT
                    id,
                    club,
                    ncortoclub,
                    equipo,
                    ncorto,
                    escudo
                FROM trivales
                WHERE club LIKE ?
                   OR equipo LIKE ?
                   OR ncortoclub LIKE ?
                   OR ncorto LIKE ?
                ORDER BY club, equipo";
        return $db->select($sql, [$searchTerm, $searchTerm, $searchTerm, $searchTerm]);
    });

    debugPrint("✅ [Rivales] Se encontraron " . count($rivales) . " rivales");
    ResponseHelper::success(['rivales' => $rivales]);
}

/**
 * Función auxiliar para debug prints
 */
function debugPrint($message) {
    error_log($message);
}
