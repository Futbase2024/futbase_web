<?php
/**
 * Script para verificar qué versión de cuotas.php está en el servidor
 * Sube este archivo al servidor y accede desde el navegador
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== VERIFICACIÓN DE VERSIÓN DE CUOTAS.PHP ===\n";
echo "Fecha: " . date('Y-m-d H:i:s') . "\n\n";

$cuotasFile = __DIR__ . '/endpoints/cuotas.php';

// 1. Verificar que existe
echo "1. VERIFICAR EXISTENCIA:\n";
if (file_exists($cuotasFile)) {
    echo "   ✅ El archivo existe\n";
    echo "   Ruta: $cuotasFile\n";
} else {
    echo "   ❌ El archivo NO existe\n";
    echo "   Ruta buscada: $cuotasFile\n";
    exit;
}

// 2. Información del archivo
echo "\n2. INFORMACIÓN DEL ARCHIVO:\n";
$size = filesize($cuotasFile);
$modified = date('Y-m-d H:i:s', filemtime($cuotasFile));
echo "   Tamaño: " . number_format($size) . " bytes\n";
echo "   Última modificación: $modified\n";

// 3. Verificar el patrón usado
echo "\n3. VERIFICAR PATRÓN DEL CÓDIGO:\n";
$content = file_get_contents($cuotasFile);

// Buscar ResponseHelper::
$usesResponseHelper = strpos($content, 'ResponseHelper::success') !== false;
echo "   Usa ResponseHelper::success(): " . ($usesResponseHelper ? '✅ SÍ' : '❌ NO') . "\n";

// Buscar funciones locales
$usesLocalFunctions = strpos($content, 'function respondSuccess') !== false;
echo "   Tiene función respondSuccess() local: " . ($usesLocalFunctions ? '✅ SÍ' : '❌ NO') . "\n";

// Buscar CORS inline
$hasCorsInline = strpos($content, "header('Access-Control-Allow-Origin:") !== false;
echo "   Tiene CORS inline: " . ($hasCorsInline ? '✅ SÍ' : '❌ NO') . "\n";

// Buscar require de ResponseHelper
$requiresResponseHelper = strpos($content, "require_once __DIR__ . '/../core/ResponseHelper.php'") !== false;
echo "   Require ResponseHelper.php: " . ($requiresResponseHelper ? '✅ SÍ' : '❌ NO') . "\n";

// 4. Verificar operaciones incluidas
echo "\n4. OPERACIONES INCLUIDAS:\n";
$operations = [
    'getcuotabyid' => false,
    'getcuotasbyclub' => false,
    'getcuotabyplayertemp' => false,
    'getcuotawithoutid' => false,
    'createcuota' => false,
    'updatecuota' => false,
    'updatetypecuota' => false,
    'deletecuota' => false,
    'deletecuotabyid' => false,
];

foreach ($operations as $op => $found) {
    $pattern = "case '$op':";
    $operations[$op] = strpos($content, $pattern) !== false;
    echo "   - $op: " . ($operations[$op] ? '✅' : '❌') . "\n";
}

$totalOps = count(array_filter($operations));
echo "\n   Total operaciones: $totalOps/9\n";

// 5. Determinar versión
echo "\n5. VERSIÓN DETECTADA:\n";

if ($usesLocalFunctions && $hasCorsInline && $totalOps == 9) {
    echo "   ✅ VERSIÓN NUEVA (funcional completa)\n";
    echo "   - Tamaño esperado: ~12KB\n";
    echo "   - Patrón: Funciones locales + CORS inline\n";
    echo "   - Operaciones: 9/9 completas\n";
    echo "   - Estado: ✅ DEBERÍA FUNCIONAR CORRECTAMENTE\n";
} else if ($usesResponseHelper && $requiresResponseHelper) {
    echo "   ⚠️ VERSIÓN ANTIGUA (con problemas)\n";
    echo "   - Tamaño esperado: ~14KB\n";
    echo "   - Patrón: ResponseHelper::\n";
    echo "   - Problema: Esta versión devuelve HTML en operaciones POST\n";
    echo "   - Estado: ❌ NECESITA SER REEMPLAZADA\n";
} else {
    echo "   ❓ VERSIÓN DESCONOCIDA\n";
    echo "   - No coincide con ningún patrón conocido\n";
}

// 6. Recomendación
echo "\n6. RECOMENDACIÓN:\n";
if ($totalOps == 9 && $usesLocalFunctions && $hasCorsInline) {
    echo "   ✅ El archivo es correcto, no requiere cambios\n";
} else {
    echo "   ❌ ACCIÓN REQUERIDA:\n";
    echo "   1. Hacer backup del archivo actual\n";
    echo "   2. Subir la versión nueva desde tu máquina local\n";
    echo "   3. Verificar permisos (644)\n";
    echo "   4. Probar operaciones POST desde Flutter\n";
}

echo "\n=== FIN DE LA VERIFICACIÓN ===\n";
