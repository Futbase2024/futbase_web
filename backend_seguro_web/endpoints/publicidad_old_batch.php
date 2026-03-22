<?php
/**
 * Endpoint: publicidad.php
 * Gestión de publicidad y anunciantes
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
        case 'getPublicidades':
            handleGetPublicidades($db, $cache, $userData);
            break;

        case 'actualizarPubli':
            handleActualizarPubli($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en publicidad.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * GET: Obtener publicidades por temporada
 */
function handleGetPublicidades($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(100, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $idTemporada = $_GET['idTemporada'] ?? null;
    if (!$idTemporada) {
        ResponseHelper::error('idTemporada es obligatorio', 400);
    }

    $cacheKey = "publicidades_temporada_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        ResponseHelper::success($cached, 'Publicidades obtenidas (cache)');
    }

    // Vista completa de publicidad con anunciantes
    $sql = "SELECT
                p.*,
                e.nombre as equipo,
                e.idclub,
                c.nombre as club,
                a.nombre as anunciante,
                a.direccion,
                a.cif,
                a.email,
                a.web,
                a.telefono,
                a.idlocalidad,
                a.idprovincia
            FROM tpublicidad p
            LEFT JOIN tequipos e ON p.idequipo = e.id
            LEFT JOIN tclub c ON e.idclub = c.id
            LEFT JOIN tanunciantes a ON p.idanunciante = a.id
            WHERE p.idtemporada = ?
            ORDER BY p.posicion ASC, p.id ASC";

    $publicidades = $db->select($sql, [$idTemporada]);

    $cache->set($cacheKey, $publicidades, 600);
    ResponseHelper::success($publicidades, 'Publicidades obtenidas');
}

/**
 * POST: Actualizar publicidad
 */
function handleActualizarPubli($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        ResponseHelper::error('ID de publicidad es obligatorio', 400);
    }

    $idequipo = $input['idequipo'] ?? null;
    $idanunciante = $input['idanunciante'] ?? null;
    $evento = $input['evento'] ?? null;
    $urlImagen = $input['urlImagen'] ?? null;
    $posicion = $input['posicion'] ?? null;
    $activo = $input['activo'] ?? 1;
    $impresiones = $input['impresiones'] ?? 0;
    $interacciones = $input['interacciones'] ?? 0;
    $idtemporada = $input['idtemporada'] ?? null;

    // Calcular CTR
    $ctr = 0;
    if ($impresiones > 0) {
        $ctr = round(($interacciones / $impresiones) * 100, 2);
    }

    $sql = "UPDATE tpublicidad SET
            idequipo = ?,
            idanunciante = ?,
            evento = ?,
            urlImagen = ?,
            posicion = ?,
            activo = ?,
            impresiones = ?,
            interacciones = ?,
            ctr = ?,
            idtemporada = ?
            WHERE id = ?";

    $rowsAffected = $db->execute($sql, [
        $idequipo,
        $idanunciante,
        $evento,
        $urlImagen,
        $posicion,
        $activo,
        $impresiones,
        $interacciones,
        $ctr,
        $idtemporada,
        $id
    ]);

    if ($rowsAffected === 0) {
        ResponseHelper::error('Publicidad no encontrada o sin cambios', 404);
    }

    // Invalidar cache
    $cache->clear();

    // Retornar lista actualizada de publicidades de la temporada
    $sqlPublicidades = "SELECT
                            p.*,
                            e.nombre as equipo,
                            e.idclub,
                            c.nombre as club,
                            a.nombre as anunciante,
                            a.direccion,
                            a.cif,
                            a.email,
                            a.web,
                            a.telefono,
                            a.idlocalidad,
                            a.idprovincia
                        FROM tpublicidad p
                        LEFT JOIN tequipos e ON p.idequipo = e.id
                        LEFT JOIN tclub c ON e.idclub = c.id
                        LEFT JOIN tanunciantes a ON p.idanunciante = a.id
                        WHERE p.idtemporada = ?
                        ORDER BY p.posicion ASC, p.id ASC";

    $publicidadesActualizadas = $db->select($sqlPublicidades, [$idtemporada]);

    ResponseHelper::success($publicidadesActualizadas, 'Publicidad actualizada correctamente');
}
