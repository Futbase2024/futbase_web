<?php
/**
 * 💰 Endpoint: contabilidad.php
 * Gestión de contabilidad del club
 * Fecha: 2025-10-26
 */

// ⚠️ CRÍTICO: Capturar TODOS los errores y convertirlos a JSON
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

ob_start();

register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        ob_clean();
        header('Content-Type: application/json');
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error fatal del servidor: ' . $error['message'],
            'file' => basename($error['file']),
            'line' => $error['line']
        ]);
        exit;
    }
});

set_exception_handler(function($exception) {
    ob_clean();
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Excepción no capturada: ' . $exception->getMessage(),
        'file' => basename($exception->getFile()),
        'line' => $exception->getLine()
    ]);
    exit;
});

set_error_handler(function($errno, $errstr, $errfile, $errline) {
    error_log("PHP Error [$errno]: $errstr in " . basename($errfile) . " on line $errline");
    return true;
});

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Autenticación Firebase
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Conexión a base de datos
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché

// Router de acciones
$action = $_GET['action'] ?? $_POST['action'] ?? null;

switch ($action) {
    // Operaciones de lectura
    case 'getContabilidadClub':
        getContabilidadClub($db, $cache, $userData);
        break;
    case 'getContabilidadClubFiltrada':
        getContabilidadClubFiltrada($db, $cache, $userData);
        break;

    // Operaciones de escritura
    case 'grabarAsiento':
        grabarAsiento($db, $cache, $userData);
        break;
    case 'updateAsiento':
        updateAsiento($db, $cache, $userData);
        break;
    case 'deleteAsiento':
        deleteAsiento($db, $cache, $userData);
        break;
    case 'deleteAsientoCuota':
        deleteAsientoCuota($db, $cache, $userData);
        break;
    case 'deleteAsientoPagoPersonal':
        deleteAsientoPagoPersonal($db, $cache, $userData);
        break;

    default:
        ResponseHelper::error('Acción no válida', 400);
}

// ============================================================================
// 📖 FUNCIONES DE LECTURA
// ============================================================================

/**
 * Obtener contabilidad del club
 */
function getContabilidadClub($db, $cache, $userData) {
    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos', 400);
    }

    $cacheKey = "contabilidad_club_{$idClub}_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        ResponseHelper::success($cached);
    }

    $sql = 'SELECT * FROM vContabilidad WHERE idclub = ? AND idtemporada = ? ORDER BY fecha DESC';
    $asientos = $db->select($sql, [$idClub, $idTemporada]);

    $cache->set($cacheKey, $asientos, 300);
    ResponseHelper::success($asientos);
}

/**
 * Obtener contabilidad filtrada
 */
function getContabilidadClubFiltrada($db, $cache, $userData) {
    $filtro = $_GET['filtro'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$filtro || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos', 400);
    }

    $cacheKey = "contabilidad_filtrada_{$filtro}_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        ResponseHelper::success($cached);
    }

    // Filtrado por concepto o familia
    $sql = 'SELECT * FROM vContabilidad
            WHERE idtemporada = ?
            AND (concepto LIKE ? OR familia LIKE ?)
            ORDER BY fecha DESC';

    $searchTerm = "%{$filtro}%";
    $asientos = $db->select($sql, [$idTemporada, $searchTerm, $searchTerm]);

    $cache->set($cacheKey, $asientos, 300);
    ResponseHelper::success($asientos);
}

// ============================================================================
// ✏️ FUNCIONES DE ESCRITURA
// ============================================================================

/**
 * Grabar nuevo asiento
 */
