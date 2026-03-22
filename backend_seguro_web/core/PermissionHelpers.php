<?php
/**
 * Helpers de permisos para usar en endpoints
 *
 * Estos helpers simplifican la validación de permisos en los endpoints
 * proporcionando funciones globales fáciles de usar.
 */

require_once __DIR__ . '/PermissionsManager.php';
require_once __DIR__ . '/Database.php';

/**
 * Verifica permisos de escritura y responde con error 403 si no tiene permisos
 *
 * @param array $userData Datos del usuario autenticado
 * @param string $resource Recurso a modificar
 * @param string $action Acción (create, update, delete)
 * @param int|null $resourceId ID del recurso específico
 * @param string|null $customMessage Mensaje de error personalizado
 * @return bool True si tiene permisos
 */
function requireWritePermission($userData, $resource, $action = 'update', $resourceId = null, $customMessage = null) {
    static $permManager = null;

    if ($permManager === null) {
        $permManager = new PermissionsManager();
    }

    try {
        $permManager->requireWritePermission($userData, $resource, $action, $resourceId);
        return true;
    } catch (PermissionDeniedException $e) {
        $message = $customMessage ?? $e->getMessage();
        respondError($message, 403);
        return false;
    }
}

/**
 * Verifica permisos de lectura y responde con error 403 si no tiene permisos
 *
 * @param array $userData Datos del usuario autenticado
 * @param string $resource Recurso a leer
 * @param int|null $resourceId ID del recurso específico
 * @param string|null $customMessage Mensaje de error personalizado
 * @return bool True si tiene permisos
 */
function requireReadPermission($userData, $resource, $resourceId = null, $customMessage = null) {
    static $permManager = null;

    if ($permManager === null) {
        $permManager = new PermissionsManager();
    }

    try {
        $permManager->requireReadPermission($userData, $resource, $resourceId);
        return true;
    } catch (PermissionDeniedException $e) {
        $message = $customMessage ?? $e->getMessage();
        respondError($message, 403);
        return false;
    }
}

/**
 * Verifica si el usuario tiene permisos de escritura (sin lanzar error)
 *
 * @param array $userData Datos del usuario autenticado
 * @param string $resource Recurso
 * @param string $action Acción
 * @param int|null $resourceId ID del recurso
 * @return bool True si tiene permisos
 */
function canWrite($userData, $resource, $action = 'update', $resourceId = null) {
    static $permManager = null;

    if ($permManager === null) {
        $permManager = new PermissionsManager();
    }

    return $permManager->canWrite($userData, $resource, $action, $resourceId);
}

/**
 * Verifica si el usuario tiene permisos de lectura (sin lanzar error)
 *
 * @param array $userData Datos del usuario autenticado
 * @param string $resource Recurso
 * @param int|null $resourceId ID del recurso
 * @return bool True si tiene permisos
 */
function canRead($userData, $resource, $resourceId = null) {
    static $permManager = null;

    if ($permManager === null) {
        $permManager = new PermissionsManager();
    }

    return $permManager->canRead($userData, $resource, $resourceId);
}

/**
 * Verifica si el usuario tiene rol de escritura (helper rápido)
 *
 * @param array $userData Datos del usuario autenticado
 * @return bool
 */
function hasWriteRole($userData) {
    // El tipo de rol viene en 'tipo' desde el middleware (selectedRol.tipo)
    $rol = $userData['tipo'] ?? $userData['permisos'] ?? $userData['db_user']['permisos'] ?? $userData['db_user']['rol'] ?? $userData['db_user']['idperfil'] ?? null;
    return in_array($rol, PermissionsManager::ROLES_WRITE);
}

/**
 * Verifica si el usuario pertenece a un rol específico
 *
 * @param array $userData Datos del usuario autenticado
 * @param int $role ID del rol
 * @return bool
 */
