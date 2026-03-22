<?php
/**
 * Endpoint seguro para gestión de Partidos
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

    // Intentar obtener action de varias fuentes
    $action = $_GET['action'] ?? null;

    // Si no está en GET, intentar leer del body JSON
    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;
    }

    if (!$action) {
        respondError('Acción no especificada', 400);
    }

    // Enrutar a la función correspondiente
    switch ($action) {
        case 'getByTemporada':
            getPartidosByTemporada($auth, $db, $cache);
            break;
        case 'getPartidosByTemporada':
            getPartidosByTemporadaAll($auth, $db, $cache);
            break;
        case 'getById':
            getPartidoById($auth, $db, $cache);
            break;
        case 'getPartidosByTemporadaAndFecha':
            getPartidosByTemporadaAndFecha($auth, $db, $cache);
            break;
        case 'getPartidosByFechaEnVivo':
            getPartidosByFechaEnVivo($auth, $db, $cache);
            break;
        case 'refreshPartidosLive':
            refreshPartidosLive($auth, $db, $cache);
            break;
        case 'savePartido':
            savePartido($auth, $db, $cache);
            break;
        case 'editarObservacionesConvocatoriaMatch':
            editarObservacionesConvocatoriaMatch($auth, $db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }

} catch (Exception $e) {
    error_log("❌ [Partidos] Error: " . $e->getMessage());
    respondError($e->getMessage(), 500);
}

/**
 * Obtiene partidos por temporada y club
 */
function getPartidosByTemporada($auth, $db, $cache) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);

    if (!$idtemporada || !$idclub) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "partidos_temporada_{$idtemporada}_{$idclub}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = "SELECT * FROM vpartido
            WHERE idtemporada = ?
            AND idclub = ?
            ORDER BY fecha DESC";

    $partidos = $db->select($sql, [$idtemporada, $idclub]);

    $cache->set($cacheKey, $partidos, 300);
    respondSuccess($partidos);
}

/**
 * Obtiene todos los partidos de una temporada
 */
function getPartidosByTemporadaAll($auth, $db, $cache) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idtemporada) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "partidos_temporada_all_{$idtemporada}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = "SELECT * FROM vpartido
            WHERE idtemporada = ?
            ORDER BY fecha DESC";

    $partidos = $db->select($sql, [$idtemporada]);

    $cache->set($cacheKey, $partidos, 300);
    respondSuccess($partidos);
}

/**
 * Obtiene un partido por ID
 */
function getPartidoById($auth, $db, $cache) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('ID inválido', 400);
    }

    $cacheKey = "partido_{$id}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    $sql = "SELECT * FROM vpartido WHERE id = ? LIMIT 1";
    $partido = $db->selectOne($sql, [$id]);

    if (!$partido) {
        respondError('Partido no encontrado', 404);
    }

    $cache->set($cacheKey, $partido, 300);
    respondSuccess($partido);
}

/**
 * Obtiene partidos por temporada y fecha
 */
function getPartidosByTemporadaAndFecha($auth, $db, $cache) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $fecha = $_GET['fecha'] ?? null;
    $idclub = Validator::validateInt($_GET['idclub'] ?? 0);

    if (!$idtemporada || !$fecha) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "partidos_temporada_{$idtemporada}_fecha_{$fecha}_club_{$idclub}";
    $cached = $cache->get($cacheKey);

    if ($cached !== null) {
        respondSuccess($cached);
    }

    if ($idclub == 0) {
        $sql = "SELECT * FROM vpartido
                WHERE idtemporada = ? AND fecha = ?
                ORDER BY fecha DESC";
        $partidos = $db->select($sql, [$idtemporada, $fecha]);
    } else {
        $sql = "SELECT * FROM vpartido
                WHERE idtemporada = ? AND fecha = ? AND idclub = ?
                ORDER BY fecha DESC";
        $partidos = $db->select($sql, [$idtemporada, $fecha, $idclub]);
    }

    $cache->set($cacheKey, $partidos, 120); // Caché de 2 minutos
    respondSuccess($partidos);
}

/**
 * Obtiene partidos en vivo por fecha
 */
function getPartidosByFechaEnVivo($auth, $db, $cache) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? 0);
    $fecha = $_GET['fecha'] ?? null;

    if (!$idtemporada || !$fecha) {
        respondError('Parámetros inválidos', 400);
    }

    // No usar caché para partidos en vivo
    if ($idclub == 0) {
        $sql = "SELECT * FROM vpartido
                WHERE idtemporada = ? AND fecha = ?
                ORDER BY fecha DESC";
        $partidos = $db->select($sql, [$idtemporada, $fecha]);
    } else {
        $sql = "SELECT * FROM vpartido
                WHERE idtemporada = ? AND fecha = ? AND idclub = ?
                ORDER BY fecha DESC";
        $partidos = $db->select($sql, [$idtemporada, $fecha, $idclub]);
    }

    respondSuccess($partidos);
}

/**
 * Refresca los partidos en vivo
 */
function refreshPartidosLive($auth, $db, $cache) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idtemporada) {
        respondError('Parámetros inválidos', 400);
    }

    // No usar caché para partidos en vivo (datos dinámicos)
    $sql = "SELECT * FROM vpartido
            WHERE idtemporada = ? AND finalizado = 0 AND minuto > 0
            ORDER BY fecha DESC";
    $partidos = $db->select($sql, [$idtemporada]);

    respondSuccess($partidos);
}

/**
 * Guarda un nuevo partido con toda la lógica de validación y convocatorias
 */
