<?php
/**
 * Script para limpiar OPcache
 * Subir a: /backend_seguro_web/clear_cache.php
 * Ejecutar desde: https://futbase.es/backend_seguro_web/clear_cache.php
 * IMPORTANTE: Eliminar después de usar por seguridad
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== LIMPIEZA DE CACHÉ PHP ===\n\n";

// 1. Verificar si OPcache está disponible
if (function_exists('opcache_reset')) {
    echo "OPcache detectado\n";

    // Obtener estado antes
    if (function_exists('opcache_get_status')) {
        $status = opcache_get_status();
        echo "Estado antes de limpiar:\n";
        echo "- Scripts cacheados: " . $status['opcache_statistics']['num_cached_scripts'] . "\n";
        echo "- Memoria usada: " . round($status['memory_usage']['used_memory'] / 1024 / 1024, 2) . " MB\n";
    }

    // Limpiar caché
    echo "\nLimpiando OPcache...\n";
    if (opcache_reset()) {
        echo "✅ OPcache limpiado exitosamente\n";
    } else {
        echo "❌ Error al limpiar OPcache\n";
    }

    // Verificar estado después
    if (function_exists('opcache_get_status')) {
        sleep(1); // Esperar un momento
        $status = opcache_get_status();
        echo "\nEstado después de limpiar:\n";
        echo "- Scripts cacheados: " . $status['opcache_statistics']['num_cached_scripts'] . "\n";
        echo "- Memoria usada: " . round($status['memory_usage']['used_memory'] / 1024 / 1024, 2) . " MB\n";
    }

} else {
    echo "⚠️  OPcache no está disponible o no está habilitado\n";
}

// 2. Intentar limpiar otros tipos de caché
echo "\n=== OTROS CACHÉS ===\n";

// Limpiar caché de realpath
if (function_exists('clearstatcache')) {
    clearstatcache(true);
    echo "✅ clearstatcache() ejecutado\n";
}

// 3. Mostrar información útil
echo "\n=== INFORMACIÓN DEL SISTEMA ===\n";
echo "PHP Version: " . phpversion() . "\n";
echo "Server Time: " . date('Y-m-d H:i:s') . "\n";
echo "Server Software: " . ($_SERVER['SERVER_SOFTWARE'] ?? 'Desconocido') . "\n";

echo "\n=== INSTRUCCIONES ===\n";
echo "1. Si OPcache se limpió correctamente, prueba tu aplicación ahora\n";
echo "2. Si el problema persiste, verifica que los archivos se subieron correctamente\n";
echo "3. Ejecuta diagnostico.php para ver el estado de los archivos\n";
echo "4. ⚠️  ELIMINA este archivo (clear_cache.php) por seguridad después de usar\n";

echo "\n=== FIN ===\n";