function hasRole($userData, $role) {
    // El tipo de rol viene en 'tipo' desde el middleware (selectedRol.tipo)
    $userRol = $userData['tipo'] ?? $userData['permisos'] ?? $userData['db_user']['permisos'] ?? $userData['db_user']['rol'] ?? $userData['db_user']['idperfil'] ?? null;
    return $userRol === $role;
}

/**
 * Verifica si el usuario es administrador (PRO, CLUB o COORDINADOR)
 *
 * @param array $userData Datos del usuario autenticado
 * @return bool
 */
function isAdmin($userData) {
    return hasRole($userData, PermissionsManager::ROLE_PRO) ||
           hasRole($userData, PermissionsManager::ROLE_CLUB) ||
           hasRole($userData, PermissionsManager::ROLE_COORDINADOR);
}

/**
 * Verifica si el usuario es entrenador, delegado o analista
 *
 * @param array $userData Datos del usuario autenticado
 * @return bool
 */
function isCoach($userData) {
    return hasRole($userData, PermissionsManager::ROLE_ENTRENADOR) ||
           hasRole($userData, PermissionsManager::ROLE_DELEGADO) ||
           hasRole($userData, PermissionsManager::ROLE_ANALISTA);
}

/**
 * Verifica si el usuario puede editar motivo de asistencia del jugador
 * EXCEPCIÓN: Roles 4 (PADRE) y 5 (JUGADOR) pueden editar motivo de sus hijos/propio
 *
 * @param array $userData Datos del usuario autenticado
 * @param int $idJugador ID del jugador
 * @return bool True si tiene permisos
 */
function canEditMotivoAsistencia($userData, $idJugador) {
    // Roles con permisos completos
    if (hasWriteRole($userData)) {
        return true;
    }

    static $permManager = null;
    if ($permManager === null) {
        $permManager = new PermissionsManager();
    }

    // EXCEPCIÓN 1: El propio jugador (rol 5) puede editar su motivo
    if (hasRole($userData, PermissionsManager::ROLE_JUGADOR)) {
        return $permManager->isSelfPlayer($userData, $idJugador);
    }

    // EXCEPCIÓN 2: El tutor (rol 4) puede editar motivo de sus hijos
    if (hasRole($userData, PermissionsManager::ROLE_PADRE)) {
        return $permManager->isParentOfPlayer($userData, $idJugador);
    }

    return false;
}

/**
 * Requiere permisos para editar motivo de asistencia (con excepciones para roles 4 y 5)
 *
 * @param array $userData Datos del usuario autenticado
 * @param int $idJugador ID del jugador
 * @return bool True si tiene permisos
 */
function requireEditMotivoPermission($userData, $idJugador) {
    if (!canEditMotivoAsistencia($userData, $idJugador)) {
        $message = "No tienes permisos para editar el motivo de asistencia";

        if (hasRole($userData, PermissionsManager::ROLE_JUGADOR)) {
            $message = "Solo puedes modificar tu propio motivo de asistencia";
        } else if (hasRole($userData, PermissionsManager::ROLE_PADRE)) {
            $message = "Solo puedes modificar el motivo de asistencia de tus hijos";
        }

        respondError($message, 403);
        return false;
    }

    return true;
}

/**
 * Responde con error y termina ejecución
 * (Definido aquí si no existe en el endpoint)
 *
 * @param string $message Mensaje de error
 * @param int $code Código HTTP
 */
if (!function_exists('respondError')) {
    function respondError($message, $code = 400) {
        http_response_code($code);
        echo json_encode([
            'success' => false,
            'error' => true,
            'message' => $message,
            'code' => $code
        ]);
        exit;
    }
}

/**
 * Responde con éxito
 * (Definido aquí si no existe en el endpoint)
 *
 * @param mixed $data Datos a retornar
 * @param string|null $message Mensaje opcional
 */
if (!function_exists('respondSuccess')) {
    function respondSuccess($data = null, $message = null) {
        $response = ['success' => true];
        if ($data !== null) {
            $response['data'] = $data;
        }
        if ($message !== null) {
            $response['message'] = $message;
        }
        echo json_encode($response);
        exit;
    }
}
