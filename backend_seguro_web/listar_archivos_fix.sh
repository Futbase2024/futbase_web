#!/bin/bash
# Script para listar los 13 archivos que necesitan subirse al servidor
# Fix: FirebaseAuthMiddleware llamadas estáticas

echo "📋 ARCHIVOS PHP QUE NECESITAN SUBIRSE AL SERVIDOR"
echo "=================================================="
echo ""
echo "Directorio local: backend_seguro_web/endpoints/"
echo "Directorio servidor: /srv/vhost/futbase.es/home/html/backend_seguro_web/endpoints/"
echo ""
echo "Archivos modificados (13 total):"
echo ""

ARCHIVOS=(
    "ropa.php"
    "camisetas.php"
    "ingresos.php"
    "cuotas_club.php"
    "pagos_personal.php"
    "mensajeria.php"
    "talla_peso.php"
    "publicidad.php"
    "gastos.php"
    "prendas.php"
    "app_config.php"
    "documentos.php"
    "preferences.php"
)

CONTADOR=1
for archivo in "${ARCHIVOS[@]}"; do
    filepath="endpoints/$archivo"
    if [ -f "$filepath" ]; then
        # Verificar que tiene el fix
        if grep -q "auth = new FirebaseAuthMiddleware" "$filepath"; then
            echo "✅ $CONTADOR. $archivo (fix verificado)"
        else
            echo "⚠️  $CONTADOR. $archivo (fix NO encontrado - revisar)"
        fi
    else
        echo "❌ $CONTADOR. $archivo (archivo NO existe)"
    fi
    CONTADOR=$((CONTADOR + 1))
done

echo ""
echo "=================================================="
echo ""
echo "COMANDO PARA SUBIR (copiar y pegar):"
echo ""
echo "scp backend_seguro_web/endpoints/{ropa,camisetas,ingresos,cuotas_club,pagos_personal,mensajeria,talla_peso,publicidad,gastos,prendas,app_config,documentos,preferences}.php usuario@futbase.es:/srv/vhost/futbase.es/home/html/backend_seguro_web/endpoints/"
echo ""
echo "O con rsync (recomendado):"
echo ""
echo "rsync -av --progress backend_seguro_web/endpoints/ usuario@futbase.es:/srv/vhost/futbase.es/home/html/backend_seguro_web/endpoints/"
echo ""
