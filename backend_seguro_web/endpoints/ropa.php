<?php
/**
 * 👕 Endpoint: ropa.php
 * Descripción: Gestión de ropa/equipación de jugadores
 * Fecha: 2025-10-25
 *
 * Operaciones de lectura (público):
 * - getRopaByClub: Obtener ropa por club y temporada
 * - getRopaByJugador: Obtener ropa de un jugador
 * - getRopaById: Obtener prenda por ID
 * - getRopaStats: Estadísticas de ropa por equipo
 *
 * Operaciones de escritura (requieren autenticación):
 * - createRopa: Crear nueva prenda
 * - updateRopa: Actualizar prenda
 * - updateEntregado: Actualizar estado de entrega
 * - updateAvisado: Actualizar estado de aviso
 * - marcarDevolucion: Marcar prenda como devuelta + crear asiento contable negativo
 * - deleteRopa: Eliminar prenda
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../core/ResponseHelper.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Rate limiting (100 peticiones/minuto)
$rateLimiter = new RateLimiter(100, 60);
$clientId = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!$rateLimiter->isAllowed($clientId)) {
    ResponseHelper::error('Demasiadas peticiones. Espera un momento 🕐', 429);
}

// Inicializar servicios
$db = Database::getInstance();
$cache = new CacheManager();
$auth = new FirebaseAuthMiddleware();

/**
 * 📋 Obtiene toda la ropa de un club en una temporada
 * Público - con caché de 60 segundos
 */
function getRopaByClub($db, $cache) {
    $idClub = $_GET['idClub'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idClub || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos (idClub, idTemporada requeridos)', 400);
    }

    if (!is_numeric($idClub) || !is_numeric($idTemporada)) {
        ResponseHelper::error('Parámetros inválidos', 400);
    }

    $cacheKey = "ropa_club_{$idClub}_{$idTemporada}";

    $ropa = $cache->remember($cacheKey, function() use ($db, $idClub, $idTemporada) {
        $sql = "SELECT * FROM vropa WHERE idclub = ? AND idtemporada = ? ORDER BY nombre";
        return $db->select($sql, [$idClub, $idTemporada]);
    }, 60); // Cache 1 minuto (datos que cambian)

    if ($ropa === false) {
        ResponseHelper::error('Error al obtener ropa', 500);
    }

    ResponseHelper::success($ropa, '✅ Ropa del club obtenida correctamente');
}

/**
 * 👤 Obtiene la ropa de un jugador específico
 * Público - con caché de 60 segundos
 */
function getRopaByJugador($db, $cache) {
    $idJugador = $_GET['idJugador'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$idJugador || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos (idJugador, idTemporada requeridos)', 400);
    }

    if (!is_numeric($idJugador) || !is_numeric($idTemporada)) {
        ResponseHelper::error('Parámetros inválidos', 400);
    }

    $cacheKey = "ropa_jugador_{$idJugador}_{$idTemporada}";

    $ropa = $cache->remember($cacheKey, function() use ($db, $idJugador, $idTemporada) {
        $sql = "SELECT * FROM vropa WHERE idjugador = ? AND idtemporada = ? ORDER BY fecha DESC";
        return $db->select($sql, [$idJugador, $idTemporada]);
    }, 60);

    if ($ropa === false) {
        ResponseHelper::error('Error al obtener ropa', 500);
    }

    ResponseHelper::success($ropa, '✅ Ropa del jugador obtenida correctamente');
}

/**
 * 🔍 Obtiene una prenda por ID
 * Público - con caché de 60 segundos
 */
function getRopaById($db, $cache) {
    $id = $_GET['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID requerido', 400);
    }

    if (!is_numeric($id)) {
        ResponseHelper::error('ID inválido', 400);
    }

    $cacheKey = "ropa_id_{$id}";

    $ropa = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM vropa WHERE id = ?";
        return $db->selectOne($sql, [$id]);
    }, 60);

    if (!$ropa) {
        ResponseHelper::error('Ropa no encontrada', 404);
    }

    ResponseHelper::success($ropa, '✅ Prenda obtenida correctamente');
}

/**
 * 📊 Obtiene estadísticas de ropa por equipo
 * Público - con caché de 300 segundos (5 minutos)
 */
