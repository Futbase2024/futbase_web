<?php
/**
 * Test detallado de rol_requests con captura de output buffer
 */

// Capturar TODO el output
ob_start();

// Configurar errores
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);

echo "=== INICIO TEST ===\n\n";

try {
    echo "1. Cargando Database.php...\n";
    require_once __DIR__ . '/core/Database.php';
    echo "   ✅ Database.php cargado\n\n";

    echo "2. Cargando otros archivos...\n";
    require_once __DIR__ . '/core/CacheManager.php';
    echo "   ✅ CacheManager.php cargado\n";
    require_once __DIR__ . '/core/ResponseHelper.php';
    echo "   ✅ ResponseHelper.php cargado\n";
    require_once __DIR__ . '/core/Validator.php';
    echo "   ✅ Validator.php cargado\n\n";

    echo "3. Obteniendo instancia de Database...\n";
    $db = Database::getInstance();
    echo "   ✅ Database instanciado\n\n";

    echo "4. Creando CacheManager...\n";
    $cache = new CacheManager(300);
    echo "   ✅ CacheManager creado\n\n";

    echo "5. Ejecutando query a vrolpeticion...\n";
    $sql = 'SELECT * FROM vrolpeticion WHERE estado = ? ORDER BY fecha DESC';
    $result = $db->select($sql, [0]);
    echo "   ✅ Query exitosa\n";
    echo "   Registros encontrados: " . count($result) . "\n\n";

    echo "6. Simulando cache->remember...\n";
    $cacheKey = "test_rol_requests_state_submitted";
    $cachedResult = $cache->remember($cacheKey, function() use ($db) {
        $sql = 'SELECT * FROM vrolpeticion WHERE estado = ? ORDER BY fecha DESC';
        return $db->select($sql, [0]);
    }, 300);
    echo "   ✅ Cache remember exitoso\n";
    echo "   Registros: " . count($cachedResult) . "\n\n";

    echo "7. Convirtiendo a JSON...\n";
    $json = json_encode([
        'success' => true,
        'data' => $cachedResult
    ]);

    if ($json === false) {
        echo "   ❌ Error en json_encode: " . json_last_error_msg() . "\n";
    } else {
        echo "   ✅ JSON generado correctamente\n";
        echo "   Tamaño: " . strlen($json) . " bytes\n\n";
    }

    echo "=== TEST COMPLETADO CON ÉXITO ===\n";

} catch (Exception $e) {
    echo "\n❌ EXCEPCIÓN CAPTURADA:\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n";
}

// Capturar cualquier error que haya ocurrido
$output = ob_get_clean();

// Enviar headers DESPUÉS de capturar output
header('Content-Type: text/plain; charset=utf-8');

// Mostrar el output capturado
echo $output;

// Mostrar cualquier error de PHP que se haya logueado
echo "\n\n=== ÚLTIMOS ERRORES PHP ===\n";
$errors = error_get_last();
if ($errors) {
    print_r($errors);
} else {
    echo "No hay errores registrados\n";
}
