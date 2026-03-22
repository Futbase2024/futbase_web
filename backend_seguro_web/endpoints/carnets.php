<?php
/**
 * Endpoint de Gestión de Carnets
 * Operaciones CRUD de carnets de socios y tipos de carnets
 *
 * @author FutBase Team
 * @version 2.0 - Backend Seguro
 * @date 2025-10-25
 */

// PRIMERO: Configurar manejo de errores ANTES de cualquier otra cosa
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('html_errors', '0'); // Deshabilitar formato HTML en errores
error_reporting(E_ALL);

// SEGUNDO: Configurar error handler para convertir warnings en excepciones
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    // No lanzar excepción para E_DEPRECATED y E_USER_DEPRECATED
    if (in_array($errno, [E_DEPRECATED, E_USER_DEPRECATED])) {
        return false;
    }

    // Registrar el error
    error_log("PHP Error [$errno]: $errstr in $errfile on line $errline");

    // Lanzar excepción para que pueda ser capturada por try-catch
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

// Capturar errores fatales (E_ERROR, E_PARSE, etc.)
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        // Limpiar cualquier output buffer
        while (ob_get_level() > 0) {
            ob_end_clean();
        }

        // Registrar el error fatal
        error_log("❌ PHP Fatal Error: {$error['message']} in {$error['file']} on line {$error['line']}");

        // Responder con JSON
        header('Content-Type: application/json; charset=utf-8');
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error fatal del servidor',
            'error' => $error['message'],
            'file' => basename($error['file']),
            'line' => $error['line']
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
});

// TERCERO: Iniciar output buffering para capturar cualquier warning/notice
ob_start();

// CUARTO: Set header ANTES de cualquier output
header('Content-Type: application/json; charset=utf-8');

// QUINTO: Incluir archivos con manejo de errores
try {
    require_once __DIR__ . '/../core/Database.php';
    require_once __DIR__ . '/../core/CacheManager.php';
    require_once __DIR__ . '/../core/RateLimiter.php';
    require_once __DIR__ . '/../core/Validator.php';
    require_once __DIR__ . '/../core/ResponseHelper.php';
    require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
    require_once __DIR__ . '/../config/cors.php';
} catch (Throwable $e) {
    // Si hay error al cargar archivos, limpiar buffer y responder
    ob_end_clean();
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error al inicializar el sistema',
        'error' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Manejar preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Rate Limiting
$clientIP = RateLimiter::getClientIP();
$rateLimiter = new RateLimiter(100, 60); // 100 req/min para lecturas

if (!$rateLimiter->isAllowed($clientIP)) {
    respondError('Demasiadas peticiones. Intenta de nuevo más tarde.', 429);
}

// Autenticación Firebase
$middleware = new FirebaseAuthMiddleware();
$userData = $middleware->authenticate();

// Conexión a base de datos y caché
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos por defecto

// Router de acciones
$action = $_GET['action'] ?? $_POST['action'] ?? null;

switch ($action) {
    // === CARNETS ===
    case 'getCarnetById':
        getCarnetById($db, $cache, $userData);
        break;
    case 'getCarnetsByClub':
        getCarnetsByClub($db, $cache, $userData);
        break;
    case 'getCarnetByNSoc':
        getCarnetByNSoc($db, $cache, $userData);
        break;
    case 'getCarnetsByJugadorTutores':
        getCarnetsByJugadorTutores($db, $cache, $userData);
        break;
    case 'createCarnet':
        $writeLimiter = new RateLimiter(50, 60); // 50 req/min para escrituras
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        createCarnet($db, $cache, $userData);
        break;
    case 'updateCarnet':
        $writeLimiter = new RateLimiter(50, 60);
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        updateCarnet($db, $cache, $userData);
        break;
    case 'deleteCarnet':
        $writeLimiter = new RateLimiter(50, 60);
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        deleteCarnet($db, $cache, $userData);
        break;
    case 'getNextNumeroSocio':
        getNextNumeroSocio($db, $cache, $userData);
        break;
    case 'deleteCarnetAndRenumber':
        $writeLimiter = new RateLimiter(50, 60);
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        deleteCarnetAndRenumber($db, $cache, $userData);
        break;

    // === TIPOS DE CARNETS ===
    case 'getTipoCarnetById':
        getTipoCarnetById($db, $cache, $userData);
        break;
    case 'getTipoCarnetsByClub':
        getTipoCarnetsByClub($db, $cache, $userData);
        break;
    case 'createTipoCarnet':
        $writeLimiter = new RateLimiter(50, 60);
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        createTipoCarnet($db, $cache, $userData);
        break;
    case 'updateTipoCarnet':
        $writeLimiter = new RateLimiter(50, 60);
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        updateTipoCarnet($db, $cache, $userData);
        break;
    case 'deleteTipoCarnet':
        $writeLimiter = new RateLimiter(50, 60);
        if (!$writeLimiter->isAllowed($clientIP)) {
            respondError('Demasiadas peticiones de escritura', 429);
        }
        deleteTipoCarnet($db, $cache, $userData);
        break;

    default:
        respondError('Acción no válida', 400);
        break;
}

// ========================================
// OPERACIONES DE CARNETS
// ========================================

/**
 * Obtener carnet por ID
 */
function getCarnetById($db, $cache, $userData) {
    $idcarnet = Validator::validateInt($_GET['idcarnet'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idcarnet || !$idtemporada) {
        respondError('Parámetros inválidos: idcarnet e idtemporada son requeridos', 400);
    }

    $cacheKey = "carnet_{$idcarnet}_{$idtemporada}";

    $carnet = $cache->remember($cacheKey, function() use ($db, $idcarnet, $idtemporada) {
        $sql = "SELECT * FROM vcarnets WHERE id = ? AND idtemporada = ? LIMIT 1";
        return $db->selectOne($sql, [$idcarnet, $idtemporada]);
    }, 300);

    if (!$carnet) {
        respondSuccess(['carnet' => ['id' => 0]]);
    }

    respondSuccess(['carnet' => $carnet]);
}

/**
 * Obtener carnets por club
 */
function getCarnetsByClub($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);

    if (!$idtemporada || !$idclub) {
        respondError('Parámetros inválidos: idtemporada e idclub son requeridos', 400);
    }

    $cacheKey = "carnets_club_{$idclub}_{$idtemporada}";

    $carnets = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada) {
        $sql = "SELECT * FROM vcarnets WHERE idclub = ? AND idtemporada = ? ORDER BY id ASC";
        return $db->select($sql, [$idclub, $idtemporada]);
    }, 300);

    respondSuccess(['carnets' => $carnets ?? []]);
}

