<?php
/**
 * Test mínimo de cuotas.php
 * Reproduce exactamente lo que hace el endpoint
 */

// Mostrar TODOS los errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: text/plain; charset=utf-8');

echo "=== TEST MINIMAL DE CUOTAS ===\n\n";

echo "1. Cargando archivos core...\n";
try {
    require_once __DIR__ . '/core/Database.php';
    echo "   ✅ Database.php\n";
} catch (Throwable $e) {
    echo "   ❌ ERROR en Database.php: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/core/CacheManager.php';
    echo "   ✅ CacheManager.php\n";
} catch (Throwable $e) {
    echo "   ❌ ERROR en CacheManager.php: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/core/RateLimiter.php';
    echo "   ✅ RateLimiter.php\n";
} catch (Throwable $e) {
    echo "   ❌ ERROR en RateLimiter.php: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    exit;
}

try {
    require_once __DIR__ . '/core/ResponseHelper.php';
    echo "   ✅ ResponseHelper.php\n";
} catch (Throwable $e) {
    echo "   ❌ ERROR en ResponseHelper.php: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    exit;
}

echo "\n2. Simulando parámetros de la petición...\n";
$_GET['action'] = 'getcuotabyplayertemp';
$_GET['idclub'] = '10';
$_GET['idtemporada'] = '6';
$_GET['idjugador'] = '3318';

echo "   action: {$_GET['action']}\n";
echo "   idclub: {$_GET['idclub']}\n";
echo "   idtemporada: {$_GET['idtemporada']}\n";
echo "   idjugador: {$_GET['idjugador']}\n";

echo "\n3. Instanciando objetos...\n";
try {
    $db = Database::getInstance();
    echo "   ✅ Database\n";
} catch (Throwable $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

try {
    $cache = new CacheManager();
    echo "   ✅ CacheManager\n";
} catch (Throwable $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "\n4. Ejecutando consulta SQL...\n";
try {
    $idClub = $_GET['idclub'];
    $idTemporada = $_GET['idtemporada'];
    $idJugador = $_GET['idjugador'];

    echo "   Parámetros: idclub=$idClub, idtemporada=$idTemporada, idjugador=$idJugador\n";

    $sql = "SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ? AND idjugador = ?";
    echo "   SQL: $sql\n";

    $cuotas = $db->select($sql, [$idClub, $idTemporada, $idJugador]);
    echo "   ✅ Consulta ejecutada\n";
    echo "   Resultados: " . count($cuotas) . " cuotas\n";

    if (count($cuotas) > 0) {
        echo "   Primera cuota: " . json_encode($cuotas[0]) . "\n";
    }

} catch (Throwable $e) {
    echo "   ❌ ERROR en consulta: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "   Trace:\n" . $e->getTraceAsString() . "\n";
    exit;
}

echo "\n5. Probando ResponseHelper::success()...\n";
try {
    // No ejecutamos success() porque hace exit, pero verificamos la estructura
    $testResponse = [
        'cuotas' => $cuotas
    ];
    $testMessage = count($cuotas) . ' cuotas del jugador obtenidas';

    echo "   Data preparada: " . json_encode($testResponse) . "\n";
    echo "   Message: $testMessage\n";
    echo "   ✅ ResponseHelper está listo\n";

} catch (Throwable $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n";
    exit;
}

echo "\n=== FIN DEL TEST ===\n";
echo "\nSi llegaste aquí, el código de cuotas funciona correctamente.\n";
echo "El problema debe estar en:\n";
echo "  1. El middleware de autenticación Firebase\n";
echo "  2. El archivo cors.php\n";
echo "  3. Algún error de sintaxis PHP en cuotas.php\n";
