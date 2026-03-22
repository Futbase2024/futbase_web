<?php
/**
 * Endpoint: talla_peso.php
 * Gestión de tallas y pesos de jugadores
 */

// Configuración de errores
error_reporting(E_ALL);
ini_set('display_errors', 0);
ob_start();

// Manejador de errores fatales
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
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

// Manejador de excepciones
set_exception_handler(function($exception) {
    if (ob_get_level() > 0) {
        ob_clean();
    }
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Excepción: ' . $exception->getMessage(),
        'file' => basename($exception->getFile()),
        'line' => $exception->getLine()
    ]);
    exit;
});

// Manejador de errores no fatales
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $auth = new FirebaseAuthMiddleware();
    $db = Database::getInstance();
    $cache = new CacheManager();

    // Verificar autenticación
    $userData = $auth->authenticate();

    // Determinar action
    $action = $_GET['action'] ?? $_POST['action'] ?? null;

    if (!$action) {
        ResponseHelper::error('Acción no especificada', 400);
    }

    switch ($action) {
        case 'getTallaPesoJugador':
            handleGetTallaPesoJugador($db, $cache, $userData);
            break;

        case 'getTallaPesoByTemporada':
            handleGetTallaPesoByTemporada($db, $cache, $userData);
            break;

        case 'createTallaje':
            handleCreateTallaje($db, $cache, $userData);
            break;

        case 'updateTallaje':
            handleUpdateTallaje($db, $cache, $userData);
            break;

        case 'deleteTallaje':
            handleDeleteTallaje($db, $cache, $userData);
            break;

        case 'deleteTallajeById':
            handleDeleteTallajeById($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en talla_peso.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener todos los registros de talla/peso de un jugador
 */
function handleGetTallaPesoJugador($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idJugador = $_GET['idJugador'] ?? null;
    if (!$idJugador) {
        ResponseHelper::error('idJugador es obligatorio', 400);
    }

    $cacheKey = "talla_peso_jugador_{$idJugador}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Registros obtenidos (cache)');
    }

    $sql = "SELECT * FROM ttallajepeso WHERE idjugador = ? ORDER BY fecha DESC";
    $registros = $db->select($sql, [$idJugador]);

    $cache->set($cacheKey, $registros, 300);
    ResponseHelper::success($registros, 'Registros obtenidos');
}

/**
 * GET: Obtener registros de talla/peso por jugador y temporada
 */
function handleGetTallaPesoByTemporada($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idJugador = $_GET['idJugador'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idJugador || !$idTemporada) {
        ResponseHelper::error('idJugador e idTemporada son obligatorios', 400);
    }

    $cacheKey = "talla_peso_jugador_{$idJugador}_temporada_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Registros obtenidos (cache)');
    }

    // Obtener fechas de la temporada
    $sqlTemporada = "SELECT fechaini, fechafin FROM ttemporadas WHERE id = ? LIMIT 1";
    $temporada = $db->selectOne($sqlTemporada, [$idTemporada]);

    if (!$temporada) {
        ResponseHelper::error('Temporada no encontrada', 404);
    }

    $sql = "SELECT * FROM ttallajepeso
            WHERE idjugador = ?
            AND fecha BETWEEN ? AND ?
            ORDER BY fecha DESC";

    $registros = $db->select($sql, [
        $idJugador,
        $temporada['fechaini'],
        $temporada['fechafin']
    ]);

    $cache->set($cacheKey, $registros, 300);
    ResponseHelper::success($registros, 'Registros obtenidos');
}

/**
 * POST: Crear nuevo registro de talla/peso
 */
