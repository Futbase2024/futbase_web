<?php
require_once __DIR__ . '/../core/FirebaseAuth.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../core/Database.php';

/**
 * Middleware de autenticación y seguridad
 * Valida Firebase ID Tokens y aplica rate limiting
 */
class FirebaseAuthMiddleware {
    private $firebaseAuth;
    private $rateLimiter;
    private $db;

    public function __construct() {
        $config = require __DIR__ . '/../config/firebase_config.php';
        $this->firebaseAuth = new FirebaseAuth($config['project_id']);
        $this->rateLimiter = new RateLimiter(100, 60); // 100 req/min por defecto
        $this->db = Database::getInstance();
    }

    /**
     * Verifica autenticación Firebase
     *
     * @return array|null Datos del usuario o null si falla
     */
    public function authenticate() {
        // Obtener token del header
        $token = $this->firebaseAuth->getBearerToken();

        if (!$token) {
            $this->respondUnauthorized('Token no proporcionado');
            return null;
        }

        // Validar token de Firebase
        $firebaseData = $this->firebaseAuth->verifyIdToken($token);

        if ($firebaseData === false) {
            $this->respondUnauthorized('Token inválido o expirado');
            return null;
        }

        // Obtener datos adicionales del usuario desde la BD
        $uid = $firebaseData['uid'];
        $userData = $this->getUserDataFromDatabase($uid);

        if (!$userData) {
            error_log("FirebaseAuthMiddleware: Usuario no encontrado en BD para UID: $uid");
            // Retornar solo los datos de Firebase si no hay datos en BD
            return $firebaseData;
        }

        // Combinar datos de Firebase con datos de la BD
        return array_merge($firebaseData, $userData);
    }

    /**
     * Obtiene datos del usuario desde la base de datos
     */
    private function getUserDataFromDatabase($uid) {
        try {
            $sql = "SELECT id, uid, email, permisos, idclub, idequipo, idtemporada
                    FROM tusuarios
                    WHERE uid = ?
                    LIMIT 1";

            $user = $this->db->selectOne($sql, [$uid]);

            if ($user) {
                // Agregar alias con guion bajo para compatibilidad con endpoints existentes
                $user['id_club'] = $user['idclub'];
                $user['id_equipo'] = $user['idequipo'];
                $user['id_temporada'] = $user['idtemporada'];
            }

            return $user ?: null;
        } catch (Exception $e) {
            error_log("FirebaseAuthMiddleware: Error al obtener usuario de BD - " . $e->getMessage());
            return null;
        }
    }

    /**
     * Aplica rate limiting
     *
     * @param string|null $identifier Identificador único (null = usar IP)
     * @param int $maxRequests Máximo de requests
     * @param int $timeWindow Ventana de tiempo en segundos
     */
    public function checkRateLimit($identifier = null, $maxRequests = 100, $timeWindow = 60) {
        // Si no se proporciona identificador, usar IP
        if ($identifier === null) {
            $identifier = RateLimiter::getClientIP();
        }

        // Crear rate limiter con configuración específica
        $rateLimiter = new RateLimiter($maxRequests, $timeWindow);

        if (!$rateLimiter->isAllowed($identifier)) {
            $this->respondRateLimitExceeded();
            return false;
        }

        // Agregar headers de rate limit
        $remaining = $rateLimiter->getRemainingRequests($identifier);
        header("X-RateLimit-Limit: $maxRequests");
        header("X-RateLimit-Remaining: $remaining");
        header("X-RateLimit-Reset: " . (time() + $timeWindow));

        return true;
    }

    /**
     * Middleware completo: rate limit + autenticación
     *
     * @return array|null Datos del usuario autenticado
     */
    public function protect($maxRequests = 100, $timeWindow = 60) {
        // 1. Verificar rate limit
        if (!$this->checkRateLimit(null, $maxRequests, $timeWindow)) {
            exit;
        }

        // 2. Verificar autenticación
        $userData = $this->authenticate();

        if ($userData === null) {
            exit;
        }

        return $userData;
    }

    /**
     * Middleware solo con rate limit (sin autenticación)
     * Útil para endpoints públicos
     */
    public function protectPublic($maxRequests = 20, $timeWindow = 60) {
        if (!$this->checkRateLimit(null, $maxRequests, $timeWindow)) {
            exit;
        }
    }

    /**
     * Verifica que el usuario tenga un permiso específico
     */
    public function checkPermission($userData, $requiredPermission) {
        $userPermissions = $userData['permisos'] ?? 0;

        // Sistema de permisos tipo bitmask
        // 1 = ver, 2 = crear, 4 = editar, 8 = eliminar, etc.
        if (($userPermissions & $requiredPermission) === 0) {
            $this->respondForbidden('No tienes permisos suficientes');
            return false;
        }

        return true;
    }

    /**
     * Respuesta 401 Unauthorized
     */
    private function respondUnauthorized($message) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => $message,
            'code' => 401
        ]);
        exit;
    }

    /**
     * Respuesta 403 Forbidden
     */
    private function respondForbidden($message) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => $message,
            'code' => 403
        ]);
        exit;
    }

    /**
     * Respuesta 429 Too Many Requests
     */
    private function respondRateLimitExceeded() {
        http_response_code(429);
        echo json_encode([
            'success' => false,
            'message' => 'Demasiadas peticiones. Por favor, intenta más tarde.',
            'code' => 429
        ]);
        exit;
    }
}
