<?php
/**
 * Versión DEBUG de cuotas.php para investigar errores POST
 * Subir temporalmente a: backend_seguro_web/endpoints/cuotas_debug.php
 */

// Log file
define('DEBUG_LOG', __DIR__ . '/../logs/cuotas_debug.log');

function debugLog($message) {
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message\n";
    file_put_contents(DEBUG_LOG, $logMessage, FILE_APPEND);
}

debugLog("========== INICIO REQUEST ==========");
debugLog("Method: " . $_SERVER['REQUEST_METHOD']);
debugLog("Action: " . ($_GET['action'] ?? 'none'));

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
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
    debugLog("respondSuccess: $message");
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
    debugLog("respondError: $message (code: $code)");
    header('Content-Type: application/json');
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message
    ]);
    exit;
}

try {
    debugLog("Iniciando autenticación...");
    // Autenticación Firebase
    $auth = new FirebaseAuthMiddleware();
    $userData = $auth->authenticate();
    debugLog("Autenticación exitosa: " . json_encode($userData));

    // Conexión a base de datos
    debugLog("Conectando a base de datos...");
    $db = Database::getInstance();
    $cache = new CacheManager();
    debugLog("Base de datos conectada");

    // Router de acciones
    $action = strtolower($_GET['action'] ?? '');
    debugLog("Acción: $action");

    switch ($action) {
        // Operaciones de lectura
        case 'getcuotabyid':
            getcuotabyid($db, $cache);
            break;
        case 'getcuotasbyclub':
            getcuotasbyclub($db, $cache);
            break;
        case 'getcuotabyplayertemp':
            getcuotabyplayertemp($db, $cache);
            break;
        case 'getcuotawithoutid':
            getcuotawithoutid($db, $cache);
            break;

        // Operaciones de escritura
        case 'createcuota':
            createcuota($db, $cache);
            break;
        case 'updatecuota':
            updatecuota($db, $cache);
            break;
        case 'updatetypecuota':
            updatetypecuota($db, $cache);
            break;
        case 'deletecuota':
            deletecuota($db, $cache);
            break;
        case 'deletecuotabyid':
            deletecuotabyid($db, $cache);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    debugLog("EXCEPCIÓN: " . $e->getMessage());
    debugLog("Stack trace: " . $e->getTraceAsString());
    respondError($e->getMessage(), 500);
}

/**
 * Obtener cuota por ID
 */
function getcuotabyid($db, $cache) {
    $idCuota = $_GET['idcuota'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idCuota || !$idTemporada) {
        respondError('idcuota e idtemporada son requeridos', 400);
    }

    $cacheKey = "cuota_{$idCuota}_{$idTemporada}";
    $cuota = $cache->remember($cacheKey, function() use ($db, $idCuota, $idTemporada) {
        $sql = "SELECT * FROM vCuotas WHERE id = ? AND idtemporada = ?";
        $result = $db->select($sql, [$idCuota, $idTemporada]);
        return $result[0] ?? null;
    }, 300);

    if (!$cuota) {
        respondSuccess(['cuota' => ['id' => 0]], 'Cuota no encontrada');
    }

    respondSuccess(['cuota' => $cuota], 'Cuota obtenida correctamente');
}

/**
 * Obtener cuotas por club
 */
function getcuotasbyclub($db, $cache) {
    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        respondError('idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "cuotas_club_{$idClub}_{$idTemporada}";
    $cuotas = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ?";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 300);

    respondSuccess(['cuotas' => $cuotas], count($cuotas) . ' cuotas obtenidas');
}

/**
 * Obtener cuotas de un jugador en temporada
 */
function getcuotabyplayertemp($db, $cache) {
    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;
    $idJugador = $_GET['idjugador'] ?? null;

    if (!$idClub || !$idTemporada || !$idJugador) {
        respondError('idclub, idtemporada e idjugador son requeridos', 400);
    }

    $cacheKey = "cuotas_player_{$idClub}_{$idTemporada}_{$idJugador}";
    $cuotas = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada, $idJugador) {
        $sql = "SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ? AND idjugador = ?";
        return $db->select($sql, [$idClub, $idTemporada, $idJugador]);
    }, 300);

    respondSuccess(['cuotas' => $cuotas], count($cuotas) . ' cuotas del jugador obtenidas');
}