/**
 * Obtener carnet por número de socio
 */
function getCarnetByNSoc($db, $cache, $userData) {
    $nsoc = Validator::validateString($_GET['nsoc'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$nsoc || !$idclub || !$idtemporada) {
        respondError('Parámetros inválidos: nsoc, idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "carnet_nsoc_{$nsoc}_{$idclub}_{$idtemporada}";

    $carnet = $cache->remember($cacheKey, function() use ($db, $nsoc, $idclub, $idtemporada) {
        $sql = "SELECT * FROM vcarnets WHERE nsocio = ? AND idclub = ? AND idtemporada = ? LIMIT 1";
        return $db->selectOne($sql, [$nsoc, $idclub, $idtemporada]);
    }, 300);

    if (!$carnet) {
        respondSuccess(['carnet' => ['id' => 0]]);
    }

    respondSuccess(['carnet' => $carnet]);
}

/**
 * Obtener carnets de jugador y tutores
 */
function getCarnetsByJugadorTutores($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idjugador = Validator::validateInt($_GET['idjugador'] ?? null);
    $idtutor1 = Validator::validateInt($_GET['idtutor1'] ?? null);
    $idtutor2 = Validator::validateInt($_GET['idtutor2'] ?? null);

    if (!$idtemporada) {
        respondError('Parámetro inválido: idtemporada es requerido', 400);
    }

    // Construir query dinámica
    $params = [$idtemporada];
    $sql = "SELECT * FROM vcarnets WHERE idtemporada = ?";

    $userConditions = [];

    if ($idjugador && $idjugador != 0) {
        $userConditions[] = "iduser = ?";
        $params[] = $idjugador;
    }

    if ($idtutor1 && $idtutor1 != 0) {
        $userConditions[] = "iduser = ?";
        $params[] = $idtutor1;
    }

    if ($idtutor2 && $idtutor2 != 0) {
        $userConditions[] = "iduser = ?";
        $params[] = $idtutor2;
    }

    if (!empty($userConditions)) {
        $sql .= " AND (" . implode(" OR ", $userConditions) . ")";
    }

    $sql .= " ORDER BY id ASC";

    $carnets = $db->select($sql, $params);

    respondSuccess(['carnets' => $carnets ?? []]);
}

/**
 * Crear carnet
 */
function createCarnet($db, $cache, $userData) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            respondError('Datos inválidos en el body', 400);
        }

        $iduser = Validator::validateInt($input['iduser'] ?? null);
        $idrol = Validator::validateInt($input['idrol'] ?? 0);
        $idclub = Validator::validateInt($input['idclub'] ?? null);
        $idtemporada = Validator::validateInt($input['idtemporada'] ?? null);
        $color = Validator::validateString($input['color'] ?? '');
        $nsocio = Validator::validateString($input['nsocio'] ?? '');
        $nombre = Validator::validateString($input['nombre'] ?? '');
        $qr = Validator::validateString($input['qr'] ?? '');
        $categoria = Validator::validateString($input['categoria'] ?? '');
        $urlimagen = Validator::validateString($input['urlimagen'] ?? '');
        $email = Validator::validateString($input['email'] ?? '');

        if (!$iduser || !$idclub || !$idtemporada) {
            respondError('Faltan datos requeridos: iduser, idclub, idtemporada', 400);
        }

        $db->beginTransaction();

        $sql = "INSERT INTO tcarnets (iduser, idrol, idclub, idtemporada, color, nsocio, nombre, qr, categoria, urlimagen, email)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $insertId = $db->insert($sql, [
            $iduser,
            $idrol,
            $idclub,
            $idtemporada,
            $color,
            $nsocio,
            $nombre,
            $qr,
            $categoria,
            $urlimagen,
            $email
        ]);

        if (!$insertId) {
            $db->rollBack();
            respondError('Error al crear el carnet', 500);
        }

        $db->commit();

        // Invalidar caché
        $cache->forget("carnets_club_{$idclub}_{$idtemporada}");

        respondSuccess([
            'success' => true,
            'id' => $insertId,
            'message' => 'Carnet creado exitosamente'
        ]);

    } catch (Exception $e) {
        // Intentar rollback solo si hay una transacción activa
        try {
            if ($db->getConnection()->inTransaction()) {
                $db->rollBack();
            }
        } catch (Exception $rollbackError) {
            error_log("[Carnets] Error en rollback: " . $rollbackError->getMessage());
        }

        error_log("[Carnets] ❌ Error en createCarnet: " . $e->getMessage());
        error_log("[Carnets] Stack trace: " . $e->getTraceAsString());
        respondError('Error al crear el carnet: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar carnet
 */
function updateCarnet($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos en el body', 400);
    }

    $id = Validator::validateInt($input['id'] ?? null);
    $nsocio = Validator::validateString($input['nsocio'] ?? null);
    $qr = Validator::validateString($input['qr'] ?? null);

    if (!$id || $nsocio === null) {
        respondError('Faltan datos requeridos: id, nsocio', 400);
    }

    try {
        // Obtener datos del carnet antes de actualizar para invalidar caché
        $carnetData = $db->selectOne("SELECT idclub, idtemporada, iduser FROM tcarnets WHERE id = ?", [$id]);

        if (!$carnetData) {
            respondError('Carnet no encontrado', 404);
        }

        $sql = "UPDATE tcarnets SET nsocio = ?, qr = ? WHERE id = ?";
        $result = $db->update($sql, [$nsocio, $qr, $id]);

        if (!$result) {
            respondError('Error al actualizar el carnet', 500);
        }

        // Invalidar caché
        $cache->forget("carnet_{$id}_{$carnetData['idtemporada']}");
        $cache->forget("carnets_club_{$carnetData['idclub']}_{$carnetData['idtemporada']}");
        $cache->forget("carnet_nsoc_{$nsocio}_{$carnetData['idclub']}_{$carnetData['idtemporada']}");

        respondSuccess([
            'success' => true,
            'message' => 'Carnet actualizado exitosamente'
        ]);

    } catch (Exception $e) {
        error_log("[Carnets] Error en updateCarnet: " . $e->getMessage());
        respondError('Error al actualizar el carnet: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar carnet
 */
function deleteCarnet($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos en el body', 400);
    }

    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('Parámetro inválido: id es requerido', 400);
    }

    try {
        // Obtener datos del carnet antes de eliminar para invalidar caché
        $carnetData = $db->selectOne("SELECT idclub, idtemporada, iduser, nsocio FROM tcarnets WHERE id = ?", [$id]);

        if (!$carnetData) {
            respondError('Carnet no encontrado', 404);
        }

        $sql = "DELETE FROM tcarnets WHERE id = ?";
        $result = $db->delete($sql, [$id]);

        if (!$result) {
            respondError('Error al eliminar el carnet', 500);
        }

        // Invalidar caché
        $cache->forget("carnet_{$id}_{$carnetData['idtemporada']}");
        $cache->forget("carnets_club_{$carnetData['idclub']}_{$carnetData['idtemporada']}");
        $cache->forget("carnet_nsoc_{$carnetData['nsocio']}_{$carnetData['idclub']}_{$carnetData['idtemporada']}");

        respondSuccess([
            'success' => true,
            'message' => 'Carnet eliminado exitosamente'
        ]);

    } catch (Exception $e) {
        error_log("[Carnets] Error en deleteCarnet: " . $e->getMessage());
        respondError('Error al eliminar el carnet: ' . $e->getMessage(), 500);
    }
}

// ========================================
// OPERACIONES DE TIPOS DE CARNETS
// ========================================

/**
 * Obtener tipo de carnet por ID
 */
function getTipoCarnetById($db, $cache, $userData) {
    $idcarnet = Validator::validateInt($_GET['idcarnet'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idcarnet || !$idtemporada) {
        respondError('Parámetros inválidos: idcarnet e idtemporada son requeridos', 400);
    }

    $cacheKey = "tipo_carnet_{$idcarnet}_{$idtemporada}";

    $carnet = $cache->remember($cacheKey, function() use ($db, $idcarnet, $idtemporada) {
        $sql = "SELECT * FROM tcarnetsimg WHERE id = ? AND idtemporada = ? LIMIT 1";
        return $db->selectOne($sql, [$idcarnet, $idtemporada]);
    }, 300);

    if (!$carnet) {
        respondSuccess(['carnet' => ['id' => 0]]);
    }

    respondSuccess(['carnet' => $carnet]);
}

/**
 * Obtener tipos de carnets por club
 */
function getTipoCarnetsByClub($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);

    if (!$idtemporada || !$idclub) {
        respondError('Parámetros inválidos: idtemporada e idclub son requeridos', 400);
    }

    $cacheKey = "tipos_carnets_club_{$idclub}_{$idtemporada}";

    $carnets = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada) {
        $sql = "SELECT * FROM tcarnetsimg WHERE idclub = ? AND idtemporada = ? ORDER BY tipo ASC";
        return $db->select($sql, [$idclub, $idtemporada]);
    }, 300);

    respondSuccess(['carnets' => $carnets ?? []]);
}

