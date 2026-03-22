# 🔄 Migration: Sistema de Devoluciones de Ropa

## 📋 Problema Actual

Error 500 al intentar marcar una devolución porque las columnas `devuelto` y `fechadevolucion` no existen en la tabla `tropa`.

## ✅ Solución

Ejecutar los scripts SQL en tu base de datos para añadir las columnas necesarias.

---

## 🚀 Pasos a Seguir

### 1️⃣ Acceder a tu Base de Datos

Opciones:
- **phpMyAdmin** (recomendado)
- **MySQL Workbench**
- **Línea de comandos MySQL**
- **Panel de control de tu hosting** (cPanel, Plesk, etc.)

### 2️⃣ Ejecutar el Script SQL

**OPCIÓN A - MySQL Moderno (5.7+, MariaDB 10.2+):**
```bash
Ejecutar: add_devolucion_columns_to_tropa.sql
```

**OPCIÓN B - MySQL Antiguo o si OPCIÓN A falla:**
```bash
Ejecutar: add_devolucion_columns_to_tropa_safe.sql
(Seguir las instrucciones dentro del archivo - ejecutar queries una por una)
```

### 3️⃣ Actualizar la Vista vropa

```bash
Ejecutar: update_vropa_view.sql
```

---

## 📝 Instrucciones Detalladas por Método

### 🌐 Usando phpMyAdmin

1. Acceder a phpMyAdmin en tu hosting
2. Seleccionar la base de datos de FutBase (generalmente se llama `futbase` o similar)
3. Click en la pestaña **SQL**
4. Copiar y pegar el contenido de `add_devolucion_columns_to_tropa.sql`
5. Click en **Continuar** o **Go**
6. Repetir pasos 3-5 con `update_vropa_view.sql`
7. Verificar que todo está OK (deberías ver mensajes de éxito)

### 💻 Usando MySQL CLI

```bash
# Conectar a la base de datos
mysql -u tu_usuario -p tu_base_de_datos

# Ejecutar los scripts
source /ruta/a/add_devolucion_columns_to_tropa.sql
source /ruta/a/update_vropa_view.sql

# Verificar
DESCRIBE tropa;
DESCRIBE vropa;
```

### 🖥️ Usando Panel de Hosting (cPanel)

1. Login a cPanel
2. Buscar **phpMyAdmin** en la sección de Bases de Datos
3. Seguir los pasos de "Usando phpMyAdmin" arriba

---

## 🔍 Verificación

Después de ejecutar los scripts, verifica que todo está correcto:

```sql
-- Ver las nuevas columnas en tropa
SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'tropa'
    AND COLUMN_NAME IN ('devuelto', 'fechadevolucion');

-- Ver la estructura actualizada de la vista
DESCRIBE vropa;
```

Deberías ver:
- ✅ `devuelto` - TINYINT(1) - DEFAULT 0
- ✅ `fechadevolucion` - DATETIME - DEFAULT NULL

---

## 🎯 Después de la Migration

1. **Recargar la aplicación** en el navegador (Ctrl+F5 o Cmd+Shift+R)
2. **Probar una devolución** desde la página de ropa
3. Deberías ver:
   - ✅ Diálogo de devolución abre correctamente
   - ✅ Opción de imprimir recibo de devolución
   - ✅ Devolución se procesa sin errores
   - ✅ Lista se actualiza automáticamente

---

## ❓ Troubleshooting

### Error: "Column 'devuelto' already exists"
**Solución:** La columna ya existe, puedes ignorar este error y continuar con el siguiente paso.

### Error: "Table 'tropa' doesn't exist"
**Solución:** Verifica que estás conectado a la base de datos correcta.

### Error: "Access denied"
**Solución:** Tu usuario no tiene permisos para crear columnas. Contacta al administrador de la base de datos.

### La vista vropa da error
**Solución:** Verifica que las tablas `tprendas`, `vjugadores` y `vequipos` existen. Puede que necesites ajustar el script según tu esquema.

---

## 📞 Soporte

Si tienes problemas:
1. Copia el mensaje de error completo
2. Verifica que la base de datos es la correcta
3. Verifica que tienes permisos de ALTER TABLE

---

## 🔒 Backup

**IMPORTANTE:** Antes de ejecutar cualquier migration, es recomendable hacer un backup de la base de datos.

```bash
# Backup de la tabla tropa
mysqldump -u usuario -p base_datos tropa > backup_tropa_$(date +%Y%m%d).sql
```

---

✅ **Una vez completada la migration, el sistema de devoluciones funcionará perfectamente.**