/**
 * Buscar cuota sin ID (por múltiples criterios)
 */
function getcuotawithoutid($db, $cache) {
    $idJugador = $_GET['idjugador'] ?? null;
    $mes = $_GET['mes'] ?? null;
    $year = $_GET['year'] ?? null;
    $idEquipo = $_GET['idequipo'] ?? null;
    $idClub = $_GET['idclub'] ?? null;
    $idTipoCuota = $_GET['idtipocuota'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idJugador || !$mes || !$year || !$idEquipo || !$idClub || !$idTipoCuota || !$idTemporada) {
        respondError('Faltan parámetros requeridos: idjugador, mes, year, idequipo, idclub, idtipocuota, idtemporada', 400);
    }

    $cacheKey = "cuota_search_{$idJugador}_{$mes}_{$year}_{$idEquipo}_{$idClub}_{$idTipoCuota}_{$idTemporada}";
    $cuota = $cache->remember($cacheKey, function() use ($db, $idJugador, $mes, $year, $idEquipo, $idClub, $idTipoCuota, $idTemporada) {
        $sql = "SELECT * FROM vCuotas
                WHERE idjugador = ?
                AND mes = ?
                AND year = ?
                AND idequipo = ?
                AND idclub = ?
                AND idtipocuota = ?
                AND idtemporada = ?";
        $result = $db->select($sql, [$idJugador, $mes, $year, $idEquipo, $idClub, $idTipoCuota, $idTemporada]);
        return $result[0] ?? null;
    }, 300);

    if (!$cuota) {
        respondSuccess(['cuota' => ['id' => 0]], 'Cuota no encontrada');
    }

    respondSuccess(['cuota' => $cuota], 'Cuota encontrada');
}

// ============================================================================
// ✏️ FUNCIONES DE ESCRITURA (POST/PUT/DELETE)
// ============================================================================

/**
 * Crear una nueva cuota
 */