function getRopaStats($db, $cache) {
    $equipoId = $_GET['equipoId'] ?? null;
    $idTemporada = $_GET['idTemporada'] ?? null;

    if (!$equipoId || !$idTemporada) {
        ResponseHelper::error('Parámetros incompletos (equipoId, idTemporada requeridos)', 400);
    }

    if (!is_numeric($equipoId) || !is_numeric($idTemporada)) {
        ResponseHelper::error('Parámetros inválidos', 400);
    }

    $cacheKey = "ropa_stats_{$equipoId}_{$idTemporada}";

    $stats = $cache->remember($cacheKey, function() use ($db, $equipoId, $idTemporada) {
        $sql = "SELECT entregado, COUNT(*) as cantidad, SUM(pvp) as valor
                FROM vropa
                WHERE idequipo = ? AND idtemporada = ?
                GROUP BY entregado";

        $results = $db->select($sql, [$equipoId, $idTemporada]);

        $stats = [
            'entregadas' => 0,
            'pendientes' => 0,
            'valorTotal' => 0.0,
            'valorEntregado' => 0.0,
            'valorPendiente' => 0.0,
        ];

        foreach ($results as $row) {
            $cantidad = (int)($row['cantidad'] ?? 0);
            $valor = (float)($row['valor'] ?? 0);

            if ($row['entregado'] == 1) {
                $stats['entregadas'] = $cantidad;
                $stats['valorEntregado'] = $valor;
            } else {
                $stats['pendientes'] = $cantidad;
                $stats['valorPendiente'] = $valor;
            }
            $stats['valorTotal'] += $valor;
        }

        return $stats;
    }, 300); // Cache 5 minutos

    ResponseHelper::success($stats, '📊 Estadísticas de ropa obtenidas');
}

/**
 * ➕ Crea una nueva prenda de ropa
 * Requiere autenticación Firebase
 */
function createRopa($db, $cache, $userData) {
    // Leer datos del body JSON
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        ResponseHelper::error('Datos inválidos', 400);
    }

    $idclub = $input['idclub'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;
    $idjugador = $input['idjugador'] ?? 0;
    $idprenda = $input['idprenda'] ?? null;
    $pvp = $input['pvp'] ?? 0;
    $descuento = $input['descuento'] ?? 0;
    $acuenta = $input['acuenta'] ?? 0;
    $entregado = $input['entregado'] ?? 0;
    $tipopago = $input['tipopago'] ?? 1;
    $nombre = $input['nombre'] ?? null;
    $talla = $input['talla'] ?? null;
    $descripcion = $input['descripcion'] ?? '';

    if (!$idclub || !$idtemporada || !$idprenda) {
        ResponseHelper::error('Parámetros incompletos (idclub, idtemporada, idprenda requeridos)', 400);
    }

    // Insertar en tropa
    $sqlRopa = "INSERT INTO tropa (idclub, idtemporada, idjugador, idprenda, pvp, descuento, acuenta, entregado, tipopago";
    $values = "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?";
    $params = [$idclub, $idtemporada, $idjugador, $idprenda, $pvp, $descuento, $acuenta, $entregado, $tipopago];

    if ($nombre) {
        $sqlRopa .= ", nombre";
        $values .= ", ?";
        $params[] = $nombre;
    }

    if ($talla) {
        $sqlRopa .= ", talla";
        $values .= ", ?";
        $params[] = $talla;
    }

    $sqlRopa .= ") " . $values . ")";

    $ropaId = $db->insert($sqlRopa, $params);

    if (!$ropaId) {
        ResponseHelper::error('Error al crear la ropa', 500);
    }

    // Crear registro contable
    $precioFinal = $pvp - $descuento;
    $cantidad = $acuenta > 0 ? $acuenta : $precioFinal;
    $fecha = date('Y-m-d');

    $sqlContabilidad = "INSERT INTO tcontabilidad (idclub, idequipo, familia, concepto, ingreso, gasto, cantidad, idcuota, idpagoper, fecha, idtemporada, idestado)
                        VALUES (?, 0, 'ROPA', ?, 1, 0, ?, 0, 0, ?, ?, ?)";

    $db->insert($sqlContabilidad, [
        $idclub,
        "Venta de ropa - $descripcion",
        $cantidad,
        $fecha,
        $idtemporada,
        $tipopago
    ]);

    // Invalidar caché de ropa y contabilidad
    $cache->delete("ropa_club_{$idclub}_{$idtemporada}");
    $cache->clear("contabilidad_*");

    // Obtener la prenda creada
    $sqlGet = "SELECT * FROM vropa WHERE id = ?";
    $ropa = $db->selectOne($sqlGet, [$ropaId]);

    ResponseHelper::success($ropa, '✅ Prenda creada correctamente');
}

