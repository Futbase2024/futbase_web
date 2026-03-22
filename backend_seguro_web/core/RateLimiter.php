<?php
/**
 * Rate Limiter basado en archivos
 * Protege contra ataques de fuerza bruta y DDoS
 */
class RateLimiter {
    private $cacheDir;
    private $maxRequests;
    private $timeWindow;

    /**
     * @param int $maxRequests Máximo de requests permitidos
     * @param int $timeWindow Ventana de tiempo en segundos
     */
    public function __construct($maxRequests = 100, $timeWindow = 60) {
        $this->cacheDir = __DIR__ . '/../cache/rate_limit/';
        $this->maxRequests = $maxRequests;
        $this->timeWindow = $timeWindow;

        // Crear directorio si no existe
        if (!is_dir($this->cacheDir)) {
            mkdir($this->cacheDir, 0755, true);
        }
    }

    /**
     * Verifica si el cliente ha excedido el rate limit
     *
     * @param string $identifier Identificador único (IP, user_id, etc.)
     * @return bool true si está permitido, false si excede el límite
     */
    public function isAllowed($identifier) {
        $key = $this->generateKey($identifier);
        $file = $this->cacheDir . $key;

        // Limpiar archivos antiguos periódicamente
        $this->cleanupOldFiles();

        // Si el archivo no existe, crear nuevo registro
        if (!file_exists($file)) {
            $this->createRecord($file);
            return true;
        }

        // Leer registro actual
        $record = json_decode(file_get_contents($file), true);

        if (!$record) {
            $this->createRecord($file);
            return true;
        }

        $now = time();
        $windowStart = $now - $this->timeWindow;

        // Filtrar requests dentro de la ventana de tiempo
        $record['requests'] = array_filter($record['requests'], function($timestamp) use ($windowStart) {
            return $timestamp > $windowStart;
        });

        // Verificar si excede el límite
        if (count($record['requests']) >= $this->maxRequests) {
            $identifierType = filter_var($identifier, FILTER_VALIDATE_IP) ? 'IP' : 'User';
            error_log("[RateLimiter] Limit exceeded for {$identifierType}: {$identifier} ({$this->maxRequests} req/{$this->timeWindow}s)");
            return false;
        }

        // Agregar nuevo request
        $record['requests'][] = $now;
        file_put_contents($file, json_encode($record));

        return true;
    }

    /**
     * Obtiene cuántos requests quedan disponibles
     */
    public function getRemainingRequests($identifier) {
        $key = $this->generateKey($identifier);
        $file = $this->cacheDir . $key;

        if (!file_exists($file)) {
            return $this->maxRequests;
        }

        $record = json_decode(file_get_contents($file), true);

        if (!$record) {
            return $this->maxRequests;
        }

        $now = time();
        $windowStart = $now - $this->timeWindow;

        // Filtrar requests dentro de la ventana
        $record['requests'] = array_filter($record['requests'], function($timestamp) use ($windowStart) {
            return $timestamp > $windowStart;
        });

        return max(0, $this->maxRequests - count($record['requests']));
    }

    /**
     * Resetea el contador para un identificador
     */
    public function reset($identifier) {
        $key = $this->generateKey($identifier);
        $file = $this->cacheDir . $key;

        if (file_exists($file)) {
            unlink($file);
        }
    }

    /**
     * Genera una clave única para el identificador
     */
    private function generateKey($identifier) {
        return 'rl_' . hash('sha256', $identifier) . '.json';
    }

    /**
     * Crea un nuevo registro de rate limit
     */
    private function createRecord($file) {
        $record = [
            'requests' => [time()],
            'created_at' => time()
        ];
        file_put_contents($file, json_encode($record));
    }

    /**
     * Limpia archivos antiguos (más de 1 hora)
     */
    private function cleanupOldFiles() {
        // Solo limpiar 1% de las veces para no sobrecargar
        if (rand(1, 100) !== 1) {
            return;
        }

        $files = glob($this->cacheDir . 'rl_*.json');
        $threshold = time() - 3600; // 1 hora

        foreach ($files as $file) {
            if (filemtime($file) < $threshold) {
                @unlink($file);
            }
        }
    }

    /**
     * Obtiene la IP del cliente (considera proxies)
     */
    public static function getClientIP() {
        $ip = '';

        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
        } elseif (!empty($_SERVER['REMOTE_ADDR'])) {
            $ip = $_SERVER['REMOTE_ADDR'];
        }

        return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : 'unknown';
    }
}
