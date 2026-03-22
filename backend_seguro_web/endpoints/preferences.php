<?php
/**
 * Endpoint: Preferences (Preferencias)
 * Descripción: Gestión de preferencias y configuración de la aplicación
 *
 * Acciones:
 * - GET: getPreferences, getTemporada
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

$action = strtolower($_GET['action'] ?? '');

// 🔓 Acciones públicas que NO requieren autenticación
$publicActions = ['gettemporada', 'getpreferences'];

// Solo autenticar si la acción NO es pública
$userData = null;
if (!in_array($action, $publicActions)) {
    $userData = $auth->protect(100, 60);
}

try {
    switch ($action) {
        case 'getpreferences':
            getPreferences($db, $cache, $userData);
            break;
        case 'gettemporada':
            getTemporada($db, $cache, $userData);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in preferences.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

function getPreferences($db, $cache, $userData) {
    $idClub = $userData['id_club'] ?? null;

    if (!$idClub) {
        // Si no hay usuario autenticado, devolver preferencias vacías
        respondSuccess([
            'id' => null,
            'appName' => 'FutBase',
            'testing' => false,
            'token' => '',
            'fcmKey' => '',
            'calidadImagen' => 80,
            'temporada' => null,
        ], 'Preferencias por defecto (sin autenticación)');
        return;
    }

    $cacheKey = "preferences_club_{$idClub}";

    $preferences = $cache->remember($cacheKey, function() use ($db, $idClub) {
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
            WHERE c.id = ?
        ";

        $result = $db->selectOne($query, [$idClub]);

        if (!$result) {
            return null;
        }

        $preferences = [
            'id' => $result['id'],
            'appName' => $result['appName'],
            'testing' => $result['testing'],
            'token' => $result['token'],
            'fcmKey' => $result['fcmKey'],
            'calidadImagen' => $result['calidadImagen'],
            'temporada' => null
        ];

        if ($result['temporada_id']) {
            $preferences['temporada'] = [
                'id' => $result['temporada_id'],
                'idtemporada' => $result['temporada_idtemporada'],
                'temporada' => $result['temporada_temporada']
            ];
        }

        return $preferences;
    }, 300);

    if (!$preferences) {
        respondError('No se encontraron preferencias', 404);
    }

    respondSuccess($preferences);
}

function getTemporada($db, $cache, $userData) {
    $idClub = $userData['id_club'] ?? null;

    if (!$idClub) {
        respondError('idClub no encontrado en token', 400);
    }

    $cacheKey = "temporada_actual_club_{$idClub}";

    $temporada = $cache->remember($cacheKey, function() use ($db, $idClub) {
        $query = "
            SELECT
                t.id,
                t.id as idtemporada,
                t.temporada
            FROM club c
            INNER JOIN temporadas t ON c.idtemporada = t.id
            WHERE c.id = ?
        ";

        return $db->selectOne($query, [$idClub]);
    }, 600);

    if (!$temporada) {
        respondError('No se encontró temporada actual', 404);
    }

    respondSuccess($temporada);
}
