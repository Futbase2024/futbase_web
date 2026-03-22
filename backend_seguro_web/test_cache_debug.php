<?php
/**
 * Debug detallado de cache->clear()
 */

header('Content-Type: text/plain; charset=utf-8');

require_once __DIR__ . '/core/CacheManager.php';

echo "=== DEBUG CACHE CLEAR ===\n\n";

$cache = new CacheManager(300);

// Crear entrada de prueba
echo "1. Creando entrada: equipos_club_133_6\n";
$cache->set("equipos_club_133_6", ["test" => "data"], 300);

// Listar archivos en el directorio de caché
$cacheDir = __DIR__ . '/cache/data/';
echo "\n2. Archivos en directorio de caché:\n";
$files = glob($cacheDir . '*.cache');
foreach ($files as $file) {
    $content = file_get_contents($file);
    $data = json_decode($content, true);
    echo "   Archivo: " . basename($file) . "\n";
    echo "   Key guardada: " . ($data['key'] ?? 'NO KEY') . "\n";
    echo "   Contenido: " . substr($content, 0, 200) . "...\n\n";
}

// Probar el patrón
$pattern = "equipos_*";
echo "\n3. Patrón a buscar: '$pattern'\n";

// Convertir patrón a regex (como lo hace el código ACTUALIZADO)
$patternEscaped = str_replace('*', '__ASTERISK__', $pattern);
$patternEscaped = preg_quote($patternEscaped, '/');
$patternEscaped = str_replace('__ASTERISK__', '.*', $patternEscaped);
$regex = '/^' . $patternEscaped . '$/';
echo "   Regex generada: $regex\n\n";

// Probar con las keys
$testKeys = [
    "equipos_club_133_6",
    "equipos_temporada_6",
    "jugadores_club_133_6"
];

echo "4. Probando regex con keys:\n";
foreach ($testKeys as $key) {
    $matches = preg_match($regex, $key);
    echo "   '$key' -> " . ($matches ? "✅ MATCH" : "❌ NO MATCH") . "\n";
}

echo "\n=== FIN DEBUG ===\n";

// Limpiar
$cache->clear();
