# 🧪 Guía de Pruebas - Backend Seguro FutbaseWeb

Esta guía te ayudará a probar que el backend esté funcionando correctamente.

---

## 📋 Checklist de Pruebas

- [ ] Test 1: Backend básico (sin autenticación)
- [ ] Test 2: Conexión a base de datos
- [ ] Test 3: Token Firebase (obtención)
- [ ] Test 4: Endpoint con autenticación
- [ ] Test 5: Rate limiting
- [ ] Test 6: Caché funcionando

---

## 🌐 Test 1: Backend Básico (Desde Navegador)

### ¿Dónde está subido tu backend?

Si lo subiste a: `https://futbase.es/backend_seguro_web/`

### Paso 1.1: Abrir en navegador

Abre tu navegador y ve a:

```
https://futbase.es/backend_seguro_web/test.php
```

### ¿Qué deberías ver?

Un JSON con información del servidor:

```json
{
  "success": true,
  "message": "✅ Todos los tests pasaron correctamente",
  "timestamp": "2025-01-24 10:30:45",
  "tests": {
    "php_version": {
      "status": "ok",
      "version": "8.1.0",
      "message": "PHP está funcionando correctamente"
    },
    "extensions": {
      "status": "ok",
      "message": "Todas las extensiones están instaladas"
    },
    "permissions": {
      "status": "ok",
      "cache_writable": true,
      "logs_writable": true,
      "message": "Permisos correctos"
    },
    "database": {
      "status": "ok",
      "message": "Conexión a BD exitosa"
    },
    "firebase": {
      "status": "ok",
      "project_id": "futbase-4e74a",
      "message": "Firebase configurado"
    }
  }
}
```

### ✅ Si todo está OK

Verás `"success": true` y todos los tests con `"status": "ok"`

### ❌ Si algo falla

#### Error de conexión a BD:
```json
{
  "database": {
    "status": "error",
    "message": "Error: Access denied for user..."
  }
}
```
**Solución**: Verifica las credenciales en `config/db_config.php`

#### Error de permisos:
```json
{
  "permissions": {
    "status": "error",
    "cache_writable": false
  }
}
```
**Solución**:
```bash
chmod 755 cache/ logs/
```

---

## 📱 Test 2: Desde Flutter/Dart

### Opción A: Copiar el código en tu app

1. Copia todo el archivo `test_flutter.dart`
2. Pégalo en tu proyecto Flutter (ej: `lib/tests/backend_tester.dart`)
3. Cambia la URL:
   ```dart
   static const String baseUrl = 'https://futbase.es/backend_seguro_web';
   ```

### Opción B: Crear un botón de prueba

En cualquier pantalla de tu app:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// En tu Widget
ElevatedButton(
  onPressed: () async {
    await _probarBackend();
  },
  child: const Text('🧪 Probar Backend'),
)

