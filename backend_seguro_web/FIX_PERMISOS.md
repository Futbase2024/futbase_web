# 🔧 Arreglar Permisos del Cache

Tu backend está casi funcionando, solo falta arreglar los permisos de escritura en la carpeta `cache/`.

---

## ✅ Lo que está funcionando:

- ✅ PHP 8.2.29 funcionando
- ✅ Todas las extensiones instaladas
- ✅ Conexión a base de datos OK
- ✅ Firebase configurado (project_id: futbase-17919)
- ✅ Carpeta logs con permisos OK

## ❌ Problema:

- ❌ Carpeta `cache/` no tiene permisos de escritura

---

## 🚀 Solución Rápida

### **Opción 1: Desde el Navegador (Más Fácil)**

1. Ve a: **`https://futbase.es/backend_seguro_web/fix_permissions.php`**
2. Deberías ver: `"success": true`
3. Recarga: **`https://futbase.es/backend_seguro_web/test.php`**
4. Ahora todo debería estar OK ✅

---

### **Opción 2: Por SSH (Más Seguro)**

Si tienes acceso SSH al servidor:

```bash
# Conectar por SSH
ssh tu_usuario@futbase.es

# Ir a la carpeta del backend
cd /ruta/a/backend_seguro_web

# Dar permisos
chmod -R 777 cache/
chmod -R 777 logs/

# Verificar
ls -la cache/
```

Deberías ver algo como:
```
drwxrwxrwx  cache/
```

---

### **Opción 3: Por cPanel/FTP**

Si usas cPanel o FTP:

1. Conéctate a tu servidor
2. Navega a `backend_seguro_web/`
3. Haz clic derecho en la carpeta `cache/`
4. Selecciona "Permisos" o "Chmod"
5. Marca todas las casillas (777)
6. ✅ Aplicar a subcarpetas
7. Guardar

---

## 🧪 Verificar que Funcionó

Después de arreglar los permisos, ve a:

```
https://futbase.es/backend_seguro_web/test.php
```

Deberías ver:
```json
{
  "success": true,
  "message": "✅ Todos los tests pasaron correctamente",
  "tests": {
    "permissions": {
      "status": "ok",
      "cache_writable": true,
      "logs_writable": true,
      "message": "Permisos correctos"
    }
  }
}
```

---

## 📱 Probar desde Flutter

Una vez que `test.php` muestre `"success": true`, prueba desde tu app:

```dart
Future<void> testBackend() async {
  // 1. Test básico
  final response = await http.get(
    Uri.parse('https://futbase.es/backend_seguro_web/test.php'),
  );

  print('Status: ${response.statusCode}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      print('✅ Backend funcionando correctamente');

      // 2. Test con autenticación
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();

        final response2 = await http.get(
          Uri.parse('https://futbase.es/backend_seguro_web/endpoints/usuarios.php?action=getAllUsers&idtemporada=1'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Usuarios: ${response2.statusCode}');
        print('Response: ${response2.body}');
      }
    }
  }
}
```

---

## 🗑️ Limpieza (Después de Arreglar)

Una vez que todo funcione, borra estos archivos de prueba por seguridad:

```bash
rm fix_permissions.php
rm test.php
```

O manualmente desde FTP/cPanel.

---

## ❓ ¿Por Qué Faltan Permisos?

Cuando subes archivos por FTP, a veces las carpetas no se crean con los permisos correctos. Las carpetas `cache/` y `logs/` necesitan permisos de escritura (777) para que PHP pueda crear archivos dentro.

---

## 🎯 Siguiente Paso

Una vez que los permisos estén OK, ya puedes empezar a usar el backend desde tu app Flutter. El endpoint de usuarios ya está funcionando:

```
GET /endpoints/usuarios.php?action=getAllUsers&idtemporada=1
```

---

**¿Necesitas ayuda?** Revisa [TESTING.md](TESTING.md) para más detalles.
