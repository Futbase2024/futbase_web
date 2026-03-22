<?php
/**
 * Test específico para operaciones POST de cuotas
 * Simula una petición POST para ver el error exacto
 */

// Mostrar TODOS los errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: text/plain; charset=utf-8');

echo "=== TEST DE OPERACIÓN POST (createcuota) ===\n\n";

// Simular datos POST
$_SERVER['REQUEST_METHOD'] = 'POST';
$_GET['action'] = 'createcuota';

// Simular el body JSON
$testData = [
    'idclub' => 133,
    'idequipo' => 1,
    'idjugador' => 11242,
    'mes' => 10,
    'year' => 2025,
    'idestado' => 1,
    'cantidad' => 50,
    'idtipocuota' => 1,
    'idtemporada' => 6
];

// Crear un stream temporal con los datos
$jsonData = json_encode($testData);
file_put_contents('php://memory', $jsonData);

echo "1. DATOS DE TEST:\n";
echo "   Action: createcuota\n";
echo "   Body: " . $jsonData . "\n\n";

echo "2. INTENTANDO CARGAR cuotas.php...\n\n";

// Capturar cualquier output
ob_start();

try {
    // Incluir el archivo
    require_once __DIR__ . '/endpoints/cuotas.php';

    $output = ob_get_clean();
    echo "3. OUTPUT CAPTURADO:\n";
    echo $output . "\n";

} catch (Throwable $e) {
    $output = ob_get_clean();

    echo "3. ERROR CAPTURADO:\n";
    echo "   Tipo: " . get_class($e) . "\n";
    echo "   Mensaje: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "\n4. OUTPUT ANTES DEL ERROR:\n";
    echo $output . "\n";
    echo "\n5. STACK TRACE:\n";
    echo $e->getTraceAsString() . "\n";
}

echo "\n=== FIN DEL TEST ===\n";
