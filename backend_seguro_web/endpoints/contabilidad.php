<?php
/**
 * 💰 Endpoint: contabilidad.php
 * Gestión de contabilidad del club
 * Fecha: 2025-10-26
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

$action = $_GET['action'] ?? '';

try {
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
        case 'deleteAsientoReciboDeuda':
            deleteAsientoReciboDeuda($db, $cache, $userData);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in contabilidad.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

function getContabilidadClub($db, $cache, $userData) {
    $idclub = $_GET['idclub'] ?? null;
    $idtemporada = $_GET['idtemporada'] ?? null;

    if (!$idclub || !$idtemporada) {
        respondError('idclub e idtemporada requeridos', 400);
    }

    $cacheKey = "contabilidad_club_{$idclub}_{$idtemporada}";
    $contabilidad = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada) {
        $sql = 'SELECT * FROM vContabilidad WHERE idclub = ? AND idtemporada = ? ORDER BY fecha DESC';
        return $db->select($sql, [$idclub, $idtemporada]);
    }, 300);

    respondSuccess($contabilidad);
}

function getContabilidadClubFiltrada($db, $cache, $userData) {
    $filtro = $_GET['filtro'] ?? null;
    $idtemporada = $_GET['idtemporada'] ?? null;

    if (!$filtro || !$idtemporada) {
        respondError('filtro e idtemporada requeridos', 400);
    }

    $cacheKey = "contabilidad_filtrada_" . md5($filtro . $idtemporada);
    $contabilidad = $cache->remember($cacheKey, function() use ($db, $filtro, $idtemporada) {
        // El filtro viene como condición SQL completa (ej: "idclub=133")
        $sql = "SELECT * FROM vContabilidad WHERE $filtro AND idtemporada = ? ORDER BY fecha ASC";
        return $db->select($sql, [$idtemporada]);
    }, 300);

    respondSuccess($contabilidad);
}

function grabarAsiento($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    // Campos obligatorios
    $idclub = $input['idclub'] ?? null;
    $concepto = $input['concepto'] ?? null;
    $cantidad = $input['cantidad'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;

    // Validar campos obligatorios
    if (!$idclub || !$concepto || $cantidad === null || $cantidad === '' || !$idtemporada) {
        respondError('Datos incompletos (idclub, concepto, cantidad, idtemporada requeridos)', 400);
    }

    // Campos con valores por defecto (NO NULL)
    $idequipo = $input['idequipo'] ?? 0;
    $familia = $input['familia'] ?? '';
    $ingreso = $input['ingreso'] ?? 0;
    $gasto = $input['gasto'] ?? 0;
    $idcuota = $input['idcuota'] ?? 0;
    $idpagoper = $input['idpagoper'] ?? 0;
    $idestado = $input['idestado'] ?? 0;
    $fecha = $input['fecha'] ?? date('Y-m-d H:i:s');

    // Convertir ingreso/gasto a int (0 o 1)
    $ingresoInt = ($ingreso === 1 || $ingreso === '1' || $ingreso === true) ? 1 : 0;
    $gastoInt = ($gasto === 1 || $gasto === '1' || $gasto === true) ? 1 : 0;

    // Asegurar que los IDs sean enteros
    $idequipoInt = is_numeric($idequipo) ? (int)$idequipo : 0;
    $idcuotaInt = is_numeric($idcuota) ? (int)$idcuota : 0;
    $idpagoperInt = is_numeric($idpagoper) ? (int)$idpagoper : 0;
    $idestadoInt = is_numeric($idestado) ? (int)$idestado : 0;

    // Debug: Log datos recibidos
    error_log("grabarAsiento - Datos procesados: " . json_encode([
        'idclub' => $idclub,
        'idequipo' => $idequipoInt,
        'familia' => $familia,
        'concepto' => $concepto,
        'ingreso' => $ingresoInt,
        'gasto' => $gastoInt,
        'cantidad' => $cantidad,
        'idcuota' => $idcuotaInt,
        'idpagoper' => $idpagoperInt,
        'fecha' => $fecha,
        'idtemporada' => $idtemporada,
        'idestado' => $idestadoInt
    ]));

    try {
        $sql = 'INSERT INTO tcontabilidad (idclub, idequipo, familia, concepto, ingreso, gasto, cantidad, idcuota, idpagoper, fecha, idtemporada, idestado)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';

        $insertId = $db->insert($sql, [
            $idclub,
            $idequipoInt,
            $familia,
            $concepto,
            $ingresoInt,
            $gastoInt,
            $cantidad,
            $idcuotaInt,
            $idpagoperInt,
            $fecha,
            $idtemporada,
            $idestadoInt
        ]);

        $cache->clear("contabilidad_*");
        respondSuccess(['success' => true, 'id' => $insertId]);
    } catch (Exception $e) {
        error_log("Error al crear asiento: " . $e->getMessage());
        respondInternalError('Error al crear asiento: ' . $e->getMessage());
    }
}

function updateAsiento($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;

    if (!$id) {
        respondError('id requerido', 400);
    }

    // Primero verificar si existe el registro (igual que en el repository_impl legacy)
    $sqlCheck = 'SELECT id FROM tcontabilidad WHERE id = ?';
    $exists = $db->select($sqlCheck, [$id]);

    if (empty($exists)) {
        respondError('Asiento no encontrado', 404);
    }

    // Preparar campos con valores por defecto (NO NULL)
    $idclub = $input['idclub'] ?? 0;
    $idequipo = isset($input['idequipo']) ? (is_numeric($input['idequipo']) ? (int)$input['idequipo'] : 0) : 0;
    $familia = $input['familia'] ?? '';
    $concepto = $input['concepto'] ?? '';
    $ingreso = isset($input['ingreso']) ? (($input['ingreso'] === 1 || $input['ingreso'] === '1' || $input['ingreso'] === true) ? 1 : 0) : 0;
    $gasto = isset($input['gasto']) ? (($input['gasto'] === 1 || $input['gasto'] === '1' || $input['gasto'] === true) ? 1 : 0) : 0;
    $cantidad = $input['cantidad'] ?? 0;
    $idcuota = isset($input['idcuota']) ? (is_numeric($input['idcuota']) ? (int)$input['idcuota'] : 0) : 0;
    $idpagoper = isset($input['idpagoper']) ? (is_numeric($input['idpagoper']) ? (int)$input['idpagoper'] : 0) : 0;
    $fecha = $input['fecha'] ?? date('Y-m-d H:i:s');
    $idtemporada = isset($input['idtemporada']) ? (is_numeric($input['idtemporada']) ? (int)$input['idtemporada'] : 0) : 0;
    $idestado = isset($input['idestado']) ? (is_numeric($input['idestado']) ? (int)$input['idestado'] : 0) : 0;

    // SQL de actualización (incluye idestado para cambios de estado de pago)
    $sql = 'UPDATE tcontabilidad SET
            idclub = ?,
            idequipo = ?,
            familia = ?,
            concepto = ?,
            ingreso = ?,
            gasto = ?,
            cantidad = ?,
            idcuota = ?,
            idpagoper = ?,
            idtemporada = ?,
            fecha = ?,
            idestado = ?
            WHERE id = ?';

    try {
        $db->execute($sql, [
            $idclub,
            $idequipo,
            $familia,
            $concepto,
            $ingreso,
            $gasto,
            $cantidad,
            $idcuota,
            $idpagoper,
            $idtemporada,
            $fecha,
            $idestado,
            $id
        ]);

        $cache->clear("contabilidad_*");
        respondSuccess(['success' => true]);
    } catch (Exception $e) {
        error_log("Error al actualizar asiento: " . $e->getMessage());
        respondInternalError('Error al actualizar asiento: ' . $e->getMessage());
    }
}

function deleteAsiento($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;

    if (!$id) {
        respondError('id requerido', 400);
    }

    $sql = 'DELETE FROM tcontabilidad WHERE id = ?';

    try {
        $db->execute($sql, [$id]);
        $cache->clear("contabilidad_*");
        respondSuccess(['success' => true]);
    } catch (Exception $e) {
        error_log("Error al eliminar asiento: " . $e->getMessage());
        respondInternalError('Error al eliminar asiento');
    }
}

function deleteAsientoCuota($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idcuota = $input['idcuota'] ?? null;

    if (!$idcuota) {
        respondError('idcuota requerido', 400);
    }

    $sql = 'DELETE FROM tcontabilidad WHERE idcuota = ?';

    try {
        $db->execute($sql, [$idcuota]);
        $cache->clear("contabilidad_*");
        respondSuccess(['success' => true]);
    } catch (Exception $e) {
        error_log("Error al eliminar asiento de cuota: " . $e->getMessage());
        respondInternalError('Error al eliminar asiento de cuota');
    }
}

function deleteAsientoPagoPersonal($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idpagopersonal = $input['idpagopersonal'] ?? null;

    if (!$idpagopersonal) {
        respondError('idpagopersonal requerido', 400);
    }

    $sql = 'DELETE FROM tcontabilidad WHERE idpagopersonal = ?';

    try {
        $db->execute($sql, [$idpagopersonal]);
        $cache->clear("contabilidad_*");
        respondSuccess(['success' => true]);
    } catch (Exception $e) {
        error_log("Error al eliminar asiento de pago personal: " . $e->getMessage());
        respondInternalError('Error al eliminar asiento de pago personal');
    }
}

function deleteAsientoReciboDeuda($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idrecibo = $input['idrecibo'] ?? null;

    if (!$idrecibo) {
        respondError('idrecibo requerido', 400);
    }

    // Eliminar asientos que coincidan con el patrón "Recibo Deuda #ID"
    $sql = "DELETE FROM tcontabilidad WHERE concepto LIKE ?";

    try {
        $db->execute($sql, ["Recibo Deuda #$idrecibo%"]);
        $cache->clear("contabilidad_*");
        respondSuccess(['success' => true]);
    } catch (Exception $e) {
        error_log("Error al eliminar asiento de recibo deuda: " . $e->getMessage());
        respondInternalError('Error al eliminar asiento de recibo deuda');
    }
}
