<?php
/**
 * Archivo de prueba básico
 * Verifica que PHP está funcionando y muestra información del servidor
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$tests = [];

// Test 1: PHP funcionando
$tests['php_version'] = [
    'status' => 'ok',
    'version' => phpversion(),
    'message' => 'PHP está funcionando correctamente'
];

// Test 2: Extensiones requeridas
$required_extensions = ['pdo', 'pdo_mysql', 'openssl', 'curl', 'json'];
$missing = [];
foreach ($required_extensions as $ext) {
    if (!extension_loaded($ext)) {
        $missing[] = $ext;
    }
}

$tests['extensions'] = [
    'status' => empty($missing) ? 'ok' : 'error',
    'required' => $required_extensions,
    'missing' => $missing,
    'message' => empty($missing) ? 'Todas las extensiones están instaladas' : 'Faltan extensiones: ' . implode(', ', $missing)
];

// Test 3: Permisos de escritura
$cache_dir = __DIR__ . '/cache/data/';
$logs_dir = __DIR__ . '/logs/';

$cache_writable = is_writable($cache_dir);
$logs_writable = is_writable($logs_dir);

$tests['permissions'] = [
    'status' => ($cache_writable && $logs_writable) ? 'ok' : 'error',
    'cache_writable' => $cache_writable,
    'logs_writable' => $logs_writable,
    'message' => ($cache_writable && $logs_writable) ? 'Permisos correctos' : 'Faltan permisos de escritura'
];

// Test 4: Conexión a base de datos
try {
    require_once __DIR__ . '/core/Database.php';
    $db = Database::getInstance();
    $result = $db->selectOne("SELECT 1 as test");

    $tests['database'] = [
        'status' => $result ? 'ok' : 'error',
        'message' => $result ? 'Conexión a BD exitosa' : 'Error al conectar a BD'
    ];
} catch (Exception $e) {
    $tests['database'] = [
        'status' => 'error',
        'message' => 'Error: ' . $e->getMessage()
    ];
}

// Test 5: Firebase Config
try {
    $firebase_config = require __DIR__ . '/config/firebase_config.php';
    $tests['firebase'] = [
        'status' => isset($firebase_config['project_id']) ? 'ok' : 'error',
        'project_id' => $firebase_config['project_id'] ?? 'NO CONFIGURADO',
        'message' => isset($firebase_config['project_id']) ? 'Firebase configurado' : 'Falta configurar Firebase'
    ];
} catch (Exception $e) {
    $tests['firebase'] = [
        'status' => 'error',
        'message' => 'Error: ' . $e->getMessage()
    ];
}

// Resumen
$all_ok = true;
foreach ($tests as $test) {
    if ($test['status'] !== 'ok') {
        $all_ok = false;
        break;
    }
}

// Respuesta
http_response_code($all_ok ? 200 : 500);
echo json_encode([
    'success' => $all_ok,
    'message' => $all_ok ? '✅ Todos los tests pasaron correctamente' : '❌ Algunos tests fallaron',
    'timestamp' => date('Y-m-d H:i:s'),
    'server_url' => $_SERVER['HTTP_HOST'] ?? 'unknown',
    'tests' => $tests
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
