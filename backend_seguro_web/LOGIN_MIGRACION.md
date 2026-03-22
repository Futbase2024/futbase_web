# 🔐 Migración del Login al Backend Seguro

Pasos para migrar el sistema de login de tu app Flutter al backend seguro.

---

## ✅ Lo que acabamos de hacer

### Backend (PHP)
- ✅ Creado `endpoints/auth.php` con el endpoint `getAppUserByUid`
- ✅ El endpoint obtiene usuario + roles en una sola llamada
- ✅ Autenticación JWT automática
- ✅ Caché de 5 minutos

### Frontend (Flutter)
- ✅ Creado `lib/core/http/secure_http_client.dart` - Cliente HTTP con JWT
- ✅ Actualizado `auth_repository_impl.dart` - Método `getAppUserByUid` usa backend seguro
- ✅ Manejo automático de tokens Firebase

---

## 🚀 Cómo Probar

### 1. Verificar que el endpoint esté subido

Abre en el navegador:
```
https://futbase.es/backend_seguro_web/endpoints/auth.php
```

Deberías ver:
```json
{
  "success": false,
  "message": "Acción no válida",
  "code": 400
}
```

Esto es normal porque no pasaste el parámetro `action`. Significa que el archivo está bien subido.

---

### 2. Probar el Login en tu App

1. **Hot Reload** de tu app (o reinicia)
2. **Cierra sesión** si estás logueado
3. **Inicia sesión** de nuevo
4. **Mira la consola** (Debug Console)

#### ✅ Si todo funciona, verás:

```
🔐 [Auth] Obteniendo usuario con backend seguro...
🌐 [SecureHttp] GET: https://futbase.es/backend_seguro_web/endpoints/auth.php?action=getAppUserByUid
✅ [SecureHttp] Token obtenido (1234 chars)
📡 [SecureHttp] Status: 200
✅ [SecureHttp] Response OK
✅ [Auth] Usuario obtenido del backend seguro
✅ [Auth] Usuario construido correctamente
```

#### ❌ Si hay errores:

**Error 401:**
```
❌ [SecureHttp] Error 401: Token inválido o expirado
```
**Solución**: El token es válido solo después del login. Asegúrate de estar logueado con Firebase.

**Error de conexión:**
```
❌ [SecureHttp] Error: ...
```
**Solución**: Verifica que `auth.php` esté subido correctamente.

**Error "Usuario no encontrado":**
```
❌ [Auth] No se encontró el usuario
```
**Solución**: El usuario no existe en la base de datos. Verifica el UID en Firebase.

---

## 🔍 Debug Paso a Paso

### Ver el token Firebase

Añade esto temporalmente en tu código:

```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final token = await user.getIdToken();
  debugPrint('🔑 Token: ${token?.substring(0, 50)}...');
  debugPrint('🆔 UID: ${user.uid}');
}
```

### Probar el endpoint directamente

Desde tu navegador, abre la consola de desarrollo (F12) y ejecuta:

```javascript
// 1. Obtener token de Firebase (si tienes Firebase Web también)
const auth = firebase.auth();
const token = await auth.currentUser.getIdToken();
console.log('Token:', token);

// 2. Hacer petición
fetch('https://futbase.es/backend_seguro_web/endpoints/auth.php?action=getAppUserByUid', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('Response:', data));
```

---

## 📊 Comparación: Antes vs Ahora

### ❌ Antes (Backend Legacy)

```dart
// 2 queries SQL directas
var sentenciaSql = 'SELECT * FROM tusuarios where uid="$uid"';
await http.post(baseUrl, body: {"query": sentenciaSql});

var rolesSql = 'SELECT * FROM vroles WHERE uid="$uid"';
await http.post(baseUrl, body: {"query": rolesSql});
```

**Problemas:**
- ❌ Sin autenticación
- ❌ SQL injection possible
- ❌ 2 peticiones HTTP
- ❌ Sin caché
- ❌ Sin rate limiting

### ✅ Ahora (Backend Seguro)

```dart
// 1 sola llamada, todo automático
final response = await SecureHttpClient.get(
  'auth.php',
  params: {'action': 'getAppUserByUid'},
);
```

**Ventajas:**
- ✅ Autenticación JWT automática
- ✅ Prepared statements (anti SQL injection)
- ✅ 1 sola petición HTTP
- ✅ Caché de 5 minutos
- ✅ Rate limiting (100 req/min)
- ✅ Manejo de errores mejorado

---

## 🎯 Siguiente Paso

Una vez que el login funcione, puedes migrar otros métodos:

### Métodos pendientes de migrar:

```dart
// En auth_repository_impl.dart

❌ createAppUser()          → Crear usuario
❌ count()                  → Contar usuarios
❌ getAllUsers()            → Obtener todos los usuarios
❌ deleteAppUser()          → Eliminar usuario
❌ getAppUserByAccountRequest() → Obtener por solicitud
```

---

## 🐛 Solución de Problemas

### El login es muy lento

**Causa**: Primera petición obtiene el token y hace la query
**Solución**: El caché hace que las siguientes sean más rápidas

### Error "Rol no encontrado"

**Causa**: El usuario no tiene roles asignados en la BD
**Solución**: Verifica que exista un rol con `selectedrol = 1`:

```sql
SELECT * FROM vroles WHERE uid = 'tu-uid';
```

### Error de CORS

**Causa**: Dominio no permitido
**Solución**: Añade tu dominio en `config/cors.php`

---

## 📈 Métricas de Performance

Puedes medir la mejora de performance:

```dart
final stopwatch = Stopwatch()..start();

await authRepository.getAppUserByUid(uid);

stopwatch.stop();
debugPrint('⏱️ Tiempo: ${stopwatch.elapsedMilliseconds}ms');
```

**Esperado:**
- Primera vez: ~200-500ms
- Con caché: ~50-100ms

---

## ✅ Checklist

- [ ] Archivo `auth.php` subido al servidor
- [ ] Endpoint responde correctamente
- [ ] `SecureHttpClient` creado
- [ ] `auth_repository_impl.dart` actualizado
- [ ] Hot reload de la app
- [ ] Cerrar sesión
- [ ] Iniciar sesión de nuevo
- [ ] Ver logs en consola
- [ ] Login funciona correctamente ✨

---

¿Tienes problemas? Revisa los logs y compártelos para ayudarte.
