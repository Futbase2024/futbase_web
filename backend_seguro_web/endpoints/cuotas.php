<?php
/**
 * Endpoint de cuotas con manejo robusto de errores
 * Asegura que SIEMPRE se devuelva JSON, nunca HTML
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
$cache = new CacheManager(300);
$auth = new FirebaseAuthMiddleware();
$userData = $auth->protect(100, 60);

$action = $_GET['action'] ?? '';

try {
    switch ($action) {
        // Operaciones de lectura
        case 'getcuotabyid':
            getcuotabyid($db, $cache);
            break;
        case 'getcuotasbyclub':
            getcuotasbyclub($db, $cache);
            break;
        case 'diagnostico_cuotas':
            diagnostico_cuotas($db);
            break;
        case 'getcuotabyplayertemp':
            getcuotabyplayertemp($db, $cache);
            break;
        case 'getcuotawithoutid':
            getcuotawithoutid($db, $cache);
            break;

        // Operaciones de escritura
        case 'createcuota':
            createcuota($db, $cache);
            break;
        case 'updatecuota':
            updatecuota($db, $cache);
            break;
        case 'updatetypecuota':
            updatetypecuota($db, $cache);
            break;
        case 'deletecuota':
            deletecuota($db, $cache);
            break;
        case 'deletecuotabyid':
            deletecuotabyid($db, $cache);
            break;
        default:
            respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("[Cuotas] Error general: " . $e->getMessage());
    error_log("[Cuotas] Stack trace: " . $e->getTraceAsString());
    respondInternalError('Error al procesar la solicitud');
}

function getcuotabyid($db, $cache) {
    try {
        $id = $_GET['id'] ?? null;
        if (!$id) {
            respondError('id requerido', 400);
        }

        error_log("[Cuotas] Obteniendo cuota por ID: {$id}");

        $cacheKey = "cuota_{$id}";
        $cuota = $cache->remember($cacheKey, function() use ($db, $id) {
            $sql = 'SELECT * FROM tcuotas WHERE id = ?';
            return $db->selectOne($sql, [$id]);
        }, 300);

        respondSuccess(['cuota' => $cuota ?? ['id' => 0]]);
    } catch (Exception $e) {
        error_log("[Cuotas] Error en getcuotabyid: " . $e->getMessage());
        respondSuccess(['cuota' => ['id' => 0]]);
    }
}

function getcuotasbyclub($db, $cache) {
    try {
        $idclub = $_GET['idclub'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;

        if (!$idclub) {
            respondError('idclub requerido', 400);
        }

        error_log("[Cuotas] Obteniendo cuotas - Club: {$idclub}, Temporada: " . ($idtemporada ?? 'todas'));

        // NO USAR CACHÉ por ahora para debug
        try {
            // VERIFICACIONES DE DEBUG PREVIAS
            error_log("[Cuotas] ===== INICIO DEBUG DETALLADO =====");

            // 1. Verificar tabla existe
            $checkTable = $db->select("SHOW TABLES LIKE 'tcuotas'");
            error_log("[Cuotas] ¿Existe tabla tcuotas? " . (count($checkTable) > 0 ? 'SÍ' : 'NO'));

            // 2. Contar TODAS las cuotas en la tabla
            $totalGeneral = $db->selectOne("SELECT COUNT(*) as total FROM tcuotas");
            error_log("[Cuotas] Total GENERAL de cuotas en tabla: " . ($totalGeneral['total'] ?? '0'));

            // 3. Contar cuotas del club
            $totalClub = $db->selectOne("SELECT COUNT(*) as total FROM tcuotas WHERE idclub = ?", [$idclub]);
            error_log("[Cuotas] Total cuotas del club {$idclub}: " . ($totalClub['total'] ?? '0'));

            // 4. Si hay temporada, contar cuotas del club/temporada
            if ($idtemporada) {
                $totalClubTemp = $db->selectOne("SELECT COUNT(*) as total FROM tcuotas WHERE idclub = ? AND idtemporada = ?", [$idclub, $idtemporada]);
                error_log("[Cuotas] Total cuotas del club {$idclub} y temporada {$idtemporada}: " . ($totalClubTemp['total'] ?? '0'));

                // 5. Ver qué temporadas tiene el club
                $temporadasDelClub = $db->select("SELECT DISTINCT idtemporada FROM tcuotas WHERE idclub = ?", [$idclub]);
                error_log("[Cuotas] Temporadas con cuotas para club {$idclub}: " . json_encode(array_column($temporadasDelClub, 'idtemporada')));
            }

            // 6. Mostrar una muestra de cuotas del club (primeras 3)
            $muestra = $db->select("SELECT id, idclub, idtemporada, idjugador, cantidad FROM tcuotas WHERE idclub = ? LIMIT 3", [$idclub]);
            error_log("[Cuotas] Muestra de cuotas del club: " . json_encode($muestra));

            error_log("[Cuotas] ===== FIN DEBUG PREVIO =====");

            // Si se proporciona temporada, filtrar por ella
            // USAR vCuotas (vista con JOINs) en lugar de tcuotas (tabla básica)
            // para obtener campos calculados como nombre, apellidos, equipo, estado, tipo
            if ($idtemporada) {
                $sql = 'SELECT * FROM vCuotas WHERE idclub = ? AND idtemporada = ? ORDER BY id DESC';
                error_log("[Cuotas] SQL con temporada: {$sql}");
                error_log("[Cuotas] Params: idclub={$idclub}, idtemporada={$idtemporada}");
                $cuotas = $db->select($sql, [$idclub, $idtemporada]);
            } else {
                $sql = 'SELECT * FROM vCuotas WHERE idclub = ? ORDER BY id DESC';
                error_log("[Cuotas] SQL sin temporada: {$sql}");
                error_log("[Cuotas] Params: idclub={$idclub}");
                $cuotas = $db->select($sql, [$idclub]);
            }

            error_log("[Cuotas] Query ejecutada. Resultados: " . count($cuotas));

            if (count($cuotas) > 0) {
                error_log("[Cuotas] Primera cuota - ID: " . ($cuotas[0]['id'] ?? 'NULL') . ", Jugador: " . ($cuotas[0]['idjugador'] ?? 'NULL'));
                respondSuccess(['cuotas' => $cuotas]);
            } else {
                error_log("[Cuotas] ⚠️ La query NO devolvió resultados");

                // Si no hay cuotas, incluir información de diagnóstico en la respuesta
                respondSuccess([
                    'cuotas' => [],
                    'debug_info' => [
                        'tabla_existe' => count($checkTable) > 0,
                        'total_cuotas_tabla' => (int)($totalGeneral['total'] ?? 0),
                        'total_cuotas_club' => (int)($totalClub['total'] ?? 0),
                        'total_cuotas_club_temporada' => $idtemporada ? (int)($totalClubTemp['total'] ?? 0) : null,
                        'temporadas_disponibles' => $idtemporada ? array_column($temporadasDelClub, 'idtemporada') : null,
                        'muestra_cuotas_club' => array_slice($muestra, 0, 2), // Solo 2 para no saturar
                        'parametros_recibidos' => [
                            'idclub' => $idclub,
                            'idtemporada' => $idtemporada,
                        ],
                        'sql_ejecutado' => $sql,
                    ]
                ]);
            }

        } catch (Exception $e) {
            error_log("[Cuotas] Error en consulta SQL: " . $e->getMessage());
            error_log("[Cuotas] SQL Error Code: " . $e->getCode());
            error_log("[Cuotas] Stack trace: " . $e->getTraceAsString());
            respondSuccess(['cuotas' => []]);
        }

    } catch (Exception $e) {
        error_log("[Cuotas] Error general en getcuotasbyclub: " . $e->getMessage());
        respondSuccess(['cuotas' => []]);
    }
}

function getcuotabyplayertemp($db, $cache) {
    try {
        $idjugador = $_GET['idjugador'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;
        $mes = $_GET['mes'] ?? null;
        $year = $_GET['year'] ?? null;

        if (!$idjugador || !$idtemporada) {
            respondError('idjugador e idtemporada requeridos', 400);
        }

        error_log("[Cuotas] Obteniendo cuotas de jugador - Jugador: {$idjugador}, Temporada: {$idtemporada}, Mes: {$mes}, Year: {$year}");

        // Crear cache key que incluya mes/year si están presentes
        $cacheKey = "cuotas_jugador_{$idjugador}_temp_{$idtemporada}";
        if ($mes && $year) {
            $cacheKey .= "_mes_{$mes}_year_{$year}";
        }

        $cuotas = $cache->remember($cacheKey, function() use ($db, $idjugador, $idtemporada, $mes, $year) {
            $sql = 'SELECT * FROM vCuotas WHERE idjugador = ? AND idtemporada = ?';
            $params = [$idjugador, $idtemporada];

            // Si se especifica mes y año, filtrar por ellos
            if ($mes && $year) {
                $sql .= ' AND mes = ? AND year = ?';
                $params[] = $mes;
                $params[] = $year;
            }

            $sql .= ' ORDER BY id DESC';

            return $db->select($sql, $params);
        }, 300);

        respondSuccess(['cuotas' => $cuotas ?? []]);

    } catch (Exception $e) {
        error_log("[Cuotas] Error en getcuotabyplayertemp: " . $e->getMessage());
        respondSuccess(['cuotas' => []]);
    }
}

function getcuotawithoutid($db, $cache) {
    try {
        $idclub = $_GET['idclub'] ?? null;
        $idjugador = $_GET['idjugador'] ?? null;
        $mes = $_GET['mes'] ?? null;
        $year = $_GET['year'] ?? null;
        $idequipo = $_GET['idequipo'] ?? null;
        $idtipocuota = $_GET['idtipocuota'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;

        if (!$idclub || !$idjugador || !$mes || !$year || !$idtemporada) {
            respondError('Datos incompletos', 400);
        }

        error_log("[Cuotas] Buscando cuota por criterios - Club: {$idclub}, Jugador: {$idjugador}, Mes: {$mes}, Year: {$year}");

        $cacheKey = "cuota_criteria_{$idclub}_{$idjugador}_{$mes}_{$year}_{$idequipo}_{$idtipocuota}_{$idtemporada}";
        $cuota = $cache->remember($cacheKey, function() use ($db, $idclub, $idjugador, $mes, $year, $idequipo, $idtipocuota, $idtemporada) {
            $sql = 'SELECT * FROM vCuotas
                    WHERE idclub = ?
                    AND idjugador = ?
                    AND mes = ?
                    AND year = ?
                    AND idtemporada = ?';

            $params = [$idclub, $idjugador, $mes, $year, $idtemporada];

            if ($idequipo) {
                $sql .= ' AND idequipo = ?';
                $params[] = $idequipo;
            }

            if ($idtipocuota) {
                $sql .= ' AND idtipocuota = ?';
                $params[] = $idtipocuota;
            }

            $sql .= ' LIMIT 1';

            return $db->selectOne($sql, $params);
        }, 300);

        if ($cuota) {
            respondSuccess(['cuota' => $cuota]);
        } else {
            respondSuccess(['cuota' => null]);
        }

    } catch (Exception $e) {
        error_log("[Cuotas] Error en getcuotawithoutid: " . $e->getMessage());
        respondSuccess(['cuota' => null]);
    }
}

function createcuota($db, $cache) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        $idclub = $input['idclub'] ?? null;
        $idequipo = $input['idequipo'] ?? null;
        $idjugador = $input['idjugador'] ?? null;
        $mes = $input['mes'] ?? null;
        $year = $input['year'] ?? null;
        $idestado = $input['idestado'] ?? null;
        $cantidad = $input['cantidad'] ?? null;
        $idtipocuota = $input['idtipocuota'] ?? null;
        $idtemporada = $input['idtemporada'] ?? null;

        if (!$idclub || !$idjugador || !$idtemporada || !$mes || !$year || !$cantidad) {
            error_log("[Cuotas] Datos incompletos - Club: {$idclub}, Jugador: {$idjugador}, Temporada: {$idtemporada}, Mes: {$mes}, Year: {$year}, Cantidad: {$cantidad}");
            respondError('Datos incompletos', 400);
        }

        error_log("[Cuotas] Creando cuota - Club: {$idclub}, Jugador: {$idjugador}, Mes: {$mes}, Year: {$year}");

        $sql = 'INSERT INTO tcuotas (idclub, idequipo, idjugador, mes, year, idestado, cantidad, idtipocuota, idtemporada, timestamp)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())';
        $insertId = $db->insert($sql, [
            $idclub,
            $idequipo ?? 0,
            $idjugador,
            $mes,
            $year,
            $idestado ?? 2,
            $cantidad,
            $idtipocuota ?? 0,
            $idtemporada
        ]);

        if ($insertId) {
            // Invalidar cachés relacionados
            $cache->clear("cuotas_club_{$idclub}*");
            $cache->clear("cuotas_jugador_{$idjugador}*");
            // Invalidar también la caché de contabilidad
            $cache->clear("contabilidad_*");

            error_log("[Cuotas] Cuota creada con ID: {$insertId}");

            // Obtener la cuota creada
            $cuotaCreada = $db->selectOne('SELECT * FROM vCuotas WHERE id = ?', [$insertId]);
            respondSuccess(['cuota' => $cuotaCreada]);
        } else {
            respondInternalError('Error al crear cuota');
        }

    } catch (Exception $e) {
        error_log("[Cuotas] Error en createcuota: " . $e->getMessage());
        error_log("[Cuotas] Stack trace: " . $e->getTraceAsString());
        respondInternalError('Error al crear cuota');
    }
}

function updatecuota($db, $cache) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        $id = $input['id'] ?? null;
        $idestado = $input['idestado'] ?? null;
        $timestamp = $input['timestamp'] ?? null;

        if (!$id) {
            respondError('id requerido', 400);
        }

        error_log("[Cuotas] Actualizando cuota ID: {$id}, Estado: {$idestado}");

        // Construir SQL dinámicamente según los campos presentes
        $updates = [];
        $params = [];

        if ($idestado !== null) {
            $updates[] = 'idestado = ?';
            $params[] = $idestado;
        }

        if ($timestamp !== null) {
            $updates[] = 'timestamp = ?';
            $params[] = $timestamp;
        }

        if (empty($updates)) {
            respondError('No hay campos para actualizar', 400);
        }

        $params[] = $id; // Agregar ID al final para el WHERE
        $sql = 'UPDATE tcuotas SET ' . implode(', ', $updates) . ' WHERE id = ?';

        error_log("[Cuotas] SQL: {$sql}");
        $result = $db->update($sql, $params);

        if ($result !== false) {
            // Obtener info de la cuota para invalidar cachés relacionados
            $cuota = $db->selectOne('SELECT idclub, idjugador FROM tcuotas WHERE id = ?', [$id]);

            $cache->forget("cuota_{$id}");
            if ($cuota) {
                $cache->clear("cuotas_club_{$cuota['idclub']}*");
                $cache->clear("cuotas_jugador_{$cuota['idjugador']}*");
            }
            // Invalidar también la caché de contabilidad
            $cache->clear("contabilidad_*");

            respondSuccess(['success' => true]);
        } else {
            respondInternalError('Error al actualizar cuota');
        }

    } catch (Exception $e) {
        error_log("[Cuotas] Error en updatecuota: " . $e->getMessage());
        respondInternalError('Error al actualizar cuota');
    }
}

function updatetypecuota($db, $cache) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        $id = $input['id'] ?? null;
        $tipo = $input['tipo'] ?? null;
        $cantidad = $input['cantidad'] ?? null;

        if (!$id) {
            respondError('id requerido', 400);
        }

        error_log("[Cuotas] Actualizando tipo de cuota ID: {$id}, Tipo: {$tipo}, Cantidad: {$cantidad}");

        // Construir SQL dinámicamente según los campos presentes
        $updates = [];
        $params = [];

        if ($tipo !== null) {
            $updates[] = 'idtipocuota = ?';
            $params[] = $tipo;
        }

        if ($cantidad !== null) {
            $updates[] = 'cantidad = ?';
            $params[] = $cantidad;
        }

        if (empty($updates)) {
            respondError('No hay campos para actualizar', 400);
        }

        $params[] = $id; // Agregar ID al final para el WHERE
        $sql = 'UPDATE tcuotas SET ' . implode(', ', $updates) . ' WHERE id = ?';

        error_log("[Cuotas] SQL: {$sql}");
        $result = $db->update($sql, $params);

        if ($result !== false) {
            // Obtener info de la cuota para invalidar cachés relacionados
            $cuota = $db->selectOne('SELECT idclub, idjugador FROM tcuotas WHERE id = ?', [$id]);

            $cache->forget("cuota_{$id}");
            if ($cuota) {
                $cache->clear("cuotas_club_{$cuota['idclub']}*");
                $cache->clear("cuotas_jugador_{$cuota['idjugador']}*");
            }

            respondSuccess(['success' => true]);
        } else {
            respondInternalError('Error al actualizar tipo de cuota');
        }

    } catch (Exception $e) {
        error_log("[Cuotas] Error en updatetypecuota: " . $e->getMessage());
        respondInternalError('Error al actualizar tipo de cuota');
    }
}

function deletecuota($db, $cache) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        $id = $input['id'] ?? null;

        if (!$id) {
            respondError('id requerido', 400);
        }

        error_log("[Cuotas] Eliminando cuota ID: {$id}");

        // Obtener datos de la cuota antes de eliminarla (para invalidar cachés correctamente)
        $cuota = $db->selectOne('SELECT idclub, idjugador FROM tcuotas WHERE id = ?', [$id]);

        $sql = 'DELETE FROM tcuotas WHERE id = ?';
        $result = $db->delete($sql, [$id]);

        if ($result) {
            // Invalidar cachés relacionados
            $cache->forget("cuota_{$id}");
            if ($cuota) {
                $cache->clear("cuotas_club_{$cuota['idclub']}*");
                $cache->clear("cuotas_jugador_{$cuota['idjugador']}*");
            }
            // Invalidar también la caché de contabilidad
            $cache->clear("contabilidad_*");
            respondSuccess(['success' => true]);
        } else {
            respondInternalError('Error al eliminar cuota');
        }

    } catch (Exception $e) {
        error_log("[Cuotas] Error en deletecuota: " . $e->getMessage());
        respondInternalError('Error al eliminar cuota');
    }
}

function deletecuotabyid($db, $cache) {
    deletecuota($db, $cache);
}

function diagnostico_cuotas($db) {
    try {
        $idclub = $_GET['idclub'] ?? null;
        $idtemporada = $_GET['idtemporada'] ?? null;

        $diagnostico = [];

        // 1. Verificar tabla existe
        $checkTable = $db->select("SHOW TABLES LIKE 'tcuotas'");
        $diagnostico['tabla_existe'] = count($checkTable) > 0;

        // 2. Contar TODAS las cuotas en la tabla
        $totalGeneral = $db->selectOne("SELECT COUNT(*) as total FROM tcuotas");
        $diagnostico['total_cuotas_tabla'] = (int)($totalGeneral['total'] ?? 0);

        // 3. Estructura de la tabla
        $estructura = $db->select("DESCRIBE tcuotas");
        $diagnostico['columnas'] = array_column($estructura, 'Field');

        if ($idclub) {
            // 4. Contar cuotas del club
            $totalClub = $db->selectOne("SELECT COUNT(*) as total FROM tcuotas WHERE idclub = ?", [$idclub]);
            $diagnostico['total_cuotas_club'] = (int)($totalClub['total'] ?? 0);

            // 5. Temporadas con cuotas para este club
            $temporadasDelClub = $db->select("SELECT DISTINCT idtemporada FROM tcuotas WHERE idclub = ? ORDER BY idtemporada", [$idclub]);
            $diagnostico['temporadas_disponibles'] = array_column($temporadasDelClub, 'idtemporada');

            // 6. Muestra de cuotas del club (primeras 3)
            $muestra = $db->select("SELECT id, idclub, idtemporada, idjugador, cantidad FROM tcuotas WHERE idclub = ? LIMIT 3", [$idclub]);
            $diagnostico['muestra_cuotas'] = $muestra;

            if ($idtemporada) {
                // 7. Contar cuotas del club/temporada
                $totalClubTemp = $db->selectOne("SELECT COUNT(*) as total FROM tcuotas WHERE idclub = ? AND idtemporada = ?", [$idclub, $idtemporada]);
                $diagnostico['total_cuotas_club_temporada'] = (int)($totalClubTemp['total'] ?? 0);

                // 8. Muestra de cuotas del club/temporada
                $muestraTemp = $db->select("SELECT id, idclub, idtemporada, idjugador, cantidad FROM tcuotas WHERE idclub = ? AND idtemporada = ? LIMIT 3", [$idclub, $idtemporada]);
                $diagnostico['muestra_cuotas_temporada'] = $muestraTemp;
            }
        }

        // 9. Información de parámetros recibidos
        $diagnostico['parametros'] = [
            'idclub' => $idclub,
            'idtemporada' => $idtemporada,
        ];

        respondSuccess($diagnostico);

    } catch (Exception $e) {
        error_log("[Cuotas] Error en diagnóstico: " . $e->getMessage());
        respondInternalError('Error al ejecutar diagnóstico: ' . $e->getMessage());
    }
}
