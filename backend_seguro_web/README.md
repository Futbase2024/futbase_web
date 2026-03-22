# 🔐 Backend Seguro - FutbaseWeb

Backend seguro con autenticación Firebase JWT para la aplicación web de FutBase.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Uso](#uso)
- [Endpoints](#endpoints)
- [Seguridad](#seguridad)
- [Testing](#testing)

---

## ✨ Características

- ✅ **Autenticación Firebase**: Validación de tokens JWT de Firebase
- ✅ **Prepared Statements**: Protección contra SQL injection
- ✅ **Rate Limiting**: Protección contra ataques de fuerza bruta
- ✅ **Sistema de Caché**: Reduce carga en base de datos
- ✅ **CORS Configurado**: Permite peticiones desde dominios autorizados
- ✅ **Validación de Datos**: Sanitización automática de inputs
- ✅ **Logs de Seguridad**: Registro de intentos fallidos y errores
- ✅ **Respuestas Estandarizadas**: Formato JSON consistente

---

## 📁 Estructura del Proyecto

```
backend_seguro_web/
├── config/
│   ├── db_config.php          # Configuración de base de datos
│   ├── firebase_config.php    # Configuración de Firebase
│   └── cors.php                # Configuración de CORS
├── core/
│   ├── Database.php            # Wrapper PDO con prepared statements
│   ├── FirebaseAuth.php        # Validador de tokens Firebase
│   ├── RateLimiter.php         # Limitador de peticiones
│   ├── CacheManager.php        # Sistema de caché en archivos
│   ├── Validator.php           # Validador de datos
│   └── ResponseHelper.php      # Funciones helper para respuestas JSON
├── middleware/
│   └── FirebaseAuthMiddleware.php  # Middleware de autenticación
├── endpoints/
│   └── usuarios.php            # Endpoint de usuarios (ejemplo)
├── cache/
│   ├── data/                   # Caché de datos
│   └── rate_limit/             # Caché de rate limiting
├── logs/
│   └── error.log               # Logs de errores
├── .htaccess                   # Configuración Apache
└── README.md                   # Este archivo
```

---

## 🚀 Instalación

### 1. Subir archivos al servidor

Sube toda la carpeta `backend_seguro_web/` a tu servidor (ej: `https://futbase.es/backend_seguro_web/`)

### 2. Configurar permisos

```bash
# Dar permisos de escritura a carpetas de caché y logs
chmod 755 backend_seguro_web/cache/
chmod 755 backend_seguro_web/cache/data/
chmod 755 backend_seguro_web/cache/rate_limit/
chmod 755 backend_seguro_web/logs/

# Proteger archivos de configuración
chmod 644 backend_seguro_web/config/*.php
```

### 3. Verificar requisitos

- **PHP**: >= 7.4
- **MySQL**: >= 5.7
- **Extensiones PHP requeridas**:
  - PDO
  - PDO_MySQL
  - OpenSSL
  - cURL
  - JSON

---

## ⚙️ Configuración

### 1. Configurar Base de Datos

Edita `config/db_config.php`:

```php
return [
    'host' => 'localhost',
    'database' => 'futbase_db',
    'username' => 'tu_usuario',
    'password' => 'tu_password_seguro',
    'charset' => 'utf8mb4',
];
```

### 2. Configurar Firebase

Edita `config/firebase_config.php`:

```php
return [
    'project_id' => 'futbase-4e74a', // Tu Project ID de Firebase
];
```

**¿Dónde encontrar el Project ID?**
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Project Settings** (⚙️)
4. Copia el **Project ID**

### 3. Configurar CORS

Edita `config/cors.php` para permitir tus dominios:

```php
$allowedOrigins = [
    'http://localhost:3000',    // Desarrollo local
    'https://futbase.es',       // Producción
    'https://www.futbase.es',
];
```

---

## 💻 Uso

### Realizar una Petición Autenticada

#### Desde Flutter (Dart):

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> getUsuarios() async {
  // 1. Obtener token JWT de Firebase
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();

  // 2. Hacer petición al backend seguro
  final response = await http.get(
    Uri.parse('https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('✅ Usuarios: ${data['data']}');
  } else {
    print('❌ Error: ${response.body}');
  }
}
```

#### Desde JavaScript:

```javascript
import { getAuth } from 'firebase/auth';

async function getUsuarios() {
  // 1. Obtener token JWT de Firebase
  const auth = getAuth();
  const token = await auth.currentUser?.getIdToken();

  // 2. Hacer petición al backend seguro
  const response = await fetch(
    'https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=1',
    {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
    }
  );

  const data = await response.json();

  if (data.success) {
    console.log('✅ Usuarios:', data.data);
  } else {
    console.error('❌ Error:', data.message);
  }
}
```

---

## 📡 Endpoints

### Usuarios

#### `GET /endpoints/usuarios.php?action=getAllUsers&idtemporada=X`

Obtiene todos los usuarios de una temporada.

**Headers:**
```
Authorization: Bearer <firebase-jwt-token>
Content-Type: application/json
```

**Respuesta:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "uid": "firebase-uid-123",
      "email": "user@example.com",
      "nombre": "Juan",
      "apellidos": "Pérez"
    }
  ]
}
```

#### `GET /endpoints/usuarios.php?action=getAppUserById&id=X`

Obtiene un usuario por ID.

#### `GET /endpoints/usuarios.php?action=getAppUserByUid&uid=X`

Obtiene un usuario por UID de Firebase.

#### `POST /endpoints/usuarios.php?action=createAppUser`

Crea un nuevo usuario.

**Body:**
```json
{
  "email": "nuevo@example.com",
  "nombre": "Nuevo",
  "apellidos": "Usuario",
  "user": "nuevousuario",
  "password": "password123",
  "idtemporada": 1,
  "idclub": 1
}
```

#### `POST /endpoints/usuarios.php?action=updateAppUser`

Actualiza un usuario existente.

#### `DELETE /endpoints/usuarios.php?action=deleteAppUser&id=X`

Elimina un usuario.

---

## 🔒 Seguridad

### Rate Limiting

Por defecto:
- **Endpoints protegidos**: 100 peticiones por minuto
- **Endpoints públicos**: 20 peticiones por minuto

Se puede ajustar en cada endpoint:

```php
$userData = $auth->protect(50, 60); // 50 req/min
```

### Prepared Statements

Todas las queries usan prepared statements automáticamente:

```php
// ✅ SEGURO
$db->select("SELECT * FROM users WHERE id = ?", [$id]);

// ❌ NUNCA HACER ESTO
$db->select("SELECT * FROM users WHERE id = $id");
```

### Validación de Datos

Siempre validar inputs:

```php
$id = Validator::validateInt($_GET['id'] ?? null);
$email = Validator::validateEmail($_POST['email'] ?? '');
$uid = Validator::validateUID($_GET['uid'] ?? '');
```

### Logs de Seguridad

Los intentos fallidos se registran automáticamente:

```
[2025-01-24 10:30:45] FirebaseAuth: Token expired
[2025-01-24 10:31:12] RateLimiter: Limit exceeded for IP: 192.168.1.100
```

---

## 🧪 Testing

### Probar con cURL

```bash
# 1. Obtener token de Firebase (desde tu app)
TOKEN="tu-firebase-jwt-token"

# 2. Probar endpoint
curl -X GET "https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### Probar con Postman

1. **Método**: GET/POST
2. **URL**: `https://futbase.es/backend_seguro_web/endpoints/usuarios.php`
3. **Headers**:
   - `Authorization`: `Bearer <tu-token-firebase>`
   - `Content-Type`: `application/json`
4. **Params**:
   - `action`: `getAllUsers`
   - `idtemporada`: `1`

---

## 📊 Formato de Respuestas

### Respuesta Exitosa

```json
{
  "success": true,
  "data": { /* datos */ },
  "message": "Operación exitosa"
}
```

### Respuesta de Error

```json
{
  "success": false,
  "message": "Descripción del error",
  "code": 400
}
```

### Códigos de Estado HTTP

- **200**: Éxito
- **400**: Error de validación
- **401**: No autenticado (token inválido/expirado)
- **403**: Sin permisos
- **404**: Recurso no encontrado
- **429**: Demasiadas peticiones (rate limit)
- **500**: Error interno del servidor

---

## 🆘 Solución de Problemas

### Error: "Token inválido o expirado"

**Causa**: El token JWT de Firebase ha expirado (24 horas) o es inválido.

**Solución**:
```dart
// Forzar refresh del token
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

### Error: "Error de conexión a la base de datos"

**Causa**: Credenciales incorrectas o servidor MySQL inaccesible.

**Solución**:
1. Verificar `config/db_config.php`
2. Comprobar que MySQL está corriendo
3. Verificar permisos del usuario MySQL

### Error: "Too Many Requests (429)"

**Causa**: Se ha excedido el rate limit.

**Solución**:
- Esperar 1 minuto
- Reducir frecuencia de peticiones
- Implementar exponential backoff en el cliente

### Error: "CORS blocked"

**Causa**: Tu dominio no está en la lista de permitidos.

**Solución**:
Añadir tu dominio en `config/cors.php`:
```php
$allowedOrigins = [
    'https://tu-dominio.com',
];
```

---

## 📚 Recursos Adicionales

- [Documentación Firebase Auth](https://firebase.google.com/docs/auth)
- [PHP PDO Documentation](https://www.php.net/manual/en/book.pdo.php)
- [Guía de Seguridad PHP](https://www.php.net/manual/en/security.php)

---

## 🎯 Próximos Pasos

1. **Migrar más endpoints**: Crear endpoints para partidos, entrenamientos, etc.
2. **Implementar permisos**: Sistema de roles y permisos granulares
3. **Añadir tests**: Tests automatizados con PHPUnit
4. **Monitoreo**: Integrar con herramientas de monitoreo (Sentry, etc.)

---

## 📝 Changelog

### v1.0.0 (2025-01-24)
- ✅ Estructura base del backend seguro
- ✅ Autenticación con Firebase JWT
- ✅ Rate limiting
- ✅ Sistema de caché
- ✅ Endpoint de usuarios completo
- ✅ Documentación completa

---

**Última actualización**: 2025-01-24
**Autor**: FutBase Team
