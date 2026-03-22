<?php
/**
 * Endpoint seguro para gestión de jugadores
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
    $cache = new CacheManager(300); // Caché de 5 minutos

    // Obtener acción
    $action = $_GET['action'] ?? $_POST['action'] ?? null;

    if (!$action) {
        respondError('Acción no especificada', 400);
    }

    // Enrutar a la función correspondiente
    switch ($action) {
        case 'getPlayer':
            getPlayer($auth, $db, $cache);
            break;
        case 'getPlayersByClub':
            getPlayersByClub($auth, $db, $cache);
            break;
        case 'getPlayersSinEquipo':
            getPlayersSinEquipo($auth, $db, $cache);
            break;
        case 'createPlayer':
            createPlayer($auth, $db, $cache);
            break;
        case 'updatePlayer':
            updatePlayer($auth, $db, $cache);
            break;
        case 'updatePlayerConvocados':
            updatePlayerConvocados($auth, $db, $cache);
            break;
        case 'saveNote':
            saveNote($auth, $db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }

} catch (Exception $e) {
    error_log("❌ [Jugadores] Error: " . $e->getMessage());
    respondError($e->getMessage(), 500);
}

/**
 * Obtiene un jugador por ID
 */
function getPlayer($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $id = $_GET['id'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$id || !$idTemporada) {
        respondError('Parámetros incompletos', 400);
    }

    $cacheKey = "player_{$id}_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = 'SELECT * FROM vjugadores WHERE id = ? AND idtemporada = ?';
    $player = $db->selectOne($sql, [$id, $idTemporada]);

    if (!$player) {
        respondError('Jugador no encontrado', 404);
    }

    $cache->set($cacheKey, $player, 300);
    respondSuccess($player);
}

/**
 * Obtiene jugadores por club
 */
function getPlayersByClub($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;
    $active = $_GET['active'] ?? null;
    $idTempInicial = $_GET['idtempinicial'] ?? null;

    if (!$idClub || !$idTemporada || $active === null || !$idTempInicial) {
        respondError('Parámetros incompletos', 400);
    }

    $cacheKey = "players_club_{$idClub}_{$idTemporada}_{$active}_{$idTempInicial}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    if ($idTempInicial == $idTemporada) {
        $sql = 'SELECT * FROM vjugadores WHERE idclub = ? AND idtemporada = ? AND visible = 1 AND activo = ? ORDER BY nombre, apellidos';
        $params = [$idClub, $idTemporada, $active];
    } else {
        $sql = 'SELECT * FROM vjugadores WHERE idclub = ? AND idtemporada = ? ORDER BY nombre, apellidos';
        $params = [$idClub, $idTemporada];
    }

    $players = $db->select($sql, $params);

    $cache->set($cacheKey, $players, 300);
    respondSuccess($players);
}

/**
 * Obtiene jugadores sin equipo
 */
function getPlayersSinEquipo($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $idTemporada = $_GET['idtemporada'] ?? null;

    if (!$idTemporada) {
        respondError('Parámetros incompletos', 400);
    }

    $cacheKey = "players_sin_equipo_{$idTemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = 'SELECT v.* FROM vjugadores v
            LEFT JOIN (
                SELECT id, MAX(idtemporada) AS ultima_temporada
                FROM vjugadores
                WHERE idtemporada != ?
                GROUP BY id
            ) ultima_temporada_tbl ON v.id = ultima_temporada_tbl.id
            WHERE (v.idtemporada = ? AND v.activo = 0)
            OR (
                v.idtemporada != ?
                AND v.idtemporada = ultima_temporada_tbl.ultima_temporada
                AND v.id NOT IN (
                    SELECT id FROM vjugadores WHERE idtemporada = ?
                )
            )';

    $players = $db->select($sql, [$idTemporada, $idTemporada, $idTemporada, $idTemporada]);

    $cache->set($cacheKey, $players, 300);
    respondSuccess($players);
}

/**
 * Crea un nuevo jugador
 */
