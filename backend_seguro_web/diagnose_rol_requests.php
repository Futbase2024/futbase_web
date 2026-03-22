<?php
/**
 * Script de diagnóstico para rol_requests
 * Muestra los errores exactos que están ocurriendo
 */

// HABILITAR errores para diagnóstico
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);

header('Content-Type: text/plain; charset=utf-8');

echo "=== DIAGNÓSTICO ROL REQUESTS ===\n\n";

require_once __DIR__ . '/core/Database.php';

try {
    $db = Database::getInstance();
    echo "✅ Conexión a BD establecida\n\n";

    // Test 1: Verificar vista vrolpeticion
    echo "Test 1: SELECT desde vrolpeticion\n";
    echo "---------------------------------------\n";
    try {
        $sql = "SELECT * FROM vrolpeticion WHERE estado = ? ORDER BY fecha DESC LIMIT 1";
        $result = $db->select($sql, [0]);
        echo "✅ Query exitosa\n";
        echo "Registros encontrados: " . count($result) . "\n";
        if (count($result) > 0) {
            echo "Primer registro:\n";
            print_r($result[0]);
        }
    } catch (Exception $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
        echo "Trace:\n" . $e->getTraceAsString() . "\n";
    }

    echo "\n\n";

    // Test 2: Verificar tabla base
    echo "Test 2: SELECT desde trolpeticion (tabla base)\n";
    echo "---------------------------------------\n";
    try {
        $sql = "SELECT * FROM trolpeticion WHERE estado = ? ORDER BY fecha DESC LIMIT 1";
        $result = $db->select($sql, [0]);
        echo "✅ Query exitosa\n";
        echo "Registros encontrados: " . count($result) . "\n";
        if (count($result) > 0) {
            echo "Primer registro:\n";
            print_r($result[0]);
        }
    } catch (Exception $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
    }

    echo "\n\n";

    // Test 3: Verificar si la vista existe
    echo "Test 3: Verificar existencia de vrolpeticion\n";
    echo "---------------------------------------\n";
    try {
        $sql = "SHOW FULL TABLES WHERE Tables_in_" . $db->getConnection()->query("SELECT DATABASE()")->fetchColumn() . " LIKE '%rolpeticion%'";
        $result = $db->getConnection()->query($sql)->fetchAll();
        echo "Tablas/vistas encontradas:\n";
        print_r($result);
    } catch (Exception $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
    }

    echo "\n\n";

    // Test 4: Simular la llamada real
    echo "Test 4: Simular getRolRequestsByState\n";
    echo "---------------------------------------\n";
    try {
        $stateMap = [
            'submitted' => 0,
            'approved' => 1,
            'rejected' => 2,
            'cancelled' => 3,
        ];

        $estadoid = $stateMap['submitted'];
        $sql = 'SELECT * FROM vrolpeticion WHERE estado = ? ORDER BY fecha DESC';
        $result = $db->select($sql, [$estadoid]);

        echo "✅ Query exitosa\n";
        echo "Total registros: " . count($result) . "\n";

        // Intentar convertir a JSON
        $json = json_encode($result);
        if ($json === false) {
            echo "❌ Error al convertir a JSON: " . json_last_error_msg() . "\n";
        } else {
            echo "✅ JSON válido generado (" . strlen($json) . " bytes)\n";
        }
    } catch (Exception $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
        echo "Trace:\n" . $e->getTraceAsString() . "\n";
    }

} catch (Exception $e) {
    echo "❌ Error general: " . $e->getMessage() . "\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n";
}

echo "\n\n=== FIN DIAGNÓSTICO ===\n";
