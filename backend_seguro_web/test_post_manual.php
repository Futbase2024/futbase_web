<?php
/**
 * Test manual de POST sin autenticación
 * Este script simula una petición POST directamente
 *
 * Subir a: /backend_seguro_web/test_post_manual.php
 * Acceder: https://futbase.es/backend_seguro_web/test_post_manual.php
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== TEST MANUAL DE POST EN CUOTAS ===\n\n";

// Simular variables de servidor
$_SERVER['REQUEST_METHOD'] = 'POST';
$_GET['action'] = 'createcuota';

// Simular el body POST
$testData = [
    'idclub' => 133,
    'idequipo' => 1,
    'idjugador' => 11242,
    'mes' => 1,
    'year' => 2025,
    'idestado' => 1,
    'cantidad' => 50.0,
    'idtipocuota' => 1,
    'idtemporada' => 6
];

// Simular php://input
$GLOBALS['TEST_POST_DATA'] = json_encode($testData);

echo "📤 Datos de prueba:\n";
echo json_encode($testData, JSON_PRETTY_PRINT) . "\n\n";

echo "🔄 Iniciando test...\n\n";

// Modificar file_get_contents temporalmente
function test_file_get_contents($path) {
    if ($path === 'php://input' && isset($GLOBALS['TEST_POST_DATA'])) {
        return $GLOBALS['TEST_POST_DATA'];
    }
    return file_get_contents($path);
}

// Capturar salida
ob_start();

try {
    // Incluir el archivo con manejo de errores
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    echo "📁 Cargando cuotas_debug.php...\n";

    // Nota: Como este script requiere autenticación, fallará
    // Pero veremos si el error es JSON o HTML

    require_once __DIR__ . '/endpoints/cuotas_debug.php';

} catch (Exception $e) {
    echo "\n❌ EXCEPCIÓN CAPTURADA:\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
}

$output = ob_get_clean();

echo "📋 SALIDA CAPTURADA:\n";
echo "================================================================================\n";
echo $output;
echo "\n================================================================================\n\n";

// Analizar la salida
if (strpos($output, '<!DOCTYPE') !== false || strpos($output, '<html') !== false) {
    echo "⚠️  PROBLEMA: La salida contiene HTML (debería ser JSON)\n";
    echo "Esto confirma el bug reportado.\n";
} elseif (strpos($output, '{"success"') !== false || strpos($output, '{\"success\"') !== false) {
    echo "✅ CORRECTO: La salida es JSON\n";
} else {
    echo "❓ DESCONOCIDO: La salida no es ni HTML ni JSON claro\n";
}

echo "\n=== FIN TEST ===\n";
