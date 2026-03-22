<?php
/**
 * Endpoint de Documentos
 * Gestión de documentos del club
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
        case 'getDocumentosPorClub':
            getDocumentosPorClub($db, $cache, $userData);
            break;

        case 'getDocumentosPorEquipo':
            getDocumentosPorEquipo($db, $cache, $userData);
            break;

        case 'getDocumentosPorUsuario':
            getDocumentosPorUsuario($db, $cache, $userData);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in documentos.php: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene documentos por club y temporada
 */
function getDocumentosPorClub($db, $cache, $userData) {
    try {
        $idClub = $_GET['idClub'] ?? null;
        $idTemporada = $_GET['idTemporada'] ?? null;

        if (!$idClub || !$idTemporada) {
            respondError('idClub e idTemporada son requeridos', 400);
        }

        error_log("[Documentos] Obteniendo documentos - Club: {$idClub}, Temporada: {$idTemporada}");

        // Sin caché por ahora para debug
        try {
            $sql = "SELECT * FROM vinformes
                    WHERE idclub = ?
                    AND idtemporada = ?
                    ORDER BY fechasubida DESC";

            $documentos = $db->select($sql, [
                $idClub,
                $idTemporada
            ]);

            error_log("[Documentos] Encontrados " . count($documentos) . " documentos");
            respondSuccess($documentos);

        } catch (Exception $e) {
            error_log("[Documentos] Error en consulta SQL: " . $e->getMessage());
            error_log("[Documentos] SQL Error Code: " . $e->getCode());
            // Si falla, devolver array vacío en lugar de error
            respondSuccess([]);
        }

    } catch (Exception $e) {
        error_log("[Documentos] Error general: " . $e->getMessage());
        respondSuccess([]);
    }
}

/**
 * Obtiene documentos por equipo y temporada
 */
function getDocumentosPorEquipo($db, $cache, $userData) {
    try {
        $idEquipo = $_GET['idEquipo'] ?? null;
        $idTemporada = $_GET['idTemporada'] ?? null;

        if (!$idEquipo || !$idTemporada) {
            respondError('idEquipo e idTemporada son requeridos', 400);
        }

        error_log("[Documentos] Obteniendo documentos de equipo - Equipo: {$idEquipo}, Temporada: {$idTemporada}");

        try {
            $sql = "SELECT * FROM vinformes
                    WHERE idequipo = ?
                    AND idtemporada = ?
                    ORDER BY fechasubida DESC";

            $documentos = $db->select($sql, [
                $idEquipo,
                $idTemporada
            ]);

            error_log("[Documentos] Encontrados " . count($documentos) . " documentos de equipo");
            respondSuccess($documentos);

        } catch (Exception $e) {
            error_log("[Documentos] Error en getDocumentosPorEquipo: " . $e->getMessage());
            respondSuccess([]);
        }

    } catch (Exception $e) {
        error_log("[Documentos] Error general en getDocumentosPorEquipo: " . $e->getMessage());
        respondSuccess([]);
    }
}

/**
 * Obtiene documentos por usuario y temporada
 */
function getDocumentosPorUsuario($db, $cache, $userData) {
    try {
        $idUsuario = $_GET['idUsuario'] ?? null;
        $idTemporada = $_GET['idTemporada'] ?? null;

        if (!$idUsuario || !$idTemporada) {
            respondError('idUsuario e idTemporada son requeridos', 400);
        }

        error_log("[Documentos] Obteniendo documentos de usuario - Usuario: {$idUsuario}, Temporada: {$idTemporada}");

        try {
            $sql = "SELECT * FROM vinformes
                    WHERE idusuario = ?
                    AND idtemporada = ?
                    ORDER BY fechasubida DESC";

            $documentos = $db->select($sql, [
                $idUsuario,
                $idTemporada
            ]);

            error_log("[Documentos] Encontrados " . count($documentos) . " documentos de usuario");
            respondSuccess($documentos);

        } catch (Exception $e) {
            error_log("[Documentos] Error en getDocumentosPorUsuario: " . $e->getMessage());
            respondSuccess([]);
        }

    } catch (Exception $e) {
        error_log("[Documentos] Error general en getDocumentosPorUsuario: " . $e->getMessage());
        respondSuccess([]);
    }
}
