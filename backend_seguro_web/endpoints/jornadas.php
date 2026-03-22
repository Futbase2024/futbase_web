<?php
/**
 * Endpoint seguro para gestión de jornadas
 * Usa PDO, autenticación Firebase JWT y caché
 *
 * Operaciones soportadas:
 * - getJornada: Obtiene una jornada específica por nombre
 * - getJornadas: Obtiene todas las jornadas ordenadas por ID
 *
 * Permisos: Operaciones de lectura públicas (sin autenticación requerida)
 */

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Responder con éxito
 */
function respondSuccess($data, $message = 'OK') {
    header('Content-Type: application/json');
    echo json_encode([
        'success' => true,
        'data' => $data,
        'message' => $message
    ]);
    exit;
}

/**
 * Responder con error
 */
function respondError($message, $code = 400) {
    header('Content-Type: application/json');
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message
    ]);
    exit;
}

try {
    $auth = new FirebaseAuthMiddleware();
    $db = Database::getInstance();
    $cache = new CacheManager(300); // TTL de 5 minutos para jornadas

    // Obtener acción
    $action = $_GET['action'] ?? $_POST['action'] ?? null;

    if (!$action) {
        respondError('Acción no especificada', 400);
    }

    // Las jornadas son datos públicos, no requieren autenticación
    // Aplicamos rate limit más permisivo para lecturas públicas
    $acciones_publicas = ['getJornada', 'getJornadas'];

    if (in_array($action, $acciones_publicas)) {
        // Rate limit permisivo para operaciones de lectura públicas
        // 100 peticiones por minuto
        $userData = $auth->protect(100, 60);
    } else {
        // Para futuras operaciones de escritura (crear/actualizar jornadas)
        // Rate limit más restrictivo: 50 peticiones por minuto
        $userData = $auth->protect(50, 60);
    }

    // Enrutar a la función correspondiente
    switch ($action) {
        case 'getJornada':
            getJornada($auth, $db, $cache);
            break;
        case 'getJornadas':
            getJornadas($auth, $db, $cache);
            break;
        case 'version':
            respondSuccess([
                'version' => '1.0.0',
                'date' => '2025-10-25',
                'endpoints' => ['getJornada', 'getJornadas']
            ]);
            break;
        default:
            respondError('Acción no válida', 400);
    }

} catch (Exception $e) {
    error_log("❌ [Jornadas] Error: " . $e->getMessage());
    respondError($e->getMessage(), 500);
}

/**
 * Obtiene una jornada específica por nombre
 * GET /jornadas.php?action=getJornada&jornada=Jornada1
 *
 * Parámetros:
 * - jornada: Nombre de la jornada a buscar (ej: "Jornada1")
 *
 * Retorna:
 * - Jornada encontrada o jornada con id=null si no existe
 * - Mantiene compatibilidad con comportamiento legacy
 */
function getJornada($auth, $db, $cache) {
    error_log("🔐 [Jornadas] getJornada - Inicio");

    $jornada = $_GET['jornada'] ?? null;

    if (!$jornada) {
        error_log("❌ [Jornadas] getJornada - Parámetro jornada no proporcionado");
        respondError('Parámetro jornada es requerido', 400);
    }

    error_log("🔍 [Jornadas] Buscando jornada: $jornada");

    // Intentar obtener de caché
    $cacheKey = "jornada_{$jornada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        error_log("✅ [Jornadas] getJornada - Datos obtenidos de caché");
        respondSuccess(['jornada' => $cached]);
    }

    // Consultar base de datos
    $sql = "SELECT * FROM tjornadas WHERE jornada = ? LIMIT 1";
    $jornadaData = $db->selectOne($sql, [$jornada]);

    // Si no se encuentra, devolver jornada con id=null (igual que legacy)
    if (!$jornadaData) {
        error_log("⚠️  [Jornadas] getJornada - Jornada no encontrada, retornando id=null");
        $jornadaData = ['id' => null];
    } else {
        error_log("✅ [Jornadas] getJornada - Jornada encontrada con ID: " . $jornadaData['id']);
        // Guardar en caché
        $cache->set($cacheKey, $jornadaData, 300);
    }

    respondSuccess(['jornada' => $jornadaData]);
}

/**
 * Obtiene todas las jornadas ordenadas por ID
 * GET /jornadas.php?action=getJornadas
 *
 * Retorna:
 * - Lista de todas las jornadas ordenadas por ID
 * - Array vacío si no hay jornadas
 */
function getJornadas($auth, $db, $cache) {
    error_log("🔐 [Jornadas] getJornadas - Inicio");

    // Intentar obtener de caché
    $cacheKey = "all_jornadas";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        error_log("✅ [Jornadas] getJornadas - Datos obtenidos de caché (" . count($cached) . " jornadas)");
        respondSuccess(['jornadas' => $cached]);
    }

    // Consultar base de datos
    $sql = "SELECT * FROM tjornadas ORDER BY id";
    $jornadas = $db->select($sql, []);

    error_log("✅ [Jornadas] getJornadas - " . count($jornadas) . " jornadas encontradas");

    // Guardar en caché (10 minutos, las jornadas cambian poco)
    $cache->set($cacheKey, $jornadas, 600);

    respondSuccess(['jornadas' => $jornadas]);
}
