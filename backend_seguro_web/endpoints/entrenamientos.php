<?php
/**
 * Endpoint seguro para gestión de entrenamientos
 * Operaciones CRUD y consultas de entrenamientos
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/CacheManager.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../middleware/FirebaseAuthMiddleware.php';
require_once __DIR__ . '/../config/cors.php';

// Manejar OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Responder con éxito
 */
function respondSuccess($data) {
    http_response_code(200);
    echo json_encode(['success' => true, 'data' => $data]);
    exit;
}

/**
 * Responder con error
 */
function respondError($message, $code = 400) {
    http_response_code($code);
    echo json_encode(['success' => false, 'error' => $message, 'message' => $message, 'code' => $code]);
    exit;
}

/**
 * Obtiene entrenamientos por club y temporada
 */
function getByClubTemporada($db, $cache, $userData) {
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idclub || !$idtemporada) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "entrenamientos_club_{$idclub}_temporada_{$idtemporada}";

    $entrenamientos = $cache->remember($cacheKey, function() use ($db, $idclub, $idtemporada) {
        $sql = "SELECT * FROM ventrenamientos
                WHERE idtemporada = ? AND idclub = ?
                ORDER BY fecha DESC";
        return $db->select($sql, [$idtemporada, $idclub]);
    });

    respondSuccess($entrenamientos);
}

/**
 * Obtiene entrenamientos por equipo y temporada
 */
function getByTeamTemporada($db, $cache, $userData) {
    $idequipo = Validator::validateInt($_GET['idequipo'] ?? null);
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);

    if (!$idequipo || !$idtemporada) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "entrenamientos_team_{$idequipo}_temporada_{$idtemporada}";

    $entrenamientos = $cache->remember($cacheKey, function() use ($db, $idequipo, $idtemporada) {
        $sql = "SELECT * FROM ventrenamientos
                WHERE idtemporada = ? AND idequipo = ?
                ORDER BY fecha DESC";
        return $db->select($sql, [$idtemporada, $idequipo]);
    });

    respondSuccess($entrenamientos);
}

/**
 * Obtiene entrenamientos por temporada y fecha
 */
function getByTemporadaAndFecha($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $fecha = $_GET['fecha'] ?? null;
    $idclub = Validator::validateInt($_GET['idclub'] ?? 0);

    if (!$idtemporada || !$fecha) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "entrenamientos_temporada_{$idtemporada}_fecha_{$fecha}_club_{$idclub}";

    $entrenamientos = $cache->remember($cacheKey, function() use ($db, $idtemporada, $fecha, $idclub) {
        if ($idclub == 0) {
            $sql = "SELECT * FROM ventrenamientos
                    WHERE idtemporada = ? AND fecha = ?
                    ORDER BY fecha DESC";
            return $db->select($sql, [$idtemporada, $fecha]);
        } else {
            $sql = "SELECT * FROM ventrenamientos
                    WHERE idtemporada = ? AND fecha = ? AND idclub = ?
                    ORDER BY fecha DESC";
            return $db->select($sql, [$idtemporada, $fecha, $idclub]);
        }
    }, 120); // Caché de 2 minutos

    respondSuccess($entrenamientos);
}

/**
 * Refresca entrenamientos en vivo
 */
function refreshLive($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);

    if (!$idtemporada || !$idclub) {
        respondError('Parámetros inválidos', 400);
    }

    // No usar caché para entrenamientos en vivo
    $sql = "SELECT * FROM ventrenamientos
            WHERE idtemporada = ? AND idclub = ? AND finalizado = 0
            ORDER BY fecha DESC";
    $entrenamientos = $db->select($sql, [$idtemporada, $idclub]);

    respondSuccess($entrenamientos);
}

/**
 * Obtiene entrenamientos en vivo por fecha
 */
function getByFechaEnVivo($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);
    $fecha = $_GET['fecha'] ?? null;

    if (!$idtemporada || !$idclub || !$fecha) {
        respondError('Parámetros inválidos', 400);
    }

    // No usar caché para entrenamientos en vivo
    $sql = "SELECT * FROM ventrenamientos
            WHERE idtemporada = ? AND idclub = ? AND fecha = ?
            ORDER BY fecha DESC";
    $entrenamientos = $db->select($sql, [$idtemporada, $idclub, $fecha]);

    respondSuccess($entrenamientos);
}

/**
 * Obtiene entrenamientos por día
 */
