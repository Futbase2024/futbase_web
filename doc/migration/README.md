# Migración a Supabase - FutBase 3.0

Este directorio contiene los scripts SQL para migrar las tablas maestras de FutBase a Supabase.

## Archivos Generados

| Archivo | Descripción | Registros |
|---------|-------------|-----------|
| `supabase_migration_001.sql` | Creación de tablas, índices, RLS y triggers | - |
| `data_taplicacion.sql` | Datos de información de la app | 1 |
| `data_tappconfig.sql` | Datos de configuración de la app | 1 |
| `data_tcategorias.sql` | Categorías de edad (BEBE, PREBENJAMIN, etc.) | 8 |
| `data_tcamisetas.sql` | Catálogo de camisetas/jerseys | 155 |
| `data_tcampos.sql` | Estadios y campos de fútbol | ~700 |
| `data_tclubes.sql` | Clubes de fútbol registrados | 106 |

## Orden de Ejecución

Ejecutar los scripts en este orden:

```bash
# 1. Crear estructura de tablas
supabase_migration_001.sql

# 2. Insertar datos en orden de dependencias
data_taplicacion.sql
data_tappconfig.sql
data_tcategorias.sql
data_tcamisetas.sql
data_tcampos.sql
data_tclubes.sql
```

## Cómo Aplicar las Migraciones

### Opción 1: Supabase Dashboard (SQL Editor)

1. Ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto
3. Navega a **SQL Editor**
4. Copia y pega el contenido de cada archivo SQL
5. Ejecuta en el orden indicado

### Opción 2: Supabase CLI

```bash
# Crear nueva migración
supabase migration new initial_master_tables

# Copiar el contenido de supabase_migration_001.sql al archivo creado
# Luego aplicar:
supabase db push
```

### Opción 3: MCP Tool (Claude Code)

```
Usar la herramienta mcp__supabase__apply_migration
```

## Estructura de Tablas

### taplicacion
- Información de versiones y enlaces de la aplicación

### tappconfig
- Configuración general (nombre app, calidad imagen, tokens FCM)

### tcategorias
- Categorías de edad para clasificar jugadores y equipos
- Rangos: BEBE (4-5), PREBENJAMIN (6-7), BENJAMIN (8-9), etc.

### tcamisetas
- Catálogo de camisetas/jerseys con URL de imagen
- idcolor: 0=sin color, 1-3=colores específicos

### tcampos
- Estadios y campos de fútbol
- Incluye coordenadas GPS (posX, posY)
- Tipos de césped: ARTIFICIAL, NATURAL
- Tipos de campo: FUTBOL 11, FUTBOL 7, FUTBOL 5

### tclubes
- Clubes de fútbol registrados
- Datos de contacto: email, teléfono, web
- Estado: validado, asociado
- Referencias a equipos (primeraeq, segundaeq, terceraeq)

## Seguridad (RLS)

Todas las tablas tienen Row Level Security habilitado con políticas de lectura pública:

```sql
-- Ejemplo de política aplicada
CREATE POLICY "Lectura pública" ON public.tclubes
    FOR SELECT USING (true);
```

## Notas

- Los campos `testing`, `validado`, `asociado` se migraron de INTEGER a BOOLEAN
- Se agregaron campos `created_at` y `updated_at` con valores automáticos
- Los triggers `updated_at` actualizan automáticamente la fecha de modificación
