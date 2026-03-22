<?php
/**
 * Archivo de inicialización global
 * Configura errores y environment para TODOS los endpoints
 *
 * IMPORTANTE: Este archivo debe ser incluido al INICIO de cada endpoint
 * require_once __DIR__ . '/init.php';
 */

// Configuración de errores - NO mostrar en HTML (seguridad)
error_reporting(E_ALL);
ini_set('display_errors', 0); // NO mostrar errores en output HTML
ini_set('display_startup_errors', 0);
ini_set('log_errors', 1); // SÍ guardar en log

// Crear directorio de logs si no existe
$logsDir = __DIR__ . '/logs';
if (!is_dir($logsDir)) {
    @mkdir($logsDir, 0755, true);
}

// Si no se puede crear, usar log por defecto de PHP
if (is_dir($logsDir) && is_writable($logsDir)) {
    ini_set('error_log', $logsDir . '/php_errors.log');
}

// Configuración de zona horaria
date_default_timezone_set('Europe/Madrid');

// Configuración de output buffering (prevenir output antes de headers)
ob_start();

// Registrar función para limpiar buffer al final
register_shutdown_function(function() {
    // Si hay un error fatal, capturarlo
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        // Limpiar cualquier output previo
        ob_clean();

        // Enviar respuesta JSON de error
        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'message' => 'Error interno del servidor',
            'code' => 500
        ]);

        // Loguear el error
        error_log("FATAL ERROR: " . $error['message'] . " in " . $error['file'] . ":" . $error['line']);
    }

    // Enviar el buffer
    ob_end_flush();
});

// Handler personalizado para excepciones no capturadas
set_exception_handler(function($exception) {
    // Limpiar buffer
    if (ob_get_level()) {
        ob_clean();
    }

    // Respuesta JSON
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => false,
        'message' => 'Error interno del servidor',
        'code' => 500
    ]);

    // Loguear
    error_log("UNCAUGHT EXCEPTION: " . $exception->getMessage() . " in " . $exception->getFile() . ":" . $exception->getLine());
    error_log("Stack trace: " . $exception->getTraceAsString());
});

// Evitar que se cargue este archivo directamente
if (basename($_SERVER['SCRIPT_FILENAME']) === 'init.php') {
    http_response_code(403);
    die('Acceso directo no permitido');
}