function createcuota($db, $cache) {
    debugLog("Entrando a createcuota()");

    $rawBody = file_get_contents('php://input');
    debugLog("Raw body length: " . strlen($rawBody));
    debugLog("Raw body: " . $rawBody);

    $body = json_decode($rawBody, true);
    debugLog("Body decoded: " . json_encode($body));

    $idclub = $body['idclub'] ?? null;
    $idequipo = $body['idequipo'] ?? null;
    $idjugador = $body['idjugador'] ?? null;
    $mes = $body['mes'] ?? null;
    $year = $body['year'] ?? null;
    $idestado = $body['idestado'] ?? null;
    $cantidad = $body['cantidad'] ?? null;
    $idtipocuota = $body['idtipocuota'] ?? null;
    $idtemporada = $body['idtemporada'] ?? null;

    debugLog("Parámetros extraídos: idclub=$idclub, idequipo=$idequipo, idjugador=$idjugador, mes=$mes, year=$year");

    if (!$idclub || !$idequipo || !$idjugador || !$mes || !$year || !$idestado || !$cantidad || !$idtipocuota || !$idtemporada) {
        debugLog("Faltan campos requeridos");
        respondError('Faltan campos requeridos', 400);
    }

    try {
        debugLog("Preparando SQL INSERT...");
        $sql = "INSERT INTO tcuotas (idclub, idequipo, idjugador, mes, year, idestado, cantidad, idtipocuota, idtemporada)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        debugLog("Ejecutando SQL: $sql");
        $db->execute($sql, [$idclub, $idequipo, $idjugador, $mes, $year, $idestado, $cantidad, $idtipocuota, $idtemporada]);

        $cuotaId = $db->getLastInsertId();
        debugLog("Cuota creada con ID: $cuotaId");

        // Invalidar caché
        $cache->delete("cuotas_club_{$idclub}_{$idtemporada}");
        $cache->delete("cuotas_player_{$idclub}_{$idtemporada}_{$idjugador}");
        debugLog("Caché invalidada");

        // Obtener la cuota creada
        debugLog("Obteniendo cuota creada...");
        $cuota = $db->selectOne("SELECT * FROM vCuotas WHERE id = ?", [$cuotaId]);
        debugLog("Cuota obtenida: " . json_encode($cuota));

        respondSuccess([
            'cuota' => $cuota,
            'message' => 'Cuota creada correctamente'
        ], 'Cuota creada correctamente');

    } catch (Exception $e) {
        debugLog("ERROR en createcuota: " . $e->getMessage());
        debugLog("Stack trace: " . $e->getTraceAsString());
        respondError('Error al crear la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar una cuota
 */
function updatecuota($db, $cache) {
    debugLog("Entrando a updatecuota()");
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;
    $idestado = $body['idestado'] ?? null;
    $timestamp = $body['timestamp'] ?? null;

    if (!$id || !$idestado) {
        respondError('id e idestado son requeridos', 400);
    }

    try {
        // Verificar que la cuota existe
        $cuotaExistente = $db->selectOne("SELECT * FROM tcuotas WHERE id = ?", [$id]);

        if (!$cuotaExistente) {
            respondError('La cuota no existe', 404);
        }

        // Actualizar cuota
        $sql = "UPDATE tcuotas SET idestado = ?, timestamp = ? WHERE id = ?";
        $db->execute($sql, [$idestado, $timestamp, $id]);

        // Invalidar caché
        $cache->delete("cuota_{$id}_{$cuotaExistente['idtemporada']}");
        $cache->delete("cuotas_club_{$cuotaExistente['idclub']}_{$cuotaExistente['idtemporada']}");
        $cache->delete("cuotas_player_{$cuotaExistente['idclub']}_{$cuotaExistente['idtemporada']}_{$cuotaExistente['idjugador']}");

        respondSuccess([
            'message' => 'Cuota actualizada correctamente'
        ], 'Cuota actualizada correctamente');

    } catch (Exception $e) {
        debugLog("ERROR en updatecuota: " . $e->getMessage());
        respondError('Error al actualizar la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar tipo de cuota (configuración)
 */
function updatetypecuota($db, $cache) {
    debugLog("Entrando a updatetypecuota()");
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;
    $tipo = $body['tipo'] ?? null;
    $cantidad = $body['cantidad'] ?? null;

    if (!$id || !$tipo || !$cantidad) {
        respondError('id, tipo y cantidad son requeridos', 400);
    }

    try {
        // Verificar que la configuración existe
        $configExistente = $db->selectOne("SELECT * FROM tconfigcuotas WHERE id = ?", [$id]);

        if (!$configExistente) {
            respondError('La configuración de cuota no existe', 404);
        }

        // Actualizar configuración
        $sql = "UPDATE tconfigcuotas SET tipo = ?, cantidad = ? WHERE id = ?";
        $db->execute($sql, [$tipo, $cantidad, $id]);

        // Invalidar caché relacionada
        $cache->delete("cuotas_club_{$configExistente['idclub']}_{$configExistente['idtemporada']}");

        respondSuccess([
            'message' => 'Configuración de cuota actualizada correctamente'
        ], 'Configuración de cuota actualizada correctamente');

    } catch (Exception $e) {
        debugLog("ERROR en updatetypecuota: " . $e->getMessage());
        respondError('Error al actualizar la configuración: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar una cuota
 */
function deletecuota($db, $cache) {
    debugLog("Entrando a deletecuota()");
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;

    if (!$id) {
        respondError('id es requerido', 400);
    }

    try {
        // Obtener datos antes de eliminar para invalidar caché
        $cuota = $db->selectOne("SELECT * FROM tcuotas WHERE id = ?", [$id]);

        if (!$cuota) {
            respondError('La cuota no existe', 404);
        }

        // Eliminar cuota
        $sql = "DELETE FROM tcuotas WHERE id = ?";
        $db->execute($sql, [$id]);

        // Invalidar caché
        $cache->delete("cuota_{$id}_{$cuota['idtemporada']}");
        $cache->delete("cuotas_club_{$cuota['idclub']}_{$cuota['idtemporada']}");
        $cache->delete("cuotas_player_{$cuota['idclub']}_{$cuota['idtemporada']}_{$cuota['idjugador']}");

        respondSuccess([
            'message' => 'Cuota eliminada correctamente'
        ], 'Cuota eliminada correctamente');

    } catch (Exception $e) {
        debugLog("ERROR en deletecuota: " . $e->getMessage());
        respondError('Error al eliminar la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar una cuota por ID (alias de deletecuota)
 */
function deletecuotabyid($db, $cache) {
    // Reutilizar la función deletecuota
    deletecuota($db, $cache);
}