/**
 * ✏️ Actualiza una prenda existente
 * Requiere autenticación Firebase
 */
function updateRopa($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        ResponseHelper::error('Datos inválidos', 400);
    }

    $id = $input['id'] ?? null;
    $idjugador = $input['idjugador'] ?? 0;
    $idprenda = $input['idprenda'] ?? null;
    $pvp = $input['pvp'] ?? 0;
    $descuento = $input['descuento'] ?? 0;
    $acuenta = $input['acuenta'] ?? 0;
    $entregado = $input['entregado'] ?? 0;
    $tipopago = $input['tipopago'] ?? 1;
    $nombre = $input['nombre'] ?? null;
    $talla = $input['talla'] ?? null;
    $descripcion = $input['descripcion'] ?? '';
    $idclub = $input['idclub'] ?? null;
    $idtemporada = $input['idtemporada'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID requerido', 400);
    }

    // Actualizar tropa
    $sqlRopa = "UPDATE tropa SET idjugador = ?, idprenda = ?, pvp = ?, descuento = ?, acuenta = ?, entregado = ?, tipopago = ?";
    $params = [$idjugador, $idprenda, $pvp, $descuento, $acuenta, $entregado, $tipopago];

    if ($nombre !== null) {
        $sqlRopa .= ", nombre = ?";
        $params[] = $nombre;
    }

    if ($talla !== null) {
        $sqlRopa .= ", talla = ?";
        $params[] = $talla;
    }

    $sqlRopa .= " WHERE id = ?";
    $params[] = $id;

    $result = $db->update($sqlRopa, $params);

    if (!$result) {
        ResponseHelper::error('Error al actualizar la ropa', 500);
    }

    // Actualizar registro contable
    if ($idclub && $idtemporada && $descripcion) {
        // Eliminar registro anterior
        $sqlDeleteContabilidad = "DELETE FROM tcontabilidad WHERE concepto LIKE ? AND idclub = ? AND idtemporada = ?";
        $db->delete($sqlDeleteContabilidad, ["Venta de ropa - $descripcion", $idclub, $idtemporada]);

        // Crear nuevo registro
        $precioFinal = $pvp - $descuento;
        $cantidad = $acuenta > 0 ? $acuenta : $precioFinal;
        $fecha = date('Y-m-d');

        $sqlContabilidad = "INSERT INTO tcontabilidad (idclub, idequipo, familia, concepto, ingreso, gasto, cantidad, idcuota, idpagoper, fecha, idtemporada, idestado)
                            VALUES (?, 0, 'ROPA', ?, 1, 0, ?, 0, 0, ?, ?, ?)";

        $db->insert($sqlContabilidad, [
            $idclub,
            "Venta de ropa - $descripcion",
            $cantidad,
            $fecha,
            $idtemporada,
            $tipopago
        ]);

        // Invalidar caché de ropa y contabilidad
        $cache->delete("ropa_club_{$idclub}_{$idtemporada}");
        $cache->clear("contabilidad_*");
    }

    // Obtener la prenda actualizada
    $sqlGet = "SELECT * FROM vropa WHERE id = ?";
    $ropa = $db->selectOne($sqlGet, [$id]);

    ResponseHelper::success($ropa, '✅ Prenda actualizada correctamente');
}

/**
 * 📦 Actualiza estado de entrega
 * Requiere autenticación Firebase
 */
function updateEntregado($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        ResponseHelper::error('Datos inválidos', 400);
    }

    $id = $input['id'] ?? null;
    $entregado = $input['entregado'] ?? null;

    if ($id === null || $entregado === null) {
        ResponseHelper::error('Parámetros incompletos (id, entregado requeridos)', 400);
    }

    $sql = "UPDATE tropa SET entregado = ? WHERE id = ?";
    $result = $db->update($sql, [$entregado, $id]);

    if (!$result) {
        ResponseHelper::error('Error al actualizar estado de entrega', 500);
    }

    // Obtener la prenda actualizada
    $sqlGet = "SELECT * FROM vropa WHERE id = ?";
    $ropa = $db->selectOne($sqlGet, [$id]);

    // Invalidar caché si tenemos los datos
    if ($ropa && isset($ropa['idclub']) && isset($ropa['idtemporada'])) {
        $cache->delete("ropa_club_{$ropa['idclub']}_{$ropa['idtemporada']}");
    }

    ResponseHelper::success($ropa, '✅ Estado de entrega actualizado');
}

