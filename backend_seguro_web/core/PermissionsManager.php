<?php
/**
 * Gestor centralizado de permisos
 *
 * Este sistema gestiona los permisos de forma centralizada para garantizar
 * que TODAS las validaciones se realicen en el backend, no en el cliente.
 *
 * PRINCIPIO DE SEGURIDAD:
 * "Never trust the client" - El cliente solo controla la UI,
 * el backend controla el acceso real a los datos.
 */

require_once __DIR__ . '/Database.php';

class PermissionsManager {

    /**
     * Roles con permisos de escritura completa
     *
     * Estos roles pueden crear, modificar y eliminar recursos
     */
    const ROLES_WRITE = [1, 2, 3, 10, 12, 13];

    /**
     * Roles con permisos de lectura completa
     * Todos los roles pueden leer, pero estos tienen acceso completo
     */
    const ROLES_READ = [1, 2, 3, 4, 5, 9, 10, 12, 13];

    /**
     * Roles específicos con permisos parciales
     */
    const ROLE_PRO = 1;           // Administrador profesional
    const ROLE_ENTRENADOR = 2;    // Entrenador del equipo
    const ROLE_CLUB = 3;          // Gestión del club
    const ROLE_PADRE = 4;         // Padre/Tutor
    const ROLE_JUGADOR = 5;       // Jugador
    const ROLE_FAN = 9;           // Aficionado (solo lectura)
    const ROLE_COORDINADOR = 10;  // Coordinador
    const ROLE_DELEGADO = 12;     // Delegado
    const ROLE_ANALISTA = 13;     // Analista

    private $db;
    private $logger;

    public function __construct($db = null) {
        $this->db = $db ?? Database::getInstance();
        $this->logger = new PermissionLogger();
    }

    /**
     * Verifica si el usuario tiene permisos de escritura
     *
     * @param array $userData Datos del usuario autenticado
     * @param string $resource Nombre del recurso (ej: "partidos", "convocatorias")
     * @param string $action Acción a realizar (ej: "create", "update", "delete")
     * @param int|null $resourceId ID del recurso específico
     * @return bool True si tiene permisos, false en caso contrario
     */
    public function canWrite($userData, $resource, $action = 'update', $resourceId = null) {
        $userId = $userData['id'] ?? null;
        // El tipo de rol viene en 'tipo' desde el middleware (selectedRol.tipo)
        $userRol = $userData['tipo'] ?? $userData['permisos'] ?? $userData['db_user']['permisos'] ?? $userData['db_user']['rol'] ?? $userData['db_user']['idperfil'] ?? null;
        $userClub = $userData['idclub'] ?? null;

        if (!$userRol) {
            $this->logger->logDenied($userId, $resource, $action, 'ROL_NOT_FOUND', [
                'userData_keys' => array_keys($userData),
                'db_user_keys' => isset($userData['db_user']) ? array_keys($userData['db_user']) : []
            ]);
            return false;
        }

        // Verificar si el rol tiene permisos de escritura
        if (!in_array($userRol, self::ROLES_WRITE)) {
            $this->logger->logDenied($userId, $resource, $action, 'INSUFFICIENT_ROLE', [
                'user_rol' => $userRol,
                'required_roles' => self::ROLES_WRITE
            ]);
            return false;
        }

        // Si hay recurso específico, verificar que pertenece al mismo club
        if ($resourceId !== null && $resource !== null) {
            if (!$this->belongsToUserClub($resource, $resourceId, $userClub)) {
                $this->logger->logDenied($userId, $resource, $action, 'CLUB_MISMATCH', [
                    'user_club' => $userClub,
                    'resource_id' => $resourceId
                ]);
                return false;
            }
        }

        $this->logger->logGranted($userId, $resource, $action);
        return true;
    }

    /**
     * Verifica permisos de escritura o lanza excepción
     *
     * @param array $userData Datos del usuario
     * @param string $resource Nombre del recurso
     * @param string $action Acción
     * @param int|null $resourceId ID del recurso
     * @throws PermissionDeniedException
     */
    public function requireWritePermission($userData, $resource, $action = 'update', $resourceId = null) {
        if (!$this->canWrite($userData, $resource, $action, $resourceId)) {
            throw new PermissionDeniedException(
                'No tienes permisos para ' . $this->getActionSpanish($action) . ' ' . $resource
            );
        }
    }

