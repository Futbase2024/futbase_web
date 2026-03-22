<?php
/**
 * Endpoint de Posiciones
 * Alias para compatibilidad con Flutter - usa la tabla tposiciones
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
        case 'getall':
            getAll($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in posiciones.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene todas las posiciones
 */
function getAll($db, $cache, $auth) {
    // No requiere autenticación - datos públicos
    $cacheKey = "posiciones_all";

    $posiciones = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT id, posicion, photourl FROM tposiciones ORDER BY id ASC";
        return $db->select($sql);
    }, 300);

    // Devolver en formato esperado por Flutter
    respondSuccess($posiciones);
}
