/**
 * Endpoint: publicidad.php
 * Gestión de publicidad y anunciantes
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

        case 'getPublicidades':
            GetPublicidades($db, $cache, $userData);
            break;

        case 'actualizarPubli':
            ActualizarPubli($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida: ' . $action, 400);
    }
} catch (Exception $e) {
    error_log("Error in publicidad.php: " . \$e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

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

function GetPublicidades($db, $cache, $userData) {
    $idTemporada = $_GET['idTemporada'] ?? null;
    if (!$idTemporada) {
        respondError('idTemporada es obligatorio', 400);
    }

    $cacheKey = "publicidades_temporada_{$idTemporada}";
    $cached = $cache->get($cacheKey);
    if ($cached !== null) {
        respondSuccess($cached, 'Publicidades obtenidas (cache)');
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
    respondSuccess($publicidades, 'Publicidades obtenidas');
}

/**
 * POST: Actualizar publicidad
 */

function ActualizarPubli($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $id = $input['id'] ?? null;
    if (!$id) {
        respondError('ID de publicidad es obligatorio', 400);
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
        respondError('Publicidad no encontrada o sin cambios', 404);
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

    respondSuccess($publicidadesActualizadas, 'Publicidad actualizada correctamente');
}

