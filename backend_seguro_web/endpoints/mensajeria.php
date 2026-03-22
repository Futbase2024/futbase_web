<?php
/**
 * Endpoint: mensajeria.php
 * Sistema de mensajería entre usuarios
 */

// CORS PRIMERO - antes que cualquier otra cosa
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

$db = Database::getInstance();
$cache = new CacheManager(300);
$auth = new FirebaseAuthMiddleware();
$userData = $auth->protect(50, 60); // Más restrictivo para mensajes

$action = $_GET['action'] ?? $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'enviarMensaje':
            enviarMensaje($db, $cache, $userData);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in mensajeria.php: " . $e->getMessage() . " | Trace: " . $e->getTraceAsString());
    respondInternalError('Error al procesar la solicitud: ' . $e->getMessage());
}

/**
 * POST: Enviar mensaje
 * Tabla: temails
 * Campos: id, idusuario, idclub, asunto, mensaje, leido, timestamp, timestampleido, idremitente, registro
 */
function enviarMensaje($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $idusuario = $input['idusuario'] ?? null;  // Destinatario
    $idclub = $input['idclub'] ?? null;
    $idremitente = $input['idremitente'] ?? $userData['id'] ?? null;
    $asunto = $input['asunto'] ?? null;
    $mensaje = $input['mensaje'] ?? null;

    if (!$idusuario || !$mensaje) {
        respondError('idusuario y mensaje son obligatorios', 400);
    }

    // Insertar mensaje en temails
    $sql = "INSERT INTO temails (idusuario, idclub, asunto, mensaje, leido, `timestamp`, idremitente, registro)
            VALUES (?, ?, ?, ?, 0, NOW(), ?, 1)";

    $mensajeId = $db->insert($sql, [
        $idusuario,
        $idclub,
        $asunto,
        $mensaje,
        $idremitente
    ]);

    if (!$mensajeId) {
        respondInternalError('Error al enviar el mensaje');
    }

    // Invalidar cache de mensajes del usuario
    $cache->clear();

    respondSuccess([
        'id' => $mensajeId,
        'message' => 'Mensaje enviado correctamente'
    ]);
}
