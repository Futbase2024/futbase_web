<?php
/**
 * Test directo del endpoint de cuotas
 * Muestra errores PHP en texto plano
 */

// Mostrar TODOS los errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Output en texto plano para ver errores
header('Content-Type: text/plain; charset=utf-8');

echo "=== INICIANDO TEST DE CUOTAS ===\n\n";

// Cargar archivos uno por uno
echo "1. Cargando Database.php...\n";
try {
    require_once __DIR__ . '/core/Database.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "2. Cargando CacheManager.php...\n";
try {
    require_once __DIR__ . '/core/CacheManager.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "3. Cargando RateLimiter.php...\n";
try {
    require_once __DIR__ . '/core/RateLimiter.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "4. Cargando ResponseHelper.php...\n";
try {
    require_once __DIR__ . '/core/ResponseHelper.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "5. Cargando FirebaseAuth.php...\n";
try {
    require_once __DIR__ . '/core/FirebaseAuth.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "6. Cargando FirebaseAuthMiddleware.php...\n";
try {
    require_once __DIR__ . '/middleware/FirebaseAuthMiddleware.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "7. Cargando cors.php...\n";
try {
    require_once __DIR__ . '/config/cors.php';
    echo "   ✅ OK\n";
} catch (Exception $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "\n8. Verificando que ResponseHelper::success() funciona...\n";
if (class_exists('ResponseHelper') && method_exists('ResponseHelper', 'success')) {
    echo "   ✅ ResponseHelper::success() existe\n";
} else {
    echo "   ❌ ResponseHelper::success() NO existe\n";
}

echo "\n9. Intentando instanciar Database...\n";
try {
    $db = Database::getInstance();
    echo "   ✅ Database instanciada\n";
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
    echo "   Stack trace:\n";
    echo $e->getTraceAsString() . "\n";
}

echo "\n10. Intentando instanciar CacheManager...\n";
try {
    $cache = new CacheManager();
    echo "   ✅ CacheManager instanciado\n";
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
    echo "   Stack trace:\n";
    echo $e->getTraceAsString() . "\n";
}

echo "\n11. Intentando instanciar RateLimiter...\n";
try {
    $rateLimiter = new RateLimiter();
    echo "   ✅ RateLimiter instanciado\n";
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
    echo "   Stack trace:\n";
    echo $e->getTraceAsString() . "\n";
}

echo "\n=== FIN DEL TEST ===\n";
echo "Si llegaste aquí sin errores, todos los archivos core están correctos.\n";
echo "El problema está en:\n";
echo "  1. La autenticación Firebase (si el endpoint requiere auth)\n";
echo "  2. La lógica específica del endpoint\n";
echo "  3. Una consulta SQL que falla\n";
