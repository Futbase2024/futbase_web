<?php
/**
 * Endpoint de Autenticación
 * Gestiona login, registro y obtención de datos de usuario autenticado
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

// Inicializar dependencias
$db = Database::getInstance();
$cache = new CacheManager(300); // 5 minutos de caché
$auth = new FirebaseAuthMiddleware();

// Obtener acción
$action = $_GET['action'] ?? '';

// Enrutamiento de acciones
try {
    switch ($action) {
        case 'getAppUserByUid':
            getAppUserByUid($db, $cache, $auth);
            break;

        case 'getUserWithRoles':
            getUserWithRoles($db, $cache, $auth);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Error in auth.php: " . $e->getMessage());
    respondInternalError('Error al procesar la solicitud');
}

/**
 * Obtiene un usuario completo con sus roles por UID de Firebase
 * Este método se usa después del login para obtener todos los datos del usuario
 */
function getAppUserByUid($db, $cache, $auth) {
    // Autenticar y obtener el token Firebase
    $userData = $auth->protect(100, 60);

    // El UID viene del token Firebase autenticado
    $uid = $userData['uid'];

    if (!$uid) {
        respondError('UID no encontrado en el token', 400);
    }

    $cacheKey = "user_complete_uid_{$uid}";

    $userComplete = $cache->remember($cacheKey, function() use ($db, $uid) {
        // 1. Obtener datos del usuario
        $sqlUser = "SELECT * FROM tusuarios WHERE uid = ? LIMIT 1";
        $user = $db->selectOne($sqlUser, [$uid]);

        if (!$user) {
            return null;
        }

        // 2. Obtener roles del usuario
        $sqlRoles = "SELECT * FROM vroles WHERE uid = ?";
        $roles = $db->select($sqlRoles, [$uid]);

        // No convertir tipos - dejar que vengan como MySQL los devuelve
        // El @StringToIntConverter de Dart acepta tanto int como string

        // 3. Encontrar el rol seleccionado (selectedrol = 1)
        $selectedRol = null;
        foreach ($roles as $rol) {
            if ($rol['selectedrol'] == 1) {
                $selectedRol = $rol;
                break;
            }
        }

        // Si no hay rol seleccionado, usar el primero
        if (!$selectedRol && !empty($roles)) {
            $selectedRol = $roles[0];
        }

        // 4. Combinar toda la información
        return [
            'uid' => $uid,
            'appUser' => [
                // Datos del usuario
                'id' => $user['id'],
                'uid' => $user['uid'],
                'email' => $user['email'],
                'nombre' => $user['nombre'],
                'apellidos' => $user['apellidos'],
                'telefono' => $user['telefono'],
                'user' => $user['user'],
                'photourl' => $user['photourl'],
                'observaciones' => $user['observaciones'],

                // Datos del rol seleccionado
                'permisos' => $selectedRol ? $selectedRol['tipo'] : 0,
                'idclub' => $selectedRol ? $selectedRol['idclub'] : null,
                'idequipo' => $selectedRol ? $selectedRol['idequipo'] : null,
                'idtemporada' => $selectedRol ? $selectedRol['idtemporada'] : null,
                'idjugador' => $selectedRol ? $selectedRol['idjugador'] : null,

                // Roles completos
                'roles' => $roles,
                'selectedRol' => $selectedRol,
            ]
        ];
    }, 300);

    if (!$userComplete) {
        respondNotFound('Usuario no encontrado');
    }

    respondSuccess($userComplete);
}

/**
 * Obtiene un usuario con sus roles (método alternativo más flexible)
 * Permite pasar el UID como parámetro
 */
function getUserWithRoles($db, $cache, $auth) {
    // Autenticar
    $userData = $auth->protect(100, 60);

    // Obtener UID del parámetro o del token
    $uid = $_GET['uid'] ?? $userData['uid'];

    if (!$uid) {
        respondError('UID es requerido', 400);
    }

    // Validar UID
    $uid = Validator::validateUID($uid);
    if (!$uid) {
        respondError('UID inválido', 400);
    }

    $cacheKey = "user_roles_{$uid}";

    $userComplete = $cache->remember($cacheKey, function() use ($db, $uid) {
        // 1. Obtener usuario
        $sqlUser = "SELECT id, uid, email, nombre, apellidos, telefono, user,
                           photourl, observaciones, idclub, idequipo, idtemporada
                    FROM tusuarios
                    WHERE uid = ?
                    LIMIT 1";

        $user = $db->selectOne($sqlUser, [$uid]);

        if (!$user) {
            return null;
        }

        // 2. Obtener roles
        $sqlRoles = "SELECT * FROM vroles WHERE uid = ? ORDER BY selectedrol DESC";
        $roles = $db->select($sqlRoles, [$uid]);

        // 3. Encontrar rol seleccionado
        $selectedRol = null;
        foreach ($roles as $rol) {
            if ($rol['selectedrol'] == 1) {
                $selectedRol = $rol;
                break;
            }
        }

        // Combinar datos
        $user['roles'] = $roles;
        $user['selectedRol'] = $selectedRol;

        return $user;
    }, 300);

    if (!$userComplete) {
        respondNotFound('Usuario no encontrado');
    }

    respondSuccess($userComplete);
}
