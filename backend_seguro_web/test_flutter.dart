import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Script de prueba para el backend seguro
/// Copia este código en tu app Flutter para probar
class BackendTester {
  // ⚠️ CAMBIA ESTA URL POR LA TUYA
  static const String baseUrl = 'https://futbase.es/backend_seguro_web';

  /// Test 1: Verificar que el backend está funcionando (sin autenticación)
  static Future<void> testBackendBasic() async {
    debugPrint('🧪 TEST 1: Backend básico');
    debugPrint('─' * 50);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test.php'),
      );

      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Backend funcionando correctamente');
          debugPrint('✅ PHP Version: ${data['tests']['php_version']['version']}');
          debugPrint('✅ Database: ${data['tests']['database']['message']}');
          debugPrint('✅ Firebase: ${data['tests']['firebase']['project_id']}');
        } else {
          debugPrint('❌ Algunos tests fallaron');
          debugPrint('❌ Detalles: ${response.body}');
        }
      } else {
        debugPrint('❌ Error: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
    }

    debugPrint('');
  }

  /// Test 2: Obtener y mostrar token Firebase
  static Future<String?> testGetToken() async {
    debugPrint('🧪 TEST 2: Obtener Token Firebase');
    debugPrint('─' * 50);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('❌ No hay usuario autenticado en Firebase');
        debugPrint('💡 Debes hacer login primero');
        return null;
      }

      debugPrint('👤 Usuario: ${user.email}');
      debugPrint('🆔 UID: ${user.uid}');

      // Obtener token
      final token = await user.getIdToken();

      if (token != null) {
        debugPrint('✅ Token obtenido exitosamente');
        debugPrint('🔑 Token (primeros 50 chars): ${token.substring(0, 50)}...');
        debugPrint('📏 Longitud del token: ${token.length} caracteres');
        return token;
      } else {
        debugPrint('❌ No se pudo obtener el token');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al obtener token: $e');
      return null;
    }
  }

  /// Test 3: Probar endpoint de usuarios (con autenticación)
  static Future<void> testUsuariosEndpoint() async {
    debugPrint('🧪 TEST 3: Endpoint de Usuarios');
    debugPrint('─' * 50);

    try {
      // 1. Obtener token
      final token = await testGetToken();
      if (token == null) {
        debugPrint('❌ No se pudo obtener token. Abortando test.');
        return;
      }

      // 2. Hacer petición al endpoint
      debugPrint('📡 Haciendo petición a: $baseUrl/endpoints/usuarios.php');

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
          debugPrint('✅ Endpoint funcionando correctamente');
          final usuarios = data['data'] as List;
          debugPrint('👥 Usuarios encontrados: ${usuarios.length}');

          if (usuarios.isNotEmpty) {
            debugPrint('');
            debugPrint('📋 Primeros 3 usuarios:');
            for (var i = 0; i < usuarios.length && i < 3; i++) {
              final user = usuarios[i];
              debugPrint('  ${i + 1}. ${user['nombre']} ${user['apellidos']} (${user['email']})');
            }
          }
        } else {
          debugPrint('❌ Error en la respuesta: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Error 401: Token inválido o expirado');
        debugPrint('💡 Intenta refrescar el token: user.getIdToken(true)');
      } else if (response.statusCode == 429) {
        debugPrint('❌ Error 429: Demasiadas peticiones (rate limit)');
        debugPrint('💡 Espera 1 minuto e intenta de nuevo');
      } else {
        debugPrint('❌ Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
    }

    debugPrint('');
  }

  /// Test 4: Probar crear usuario
  static Future<void> testCreateUser() async {
    debugPrint('🧪 TEST 4: Crear Usuario');
    debugPrint('─' * 50);

    try {
      final token = await testGetToken();
      if (token == null) return;

      final nuevoUsuario = {
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'nombre': 'Usuario',
        'apellidos': 'De Prueba',
        'user': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        'password': 'password123',
        'idtemporada': 1,
        'idclub': 1,
        'permisos': 0,
      };

      debugPrint('📤 Creando usuario: ${nuevoUsuario['email']}');

      final response = await http.post(
        Uri.parse('$baseUrl/endpoints/usuarios.php?action=createAppUser'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nuevoUsuario),
      );

      debugPrint('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Usuario creado exitosamente');
          debugPrint('🆔 ID: ${data['data']['id']}');
          debugPrint('📧 Email: ${data['data']['email']}');
        } else {
          debugPrint('❌ Error: ${data['message']}');
        }
      } else {
        debugPrint('❌ Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
    }

    debugPrint('');
  }

  /// Test 5: Probar rate limiting
  static Future<void> testRateLimiting() async {
    debugPrint('🧪 TEST 5: Rate Limiting');
    debugPrint('─' * 50);

    try {
      final token = await testGetToken();
      if (token == null) return;

      debugPrint('📡 Haciendo 10 peticiones rápidas...');

      for (var i = 1; i <= 10; i++) {
        final response = await http.get(
          Uri.parse('$baseUrl/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        final rateLimitRemaining = response.headers['x-ratelimit-remaining'];

        if (response.statusCode == 200) {
          debugPrint('  $i. ✅ OK (remaining: $rateLimitRemaining)');
        } else if (response.statusCode == 429) {
          debugPrint('  $i. ⚠️ BLOQUEADO (rate limit alcanzado)');
          break;
        } else {
          debugPrint('  $i. ❌ Error ${response.statusCode}');
        }

        // Pequeña pausa entre peticiones
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ Test de rate limiting completado');
    } catch (e) {
      debugPrint('❌ Exception: $e');
    }

    debugPrint('');
  }

  /// Ejecutar todos los tests
  static Future<void> runAllTests() async {
    debugPrint('\n');
    debugPrint('═' * 50);
    debugPrint('🚀 INICIANDO TESTS DEL BACKEND SEGURO');
    debugPrint('═' * 50);
    debugPrint('\n');

    await testBackendBasic();
    await Future.delayed(const Duration(seconds: 1));

    await testGetToken();
    await Future.delayed(const Duration(seconds: 1));

    await testUsuariosEndpoint();
    await Future.delayed(const Duration(seconds: 1));

    // await testCreateUser();
    // await Future.delayed(const Duration(seconds: 1));

    // await testRateLimiting();

    debugPrint('═' * 50);
    debugPrint('✅ TESTS COMPLETADOS');
    debugPrint('═' * 50);
    debugPrint('\n');
  }
}

/// Función helper para usar en tu app
void debugPrint(String message) {
  debugPrint(message);
}

/// EJEMPLO DE USO:
///
/// En tu app Flutter, puedes llamar esto desde un botón:
///
/// ElevatedButton(
///   onPressed: () async {
///     await BackendTester.runAllTests();
///   },
///   child: Text('Probar Backend'),
/// )
///
/// O probar tests individuales:
///
/// await BackendTester.testBackendBasic();
/// await BackendTester.testUsuariosEndpoint();