function getPorDia($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $fecha = $_GET['fecha'] ?? null;
    $idclub = Validator::validateInt($_GET['idclub'] ?? null);

    if (!$idtemporada || !$fecha || !$idclub) {
        respondError('Parámetros inválidos', 400);
    }

    $cacheKey = "entrenamientos_dia_{$fecha}_temporada_{$idtemporada}_club_{$idclub}";

    $entrenamientos = $cache->remember($cacheKey, function() use ($db, $idtemporada, $fecha, $idclub) {
        $sql = "SELECT * FROM ventrenamientos
                WHERE idtemporada = ? AND fecha = ? AND idclub = ?
                ORDER BY fecha DESC";
        return $db->select($sql, [$idtemporada, $fecha, $idclub]);
    }, 120); // Caché de 2 minutos

    respondSuccess($entrenamientos);
}

/**
 * Obtiene entrenamiento por ID
 */
function getById($db, $cache, $userData) {
    $id = Validator::validateInt($_GET['id'] ?? null);

    if (!$id) {
        respondError('ID inválido', 400);
    }

    $cacheKey = "entrenamiento_{$id}";

    $entrenamiento = $cache->remember($cacheKey, function() use ($db, $id) {
        $sql = "SELECT * FROM ventrenamientos WHERE id = ?";
        return $db->selectOne($sql, [$id]);
    });

    if (!$entrenamiento) {
        respondError('Entrenamiento no encontrado', 404);
    }

    respondSuccess($entrenamiento);
}

/**
 * Crea un nuevo entrenamiento
 */
function create($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);

    $fecha = $input['fecha'] ?? null;
    $hinicio = $input['hinicio'] ?? $input['hora'] ?? null;
    $hfin = $input['hfin'] ?? null;
    $nombre = $input['nombre'] ?? '';
    $idtemporada = Validator::validateInt($input['idtemporada'] ?? null);
    $idequipo = Validator::validateInt($input['idequipo'] ?? null);
    $idclub = Validator::validateInt($input['idclub'] ?? null);
    $idlugar = Validator::validateInt($input['idlugar'] ?? 0);
    $finalizado = Validator::validateInt($input['finalizado'] ?? 0);
    $tlimite = Validator::validateInt($input['tlimite'] ?? 0);

    if (!$fecha || !$idtemporada || !$idequipo || !$idclub) {
        respondError('Parámetros obligatorios faltantes', 400);
    }

    try {
        $db->beginTransaction();

        // Verificar si ya existe un entrenamiento similar
        $sqlCheck = "SELECT * FROM tentrenamientos WHERE nombre = ? AND hinicio = ?";
        $existe = $db->selectOne($sqlCheck, [$nombre, $hinicio]);

        if ($existe) {
            $db->rollback();
            respondError('Ya existe un entrenamiento igual', 409);
        }

        $sql = "INSERT INTO tentrenamientos
                (idtemporada, idclub, idequipo, idlugar, nombre, fecha, hinicio, hfin, finalizado, tlimite)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $idEntrenamiento = $db->insert($sql, [
            $idtemporada, $idclub, $idequipo, $idlugar, $nombre, $fecha, $hinicio, $hfin, $finalizado, $tlimite
        ]);

        // Actualizar jugadores del equipo para marcar con entrenamiento
        $sqlUpdate = "UPDATE tjugadores SET conventreno = 1 WHERE idequipo = ? AND activo = 1";
        $db->execute($sqlUpdate, [$idequipo]);

        $db->commit();
        $cache->clear();

        $entrenamientoCreado = $db->selectOne("SELECT * FROM ventrenamientos WHERE id = ?", [$idEntrenamiento]);

        if (!$entrenamientoCreado) {
            respondError('Error al obtener el entrenamiento creado', 500);
        }

        respondSuccess($entrenamientoCreado);
    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en create entrenamiento: " . $e->getMessage());
        error_log("Input recibido: " . json_encode($input));
        respondError('Error al crear: ' . $e->getMessage(), 500);
    }
}

/**
 * Actualiza un entrenamiento
 */
