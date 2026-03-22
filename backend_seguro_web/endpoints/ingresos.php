<?php
/**
 * Endpoint: ingresos.php
 * Gestión de ingresos del club
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
        case 'getIngresos':
            getIngresos($db, $cache, $userData);
            break;

        case 'getIngreso':
            getIngreso($db, $cache, $userData);
            break;

        case 'grabarIngreso':
            grabarIngreso($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in ingresos.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * GET: Obtener todos los ingresos del club
 */
function getIngresos($db, $cache, $userData) {
    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        respondError('Usuario sin club asignado', 403);
    }

    $cacheKey = "ingresos_club_{$idClub}";
    $ingresos = $cache->remember($cacheKey, function() use ($db, $idClub) {
        // Obtener ingresos del club y los genéricos (idclub = 0)
        $sql = "SELECT * FROM tingresos WHERE idclub IN (?, 0) ORDER BY concepto ASC";
        return $db->select($sql, [$idClub]);
    }, 300);

    respondSuccess($ingresos);
}

/**
 * GET: Obtener un ingreso por ID
 */
function getIngreso($db, $cache, $userData) {
    $idIngreso = $_GET['id'] ?? null;

    if (!$idIngreso) {
        respondError('ID de ingreso requerido', 400);
    }

    $idClub = $userData['idclub'] ?? null;
    if (!$idClub) {
        respondError('Usuario sin club asignado', 403);
    }

    $cacheKey = "ingreso_{$idIngreso}";
    $ingreso = $cache->remember($cacheKey, function() use ($db, $idIngreso, $idClub) {
        $sql = "SELECT * FROM tingresos WHERE id = ? AND idclub = ? LIMIT 1";
        return $db->selectOne($sql, [$idIngreso, $idClub]);
    }, 300);

    if (!$ingreso) {
        respondNotFound('Ingreso no encontrado');
    }

    respondSuccess($ingreso);
}

/**
 * POST: Grabar nuevo ingreso
 */
function grabarIngreso($db, $cache, $userData) {
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
    $sqlCheck = "SELECT id FROM tingresos WHERE idclub = ? AND concepto = ? LIMIT 1";
    $existing = $db->selectOne($sqlCheck, [$idClub, $concepto]);

    if ($existing) {
        respondError('Ya existe un ingreso con ese concepto', 409);
    }

    try {
        // Insertar nuevo ingreso
        $sql = "INSERT INTO tingresos (idclub, concepto) VALUES (?, ?)";
        $ingresoId = $db->insert($sql, [$idClub, $concepto]);

        // Obtener el ingreso creado
        $sqlIngreso = "SELECT * FROM tingresos WHERE id = ? LIMIT 1";
        $ingresoCreado = $db->selectOne($sqlIngreso, [$ingresoId]);

        if (!$ingresoCreado) {
            respondInternalError('Error: No se pudo recuperar el ingreso creado');
        }

        // Limpiar cache
        $cache->clear("ingresos_*");

        // Retornar con la estructura esperada por Dart
        respondSuccess(['ingreso' => $ingresoCreado], 'Ingreso creado correctamente');
    } catch (Exception $e) {
        error_log("Error al crear ingreso: " . $e->getMessage());
        respondInternalError('Error al crear el ingreso');
    }
}
