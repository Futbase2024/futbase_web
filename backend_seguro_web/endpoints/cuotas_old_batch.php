<?php
/**
 * Endpoint de cuotas con manejo robusto de errores
 * Asegura que SIEMPRE se devuelva JSON, nunca HTML
 */

// ⚠️ CRÍTICO: Capturar TODOS los errores y convertirlos a JSON
error_reporting(E_ALL);
ini_set('display_errors', 0); // NO mostrar errores en HTML
ini_set('log_errors', 1);

// Iniciar buffer de salida para capturar cualquier output inesperado
ob_start();

// Registrar manejador de errores fatal
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        ob_clean(); // Limpiar cualquier output previo (HTML)
        header('Content-Type: application/json');
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Error fatal del servidor: ' . $error['message'],
            'file' => basename($error['file']),
            'line' => $error['line']
        ]);
        exit;
    }
});

// Manejador de excepciones no capturadas
set_exception_handler(function($exception) {
    ob_clean(); // Limpiar cualquier output previo
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Excepción no capturada: ' . $exception->getMessage(),
        'file' => basename($exception->getFile()),
        'line' => $exception->getLine()
    ]);
    exit;
});

// Manejador de errores (warnings, notices, etc.)
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    // No interrumpir la ejecución por warnings menores, solo loguearlos
    error_log("PHP Error [$errno]: $errstr in " . basename($errfile) . " on line $errline");
    return true; // Prevenir el manejador por defecto
});

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
    ob_clean(); // Limpiar cualquier output previo (warnings, notices, etc.)
    header('Content-Type: application/json');
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $data,
        'message' => $message
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Responder con error
 */
function respondError($message, $code = 400) {
    ob_clean(); // Limpiar cualquier output previo (warnings, notices, HTML, etc.)
    header('Content-Type: application/json');
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // Autenticación Firebase
    $auth = new FirebaseAuthMiddleware();
    $userData = $auth->authenticate();

    // Conexión a base de datos
    $db = Database::getInstance();
    $cache = new CacheManager();

    // Router de acciones
    $action = strtolower($_GET['action'] ?? '');

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
        respondError('Faltan campos requeridos', 400);
    }

    try {
        $sql = "INSERT INTO tcuotas (idclub, idequipo, idjugador, mes, year, idestado, cantidad, idtipocuota, idtemporada)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $cuotaId = $db->insert($sql, [$idclub, $idequipo, $idjugador, $mes, $year, $idestado, $cantidad, $idtipocuota, $idtemporada]);

        // Invalidar caché
        $cache->delete("cuotas_club_{$idclub}_{$idtemporada}");
        $cache->delete("cuotas_player_{$idclub}_{$idtemporada}_{$idjugador}");

        // Obtener la cuota creada
        $cuota = $db->selectOne("SELECT * FROM vCuotas WHERE id = ?", [$cuotaId]);

        respondSuccess([
            'cuota' => $cuota,
            'message' => 'Cuota creada correctamente'
        ], 'Cuota creada correctamente');

    } catch (Exception $e) {
        respondError('Error al crear la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar una cuota
 */
function updatecuota($db, $cache) {
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
        respondError('Error al actualizar la cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar tipo de cuota (configuración)
 */
function updatetypecuota($db, $cache) {
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
        respondError('Error al actualizar la configuración: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar una cuota
 */
function deletecuota($db, $cache) {
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