    /**
     * Verifica si el usuario puede leer un recurso
     *
     * @param array $userData Datos del usuario
     * @param string $resource Nombre del recurso
     * @param int|null $resourceId ID del recurso específico
     * @return bool
     */
    public function canRead($userData, $resource, $resourceId = null) {
        // El tipo de rol viene en 'tipo' desde el middleware (selectedRol.tipo)
        $userRol = $userData['tipo'] ?? $userData['permisos'] ?? $userData['db_user']['permisos'] ?? $userData['db_user']['rol'] ?? $userData['db_user']['idperfil'] ?? null;
        $userClub = $userData['idclub'] ?? null;

        if (!$userRol) {
            return false;
        }

        // Todos los roles autenticados pueden leer
        if (!in_array($userRol, self::ROLES_READ)) {
            return false;
        }

        // Verificar que el recurso pertenece al mismo club
        if ($resourceId !== null && $resource !== null) {
            if (!$this->belongsToUserClub($resource, $resourceId, $userClub)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Verifica permisos de lectura o lanza excepción
     *
     * @param array $userData Datos del usuario
     * @param string $resource Nombre del recurso
     * @param int|null $resourceId ID del recurso
     * @throws PermissionDeniedException
     */
    public function requireReadPermission($userData, $resource, $resourceId = null) {
        if (!$this->canRead($userData, $resource, $resourceId)) {
            throw new PermissionDeniedException(
                'No tienes permisos para ver ' . $resource
            );
        }
    }

    /**
     * Verifica si un recurso pertenece al club del usuario
     *
     * @param string $resource Tipo de recurso (partidos, jugadores, etc)
     * @param int $resourceId ID del recurso
     * @param int $userClub ID del club del usuario
     * @return bool
     */
    private function belongsToUserClub($resource, $resourceId, $userClub) {
        if ($userClub === null) {
            return false;
        }

        try {
            $table = $this->getTableForResource($resource);
            $idField = $this->getIdFieldForResource($resource);

            $sql = "SELECT idclub FROM {$table} WHERE {$idField} = ? LIMIT 1";
            $result = $this->db->selectOne($sql, [$resourceId]);

            if (!$result) {
                return false;
            }

            return (int)$result['idclub'] === (int)$userClub;

        } catch (Exception $e) {
            error_log("Error verificando ownership: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtiene el nombre de la tabla para un recurso
     *
     * @param string $resource
     * @return string
     */
    private function getTableForResource($resource) {
        $tables = [
            'partidos' => 'tpartidos',
            'jugadores' => 'tjugadores',
            'entrenamientos' => 'tentrenamientos',
            'convocatorias' => 'tconvpartidos',
            'estadisticas' => 'testadisticas',
            'eventos' => 'teventos',
            'lesiones' => 'tlesiones',
            'cuotas' => 'tcuotas',
            'mensajes' => 'tmensajeria',
            'carnets' => 'tcarnets',
            'equipos' => 'tequipos'
        ];

        return $tables[$resource] ?? 't' . $resource;
    }

    /**
     * Obtiene el campo ID para un recurso
     *
     * @param string $resource
     * @return string
     */
    private function getIdFieldForResource($resource) {
        // La mayoría usan 'id', pero algunos tienen nombres específicos
        $fields = [
            'partidos' => 'id',
            'jugadores' => 'id',
            'convocatorias' => 'idpartido', // Las convocatorias usan idpartido
            'entrenamientos' => 'id'
        ];

        return $fields[$resource] ?? 'id';
    }

    /**
     * Traduce acciones al español para mensajes de error
     *
     * @param string $action
     * @return string
     */
    private function getActionSpanish($action) {
        $translations = [
            'create' => 'crear',
            'update' => 'modificar',
            'delete' => 'eliminar',
            'write' => 'escribir'
        ];

        return $translations[$action] ?? $action;
    }

    /**
     * Verifica si el usuario es el propio jugador
     * Usado para permitir acciones específicas a padres y jugadores
     *
     * @param array $userData
     * @param int $jugadorId
     * @return bool
     */
    public function isSelfPlayer($userData, $jugadorId) {
        $userId = $userData['id'] ?? null;
        $idRol = $userData['idrol'] ?? null;

        if (!$userId || !$idRol) {
            return false;
        }

        try {
            // Verificar si el rol seleccionado (tipo 5 = JUGADOR) tiene este jugador asignado
            $sql = "SELECT id FROM troles
                    WHERE id = ?
                    AND tipo = 5
                    AND idjugador = ?
                    LIMIT 1";
            $result = $this->db->selectOne($sql, [$idRol, $jugadorId]);

            return $result !== null;
        } catch (Exception $e) {
            error_log("Error verificando self-player: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verifica si el usuario es padre del jugador
     *
     * @param array $userData
     * @param int $jugadorId
     * @return bool
     */
    public function isParentOfPlayer($userData, $jugadorId) {
        $userId = $userData['id'] ?? null;
        $idRol = $userData['idrol'] ?? null;
        // El tipo de rol viene en 'tipo' desde el middleware (selectedRol.tipo)
        $userRol = $userData['tipo'] ?? $userData['permisos'] ?? $userData['db_user']['permisos'] ?? $userData['db_user']['rol'] ?? null;

        if (!$userId || !$idRol || $userRol != self::ROLE_PADRE) {
            return false;
        }

        try {
            // Verificar si el jugador está vinculado al rol de padre (idjugador, idjugador2, idjugador3, idjugador4)
            $sql = "SELECT * FROM troles
                    WHERE id = ?
                    AND tipo = 4
                    AND (idjugador = ? OR idjugador2 = ? OR idjugador3 = ? OR idjugador4 = ?)
                    LIMIT 1";
            $result = $this->db->selectOne($sql, [$idRol, $jugadorId, $jugadorId, $jugadorId, $jugadorId]);

            return $result !== null;
        } catch (Exception $e) {
            error_log("Error verificando parent-player: " . $e->getMessage());
            return false;
        }
    }
}

/**
 * Excepción personalizada para permisos denegados
 */
class PermissionDeniedException extends Exception {
    public function __construct($message = "Permisos insuficientes", $code = 403) {
        parent::__construct($message, $code);
    }
}

/**
 * Logger de permisos para auditoría
 */
class PermissionLogger {

    private $logFile;

    public function __construct() {
        $this->logFile = __DIR__ . '/../logs/permissions.log';

        // Crear directorio de logs si no existe (suprimir warnings)
        $logDir = dirname($this->logFile);
        if (!is_dir($logDir)) {
            @mkdir($logDir, 0755, true);
        }
    }

    /**
     * Registra un acceso permitido
     */
    public function logGranted($userId, $resource, $action) {
        $this->log('GRANTED', $userId, $resource, $action);
    }

    /**
     * Registra un acceso denegado
     */
    public function logDenied($userId, $resource, $action, $reason, $context = []) {
        $this->log('DENIED', $userId, $resource, $action, $reason, $context);
    }

    /**
     * Escribe en el log
     */
    private function log($status, $userId, $resource, $action, $reason = null, $context = []) {
        $timestamp = date('Y-m-d H:i:s');
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';

        $logData = [
            'timestamp' => $timestamp,
            'status' => $status,
            'user_id' => $userId,
            'ip' => $ip,
            'resource' => $resource,
            'action' => $action,
            'reason' => $reason,
            'context' => $context,
            'user_agent' => substr($userAgent, 0, 100) // Limitar tamaño
        ];

        $logLine = json_encode($logData) . PHP_EOL;

        // Escribir en archivo con manejo de errores (suprimir warnings)
        try {
            @file_put_contents($this->logFile, $logLine, FILE_APPEND | LOCK_EX);
        } catch (Exception $e) {
            error_log("Error escribiendo log de permisos: " . $e->getMessage());
        }
    }
}
