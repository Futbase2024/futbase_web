<?php
/**
 * Script de diagnóstico para el servidor
 * Subir este archivo a: /backend_seguro_web/diagnostico.php
 * Acceder desde: https://futbase.es/backend_seguro_web/diagnostico.php
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== DIAGNÓSTICO DEL SERVIDOR ===\n";
echo "Fecha: " . date('Y-m-d H:i:s') . "\n\n";

// 1. Información de PHP
echo "1. INFORMACIÓN DE PHP:\n";
echo "   Versión PHP: " . phpversion() . "\n";
echo "   OPcache habilitado: " . (function_exists('opcache_get_status') ? 'SÍ' : 'NO') . "\n";
if (function_exists('opcache_get_status')) {
    $opcache = opcache_get_status();
    echo "   OPcache activo: " . ($opcache['opcache_enabled'] ? 'SÍ' : 'NO') . "\n";
}
echo "\n";

// 2. Verificar archivos core
echo "2. ARCHIVOS CORE:\n";
$coreFiles = [
    'ResponseHelper.php',
    'Database.php',
    'CacheManager.php',
    'RateLimiter.php',
];

foreach ($coreFiles as $file) {
    $path = __DIR__ . '/core/' . $file;
    if (file_exists($path)) {
        $size = filesize($path);
        $modified = date('Y-m-d H:i:s', filemtime($path));
        echo "   ✅ $file ($size bytes, modificado: $modified)\n";
    } else {
        echo "   ❌ $file NO EXISTE\n";
    }
}
echo "\n";

// 3. Verificar ResponseHelper específicamente
echo "3. VERIFICACIÓN DE ResponseHelper:\n";
require_once __DIR__ . '/core/ResponseHelper.php';

if (class_exists('ResponseHelper')) {
    echo "   ✅ Clase ResponseHelper existe\n";
    echo "   ✅ Método success(): " . (method_exists('ResponseHelper', 'success') ? 'SÍ' : 'NO') . "\n";
    echo "   ✅ Método error(): " . (method_exists('ResponseHelper', 'error') ? 'SÍ' : 'NO') . "\n";
} else {
    echo "   ❌ Clase ResponseHelper NO EXISTE\n";
}

if (function_exists('respondSuccess')) {
    echo "   ✅ Función global respondSuccess() existe\n";
} else {
    echo "   ❌ Función global respondSuccess() NO existe\n";
}
echo "\n";

// 4. Verificar endpoints
echo "4. ARCHIVOS ENDPOINT:\n";
$endpoints = [
    'cuotas.php',
    'lesiones.php',
    'jugadores.php',
    'equipos.php',
    'partidos.php',
];

foreach ($endpoints as $file) {
    $path = __DIR__ . '/endpoints/' . $file;
    if (file_exists($path)) {
        $size = filesize($path);
        $modified = date('Y-m-d H:i:s', filemtime($path));
        echo "   ✅ $file ($size bytes, modificado: $modified)\n";
    } else {
        echo "   ❌ $file NO EXISTE\n";
    }
}
echo "\n";

// 5. Verificar contenido específico de cuotas.php
echo "5. ANÁLISIS DE cuotas.php:\n";
$cuotasPath = __DIR__ . '/endpoints/cuotas.php';
if (file_exists($cuotasPath)) {
    $content = file_get_contents($cuotasPath);

    // Buscar funciones duplicadas
    $hasDuplicate = strpos($content, 'function respondSuccess') !== false;
    echo "   Tiene función respondSuccess duplicada: " . ($hasDuplicate ? '❌ SÍ' : '✅ NO') . "\n";

    // Buscar parámetro correcto
    $hasIdjugador = strpos($content, "\$_GET['idjugador']") !== false;
    $hasIdplayer = strpos($content, "\$_GET['idplayer']") !== false;
    echo "   Usa 'idjugador': " . ($hasIdjugador ? '✅ SÍ' : '❌ NO') . "\n";
    echo "   Usa 'idplayer' (antiguo): " . ($hasIdplayer ? '❌ SÍ' : '✅ NO') . "\n";
} else {
    echo "   ❌ Archivo no encontrado\n";
}
echo "\n";

// 6. Verificar contenido específico de lesiones.php
echo "6. ANÁLISIS DE lesiones.php:\n";
$lesionesPath = __DIR__ . '/endpoints/lesiones.php';
if (file_exists($lesionesPath)) {
    $content = file_get_contents($lesionesPath);

    // Buscar debugPrint
    $debugPrintPos = strpos($content, 'function debugPrint');
    $firstUsePos = strpos($content, 'debugPrint("');

    if ($debugPrintPos !== false && $firstUsePos !== false) {
        echo "   debugPrint definida ANTES de usarse: " . ($debugPrintPos < $firstUsePos ? '✅ SÍ' : '❌ NO') . "\n";
        echo "   Posición definición: $debugPrintPos\n";
        echo "   Posición primer uso: $firstUsePos\n";
    } else {
        echo "   ❌ No se encontró debugPrint\n";
    }
} else {
    echo "   ❌ Archivo no encontrado\n";
}
echo "\n";

// 7. Test de ResponseHelper en acción
echo "7. TEST DE ResponseHelper:\n";
try {
    ob_start();
    // No podemos ejecutar success() porque hace exit, pero podemos verificar que existe
    echo "   ✅ ResponseHelper listo para usar\n";
    ob_end_clean();
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
}

echo "\n=== FIN DIAGNÓSTICO ===\n";
echo "\nSi ves este mensaje, el archivo está funcionando correctamente.\n";
echo "Compara las fechas de modificación con tus archivos locales.\n";
echo "Si las fechas son antiguas, los archivos NO se subieron correctamente.\n";
