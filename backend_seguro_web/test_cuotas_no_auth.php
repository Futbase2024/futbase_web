<?php
/**
 * Test del endpoint de cuotas SIN autenticación
 * Para probar si la consulta SQL funciona
 */

// Mostrar errores
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

try {
    require_once __DIR__ . '/core/Database.php';
    require_once __DIR__ . '/core/CacheManager.php';
    require_once __DIR__ . '/core/ResponseHelper.php';

    $db = Database::getInstance();
    $cache = new CacheManager();

    $idClub = $_GET['idclub'] ?? null;
    $idTemporada = $_GET['idtemporada'] ?? null;
    $idJugador = $_GET['idjugador'] ?? null;

    if (!$idClub || !$idTemporada || !$idJugador) {
        ResponseHelper::error('❌ Parámetros faltantes: idclub, idtemporada, idjugador son requeridos', 400);
    }

    // Probar consulta SQL directa (sin caché para ver si hay error)
    $sql = "SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ? AND idjugador = ?";

    echo json_encode([
        'debug' => [
            'sql' => $sql,
            'params' => [$idClub, $idTemporada, $idJugador],
            'message' => 'Ejecutando consulta...'
        ]
    ]);

    exit; // Salir antes de ejecutar para ver si llega hasta aquí

    $cuotas = $db->select($sql, [$idClub, $idTemporada, $idJugador]);

    ResponseHelper::success([
        'cuotas' => $cuotas,
        'count' => count($cuotas),
        'debug' => [
            'idclub' => $idClub,
            'idtemporada' => $idTemporada,
            'idjugador' => $idJugador
        ]
    ], count($cuotas) . ' cuotas encontradas (sin autenticación)');

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'trace' => explode("\n", $e->getTraceAsString())
    ], JSON_PRETTY_PRINT);
}