function createPlayer($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos no válidos', 400);
    }

    // Validar campos requeridos
    $required = ['nombre', 'apellidos', 'idclub', 'idequipo', 'idcategoria', 'idposicion',
                 'idpiedominante', 'idestado', 'idtemporada'];

    foreach ($required as $field) {
        if (!isset($input[$field])) {
            respondError("Campo requerido: $field", 400);
        }
    }

    // Verificar si el jugador ya existe
    $sql = 'SELECT * FROM vjugadores WHERE nombre = ? AND apellidos = ? AND idclub = ? AND idequipo = ?';
    $existing = $db->selectOne($sql, [
        $input['nombre'],
        $input['apellidos'],
        $input['idclub'],
        $input['idequipo']
    ]);

    if ($existing) {
        respondError('El jugador ya existe', 409);
    }

    // Crear jugador
    $fechaalta = date('d-m-Y');
    $foto = $input['foto'] ?? '';

    $sql = 'INSERT INTO tjugadores (
                idcategoria, idclub, idequipo, idposicion, idpiedominante, idestado,
                idprovincia, idlocalidad, idtipocuota, idtemporada, nombre, apellidos,
                apodo, email, telefono, foto, fechanacimiento, fechaalta, peso, altura,
                domicilio, dni, emailtutor1, emailtutor2, tutor1, tutor2, recmedico, fecharecmedico,
                ficha
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';

    $params = [
        $input['idcategoria'],
        $input['idclub'],
        $input['idequipo'],
        $input['idposicion'],
        $input['idpiedominante'],
        $input['idestado'],
        $input['idprovincia'] ?? null,
        $input['idlocalidad'] ?? null,
        $input['idtemporada'],
        $input['nombre'],
        $input['apellidos'],
        $input['apodo'] ?? '',
        $input['email'] ?? '',
        $input['telefono'] ?? '',
        $foto,
        $input['fechanacimiento'] ?? null,
        $fechaalta,
        $input['peso'] ?? null,
        $input['altura'] ?? null,
        $input['domicilio'] ?? '',
        $input['dni'] ?? '',
        $input['emailtutor1'] ?? '',
        $input['emailtutor2'] ?? '',
        $input['tutor1'] ?? '',
        $input['tutor2'] ?? '',
        $input['recmedico'] ?? 0,
        $input['fecharecmedico'] ?? null,
        $input['fichafederativa'] ?? ''
    ];

    $playerId = $db->insert($sql, $params);

    // Invalidar caché
    $cache->clear("players_club_{$input['idclub']}_{$input['idtemporada']}_*");

    respondSuccess(['id' => $playerId, 'message' => 'Jugador creado correctamente']);
}

/**
 * Actualiza un jugador
 */
