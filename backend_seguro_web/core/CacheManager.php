<?php
/**
 * Gestor de caché basado en archivos
 * Compatible con Arsys (no requiere extensiones especiales)
 */
class CacheManager {
    private $cacheDir;
    private $defaultTTL;

    /**
     * @param int $defaultTTL Tiempo de vida por defecto en segundos
     */
    public function __construct($defaultTTL = 300) {
        $this->cacheDir = __DIR__ . '/../cache/data/';
        $this->defaultTTL = $defaultTTL;

        // Crear directorio si no existe
        if (!is_dir($this->cacheDir)) {
            mkdir($this->cacheDir, 0755, true);
        }
    }

    /**
     * Guarda datos en caché
     *
     * @param string $key Clave única
     * @param mixed $data Datos a cachear
     * @param int|null $ttl Tiempo de vida en segundos (null = usar default)
     * @return bool
     */
    public function set($key, $data, $ttl = null) {
        try {
            $ttl = $ttl ?? $this->defaultTTL;
            $file = $this->getCacheFile($key);

            $cacheData = [
                'key' => $key,  // Guardar la key original para poder buscar por patrón
                'data' => $data,
                'expires_at' => time() + $ttl,
                'created_at' => time()
            ];

            return file_put_contents($file, json_encode($cacheData)) !== false;

        } catch (Exception $e) {
            error_log("Cache set error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtiene datos de la caché
     *
     * @param string $key Clave única
     * @return mixed|null Datos cacheados o null si no existe/expiró
     */
    public function get($key) {
        try {
            $file = $this->getCacheFile($key);

            if (!file_exists($file)) {
                return null;
            }

            $content = file_get_contents($file);
            $cacheData = json_decode($content, true);

            if (!$cacheData) {
                return null;
            }

            // Verificar si expiró
            if ($cacheData['expires_at'] < time()) {
                $this->delete($key);
                return null;
            }

            return $cacheData['data'];

        } catch (Exception $e) {
            error_log("Cache get error: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Verifica si existe una clave en caché y no ha expirado
     */
    public function has($key) {
        return $this->get($key) !== null;
    }

    /**
     * Elimina una entrada de la caché
     */
    public function delete($key) {
        $file = $this->getCacheFile($key);

        if (file_exists($file)) {
            return @unlink($file);
        }

        return true;
    }

    /**
     * Alias de delete() - Elimina una entrada de la caché
     */
    public function forget($key) {
        return $this->delete($key);
    }

    /**
     * Alias de delete() - Elimina una entrada de la caché
     */
    public function invalidate($key) {
        return $this->delete($key);
    }

    /**
     * Limpia toda la caché o por patrón
     *
     * @param string|null $pattern Patrón para filtrar (ej: 'partidos_*')
     * @return int Número de archivos eliminados
     */
    public function clear($pattern = null) {
        try {
            $deleted = 0;
            $files = glob($this->cacheDir . '*.cache');

            if ($pattern === null) {
                // Limpiar todo
                foreach ($files as $file) {
                    if (@unlink($file)) {
                        $deleted++;
                    }
                }
            } else {
                // Limpiar por patrón: convertir wildcard a regex
                // Primero escapar caracteres especiales de regex, EXCEPTO *
                $patternEscaped = str_replace('*', '__ASTERISK__', $pattern);
                $patternEscaped = preg_quote($patternEscaped, '/');
                $patternEscaped = str_replace('__ASTERISK__', '.*', $patternEscaped);
                $regex = '/^' . $patternEscaped . '$/';

                foreach ($files as $file) {
                    $content = @file_get_contents($file);
                    if ($content === false) {
                        continue;
                    }

                    $cacheData = json_decode($content, true);
                    if (!$cacheData || !isset($cacheData['key'])) {
                        continue;
                    }

                    // Comparar la key original con el patrón
                    if (preg_match($regex, $cacheData['key'])) {
                        if (@unlink($file)) {
                            $deleted++;
                        }
                    }
                }
            }

            return $deleted;

        } catch (Exception $e) {
            error_log("Cache clear error: " . $e->getMessage());
            return 0;
        }
    }

    /**
     * Obtiene o establece caché (remember pattern)
     *
     * @param string $key Clave única
     * @param callable $callback Función que retorna los datos si no están en caché
     * @param int|null $ttl Tiempo de vida
     * @return mixed
     */
    public function remember($key, $callback, $ttl = null) {
        $data = $this->get($key);

        if ($data !== null) {
            return $data;
        }

        $data = $callback();
        $this->set($key, $data, $ttl);

        return $data;
    }

    /**
     * Limpia entradas expiradas (garbage collection)
     */
    public function cleanupExpired() {
        try {
            $files = glob($this->cacheDir . '*.cache');
            $now = time();
            $cleaned = 0;

            foreach ($files as $file) {
                $content = @file_get_contents($file);

                if ($content === false) {
                    continue;
                }

                $cacheData = json_decode($content, true);

                if ($cacheData && $cacheData['expires_at'] < $now) {
                    @unlink($file);
                    $cleaned++;
                }
            }

            return $cleaned;

        } catch (Exception $e) {
            error_log("Cache cleanup error: " . $e->getMessage());
            return 0;
        }
    }

    /**
     * Genera el nombre del archivo de caché
     */
    private function getCacheFile($key) {
        $safeKey = preg_replace('/[^a-zA-Z0-9_-]/', '_', $key);
        return $this->cacheDir . hash('sha256', $safeKey) . '.cache';
    }

    /**
     * Obtiene estadísticas de la caché
     */
    public function getStats() {
        $files = glob($this->cacheDir . '*.cache');
        $totalSize = 0;
        $expired = 0;
        $valid = 0;
        $now = time();

        foreach ($files as $file) {
            $totalSize += filesize($file);

            $content = @file_get_contents($file);
            if ($content !== false) {
                $cacheData = json_decode($content, true);
                if ($cacheData) {
                    if ($cacheData['expires_at'] < $now) {
                        $expired++;
                    } else {
                        $valid++;
                    }
                }
            }
        }

        return [
            'total_entries' => count($files),
            'valid_entries' => $valid,
            'expired_entries' => $expired,
            'total_size_bytes' => $totalSize,
            'total_size_mb' => round($totalSize / 1024 / 1024, 2)
        ];
    }
}