function update($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('ID inválido', 400);
    }

    try {
        $db->beginTransaction();

        // Construir los campos a actualizar dinámicamente
        $fieldsToUpdate = [];
        $params = [];

        // Campos que se pueden actualizar
        $allowedFields = [
            'fecha', 'hinicio', 'hfin', 'nombre', 'idtemporada', 'idequipo', 'idclub', 'idlugar',
            'lugar', 'observaciones', 'obsentrenador', 'informe', 'idsesion', 'tlimite', 'finalizado', 'notificado'
        ];

        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $fieldsToUpdate[] = "$field = ?";
                $params[] = $input[$field];
            }
        }

        if (empty($fieldsToUpdate)) {
            respondError('No hay campos para actualizar', 400);
        }

        $params[] = $id; // ID para WHERE
        $sql = "UPDATE tentrenamientos SET " . implode(', ', $fieldsToUpdate) . " WHERE id = ?";

        $affected = $db->execute($sql, $params);

        $db->commit();
        $cache->clear();

        $entrenamientoActualizado = $db->selectOne("SELECT * FROM ventrenamientos WHERE id = ?", [$id]);

        if (!$entrenamientoActualizado) {
            respondError('Entrenamiento no encontrado después de actualizar', 404);
        }

        respondSuccess($entrenamientoActualizado);
    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en update entrenamiento ID $id: " . $e->getMessage());
        error_log("Input recibido: " . json_encode($input));
        respondError('Error al actualizar: ' . $e->getMessage(), 500);
    }
}

/**
 * Elimina un entrenamiento
 */
function delete($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('ID inválido', 400);
    }

    try {
        $db->beginTransaction();
        $db->execute("DELETE FROM tentrenojugador WHERE identrenamiento = ?", [$id]);
        $affected = $db->execute("DELETE FROM tentrenamientos WHERE id = ?", [$id]);
        $db->commit();
        $cache->clear();

        respondSuccess(['success' => true, 'affected_rows' => $affected]);
    } catch (Exception $e) {
        $db->rollback();
        error_log("Error en delete: " . $e->getMessage());
        respondError('Error al eliminar', 500);
    }
}

/**
 * Finaliza un entrenamiento
 */
function finalizar($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);

    if (!$id) {
        respondError('ID inválido', 400);
    }

    try {
        $sql = "UPDATE tentrenamientos SET finalizado = 1 WHERE id = ?";
        $db->execute($sql, [$id]);
        $cache->clear();

        $entrenamiento = $db->selectOne("SELECT * FROM ventrenamientos WHERE id = ?", [$id]);
        respondSuccess($entrenamiento);
    } catch (Exception $e) {
        error_log("Error en finalizar: " . $e->getMessage());
        respondError('Error al finalizar', 500);
    }
}

/**
 * Edita observaciones
 */
function editarObservaciones($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);
    $observaciones = $input['observaciones'] ?? '';

    if (!$id) {
        respondError('ID inválido', 400);
    }

    try {
        $sql = "UPDATE tentrenamientos SET observaciones = ? WHERE id = ?";
        $affected = $db->execute($sql, [$observaciones, $id]);
        $cache->clear();

        respondSuccess(['success' => true, 'affected_rows' => $affected]);
    } catch (Exception $e) {
        error_log("Error en editarObservaciones: " . $e->getMessage());
        respondError('Error', 500);
    }
}

/**
 * Edita observaciones entrenador
 */
function editarObsEntrenador($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);
    $obsentrenador = $input['obsentrenador'] ?? '';

    if (!$id) {
        respondError('ID inválido', 400);
    }

    try {
        $sql = "UPDATE tentrenamientos SET obsentrenador = ? WHERE id = ?";
        $affected = $db->execute($sql, [$obsentrenador, $id]);
        $cache->clear();

        respondSuccess(['success' => true, 'affected_rows' => $affected]);
    } catch (Exception $e) {
        error_log("Error: " . $e->getMessage());
        respondError('Error', 500);
    }
}

/**
 * Edita mensaje
 */
function editarMensaje($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);
    $mensaje = $input['mensaje'] ?? '';

    if (!$id) {
        respondError('ID inválido', 400);
    }

    try {
        $sql = "UPDATE tentrenamientos SET mensaje = ? WHERE id = ?";
        $affected = $db->execute($sql, [$mensaje, $id]);
        $cache->clear();

        respondSuccess(['success' => true, 'affected_rows' => $affected]);
    } catch (Exception $e) {
        error_log("Error: " . $e->getMessage());
        respondError('Error', 500);
    }
}

/**
 * Cuenta entrenamientos
 */
