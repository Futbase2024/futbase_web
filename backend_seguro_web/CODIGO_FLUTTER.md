# 📱 Código Flutter para Probar el Backend

Ahora que el backend funciona desde el navegador, vamos a probarlo desde tu app Flutter.

---

## 🚀 Opción 1: Código Rápido de Prueba

Copia este código en cualquier lugar de tu app (ej: en un botón):

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> testBackendSeguro() async {
  const baseUrl = 'https://futbase.es/backend_seguro_web';

  debugPrint('🧪 Iniciando tests del backend seguro...');
  debugPrint('─' * 60);

  // ==================== TEST 1: Backend Básico ====================
  debugPrint('\n📡 TEST 1: Verificando backend...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/test.php'),
    );

    debugPrint('Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        debugPrint('✅ Backend funcionando correctamente');
        debugPrint('   PHP: ${data['tests']['php_version']['version']}');
        debugPrint('   BD: ${data['tests']['database']['message']}');
        debugPrint('   Firebase: ${data['tests']['firebase']['project_id']}');
      } else {
        debugPrint('❌ Algunos tests fallaron: ${data['message']}');
        return;
      }
    } else {
      debugPrint('❌ Error: Status ${response.statusCode}');
      return;
    }
  } catch (e) {
    debugPrint('❌ Error al conectar: $e');
    return;
  }

  // ==================== TEST 2: Obtener Token ====================
  debugPrint('\n🔑 TEST 2: Obteniendo token Firebase...');

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('❌ No hay usuario autenticado en Firebase');
    debugPrint('💡 Debes hacer login primero');
    return;
  }

  debugPrint('👤 Usuario: ${user.email}');

  String? token;
  try {
    token = await user.getIdToken();
    if (token != null) {
      debugPrint('✅ Token obtenido (${token.length} chars)');
    } else {
      debugPrint('❌ No se pudo obtener el token');
      return;
    }
  } catch (e) {
    debugPrint('❌ Error al obtener token: $e');
    return;
  }

  // ==================== TEST 3: Endpoint Usuarios ====================
  debugPrint('\n👥 TEST 3: Probando endpoint de usuarios...');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final usuarios = data['data'] as List;
        debugPrint('✅ Endpoint funcionando correctamente');
        debugPrint('✅ Usuarios encontrados: ${usuarios.length}');

        if (usuarios.isNotEmpty) {
          debugPrint('\n📋 Primeros 3 usuarios:');
          for (var i = 0; i < usuarios.length && i < 3; i++) {
            final u = usuarios[i];
            debugPrint('   ${i + 1}. ${u['nombre']} ${u['apellidos']} (${u['email']})');
          }
        }
      } else {
        debugPrint('❌ Error: ${data['message']}');
      }
    } else if (response.statusCode == 401) {
      debugPrint('❌ Error 401: Token inválido o expirado');
      debugPrint('💡 Intenta refrescar: await user.getIdToken(true)');
    } else if (response.statusCode == 429) {
      debugPrint('❌ Error 429: Demasiadas peticiones (rate limit)');
    } else {
      debugPrint('❌ Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }

  debugPrint('\n' + '─' * 60);
  debugPrint('✅ Tests completados\n');
}
```

---

## 🎯 Opción 2: Widget Completo con Botón

Si quieres un widget completo para añadir en tu app:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestBackendButton extends StatefulWidget {
  const TestBackendButton({super.key});

  @override
  State<TestBackendButton> createState() => _TestBackendButtonState();
}

class _TestBackendButtonState extends State<TestBackendButton> {
  bool _isLoading = false;
  String _result = '';

  Future<void> _testBackend() async {
    setState(() {
      _isLoading = true;
      _result = 'Probando backend...\n';
    });

    const baseUrl = 'https://futbase.es/backend_seguro_web';

    try {
      // Test básico
      final response1 = await http.get(Uri.parse('$baseUrl/test.php'));

      if (response1.statusCode == 200) {
        final data = jsonDecode(response1.body);
        if (data['success']) {
          setState(() {
            _result += '✅ Backend OK\n';
          });

          // Test con autenticación
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();

            final response2 = await http.get(
              Uri.parse('$baseUrl/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );

            if (response2.statusCode == 200) {
              final data2 = jsonDecode(response2.body);
              if (data2['success']) {
                final usuarios = data2['data'] as List;
                setState(() {
                  _result += '✅ Autenticación OK\n';
                  _result += '✅ ${usuarios.length} usuarios encontrados\n';
                });
              }
            } else {
              setState(() {
                _result += '❌ Error ${response2.statusCode}\n';
              });
            }
          } else {
            setState(() {
              _result += '❌ No hay usuario autenticado\n';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _result += '❌ Error: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _testBackend,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.bug_report),
          label: const Text('🧪 Probar Backend Seguro'),
        ),
        if (_result.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _result,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

**Uso:**
```dart
// En cualquier pantalla
TestBackendButton(),
```

---

## 📍 Dónde Poner el Código

### Opción A: En tu pantalla de settings/debug

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: ListView(
        children: [
          // ... otros settings ...

          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Probar Backend'),
            onTap: () async {
              await testBackendSeguro();
            },
          ),
        ],
      ),
    );
  }
}
```

### Opción B: En tu pantalla principal (temporal)

```dart
FloatingActionButton(
  onPressed: () async {
    await testBackendSeguro();
  },
  child: Icon(Icons.bug_report),
)
```

---

## 🔍 ¿Qué Verás en la Consola?

Si todo funciona correctamente:

```
🧪 Iniciando tests del backend seguro...
────────────────────────────────────────────────────────────

📡 TEST 1: Verificando backend...
Status: 200
✅ Backend funcionando correctamente
   PHP: 8.2.29
   BD: Conexión a BD exitosa
   Firebase: futbase-17919

🔑 TEST 2: Obteniendo token Firebase...
👤 Usuario: tu@email.com
✅ Token obtenido (1234 chars)

👥 TEST 3: Probando endpoint de usuarios...
Status: 200
✅ Endpoint funcionando correctamente
✅ Usuarios encontrados: 15

📋 Primeros 3 usuarios:
   1. Juan Pérez (juan@example.com)
   2. María García (maria@example.com)
   3. Carlos López (carlos@example.com)

────────────────────────────────────────────────────────────
✅ Tests completados
```

---

## ❌ Posibles Errores

### Error 401: Token inválido
```dart
// Forzar refresh del token
final token = await user.getIdToken(true); // ← true para forzar refresh
```

### Error CORS
Verifica que tu dominio esté en `backend_seguro_web/config/cors.php`

### Error de conexión
Verifica la URL: `https://futbase.es/backend_seguro_web`

---

## 🎯 Siguiente Paso

Una vez que veas que todo funciona, puedes empezar a usar el backend en tu app:

```dart
// Ejemplo: Obtener usuarios
Future<List<User>> getUsuarios(int idTemporada) async {
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();

  final response = await http.get(
    Uri.parse('https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=$idTemporada'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    }
  }

  return [];
}
```

---

¿Quieres que te ayude a crear alguna integración específica con tu app?