/**
 * 🔔 Actualiza estado de aviso
 * Requiere autenticación Firebase
 */
function updateAvisado($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        ResponseHelper::error('Datos inválidos', 400);
    }

    $id = $input['id'] ?? null;
    $avisado = $input['avisado'] ?? null;

    if ($id === null || $avisado === null) {
        ResponseHelper::error('Parámetros incompletos (id, avisado requeridos)', 400);
    }

    $sql = "UPDATE tropa SET avisado = ? WHERE id = ?";
    $result = $db->update($sql, [$avisado, $id]);

    if (!$result) {
        ResponseHelper::error('Error al actualizar estado de aviso', 500);
    }

    // Obtener la prenda actualizada
    $sqlGet = "SELECT * FROM vropa WHERE id = ?";
    $ropa = $db->selectOne($sqlGet, [$id]);

    // Invalidar caché si tenemos los datos
    if ($ropa && isset($ropa['idclub']) && isset($ropa['idtemporada'])) {
        $cache->delete("ropa_club_{$ropa['idclub']}_{$ropa['idtemporada']}");
    }

    ResponseHelper::success($ropa, '✅ Estado de aviso actualizado');
}

/**
 * 🗑️ Elimina una prenda
 * Requiere autenticación Firebase
 */
function deleteRopa($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        ResponseHelper::error('Datos inválidos', 400);
    }

    $id = $input['id'] ?? null;

    if (!$id) {
        ResponseHelper::error('ID requerido', 400);
    }

    // Obtener detalles antes de eliminar
    $sqlGet = "SELECT * FROM vropa WHERE id = ?";
    $ropa = $db->selectOne($sqlGet, [$id]);

    if (!$ropa) {
        ResponseHelper::error('Ropa no encontrada', 404);
    }

    // Eliminar registro contable asociado
    $descripcion = $ropa['descripcion'] ?? '';
    $idclub = $ropa['idclub'] ?? null;
    $idtemporada = $ropa['idtemporada'] ?? null;

    if ($descripcion && $idclub && $idtemporada) {
        $sqlDeleteContabilidad = "DELETE FROM tcontabilidad WHERE concepto LIKE ? AND idclub = ? AND idtemporada = ?";
        $db->delete($sqlDeleteContabilidad, ["Venta de ropa - $descripcion", $idclub, $idtemporada]);
    }

    // Eliminar la ropa
    $sql = "DELETE FROM tropa WHERE id = ?";
    $result = $db->delete($sql, [$id]);

    if (!$result) {
        ResponseHelper::error('Error al eliminar la ropa', 500);
    }

    // Invalidar caché de ropa y contabilidad
    if ($idclub && $idtemporada) {
        $cache->delete("ropa_club_{$idclub}_{$idtemporada}");
        // Invalidar también la caché de contabilidad ya que se eliminó un registro
        $cache->clear("contabilidad_*");
    }

    ResponseHelper::success(null, '🗑️ Ropa eliminada correctamente');
}

/**
 * 🔄 Marca una prenda como devuelta y crea asiento contable de devolución
 * Requiere autenticación Firebase
 */
