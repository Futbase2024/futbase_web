<?php
/**
 * Test directo de ropa.php para ver errores
 */

// Activar errores para ver qué está pasando
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "=== TEST ROPA.PHP ===\n\n";

// Simular variables que el endpoint necesita
$_SERVER['REQUEST_METHOD'] = 'POST';
$_GET['action'] = 'createRopa';

// Simular datos POST
$_POST = [
    'idclub' => 133,
    'idtemporada' => 6,
    'idjugador' => 1,
    'prenda' => 'Camiseta',
    'talla' => 'M',
    'numero' => 10
];

// Headers simulados
$headers = [
    'Authorization: Bearer test_token_here'
];

echo "1. Variables configuradas\n";
echo "2. Intentando cargar ropa.php...\n\n";

// Capturar output
ob_start();

try {
    // Esto debería mostrar el error real
    include __DIR__ . '/endpoints/ropa.php';
    $output = ob_get_clean();

    echo "Output capturado:\n";
    echo $output;
} catch (Exception $e) {
    ob_end_clean();
    echo "❌ Exception: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

echo "\n=== FIN TEST ===\n";
