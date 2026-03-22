# 📦 Guía de Instalación - Backend Seguro FutbaseWeb

Esta guía te ayudará a instalar y configurar el backend seguro en tu servidor.

---

## ⚡ Instalación Rápida

### Paso 1: Verificar Requisitos

```bash
# Verificar versión de PHP
php -v  # Debe ser >= 7.4

# Verificar extensiones PHP
php -m | grep -E 'pdo|mysql|openssl|curl|json'
```

**Requisitos mínimos:**
- PHP >= 7.4
- MySQL >= 5.7
- Extensiones PHP: PDO, PDO_MySQL, OpenSSL, cURL, JSON

---

### Paso 2: Subir Archivos

Sube la carpeta `backend_seguro_web/` a tu servidor web.

**Ejemplo de estructura:**
```
/var/www/html/
└── backend_seguro_web/
    ├── config/
    ├── core/
    ├── middleware/
    ├── endpoints/
    ├── cache/
    └── logs/
```

**URL de acceso:**
- Local: `http://localhost/backend_seguro_web/`
- Producción: `https://futbase.es/backend_seguro_web/`

---

### Paso 3: Configurar Permisos

```bash
# Navegar a la carpeta del backend
cd /var/www/html/backend_seguro_web/

# Dar permisos de escritura a caché y logs
chmod 755 cache/
chmod 755 cache/data/
chmod 755 cache/rate_limit/
chmod 755 logs/

# Proteger archivos de configuración
chmod 644 config/*.php

# Si usas SELinux (opcional)
chcon -R -t httpd_sys_rw_content_t cache/
chcon -R -t httpd_sys_rw_content_t logs/
```

---

### Paso 4: Configurar Base de Datos

#### 4.1 Editar `config/db_config.php`

```php
<?php
return [
    'host' => 'localhost',           // o IP del servidor MySQL
    'database' => 'futbase_db',      // nombre de tu base de datos
    'username' => 'futbase_user',    // usuario MySQL
    'password' => 'TU_PASSWORD_AQUI', // contraseña segura
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]
];
```

#### 4.2 Probar Conexión

Crea un archivo temporal `test_db.php` en la raíz:

```php
<?php
require_once 'core/Database.php';

try {
    $db = Database::getInstance();
    echo "✅ Conexión exitosa a la base de datos\n";
} catch (Exception $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
}
```

Ejecuta:
```bash
php test_db.php
```

Si funciona, elimina el archivo:
```bash
rm test_db.php
```

---

### Paso 5: Configurar Firebase

#### 5.1 Obtener Project ID

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Haz clic en ⚙️ **Project Settings**
4. Copia el **Project ID** (ej: `futbase-4e74a`)

#### 5.2 Editar `config/firebase_config.php`

```php
<?php
return [
    'project_id' => 'futbase-4e74a', // ⬅️ CAMBIA ESTO por tu Project ID
];
```

---

### Paso 6: Configurar CORS

Edita `config/cors.php` para permitir peticiones desde tus dominios:

```php
<?php
$allowedOrigins = [
    'http://localhost:3000',        // Flutter Web local
    'http://localhost:8080',        // Otro puerto local
    'https://futbase.es',           // Producción
    'https://www.futbase.es',       // www
    'https://app.futbase.es',       // App web
];
```

---

### Paso 7: Verificar Instalación

#### 7.1 Probar Endpoint Público (sin autenticación)

Crea un archivo temporal `test_endpoint.php`:

```php
<?php
header('Content-Type: application/json');

echo json_encode([
    'success' => true,
    'message' => '✅ Backend funcionando correctamente',
    'timestamp' => time()
]);
```

Accede desde el navegador:
```
https://futbase.es/backend_seguro_web/test_endpoint.php
```

Deberías ver:
```json
{
  "success": true,
  "message": "✅ Backend funcionando correctamente",
  "timestamp": 1706112345
}
```

#### 7.2 Probar con Token Firebase (desde tu app)

En tu app Flutter, haz una petición de prueba:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> testBackend() async {
  try {
    // 1. Obtener token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ No hay usuario autenticado');
      return;
    }

    final token = await user.getIdToken();
    print('🔑 Token obtenido');

    // 2. Hacer petición
    final response = await http.get(
      Uri.parse('https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📡 Status: ${response.statusCode}');
    print('📄 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print('✅ Backend funcionando correctamente');
        print('👥 Usuarios encontrados: ${data['data'].length}');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## 🔧 Configuración Avanzada

### Ajustar Rate Limiting

En cada endpoint, puedes ajustar los límites:

```php
// 50 peticiones por minuto
$userData = $auth->protect(50, 60);

// 200 peticiones en 5 minutos
$userData = $auth->protect(200, 300);
```

### Ajustar Tiempo de Caché

En cada endpoint:

```php
// Caché de 10 minutos (600 segundos)
$cache = new CacheManager(600);

// Caché personalizado por query
$data = $cache->remember($key, function() use ($db) {
    return $db->select("SELECT * FROM ...");
}, 1800); // 30 minutos
```

### Habilitar HTTPS (Producción)

Edita `.htaccess` y descomenta:

```apache
# Descomentar estas líneas
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

---

## 🐛 Solución de Problemas

### Error: "Permission denied"

```bash
# Dar permisos correctos
sudo chown -R www-data:www-data backend_seguro_web/
sudo chmod -R 755 backend_seguro_web/
sudo chmod -R 777 backend_seguro_web/cache/
sudo chmod -R 777 backend_seguro_web/logs/
```

### Error: "PDOException: Access denied"

Verifica credenciales de MySQL:

```bash
# Probar conexión manual
mysql -u futbase_user -p -h localhost futbase_db
```

Si falla, crear usuario:

```sql
CREATE USER 'futbase_user'@'localhost' IDENTIFIED BY 'password_seguro';
GRANT ALL PRIVILEGES ON futbase_db.* TO 'futbase_user'@'localhost';
FLUSH PRIVILEGES;
```

### Error: "Token inválido"

1. Verifica que el `project_id` en `config/firebase_config.php` sea correcto
2. Verifica que el token no haya expirado (24 horas)
3. Fuerza refresh del token en tu app:
   ```dart
   final token = await user.getIdToken(true); // force refresh
   ```

### Error: "CORS blocked"

1. Verifica que tu dominio esté en `config/cors.php`
2. Verifica que `.htaccess` tenga `mod_headers` habilitado
3. Verifica headers en la consola del navegador

---

## ✅ Checklist de Instalación

- [ ] PHP >= 7.4 instalado
- [ ] MySQL >= 5.7 instalado
- [ ] Extensiones PHP requeridas habilitadas
- [ ] Archivos subidos al servidor
- [ ] Permisos configurados (755 para carpetas, 644 para archivos)
- [ ] `config/db_config.php` configurado
- [ ] Conexión a BD probada y funcionando
- [ ] `config/firebase_config.php` configurado con Project ID correcto
- [ ] `config/cors.php` con dominios permitidos
- [ ] `.htaccess` configurado
- [ ] Endpoint de prueba funcionando
- [ ] Petición con token Firebase funcionando

---

## 📞 Soporte

Si tienes problemas con la instalación:

1. Revisa los logs: `logs/error.log`
2. Revisa los logs de Apache/Nginx
3. Revisa la documentación: [README.md](README.md)

---

**¡Instalación completada! 🎉**

Ahora puedes empezar a usar el backend seguro en tu aplicación.
