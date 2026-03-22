<?php
/**
 * Endpoint de Estadios
 * Gestión de estadios/campos de fútbol
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Obtiene todos los estadios
 */
function getEstadios($db, $cache, $userData) {
    $cacheKey = "estadios_all";

    $estadios = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM vcampos ORDER BY campo";
        return $db->select($sql, []);
    });

    respondSuccess(['estadios' => $estadios]);
}

/**
 * Obtiene un estadio por ID
 */
function getEstadioById($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('id es requerido', 400);
    }

    $cacheKey = "estadio_id_{$id}";

    $estadio = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM vcampos WHERE id = ?";
        $result = $db->select($sql, [$id]);
        return $result[0] ?? null;
    });

    if ($estadio) {
        respondSuccess(['estadio' => $estadio]);
    } else {
        respondError('Estadio no encontrado', 404);
    }
}

/**
 * Obtiene un estadio por nombre
 */
function getEstadioByName($db, $cache, $userData) {
    $nombre = $_GET['nombre'] ?? null;

    if (!$nombre) {
        respondError('nombre es requerido', 400);
    }

    $cacheKey = "estadio_nombre_" . md5($nombre);

    $estadio = $cache->remember($cacheKey, function() use ($db, $nombre) {
        $sql = "SELECT * FROM vcampos WHERE campo = ?";
        $result = $db->select($sql, [$nombre]);
        return $result[0] ?? null;
    });

    if ($estadio) {
        respondSuccess(['estadio' => $estadio]);
    } else {
        respondError('Estadio no encontrado', 404);
    }
}

/**
 * Crea un nuevo estadio
 */
function createEstadio($db, $cache, $userData) {
    $rawInput = file_get_contents('php://input');
    $data = json_decode($rawInput, true);

    $campo = $data['campo'] ?? null;
    $direccion = $data['direccion'] ?? null;
    $cesped = $data['cesped'] ?? 'ARTIFICIAL';
    $tipo = $data['tipo'] ?? 'FUTBOL 11';
    $idprovincia = Validator::validateInt($data['idprovincia'] ?? null);
    $idlocalidad = Validator::validateInt($data['idlocalidad'] ?? null);

    if (!$campo || !$idprovincia || !$idlocalidad) {
        respondError('campo, idprovincia e idlocalidad son requeridos', 400);
    }

    // Verificar permisos: Admin, Coordinador, Staff
    $rolesPermitidos = [10, 12, 3, 13];
    if (!in_array($userData['tipo'], $rolesPermitidos)) {
        respondError('No tienes permisos para crear estadios', 403);
    }

    // Verificar si ya existe
    $sqlCheck = "SELECT * FROM tcampos
                 WHERE campo = ? AND idprovincia = ? AND idlocalidad = ?";
    $existing = $db->select($sqlCheck, [$campo, $idprovincia, $idlocalidad]);

    if (!empty($existing)) {
        respondError('Ya existe un estadio con estas características', 409);
    }

    // Crear el estadio
    $sql = "INSERT INTO tcampos (campo, direccion, cesped, tipo, idprovincia, idlocalidad)
            VALUES (?, ?, ?, ?, ?, ?)";

    $result = $db->query($sql, [$campo, $direccion, $cesped, $tipo, $idprovincia, $idlocalidad]);

    if ($result) {
        // Limpiar caché
        $cache->delete("estadios_all");

        // Obtener el estadio creado
        $sqlGet = "SELECT * FROM vcampos WHERE campo = ? ORDER BY id DESC LIMIT 1";
        $estadio = $db->select($sqlGet, [$campo]);

        if (!empty($estadio)) {
            respondSuccess(['estadio' => $estadio[0]]);
        } else {
            respondError('Error al obtener el estadio creado', 500);
        }
    } else {
        respondError('Error al crear el estadio', 500);
    }
}

// Ejecución principal
$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché

try {
    $userData = $middleware->protect(100, 50, true);

    $action = $_GET['action'] ?? null;
    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;
    }

    if (!$action) {
        respondError('Acción no especificada', 400);
    }

    // Normalizar action a lowercase
    $action = strtolower($action);

    switch ($action) {
        case 'getestadios':
            getEstadios($db, $cache, $userData);
            break;

        case 'getestadiobyid':
            getEstadioById($db, $cache, $userData);
            break;

        case 'getestadiobyname':
            getEstadioByName($db, $cache, $userData);
            break;

        case 'createestadio':
            createEstadio($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
            break;
    }

} catch (Exception $e) {
    respondError('Error del servidor: ' . $e->getMessage(), 500);
}
