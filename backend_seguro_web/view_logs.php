<?php
/**
 * Visor de logs - Solo para debug
 * ELIMINAR en producción
 */

header('Content-Type: text/plain; charset=utf-8');

$logFile = __DIR__ . '/logs/php_errors.log';

if (!file_exists($logFile)) {
    echo "❌ Archivo de log no existe: $logFile\n";
    echo "\n¿Existe el directorio logs?\n";
    if (is_dir(__DIR__ . '/logs')) {
        echo "✅ Sí, directorio logs existe\n";
        echo "Archivos en logs:\n";
        $files = scandir(__DIR__ . '/logs');
        print_r($files);
    } else {
        echo "❌ No, directorio logs NO existe\n";
        echo "Crear con: mkdir " . __DIR__ . "/logs\n";
    }
    exit;
}

echo "=== ÚLTIMAS 50 LÍNEAS DEL LOG ===\n";
echo "Archivo: $logFile\n";
echo "Última modificación: " . date('Y-m-d H:i:s', filemtime($logFile)) . "\n";
echo "Tamaño: " . filesize($logFile) . " bytes\n\n";
echo "=======================================\n\n";

// Leer últimas 50 líneas
$lines = file($logFile);
$lastLines = array_slice($lines, -50);
echo implode('', $lastLines);

echo "\n\n=======================================\n";
echo "Total de líneas en el log: " . count($lines) . "\n";