function countEntrenamientos($db, $cache, $userData) {
    $idtemporada = Validator::validateInt($_GET['idtemporada'] ?? null);
    $permisos = Validator::validateInt($_GET['permisos'] ?? 0);
    $idequipo = Validator::validateInt($_GET['idequipo'] ?? 0);
    $idclub = Validator::validateInt($_GET['idclub'] ?? 0);

    if (!$idtemporada) {
        respondError('Parámetros inválidos', 400);
    }

    $sql = '';
    $params = [$idtemporada];

    if ($permisos == 1) {
        $sql = "SELECT COUNT(*) as count FROM tentrenamientos WHERE idtemporada = ?";
    } else if ($permisos == 2 || $permisos == 12 || $permisos == 13) {
        $sql = "SELECT COUNT(*) as count FROM tentrenamientos
                WHERE idtemporada = ? AND idequipo = ? AND finalizado = 0";
        $params[] = $idequipo;
    } else if ($permisos == 3 || $permisos == 10) {
        $sql = "SELECT COUNT(*) as count FROM tentrenamientos
                WHERE idtemporada = ? AND idclub = ? AND finalizado = 0";
        $params[] = $idclub;
    } else {
        $sql = "SELECT COUNT(*) as count FROM tentrenamientos WHERE idtemporada = ?";
    }

    $result = $db->selectOne($sql, $params);
    $count = intval($result['count'] ?? 0);

    http_response_code(200);
    echo json_encode(['success' => true, 'count' => $count]);
    exit;
}

/**
 * Edita notificado
 */
function editarNotificado($db, $cache, $userData) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = Validator::validateInt($input['id'] ?? null);
    $notificado = Validator::validateInt($input['notificado'] ?? null);
    $observaciones = $input['observaciones'] ?? '';

    if (!$id || $notificado === null) {
        respondError('Parámetros inválidos', 400);
    }

    try {
        $sql = "UPDATE tentrenamientos SET notificado = ?, observaciones = ? WHERE id = ?";
        $affected = $db->execute($sql, [$notificado, $observaciones, $id]);
        $cache->clear();

        respondSuccess(['success' => true, 'affected_rows' => $affected]);
    } catch (Exception $e) {
        error_log("Error: " . $e->getMessage());
        respondError('Error', 500);
    }
}

/**
 * Obtiene jugadores convocados
 */
function getJugadoresConvocados($db, $cache, $userData) {
    $identrenamiento = Validator::validateInt($_GET['identrenamiento'] ?? null);

    if (!$identrenamiento) {
        respondError('Parámetros inválidos', 400);
    }

    // No usar caché para asistencia en tiempo real
    $sql = "SELECT * FROM ventrenojugador WHERE identrenamiento = ? ORDER BY nombre";
    $jugadores = $db->select($sql, [$identrenamiento]);

    respondSuccess($jugadores);
}

// Inicialización
$middleware = new FirebaseAuthMiddleware();
$db = Database::getInstance();
$cache = new CacheManager(300);

try {
    $action = $_GET['action'] ?? null;

    if (!$action) {
        $rawInput = file_get_contents('php://input');
        $jsonInput = json_decode($rawInput, true);
        $action = $jsonInput['action'] ?? $_POST['action'] ?? null;
    }

    // Rate limit diferenciado: lecturas 100/60s, escrituras 50/60s
    $writeActions = ['create', 'update', 'delete', 'finalizar', 'editarObservaciones', 'editarObsEntrenador', 'editarMensaje', 'editarNotificado'];
    $isWrite = in_array($action, $writeActions);

    $userData = $isWrite
        ? $middleware->protect(50, 60, true)  // Escrituras: 50 req/60s
        : $middleware->protect(100, 60, true); // Lecturas: 100 req/60s

    switch ($action) {
        case 'getByClubTemporada': getByClubTemporada($db, $cache, $userData); break;
        case 'getByTeamTemporada': getByTeamTemporada($db, $cache, $userData); break;
        case 'getByTemporadaAndFecha': getByTemporadaAndFecha($db, $cache, $userData); break;
        case 'refreshLive': refreshLive($db, $cache, $userData); break;
        case 'getByFechaEnVivo': getByFechaEnVivo($db, $cache, $userData); break;
        case 'getPorDia': getPorDia($db, $cache, $userData); break;
        case 'getById': getById($db, $cache, $userData); break;
        case 'create': create($db, $cache, $userData); break;
        case 'update': update($db, $cache, $userData); break;
        case 'delete': delete($db, $cache, $userData); break;
        case 'finalizar': finalizar($db, $cache, $userData); break;
        case 'editarObservaciones': editarObservaciones($db, $cache, $userData); break;
        case 'editarObsEntrenador': editarObsEntrenador($db, $cache, $userData); break;
        case 'editarMensaje': editarMensaje($db, $cache, $userData); break;
        case 'count': countEntrenamientos($db, $cache, $userData); break;
        case 'editarNotificado': editarNotificado($db, $cache, $userData); break;
        case 'getJugadoresConvocados': getJugadoresConvocados($db, $cache, $userData); break;
        case 'listarArchivosExistentes': listarArchivosExistentes($db, $cache, $userData); break;
        case 'listarArchivos': listarArchivos($db, $cache, $userData); break;
        case 'subirArchivo': subirArchivo($db, $cache, $userData); break;
        case 'guardarRegistroArchivo': guardarRegistroArchivo($db, $cache, $userData); break;
        case 'eliminarArchivo': eliminarArchivo($db, $cache, $userData); break;
        case 'eliminarSoloRegistro': eliminarSoloRegistro($db, $cache, $userData); break;
        case 'eliminarArchivoDelServidor': eliminarArchivoDelServidor($db, $cache, $userData); break;
        default: respondError('Acción no válida', 400);
    }
} catch (Exception $e) {
    error_log("Entrenamientos error: " . $e->getMessage());
    respondError('Error en el servidor', 500);
}

