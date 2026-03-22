<?php
/**
 * ⚽ Endpoint: sistemas_juego.php
 * Descripción: Catálogo de sistemas de juego (4-4-2, 4-3-3, etc)
 * Fecha: 2025-10-25
 *
 * Operaciones:
 * - getSistemas: Obtener todos los sistemas (público, caché 600s)
 * - getSistemaById: Obtener sistema por ID (público, caché 600s)
 * - getSistemasByTipoCampo: Obtener sistemas por tipo de campo (público, caché 600s)
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
 * 📋 Obtiene todos los sistemas de juego
 * Público - con caché de 600 segundos (10 minutos)
 */
function getSistemas($db, $cache) {
    $cacheKey = 'sistemas_all';

    $sistemas = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tsistemas ORDER BY id";
        return $db->select($sql);
    }, 600); // Cache 10 minutos (datos muy estáticos)

    if ($sistemas === false) {
        ResponseHelper::error('Error al obtener sistemas de juego', 500);
    }

    ResponseHelper::success($sistemas, '✅ Sistemas de juego obtenidos correctamente');
}

/**
 * 🔍 Obtiene un sistema de juego por ID
 * Público - con caché de 600 segundos
 */
function getSistemaById($db, $cache) {
    $id = $_GET['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID requerido', 400);
    }

    if (!is_numeric($id)) {
        ResponseHelper::error('ID inválido', 400);
    }

    $cacheKey = "sistema_{$id}";

    $sistema = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM tsistemas WHERE id = ?";
        return $db->selectOne($sql, [$id]);
    }, 600);

    if (!$sistema) {
        ResponseHelper::error('Sistema de juego no encontrado', 404);
    }

    ResponseHelper::success($sistema, '✅ Sistema de juego obtenido correctamente');
}

/**
 * 🏟️ Obtiene sistemas de juego por tipo de campo
 * Público - con caché de 600 segundos
 * @param tipocampo: 7 (fútbol 7), 11 (fútbol 11), etc.
 */
function getSistemasByTipoCampo($db, $cache) {
    $tipocampo = $_GET['tipocampo'] ?? null;

    if (!$tipocampo) {
        ResponseHelper::error('Tipo de campo requerido', 400);
    }

    if (!is_numeric($tipocampo)) {
        ResponseHelper::error('Tipo de campo inválido', 400);
    }

    $cacheKey = "sistemas_tipocampo_{$tipocampo}";

    $sistemas = $cache->remember($cacheKey, function() use ($db, $tipocampo) {
        $sql = "SELECT * FROM tsistemas WHERE tipocampo = ? ORDER BY id";
        return $db->select($sql, [$tipocampo]);
    }, 600);

    if ($sistemas === false) {
        ResponseHelper::error('Error al obtener sistemas', 500);
    }

    ResponseHelper::success($sistemas, '✅ Sistemas filtrados por tipo de campo');
}

// Router principal
try {
    $action = $_GET['action'] ?? '';

    switch ($action) {
        case 'getSistemas':
            getSistemas($db, $cache);
            break;

        case 'getSistemaById':
            getSistemaById($db, $cache);
            break;

        case 'getSistemasByTipoCampo':
            getSistemasByTipoCampo($db, $cache);
            break;

        default:
            ResponseHelper::error('Acción no válida 🚫', 400);
    }
} catch (Exception $e) {
    error_log("❌ Error en sistemas_juego.php: " . $e->getMessage());
    ResponseHelper::error('Error interno del servidor', 500);
}
