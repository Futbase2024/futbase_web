<?php
/**
 * Diagnóstico detallado de ropa.php
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== DIAGNÓSTICO ROPA.PHP ===\n\n";

// 1. Verificar archivos core
echo "1. Verificando archivos core:\n";
$files = [
    'init.php' => __DIR__ . '/init.php',
    'Database.php' => __DIR__ . '/core/Database.php',
    'CacheManager.php' => __DIR__ . '/core/CacheManager.php',
    'ResponseHelper.php' => __DIR__ . '/core/ResponseHelper.php',
    'FirebaseAuthMiddleware.php' => __DIR__ . '/middleware/FirebaseAuthMiddleware.php',
];

foreach ($files as $name => $path) {
    if (file_exists($path)) {
        echo "   ✅ $name existe\n";
    } else {
        echo "   ❌ $name NO EXISTE en: $path\n";
    }
}

// 2. Verificar endpoint
echo "\n2. Verificando endpoint ropa.php:\n";
$ropaPath = __DIR__ . '/endpoints/ropa.php';
if (file_exists($ropaPath)) {
    echo "   ✅ ropa.php existe\n";

    // Verificar que tiene init.php
    $content = file_get_contents($ropaPath);
    if (strpos($content, 'init.php') !== false) {
        echo "   ✅ Contiene require de init.php\n";
    } else {
        echo "   ❌ NO contiene require de init.php\n";
    }

    // Mostrar primeras líneas
    $lines = explode("\n", $content);
    echo "\n   Primeras 30 líneas de ropa.php:\n";
    for ($i = 0; $i < min(30, count($lines)); $i++) {
        echo "   " . ($i + 1) . ": " . $lines[$i] . "\n";
    }
} else {
    echo "   ❌ ropa.php NO EXISTE\n";
}

// 3. Verificar logs
echo "\n3. Verificando logs:\n";
$logDir = __DIR__ . '/logs';
if (is_dir($logDir)) {
    echo "   ✅ Directorio logs existe\n";
    $logFiles = scandir($logDir);
    foreach ($logFiles as $file) {
        if ($file != '.' && $file != '..' && $file != '.gitkeep') {
            $logPath = $logDir . '/' . $file;
            $size = filesize($logPath);
            echo "   📄 $file ($size bytes)\n";

            if ($size > 0 && $size < 10000) {
                echo "      Contenido:\n";
                echo "      " . str_replace("\n", "\n      ", file_get_contents($logPath)) . "\n";
            }
        }
    }
} else {
    echo "   ❌ Directorio logs NO EXISTE\n";
}

echo "\n=== FIN DIAGNÓSTICO ===\n";
