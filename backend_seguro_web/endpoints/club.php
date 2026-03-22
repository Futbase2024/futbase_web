<?php
/**
 * Endpoint seguro para gestión de clubes
 * Usa PDO, autenticación Firebase JWT y caché
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
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

// Obtener acción
$action = $_GET['action'] ?? '';

// Enrutamiento de acciones
try {
    switch ($action) {
        case 'getClub':
            getClub($db, $cache, $auth);
            break;

        case 'getClubs':
            getClubs($db, $cache, $auth);
            break;

        case 'saveClub':
            saveClub($db, $cache, $auth);
            break;

        case 'updateClub':
            updateClub($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("❌ [Club] Error: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene un club por ID
 */
function getClub($db, $cache, $auth) {
    // Autenticar (100 req/60s)
    $userData = $auth->protect(100, 60);

    // Validar parámetros
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idclub || !$idtemporada) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "club_{$idclub}_{$idtemporada}";

    // Intentar obtener del caché
    $club = $cache->remember($cacheKey, function() use ($db, $idclub) {
        $sql = "SELECT * FROM vclubes WHERE id = ? LIMIT 1";
        return $db->selectOne($sql, [$idclub]);
    }, 300);

    if (!$club) {
        respondNotFound('Club no encontrado');
    }

    respondSuccess($club);
}

/**
 * Obtiene todos los clubes de una temporada
 */
function getClubs($db, $cache, $auth) {
    // Autenticar (100 req/60s)
    $userData = $auth->protect(100, 60);

    // Validar parámetros
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idtemporada) {
        respondError('Parámetro idtemporada es requerido', 400);
    }

    $cacheKey = "clubs_temporada_{$idtemporada}";

    // Intentar obtener del caché
    $clubs = $cache->remember($cacheKey, function() use ($db) {
        // Obtener todos los clubes activos
        // Nota: La vista vclubes no tiene filtro por temporada,
        // se puede ajustar si existe una relación específica
        $sql = "SELECT * FROM vclubes WHERE validado = 1 ORDER BY club ASC";
        return $db->select($sql, []);
    }, 300);

    respondSuccess($clubs);
}

/**
 * Guarda/crea un nuevo club
 */
function saveClub($db, $cache, $auth) {
    // Autenticar con rate limit más restrictivo (50 req/60s)
    $userData = $auth->protect(50, 60);

    // Obtener datos del body
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos no válidos', 400);
    }

    // Validar campos requeridos
    $required = ['club', 'email'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            respondError("Campo requerido: $field", 400);
        }
    }

    // Verificar si el club ya existe
    $sqlCheck = 'SELECT id FROM vclubes WHERE club = ? LIMIT 1';
    $existing = $db->selectOne($sqlCheck, [$input['club']]);

    if ($existing) {
        respondError('El club ya existe', 409);
    }

    // Preparar datos con valores por defecto
    $validado = isset($input['validado']) ? (int)$input['validado'] : 0;
    $asociado = isset($input['asociado']) ? (int)$input['asociado'] : 0;
    $idlocalidad = Validator::validateInt($input['idlocalidad'] ?? null);
    $idprovincia = Validator::validateInt($input['idprovincia'] ?? null);
    $idcampo = Validator::validateInt($input['idcampo'] ?? null);

    // Insertar el club
    $sql = 'INSERT INTO tclubes (
                club, codigo, cif, domicilio, cpostal, email, telefono, web,
                ncorto, validado, asociado, idlocalidad, idprovincia, idcampo
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';

    $params = [
        $input['club'],
        $input['codigo'] ?? '',
        $input['cif'] ?? '',
        $input['domicilio'] ?? '',
        $input['cpostal'] ?? '',
        $input['email'],
        $input['telefono'] ?? '',
        $input['web'] ?? '',
        $input['ncorto'] ?? '',
        $validado,
        $asociado,
        $idlocalidad,
        $idprovincia,
        $idcampo
    ];

    try {
        $clubId = $db->insert($sql, $params);

        // Invalidar caché de clubes
        $cache->clear('clubs_temporada_*');

        respondSuccess([
            'id' => $clubId,
            'message' => 'Club creado correctamente'
        ], 'Club creado correctamente');

    } catch (Exception $e) {
        error_log("❌ [Club] Error al crear club: " . $e->getMessage());
        respondInternalError('Error al crear el club');
    }
}

/**
 * Actualiza un club existente
 */
function updateClub($db, $cache, $auth) {
    // Autenticar con rate limit más restrictivo (50 req/60s)
    $userData = $auth->protect(50, 60);

    // Obtener datos del body
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos no válidos o ID no proporcionado', 400);
    }

    $idclub = Validator::validateInt($input['id']);
    if (!$idclub) {
        respondError('ID de club inválido', 400);
    }

    // Verificar que el club existe
    $sqlCheck = 'SELECT * FROM vclubes WHERE id = ? LIMIT 1';
    $existing = $db->selectOne($sqlCheck, [$idclub]);

    if (!$existing) {
        respondNotFound('El club no existe');
    }

    // Preparar datos para actualización
    $validado = isset($input['validado']) ? (int)$input['validado'] : $existing['validado'];
    $asociado = isset($input['asociado']) ? (int)$input['asociado'] : $existing['asociado'];
    $idlocalidad = isset($input['idlocalidad']) ? Validator::validateInt($input['idlocalidad']) : $existing['idlocalidad'];
    $idprovincia = isset($input['idprovincia']) ? Validator::validateInt($input['idprovincia']) : $existing['idprovincia'];
    $idcampo = isset($input['idcampo']) ? Validator::validateInt($input['idcampo']) : $existing['idcampo'];

    // Actualizar el club
    $sql = 'UPDATE tclubes SET
                club = ?,
                codigo = ?,
                cif = ?,
                domicilio = ?,
                cpostal = ?,
                email = ?,
                telefono = ?,
                web = ?,
                ncorto = ?,
                validado = ?,
                asociado = ?,
                idlocalidad = ?,
                idprovincia = ?,
                idcampo = ?
            WHERE id = ?';

    $params = [
        $input['club'] ?? $existing['club'],
        $input['codigo'] ?? $existing['codigo'],
        $input['cif'] ?? $existing['cif'],
        $input['domicilio'] ?? $existing['domicilio'],
        $input['cpostal'] ?? $existing['cpostal'],
        $input['email'] ?? $existing['email'],
        $input['telefono'] ?? $existing['telefono'],
        $input['web'] ?? $existing['web'],
        $input['ncorto'] ?? $existing['ncorto'],
        $validado,
        $asociado,
        $idlocalidad,
        $idprovincia,
        $idcampo,
        $idclub
    ];

    try {
        $db->execute($sql, $params);

        // Invalidar caché
        $cache->clear("club_{$idclub}_*");
        $cache->clear('clubs_temporada_*');

        respondSuccess([
            'id' => $idclub,
            'message' => 'Club actualizado correctamente'
        ], 'Club actualizado correctamente');

    } catch (Exception $e) {
        error_log("❌ [Club] Error al actualizar club: " . $e->getMessage());
        respondInternalError('Error al actualizar el club');
    }
}
