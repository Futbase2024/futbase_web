<?php
/**
 * Configuración de JWT Firebase
 *
 * Firebase valida automáticamente los tokens JWT.
 * Solo necesitamos el Project ID de Firebase.
 */

return [
    // CRÍTICO: Cambiar esta clave en producción por una clave única y segura
    'jwt_secret_key' => 'TU_CLAVE_SECRETA_SUPER_SEGURA_CAMBIAR_EN_PRODUCCION_' . hash('sha256', 'futbase2024'),
    
    // Duración del token en segundos (24 horas)
    'jwt_expiration' => 86400,
    
    // Algoritmo de encriptación
    'jwt_algorithm' => 'HS256',
    
    // Emisor del token
    'jwt_issuer' => 'futbase.es',
];
