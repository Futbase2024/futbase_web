#!/usr/bin/env python3
"""
Script para corregir llamadas estáticas incorrectas a FirebaseAuthMiddleware
Cambia: $userData = FirebaseAuthMiddleware::authenticate();
Por: $auth = new FirebaseAuthMiddleware(); y $userData = $auth->authenticate();
"""

import os
import re

# Archivos a corregir (basados en grep anterior)
FILES_TO_FIX = [
    'ropa.php',
    'camisetas.php',
    'preferences.php',
    'ingresos.php',
    'cuotas_club.php',
    'pagos_personal.php',
    'mensajeria.php',
    'talla_peso.php',
    'publicidad.php',
    'gastos.php',
    'prendas.php',
    'app_config.php',
    'documentos.php',
]

ENDPOINTS_DIR = os.path.join(os.path.dirname(__file__), 'endpoints')

def fix_file(filepath):
    """Corrige un archivo PHP"""
    print(f"\n📝 Procesando: {os.path.basename(filepath)}")

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Patrón 1: Buscar si ya tiene la instancia $auth
    has_auth_instance = re.search(r'\$auth\s*=\s*new\s+FirebaseAuthMiddleware\s*\(\s*\);', content)

    if not has_auth_instance:
        # Buscar dónde se inicializan $db y $cache
        init_match = re.search(
            r'(\$db\s*=\s*Database::getInstance\(\);.*?\$cache\s*=\s*new\s+CacheManager.*?;)',
            content,
            re.DOTALL
        )

        if init_match:
            # Agregar $auth después de $cache
            old_init = init_match.group(1)
            new_init = old_init + '\n$auth = new FirebaseAuthMiddleware();'
            content = content.replace(old_init, new_init, 1)
            print("   ✅ Agregada instancia $auth")
        else:
            print("   ⚠️  No se encontró el patrón de inicialización")
            return False
    else:
        print("   ℹ️  Ya tiene instancia $auth")

    # Patrón 2: Reemplazar FirebaseAuthMiddleware::authenticate() por $auth->authenticate()
    static_calls = re.findall(r'FirebaseAuthMiddleware::authenticate\(\)', content)

    if static_calls:
        content = re.sub(
            r'FirebaseAuthMiddleware::authenticate\(\)',
            r'$auth->authenticate()',
            content
        )
        print(f"   ✅ Corregidas {len(static_calls)} llamadas estáticas")
    else:
        print("   ℹ️  No hay llamadas estáticas para corregir")

    # Solo escribir si hubo cambios
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"   💾 Archivo actualizado")
        return True
    else:
        print(f"   ⏭️  Sin cambios necesarios")
        return False

def main():
    print("🔧 FIX: Corrigiendo llamadas estáticas a FirebaseAuthMiddleware")
    print("=" * 70)

    fixed_count = 0

    for filename in FILES_TO_FIX:
        filepath = os.path.join(ENDPOINTS_DIR, filename)

        if not os.path.exists(filepath):
            print(f"\n⚠️  Archivo no encontrado: {filename}")
            continue

        if fix_file(filepath):
            fixed_count += 1

    print("\n" + "=" * 70)
    print(f"✅ Proceso completado: {fixed_count}/{len(FILES_TO_FIX)} archivos modificados")

if __name__ == '__main__':
    main()
