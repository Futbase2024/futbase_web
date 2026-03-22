<?php
/**
 * Configuración de CORS
 *
 * Permite peticiones desde dominios específicos
 */

// Configurar origins permitidos
$allowedOrigins = [
    'http://localhost:3000',
    'https://futbase.es',
    'https://www.futbase.es',
    'capacitor://localhost', // Para apps móviles Capacitor
    'ionic://localhost',     // Para apps móviles Ionic
];

// Obtener el origin de la petición
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

// Verificar si el origin está permitido
if (in_array($origin, $allowedOrigins)) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    // En desarrollo, permitir todos los origins
    // IMPORTANTE: En producción, comentar esta línea
    header("Access-Control-Allow-Origin: *");
}

// Headers permitidos
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Max-Age: 86400'); // 24 horas

// Nota: Content-Type se establece en cada endpoint individual