function handleCreateTallaje($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $idjugador = $input['idjugador'] ?? null;
    $peso = $input['peso'] ?? null;
    $altura = $input['altura'] ?? null;
    $fecha = $input['fecha'] ?? date('Y-m-d');

    if (!$idjugador || $peso === null || $altura === null) {
        ResponseHelper::error('idjugador, peso y altura son obligatorios', 400);
    }

    // Calcular métricas
    $alturaMetros = $altura / 100;
    $imc = $alturaMetros > 0 ? round($peso / ($alturaMetros * $alturaMetros), 2) : 0;
    $pesoideal = round(22 * ($alturaMetros * $alturaMetros), 2);
    $difp = round($peso - $pesoideal, 2);

    // Obtener apodo del jugador
    $sqlJugador = "SELECT apodo FROM tjugadores WHERE id = ? LIMIT 1";
    $jugador = $db->selectOne($sqlJugador, [$idjugador]);
    $apodo = $jugador['apodo'] ?? '';

    // Obtener último registro para calcular diferencias
    $sqlUltimo = "SELECT peso, altura FROM ttallajepeso WHERE idjugador = ? ORDER BY fecha DESC LIMIT 1";
    $ultimo = $db->selectOne($sqlUltimo, [$idjugador]);

    $difa = 0;
    if ($ultimo) {
        $difa = $altura - ($ultimo['altura'] ?? 0);
    }

    $sql = "INSERT INTO ttallajepeso (idjugador, apodo, peso, altura, fecha, difp, difa, imc, pesoideal)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $tallajeId = $db->insert($sql, [
        $idjugador,
        $apodo,
        $peso,
        $altura,
        $fecha,
        $difp,
        $difa,
        $imc,
        $pesoideal
    ]);

    if (!$tallajeId) {
        ResponseHelper::error('Error al crear el registro', 500);
    }

    // Obtener el registro creado
    $sqlTallaje = "SELECT * FROM ttallajepeso WHERE id = ? LIMIT 1";
    $tallajeCreado = $db->selectOne($sqlTallaje, [$tallajeId]);

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success([
        'tallaje' => $tallajeCreado,
        'message' => 'Registro creado correctamente'
    ], 'Registro creado');
}

/**
 * POST: Actualizar registro de talla/peso
 */
function handleUpdateTallaje($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    $peso = $input['peso'] ?? null;
    $altura = $input['altura'] ?? null;
    $fecha = $input['fecha'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID del registro es obligatorio', 400);
    }

    // Recalcular métricas si se proporcionan peso o altura
    $updates = [];
    $params = [];

    if ($peso !== null) {
        $updates[] = "peso = ?";
        $params[] = $peso;
    }

    if ($altura !== null) {
        $updates[] = "altura = ?";
        $params[] = $altura;
    }

    if ($fecha !== null) {
        $updates[] = "fecha = ?";
        $params[] = $fecha;
    }

    // Si cambiaron peso o altura, recalcular métricas
    if ($peso !== null || $altura !== null) {
        $sqlActual = "SELECT peso, altura FROM ttallajepeso WHERE id = ? LIMIT 1";
        $actual = $db->selectOne($sqlActual, [$id]);

        $pesoFinal = $peso ?? $actual['peso'];
        $alturaFinal = $altura ?? $actual['altura'];

        $alturaMetros = $alturaFinal / 100;
        $imc = $alturaMetros > 0 ? round($pesoFinal / ($alturaMetros * $alturaMetros), 2) : 0;
        $pesoideal = round(22 * ($alturaMetros * $alturaMetros), 2);
        $difp = round($pesoFinal - $pesoideal, 2);

        $updates[] = "imc = ?";
        $params[] = $imc;
        $updates[] = "pesoideal = ?";
        $params[] = $pesoideal;
        $updates[] = "difp = ?";
        $params[] = $difp;
    }

    if (empty($updates)) {
        ResponseHelper::error('No hay datos para actualizar', 400);
    }

    $params[] = $id;
    $sql = "UPDATE ttallajepeso SET " . implode(", ", $updates) . " WHERE id = ?";

    $rowsAffected = $db->execute($sql, $params);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Registro no encontrado o sin cambios', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Registro actualizado correctamente');
}

/**
 * POST: Eliminar registro de talla/peso
 */
function handleDeleteTallaje($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID del registro es obligatorio', 400);
    }

    $sql = "DELETE FROM ttallajepeso WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$id]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Registro no encontrado', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Registro eliminado correctamente');
}

/**
 * POST: Eliminar registro de talla/peso por ID
 */
function handleDeleteTallajeById($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID del registro es obligatorio', 400);
    }

    $sql = "DELETE FROM ttallajepeso WHERE id = ?";
    $rowsAffected = $db->execute($sql, [$id]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Registro no encontrado', 404);
    }

    // Invalidar cache
    $cache->clear();

    ResponseHelper::success(null, 'Registro eliminado correctamente');
}
