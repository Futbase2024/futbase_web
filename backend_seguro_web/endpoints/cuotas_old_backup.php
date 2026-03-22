<?php
/**
 * 💳 Endpoint de Gestión de Cuotas
 * Operaciones CRUD de cuotas de jugadores
 *
 * Permisos: Cualquier usuario autenticado
 * Rate Limit: 100 req/min lectura, 50 req/min escritura
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Autenticación Firebase
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Conexión a base de datos
$db = Database::getInstance();
$cache = new CacheManager();

// Rate limiting
$rateLimiter = new RateLimiter();
$action = strtolower($_GET['action'] ?? '');

// Aplicar rate limit según tipo de operación
$writeActions = ['createcuota', 'updatecuota', 'updatetypecuota', 'deletecuota', 'deletecuotabyid'];
if (in_array($action, $writeActions)) {
    $rateLimiter->checkLimit($userData['uid'], 50); // 50 req/min para escritura
} else {
    $rateLimiter->checkLimit($userData['uid'], 100); // 100 req/min para lectura
}

// Router de acciones
switch ($action) {
    // ============================================================================
    // 📖 OPERACIONES DE LECTURA (GET)
    // ============================================================================
    case 'getcuotabyid':
        getcuotabyid($db, $cache, $userData);
        break;
    case 'getcuotasbyclub':
        getcuotasbyclub($db, $cache, $userData);
        break;
    case 'getcuotabyplayertemp':
        getcuotabyplayertemp($db, $cache, $userData);
        break;
    case 'getcuotawithoutid':
        getcuotawithoutid($db, $cache, $userData);
        break;

    // ============================================================================
    // ✏️ OPERACIONES DE ESCRITURA (POST/PUT/DELETE)
    // ============================================================================
    case 'createcuota':
        createcuota($db, $cache, $userData);
        break;
    case 'updatecuota':
        updatecuota($db, $cache, $userData);
        break;
    case 'updatetypecuota':
        updatetypecuota($db, $cache, $userData);
        break;
    case 'deletecuota':
        deletecuota($db, $cache, $userData);
        break;
    case 'deletecuotabyid':
        deletecuotabyid($db, $cache, $userData);
        break;

    default:
        ResponseHelper::error('❌ Acción no válida', 400);
        break;
}

// ============================================================================
// 📖 FUNCIONES DE LECTURA (GET)
// ============================================================================

/**
 * 🔍 Obtener una cuota por ID
 * GET /cuotas.php?action=getcuotabyid&idcuota=123&idtemporada=6
 * Permisos: Cualquier usuario autenticado
 */
function getcuotabyid($db, $cache, $userData) {
    $idCuota = $_GET['idcuota'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idCuota || !$idTemporada) {
        ResponseHelper::error('❌ idcuota e idtemporada son requeridos', 400);
    }

    $cacheKey = "cuota_{$idCuota}_{$idTemporada}";
    $cuota = $cache->remember($cacheKey, function() use ($db, $idCuota, $idTemporada) {
        $sql = "SELECT * FROM vCuotas WHERE id = ? AND idtemporada = ?";
        return $db->selectOne($sql, [$idCuota, $idTemporada]);
    }, 300);

    if (!$cuota) {
        // Retornar cuota vacía si no existe (comportamiento legacy)
        ResponseHelper::success(['cuota' => ['id' => 0]], '✅ Cuota no encontrada');
    }

    ResponseHelper::success(['cuota' => $cuota], '✅ Cuota obtenida correctamente');
}

/**
 * 🔍 Obtener cuotas de un club
 * GET /cuotas.php?action=getcuotasbyclub&idclub=1&idtemporada=6
 * Permisos: Cualquier usuario autenticado
 */
function getcuotasbyclub($db, $cache, $userData) {
    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        ResponseHelper::error('❌ idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "cuotas_club_{$idClub}_{$idTemporada}";
    $cuotas = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ?";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 300);

    ResponseHelper::success(['cuotas' => $cuotas], '✅ ' . count($cuotas) . ' cuotas obtenidas');
}

/**
 * 🔍 Obtener cuotas de un jugador en temporada
 * GET /cuotas.php?action=getcuotabyplayertemp&idclub=1&idtemporada=6&idjugador=123
 * Permisos: Cualquier usuario autenticado
 */
function getcuotabyplayertemp($db, $cache, $userData) {
    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;
    $idJugador = $_GET['idjugador'] ?? null;

    if (!$idClub || !$idTemporada || !$idJugador) {
        ResponseHelper::error('❌ idclub, idtemporada e idjugador son requeridos', 400);
    }

    $cacheKey = "cuotas_player_{$idClub}_{$idTemporada}_{$idJugador}";
    $cuotas = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada, $idJugador) {
        $sql = "SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ? AND idjugador = ?";
        return $db->select($sql, [$idClub, $idTemporada, $idJugador]);
    }, 300);

    ResponseHelper::success(['cuotas' => $cuotas], '✅ ' . count($cuotas) . ' cuotas del jugador obtenidas');
}

