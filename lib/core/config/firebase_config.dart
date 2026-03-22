import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Configuración de Firebase para la autenticación con backend_seguro_web
///
/// Inicializar en main.dart antes de runApp():
/// ```dart
/// await FirebaseConfig.initialize();
/// ```
class FirebaseConfig {
  FirebaseConfig._();

  static bool _initialized = false;

  /// Inicializa Firebase Auth
  ///
  /// Nota: Para web, necesitas añadir los scripts de Firebase en index.html
  /// Para móviles, necesitas los archivos google-services.json / GoogleService-Info.plist
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Firebase ya debería estar inicializado por firebase_core
      // Solo verificamos que la autenticación esté disponible
      final auth = FirebaseAuth.instance;
      debugPrint('🔥 [FirebaseConfig] Firebase Auth inicializado');

      // Escuchar cambios de estado de autenticación
      auth.authStateChanges().listen((User? user) {
        if (kDebugMode) {
          if (user != null) {
            debugPrint('🔥 [FirebaseConfig] Usuario autenticado: ${user.email}');
          } else {
            debugPrint('🔥 [FirebaseConfig] No hay usuario autenticado');
          }
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('🔥 [FirebaseConfig] Error al inicializar: $e');
      rethrow;
    }
  }

  /// Obtiene la instancia de FirebaseAuth
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Obtiene el usuario actual
  static User? get currentUser => auth.currentUser;

  /// Verifica si hay un usuario autenticado
  static bool get isAuthenticated => currentUser != null;

  /// Obtiene el token de autenticación actual
  static Future<String?> getIdToken() async {
    final user = currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Obtiene el token de autenticación forzando refresh
  static Future<String?> getIdTokenRefresh() async {
    final user = currentUser;
    if (user == null) return null;
    return await user.getIdToken(true);
  }

  /// Cierra la sesión del usuario
  static Future<void> signOut() async {
    await auth.signOut();
    debugPrint('🔥 [FirebaseConfig] Sesión cerrada');
  }
}
