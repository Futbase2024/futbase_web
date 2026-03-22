<?php
/**
 * Endpoint de Control de Deuda de Temporada
 * Sistema paralelo para control de deuda total independiente de cuotas mensuales
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$db = Database::getInstance();
$cache = new CacheManager(5);
$auth = new FirebaseAuthMiddleware();
$userData = $auth->protect(100, 60);

// Leer JSON del body para peticiones POST
$GLOBALS['input'] = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rawInput = file_get_contents('php://input');
    if ($rawInput) {
        $GLOBALS['input'] = json_decode($rawInput, true);
    }
}

$action = $_GET['action'] ?? ($GLOBALS['input']['action'] ?? '');

try {
    switch ($action) {
        // Control de Deuda - Operaciones de lectura
        case 'getControlDeudaByJugador':
            getControlDeudaByJugador($db, $cache);
            break;

        // Control de Deuda - Operaciones de escritura
        case 'createControlDeuda':
            createControlDeuda($db, $cache);
            break;
        case 'updateControlDeuda':
            updateControlDeuda($db, $cache);
            break;
        case 'deleteControlDeuda':
            deleteControlDeuda($db, $cache);
            break;

        // Recibos - Operaciones de lectura
        case 'getRecibosByJugador':
            getRecibosByJugador($db, $cache);
            break;
        case 'getResumenDeuda':
            getResumenDeuda($db, $cache);
            break;

        // Recibos - Operaciones de escritura
        case 'createRecibo':
            createRecibo($db, $cache);
            break;
        case 'updateRecibo':
            updateRecibo($db, $cache);
            break;
        case 'deleteRecibo':
            deleteRecibo($db, $cache);
            break;

        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("[ControlDeuda] Error general: " . $e->getMessage());
    error_log("[ControlDeuda] Stack trace: " . $e->getTraceAsString());
    respondInternalError('Error al procesar la solicitud');
}

// ============ FUNCIONES DE CONTROL DE DEUDA ============

function getControlDeudaByJugador($db, $cache) {
    try {
        $idclub = $_GET['idclub'] ?? null;
        $idjugador = $_GET['idjugador'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;

        if (!$idclub || !$idjugador || !$idtemporada) {
            respondError('idclub, idjugador e idtemporada son requeridos', 400);
        }

        error_log("[ControlDeuda] getControlDeudaByJugador - idJugador: {$idjugador}, idTemporada: {$idtemporada}");

        // SIN CACHÉ - Consulta directa a BD
        $sql = 'SELECT * FROM tcontrol_deuda_temporada
                WHERE idclub = ? AND idjugador = ? AND idtemporada = ?';
        $control = $db->selectOne($sql, [$idclub, $idjugador, $idtemporada]);

        if ($control) {
            respondSuccess(['data' => [$control]]);
        } else {
            respondSuccess(['data' => []]);
        }
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en getControlDeudaByJugador: " . $e->getMessage());
        respondSuccess(['data' => []]);
    }
}

function createControlDeuda($db, $cache) {
    try {
        $input = $GLOBALS['input'];
        $idclub = $input['idclub'] ?? null;
        $idjugador = $input['idjugador'] ?? null;
        $idtemporada = $input['idtemporada'] ?? null;
        $totalTemporada = $input['total_temporada'] ?? 0;

        if (!$idclub || !$idjugador || !$idtemporada) {
            respondError('idclub, idjugador e idtemporada son requeridos', 400);
        }

        error_log("[ControlDeuda] createControlDeuda - total: {$totalTemporada}");

        // Verificar si ya existe
        $existente = $db->selectOne(
            'SELECT id FROM tcontrol_deuda_temporada WHERE idclub = ? AND idjugador = ? AND idtemporada = ?',
            [$idclub, $idjugador, $idtemporada]
        );

        if ($existente) {
            // Si existe, actualizamos
            $sql = 'UPDATE tcontrol_deuda_temporada
                    SET total_temporada = ?
                    WHERE id = ?';
            $db->execute($sql, [$totalTemporada, $existente['id']]);
        } else {
            // Si no existe, insertamos
            $sql = 'INSERT INTO tcontrol_deuda_temporada
                    (idclub, idjugador, idtemporada, total_temporada)
                    VALUES (?, ?, ?, ?)';
            $db->execute($sql, [$idclub, $idjugador, $idtemporada, $totalTemporada]);
        }

        // Limpiar caché
        $cache->forget("control_deuda_{$idclub}_{$idjugador}_{$idtemporada}");
        $cache->forget("resumen_deuda_{$idclub}_{$idjugador}_{$idtemporada}");

        respondSuccess(['message' => 'Control de deuda creado/actualizado correctamente']);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en createControlDeuda: " . $e->getMessage());
        respondInternalError('Error al crear control de deuda');
    }
}

function updateControlDeuda($db, $cache) {
    try {
        $input = $GLOBALS['input'];
        $id = $input['id'] ?? null;
        $totalTemporada = $input['total_temporada'] ?? null;

        if (!$id || $totalTemporada === null) {
            respondError('id y total_temporada son requeridos', 400);
        }

        error_log("[ControlDeuda] updateControlDeuda - id: {$id}");

        // Obtener datos para limpiar caché
        $control = $db->selectOne('SELECT * FROM tcontrol_deuda_temporada WHERE id = ?', [$id]);

        $sql = 'UPDATE tcontrol_deuda_temporada SET total_temporada = ? WHERE id = ?';
        $db->execute($sql, [$totalTemporada, $id]);

        // Limpiar caché
        if ($control) {
            $cache->forget("control_deuda_{$control['idclub']}_{$control['idjugador']}_{$control['idtemporada']}");
            $cache->forget("resumen_deuda_{$control['idclub']}_{$control['idjugador']}_{$control['idtemporada']}");
        }

        respondSuccess(['message' => 'Control de deuda actualizado correctamente']);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en updateControlDeuda: " . $e->getMessage());
        respondInternalError('Error al actualizar control de deuda');
    }
}

function deleteControlDeuda($db, $cache) {
    try {
        $input = $GLOBALS['input'];
        $id = $input['id'] ?? null;

        if (!$id) {
            respondError('id requerido', 400);
        }

        error_log("[ControlDeuda] deleteControlDeuda - id: {$id}");

        // Obtener datos para limpiar caché
        $control = $db->selectOne('SELECT * FROM tcontrol_deuda_temporada WHERE id = ?', [$id]);

        // Eliminar recibos asociados primero
        $db->execute('DELETE FROM trecibos_pagos WHERE idcontrol_deuda = ?', [$id]);

        // Eliminar control de deuda
        $db->execute('DELETE FROM tcontrol_deuda_temporada WHERE id = ?', [$id]);

        // Limpiar caché
        if ($control) {
            $cache->forget("control_deuda_{$control['idclub']}_{$control['idjugador']}_{$control['idtemporada']}");
            $cache->forget("recibos_{$control['idclub']}_{$control['idjugador']}_{$control['idtemporada']}");
            $cache->forget("resumen_deuda_{$control['idclub']}_{$control['idjugador']}_{$control['idtemporada']}");
        }

        respondSuccess(['message' => 'Control de deuda eliminado correctamente']);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en deleteControlDeuda: " . $e->getMessage());
        respondInternalError('Error al eliminar control de deuda');
    }
}

// ============ FUNCIONES DE RECIBOS ============

function getRecibosByJugador($db, $cache) {
    try {
        $idclub = $_GET['idclub'] ?? null;
        $idjugador = $_GET['idjugador'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;

        if (!$idclub || !$idjugador || !$idtemporada) {
            respondError('idclub, idjugador e idtemporada son requeridos', 400);
        }

        error_log("[ControlDeuda] getRecibosByJugador - idJugador: {$idjugador}");

        // SIN CACHÉ - Consulta directa a BD
        $sql = 'SELECT * FROM trecibos_pagos
                WHERE idclub = ? AND idjugador = ? AND idtemporada = ?
                ORDER BY fecha_pago DESC';
        $recibos = $db->select($sql, [$idclub, $idjugador, $idtemporada]);

        respondSuccess(['data' => $recibos ?? []]);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en getRecibosByJugador: " . $e->getMessage());
        respondSuccess(['data' => []]);
    }
}

function createRecibo($db, $cache) {
    try {
        $input = $GLOBALS['input'];
        error_log("[ControlDeuda] createRecibo - input recibido: " . json_encode($input));

        $idclub = $input['idclub'] ?? null;
        $idjugador = $input['idjugador'] ?? null;
        $idtemporada = $input['idtemporada'] ?? null;
        $idcontrolDeuda = $input['idcontrol_deuda'] ?? null;
        $cantidad = $input['cantidad'] ?? 0;
        $fechaPago = $input['fecha_pago'] ?? date('Y-m-d H:i:s');
        $concepto = $input['concepto'] ?? '';
        $metodoPago = $input['metodo_pago'] ?? 'EFECTIVO';

        error_log("[ControlDeuda] createRecibo - Params: idclub=$idclub, idjugador=$idjugador, idtemporada=$idtemporada, cantidad=$cantidad");

        if (!$idclub || !$idjugador || !$idtemporada) {
            respondError('idclub, idjugador e idtemporada son requeridos', 400);
        }

        error_log("[ControlDeuda] createRecibo - cantidad: {$cantidad}");

        $sql = 'INSERT INTO trecibos_pagos
                (idclub, idjugador, idtemporada, idcontrol_deuda, cantidad, fecha_pago, concepto, metodo_pago)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)';

        error_log("[ControlDeuda] createRecibo - Ejecutando INSERT con params: " . json_encode([
            $idclub, $idjugador, $idtemporada, $idcontrolDeuda, $cantidad, $fechaPago, $concepto, $metodoPago
        ]));

        // Usar insert() en lugar de execute() para obtener el ID
        $insertId = $db->insert($sql, [
            $idclub,
            $idjugador,
            $idtemporada,
            $idcontrolDeuda, // Puede ser null
            $cantidad,
            $fechaPago,
            $concepto,
            $metodoPago
        ]);

        error_log("[ControlDeuda] createRecibo - INSERT exitoso con ID: {$insertId}");

        // Obtener el recibo completo
        $sqlGet = 'SELECT * FROM trecibos_pagos WHERE id = ?';
        $recibo = $db->selectOne($sqlGet, [$insertId]);

        // Limpiar caché
        $cache->forget("recibos_{$idclub}_{$idjugador}_{$idtemporada}");
        $cache->forget("resumen_deuda_{$idclub}_{$idjugador}_{$idtemporada}");

        respondSuccess(['data' => $recibo, 'message' => 'Recibo creado correctamente']);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en createRecibo: " . $e->getMessage());
        respondInternalError('Error al crear recibo');
    }
}

function updateRecibo($db, $cache) {
    try {
        $input = $GLOBALS['input'];
        $id = $input['id'] ?? null;
        $cantidad = $input['cantidad'] ?? null;
        $fechaPago = $input['fecha_pago'] ?? null;
        $concepto = $input['concepto'] ?? null;
        $metodoPago = $input['metodo_pago'] ?? null;

        if (!$id || $cantidad === null) {
            respondError('id y cantidad son requeridos', 400);
        }

        error_log("[ControlDeuda] updateRecibo - id: {$id}");

        // Obtener datos para limpiar caché
        $recibo = $db->selectOne('SELECT * FROM trecibos_pagos WHERE id = ?', [$id]);

        $sql = 'UPDATE trecibos_pagos
                SET cantidad = ?, fecha_pago = ?, concepto = ?, metodo_pago = ?
                WHERE id = ?';

        $db->execute($sql, [$cantidad, $fechaPago, $concepto, $metodoPago, $id]);

        // Limpiar caché
        if ($recibo) {
            $cache->forget("recibos_{$recibo['idclub']}_{$recibo['idjugador']}_{$recibo['idtemporada']}");
            $cache->forget("resumen_deuda_{$recibo['idclub']}_{$recibo['idjugador']}_{$recibo['idtemporada']}");
        }

        respondSuccess(['message' => 'Recibo actualizado correctamente']);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en updateRecibo: " . $e->getMessage());
        respondInternalError('Error al actualizar recibo');
    }
}

function deleteRecibo($db, $cache) {
    try {
        $input = $GLOBALS['input'];
        $id = $input['id'] ?? null;

        if (!$id) {
            respondError('id requerido', 400);
        }

        error_log("[ControlDeuda] deleteRecibo - id: {$id}");

        // Obtener datos para limpiar caché
        $recibo = $db->selectOne('SELECT * FROM trecibos_pagos WHERE id = ?', [$id]);

        $db->execute('DELETE FROM trecibos_pagos WHERE id = ?', [$id]);

        // Limpiar caché
        if ($recibo) {
            $cache->forget("recibos_{$recibo['idclub']}_{$recibo['idjugador']}_{$recibo['idtemporada']}");
            $cache->forget("resumen_deuda_{$recibo['idclub']}_{$recibo['idjugador']}_{$recibo['idtemporada']}");
        }

        respondSuccess(['message' => 'Recibo eliminado correctamente']);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en deleteRecibo: " . $e->getMessage());
        respondInternalError('Error al eliminar recibo');
    }
}

function getResumenDeuda($db, $cache) {
    try {
        $idclub = $_GET['idclub'] ?? null;
        $idjugador = $_GET['idjugador'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;

        if (!$idclub || !$idjugador || !$idtemporada) {
            respondError('idclub, idjugador e idtemporada son requeridos', 400);
        }

        error_log("[ControlDeuda] getResumenDeuda - idJugador: {$idjugador}");

        // SIN CACHÉ - Consultas directas a BD
        // Obtener total de temporada
        $control = $db->selectOne(
            'SELECT total_temporada FROM tcontrol_deuda_temporada
             WHERE idclub = ? AND idjugador = ? AND idtemporada = ?',
            [$idclub, $idjugador, $idtemporada]
        );

        $totalTemporada = $control ? (float)$control['total_temporada'] : 0.0;

        // Obtener suma de recibos
        $recibosSum = $db->selectOne(
            'SELECT COALESCE(SUM(cantidad), 0) as total_pagado FROM trecibos_pagos
             WHERE idclub = ? AND idjugador = ? AND idtemporada = ?',
            [$idclub, $idjugador, $idtemporada]
        );

        $totalPagado = $recibosSum ? (float)$recibosSum['total_pagado'] : 0.0;
        $pendiente = $totalTemporada - $totalPagado;

        $resumen = [
            'total_temporada' => $totalTemporada,
            'total_pagado' => $totalPagado,
            'pendiente' => $pendiente,
        ];

        error_log("[ControlDeuda] DEBUG - control raw: " . print_r($control, true));
        error_log("[ControlDeuda] DEBUG - recibosSum raw: " . print_r($recibosSum, true));
        error_log("[ControlDeuda] DEBUG - totalTemporada: $totalTemporada");
        error_log("[ControlDeuda] DEBUG - totalPagado: $totalPagado");
        error_log("[ControlDeuda] DEBUG - pendiente: $pendiente");
        error_log("[ControlDeuda] DEBUG - resumen final: " . json_encode($resumen));

        respondSuccess(['data' => $resumen]);
    } catch (Exception $e) {
        error_log("[ControlDeuda] Error en getResumenDeuda: " . $e->getMessage());
        respondSuccess(['data' => [
            'total_temporada' => 0,
            'total_pagado' => 0,
            'pendiente' => 0,
        ]]);
    }
}
