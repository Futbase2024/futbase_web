<?php
/**
 * Validador de Firebase ID Tokens
 * Valida tokens de Firebase sin necesidad de SDK
 */
class FirebaseAuth {
    private $projectId;
    private $publicKeysUrl = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';
    private $publicKeys = null;
    private $publicKeysExpiry = null;

    public function __construct($projectId) {
        $this->projectId = $projectId;
    }

    /**
     * Valida un Firebase ID Token
     *
     * @param string $token Firebase ID Token
     * @return array|false Datos del usuario si es válido, false si no
     */
    public function verifyIdToken($token) {
        try {
            // Dividir el token en sus partes
            $parts = explode('.', $token);

            if (count($parts) !== 3) {
                error_log("FirebaseAuth: Token format invalid");
                return false;
            }

            list($headerEncoded, $payloadEncoded, $signatureEncoded) = $parts;

            // Decodificar header y payload
            $header = json_decode($this->base64UrlDecode($headerEncoded), true);
            $payload = json_decode($this->base64UrlDecode($payloadEncoded), true);

            if (!$header || !$payload) {
                error_log("FirebaseAuth: Failed to decode token");
                return false;
            }

            // Verificar claims básicos
            if (!$this->verifyBasicClaims($payload)) {
                return false;
            }

            // Verificar firma
            if (!$this->verifySignature($headerEncoded, $payloadEncoded, $signatureEncoded, $header)) {
                error_log("FirebaseAuth: Signature verification failed");
                return false;
            }

            // Retornar datos del usuario
            return [
                'uid' => $payload['user_id'] ?? $payload['sub'],
                'email' => $payload['email'] ?? null,
                'email_verified' => $payload['email_verified'] ?? false,
                'name' => $payload['name'] ?? null,
                'picture' => $payload['picture'] ?? null,
                'firebase' => $payload, // Todos los claims de Firebase
            ];

        } catch (Exception $e) {
            error_log("FirebaseAuth: Exception - " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verifica los claims básicos del token
     */
    private function verifyBasicClaims($payload) {
        // Verificar expiración
        if (!isset($payload['exp']) || $payload['exp'] < time()) {
            error_log("FirebaseAuth: Token expired");
            return false;
        }

        // Verificar que no se use antes de tiempo
        if (isset($payload['iat']) && $payload['iat'] > time()) {
            error_log("FirebaseAuth: Token used before valid");
            return false;
        }

        // Verificar audience (debe ser el project ID)
        if (!isset($payload['aud']) || $payload['aud'] !== $this->projectId) {
            error_log("FirebaseAuth: Invalid audience. Expected: {$this->projectId}, Got: " . ($payload['aud'] ?? 'none'));
            return false;
        }

        // Verificar issuer
        $expectedIssuer = "https://securetoken.google.com/{$this->projectId}";
        if (!isset($payload['iss']) || $payload['iss'] !== $expectedIssuer) {
            error_log("FirebaseAuth: Invalid issuer");
            return false;
        }

        // Verificar que tenga user_id o sub
        if (!isset($payload['sub']) && !isset($payload['user_id'])) {
            error_log("FirebaseAuth: Missing user_id/sub");
            return false;
        }

        return true;
    }

    /**
     * Verifica la firma del token usando las claves públicas de Google
     */
    private function verifySignature($headerEncoded, $payloadEncoded, $signatureEncoded, $header) {
        // Obtener las claves públicas de Google
        if (!$this->loadPublicKeys()) {
            return false;
        }

        // Obtener el kid (key ID) del header
        if (!isset($header['kid'])) {
            error_log("FirebaseAuth: Missing kid in header");
            return false;
        }

        $kid = $header['kid'];

        // Buscar la clave pública correspondiente
        if (!isset($this->publicKeys[$kid])) {
            error_log("FirebaseAuth: Public key not found for kid: $kid");
            return false;
        }

        $publicKeyPem = $this->publicKeys[$kid];

        // Verificar la firma
        $data = "$headerEncoded.$payloadEncoded";
        $signature = $this->base64UrlDecode($signatureEncoded);

        $publicKey = openssl_pkey_get_public($publicKeyPem);
        if ($publicKey === false) {
            error_log("FirebaseAuth: Failed to load public key");
            return false;
        }

        $result = openssl_verify($data, $signature, $publicKey, OPENSSL_ALGO_SHA256);

        return $result === 1;
    }

    /**
     * Carga las claves públicas de Google (con caché)
     */
    private function loadPublicKeys() {
        // Si ya tenemos las claves y no han expirado, usarlas
        if ($this->publicKeys !== null && $this->publicKeysExpiry > time()) {
            return true;
        }

        try {
            $ch = curl_init($this->publicKeysUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, true);

            $response = curl_exec($ch);
            $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
            $headers = substr($response, 0, $headerSize);
            $body = substr($response, $headerSize);

            curl_close($ch);

            $this->publicKeys = json_decode($body, true);

            if (!$this->publicKeys) {
                error_log("FirebaseAuth: Failed to decode public keys");
                return false;
            }

            // Extraer tiempo de expiración del header Cache-Control
            if (preg_match('/max-age=(\d+)/', $headers, $matches)) {
                $maxAge = (int)$matches[1];
                $this->publicKeysExpiry = time() + $maxAge;
            } else {
                // Por defecto, cachear por 1 hora
                $this->publicKeysExpiry = time() + 3600;
            }

            return true;

        } catch (Exception $e) {
            error_log("FirebaseAuth: Failed to load public keys - " . $e->getMessage());
            return false;
        }
    }

    /**
     * Decodificación Base64 URL-safe
     */
    private function base64UrlDecode($data) {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/'));
    }

    /**
     * Extrae el token del header Authorization
     */
    public function getBearerToken() {
        $headers = $this->getAuthorizationHeader();

        if (!empty($headers)) {
            if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
                return $matches[1];
            }
        }

        return null;
    }

    /**
     * Obtiene el header Authorization
     */
    private function getAuthorizationHeader() {
        $headers = null;

        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER['Authorization']);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER['HTTP_AUTHORIZATION']);
        } elseif (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            $requestHeaders = array_combine(
                array_map('ucwords', array_keys($requestHeaders)),
                array_values($requestHeaders)
            );

            if (isset($requestHeaders['Authorization'])) {
                $headers = trim($requestHeaders['Authorization']);
            }
        }

        return $headers;
    }
}
