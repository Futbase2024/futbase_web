<?php
/**
 * 🦶 Endpoint: lateralidad.php
 * Descripción: Catálogo de lateralidad/pie dominante
 * Fecha: 2025-10-25
 *
 * Operaciones:
 * - getLateralidades: Obtener todas las lateralidades (público, caché 600s)
 * - getLateralidadById: Obtener lateralidad por ID (público, caché 600s)
 */

// Configurar manejo de errores
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

// Iniciar output buffering
ob_start();

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Rate limiting (100 peticiones/minuto - lectura pública)
$rateLimiter = new RateLimiter(100, 60);
$clientId = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!$rateLimiter->isAllowed($clientId)) {
    ResponseHelper::error('Demasiadas peticiones. Espera un momento 🕐', 429);
}

// Inicializar servicios
$db = Database::getInstance();
$cache = new CacheManager();

/**
 * 📋 Obtiene todas las lateralidades
 * Público - con caché de 600 segundos (10 minutos)
 */
function getLateralidades($db, $cache) {
    $cacheKey = 'lateralidades_all';

    $lateralidades = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tpiedominante ORDER BY id";
        return $db->select($sql);
    }, 600); // Cache 10 minutos (datos muy estáticos)

    if ($lateralidades === false) {
        ResponseHelper::error('Error al obtener lateralidades', 500);
    }

    ResponseHelper::success($lateralidades, '✅ Lateralidades obtenidas correctamente');
}

/**
 * 🔍 Obtiene una lateralidad por ID
 * Público - con caché de 600 segundos
 */
function getLateralidadById($db, $cache) {
    $id = $_GET['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID requerido', 400);
    }

    if (!is_numeric($id)) {
        ResponseHelper::error('ID inválido', 400);
    }

    $cacheKey = "lateralidad_{$id}";

    $lateralidad = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM tpiedominante WHERE id = ?";
        return $db->selectOne($sql, [$id]);
    }, 600);

    if (!$lateralidad) {
        ResponseHelper::error('Lateralidad no encontrada', 404);
    }

    ResponseHelper::success($lateralidad, '✅ Lateralidad obtenida correctamente');
}

// Router principal
try {
    $action = $_GET['action'] ?? '';

    switch ($action) {
        case 'getLateralidades':
            getLateralidades($db, $cache);
            break;

        case 'getLateralidadById':
            getLateralidadById($db, $cache);
            break;

        default:
            ResponseHelper::error('Acción no válida 🚫', 400);
    }
} catch (Exception $e) {
    error_log("❌ Error en lateralidad.php: " . $e->getMessage());
    ResponseHelper::error('Error interno del servidor', 500);
}
