<?php
/**
 * Script de prueba para verificar si existe la vista vrolpeticion
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/core/Database.php';

try {
    $db = Database::getInstance();

    echo "=== Test 1: Verificar si existe la vista vrolpeticion ===\n";

    // Intentar describir la vista
    $sql = "DESCRIBE vrolpeticion";
    try {
        $result = $db->select($sql);
        echo "✅ La vista vrolpeticion EXISTE\n";
        echo "Columnas:\n";
        print_r($result);
    } catch (Exception $e) {
        echo "❌ La vista vrolpeticion NO EXISTE o hay un error\n";
        echo "Error: " . $e->getMessage() . "\n\n";
    }

    echo "\n=== Test 2: Verificar tabla base trolpeticion ===\n";
    $sql = "DESCRIBE trolpeticion";
    try {
        $result = $db->select($sql);
        echo "✅ La tabla trolpeticion EXISTE\n";
        echo "Columnas:\n";
        print_r($result);
    } catch (Exception $e) {
        echo "❌ La tabla trolpeticion NO EXISTE\n";
        echo "Error: " . $e->getMessage() . "\n";
    }

    echo "\n=== Test 3: Intentar SELECT simple ===\n";
    $sql = "SELECT * FROM vrolpeticion LIMIT 1";
    try {
        $result = $db->select($sql);
        echo "✅ SELECT funcionó. Registros encontrados: " . count($result) . "\n";
        if (count($result) > 0) {
            echo "Primer registro:\n";
            print_r($result[0]);
        }
    } catch (Exception $e) {
        echo "❌ Error en SELECT\n";
        echo "Error: " . $e->getMessage() . "\n";
    }

    echo "\n=== Test 4: Buscar si la vista existe en INFORMATION_SCHEMA ===\n";
    $sql = "SELECT TABLE_NAME, TABLE_TYPE
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME LIKE '%rolpeticion%'";
    try {
        $result = $db->select($sql);
        echo "Tablas/vistas relacionadas con 'rolpeticion':\n";
        print_r($result);
    } catch (Exception $e) {
        echo "❌ Error buscando en INFORMATION_SCHEMA\n";
        echo "Error: " . $e->getMessage() . "\n";
    }

} catch (Exception $e) {
    echo "Error general: " . $e->getMessage() . "\n";
}
