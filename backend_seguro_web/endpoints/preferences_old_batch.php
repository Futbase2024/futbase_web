<?php
/**
 * Endpoint: Preferences (Preferencias)
 * Descripción: Gestión de preferencias y configuración de la aplicación
 *
 * Acciones:
 * - GET: getPreferences, getTemporada
 */

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/RateLimiter.php';

// Configurar manejo de errores y output buffering
ini_set('display_errors', 0);
error_reporting(E_ALL);
ob_start();

// Registrar handler de errores
set_error_handler(function($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});

register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        ob_clean();
        http_response_code(500);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'error' => 'Error interno del servidor',
            'message' => 'Ha ocurrido un error inesperado'
        ]);
    }
    ob_end_flush();
});

try {
    // Inicializar servicios
    $db = Database::getInstance();
    $cache = new CacheManager();
    $auth = new FirebaseAuthMiddleware();

    // Verificar autenticación
    $authResult = $auth->authenticate();
    $userId = $authResult['uid'];
    $idClub = $authResult['id_club'];

    // Obtener acción
    $action = $_GET['action'] ?? '';

    // Rate limiting
    $rateLimiter = new RateLimiter();

    switch ($action) {

        case 'getPreferences':
            // Rate limiting: lectura
            if (!$rateLimiter->checkLimit($userId, 'read')) {
                ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
            }

            // Cache key
            $cacheKey = "preferences_club_{$idClub}";

            // Intentar obtener del cache
            $cachedData = $cache->get($cacheKey);
            if ($cachedData !== null) {
                ResponseHelper::success($cachedData);
            }

            $db = Database::getInstance();

            // Obtener preferencias del club
            $query = "
                SELECT
                    c.id,
                    c.nombre as appName,
                    c.testing,
                    c.token,
                    c.fcm_key as fcmKey,
                    c.calidad_imagen as calidadImagen,
                    t.id as temporada_id,
                    t.id as temporada_idtemporada,
                    t.temporada as temporada_temporada
                FROM club c
                LEFT JOIN temporadas t ON c.idtemporada = t.id
                WHERE c.id = :idClub
            ";

            $result = $db->selectOne($query, ['idClub' => $idClub]);

            if (!$result) {
                ResponseHelper::error('No se encontraron preferencias');
            }

            // Formatear respuesta
            $preferences = [
                'id' => $result['id'],
                'appName' => $result['appName'],
                'testing' => $result['testing'],
                'token' => $result['token'],
                'fcmKey' => $result['fcmKey'],
                'calidadImagen' => $result['calidadImagen'],
                'temporada' => null
            ];

            // Agregar temporada si existe
            if ($result['temporada_id']) {
                $preferences['temporada'] = [
                    'id' => $result['temporada_id'],
                    'idtemporada' => $result['temporada_idtemporada'],
                    'temporada' => $result['temporada_temporada']
                ];
            }

            // Guardar en cache (5 minutos)
            $cache->set($cacheKey, $preferences, 300);

            ResponseHelper::success($preferences);
            break;

        case 'getTemporada':
            // Rate limiting: lectura
            if (!$rateLimiter->checkLimit($userId, 'read')) {
                ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
            }

            // Cache key
            $cacheKey = "temporada_actual_club_{$idClub}";

            // Intentar obtener del cache
            $cachedData = $cache->get($cacheKey);
            if ($cachedData !== null) {
                ResponseHelper::success($cachedData);
            }

            $db = Database::getInstance();

            // Obtener temporada actual del club
            $query = "
                SELECT
                    t.id,
                    t.id as idtemporada,
                    t.temporada
                FROM club c
                INNER JOIN temporadas t ON c.idtemporada = t.id
                WHERE c.id = :idClub
            ";

            $temporada = $db->selectOne($query, ['idClub' => $idClub]);

            if (!$temporada) {
                ResponseHelper::error('No se encontró temporada actual');
            }

            // Guardar en cache (10 minutos)
            $cache->set($cacheKey, $temporada, 600);

            ResponseHelper::success($temporada);
            break;

        default:
            ResponseHelper::error('Acción no válida', 400);
    }

} catch (Exception $e) {
    ob_clean();
    error_log("Error en preferences.php: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());

    ResponseHelper::error(
        'Error al procesar la solicitud: ' . $e->getMessage(),
        500
    );
}