// Función de prueba
Future<void> _probarBackend() async {
  const baseUrl = 'https://futbase.es/backend_seguro_web';

  debugPrint('🧪 Probando backend...');

  // 1. Test básico (sin autenticación)
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/test.php'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('✅ Backend: ${data['message']}');
    } else {
      debugPrint('❌ Error: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }

  // 2. Test con autenticación
  try {
    // Obtener token Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ No hay usuario autenticado');
      return;
    }

    final token = await user.getIdToken();
    debugPrint('✅ Token obtenido');

    // Hacer petición autenticada
    final response = await http.get(
      Uri.parse('$baseUrl/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('📡 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final usuarios = data['data'] as List;
        debugPrint('✅ Usuarios: ${usuarios.length}');
      }
    } else if (response.statusCode == 401) {
      debugPrint('❌ Token inválido o expirado');
    } else {
      debugPrint('❌ Error: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
```

### Ejecutar tests

```dart
// Opción 1: Todos los tests
await BackendTester.runAllTests();

// Opción 2: Tests individuales
await BackendTester.testBackendBasic();
await BackendTester.testGetToken();
await BackendTester.testUsuariosEndpoint();
```

---

## 🔍 Test 3: Con cURL (Línea de Comandos)

### Test básico
```bash
curl https://futbase.es/backend_seguro_web/test.php
```

### Test con autenticación

Primero, obtén tu token desde la app:
```dart
final token = await FirebaseAuth.instance.currentUser?.getIdToken();
print('Token: $token');
```

Luego usa el token en cURL:
```bash
curl -X GET "https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=1" \
  -H "Authorization: Bearer TU_TOKEN_AQUI" \
  -H "Content-Type: application/json"
```

---

## 📊 Interpretar Resultados

### ✅ Respuesta exitosa
```json
{
  "success": true,
  "data": [ /* datos */ ],
  "message": "Operación exitosa"
}
```

### ❌ Errores comunes

#### 401 Unauthorized
```json
{
  "success": false,
  "message": "Token inválido o expirado",
  "code": 401
}
```
**Causa**: Token JWT expirado o inválido
**Solución**: Refrescar token
```dart
final token = await user.getIdToken(true); // force refresh
```

#### 403 Forbidden
```json
{
  "success": false,
  "message": "No tienes permisos suficientes",
  "code": 403
}
```
**Causa**: Usuario sin permisos
**Solución**: Verificar permisos del usuario en BD

#### 404 Not Found
```json
{
  "success": false,
  "message": "Recurso no encontrado",
  "code": 404
}
```
**Causa**: ID no existe en BD
**Solución**: Verificar que el ID existe

#### 429 Too Many Requests
```json
{
  "success": false,
  "message": "Demasiadas peticiones",
  "code": 429
}
```
**Causa**: Rate limit excedido (100 req/min)
**Solución**: Esperar 1 minuto

#### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error interno del servidor",
  "code": 500
}
```
**Causa**: Error en el servidor
**Solución**: Revisar logs en `logs/error.log`

---

## 🐛 Debugging

### Ver logs del servidor

```bash
# Ver últimas 50 líneas del log
tail -n 50 /ruta/a/backend_seguro_web/logs/error.log

# Seguir logs en tiempo real
tail -f /ruta/a/backend_seguro_web/logs/error.log
```

### Logs de PHP

En tu servidor, verifica:
```bash
# Logs de Apache
tail -f /var/log/apache2/error.log

# Logs de PHP
tail -f /var/log/php/error.log
```

### Activar logs detallados

Edita `config/db_config.php` y añade:
```php
// Al final del archivo
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../logs/error.log');
```

---

## 📈 Test de Performance

### Probar caché

```dart
// Primera petición (sin caché)
final stopwatch1 = Stopwatch()..start();
await http.get(Uri.parse('$url?action=getAllUsers&idtemporada=1'));
stopwatch1.stop();
print('Sin caché: ${stopwatch1.elapsedMilliseconds}ms');

// Segunda petición (con caché)
final stopwatch2 = Stopwatch()..start();
await http.get(Uri.parse('$url?action=getAllUsers&idtemporada=1'));
stopwatch2.stop();
print('Con caché: ${stopwatch2.elapsedMilliseconds}ms');

// La segunda debería ser mucho más rápida
```

### Probar rate limiting

```dart
// Hacer 120 peticiones en 1 minuto
for (var i = 0; i < 120; i++) {
  final response = await http.get(/* ... */);

  if (response.statusCode == 429) {
    print('Rate limit alcanzado en petición $i');
    break;
  }
}
```

---

## ✅ Checklist Final

Una vez que todos los tests pasen:

- [x] Backend responde correctamente
- [x] Conexión a BD funciona
- [x] Token Firebase se obtiene correctamente
- [x] Autenticación funciona
- [x] Endpoints responden con datos correctos
- [x] Rate limiting funciona
- [x] Caché funciona
- [x] Logs se generan correctamente

---

## 🎯 Próximos Pasos

Una vez que todo funcione:

1. **Eliminar archivo de prueba**:
   ```bash
   rm backend_seguro_web/test.php
   ```

2. **Integrar en tu app**:
   - Reemplazar URLs del backend legacy
   - Añadir interceptores para tokens
   - Implementar refresh automático de tokens

3. **Monitorear**:
   - Revisar logs diariamente
   - Verificar performance
   - Ajustar rate limits si es necesario

---

**¿Tienes problemas?** Revisa [README.md](README.md) o [INSTALL.md](INSTALL.md)
