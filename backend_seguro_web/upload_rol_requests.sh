#!/bin/bash
# Script para subir rol_requests.php actualizado al servidor

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "================================================"
echo "📤 Subiendo rol_requests.php al servidor..."
echo "================================================"

# Archivo a subir
LOCAL_FILE="./endpoints/rol_requests.php"
REMOTE_PATH="/backend_seguro_web/endpoints/rol_requests.php"

# Verificar que el archivo existe
if [ ! -f "$LOCAL_FILE" ]; then
    echo -e "${RED}❌ Error: Archivo no encontrado: $LOCAL_FILE${NC}"
    exit 1
fi

echo ""
echo "📋 Información del archivo:"
echo "   - Archivo local: $LOCAL_FILE"
echo "   - Destino: futbase.es$REMOTE_PATH"
echo "   - Tamaño: $(ls -lh $LOCAL_FILE | awk '{print $5}')"
echo ""

# Opciones de subida:
echo "Selecciona el método de subida:"
echo "1) FTP (requiere credenciales FTP)"
echo "2) SCP/SFTP (requiere acceso SSH)"
echo "3) Mostrar el contenido para copiar manualmente"
echo ""
read -p "Opción [1-3]: " option

case $option in
    1)
        echo ""
        read -p "Usuario FTP: " ftp_user
        read -sp "Contraseña FTP: " ftp_pass
        echo ""

        curl -T "$LOCAL_FILE" \
             --user "$ftp_user:$ftp_pass" \
             "ftp://futbase.es$REMOTE_PATH"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Archivo subido correctamente${NC}"
        else
            echo -e "${RED}❌ Error al subir archivo${NC}"
        fi
        ;;
    2)
        echo ""
        read -p "Usuario SSH: " ssh_user

        scp "$LOCAL_FILE" "$ssh_user@futbase.es:$REMOTE_PATH"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Archivo subido correctamente${NC}"
        else
            echo -e "${RED}❌ Error al subir archivo${NC}"
        fi
        ;;
    3)
        echo ""
        echo "================================================"
        echo "📄 Contenido del archivo (primeras 50 líneas):"
        echo "================================================"
        head -50 "$LOCAL_FILE"
        echo ""
        echo "..."
        echo ""
        echo "Copia el contenido completo desde: $LOCAL_FILE"
        echo "Y pégalo en el servidor en: $REMOTE_PATH"
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo "================================================"
echo "🔍 Para verificar que funciona, ejecuta:"
echo "   curl 'https://futbase.es/backend_seguro_web/endpoints/rol_requests.php?action=getRolRequestsByState' \\"
echo "        -X POST -H 'Content-Type: application/json' \\"
echo "        -d '{\"stateName\":\"submitted\"}'"
echo "================================================"