/**
 * 🔍 Buscar cuota sin ID (por múltiples criterios)
 * GET /cuotas.php?action=getcuotawithoutid&idjugador=123&mes=1&year=2025&idequipo=1&idclub=1&idtipocuota=1&idtemporada=6
 * Permisos: Cualquier usuario autenticado
 */
function getcuotawithoutid($db, $cache, $userData) {
    $idjugador = $_GET['idjugador'] ?? null;
    $mes = $_GET['mes'] ?? null;
    $year = $_GET['year'] ?? null;
    $idequipo = $_GET['idequipo'] ?? null;
    $idclub = $_GET['idclub'] ?? null;
    $idtipocuota = $_GET['idtipocuota'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idjugador || !$mes || !$year || !$idequipo || !$idclub || !$idtipocuota || !$idTemporada) {
        ResponseHelper::error('❌ Faltan parámetros requeridos: idjugador, mes, year, idequipo, idclub, idtipocuota, idtemporada', 400);
    }

    $cacheKey = "cuota_criteria_{$idjugador}_{$mes}_{$year}_{$idequipo}_{$idclub}_{$idtipocuota}_{$idTemporada}";
    $cuota = $cache->remember($cacheKey, function() use ($db, $idjugador, $mes, $year, $idequipo, $idclub, $idtipocuota, $idTemporada) {
        $sql = "SELECT * FROM vCuotas
                WHERE idjugador = ? AND mes = ? AND year = ?
                AND idequipo = ? AND idclub = ? AND idtipocuota = ?
                AND idtemporada = ?
                ORDER BY timestamp DESC
                LIMIT 1";
        return $db->selectOne($sql, [$idjugador, $mes, $year, $idequipo, $idclub, $idtipocuota, $idTemporada]);
    }, 300);

    if (!$cuota) {
        // Retornar cuota vacía si no existe (comportamiento legacy)
        ResponseHelper::success(['cuota' => ['id' => 0]], '✅ Cuota no encontrada');
    }

    ResponseHelper::success(['cuota' => $cuota], '✅ Cuota encontrada');
}

// ============================================================================
// ✏️ FUNCIONES DE ESCRITURA (POST/PUT/DELETE)
// ============================================================================

/**
 * ➕ Crear una nueva cuota
 * POST /cuotas.php?action=createcuota
 * Body: { idclub, idequipo, idjugador, mes, year, idestado, cantidad, idtipocuota, idtemporada }
 * Permisos: Cualquier usuario autenticado
 */