// ============================================================================
// FUNCIONES DE GESTIÓN DE ARCHIVOS
// ============================================================================

/**
 * Lista todos los archivos existentes en la base de datos
 * Opcionalmente filtra por nombre original
 */
function listarArchivosExistentes($db, $cache, $userData) {
    $filtroNombre = $_GET['filtroNombre'] ?? null;

    // Construir SQL con filtro opcional
    if ($filtroNombre && trim($filtroNombre) !== '') {
        $filtroLimpio = trim($filtroNombre);
        $sql = "SELECT * FROM ventrenamiento_archivos WHERE nombreoriginal LIKE ? ORDER BY fechasubida DESC";
        $params = ["%$filtroLimpio%"];
    } else {
        $sql = "SELECT * FROM ventrenamiento_archivos ORDER BY fechasubida DESC";
        $params = [];
    }

    $archivos = $db->select($sql, $params);
    respondSuccess($archivos, '✅ ' . count($archivos) . ' archivos encontrados');
}

/**
 * Lista archivos de un entrenamiento específico
 */
function listarArchivos($db, $cache, $userData) {
    $idEntrenamiento = $_GET['idEntrenamiento'] ?? null;

    if (!$idEntrenamiento) {
        respondError('idEntrenamiento es requerido', 400);
        return;
    }

    $sql = "SELECT * FROM ventrenamiento_archivos WHERE identrenamiento = ? ORDER BY fechasubida ASC";
    $archivos = $db->select($sql, [$idEntrenamiento]);

    respondSuccess($archivos, '✅ ' . count($archivos) . ' archivos del entrenamiento');
}

/**
 * Sube un archivo al servidor y devuelve la URL
 */
function subirArchivo($db, $cache, $userData) {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $archivoBase64 = $data['archivo'] ?? null;
    $nombreOriginal = $data['nombreOriginal'] ?? null;
    $tipo = $data['tipo'] ?? null;

    if (!$archivoBase64 || !$nombreOriginal || !$tipo) {
        respondError('Parámetros incompletos', 400);
        return;
    }

    try {
        // Decodificar el archivo base64
        $archivoBytes = base64_decode($archivoBase64);
        if ($archivoBytes === false) {
            respondError('Error al decodificar el archivo', 400);
            return;
        }

        // Generar nombre único para el archivo
        $extension = pathinfo($nombreOriginal, PATHINFO_EXTENSION);
        $nombreUnico = uniqid() . '_' . time() . '.' . $extension;

        // Directorio donde se guardarán los archivos
        $directorioDestino = __DIR__ . '/../../entrenamientos_archivos/';

        // Crear directorio si no existe
        if (!is_dir($directorioDestino)) {
            mkdir($directorioDestino, 0755, true);
        }

        $rutaCompleta = $directorioDestino . $nombreUnico;

        // Guardar archivo
        if (file_put_contents($rutaCompleta, $archivoBytes) === false) {
            respondError('Error al guardar el archivo', 500);
            return;
        }

        // Construir URL del archivo
        $url = 'https://futbase.es/entrenamientos_archivos/' . $nombreUnico;

        respondSuccess(['url' => $url], '✅ Archivo subido correctamente');

    } catch (Exception $e) {
        error_log("Error subiendo archivo: " . $e->getMessage());
        respondError('Error al subir el archivo', 500);
    }
}

