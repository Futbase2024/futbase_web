<?php
/**
 * 🏆 Endpoint de Gestión de Categorías
 * Operaciones CRUD de categorías deportivas
 *
 * @version 1.0.0
 * @date 2025-10-25
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(300); // 🕐 Caché de 5 minutos

try {
    // Intentar obtener action de varias fuentes
    $action = $_GET['action'] ?? null;

    // Si no está en GET, intentar leer del body JSON
    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;

        // Guardar el body parseado para reutilizar
        if ($jsonInput) {
            $_POST = array_merge($_POST, $jsonInput);
        }
    }

    // Normalizar action a lowercase
    $action = strtolower($action ?? '');

    // 🔓 Acciones públicas que NO requieren autenticación
    $publicActions = ['getcategories', 'getcategorytypes'];

    // Solo autenticar si la acción NO es pública
    $userData = null;
    if (!in_array($action, $publicActions)) {
        // 🔐 Autenticar con Firebase y aplicar rate limit
        $userData = $middleware->protect(100, 60, true); // 100 req/min
    }

    switch ($action) {
        case 'getcategory':
            getCategory($db, $cache, $userData);
            break;

        case 'getcategories':
            getCategories($db, $cache, $userData);
            break;

        case 'getcategorytypes':
            getCategoryTypes($db, $cache, $userData);
            break;

        case 'getcategoriesbyclub':
            getCategoriesByClub($db, $cache, $userData);
            break;

        case 'createcategory':
            createCategory($db, $cache, $userData);
            break;

        case 'updatecategory':
            updateCategory($db, $cache, $userData);
            break;

        case 'deletecategory':
            deleteCategory($db, $cache, $userData);
            break;

        default:
            respondError('❌ Acción no válida', 400);
            break;
    }

} catch (Exception $e) {
    error_log("❌ Categories error: " . $e->getMessage());
    respondError('❌ Error interno del servidor', 500);
}

// ========== 🏆 OPERACIONES DE CATEGORÍAS ==========

/**
 * 🔍 Obtener categoría por ID
 */
function getCategory($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$id || !$idTemporada) {
        respondError('❌ id e idtemporada son requeridos', 400);
    }

    $cacheKey = "category_{$id}_{$idTemporada}";
    $category = $cache->remember($cacheKey, function() use ($db, $id, $idTemporada) {
        $sql = "SELECT * FROM tcategorias WHERE id = ? AND idtemporada = ?";
        return $db->selectOne($sql, [$id, $idTemporada]);
    });

    if (!$category) {
        respondError('❌ Categoría no encontrada', 404);
    }

    respondSuccess(['category' => $category], '✅ Categoría obtenida exitosamente');
}

/**
 * 📋 Obtener todas las categorías
 * Acción pública - no requiere autenticación
 */
function getCategories($db, $cache, $userData) {
    $cacheKey = "categories_all";
    $categories = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM tcategorias ORDER BY categoria ASC";
        return $db->select($sql);
    });

    respondSuccess(
        ['categories' => $categories],
        '✅ ' . count($categories) . ' categorías obtenidas'
    );
}

/**
 * 📋 Obtener tipos de categoría
 * Acción pública - no requiere autenticación
 */
function getCategoryTypes($db, $cache, $userData) {
    $cacheKey = "category_types_all";
    $types = $cache->remember($cacheKey, function() use ($db) {
        $sql = "SELECT * FROM ttipocategoria ORDER BY tipo ASC";
        return $db->select($sql);
    });

    respondSuccess(
        ['types' => $types],
        '✅ ' . count($types) . ' tipos de categoría obtenidos'
    );
}

/**
 * 🏢 Obtener categorías por club
 */
function getCategoriesByClub($db, $cache, $userData) {
    $idClub = Validator::validateInt($_GET['idclub'] ?? null);
    $idTemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idClub || !$idTemporada) {
        respondError('❌ idclub e idtemporada son requeridos', 400);
    }

    $cacheKey = "categories_club_{$idClub}_{$idTemporada}";
    $categories = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT DISTINCT c.*
                FROM tcategorias c
                INNER JOIN tequipos e ON e.idcategoria = c.id
                WHERE e.idclub = ? AND c.idtemporada = ?
                ORDER BY c.categoria ASC";
        return $db->select($sql, [$idClub, $idTemporada]);
    });

    respondSuccess(
        ['categories' => $categories],
        '✅ ' . count($categories) . ' categorías del club obtenidas'
    );
}

