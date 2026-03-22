<?php
// Script para verificar si rol_requests.php tiene los cambios
header('Content-Type: text/plain; charset=utf-8');

$file = __DIR__ . '/endpoints/rol_requests.php';

if (!file_exists($file)) {
    echo "❌ Archivo no encontrado\n";
    exit;
}

echo "=== VERIFICACIÓN DE VERSIÓN ===\n\n";
echo "Archivo: $file\n";
echo "Última modificación: " . date('Y-m-d H:i:s', filemtime($file)) . "\n";
echo "Tamaño: " . filesize($file) . " bytes\n\n";

// Buscar la línea clave que indica si tiene los cambios
$content = file_get_contents($file);

if (strpos($content, "ini_set('display_errors', 0); // NO mostrar errores en HTML") !== false) {
    echo "✅ El archivo TIENE los cambios (display_errors configurado)\n";
} else {
    echo "❌ El archivo NO TIENE los cambios\n";
}

if (strpos($content, "error_reporting(E_ALL);") !== false) {
    echo "✅ error_reporting configurado\n";
} else {
    echo "❌ error_reporting NO configurado\n";
}

// Mostrar las primeras líneas después de los headers
echo "\n=== Primeras 45 líneas del archivo ===\n";
$lines = explode("\n", $content);
for ($i = 0; $i < min(45, count($lines)); $i++) {
    echo sprintf("%3d: %s\n", $i + 1, $lines[$i]);
}