function updatePlayer($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    error_log("📝 [updatePlayer] Input recibido: " . json_encode($input));

    if (!$input || !isset($input['id'])) {
        respondError('Datos no válidos', 400);
    }

    // Verificar que el jugador existe
    $sql = 'SELECT * FROM vjugadores WHERE id = ?';
    $existing = $db->selectOne($sql, [$input['id']]);

    if (!$existing) {
        respondError('El jugador no existe', 404);
    }

    error_log("📝 [updatePlayer] Jugador existente: " . json_encode($existing));

    // Buscar IDs de tutores si se proporcionaron emails
    $idTutor1 = 0;
    $idTutor2 = 0;
    $temporadaActiva = $input['temporadaActiva'] ?? $existing['idtemporada'];

    if (!empty($input['emailtutor1'])) {
        $sql = 'SELECT id FROM tusuarios WHERE email = ? AND permisos = 4 AND idtemporada = ?';
        $tutor1 = $db->selectOne($sql, [$input['emailtutor1'], $temporadaActiva]);
        if ($tutor1) {
            $idTutor1 = $tutor1['id'];
        }
    }

    if (!empty($input['emailtutor2'])) {
        $sql = 'SELECT id FROM tusuarios WHERE email = ? AND permisos = 4 AND idtemporada = ?';
        $tutor2 = $db->selectOne($sql, [$input['emailtutor2'], $temporadaActiva]);
        if ($tutor2) {
            $idTutor2 = $tutor2['id'];
        }
    }

    // Actualizar jugador
    $sql = 'UPDATE tjugadores SET
                idcategoria = ?, idclub = ?, idequipo = ?, idposicion = ?,
                idpiedominante = ?, idestado = ?, idtutor1 = ?, idtutor2 = ?,
                activo = ?, idtemporada = ?, idprovincia = ?, idlocalidad = ?,
                nombre = ?, apellidos = ?, apodo = ?, idtipocuota = ?,
                email = ?, telefono = ?, convocado = ?, conventreno = ?,
                peso = ?, altura = ?, domicilio = ?, foto = ?,
                fechanacimiento = ?, recmedico = ?, fecharecmedico = ?, dni = ?,
                emailtutor1 = ?, emailtutor2 = ?, tutor1 = ?, tutor2 = ?,
                ficha = ?
            WHERE id = ?';

    $params = [
        $input['idcategoria'] ?? $existing['idcategoria'],
        $input['idclub'] ?? $existing['idclub'],
        $input['idequipo'] ?? $existing['idequipo'],
        $input['idposicion'] ?? $existing['idposicion'],
        $input['idpiedominante'] ?? $existing['idpiedominante'],
        $input['idestado'] ?? $existing['idestado'],
        $idTutor1,
        $idTutor2,
        $input['activo'] ?? $existing['activo'],
        $input['idtemporada'] ?? $existing['idtemporada'],
        $input['idprovincia'] ?? $existing['idprovincia'],
        $input['idlocalidad'] ?? $existing['idlocalidad'],
        $input['nombre'] ?? $existing['nombre'],
        $input['apellidos'] ?? $existing['apellidos'],
        $input['apodo'] ?? $existing['apodo'],
        $input['idtipocuota'] ?? $existing['idtipocuota'],
        $input['email'] ?? $existing['email'],
        $input['telefono'] ?? $existing['telefono'],
        $input['convocado'] ?? $existing['convocado'],
        $input['conventreno'] ?? $existing['conventreno'],
        $input['peso'] ?? $existing['peso'],
        $input['altura'] ?? $existing['altura'],
        $input['domicilio'] ?? $existing['domicilio'],
        $input['foto'] ?? $existing['foto'],
        $input['fechanacimiento'] ?? $existing['fechanacimiento'],
        $input['recmedico'] ?? $existing['recmedico'],
        $input['fecharecmedico'] ?? $existing['fecharecmedico'],
        $input['dni'] ?? $existing['dni'],
        $input['emailtutor1'] ?? '',
        $input['emailtutor2'] ?? '',
        $input['tutor1'] ?? '',
        $input['tutor2'] ?? '',
        $input['fichafederativa'] ?? $existing['ficha'],
        $input['id']
    ];

    $rowsAffected = $db->execute($sql, $params);

    error_log("📝 [updatePlayer] UPDATE tjugadores - Filas afectadas: $rowsAffected");
    error_log("📝 [updatePlayer] SQL ejecutado: $sql");
    error_log("📝 [updatePlayer] Parámetros: " . json_encode($params));

    // Actualizar estadísticas del jugador
    $sql = 'UPDATE testadisticasjugador SET idclub = ?, idequipo = ?
            WHERE idjugador = ? AND idtemporada = ? AND visible = 1';
    $rowsStats = $db->execute($sql, [
        $input['idclub'] ?? $existing['idclub'],
        $input['idequipo'] ?? $existing['idequipo'],
        $input['id'],
        $temporadaActiva
    ]);

    error_log("📝 [updatePlayer] UPDATE testadisticasjugador - Filas afectadas: $rowsStats");

    // Invalidar TODO el caché de jugadores
    // Nota: clear() con patrón no funciona porque las claves se hashean con SHA256
    // Por ahora, limpiamos toda la caché para asegurar que se actualice
    $cache->clear();

    error_log("📝 [updatePlayer] ✅ Caché completamente invalidada, enviando respuesta");

    respondSuccess(['message' => 'Jugador actualizado correctamente']);
}

/**
 * Actualiza convocados de un partido
 */
function updatePlayerConvocados($auth, $db, $cache) {
    $userData = $auth->protect(50, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['idclub']) || !isset($input['idequipo']) || !isset($input['idTemporada'])) {
        respondError('Datos no válidos', 400);
    }

    // Obtener jugadores del equipo
    $sql = 'SELECT id FROM vjugadores WHERE idclub = ? AND idequipo = ? AND activo = 1 AND visible = 1 AND idtemporada = ?';
    $players = $db->select($sql, [$input['idclub'], $input['idequipo'], $input['idTemporada']]);

    if (empty($players)) {
        respondSuccess(['message' => 'No hay jugadores para actualizar']);
    }

    // Actualizar convocado = 0 para todos
    $sql = 'UPDATE tjugadores SET convocado = 0 WHERE id = ?';
    foreach ($players as $player) {
        $db->execute($sql, [$player['id']]);
    }

    // Invalidar caché
    $cache->clear("players_club_{$input['idclub']}_*");

    respondSuccess(['message' => 'Convocados actualizados correctamente']);
}

/**
 * Guarda nota de un jugador
 */
function saveNote($auth, $db, $cache) {
    $userData = $auth->protect(100, 60);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['id']) || !isset($input['nota'])) {
        respondError('Datos no válidos', 400);
    }

    // Verificar que el jugador existe
    $sql = 'SELECT * FROM vjugadores WHERE id = ?';
    $existing = $db->selectOne($sql, [$input['id']]);

    if (!$existing) {
        respondError('El jugador no existe', 404);
    }

    // Actualizar nota
    $sql = 'UPDATE tjugadores SET nota = ? WHERE id = ?';
    $db->execute($sql, [$input['nota'], $input['id']]);

    // Invalidar caché
    $cache->clear("player_{$input['id']}_*");

    respondSuccess(['message' => 'Nota guardada correctamente']);
}
