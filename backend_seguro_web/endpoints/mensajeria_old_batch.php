<?php
/**
 * Endpoint: mensajeria.php
 * Sistema de mensajería entre usuarios
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
        case 'enviarMensaje':
            handleEnviarMensaje($db, $cache, $userData);
            break;

        default:
            ResponseHelper::error('Acción no válida: ' . $action, 400);
    }

} catch (Exception $e) {
    error_log("Error en mensajeria.php: " . $e->getMessage());
    ResponseHelper::error('Error del servidor: ' . $e->getMessage(), 500);
}

/**
 * POST: Enviar mensaje
 */
function handleEnviarMensaje($db, $cache, $userData) {
    $rateLimiter = new RateLimiter(50, 60);
    if (!$rateLimiter->isAllowed($userData['uid'])) {
        ResponseHelper::error('Demasiadas peticiones. Intente más tarde.', 429);
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $idusuario = $input['idusuario'] ?? null;
    $idclub = $input['idclub'] ?? null;
    $idremitente = $input['idremitente'] ?? $userData['id'] ?? null;
    $asunto = $input['asunto'] ?? null;
    $mensaje = $input['mensaje'] ?? null;

    if (!$idusuario || !$mensaje) {
        ResponseHelper::error('idusuario y mensaje son obligatorios', 400);
    }

    // Obtener nombre del remitente
    $sqlRemitente = "SELECT nombre, apellidos FROM tusuarios WHERE id = ? LIMIT 1";
    $remitenteData = $db->selectOne($sqlRemitente, [$idremitente]);
    $remitente = $remitenteData ? ($remitenteData['nombre'] . ' ' . $remitenteData['apellidos']) : 'Sistema';

    // Obtener nombre del club si existe
    $club = '';
    if ($idclub) {
        $sqlClub = "SELECT nombre FROM tclub WHERE id = ? LIMIT 1";
        $clubData = $db->selectOne($sqlClub, [$idclub]);
        $club = $clubData ? $clubData['nombre'] : '';
    }

    // Insertar mensaje
    $sql = "INSERT INTO tmensajeria (idusuario, idclub, club, idremitente, remitente, asunto, mensaje, leido, timestamp, registro)
            VALUES (?, ?, ?, ?, ?, ?, ?, 0, NOW(), 1)";

    $mensajeId = $db->insert($sql, [
        $idusuario,
        $idclub,
        $club,
        $idremitente,
        $remitente,
        $asunto,
        $mensaje
    ]);

    if (!$mensajeId) {
        ResponseHelper::error('Error al enviar el mensaje', 500);
    }

    // Invalidar cache de mensajes del usuario
    $cache->clear();

    ResponseHelper::success([
        'id' => $mensajeId,
        'message' => 'Mensaje enviado correctamente'
    ], 'Mensaje enviado');
}
