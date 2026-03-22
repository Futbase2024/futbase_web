<?php
/**
 * Endpoint de Cuotas Club
 * Operaciones CRUD de cuotas de club
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
        case 'getCuota':
            getCuota($db, $cache, $userData);
            break;

        case 'getCuotas':
            getCuotas($db, $cache, $userData);
            break;

        case 'getCuotasByClub':
            getCuotasByClub($db, $cache, $userData);
            break;

        case 'createCuota':
            createCuota($db, $cache, $userData);
            break;

        case 'updateCuota':
            updateCuota($db, $cache, $userData);
            break;

        case 'deleteCuota':
            deleteCuota($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in cuotas_club.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene una cuota por tipo
 */
function getCuota($db, $cache, $userData) {
    $tipo = $_GET['tipo'] ?? null;
    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$tipo || !$idClub || !$idTemporada) {
        respondError('tipo, idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "cuota_club_tipo_{$tipo}_club_{$idClub}_temp_{$idTemporada}";

    $cuota = $cache->remember($cacheKey, function() use ($db, $tipo, $idClub, $idTemporada) {
        $sql = "SELECT * FROM tconfigcuotas WHERE tipo = ? AND idclub = ? AND idtemporada = ? LIMIT 1";
        return $db->selectOne($sql, [$tipo, $idClub, $idTemporada]);
    }, 600);

    if (!$cuota) {
        respondSuccess(['id' => 0], 'Cuota no encontrada');
    }

    respondSuccess($cuota, 'Cuota obtenida');
}

/**
 * Obtiene todas las cuotas (opcionalmente filtradas por temporada)
 */
function getCuotas($db, $cache, $userData) {
    $idTemporada = $_GET['idTemporada'] ?? null;

    if ($idTemporada) {
        // Filtrar por temporada si se proporciona
        $cacheKey = "cuotas_club_temporada_{$idTemporada}";

        $cuotas = $cache->remember($cacheKey, function() use ($db, $idTemporada) {
            $sql = "SELECT * FROM tconfigcuotas WHERE idtemporada = ? ORDER BY tipo ASC";
            return $db->select($sql, [$idTemporada]);
        }, 600);
    } else {
        // Devolver todas las cuotas si no se proporciona temporada
        $cacheKey = "cuotas_club_all";

        $cuotas = $cache->remember($cacheKey, function() use ($db) {
            $sql = "SELECT * FROM tconfigcuotas ORDER BY tipo ASC";
            return $db->select($sql);
        }, 600);
    }

    respondSuccess($cuotas);
}

/**
 * Obtiene cuotas de un club específico
 */
function getCuotasByClub($db, $cache, $userData) {
    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son requeridos', 400);
    }

    $cacheKey = "cuotas_club_club_{$idClub}_temp_{$idTemporada}";

    $cuotas = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT * FROM tconfigcuotas WHERE idclub = ? AND idtemporada = ? ORDER BY tipo ASC";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 600);

    respondSuccess($cuotas);
}

/**
 * Crea una nueva cuota
 */
function createCuota($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos', 400);
    }

    $idclub = $input['idclub'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $cantidad = $input['cantidad'] ?? 0;
    $idtemporada = $input['idtemporada'] ?? null;

    if (!$idclub || !$tipo || !$idtemporada) {
        respondError('idclub, tipo e idtemporada son obligatorios', 400);
    }

    // Verificar si ya existe
    $sqlCheck = "SELECT id FROM tconfigcuotas WHERE idclub = ? AND tipo = ? AND idtemporada = ? LIMIT 1";
    $existing = $db->selectOne($sqlCheck, [$idclub, $tipo, $idtemporada]);

    if ($existing) {
        respondError('Ya existe una cuota de este tipo para este club y temporada', 409);
    }

    $sql = "INSERT INTO tconfigcuotas (idclub, tipo, cantidad, idtemporada) VALUES (?, ?, ?, ?)";
    $cuotaId = $db->insert($sql, [$idclub, $tipo, $cantidad, $idtemporada]);

    if (!$cuotaId) {
        respondInternalError('Error al crear la cuota');
    }

    // Obtener la cuota creada
    $sqlCuota = "SELECT * FROM tconfigcuotas WHERE id = ? LIMIT 1";
    $cuotaCreada = $db->selectOne($sqlCuota, [$cuotaId]);

    // Invalidar cache
    $cache->clear("cuotas_*");

    respondSuccess([
        'cuota' => $cuotaCreada,
        'message' => 'Cuota creada correctamente'
    ], 'Cuota creada');
}

/**
 * Actualiza una cuota existente
 */
function updateCuota($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos inválidos', 400);
    }

    $id = $input['id'];
    $tipo = $input['tipo'] ?? null;
    $cantidad = $input['cantidad'] ?? null;

    $sql = "UPDATE tconfigcuotas SET tipo = ?, cantidad = ? WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$tipo, $cantidad, $id]);

    if ($rowsAffected === 0) {
        respondNotFound('Cuota no encontrada o sin cambios');
    }

    // Invalidar cache
    $cache->clear("cuotas_*");

    respondSuccess(null, 'Cuota actualizada correctamente');
}

/**
 * Elimina una cuota
 */
function deleteCuota($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos inválidos', 400);
    }

    $id = $input['id'];

    $sql = "DELETE FROM tconfigcuotas WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$id]);

    if ($rowsAffected === 0) {
        respondNotFound('Cuota no encontrada');
    }

    // Invalidar cache
    $cache->clear("cuotas_*");

    respondSuccess(null, 'Cuota eliminada correctamente');
}
