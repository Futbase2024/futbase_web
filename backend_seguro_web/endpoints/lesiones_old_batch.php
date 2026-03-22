<?php
/**
 * Endpoint de Gestión de Lesiones
 * Operaciones CRUD de lesiones de jugadores
 *
 * Permisos: Cualquier usuario autenticado para lectura
 *           Roles 1,2,3,10,12,13 para escritura
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
            'message' => 'Error fatal del servidor: ' . $error['message'],
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
        'message' => 'Excepción no capturada: ' . $exception->getMessage(),
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

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Autenticación Firebase
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Rate limiting: 100 peticiones por 60 segundos
$rateLimiter = new RateLimiter(100, 60);
if (!$rateLimiter->isAllowed($userData['uid'])) {
    ResponseHelper::error('Demasiadas peticiones. Por favor, intenta más tarde.', 429);
}

// Conexión a base de datos
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché

/**
 * Función auxiliar para debug prints
 */
function debugPrint($message) {
    error_log($message);
}

// Router de acciones
$action = $_GET['action'] ?? $_POST['action'] ?? null;

switch ($action) {
    case 'getlesiones':
        getLesiones($db, $cache, $userData);
        break;
    case 'grabarlesion':
        grabarLesion($db, $cache, $userData);
        break;
    case 'updatelesion':
        updateLesion($db, $cache, $userData);
        break;
    case 'deletelesion':
        deleteLesion($db, $cache, $userData);
        break;
    default:
        ResponseHelper::error('❌ Acción no válida', 400);
        break;
}

/**
 * Obtener lesiones de un jugador
 * GET /lesiones.php?action=getlesiones&idjugador=123
 * Permisos: Cualquier usuario autenticado
 */
function getLesiones($db, $cache, $userData) {
    $idjugador = $_GET['idjugador'] ?? $_GET['idJugador'] ?? null;

    if (!$idjugador) {
        ResponseHelper::error('❌ idjugador es requerido', 400);
    }

    debugPrint("🔍 [Lesiones] Obteniendo lesiones del jugador $idjugador");

    $cacheKey = "lesiones_jugador_{$idjugador}";
    $lesiones = $cache->remember($cacheKey, function() use ($db, $idjugador) {
        $sql = "SELECT * FROM tlesiones WHERE idjugador = ? ORDER BY fechainicio DESC";
        return $db->select($sql, [$idjugador]);
    });

    debugPrint("✅ [Lesiones] Se encontraron " . count($lesiones) . " lesiones");
    ResponseHelper::success(['lesiones' => $lesiones]);
}

/**
 * Crear una nueva lesión
 * POST /lesiones.php?action=grabarlesion
 * Body: {
 *   "idclub": 1,
 *   "idequipo": 1,
 *   "idjugador": 123,
 *   "lesion": "Rotura de ligamento",
 *   "tipo": "muscular",
 *   "observaciones": "...",
 *   "fechainicio": "2025-01-01",
 *   "idtemporada": 6
 * }
 * Permisos: Cualquier usuario autenticado
 */