function marcarDevolucion($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        ResponseHelper::error('Datos inválidos', 400);
    }

    $id = $input['id'] ?? null;
    $devuelto = $input['devuelto'] ?? 1;

    if (!$id) {
        ResponseHelper::error('ID requerido', 400);
    }

    if (!is_numeric($id) || !is_numeric($devuelto)) {
        ResponseHelper::error('Parámetros inválidos', 400);
    }

    // Obtener detalles de la prenda
    $sqlGet = "SELECT * FROM vropa WHERE id = ?";
    $ropa = $db->selectOne($sqlGet, [$id]);

    if (!$ropa) {
        ResponseHelper::error('Ropa no encontrada', 404);
    }

    // Verificar que no esté ya devuelta
    if ($ropa['devuelto'] == 1) {
        ResponseHelper::error('Esta prenda ya ha sido devuelta', 400);
    }

    // Actualizar estado de devolución
    $fechaDevolucion = date('Y-m-d H:i:s');
    $sql = "UPDATE tropa SET devuelto = ?, fechadevolucion = ? WHERE id = ?";
    $result = $db->update($sql, [$devuelto, $fechaDevolucion, $id]);

    if (!$result) {
        ResponseHelper::error('Error al marcar devolución', 500);
    }

    // Crear asiento contable de devolución (importe NEGATIVO)
    $pvp = (float)($ropa['pvp'] ?? 0);
    $descuento = (float)($ropa['descuento'] ?? 0);
    $acuenta = (float)($ropa['acuenta'] ?? 0);
    $precioFinal = $pvp - $descuento;

    // El importe a devolver es lo que se pagó (aCuenta si >0, sino precioFinal)
    $importeDevolucion = $acuenta > 0 ? $acuenta : $precioFinal;

    // NEGATIVO para indicar devolución/salida de dinero
    $cantidadNegativa = -abs($importeDevolucion);

    $idclub = $ropa['idclub'] ?? null;
    $idtemporada = $ropa['idtemporada'] ?? null;
    $tipopago = $ropa['tipopago'] ?? 1;
    $descripcion = $ropa['descripcion'] ?? 'Artículo';
    $fecha = date('Y-m-d');

    // Insertar asiento contable de devolución
    // ingreso=0, gasto=1 y cantidad NEGATIVA para restar del total
    $sqlContabilidad = "INSERT INTO tcontabilidad (idclub, idequipo, familia, concepto, ingreso, gasto, cantidad, idcuota, idpagoper, fecha, idtemporada, idestado)
                        VALUES (?, 0, 'ROPA', ?, 0, 1, ?, 0, 0, ?, ?, ?)";

    $db->insert($sqlContabilidad, [
        $idclub,
        "Devolución de ropa - $descripcion",
        $cantidadNegativa,  // NEGATIVO
        $fecha,
        $idtemporada,
        $tipopago
    ]);

    // Invalidar caché relacionada
    $idjugador = $ropa['idjugador'] ?? null;

    if ($idclub && $idtemporada) {
        $cache->delete("ropa_club_{$idclub}_{$idtemporada}");
    }

    if ($idjugador && $idtemporada) {
        $cache->delete("ropa_jugador_{$idjugador}_{$idtemporada}");
    }

    $cache->delete("ropa_{$id}");

    // Invalidar caché de contabilidad para que se recalculen los totales
    $cache->clear("contabilidad_*");

    ResponseHelper::success([
        'id' => $id,
        'devuelto' => $devuelto,
        'fechadevolucion' => $fechaDevolucion,
        'importeDevuelto' => $cantidadNegativa,
        'asientoContable' => "Devolución de ropa - $descripcion"
    ], '🔄 Devolución procesada correctamente con asiento contable');
}

// Router principal
try {
    $action = $_GET['action'] ?? '';

    // Operaciones públicas (sin autenticación)
    $publicActions = ['getRopaByClub', 'getRopaByJugador', 'getRopaById', 'getRopaStats'];

    if (in_array($action, $publicActions)) {
        switch ($action) {
            case 'getRopaByClub':
                getRopaByClub($db, $cache);
                break;
            case 'getRopaByJugador':
                getRopaByJugador($db, $cache);
                break;
            case 'getRopaById':
                getRopaById($db, $cache);
                break;
            case 'getRopaStats':
                getRopaStats($db, $cache);
                break;
        }
    } else {
        // Operaciones que requieren autenticación
        $userData = $auth->authenticate();

        // Debug: Log action para verificar
        error_log("🔍 [Ropa] Action recibida: $action");

        switch ($action) {
            case 'createRopa':
                createRopa($db, $cache, $userData);
                break;
            case 'updateRopa':
                updateRopa($db, $cache, $userData);
                break;
            case 'updateEntregado':
                updateEntregado($db, $cache, $userData);
                break;
            case 'updateAvisado':
                updateAvisado($db, $cache, $userData);
                break;
            case 'deleteRopa':
                deleteRopa($db, $cache, $userData);
                break;
            case 'marcarDevolucion':
                marcarDevolucion($db, $cache, $userData);
                break;
            default:
                ResponseHelper::error('Acción no válida 🚫', 400);
        }
    }
} catch (Exception $e) {
    error_log("❌ Error en ropa.php: " . $e->getMessage());
    ResponseHelper::error('Error interno del servidor', 500);
}
