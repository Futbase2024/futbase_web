<?php
/**
 * Endpoint de Pagos Personal
 * Gestión de pagos al personal del club
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Inicializar dependencias
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché
$auth = new FirebaseAuthMiddleware();

// Proteger endpoint con autenticación y rate limiting
$userData = $auth->protect(100, 60); // 100 requests/min

// Obtener acción
$action = $_GET['action'] ?? '';

// Enrutamiento de acciones
try {
    switch ($action) {
        case 'getPagosByUser':
            getPagosByUser($db, $cache, $userData);
            break;

        case 'getPagosByClub':
            getPagosByClub($db, $cache, $userData);
            break;

        case 'createPago':
            createPago($db, $cache, $userData);
            break;

        case 'updatePago':
            updatePago($db, $cache, $userData);
            break;

        case 'deletePago':
            deletePago($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in pagos_personal.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene pagos por usuario
 */
function getPagosByUser($db, $cache, $userData) {
    $idUser = $_GET['idUser'] ?? null;
    $idClub = $_GET['idClub'] ?? null;

    if (!$idUser || !$idClub) {
        respondError('idUser e idClub son requeridos', 400);
    }

    $cacheKey = "pagos_personal_user_{$idUser}_club_{$idClub}";

    $pagos = $cache->remember($cacheKey, function() use ($db, $idUser, $idClub) {
        $sql = "SELECT * FROM tpagopersonal WHERE iduser = ? AND idclub = ? ORDER BY fecha DESC";
        return $db->select($sql, [$idUser, $idClub]);
    }, 300);

    respondSuccess($pagos);
}

/**
 * Obtiene pagos por club y temporada
 */
function getPagosByClub($db, $cache, $userData) {
    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "pagos_personal_club_{$idClub}_temporada_{$idTemporada}";

    $pagos = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT * FROM tpagopersonal WHERE idclub = ? AND idtemporada = ? ORDER BY fecha DESC";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 300);

    respondSuccess($pagos);
}

/**
 * Crea un nuevo pago
 */
function createPago($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos', 400);
    }

    $iduser = $input['iduser'] ?? null;
    $idclub = $input['idclub'] ?? null;
    $idequipo = $input['idequipo'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $concepto = $input['concepto'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $importe = $input['importe'] ?? null;
    $fecha = $input['fecha'] ?? null;

    if (!$iduser || !$idclub || $importe === null) {
        respondError('iduser, idclub e importe son obligatorios', 400);
    }

    $sql = "INSERT INTO tpagopersonal (iduser, idclub, idequipo, idtemporada, concepto, tipo, importe, fecha)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    $pagoId = $db->insert($sql, [
        $iduser,
        $idclub,
        $idequipo,
        $idtemporada,
        $concepto,
        $tipo,
        $importe,
        $fecha
    ]);

    if (!$pagoId) {
        respondInternalError('Error al crear el pago');
    }

    // Obtener el pago creado
    $sqlPago = "SELECT * FROM tpagopersonal WHERE id = ? LIMIT 1";
    $pagoCreado = $db->selectOne($sqlPago, [$pagoId]);

    // Invalidar cache
    $cache->clear("pagos_*");

    respondSuccess([
        'pago' => $pagoCreado,
        'message' => 'Pago creado correctamente'
    ], 'Pago creado');
}

/**
 * Actualiza un pago existente
 */
function updatePago($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos inválidos', 400);
    }

    $id = $input['id'];
    $iduser = $input['iduser'] ?? null;
    $idclub = $input['idclub'] ?? null;
    $idequipo = $input['idequipo'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $concepto = $input['concepto'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $importe = $input['importe'] ?? null;
    $fecha = $input['fecha'] ?? null;

    $sql = "UPDATE tpagopersonal SET
            iduser = ?,
            idclub = ?,
            idequipo = ?,
            idtemporada = ?,
            concepto = ?,
            tipo = ?,
            importe = ?,
            fecha = ?
            WHERE id = ?";

    $rowsAffected = $db->execute($sql, [
        $iduser,
        $idclub,
        $idequipo,
        $idtemporada,
        $concepto,
        $tipo,
        $importe,
        $fecha,
        $id
    ]);

    if ($rowsAffected === 0) {
        respondNotFound('Pago no encontrado o sin cambios');
    }

    // Invalidar cache
    $cache->clear("pagos_*");

    respondSuccess(null, 'Pago actualizado correctamente');
}

/**
 * Elimina un pago
 */
function deletePago($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos inválidos', 400);
    }

    $id = $input['id'];

    $sql = "DELETE FROM tpagopersonal WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$id]);

    if ($rowsAffected === 0) {
        respondNotFound('Pago no encontrado');
    }

    // Invalidar cache
    $cache->clear("pagos_*");

    respondSuccess(null, 'Pago eliminado correctamente');
}
