<?php
/**
 * Endpoint para subir fichas federativas (imágenes o PDFs)
 * Guarda en: https://futbase.es/imagenes/fichas/
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
    exit();
}

try {
    // Directorio donde se guardarán las fichas
    $targetDir = $_SERVER['DOCUMENT_ROOT'] . '/imagenes/fichas/';

    // Crear directorio si no existe
    if (!is_dir($targetDir)) {
        mkdir($targetDir, 0755, true);
    }

    // Obtener datos del POST
    $fileData = $_POST['file'] ?? $_POST['image'] ?? null;
    $fileName = $_POST['name'] ?? null;

    if (!$fileData || !$fileName) {
        http_response_code(400);
        echo json_encode(['error' => 'Datos incompletos']);
        exit();
    }

    // Decodificar base64
    $decodedFile = base64_decode($fileData);

    if ($decodedFile === false) {
        http_response_code(400);
        echo json_encode(['error' => 'Error al decodificar el archivo']);
        exit();
    }

    // Ruta completa del archivo
    $filePath = $targetDir . $fileName;

    // Guardar archivo
    if (file_put_contents($filePath, $decodedFile) === false) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al guardar el archivo']);
        exit();
    }

    // URL pública del archivo
    $fileUrl = 'https://futbase.es/imagenes/fichas/' . $fileName;

    // Responder con la URL
    http_response_code(200);
    echo $fileUrl;

} catch (Exception $e) {
    error_log("Error en subida_ficha.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Error del servidor: ' . $e->getMessage()]);
}
