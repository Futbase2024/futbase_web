<?php
/**
 * Clase y funciones helper para respuestas JSON estandarizadas
 */

class ResponseHelper {
    /**
     * Respuesta exitosa
     */
    public static function success($data = null, $message = null) {
        // Limpiar cualquier output previo (warnings, notices, HTML)
        while (ob_get_level() > 0) {
            ob_end_clean();
        }
        header('Content-Type: application/json; charset=utf-8');
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'data' => $data,
            'message' => $message
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Respuesta de error
     */
    public static function error($message, $code = 400, $data = null) {
        // Limpiar cualquier output previo (warnings, notices, HTML)
        while (ob_get_level() > 0) {
            ob_end_clean();
        }
        header('Content-Type: application/json; charset=utf-8');
        http_response_code($code);
        echo json_encode([
            'success' => false,
            'message' => $message,
            'data' => $data,
            'code' => $code
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

/**
 * Funciones globales (wrappers para compatibilidad)
 */
function respondSuccess($data = null, $message = null) {
    ResponseHelper::success($data, $message);
}

function respondError($message, $code = 400, $data = null) {
    ResponseHelper::error($message, $code, $data);
}

/**
 * Respuesta 404 Not Found
 */
function respondNotFound($message = 'Recurso no encontrado') {
    respondError($message, 404);
}

/**
 * Respuesta 401 Unauthorized
 */
function respondUnauthorized($message = 'No autenticado') {
    respondError($message, 401);
}

/**
 * Respuesta 403 Forbidden
 */
function respondForbidden($message = 'No tienes permisos suficientes') {
    respondError($message, 403);
}

/**
 * Respuesta 500 Internal Server Error
 */
function respondInternalError($message = 'Error interno del servidor') {
    respondError($message, 500);
}

/**
 * Respuesta de validación fallida
 */
function respondValidationError($errors) {
    respondError('Errores de validación', 422, $errors);
}
