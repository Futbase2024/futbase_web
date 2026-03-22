#!/bin/bash
# Script para arreglar permisos del backend seguro

echo "🔧 Arreglando permisos del Backend Seguro..."
echo ""

# Obtener la ruta del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "📁 Directorio: $SCRIPT_DIR"
echo ""

# Crear carpetas si no existen
echo "📂 Creando carpetas necesarias..."
mkdir -p cache/data
mkdir -p cache/rate_limit
mkdir -p logs

# Dar permisos de escritura
echo "🔐 Configurando permisos..."

# Opción 1: Permisos 777 (más permisivo, para desarrollo)
chmod -R 777 cache/
chmod -R 777 logs/

# Opción 2 (comentada): Permisos 755 con propietario www-data
# sudo chown -R www-data:www-data cache/
# sudo chown -R www-data:www-data logs/
# sudo chmod -R 755 cache/
# sudo chmod -R 755 logs/

# Verificar permisos
echo ""
echo "✅ Verificando permisos..."
echo "Cache data: $(ls -ld cache/data | awk '{print $1, $3, $4}')"
echo "Cache rate_limit: $(ls -ld cache/rate_limit | awk '{print $1, $3, $4}')"
echo "Logs: $(ls -ld logs | awk '{print $1, $3, $4}')"

echo ""
echo "🎉 ¡Permisos configurados!"
echo ""
echo "💡 Ahora recarga: https://futbase.es/backend_seguro_web/test.php"