/**
 * ➕ Crear nueva categoría
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function createCategory($db, $cache, $userData) {
    // 🔐 Verificar permisos
    requireWritePermission($userData);

    $categoria = Validator::validateString($_POST['categoria'] ?? '', 1, 100);
    $idTemporada = Validator::validateInt($_POST['idtemporada'] ?? null);

    if (!$categoria || !$idTemporada) {
        respondError('❌ categoria e idtemporada son requeridos', 400);
    }

    // ➕ Insertar categoría
    $sql = "INSERT INTO tcategorias (categoria, idtemporada) VALUES (?, ?)";
    $idCategory = $db->insert($sql, [$categoria, $idTemporada]);

    // 🧹 Limpiar caché
    $cache->clear("categories_*");

    respondSuccess([
        'id' => $idCategory,
    ], '✅ Categoría creada exitosamente');
}

/**
 * ✏️ Actualizar categoría
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function updateCategory($db, $cache, $userData) {
    // 🔐 Verificar permisos
    requireWritePermission($userData);

    $id = Validator::validateInt($_POST['id'] ?? null);
    $categoria = Validator::validateString($_POST['categoria'] ?? '', 1, 100);

    if (!$id || !$categoria) {
        respondError('❌ id y categoria son requeridos', 400);
    }

    // ✏️ Actualizar categoría
    $sql = "UPDATE tcategorias SET categoria = ? WHERE id = ?";
    $affected = $db->execute($sql, [$categoria, $id]);

    // 🧹 Limpiar caché
    $cache->clear("categories_*");
    $cache->clear("category_{$id}_*");

    respondSuccess([
        'affected_rows' => $affected,
    ], '✅ Categoría actualizada exitosamente');
}

/**
 * 🗑️ Eliminar categoría
 * REQUIERE: Permisos de escritura (roles 1,2,3,10,12,13)
 */
function deleteCategory($db, $cache, $userData) {
    // 🔐 Verificar permisos
    requireWritePermission($userData);

    $id = Validator::validateInt($_POST['id'] ?? null);

    if (!$id) {
        respondError('❌ id es requerido', 400);
    }

    // 🔍 Verificar que no tenga equipos asociados
    $sql = "SELECT COUNT(*) as count FROM tequipos WHERE idcategoria = ?";
    $result = $db->selectOne($sql, [$id]);

    if ($result['count'] > 0) {
        respondError('❌ No se puede eliminar la categoría porque tiene ' . $result['count'] . ' equipos asociados', 400);
    }

    // 🗑️ Eliminar categoría
    $sql = "DELETE FROM tcategorias WHERE id = ?";
    $affected = $db->execute($sql, [$id]);

    // 🧹 Limpiar caché
    $cache->clear("categories_*");
    $cache->clear("category_{$id}_*");

    respondSuccess([
        'affected_rows' => $affected,
    ], '✅ Categoría eliminada exitosamente');
}

/**
 * 🔐 Verificar permisos de escritura
 * Roles permitidos: 1 (PRO), 2 (CLUB), 3 (COORDINADOR), 10 (ENTRENADOR), 12 (DELEGADO), 13 (ANALISTA)
 */
function requireWritePermission($userData) {
    if (!$userData) {
        respondError('❌ Autenticación requerida', 401);
    }

    $allowedRoles = [1, 2, 3, 10, 12, 13];

    // El rol puede venir en diferentes lugares según el middleware
    $userRole = $userData['tipo'] ??
                $userData['role'] ??
                $userData['permisos'] ??
                ($userData['db_user']['permisos'] ?? null);

    if (!in_array($userRole, $allowedRoles)) {
        respondError('❌ No tienes permisos para realizar esta operación. Rol actual: ' . ($userRole ?? 'desconocido'), 403);
    }
}
