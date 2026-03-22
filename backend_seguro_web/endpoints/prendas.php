<?php
/**
 * Endpoint: prendas.php
 * Gestión de prendas (garments) del club
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
        case 'getPrendasByClub':
            getPrendasByClub($db, $cache, $userData);
            break;

        case 'createPrenda':
            createPrenda($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in prendas.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * GET: Obtener prendas por club y temporada
 */
function getPrendasByClub($db, $cache, $userData) {
    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        respondError('idClub e idTemporada son obligatorios', 400);
    }

    $cacheKey = "prendas_club_{$idClub}_temp_{$idTemporada}";
    $prendas = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT id as idprenda, idclub, idtemporada, descripcion, pvp
                FROM tprendas
                WHERE idclub = ? AND idtemporada = ?
                ORDER BY descripcion ASC";
        $result = $db->select($sql, [$idClub, $idTemporada]);

        // Normalizar claves a minúsculas para compatibilidad con JSON
        return array_map(function($row) {
            return array_change_key_case($row, CASE_LOWER);
        }, $result);
    }, 0); // Cache desactivado temporalmente para testing

    error_log("🔍 [Prendas] Devolviendo " . count($prendas) . " prendas");
    if (!empty($prendas)) {
        error_log("🔍 [Prendas] Primera prenda: " . json_encode($prendas[0]));
    }

    respondSuccess($prendas);
}

/**
 * POST: Crear nueva prenda
 */
function createPrenda($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idclub = $input['idclub'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $descripcion = $input['descripcion'] ?? null;
    $pvp = $input['pvp'] ?? 0;

    if (!$idclub || !$idtemporada || !$descripcion) {
        respondError('idclub, idtemporada y descripcion son obligatorios', 400);
    }

    try {
        // Insertar prenda
        $sql = "INSERT INTO tprendas (idclub, idtemporada, descripcion, pvp) VALUES (?, ?, ?, ?)";
        $prendaId = $db->insert($sql, [$idclub, $idtemporada, $descripcion, $pvp]);

        // Obtener la prenda creada
        $sqlPrenda = "SELECT id as idprenda, idclub, idtemporada, descripcion, pvp
                      FROM tprendas WHERE id = ? LIMIT 1";
        $prendaCreada = $db->selectOne($sqlPrenda, [$prendaId]);

        if (!$prendaCreada) {
            respondInternalError('Error: No se pudo recuperar la prenda creada');
        }

        // Normalizar claves a minúsculas para compatibilidad con JSON
        $prendaCreada = array_change_key_case($prendaCreada, CASE_LOWER);

        // Invalidar cache
        $cache->clear("prendas_*");

        respondSuccess(['prenda' => $prendaCreada], 'Prenda creada correctamente');
    } catch (Exception $e) {
        error_log("Error al crear prenda: " . $e->getMessage());
        respondInternalError('Error al crear la prenda');
    }
}
