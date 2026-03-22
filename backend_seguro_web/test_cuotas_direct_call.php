<?php
/**
 * Llamada directa al código de getcuotabyplayertemp
 * Para ver exactamente qué error está produciendo
 */

// Mostrar TODOS los errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Simular que viene de un navegador
header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html><html><head><title>Test Cuotas</title></head><body>";
echo "<h1>Test de cuotas.php</h1>";
echo "<pre>";

echo "=== INICIANDO TEST DIRECTO ===\n\n";

// Simular parámetros GET
$_GET['action'] = 'getcuotabyplayertemp';
$_GET['idclub'] = '10';
$_GET['idtemporada'] = '6';
$_GET['idjugador'] = '3318';

echo "Parámetros simulados:\n";
echo "  action: " . $_GET['action'] . "\n";
echo "  idclub: " . $_GET['idclub'] . "\n";
echo "  idtemporada: " . $_GET['idtemporada'] . "\n";
echo "  idjugador: " . $_GET['idjugador'] . "\n\n";

echo "Cargando cuotas.php...\n\n";

// Capturar el output
ob_start();

try {
    // Incluir el archivo cuotas.php
    // NOTA: Esto fallará en la autenticación, pero nos mostrará el error exacto
    include __DIR__ . '/endpoints/cuotas.php';
} catch (Throwable $e) {
    $output = ob_get_clean();
    echo "ERROR CAPTURADO:\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n\n";
    echo "Output capturado:\n";
    echo $output;
}

$output = ob_get_clean();
echo "\nOutput de cuotas.php:\n";
echo $output;

echo "\n\n=== FIN DEL TEST ===\n";
echo "</pre></body></html>";
