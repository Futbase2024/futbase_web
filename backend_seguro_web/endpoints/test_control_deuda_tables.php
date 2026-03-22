<?php
/**
 * Script de diagnóstico para verificar tablas de control_deuda
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $db = Database::getInstance();

    $diagnostico = [
        'tablas' => [],
        'errores' => []
    ];

    // Verificar tabla tcontrol_deuda_temporada
    try {
        $result = $db->selectOne("SHOW TABLES LIKE 'tcontrol_deuda_temporada'");
        if ($result) {
            $diagnostico['tablas']['tcontrol_deuda_temporada'] = 'existe';

            // Obtener estructura
            $columns = $db->select("DESCRIBE tcontrol_deuda_temporada");
            $diagnostico['tablas']['tcontrol_deuda_temporada_estructura'] = $columns;

            // Contar registros
            $count = $db->selectOne("SELECT COUNT(*) as total FROM tcontrol_deuda_temporada");
            $diagnostico['tablas']['tcontrol_deuda_temporada_registros'] = $count['total'];
        } else {
            $diagnostico['tablas']['tcontrol_deuda_temporada'] = 'NO EXISTE';
            $diagnostico['errores'][] = 'Tabla tcontrol_deuda_temporada no existe';
        }
    } catch (Exception $e) {
        $diagnostico['tablas']['tcontrol_deuda_temporada'] = 'ERROR';
        $diagnostico['errores'][] = 'Error al verificar tcontrol_deuda_temporada: ' . $e->getMessage();
    }

    // Verificar tabla trecibos_pagos
    try {
        $result = $db->selectOne("SHOW TABLES LIKE 'trecibos_pagos'");
        if ($result) {
            $diagnostico['tablas']['trecibos_pagos'] = 'existe';

            // Obtener estructura
            $columns = $db->select("DESCRIBE trecibos_pagos");
            $diagnostico['tablas']['trecibos_pagos_estructura'] = $columns;

            // Contar registros
            $count = $db->selectOne("SELECT COUNT(*) as total FROM trecibos_pagos");
            $diagnostico['tablas']['trecibos_pagos_registros'] = $count['total'];
        } else {
            $diagnostico['tablas']['trecibos_pagos'] = 'NO EXISTE';
            $diagnostico['errores'][] = 'Tabla trecibos_pagos no existe';
        }
    } catch (Exception $e) {
        $diagnostico['tablas']['trecibos_pagos'] = 'ERROR';
        $diagnostico['errores'][] = 'Error al verificar trecibos_pagos: ' . $e->getMessage();
    }

    // Probar una query simple
    try {
        $test = $db->selectOne(
            'SELECT * FROM tcontrol_deuda_temporada WHERE idclub = ? AND idjugador = ? AND idtemporada = ? LIMIT 1',
            [133, 12389, 6]
        );
        $diagnostico['test_query_control'] = $test ?? 'Sin resultados';
    } catch (Exception $e) {
        $diagnostico['test_query_control'] = 'ERROR: ' . $e->getMessage();
    }

    try {
        $test = $db->select(
            'SELECT * FROM trecibos_pagos WHERE idclub = ? AND idjugador = ? AND idtemporada = ? LIMIT 5',
            [133, 12389, 6]
        );
        $diagnostico['test_query_recibos'] = $test ?? [];
    } catch (Exception $e) {
        $diagnostico['test_query_recibos'] = 'ERROR: ' . $e->getMessage();
    }

    respondSuccess($diagnostico);

} catch (Exception $e) {
    respondError('Error general: ' . $e->getMessage(), 500);
}