function savePartido($auth, $db, $cache) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos', 400);
    }

    // Validar campos requeridos
    $required = ['idequipo', 'fecha', 'idjornada', 'idtemporada', 'idclub'];
    foreach ($required as $field) {
        if (!isset($input[$field])) {
            respondError("Campo requerido: $field", 400);
        }
    }

    $idequipo = Validator::validateInt($input['idequipo']);
    $fecha = $input['fecha'];
    $idjornada = Validator::validateInt($input['idjornada']);
    $idtemporada = Validator::validateInt($input['idtemporada']);
    $idclub = Validator::validateInt($input['idclub']);

    // Validar que no exista un partido duplicado
    $checkSql = "SELECT COUNT(*) as count FROM tpartidos
                 WHERE idequipo = ? AND fecha = ? AND idjornada = ?
                 AND idtemporada = ? AND idclub = ?";
    $exists = $db->selectOne($checkSql, [$idequipo, $fecha, $idjornada, $idtemporada, $idclub]);

    if ($exists && $exists['count'] > 0) {
        respondError('Ya existe un partido igual para este equipo en esta fecha y jornada', 400);
    }

    // Iniciar transacción
    $db->beginTransaction();

    try {
        // Insertar el partido
        $horaconvocatoria = $input['horaconvocatoria'] ?? '';
        $hora = $input['hora'] ?? '00:00';

        $insertSql = "INSERT INTO tpartidos
            (idjornada, idtemporada, idcategoria, idequipo, idclub, idrival, rival,
             idlugar, fecha, goles, golesrival, finalizado, minuto, hora, horaconvocatoria,
             casafuera, escudorival, sistema, minutosporparte, numeropartes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, '00:00', ?, ?, ?, ?, ?, ?, ?)";

        $idPartido = $db->insert($insertSql, [
            $idjornada,
            $idtemporada,
            $input['idcategoria'] ?? 0,
            $idequipo,
            $idclub,
            $input['idrival'] ?? 0,
            $input['rival'] ?? '',
            $input['idlugar'] ?? 0,
            $fecha,
            $hora,
            $horaconvocatoria,
            $input['casafuera'] ?? 0,
            $input['escudorival'] ?? '',
            $input['sistema'] ?? '',
            $input['minutosporparte'] ?? 0,
            $input['numeropartes'] ?? 2
        ]);

        // Obtener jugadores activos del equipo para crear convocatorias
        $jugadoresSql = "SELECT * FROM vjugadores
                        WHERE idclub = ? AND idequipo = ?
                        AND activo = 1 AND visible = 1 AND idtemporada = ?";
        $jugadores = $db->select($jugadoresSql, [$idclub, $idequipo, $idtemporada]);

        // Crear convocatorias para cada jugador
        foreach ($jugadores as $jugador) {
            $idjugador = $jugador['id'];

            // Resetear estado de convocatoria del jugador
            $db->execute("UPDATE tjugadores SET convocado = 0 WHERE id = ?", [$idjugador]);

            // Determinar idmotivo basado en idestado
            $idmotivo = 0;
            if (isset($jugador['idestado'])) {
                if ($jugador['idestado'] == 1) $idmotivo = 0;
                else if ($jugador['idestado'] == 2) $idmotivo = 4;
                else if ($jugador['idestado'] == 3) $idmotivo = 5;
            }

            // Verificar que no existe ya una convocatoria
            $checkConvSql = "SELECT COUNT(*) as count FROM tconvpartidos
                           WHERE idpartido = ? AND idjugador = ? AND idclub = ?
                           AND idequipo = ? AND idtemporada = ?";
            $existsConv = $db->selectOne($checkConvSql, [$idPartido, $idjugador, $idclub, $idequipo, $idtemporada]);

            if ($existsConv['count'] == 0) {
                $insertConvSql = "INSERT INTO tconvpartidos
                    (idpartido, idjugador, idclub, idequipo, idtemporada, convocado, idmotivo, observaciones, dorsal)
                    VALUES (?, ?, ?, ?, ?, 0, ?, '', ?)";

                $db->insert($insertConvSql, [
                    $idPartido,
                    $idjugador,
                    $idclub,
                    $idequipo,
                    $idtemporada,
                    $idmotivo,
                    $jugador['dorsal'] ?? 0
                ]);
            }
        }

        $db->commit();

        // Limpiar caché
        $cache->clear("partidos_*");

        // Obtener el partido creado para devolverlo
        $partidoCreado = $db->selectOne("SELECT * FROM vpartido WHERE id = ?", [$idPartido]);

        respondSuccess($partidoCreado);

    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en savePartido: " . $e->getMessage());
        respondError('Error al guardar el partido: ' . $e->getMessage(), 500);
    }
}

/**
 * Edita las observaciones de la convocatoria de un partido
 */
function editarObservacionesConvocatoriaMatch($auth, $db, $cache) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idPartido = Validator::validateInt($input['idPartido'] ?? null);
    $observaciones = $input['observaciones'] ?? '';

    if (!$idPartido) {
        respondError('Parámetros inválidos', 400);
    }

    $sql = "UPDATE tpartidos SET obsconvocatoria = ? WHERE id = ?";
    $affected = $db->execute($sql, [$observaciones, $idPartido]);

    // Limpiar caché
    $cache->clear("partidos_*");
    $cache->delete("partido_{$idPartido}");

    respondSuccess([
        'success' => true,
        'affected_rows' => $affected
    ]);
}
