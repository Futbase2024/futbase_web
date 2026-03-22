<?php
/**
 * Endpoint seguro para gestión de equipos
 * Usa PDO, autenticación Firebase JWT y caché
 */

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Responder con éxito
 */
function respondSuccess($data, $message = 'OK') {
    header('Content-Type: application/json');
    echo json_encode([
        'success' => true,
        'data' => $data,
        'message' => $message
    ]);
    exit;
}

/**
 * Responder con error
 */
function respondError($message, $code = 400) {
    header('Content-Type: application/json');
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message
    ]);
    exit;
}

try {
    $auth = new FirebaseAuthMiddleware();
    $db = Database::getInstance();
    $cache = new CacheManager(300);

    // Autenticar con Firebase y aplicar rate limit
    $userData = $auth->protect(100, 60);

    // Obtener acción
    $action = $_GET['action'] ?? $_POST['action'] ?? null;

    if (!$action) {
        respondError('Acción no especificada', 400);
    }

    // Enrutar a la función correspondiente
    switch ($action) {
        case 'getTeam':
            getTeam($auth, $db, $cache);
            break;
        case 'getTeams':
            getTeams($auth, $db, $cache);
            break;
        case 'getTeamsByClub':
            getTeamsByClub($auth, $db, $cache);
            break;
        case 'createTeam':
        case 'create':
            createTeam($auth, $db, $cache);
            break;
        case 'updateTeam':
        case 'update':
            updateTeam($auth, $db, $cache);
            break;
        case 'deleteTeam':
        case 'delete':
            deleteTeam($auth, $db, $cache);
            break;
        case 'updateInformePDF':
            updateInformePDF($auth, $db, $cache);
            break;
        case 'version':
            respondSuccess([
                'version' => '1.0.0',
                'date' => '2025-10-24',
                'endpoints' => ['getTeam', 'getTeams', 'getTeamsByClub', 'createTeam', 'updateTeam', 'deleteTeam', 'updateInformePDF']
            ]);
            break;
        default:
            respondError('Acción no válida', 400);
    }

} catch (Exception $e) {
    error_log("❌ [Equipos] Error: " . $e->getMessage());
    respondError($e->getMessage(), 500);
}

/**
 * Obtiene un equipo por ID
 */
function getTeam($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $idEquipo = $_GET['idequipo'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idEquipo || !$idTemporada) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "equipo_{$idEquipo}_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = "SELECT * FROM vequipos WHERE id = ? AND idtemporada = ? LIMIT 1";
    $equipo = $db->selectOne($sql, [$idEquipo, $idTemporada]);

    if (!$equipo) {
        respondError('Equipo no encontrado', 404);
    }

    $cache->set($cacheKey, $equipo, 300);
    respondSuccess($equipo);
}

/**
 * Obtiene todos los equipos de una temporada
 */
function getTeams($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idTemporada) {
        respondError('Parámetro inválido: idtemporada es requerido', 400);
    }

    $cacheKey = "equipos_temporada_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = "SELECT * FROM vequipos WHERE idtemporada = ? ORDER BY Categoria ASC, Equipo ASC";
    $equipos = $db->select($sql, [$idTemporada]);

    $cache->set($cacheKey, $equipos, 600);
    respondSuccess($equipos);
}

/**
 * Obtiene equipos por club y temporada
 */
function getTeamsByClub($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $idTemporada = $_GET['idtemporada'] ?? null;
    $idClub = $_GET['idclub'] ?? null;

    if (!$idTemporada || !$idClub) {
        respondError('Parámetros inválidos: idtemporada e idclub son requeridos', 400);
    }

    $cacheKey = "equipos_club_{$idClub}_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = "SELECT * FROM vequipos WHERE idclub = ? AND idtemporada = ? ORDER BY Categoria ASC, Equipo ASC";
    $equipos = $db->select($sql, [$idClub, $idTemporada]);

    $cache->set($cacheKey, $equipos, 600);
    respondSuccess($equipos);
}

/**
 * Crea un nuevo equipo
 */