/**
 * Guarda el registro de un archivo en la base de datos
 */
function guardarRegistroArchivo($db, $cache, $userData) {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $idEntrenamiento = $data['idEntrenamiento'] ?? null;
    $urlArchivo = $data['urlArchivo'] ?? null;
    $tipo = $data['tipo'] ?? null;
    $nombreOriginal = $data['nombreOriginal'] ?? null;
    $familia = $data['familia'] ?? null;

    if (!$idEntrenamiento || !$urlArchivo || !$tipo || !$nombreOriginal) {
        respondError('Parámetros incompletos', 400);
        return;
    }

    if ($familia) {
        $sql = "INSERT INTO entrenamiento_archivos (identrenamiento, urlarchivo, tipo, nombreoriginal, familia)
                VALUES (?, ?, ?, ?, ?)";
        $params = [$idEntrenamiento, $urlArchivo, $tipo, $nombreOriginal, $familia];
    } else {
        $sql = "INSERT INTO entrenamiento_archivos (identrenamiento, urlarchivo, tipo, nombreoriginal)
                VALUES (?, ?, ?, ?)";
        $params = [$idEntrenamiento, $urlArchivo, $tipo, $nombreOriginal];
    }

    $db->execute($sql, $params);
    respondSuccess(null, '✅ Registro guardado correctamente');
}

/**
 * Elimina un archivo completo (registro + archivo físico)
 */
function eliminarArchivo($db, $cache, $userData) {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $idArchivo = $data['idArchivo'] ?? null;
    $urlArchivo = $data['urlArchivo'] ?? null;

    if (!$idArchivo || !$urlArchivo) {
        respondError('Parámetros incompletos', 400);
        return;
    }

    try {
        // Extraer nombre del archivo de la URL
        $partes = explode('/', $urlArchivo);
        $nombreArchivo = end($partes);

        // Ruta del archivo en el servidor
        $rutaArchivo = __DIR__ . '/../../entrenamientos_archivos/' . $nombreArchivo;

        // Eliminar archivo físico si existe
        if (file_exists($rutaArchivo)) {
            if (!unlink($rutaArchivo)) {
                error_log("No se pudo eliminar el archivo físico: $rutaArchivo");
            }
        }

        // Eliminar registro de la base de datos
        $sql = "DELETE FROM entrenamiento_archivos WHERE id = ?";
        $db->execute($sql, [$idArchivo]);

        respondSuccess(null, '✅ Archivo eliminado correctamente');

    } catch (Exception $e) {
        error_log("Error eliminando archivo: " . $e->getMessage());
        respondError('Error al eliminar el archivo', 500);
    }
}

/**
 * Elimina solo el registro de la base de datos (sin borrar el archivo físico)
 */
function eliminarSoloRegistro($db, $cache, $userData) {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $idArchivo = $data['idArchivo'] ?? null;

    if (!$idArchivo) {
        respondError('idArchivo es requerido', 400);
        return;
    }

    $sql = "DELETE FROM entrenamiento_archivos WHERE id = ?";
    $db->execute($sql, [$idArchivo]);

    respondSuccess(null, '✅ Registro eliminado correctamente');
}

/**
 * Elimina solo el archivo físico del servidor (sin tocar la base de datos)
 */
function eliminarArchivoDelServidor($db, $cache, $userData) {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $urlArchivo = $data['urlArchivo'] ?? null;

    if (!$urlArchivo) {
        respondError('urlArchivo es requerido', 400);
        return;
    }

    try {
        // Extraer nombre del archivo de la URL
        $partes = explode('/', $urlArchivo);
        $nombreArchivo = end($partes);

        // Ruta del archivo en el servidor
        $rutaArchivo = __DIR__ . '/../../entrenamientos_archivos/' . $nombreArchivo;

        // Eliminar archivo físico si existe
        if (file_exists($rutaArchivo)) {
            if (unlink($rutaArchivo)) {
                respondSuccess(null, '✅ Archivo eliminado del servidor');
            } else {
                respondError('No se pudo eliminar el archivo', 500);
            }
        } else {
            respondSuccess(null, '⚠️ El archivo no existe en el servidor');
        }

    } catch (Exception $e) {
        error_log("Error eliminando archivo del servidor: " . $e->getMessage());
        respondError('Error al eliminar el archivo', 500);
    }
}