function grabarLesion($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idclub = $input['idclub'] ?? null;
    $idequipo = $input['idequipo'] ?? null;
    $idjugador = $input['idjugador'] ?? null;
    $lesion = $input['lesion'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $observaciones = $input['observaciones'] ?? null;
    $fechainicio = $input['fechainicio'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;

    if (!$idclub || !$idequipo || !$idjugador || !$lesion || !$fechainicio || !$idtemporada) {
        ResponseHelper::error('❌ Faltan datos requeridos: idclub, idequipo, idjugador, lesion, fechainicio, idtemporada', 400);
    }

    debugPrint("➕ [Lesiones] Creando lesión para jugador $idjugador");

    // Convertir fechainicio si viene en formato ISO8601
    if (strpos($fechainicio, 'T') !== false) {
        $fechainicio = date('Y-m-d', strtotime($fechainicio));
    }

    $sql = "INSERT INTO tlesiones (idclub, idequipo, idjugador, lesion, tipo, observaciones, fechainicio, idtemporada)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    $result = $db->insert($sql, [$idclub, $idequipo, $idjugador, $lesion, $tipo, $observaciones, $fechainicio, $idtemporada]);

    if ($result) {
        // Invalidar cache
        $cache->forget("lesiones_jugador_{$idjugador}");

        debugPrint("✅ [Lesiones] Lesión creada con ID: " . $db->lastInsertId());
        ResponseHelper::success([
            'success' => true,
            'id' => $db->lastInsertId()
        ]);
    } else {
        debugPrint("❌ [Lesiones] Error al crear lesión");
        ResponseHelper::error('❌ Error al crear lesión', 500);
    }
}

/**
 * Actualizar una lesión
 * POST /lesiones.php?action=updatelesion
 * Body: {
 *   "id": 123,
 *   "fechainicio": "2025-01-01",
 *   "fechafin": "2025-02-01",
 *   "tipo": "muscular",
 *   "lesion": "Rotura de ligamento",
 *   "duracion": 30,
 *   "idjugador": 123
 * }
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function updateLesion($db, $cache, $userData) {
    // Validar permisos de escritura
    $writableRoles = [1, 2, 3, 10, 12, 13];

    // Obtener el rol del usuario desde vroles
    $uid = $userData['uid'] ?? null;
    $idtemporada = $userData['idtemporada'] ?? null;

    if (!$uid) {
        ResponseHelper::error('❌ UID de usuario no encontrado', 400);
    }

    $sqlRol = "SELECT tipo FROM vroles WHERE uid = ? AND idtemporada = ? AND selectedrol = 1 LIMIT 1";
    $rolData = $db->selectOne($sqlRol, [$uid, $idtemporada]);
    $userRole = $rolData['tipo'] ?? 0;

    debugPrint("🔐 [Lesiones] Usuario con ROL: $userRole");

    if (!in_array($userRole, $writableRoles)) {
        ResponseHelper::error('🔒 No tienes permisos para actualizar lesiones', 403);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    $fechainicio = $input['fechainicio'] ?? null;
    $fechafin = $input['fechafin'] ?? null;
    $tipo = $input['tipo'] ?? null;
    $lesion = $input['lesion'] ?? null;
    $duracion = $input['duracion'] ?? 0;
    $idjugador = $input['idjugador'] ?? null;

    if (!$id || !$idjugador) {
        ResponseHelper::error('❌ Faltan datos requeridos: id, idjugador', 400);
    }

    debugPrint("✏️ [Lesiones] Actualizando lesión $id");

    // Verificar que la lesión existe
    $sqlCheck = "SELECT * FROM tlesiones WHERE id = ?";
    $existing = $db->selectOne($sqlCheck, [$id]);

    if (!$existing) {
        debugPrint("❌ [Lesiones] Lesión $id no encontrada");
        ResponseHelper::error('❌ La lesión no existe', 404);
    }

    // Convertir fechas si vienen en formato ISO8601
    if ($fechainicio && strpos($fechainicio, 'T') !== false) {
        $fechainicio = date('Y-m-d', strtotime($fechainicio));
    }
    if ($fechafin && strpos($fechafin, 'T') !== false) {
        $fechafin = date('Y-m-d', strtotime($fechafin));
    }

    // Construir SQL dinámicamente según los campos presentes
    $updateFields = [];
    $params = [];

    if ($fechainicio !== null) {
        $updateFields[] = "fechainicio = ?";
        $params[] = $fechainicio;
    }
    if ($fechafin !== null) {
        $updateFields[] = "fechafin = ?";
        $params[] = $fechafin;
    }
    if ($tipo !== null) {
        $updateFields[] = "tipo = ?";
        $params[] = $tipo;
    }
    if ($lesion !== null) {
        $updateFields[] = "lesion = ?";
        $params[] = $lesion;
    }
    if ($duracion !== null) {
        $updateFields[] = "duracion = ?";
        $params[] = $duracion;
    }

    $params[] = $id;

    $sql = "UPDATE tlesiones SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $result = $db->update($sql, $params);

    if ($result) {
        // Invalidar cache
        $cache->forget("lesiones_jugador_{$idjugador}");

        debugPrint("✅ [Lesiones] Lesión actualizada correctamente");
        ResponseHelper::success(['success' => true]);
    } else {
        debugPrint("❌ [Lesiones] Error al actualizar lesión");
        ResponseHelper::error('❌ Error al actualizar lesión', 500);
    }
}

/**
 * Eliminar una lesión
 * POST /lesiones.php?action=deletelesion
 * Body: {"id": 123, "idjugador": 123}
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function deleteLesion($db, $cache, $userData) {
    // Validar permisos de escritura
    $writableRoles = [1, 2, 3, 10, 12, 13];

    // Obtener el rol del usuario desde vroles
    $uid = $userData['uid'] ?? null;
    $idtemporada = $userData['idtemporada'] ?? null;

    if (!$uid) {
        ResponseHelper::error('❌ UID de usuario no encontrado', 400);
    }

    $sqlRol = "SELECT tipo FROM vroles WHERE uid = ? AND idtemporada = ? AND selectedrol = 1 LIMIT 1";
    $rolData = $db->selectOne($sqlRol, [$uid, $idtemporada]);
    $userRole = $rolData['tipo'] ?? 0;

    debugPrint("🔐 [Lesiones] Usuario con ROL: $userRole");

    if (!in_array($userRole, $writableRoles)) {
        ResponseHelper::error('🔒 No tienes permisos para eliminar lesiones', 403);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    $idjugador = $input['idjugador'] ?? null;

    if (!$id) {
        ResponseHelper::error('❌ id es requerido', 400);
    }

    debugPrint("🗑️ [Lesiones] Eliminando lesión $id");

    $sql = "DELETE FROM tlesiones WHERE id = ?";
    $result = $db->delete($sql, [$id]);

    if ($result) {
        // Invalidar cache solo si tenemos el idjugador
        if ($idjugador) {
            $cache->forget("lesiones_jugador_{$idjugador}");
        }

        debugPrint("✅ [Lesiones] Lesión eliminada correctamente");
        ResponseHelper::success(['success' => true]);
    } else {
        debugPrint("❌ [Lesiones] Error al eliminar lesión");
        ResponseHelper::error('❌ Error al eliminar lesión', 500);
    }
}