function createTeam($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos', 400);
    }

    // Validar campos requeridos
    $required = ['idclub', 'idcategoria', 'idtemporada', 'equipo'];
    foreach ($required as $field) {
        if (!isset($input[$field])) {
            respondError("Campo requerido: $field", 400);
        }
    }

    $idclub = $input['idclub'];
    $idcategoria = $input['idcategoria'];
    $idtemporada = $input['idtemporada'];
    $equipo = $input['equipo'];
    $ncorto = $input['ncorto'] ?? '';
    $titulares = $input['titulares'] ?? 0;
    $minutos = $input['minutos'] ?? 0;

    // Verificar si ya existe
    $checkSql = "SELECT COUNT(*) as count FROM tequipos WHERE idclub = ? AND equipo = ? AND idtemporada = ?";
    $exists = $db->selectOne($checkSql, [$idclub, $equipo, $idtemporada]);

    if ($exists && $exists['count'] > 0) {
        respondError('Ya existe un equipo con estas características', 400);
    }

    // Iniciar transacción
    $db->beginTransaction();

    try {
        // Insertar equipo
        $sql = "INSERT INTO tequipos (idclub, idcategoria, idtemporada, equipo, ncorto, titulares, minutos)
                VALUES (?, ?, ?, ?, ?, ?, ?)";

        $idEquipo = $db->insert($sql, [
            $idclub,
            $idcategoria,
            $idtemporada,
            $equipo,
            $ncorto,
            $titulares,
            $minutos
        ]);

        $db->commit();

        // Limpiar caché
        $cache->clear("equipos_*");

        // Obtener el equipo creado
        $equipoCreado = $db->selectOne("SELECT * FROM vequipos WHERE id = ?", [$idEquipo]);

        respondSuccess($equipoCreado);

    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en createTeam: " . $e->getMessage());
        respondError('Error al crear el equipo: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualiza un equipo existente
 */
function updateTeam($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id'])) {
        respondError('Datos inválidos', 400);
    }

    $idEquipo = $input['id'];

    if (!$idEquipo) {
        respondError('ID de equipo inválido', 400);
    }

    // Verificar que existe
    $checkSql = "SELECT id FROM tequipos WHERE id = ? LIMIT 1";
    $exists = $db->selectOne($checkSql, [$idEquipo]);

    if (!$exists) {
        respondError('Equipo no encontrado', 404);
    }

    $sql = "UPDATE tequipos SET
            equipo = ?,
            ncorto = ?,
            titulares = ?,
            minutos = ?,
            idcategoria = ?
            WHERE id = ?";

    $db->execute($sql, [
        $input['equipo'] ?? '',
        $input['ncorto'] ?? '',
        $input['titulares'] ?? 0,
        $input['minutos'] ?? 0,
        $input['idcategoria'] ?? 0,
        $idEquipo
    ]);

    // Limpiar caché relacionada con equipos
    $cache->clear("equipos_*");
    $cache->clear("equipo_*");

    // Devolver el equipo actualizado
    $equipoActualizado = $db->selectOne("SELECT * FROM vequipos WHERE id = ?", [$idEquipo]);
    respondSuccess($equipoActualizado);
}

/**
 * Elimina un equipo
 */
function deleteTeam($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);
    $idEquipo = $input['id'] ?? $_GET['id'] ?? null;

    if (!$idEquipo) {
        respondError('ID inválido', 400);
    }

    // Verificar que existe
    $equipo = $db->selectOne("SELECT * FROM vequipos WHERE id = ? LIMIT 1", [$idEquipo]);

    if (!$equipo) {
        respondError('Equipo no encontrado', 404);
    }

    $db->beginTransaction();

    try {
        // Eliminar equipo (hard delete)
        $sql = "DELETE FROM tequipos WHERE id = ?";
        $affected = $db->execute($sql, [$idEquipo]);

        $db->commit();

        // Limpiar caché
        $cache->clear("equipos_*");
        $cache->clear("equipo_{$idEquipo}_*");

        respondSuccess([
            'success' => true,
            'affected_rows' => $affected
        ]);

    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en deleteTeam: " . $e->getMessage());
        respondError('Error al eliminar el equipo', 500);
    }
}

/**
 * Actualiza el informe PDF de un equipo
 */
function updateInformePDF($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos', 400);
    }

    $idEquipo = $input['idequipo'] ?? null;
    $informe = $input['informe'] ?? '';

    if (!$idEquipo) {
        respondError('ID de equipo es requerido', 400);
    }

    // Verificar que existe
    $equipo = $db->selectOne("SELECT id FROM tequipos WHERE id = ? LIMIT 1", [$idEquipo]);

    if (!$equipo) {
        respondError('Equipo no encontrado', 404);
    }

    $db->beginTransaction();

    try {
        $sql = "UPDATE tequipos SET informe = ? WHERE id = ?";
        $affected = $db->execute($sql, [$informe, $idEquipo]);

        $db->commit();

        // Limpiar caché
        $cache->clear("equipos_*");
        $cache->clear("equipo_{$idEquipo}_*");

        respondSuccess([
            'success' => true,
            'affected_rows' => $affected
        ]);

    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en updateInformePDF: " . $e->getMessage());
        respondError('Error al actualizar el informe', 500);
    }
}