function grabarAsiento($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $idclub = $body['idclub'] ?? null;
    $fecha = $body['fecha'] ?? null;
    $concepto = $body['concepto'] ?? null;
    $cantidad = $body['cantidad'] ?? null;
    $idequipo = $body['idequipo'] ?? 0;
    $idtemporada = $body['idtemporada'] ?? null;
    $ingreso = $body['ingreso'] ?? 0;
    $gasto = $body['gasto'] ?? 0;
    $idcuota = $body['idcuota'] ?? 0;
    $idpagoper = $body['idpagoper'] ?? 0;

    if (!$idclub || !$fecha || !$concepto || !$cantidad || !$idtemporada) {
        ResponseHelper::error('Faltan campos requeridos', 400);
    }

    try {
        $sql = "INSERT INTO tcontabilidad
                (idclub, fecha, concepto, cantidad, idequipo, idtemporada, ingreso, gasto, idcuota, idpagoper)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $asientoId = $db->insert($sql, [
            $idclub, $fecha, $concepto, $cantidad, $idequipo,
            $idtemporada, $ingreso, $gasto, $idcuota, $idpagoper
        ]);

        // Invalidar caché
        $cache->clear();

        $asiento = $db->selectOne("SELECT * FROM vContabilidad WHERE id = ?", [$asientoId]);

        ResponseHelper::success([
            'asiento' => $asiento,
            'message' => 'Asiento grabado correctamente'
        ], 'Asiento grabado correctamente');

    } catch (Exception $e) {
        ResponseHelper::error('Error al grabar asiento: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar asiento
 */
function updateAsiento($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $id = $body['id'] ?? null;
    $idclub = $body['idclub'] ?? null;
    $fecha = $body['fecha'] ?? null;
    $concepto = $body['concepto'] ?? null;
    $cantidad = $body['cantidad'] ?? null;
    $idequipo = $body['idequipo'] ?? 0;
    $idtemporada = $body['idtemporada'] ?? null;
    $ingreso = $body['ingreso'] ?? 0;
    $gasto = $body['gasto'] ?? 0;
    $idcuota = $body['idcuota'] ?? 0;
    $idpagoper = $body['idpagoper'] ?? 0;

    if (!$id || !$idclub || !$fecha || !$concepto || !$cantidad || !$idtemporada) {
        ResponseHelper::error('Faltan campos requeridos', 400);
    }

    try {
        // Verificar que el asiento existe
        $existing = $db->selectOne("SELECT * FROM tcontabilidad WHERE id = ?", [$id]);

        if (!$existing) {
            ResponseHelper::error('El asiento no existe', 404);
        }

        $sql = "UPDATE tcontabilidad SET
                idclub = ?, fecha = ?, concepto = ?, cantidad = ?,
                idequipo = ?, idtemporada = ?, ingreso = ?, gasto = ?,
                idcuota = ?, idpagoper = ?
                WHERE id = ?";

        $db->execute($sql, [
            $idclub, $fecha, $concepto, $cantidad, $idequipo,
            $idtemporada, $ingreso, $gasto, $idcuota, $idpagoper, $id
        ]);

        // Invalidar caché
        $cache->clear();

        ResponseHelper::success(['message' => 'Asiento actualizado correctamente']);

    } catch (Exception $e) {
        ResponseHelper::error('Error al actualizar asiento: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar asiento
 */
function deleteAsiento($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);
    $id = $body['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID es requerido', 400);
    }

    try {
        // Verificar que existe
        $existing = $db->selectOne("SELECT * FROM tcontabilidad WHERE id = ?", [$id]);

        if (!$existing) {
            ResponseHelper::error('El asiento no existe', 404);
        }

        $db->execute("DELETE FROM tcontabilidad WHERE id = ?", [$id]);

        // Invalidar caché
        $cache->clear();

        ResponseHelper::success(['message' => 'Asiento eliminado correctamente']);

    } catch (Exception $e) {
        ResponseHelper::error('Error al eliminar asiento: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar asiento de cuota
 */
function deleteAsientoCuota($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);
    $idCuota = $body['idcuota'] ?? null;

    if (!$idCuota) {
        ResponseHelper::error('ID de cuota es requerido', 400);
    }

    try {
        $db->execute("DELETE FROM tcontabilidad WHERE idcuota = ?", [$idCuota]);

        // Invalidar caché
        $cache->clear();

        ResponseHelper::success(['message' => 'Asiento de cuota eliminado correctamente']);

    } catch (Exception $e) {
        ResponseHelper::error('Error al eliminar asiento de cuota: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar asiento de pago personal
 */
function deleteAsientoPagoPersonal($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);
    $idPagoPer = $body['idpagopersonal'] ?? null;

    if (!$idPagoPer) {
        ResponseHelper::error('ID de pago personal es requerido', 400);
    }

    try {
        $db->execute("DELETE FROM tcontabilidad WHERE idpagoper = ?", [$idPagoPer]);

        // Invalidar caché
        $cache->clear();

        ResponseHelper::success(['message' => 'Asiento de pago personal eliminado correctamente']);

    } catch (Exception $e) {
        ResponseHelper::error('Error al eliminar asiento de pago personal: ' . $e->getMessage(), 500);
    }
}
