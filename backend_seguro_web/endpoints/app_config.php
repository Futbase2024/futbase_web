<?php
/**
 * Endpoint: app_config.php
 * Configuración global de la aplicación
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

$action = $_GET['action'] ?? $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'getAppConfig':
            getAppConfig($db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in app_config.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * GET: Obtener configuración de la aplicación
 */
function getAppConfig($db, $cache) {
    $cacheKey = "app_config";

    $config = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT
            id,
            appname,
            COALESCE(testing, 0) as testing,
            COALESCE(token, '') as token,
            COALESCE(fcmkey, '') as fcmkey,
            COALESCE(calidadimagen, 80) as calidadimagen
            FROM tappconfig LIMIT 1";
        $result = $db->selectOne($sql);

        if (!$result) {
            // Si no existe configuración, crear una por defecto
            return [
                'id' => 1,
                'appname' => 'FutBase',
                'testing' => 0,
                'token' => '',
                'fcmkey' => '',
                'calidadimagen' => 80
            ];
        }

        return $result;
    }, 3600);

    respondSuccess($config);
}
