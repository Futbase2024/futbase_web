<?php
/**
 * Endpoint: gastos.php
 * Gestión de gastos del club
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
        case 'getGastos':
            getGastos($db, $cache, $userData);
            break;

        case 'getGasto':
            getGasto($db, $cache, $userData);
            break;

        case 'grabarGasto':
            grabarGasto($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in gastos.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * GET: Obtener todos los gastos del club
 */
function getGastos($db, $cache, $userData) {
    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        respondError('Usuario sin club asignado', 403);
    }

    $cacheKey = "gastos_club_{$idClub}";
    $gastos = $cache->remember($cacheKey, function() use ($db, $idClub) {
        // Obtener gastos del club y los genéricos (idclub = 0)
        $sql = "SELECT * FROM tgastos WHERE idclub IN (?, 0) ORDER BY concepto ASC";
        return $db->select($sql, [$idClub]);
    }, 300);

    respondSuccess($gastos);
}

/**
 * GET: Obtener un gasto por ID
 */
function getGasto($db, $cache, $userData) {
    $idGasto = $_GET['id'] ?? null;

    if (!$idGasto) {
        respondError('ID de gasto requerido', 400);
    }

    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        respondError('Usuario sin club asignado', 403);
    }

    $cacheKey = "gasto_{$idGasto}";
    $gasto = $cache->remember($cacheKey, function() use ($db, $idGasto, $idClub) {
        $sql = "SELECT * FROM tgastos WHERE id = ? AND idclub = ? LIMIT 1";
        return $db->selectOne($sql, [$idGasto, $idClub]);
    }, 300);

    if (!$gasto) {
        respondNotFound('Gasto no encontrado');
    }

    respondSuccess($gasto);
}

/**
 * POST: Grabar nuevo gasto
 */
function grabarGasto($db, $cache, $userData) {
    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        respondError('Usuario sin club asignado', 403);
    }

    $input = json_decode(file_get_contents('php://input'), true);
    $concepto = $input['concepto'] ?? null;

    if (!$concepto) {
        respondError('Concepto es obligatorio', 400);
    }

    // Verificar si ya existe
    $sqlCheck = "SELECT id FROM tgastos WHERE idclub = ? AND concepto = ? LIMIT 1";
    $existing = $db->selectOne($sqlCheck, [$idClub, $concepto]);

    if ($existing) {
        respondError('Ya existe un gasto con ese concepto', 409);
    }

    try {
        // Insertar nuevo gasto
        $sql = "INSERT INTO tgastos (idclub, concepto) VALUES (?, ?)";
        $gastoId = $db->insert($sql, [$idClub, $concepto]);

        // Obtener el gasto creado
        $sqlGasto = "SELECT * FROM tgastos WHERE id = ? LIMIT 1";
        $gastoCreado = $db->selectOne($sqlGasto, [$gastoId]);

        if (!$gastoCreado) {
            respondInternalError('Error: No se pudo recuperar el gasto creado');
        }

        // Limpiar cache
        $cache->clear("gastos_*");

        // Retornar con la estructura esperada por Dart
        respondSuccess(['gasto' => $gastoCreado], 'Gasto creado correctamente');
    } catch (Exception $e) {
        error_log("Error al crear gasto: " . $e->getMessage());
        respondInternalError('Error al crear el gasto');
    }
}
