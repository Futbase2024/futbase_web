<?php
/**
 * Verifica la versión del endpoint equipos.php
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== VERIFICACIÓN EQUIPOS.PHP ===\n\n";

$file = __DIR__ . '/endpoints/equipos.php';

if (!file_exists($file)) {
    echo "❌ Archivo no encontrado\n";
    exit;
}

echo "Archivo: $file\n";
echo "Última modificación: " . date('Y-m-d H:i:s', filemtime($file)) . "\n";
echo "Tamaño: " . filesize($file) . " bytes\n\n";

$content = file_get_contents($file);

// Buscar la función updateTeam
$lines = explode("\n", $content);
$inUpdateTeam = false;
$updateTeamLines = [];
$lineNum = 0;

foreach ($lines as $line) {
    $lineNum++;
    if (strpos($line, 'function updateTeam') !== false) {
        $inUpdateTeam = true;
    }

    if ($inUpdateTeam) {
        $updateTeamLines[] = sprintf("%4d: %s", $lineNum, $line);

        // Terminar cuando encontramos el fin de la función
        if (strpos($line, 'respondSuccess') !== false && count($updateTeamLines) > 20) {
            break;
        }
    }
}

echo "=== Función updateTeam (últimas líneas) ===\n";
$lastLines = array_slice($updateTeamLines, -15);
echo implode("\n", $lastLines);

echo "\n\n=== Verificaciones ===\n";

if (strpos($content, '$cache->clear("equipos_*")') !== false) {
    echo "✅ Tiene: \$cache->clear(\"equipos_*\")\n";
} else {
    echo "❌ NO tiene: \$cache->clear(\"equipos_*\")\n";
}

if (strpos($content, '$cache->clear("equipo_*")') !== false) {
    echo "✅ Tiene: \$cache->clear(\"equipo_*\")\n";
} else {
    echo "❌ NO tiene: \$cache->clear(\"equipo_*\")\n";
}

// Buscar si tiene el código viejo (con múltiples delete)
if (strpos($content, '$cache->delete("equipos_club_') !== false) {
    echo "⚠️  ADVERTENCIA: Tiene código antiguo con \$cache->delete() específicos\n";
}

echo "\n=== FIN VERIFICACIÓN ===\n";
