<?php
/**
 * Test de rol_requests con simulación de autenticación
 */

// Cargar init.php
require_once __DIR__ . '/init.php';

header('Content-Type: text/plain; charset=utf-8');

echo "=== TEST ROL_REQUESTS CON AUTH ===\n\n";

try {
    require_once __DIR__ . '/core/Database.php';
    require_once __DIR__ . '/core/CacheManager.php';
    require_once __DIR__ . '/core/ResponseHelper.php';
    require_once __DIR__ . '/core/Validator.php';

    echo "1. ✅ Archivos core cargados\n\n";

    $db = Database::getInstance();
    $cache = new CacheManager(300);

    echo "2. ✅ Servicios inicializados\n\n";

    // Simular función getRolRequestsByState
    echo "3. Simulando getRolRequestsByState...\n";

    // Simular input JSON
    $input = ['stateName' => 'submitted'];
    $statename = $input['stateName'];

    echo "   - Estado solicitado: $statename\n";

    // Mapeo de estados
    $stateMap = [
        'submitted' => 0,
        'approved' => 1,
        'rejected' => 2,
        'cancelled' => 3,
    ];

    $estadoid = $stateMap[$statename] ?? null;
    echo "   - Estado ID: $estadoid\n";

    if ($estadoid === null) {
        echo "   ❌ Estado no válido\n";
        exit;
    }

    $cacheKey = "rol_requests_state_{$statename}";
    echo "   - Cache key: $cacheKey\n\n";

    echo "4. Ejecutando query...\n";

    try {
        $result = $cache->remember($cacheKey, function() use ($db, $estadoid) {
            $sql = 'SELECT * FROM vrolpeticion WHERE estado = ? ORDER BY fecha DESC';
            return $db->select($sql, [$estadoid]);
        }, 300);

        echo "   ✅ Query exitosa\n";
        echo "   Registros encontrados: " . count($result) . "\n\n";

        echo "5. Generando respuesta JSON...\n";
        $response = [
            'success' => true,
            'data' => $result
        ];

        $json = json_encode($response);
        if ($json === false) {
            echo "   ❌ Error en json_encode: " . json_last_error_msg() . "\n";
        } else {
            echo "   ✅ JSON generado\n";
            echo "   Tamaño: " . strlen($json) . " bytes\n\n";
        }

        echo "=== TEST COMPLETADO CON ÉXITO ===\n";

    } catch (Exception $e) {
        echo "   ❌ EXCEPCIÓN en cache->remember\n";
        echo "   Mensaje: " . $e->getMessage() . "\n";
        echo "   Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
        echo "   Trace:\n" . $e->getTraceAsString() . "\n";
    }

} catch (Exception $e) {
    echo "❌ EXCEPCIÓN GENERAL\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Archivo: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n";
}

echo "\n=== FIN TEST ===\n";
