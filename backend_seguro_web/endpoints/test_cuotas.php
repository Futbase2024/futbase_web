<?php
/**
 * Endpoint de prueba para cuotas_club
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';

try {
    error_log("🔍 [test_cuotas] Iniciando test");

    // Test 1: Verificar autenticación
    $auth = new FirebaseAuthMiddleware();
    $userData = $auth->authenticate();
    error_log("✅ [test_cuotas] Autenticación OK - UID: " . $userData['uid']);

    // Test 2: Verificar base de datos
    $db = Database::getInstance();
    error_log("✅ [test_cuotas] Database OK");

    // Test 3: Verificar que la tabla existe
    $idClub = $_GET['idClub'] ?? 133;
    $idTemporada = $_GET['idTemporada'] ?? 6;

    error_log("🔍 [test_cuotas] Probando query con idClub=$idClub, idTemporada=$idTemporada");

    $sql = "SELECT * FROM tconfigcuotas WHERE idclub = ? AND idtemporada = ? LIMIT 5";
    $result = $db->select($sql, [$idClub, $idTemporada]);

    error_log("✅ [test_cuotas] Query OK - Resultados: " . count($result));

    // Test 4: Verificar ResponseHelper
    ResponseHelper::success([
        'test' => 'ok',
        'resultados' => count($result),
        'datos' => $result
    ], 'Test completado exitosamente');

} catch (Exception $e) {
    error_log("❌ [test_cuotas] Error: " . $e->getMessage());
    error_log("❌ [test_cuotas] Trace: " . $e->getTraceAsString());

    ResponseHelper::error('Error en test: ' . $e->getMessage(), 500);
}
