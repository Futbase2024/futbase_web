<?php
/**
 * Verificar logs más recientes de ropa.php
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== LOGS RECIENTES PHP ===\n\n";

$logFile = __DIR__ . '/logs/php_errors.log';

if (file_exists($logFile)) {
    $content = file_get_contents($logFile);
    $lines = explode("\n", $content);

    // Mostrar últimas 50 líneas
    $recentLines = array_slice($lines, -50);

    echo "Últimas 50 líneas del log:\n";
    echo "─────────────────────────────\n";
    echo implode("\n", $recentLines);
    echo "\n─────────────────────────────\n";

    // Filtrar solo errores de ropa.php
    echo "\nErrores específicos de ropa.php:\n";
    echo "─────────────────────────────\n";
    foreach ($lines as $line) {
        if (stripos($line, 'ropa.php') !== false) {
            echo $line . "\n";
        }
    }
} else {
    echo "❌ Archivo de log no encontrado: $logFile\n";
}

echo "\n=== FIN LOGS ===\n";
