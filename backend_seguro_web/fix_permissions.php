<?php
/**
 * Script PHP para arreglar permisos
 * Ejecuta este archivo desde el navegador una sola vez
 */

header('Content-Type: application/json; charset=utf-8');

$results = [];

// Crear carpetas si no existen
$folders = [
    'cache',
    'cache/data',
    'cache/rate_limit',
    'logs',
];

foreach ($folders as $folder) {
    $path = __DIR__ . '/' . $folder;

    if (!is_dir($path)) {
        $created = mkdir($path, 0777, true);
        $results[$folder] = [
            'action' => 'created',
            'success' => $created,
            'permissions' => $created ? substr(sprintf('%o', fileperms($path)), -4) : 'N/A'
        ];
    } else {
        // Intentar cambiar permisos
        $changed = chmod($path, 0777);
        $results[$folder] = [
            'action' => 'chmod',
            'success' => $changed,
            'permissions' => substr(sprintf('%o', fileperms($path)), -4),
            'writable' => is_writable($path)
        ];
    }
}

// Crear archivos .gitkeep para mantener las carpetas en git
$gitkeeps = [
    'cache/data/.gitkeep',
    'cache/rate_limit/.gitkeep',
    'logs/.gitkeep',
];

foreach ($gitkeeps as $gitkeep) {
    $path = __DIR__ . '/' . $gitkeep;
    if (!file_exists($path)) {
        file_put_contents($path, '');
    }
}

// Verificar estado final
$cache_data_writable = is_writable(__DIR__ . '/cache/data');
$cache_rate_writable = is_writable(__DIR__ . '/cache/rate_limit');
$logs_writable = is_writable(__DIR__ . '/logs');

$all_ok = $cache_data_writable && $cache_rate_writable && $logs_writable;

// Respuesta
http_response_code($all_ok ? 200 : 500);
echo json_encode([
    'success' => $all_ok,
    'message' => $all_ok
        ? '✅ Permisos configurados correctamente'
        : '❌ Algunos permisos no se pudieron configurar',
    'details' => $results,
    'final_status' => [
        'cache_data_writable' => $cache_data_writable,
        'cache_rate_limit_writable' => $cache_rate_writable,
        'logs_writable' => $logs_writable,
    ],
    'instructions' => $all_ok
        ? 'Ahora puedes borrar este archivo: fix_permissions.php'
        : 'Si los permisos no se configuraron, ejecuta manualmente: chmod -R 777 cache/ logs/',
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
