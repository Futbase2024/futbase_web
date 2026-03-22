<?php
/**
 * Test para verificar que cache->clear() funciona correctamente
 */

header('Content-Type: text/plain; charset=utf-8');

require_once __DIR__ . '/core/CacheManager.php';

echo "=== TEST CACHE CLEAR CON WILDCARDS ===\n\n";

$cache = new CacheManager(300);

// Test 1: Crear algunas entradas de caché
echo "1. Creando entradas de caché de prueba...\n";
$cache->set("equipos_club_133_6", ["test" => "data1"], 300);
$cache->set("equipos_club_999_6", ["test" => "data2"], 300);
$cache->set("equipos_temporada_6", ["test" => "data3"], 300);
$cache->set("jugadores_club_133_6", ["test" => "data4"], 300);
echo "   ✅ 4 entradas creadas\n\n";

// Test 2: Verificar que existen
echo "2. Verificando que existen...\n";
echo "   equipos_club_133_6: " . ($cache->has("equipos_club_133_6") ? "✅ Existe" : "❌ No existe") . "\n";
echo "   equipos_club_999_6: " . ($cache->has("equipos_club_999_6") ? "✅ Existe" : "❌ No existe") . "\n";
echo "   equipos_temporada_6: " . ($cache->has("equipos_temporada_6") ? "✅ Existe" : "❌ No existe") . "\n";
echo "   jugadores_club_133_6: " . ($cache->has("jugadores_club_133_6") ? "✅ Existe" : "❌ No existe") . "\n\n";

// Test 3: Limpiar con patrón equipos_*
echo "3. Limpiando con patrón 'equipos_*'...\n";
$deleted = $cache->clear("equipos_*");
echo "   ✅ $deleted archivos eliminados\n\n";

// Test 4: Verificar qué queda
echo "4. Verificando qué queda después de clear('equipos_*')...\n";
echo "   equipos_club_133_6: " . ($cache->has("equipos_club_133_6") ? "❌ SIGUE EXISTIENDO (ERROR)" : "✅ Eliminado") . "\n";
echo "   equipos_club_999_6: " . ($cache->has("equipos_club_999_6") ? "❌ SIGUE EXISTIENDO (ERROR)" : "✅ Eliminado") . "\n";
echo "   equipos_temporada_6: " . ($cache->has("equipos_temporada_6") ? "❌ SIGUE EXISTIENDO (ERROR)" : "✅ Eliminado") . "\n";
echo "   jugadores_club_133_6: " . ($cache->has("jugadores_club_133_6") ? "✅ Existe (correcto, no debería borrarse)" : "❌ Eliminado (ERROR)") . "\n\n";

// Test 5: Verificar la versión de CacheManager
echo "5. Verificando versión de CacheManager...\n";
$reflection = new ReflectionClass($cache);
$method = $reflection->getMethod('set');
$source = file_get_contents($reflection->getFileName());

if (strpos($source, "'key' => \$key") !== false) {
    echo "   ✅ CacheManager tiene la modificación (guarda 'key' original)\n";
} else {
    echo "   ❌ CacheManager NO tiene la modificación\n";
}

if (strpos($source, "preg_match(\$regex") !== false) {
    echo "   ✅ CacheManager tiene clear() mejorado con regex\n";
} else {
    echo "   ❌ CacheManager NO tiene clear() mejorado\n";
}

echo "\n=== FIN TEST ===\n";

// Limpiar todo
$cache->clear();
