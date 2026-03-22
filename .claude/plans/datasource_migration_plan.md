# Plan: Migración a Datasource Dual (Supabase + BackendSeguro)

## ✅ ESTADO: COMPLETADO

## 🎯 Objetivo
Crear una arquitectura que permita cambiar entre Supabase y backend_seguro_web con un solo flag de configuración.

## ✅ Fases Completadas

### Fase 1: Infraestructura Base ✅
- [x] Crear `AppConfig` con flag `useBackendSeguro`
- [x] Crear `ApiResponse` modelo estandarizado
- [x] Crear interfaz `AppDataSource` con métodos comunes
- [x] Crear `DataSourceFactory`

### Fase 2: Implementación Supabase ✅
- [x] Crear `SupabaseDataSource` implementando la interfaz
- [x] Extraer lógica de BLoCs existentes

### Fase 3: Implementación BackendSeguro ✅
- [x] Crear `BackendSeguroDataSource` con cliente HTTP
- [x] Implementar autenticación Firebase JWT
- [x] Añadir `firebase_auth` al pubspec.yaml
- [x] Crear `FirebaseConfig` para inicialización

### Fase 4: Refactorizar BLoCs ✅
- [x] Actualizar `FeesBloc` para usar datasource
- [x] Actualizar `TrainingsBloc` para usar datasource

### Fase 5: Firebase Web Config ✅
- [x] Añadir `firebase_core` a pubspec.yaml
- [x] Crear `lib/firebase_options.dart` con configuración del proyecto
- [x] Actualizar `web/index.html` con scripts de Firebase SDK
- [x] Actualizar `main.dart` para inicializar Firebase condicionalmente
- [x] Configurar `FirebaseConfig` helper

### Fase 6: Testing (Pendiente)
- [ ] Obtener API Key y App ID desde Firebase Console
- [ ] Reemplazar placeholders en `firebase_options.dart` y `web/index.html`
- [ ] Verificar funcionamiento con Supabase (`useBackendSeguro = false`)
- [ ] Verificar funcionamiento con BackendSeguro (`useBackendSeguro = true`)
- [ ] Probar cambio de flag sin modificar código adicional

---

## 🔧 Cómo Cambiar de Proveedor

**Editar `lib/core/config/app_config.dart`:**

```dart
// false = Supabase (actual)
// true  = backend_seguro_web (PHP + Firebase Auth)
static const bool useBackendSeguro = false;  // ← Cambiar aquí
```

---

## 🔥 Configuración Firebase (Para backend_seguro_web)

### 1. Añadir dependencias en `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
```

### 2. Inicializar en `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:futbase_web_3/core/config/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseConfig.initialize();

  // Inicializar Supabase (mantener para transición)
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}
```

### 3. Configurar plataformas:

#### Web (`web/index.html`):
```html
<!-- Añadir antes de main.dart.js -->
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js"></script>
<script>
  firebase.initializeApp({
    apiKey: "...",
    authDomain: "futbase-xxxxx.firebaseapp.com",
    projectId: "futbase-xxxxx",
    storageBucket: "futbase-xxxxx.appspot.com",
    messagingSenderId: "...",
    appId: "..."
  });
</script>
```

#### Android (`android/app/google-services.json`):
- Descargar desde Firebase Console
- Colocar en `android/app/`

#### iOS (`ios/Runner/GoogleService-Info.plist`):
- Descargar desde Firebase Console
- Añadir via Xcode al proyecto

---

## 📁 Archivos Creados

| Archivo | Descripción |
|---------|-------------|
| `lib/core/config/app_config.dart` | Flag de selección |
| `lib/core/config/firebase_config.dart` | Configuración Firebase |
| `lib/core/datasources/api_response.dart` | Modelo de respuesta |
| `lib/core/datasources/app_datasource.dart` | Interfaz común |
| `lib/core/datasources/supabase_datasource.dart` | Implementación Supabase |
| `lib/core/datasources/backend_seguro_datasource.dart` | Implementación HTTP |
| `lib/core/datasources/datasource_factory.dart` | Factory |
| `lib/core/datasources/datasources.dart` | Barrel exports |

---

## 📊 Endpoints BackendSeguro Usados

| Endpoint | Action | Método |
|----------|--------|--------|
| `cuotas.php` | `getcuotasbyclub` | GET |
| `entrenamientos.php` | `getbyteamtemporada` | GET |
| `entrenamientos.php` | `getbyclubtemporada` | GET |
| `entrenamientos.php` | `create` | POST |
| `entrenamientos.php` | `update` | POST |
| `entrenamientos.php` | `delete` | POST |
| `equipos.php` | `getbyclubtemporada` | GET |
| `jugadores.php` | `getbyequipo` | GET |
| `categories.php` | `getall` | GET |
| `entrenos_jugadores.php` | `getmotivos` | GET |
| `entrenos_jugadores.php` | `getbyentrenamiento` | GET |
| `entrenos_jugadores.php` | `savebatch` | POST |

---

## ⚠️ Notas Importantes

1. **Autenticación dual**: Mientras uses `useBackendSeguro = false`, la app usa Supabase Auth. Al cambiar a `true`, usa Firebase Auth.

2. **Migración de usuarios**: Los usuarios deben registrarse en ambos sistemas o implementar migración.

3. **Rate limiting**: BackendSeguro tiene rate limiting (100 req/min).

4. **Cache**: BackendSeguro tiene cache propio en el servidor.
