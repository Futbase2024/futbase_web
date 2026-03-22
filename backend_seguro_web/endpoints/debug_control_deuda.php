<?php
// ENDPOINT TEMPORAL SOLO PARA DEBUG - ELIMINAR DESPUÉS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../core/Database.php';

try {
    $db = new Database();

    $idjugador = $_GET['idjugador'] ?? 12389;
    $idtemporada = $_GET['idtemporada'] ?? 6;
    $idclub = $_GET['idclub'] ?? 133;

    echo "=== DEBUG CONTROL DEUDA ===\n\n";

    // 1. Verificar si existe el registro
    $control = $db->selectOne(
        'SELECT * FROM tcontrol_deuda_temporada WHERE idclub = ? AND idjugador = ? AND idtemporada = ?',
        [$idclub, $idjugador, $idtemporada]
    );

    echo "1. Control en BD:\n";
    echo json_encode($control, JSON_PRETTY_PRINT) . "\n\n";

    // 2. Obtener total de temporada
    $controlTotal = $db->selectOne(
        'SELECT total_temporada FROM tcontrol_deuda_temporada WHERE idclub = ? AND idjugador = ? AND idtemporada = ?',
        [$idclub, $idjugador, $idtemporada]
    );

    echo "2. Total temporada (solo campo):\n";
    echo json_encode($controlTotal, JSON_PRETTY_PRINT) . "\n\n";

    $totalTemporada = $controlTotal ? (float)$controlTotal['total_temporada'] : 0.0;
    echo "3. Total temporada parseado: $totalTemporada\n\n";

    // 3. Obtener recibos
    $recibosSum = $db->selectOne(
        'SELECT COALESCE(SUM(cantidad), 0) as total_pagado FROM trecibos_pagos WHERE idclub = ? AND idjugador = ? AND idtemporada = ?',
        [$idclub, $idjugador, $idtemporada]
    );

    echo "4. Recibos sum:\n";
    echo json_encode($recibosSum, JSON_PRETTY_PRINT) . "\n\n";

    $totalPagado = $recibosSum ? (float)$recibosSum['total_pagado'] : 0.0;
    echo "5. Total pagado parseado: $totalPagado\n\n";

    $pendiente = $totalTemporada - $totalPagado;

    // 4. Construir resumen como lo hace el endpoint real
    $resumen = [
        'total_temporada' => $totalTemporada,
        'total_pagado' => $totalPagado,
        'pendiente' => $pendiente,
    ];

    echo "6. Resumen final:\n";
    echo json_encode($resumen, JSON_PRETTY_PRINT) . "\n\n";

    // 5. Respuesta como la devuelve el endpoint real
    $response = ['data' => $resumen];
    echo "7. Response completo (como endpoint real):\n";
    echo json_encode($response, JSON_PRETTY_PRINT) . "\n\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}
