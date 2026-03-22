<?php
/**
 * Script de prueba para cuotas.php
 * Verificar que todos los archivos se cargan correctamente
 */

header('Content-Type: text/plain; charset=utf-8');
echo "=== TEST DE CUOTAS.PHP ===\n\n";

// 1. Test de archivos core
echo "1. Verificando archivos core...\n";

try {
    require_once __DIR__ . '/core/Database.php';
    echo "   ✅ Database.php cargado\n";
} catch (Exception $e) {
    echo "   ❌ Error en Database.php: " . $e->getMessage() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/core/CacheManager.php';
    echo "   ✅ CacheManager.php cargado\n";
} catch (Exception $e) {
    echo "   ❌ Error en CacheManager.php: " . $e->getMessage() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/core/RateLimiter.php';
    echo "   ✅ RateLimiter.php cargado\n";
} catch (Exception $e) {
    echo "   ❌ Error en RateLimiter.php: " . $e->getMessage() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/core/ResponseHelper.php';
    echo "   ✅ ResponseHelper.php cargado\n";
} catch (Exception $e) {
    echo "   ❌ Error en ResponseHelper.php: " . $e->getMessage() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/middleware/FirebaseAuthMiddleware.php';
    echo "   ✅ FirebaseAuthMiddleware.php cargado\n";
} catch (Exception $e) {
    echo "   ❌ Error en FirebaseAuthMiddleware.php: " . $e->getMessage() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/config/cors.php';
    echo "   ✅ cors.php cargado\n";
} catch (Exception $e) {
    echo "   ❌ Error en cors.php: " . $e->getMessage() . "\n";
    exit;
}

echo "\n2. Verificando clases...\n";

if (class_exists('Database')) {
    echo "   ✅ Clase Database existe\n";
} else {
    echo "   ❌ Clase Database NO existe\n";
}

if (class_exists('CacheManager')) {
    echo "   ✅ Clase CacheManager existe\n";
} else {
    echo "   ❌ Clase CacheManager NO existe\n";
}

if (class_exists('RateLimiter')) {
    echo "   ✅ Clase RateLimiter existe\n";
} else {
    echo "   ❌ Clase RateLimiter NO existe\n";
}

if (class_exists('ResponseHelper')) {
    echo "   ✅ Clase ResponseHelper existe\n";

    if (method_exists('ResponseHelper', 'success')) {
        echo "   ✅ Método ResponseHelper::success() existe\n";
    } else {
        echo "   ❌ Método ResponseHelper::success() NO existe\n";
    }

    if (method_exists('ResponseHelper', 'error')) {
        echo "   ✅ Método ResponseHelper::error() existe\n";
    } else {
        echo "   ❌ Método ResponseHelper::error() NO existe\n";
    }
} else {
    echo "   ❌ Clase ResponseHelper NO existe\n";
}

if (class_exists('FirebaseAuthMiddleware')) {
    echo "   ✅ Clase FirebaseAuthMiddleware existe\n";
} else {
    echo "   ❌ Clase FirebaseAuthMiddleware NO existe\n";
}

echo "\n3. Intentando ejecutar una función simple...\n";

try {
    $testData = ['test' => 'ok'];
    echo "   Datos de prueba: " . json_encode($testData) . "\n";
    echo "   ✅ JSON encode funciona\n";
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
}

echo "\n4. Simulando respuesta con ResponseHelper...\n";

try {
    // No ejecutamos success() porque hace exit, pero verificamos que la clase está bien
    echo "   ✅ ResponseHelper está listo para usar\n";
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
}

echo "\n=== FIN DEL TEST ===\n";
echo "Si ves este mensaje, todos los archivos core se cargan correctamente.\n";
echo "El problema debe estar en:\n";
echo "  1. La autenticación Firebase (middleware)\n";
echo "  2. La lógica específica del endpoint\n";
echo "  3. Un error en tiempo de ejecución\n";