/**
 * Crear tipo de carnet
 */
function createTipoCarnet($db, $cache, $userData) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            respondError('Datos inválidos en el body', 400);
        }

        $idclub = Validator::validateInt($input['idclub'] ?? null);
        $tipo = Validator::validateString($input['tipo'] ?? null);
        $urlimagen = Validator::validateString($input['urlimagen'] ?? '');
        $idtemporada = Validator::validateInt($input['idtemporada'] ?? null);
        $colorletras = Validator::validateString($input['colorletras'] ?? '');

        if (!$idclub || !$tipo || !$idtemporada) {
            respondError('Faltan datos requeridos: idclub, tipo, idtemporada', 400);
        }

        $sql = "INSERT INTO tcarnetsimg (idclub, tipo, urlimagen, idtemporada, colorletras)
                VALUES (?, ?, ?, ?, ?)";

        $insertId = $db->insert($sql, [$idclub, $tipo, $urlimagen, $idtemporada, $colorletras]);

        if (!$insertId) {
            error_log("[Carnets] Insert no devolvió ID para tipo de carnet");
            respondError('Error al crear el tipo de carnet: no se obtuvo ID', 500);
        }

        // Invalidar caché
        $cache->forget("tipos_carnets_club_{$idclub}_{$idtemporada}");

        respondSuccess([
            'success' => true,
            'id' => $insertId,
            'message' => 'Tipo de carnet creado exitosamente'
        ]);

    } catch (Exception $e) {
        error_log("[Carnets] ❌ Error en createTipoCarnet: " . $e->getMessage());
        error_log("[Carnets] Stack trace: " . $e->getTraceAsString());
        respondError('Error al crear el tipo de carnet: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualizar tipo de carnet
 */
function updateTipoCarnet($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos en el body', 400);
    }

    $id = Validator::validateInt($input['id'] ?? null);
    $tipo = Validator::validateString($input['tipo'] ?? null);
    $urlimagen = Validator::validateString($input['urlimagen'] ?? null);
    $colorletras = Validator::validateString($input['colorletras'] ?? null);

    if (!$id || !$tipo || $urlimagen === null || $colorletras === null) {
        respondError('Faltan datos requeridos: id, tipo, urlimagen, colorletras', 400);
    }

    try {
        // Obtener datos antes de actualizar
        $carnetData = $db->selectOne("SELECT idclub, idtemporada FROM tcarnetsimg WHERE id = ?", [$id]);

        if (!$carnetData) {
            respondError('Tipo de carnet no encontrado', 404);
        }

        $sql = "UPDATE tcarnetsimg SET tipo = ?, urlimagen = ?, colorletras = ? WHERE id = ?";
        $result = $db->update($sql, [$tipo, $urlimagen, $colorletras, $id]);

        if (!$result) {
            respondError('Error al actualizar el tipo de carnet', 500);
        }

        // Invalidar caché
        $cache->forget("tipo_carnet_{$id}_{$carnetData['idtemporada']}");
        $cache->forget("tipos_carnets_club_{$carnetData['idclub']}_{$carnetData['idtemporada']}");

        respondSuccess([
            'success' => true,
            'message' => 'Tipo de carnet actualizado exitosamente'
        ]);

    } catch (Exception $e) {
        error_log("[Carnets] Error en updateTipoCarnet: " . $e->getMessage());
        respondError('Error al actualizar el tipo de carnet: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar tipo de carnet
 */
function deleteTipoCarnet($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        respondError('Datos inválidos en el body', 400);
    }

    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('Parámetro inválido: id es requerido', 400);
    }

    try {
        // Obtener datos antes de eliminar
        $carnetData = $db->selectOne("SELECT idclub, idtemporada FROM tcarnetsimg WHERE id = ?", [$id]);

        if (!$carnetData) {
            respondError('Tipo de carnet no encontrado', 404);
        }

        $sql = "DELETE FROM tcarnetsimg WHERE id = ?";
        $result = $db->delete($sql, [$id]);

        if (!$result) {
            respondError('Error al eliminar el tipo de carnet', 500);
        }

        // Invalidar caché
        $cache->forget("tipo_carnet_{$id}_{$carnetData['idtemporada']}");
        $cache->forget("tipos_carnets_club_{$carnetData['idclub']}_{$carnetData['idtemporada']}");

        respondSuccess([
            'success' => true,
            'message' => 'Tipo de carnet eliminado exitosamente'
        ]);

    } catch (Exception $e) {
        error_log("[Carnets] Error en deleteTipoCarnet: " . $e->getMessage());
        respondError('Error al eliminar el tipo de carnet: ' . $e->getMessage(), 500);
    }
}

/**
 * Obtener siguiente número de socio disponible para un tipo
 * Solo para club 163, tipo 4 (tutores): rango 1001-1999
 */
function getNextNumeroSocio($db, $cache, $userData) {
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idrol = Validator::validateInt($_GET['idrol'] ?? null);

    if (!$idclub || !$idtemporada || !$idrol) {
        respondError('Parámetros inválidos: idclub, idtemporada e idrol son requeridos', 400);
    }

    // Solo aplicar para club 163
    if ($idclub != 163) {
        respondError('Esta funcionalidad solo está disponible para el club 163', 403);
    }

    // Configuración de rangos (solo tipo 4 por ahora)
    $ranges = [
        4 => ['start' => 1000, 'end' => 1999, 'name' => 'Tutores'],
    ];

    if (!isset($ranges[$idrol])) {
        respondError("No hay rango configurado para este tipo de carnet", 400);
    }

    $range = $ranges[$idrol];

    try {
        // Buscar números ya usados en el rango
        $sql = "SELECT nsocio
                FROM tcarnets
                WHERE idclub = ?
                  AND idtemporada = ?
                  AND idrol = ?
                  AND CAST(nsocio AS UNSIGNED) BETWEEN ? AND ?
                ORDER BY CAST(nsocio AS UNSIGNED) ASC";

        $carnets = $db->select($sql, [$idclub, $idtemporada, $idrol, $range['start'], $range['end']]);

        $usados = [];
        foreach ($carnets as $carnet) {
            $usados[] = (int)$carnet['nsocio'];
        }

        // Encontrar primer hueco disponible
        $siguiente = null;
        for ($i = $range['start']; $i <= $range['end']; $i++) {
            if (!in_array($i, $usados)) {
                $siguiente = $i;
                break;
            }
        }

        if ($siguiente === null) {
            respondError("Rango completo para este tipo de carnet ({$range['start']}-{$range['end']})", 409);
        }

        respondSuccess([
            'numero' => $siguiente,
            'rango' => $range,
            'usados' => count($usados),
            'disponibles' => ($range['end'] - $range['start'] + 1) - count($usados)
        ]);

    } catch (Exception $e) {
        error_log("[Carnets] Error en getNextNumeroSocio: " . $e->getMessage());
        respondError('Error al obtener siguiente número: ' . $e->getMessage(), 500);
    }
}

/**
 * Eliminar carnet y renumerar los siguientes del mismo tipo
 * Solo para club 163, tipo 4 (tutores)
 */
function deleteCarnetAndRenumber($db, $cache, $userData) {
    $body = json_decode(file_get_contents('php://input'), true);

    $id = Validator::validateInt($body['id'] ?? null);
    $idclub = Validator::validateInt($body['idclub'] ?? null);
    $idtemporada = Validator::validateInt($body['idtemporada'] ?? null);

    if (!$id || !$idclub || !$idtemporada) {
        respondError('Parámetros inválidos: id, idclub e idtemporada son requeridos', 400);
    }

    // Solo aplicar para club 163
    if ($idclub != 163) {
        respondError('Esta funcionalidad solo está disponible para el club 163', 403);
    }

    $db->beginTransaction();

    try {
        // 1. Obtener info del carnet a borrar
        $sql = "SELECT nsocio, idrol, iduser
                FROM tcarnets
                WHERE id = ? AND idclub = ? AND idtemporada = ?";
        $carnet = $db->selectOne($sql, [$id, $idclub, $idtemporada]);

        if (!$carnet) {
            respondError("Carnet no encontrado", 404);
        }

        $numeroEliminado = (int)$carnet['nsocio'];
        $idrol = (int)$carnet['idrol'];
        $iduser = $carnet['iduser'];

        // Solo renumerar si es tipo 4 (tutores)
        if ($idrol != 4) {
            // Para otros tipos, solo eliminar sin renumerar
            $sql = "DELETE FROM tcarnets WHERE id = ?";
            $db->delete($sql, [$id]);

            // Invalidar caché
            $cache->forget("carnet_{$id}_{$idtemporada}");
            $cache->forget("carnets_club_{$idclub}_{$idtemporada}");
            $cache->forget("carnets_user_{$iduser}_{$idtemporada}");

            $db->commit();

            respondSuccess([
                'renumerados' => 0,
                'mensaje' => 'Carnet eliminado (sin renumeración para este tipo)'
            ]);
            return;
        }

        // 2. Eliminar el carnet
        $sql = "DELETE FROM tcarnets WHERE id = ?";
        $db->delete($sql, [$id]);

        // 3. Obtener carnets posteriores del mismo tipo
        $sql = "SELECT id, nsocio
                FROM tcarnets
                WHERE idclub = ?
                  AND idtemporada = ?
                  AND idrol = ?
                  AND CAST(nsocio AS UNSIGNED) > ?
                ORDER BY CAST(nsocio AS UNSIGNED) ASC";

        $carnetsParaRenumerar = $db->select($sql, [$idclub, $idtemporada, $idrol, $numeroEliminado]);

        // 4. Renumerar cada uno restando 1
        $renumerados = 0;
        foreach ($carnetsParaRenumerar as $carnetUpdate) {
            $nuevoNumero = (int)$carnetUpdate['nsocio'] - 1;
            $carnetId = (int)$carnetUpdate['id'];

            // Actualizar número y regenerar QR
            $sql = "UPDATE tcarnets
                    SET nsocio = ?
                    WHERE id = ?";
            $db->update($sql, [(string)$nuevoNumero, $carnetId]);

            $renumerados++;

            // Invalidar caché individual
            $cache->forget("carnet_{$carnetId}_{$idtemporada}");
        }

        // Invalidar caché general
        $cache->forget("carnet_{$id}_{$idtemporada}");
        $cache->forget("carnets_club_{$idclub}_{$idtemporada}");
        $cache->forget("carnets_user_{$iduser}_{$idtemporada}");

        $db->commit();

        respondSuccess([
            'renumerados' => $renumerados,
            'mensaje' => "Carnet eliminado y {$renumerados} carnets renumerados correctamente"
        ]);

    } catch (Exception $e) {
        $db->rollback();
        error_log("[Carnets] Error en deleteCarnetAndRenumber: " . $e->getMessage());
        respondError("Error al eliminar y renumerar: " . $e->getMessage(), 500);
    }
}
