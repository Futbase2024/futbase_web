import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

/// Configuración de Firebase para Futbase
/// Proyecto: futbase-17919
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions no está configurado para ${defaultTargetPlatform.name}. '
      'Esta aplicación solo está configurada para web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACpS3zXdlDEFgZzIDuxyT6j4Wp57_Ephc',
    authDomain: 'futbase-17919.firebaseapp.com',
    projectId: 'futbase-17919',
    storageBucket: 'futbase-17919.appspot.com',
    messagingSenderId: '65194175239',
    appId: '1:65194175239:web:b9744ce4454c150d5d73a2',
  );
}