function createcuota($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $idclub = $body['idclub'] ?? null;
    $idequipo = $body['idequipo'] ?? null;
    $idjugador = $body['idjugador'] ?? null;
    $mes = $body['mes'] ?? null;
    $year = $body['year'] ?? null;
    $idestado = $body['idestado'] ?? null;
    $cantidad = $body['cantidad'] ?? null;
    $idtipocuota = $body['idtipocuota'] ?? null;
    $idtemporada = $body['idtemporada'] ?? null;

    if (!$idclub || !$idequipo || !$idjugador || !$mes || !$year || !$idestado || !$cantidad || !$idtipocuota || !$idtemporada) {
        ResponseHelper::error('❌ Faltan campos requeridos', 400);
    }

    try {
        $sql = "INSERT INTO tcuotas (idclub, idequipo, idjugador, mes, year, idestado, cantidad, idtipocuota, idtemporada)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $db->execute($sql, [$idclub, $idequipo, $idjugador, $mes, $year, $idestado, $cantidad, $idtipocuota, $idtemporada]);
        $cuotaId = $db->getLastInsertId();

        // Invalidar caché
        $cache->delete("cuotas_club_{$idclub}_{$idtemporada}");
        $cache->delete("cuotas_player_{$idclub}_{$idtemporada}_{$idjugador}");

        // Obtener la cuota creada
        $cuota = $db->selectOne("SELECT * FROM vCuotas WHERE id = ?", [$cuotaId]);

        ResponseHelper::success([
            'cuota' => $cuota,
            'message' => '✅ Cuota creada correctamente'
        ], '✅ Cuota creada correctamente');

    } catch (Exception $e) {
        ResponseHelper::error('❌ Error al crear la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * ♻️ Actualizar una cuota
 * PUT /cuotas.php?action=updatecuota
 * Body: { id, idestado, timestamp }
 * Permisos: Cualquier usuario autenticado
 */
function updatecuota($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;
    $idestado = $body['idestado'] ?? null;
    $timestamp = $body['timestamp'] ?? null;

    if (!$id || !$idestado) {
        ResponseHelper::error('❌ id e idestado son requeridos', 400);
    }

    try {
        // Verificar que la cuota existe
        $cuotaExistente = $db->selectOne("SELECT * FROM tcuotas WHERE id = ?", [$id]);

        if (!$cuotaExistente) {
            ResponseHelper::error('❌ La cuota no existe', 404);
        }

        // Actualizar cuota
        $sql = "UPDATE tcuotas SET idestado = ?, timestamp = ? WHERE id = ?";
        $db->execute($sql, [$idestado, $timestamp, $id]);

        // Invalidar caché
        $cache->delete("cuota_{$id}_{$cuotaExistente['idtemporada']}");
        $cache->delete("cuotas_club_{$cuotaExistente['idclub']}_{$cuotaExistente['idtemporada']}");
        $cache->delete("cuotas_player_{$cuotaExistente['idclub']}_{$cuotaExistente['idtemporada']}_{$cuotaExistente['idjugador']}");

        ResponseHelper::success([
            'message' => '✅ Cuota actualizada correctamente'
        ], '✅ Cuota actualizada correctamente');

    } catch (Exception $e) {
        ResponseHelper::error('❌ Error al actualizar la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * ♻️ Actualizar tipo de cuota (configuración de cuota del club)
 * PUT /cuotas.php?action=updatetypecuota
 * Body: { id, tipo, cantidad }
 * Permisos: Cualquier usuario autenticado
 */
function updatetypecuota($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;
    $tipo = $body['tipo'] ?? null;
    $cantidad = $body['cantidad'] ?? null;

    if (!$id || !$tipo || !$cantidad) {
        ResponseHelper::error('❌ id, tipo y cantidad son requeridos', 400);
    }

    try {
        // Verificar que la configuración existe
        $configExistente = $db->selectOne("SELECT * FROM tconfigcuotas WHERE id = ?", [$id]);

        if (!$configExistente) {
            ResponseHelper::error('❌ La configuración de cuota no existe', 404);
        }

        // Actualizar configuración
        $sql = "UPDATE tconfigcuotas SET tipo = ?, cantidad = ? WHERE id = ?";
        $db->execute($sql, [$tipo, $cantidad, $id]);

        // Invalidar caché relacionada
        $cache->delete("cuotas_club_{$configExistente['idclub']}_{$configExistente['idtemporada']}");

        ResponseHelper::success([
            'message' => '✅ Configuración de cuota actualizada correctamente'
        ], '✅ Configuración de cuota actualizada correctamente');

    } catch (Exception $e) {
        ResponseHelper::error('❌ Error al actualizar la configuración: ' . $e->getMessage(), 500);
    }
}

/**
 * 🗑️ Eliminar una cuota
 * DELETE /cuotas.php?action=deletecuota
 * Body: { id }
 * Permisos: Cualquier usuario autenticado
 */
function deletecuota($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('❌ id es requerido', 400);
    }

    try {
        // Obtener datos antes de eliminar para invalidar caché
        $cuota = $db->selectOne("SELECT * FROM tcuotas WHERE id = ?", [$id]);

        if (!$cuota) {
            ResponseHelper::error('❌ La cuota no existe', 404);
        }

        // Eliminar cuota
        $sql = "DELETE FROM tcuotas WHERE id = ?";
        $db->execute($sql, [$id]);

        // Invalidar caché
        $cache->delete("cuota_{$id}_{$cuota['idtemporada']}");
        $cache->delete("cuotas_club_{$cuota['idclub']}_{$cuota['idtemporada']}");
        $cache->delete("cuotas_player_{$cuota['idclub']}_{$cuota['idtemporada']}_{$cuota['idjugador']}");

        ResponseHelper::success([
            'message' => '✅ Cuota eliminada correctamente'
        ], '✅ Cuota eliminada correctamente');

    } catch (Exception $e) {
        ResponseHelper::error('❌ Error al eliminar la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * 🗑️ Eliminar una cuota por ID (alias de deletecuota)
 * DELETE /cuotas.php?action=deletecuotabyid
 * Body: { id }
 * Permisos: Cualquier usuario autenticado
 */
function deletecuotabyid($db, $cache, $userData) {
    // Reutilizar la función deletecuota
    deletecuota($db, $cache, $userData);
}
