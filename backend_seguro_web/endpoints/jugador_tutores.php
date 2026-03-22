<?php
/**
 * Endpoint: jugador_tutores.php
 * Descripción: Gestión de relaciones entre jugadores y tutores
 * Fecha: 2025-12-06
 *
 * Operaciones:
 * - getTutoresByJugador: Obtener todos los tutores de un jugador
 */

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

// Inicializar servicios
$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché por defecto
$rateLimiter = new RateLimiter();

// Autenticar usuario con rate limiting de lectura
$userData = $middleware->protect();

// Obtener acción
$action = $_GET['action'] ?? null;

if (!$action) {
    respondError('Acción no especificada', 400);
}

// Rate limiting para lectura (100 req/min)
if (!$rateLimiter->isAllowed($userData['uid'])) {
    respondError('Demasiadas peticiones. Por favor, intenta más tarde.', 429);
}

// Ejecutar acción
switch ($action) {
    case 'getTutoresByJugador':
        $result = getTutoresByJugador($db, $cache, $userData);
        break;
    default:
        respondError('Acción no válida', 400);
}

respondSuccess($result);

// ==================== FUNCIONES ====================

/**
 * Obtiene todos los tutores de un jugador
 */
function getTutoresByJugador($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idjugador = Validator::validateInt($input['idJugador'] ?? null);
    $idtemporada = Validator::validateInt($input['idTemporada'] ?? null);

    if (!$idjugador || !$idtemporada) {
        respondError('Parámetros incompletos: idJugador e idTemporada son requeridos', 400);
    }

    $cacheKey = "jugador_tutores_jugador_{$idjugador}_temporada_{$idtemporada}";

    return $cache->remember($cacheKey, function() use ($db, $idjugador, $idtemporada) {
        // Consulta que busca en los 4 campos de jugador en troles
        $sql = 'SELECT DISTINCT
                    r.id as idrol,
                    r.idusuario,
                    r.tipo,
                    r.uid,
                    u.id,
                    u.nombre,
                    u.apellidos,
                    u.email,
                    u.telefono,
                    u.user,
                    u.password,
                    r.idtemporada
                FROM troles r
                INNER JOIN tusuarios u ON r.idusuario = u.id
                WHERE r.tipo = 4
                  AND r.idtemporada = ?
                  AND (
                      r.idjugador = ?
                      OR r.idjugador2 = ?
                      OR r.idjugador3 = ?
                      OR r.idjugador4 = ?
                  )';

        $params = [$idtemporada, $idjugador, $idjugador, $idjugador, $idjugador];

        $tutores = $db->select($sql, $params);

        return $tutores ?? [];
    }, 300);
}
