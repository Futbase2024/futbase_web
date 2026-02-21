# Plan de Migración: Triggers y Vistas MySQL -> Supabase (PostgreSQL)

## Resumen

- **Triggers a migrar**: 13
- **Vistas a migrar**: 47
- **Tablas ya migradas**: Confirmado (archivos JSON en `/tablas/`)

---

## 1. TRIGGERS

### 1.1 Tabla: `tconvpartidos`

#### Trigger: `tconvpartidos_AFTER_UPDATE`
**Propósito**: Actualiza estadísticas acumuladas de temporada cuando se finaliza un partido

**Lógica**:
1. Si `finalizado = 1` y `valoracion = 0`:
   - Actualiza `testadisticasjugador` sumando: pj, ptitular, plesionado, goles, asistencias, minutos, tarjetas, etc.
   - Calcula evolución del pfScore
   - Aplica sanciones por acumulación de amarillas (5, 10, 15, 20)
   - Si roja directa, marca jugador como sancionado
   - Quita estado convocado

```sql
-- PostgreSQL equivalent
CREATE OR REPLACE FUNCTION fn_convpartidos_after_update()
RETURNS TRIGGER AS $$
DECLARE
    v_tar_ama INTEGER;
    v_tar_ama2 INTEGER;
    v_stats RECORD;
    v_nuevo_pf_score INTEGER;
    v_anterior_pf_score INTEGER;
    v_nueva_evol INTEGER;
    v_tar_am_sancion INTEGER;
BEGIN
    -- Calcular tarjetas amarillas
    IF NEW.tam = 2 THEN
        v_tar_ama2 := 1;
        v_tar_ama := 1;
    ELSE
        v_tar_ama := NEW.tam;
        v_tar_ama2 := 0;
    END IF;

    -- Solo ejecutar si partido finalizado y sin valoración
    IF NEW.finalizado = 1 AND NEW.valoracion = 0 THEN
        -- Obtener estadísticas actuales
        SELECT * INTO v_stats
        FROM testadisticasjugador
        WHERE idjugador = NEW.idjugador AND idtemporada = NEW.idtemporada;

        IF v_stats IS NOT NULL THEN
            v_anterior_pf_score := v_stats.pfscore;

            -- Actualizar estadísticas acumuladas
            UPDATE testadisticasjugador SET
                pj = pj + NEW.convocado,
                ptitular = ptitular + NEW.titular,
                plesionado = plesionado + NEW.lesion,
                goles = goles + NEW.goles,
                golpp = golpp + NEW.golpp,
                asistencias = asistencias + NEW.asistencias,
                minutos = minutos + NEW.minutos,
                tr = tr + NEW.tro,
                ta = ta + v_tar_ama,
                ta2 = ta2 + v_tar_ama2,
                penalti = penalti + NEW.penalti,
                perdidas = perdidas + NEW.perdidas,
                recuperaciones = recuperaciones + NEW.recuperaciones,
                fjuego = fjuego + NEW.fjuego,
                faltacom = faltacom + NEW.faltacom,
                faltarec = faltarec + NEW.faltarec,
                tiroap = tiroap + NEW.tiroap,
                tirofuera = tirofuera + NEW.tirofuera,
                paradas = paradas + NEW.paradas,
                despejes = despejes + NEW.despejes,
                salidas = salidas + NEW.salidas,
                fallos = fallos + NEW.fallos
            WHERE idjugador = NEW.idjugador AND visible = 1 AND idtemporada = NEW.idtemporada;

            -- Calcular evolución
            v_nuevo_pf_score := NEW.pfscore;
            IF v_nuevo_pf_score > v_anterior_pf_score THEN
                v_nueva_evol := 1;
            ELSIF v_nuevo_pf_score < v_anterior_pf_score THEN
                v_nueva_evol := 2;
            ELSE
                v_nueva_evol := 0;
            END IF;

            -- Sanciones por amarillas acumuladas
            v_tar_am_sancion := v_stats.ta + v_tar_ama;
            IF v_tar_am_sancion IN (5, 10, 15, 20) AND v_tar_ama = 1 THEN
                UPDATE tjugadores SET idestado = 3
                WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
            END IF;

            -- Roja directa
            IF NEW.tro = 1 THEN
                UPDATE tjugadores SET idestado = 3
                WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
            END IF;
        END IF;

        -- Quitar estado convocado
        UPDATE tjugadores SET convocado = 0
        WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_convpartidos_after_update
AFTER UPDATE ON tconvpartidos
FOR EACH ROW EXECUTE FUNCTION fn_convpartidos_after_update();
```

---

#### Trigger: `tconvpartidos_BEFORE_DELETE`
**Propósito**: Quita estado convocado antes de eliminar

```sql
CREATE OR REPLACE FUNCTION fn_convpartidos_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE tjugadores SET convocado = 0
    WHERE id = OLD.idjugador AND idtemporada = OLD.idtemporada;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_convpartidos_before_delete
BEFORE DELETE ON tconvpartidos
FOR EACH ROW EXECUTE FUNCTION fn_convpartidos_before_delete();
```

---

#### Trigger: `tconvpartidos_AFTER_DELETE`
**Propósito**: Resta estadísticas cuando se elimina un partido finalizado

```sql
CREATE OR REPLACE FUNCTION fn_convpartidos_after_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_tar_ama INTEGER;
    v_tar_ama2 INTEGER;
    v_stats RECORD;
BEGIN
    -- Calcular tipo de amarilla
    IF OLD.tam = 2 THEN
        v_tar_ama2 := 1;
        v_tar_ama := 1;
    ELSE
        v_tar_ama := OLD.tam;
        v_tar_ama2 := 0;
    END IF;

    -- Solo si partido estaba finalizado
    IF OLD.finalizado = 1 THEN
        SELECT * INTO v_stats
        FROM testadisticasjugador
        WHERE idjugador = OLD.idjugador AND idtemporada = OLD.idtemporada;

        IF v_stats IS NOT NULL THEN
            UPDATE testadisticasjugador SET
                pj = pj - OLD.convocado,
                ptitular = ptitular - OLD.titular,
                plesionado = plesionado - OLD.lesion,
                goles = goles - OLD.goles,
                golpp = golpp - OLD.golpp,
                asistencias = asistencias - OLD.asistencias,
                minutos = minutos - OLD.minutos,
                tr = tr - OLD.tro,
                ta = ta - v_tar_ama,
                ta2 = ta2 - v_tar_ama2,
                valoracion = valoracion - OLD.valoracion,
                penalti = penalti - OLD.penalti,
                perdidas = perdidas - OLD.perdidas,
                recuperaciones = recuperaciones - OLD.recuperaciones,
                fjuego = fjuego - OLD.fjuego,
                faltacom = faltacom - OLD.faltacom,
                faltarec = faltarec - OLD.faltarec,
                tiroap = tiroap - OLD.tiroap,
                tirofuera = tirofuera - OLD.tirofuera,
                paradas = paradas - OLD.paradas,
                despejes = despejes - OLD.despejes,
                salidas = salidas - OLD.salidas,
                fallos = fallos - OLD.fallos
            WHERE idjugador = OLD.idjugador AND visible = 1 AND idtemporada = OLD.idtemporada;
        END IF;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_convpartidos_after_delete
AFTER DELETE ON tconvpartidos
FOR EACH ROW EXECUTE FUNCTION fn_convpartidos_after_delete();
```

---

### 1.2 Tabla: `tentrenamientos`

#### Trigger: `tentrenamientos_AFTER_INSERT`
**Propósito**: Inserta jugadores y entrenadores automáticamente al crear entrenamiento

```sql
CREATE OR REPLACE FUNCTION fn_entrenamientos_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar jugadores activos del equipo
    INSERT INTO tentrenojugador(idjugador, identrenamiento, idequipo, idclub, asiste, motivo, observaciones, tlimite)
    SELECT id, NEW.id, NEW.idequipo, NEW.idclub, 0, 0, '', NEW.tlimite
    FROM tjugadores
    WHERE idequipo = NEW.idequipo AND activo = 1;

    -- Insertar entrenadores (tipo 2 y 12)
    INSERT INTO tentrenoct(identrenador, identrenamiento, idequipo, idclub, asiste, motivo, observaciones)
    SELECT id, NEW.id, NEW.idequipo, NEW.idclub, 0, 0, ''
    FROM troles
    WHERE idequipo = NEW.idequipo AND tipo IN (2, 12);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_entrenamientos_after_insert
AFTER INSERT ON tentrenamientos
FOR EACH ROW EXECUTE FUNCTION fn_entrenamientos_after_insert();
```

---

### 1.3 Tabla: `teventospartido`

#### Trigger: `teventospartido_AFTER_INSERT`
**Propósito**: Actualiza goles, tarjetas, minutos en tiempo real durante el partido

**Lógica Compleja**:
- Si `gol = 1`: Incrementa goles en convocatoria y partido
- Si `penalti = 1`: También incrementa penaltis
- Si `asistencia = 1`: Incrementa asistencias
- Si `golencajado = 1`: Incrementa goles rival
- Si `tam` o `tam2`: Maneja tarjetas amarillas (acumuladas = roja)
- Si `tro`: Tarjeta roja directa
- Si `sale`/`entra`: Control de sustituciones y minutos

```sql
CREATE OR REPLACE FUNCTION fn_eventospartido_after_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_jug_ta INTEGER;
    v_min_jug INTEGER;
    v_min_ent INTEGER;
    v_casa_fue INTEGER;
BEGIN
    -- Gol
    IF NEW.gol = 1 THEN
        IF NEW.penalti = 1 THEN
            UPDATE tconvpartidos SET goles = goles + 1, penalti = penalti + 1
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
            UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, goles = goles + 1
            WHERE id = NEW.idpartido;
        ELSE
            UPDATE tconvpartidos SET goles = goles + 1
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
            UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, goles = goles + 1
            WHERE id = NEW.idpartido;
        END IF;
    END IF;

    -- Asistencia
    IF NEW.asistencia = 1 THEN
        UPDATE tconvpartidos SET asistencias = asistencias + 1
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    -- Gol encajado (portero)
    IF NEW.golencajado = 1 THEN
        UPDATE tconvpartidos SET goles = goles + 1
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        SELECT casafuera INTO v_casa_fue FROM tpartidos WHERE id = NEW.idpartido;
        IF NEW.idjugador <> 1 THEN
            UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, golesrival = golesrival + 1
            WHERE id = NEW.idpartido;
        END IF;
    END IF;

    -- Eventos de tiempo (inicio, descanso, fin)
    IF NEW.inicio = 1 OR NEW.descanso = 1 OR NEW.fin = 1 THEN
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
    END IF;

    -- Lesión
    IF NEW.lesion = 1 THEN
        UPDATE tconvpartidos SET lesion = 1
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    -- Tarjetas amarillas
    IF NEW.tam = 1 OR NEW.tam2 = 1 THEN
        SELECT tam, minutos, mentra INTO v_jug_ta, v_min_jug, v_min_ent
        FROM tconvpartidos
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        IF v_jug_ta = 0 THEN
            UPDATE tconvpartidos SET tam = tam + 1
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        ELSIF v_jug_ta = 1 THEN
            UPDATE tconvpartidos SET
                tam = tam + 1,
                tro = tro + 1,
                jugando = 0,
                minutos = (NEW.min - v_min_ent) + v_min_jug
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        END IF;
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
    END IF;

    -- Tarjeta roja directa
    IF NEW.tro = 1 AND NEW.tam2 = 0 THEN
        SELECT minutos, mentra INTO v_min_jug, v_min_ent
        FROM tconvpartidos
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        UPDATE tconvpartidos SET tro = tro + 1, jugando = 0, minutos = (NEW.min - v_min_ent) + v_min_jug
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
    END IF;

    -- Sale (sustitución)
    IF NEW.sale = 1 THEN
        SELECT minutos, mentra INTO v_min_jug, v_min_ent
        FROM tconvpartidos
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
        UPDATE tconvpartidos SET jugando = 0, minutos = (NEW.min - v_min_ent) + v_min_jug, mentra = NEW.min
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    -- Entra (sustitución)
    IF NEW.entra = 1 THEN
        UPDATE tconvpartidos SET jugando = 1, mentra = NEW.min
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_eventospartido_after_insert
AFTER INSERT ON teventospartido
FOR EACH ROW EXECUTE FUNCTION fn_eventospartido_after_insert();
```

---

#### Trigger: `teventospartido_AFTER_DELETE`
**Propósito**: Revierte cambios al eliminar evento

```sql
CREATE OR REPLACE FUNCTION fn_eventospartido_after_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_jug_ta INTEGER;
    v_jug_tit INTEGER;
BEGIN
    -- Revertir gol
    IF OLD.gol = 1 THEN
        IF OLD.penalti = 1 THEN
            UPDATE tconvpartidos SET goles = goles - 1, penalti = penalti - 1
            WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
            UPDATE tpartidos SET goles = goles - 1 WHERE id = OLD.idpartido;
        ELSE
            UPDATE tconvpartidos SET goles = goles - 1
            WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
            UPDATE tpartidos SET goles = goles - 1 WHERE id = OLD.idpartido;
        END IF;
    END IF;

    -- Revertir asistencia
    IF OLD.asistencia = 1 THEN
        UPDATE tconvpartidos SET asistencias = asistencias - 1
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
    END IF;

    -- Revertir gol encajado
    IF OLD.golencajado = 1 THEN
        UPDATE tconvpartidos SET goles = goles - 1
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        UPDATE tpartidos SET golesrival = golesrival - 1 WHERE id = OLD.idpartido;
    END IF;

    -- Revertir tarjeta amarilla
    IF OLD.tam = 1 THEN
        SELECT tam INTO v_jug_ta FROM tconvpartidos
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;

        IF v_jug_ta = 1 THEN
            UPDATE tconvpartidos SET tam = tam - 1
            WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        ELSIF v_jug_ta = 2 THEN
            UPDATE tconvpartidos SET tam = tam - 1, tro = tro - 1
            WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        END IF;
    END IF;

    -- Revertir roja directa
    IF OLD.tro = 1 AND OLD.tam2 = 0 THEN
        UPDATE tconvpartidos SET tro = tro - 1
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
    END IF;

    -- Revertir lesión
    IF OLD.lesion = 1 THEN
        UPDATE tconvpartidos SET lesion = 0
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        UPDATE tjugadores SET idestado = 1 WHERE id = OLD.idjugador;
        DELETE FROM tlesiones WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_eventospartido_after_delete
AFTER DELETE ON teventospartido
FOR EACH ROW EXECUTE FUNCTION fn_eventospartido_after_delete();
```

---

### 1.4 Tabla: `tjugador` / `tjugadores`

#### Trigger: `tjugadores_AFTER_INSERT`
**Propósito**: Crea registro de estadísticas y registro de padres al crear jugador

```sql
CREATE OR REPLACE FUNCTION fn_jugadores_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Crear registro de estadísticas
    INSERT INTO testadisticasjugador
    (idclub, idequipo, idjugador, idtemporada, pj, ptitular, plesionado, goles, ta, ta2, tr, minutos, valoracion)
    VALUES
    (NEW.idclub, NEW.idequipo, NEW.id, NEW.idtemporada, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    -- Registrar tutor 1 si no existe
    IF NEW.emailtutor1 IS NOT NULL AND NEW.emailtutor1 <> 'null' AND NEW.emailtutor1 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, FLOOR(RANDOM() * 1000000)::INT, 0, 1);
        END IF;
    END IF;

    -- Registrar tutor 2 si no existe
    IF NEW.emailtutor2 IS NOT NULL AND NEW.emailtutor2 <> 'null' AND NEW.emailtutor2 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, FLOOR(RANDOM() * 1000000)::INT, 0, 2);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_jugadores_after_insert
AFTER INSERT ON tjugadores
FOR EACH ROW EXECUTE FUNCTION fn_jugadores_after_insert();
```

---

#### Trigger: `tjugadores_AFTER_UPDATE`
**Propósito**: Actualiza registro de padres al modificar emails de tutores

```sql
CREATE OR REPLACE FUNCTION fn_jugadores_after_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar tutor 1 si cambió y no existe
    IF NEW.emailtutor1 IS NOT NULL AND NEW.emailtutor1 <> 'null' AND NEW.emailtutor1 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, FLOOR(RANDOM() * 1000000)::INT, 0, 1);
        END IF;
    END IF;

    -- Registrar tutor 2 si cambió y no existe
    IF NEW.emailtutor2 IS NOT NULL AND NEW.emailtutor2 <> 'null' AND NEW.emailtutor2 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, FLOOR(RANDOM() * 1000000)::INT, 0, 2);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_jugadores_after_update
AFTER UPDATE ON tjugadores
FOR EACH ROW EXECUTE FUNCTION fn_jugadores_after_update();
```

---

### 1.5 Tabla: `tpartidos`

#### Trigger: `tpartidos_AFTER_UPDATE`
**Propósito**: Finaliza convocatorias y calcula minutos finales cuando se finaliza partido

```sql
CREATE OR REPLACE FUNCTION fn_partidos_after_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se finaliza el partido
    IF NEW.finalizado = 1 THEN
        -- Jugadores que no estaban jugando
        UPDATE tconvpartidos SET jugando = 0, finalizado = 1
        WHERE idpartido = NEW.id AND jugando = 0;

        -- Jugadores que estaban jugando (calcular minutos finales)
        UPDATE tconvpartidos SET jugando = 0, finalizado = 1, minutos = (NEW.min - mentra) + minutos
        WHERE idpartido = NEW.id AND jugando = 1;
    END IF;

    -- Si se reinicia el partido (goles 0-0, no finalizado, minuto 0)
    IF NEW.goles = 0 AND NEW.golesrival = 0 AND NEW.finalizado = 0 AND NEW.minuto = '00:00' AND NEW.min = 0 THEN
        UPDATE tconvpartidos SET minutos = 0, mentra = 0, jugando = titular
        WHERE idpartido = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_partidos_after_update
AFTER UPDATE ON tpartidos
FOR EACH ROW EXECUTE FUNCTION fn_partidos_after_update();
```

---

#### Trigger: `tpartidos_BEFORE_DELETE`
**Propósito**: Elimina registros relacionados antes de eliminar partido

```sql
CREATE OR REPLACE FUNCTION fn_partidos_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM tconvpartidos WHERE idpartido = OLD.id;
    DELETE FROM testadisticaspartido WHERE idpartido = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_partidos_before_delete
BEFORE DELETE ON tpartidos
FOR EACH ROW EXECUTE FUNCTION fn_partidos_before_delete();
```

---

## 2. VISTAS

**NOTA**: El archivo `mysql_schema.sql` contiene solo estructuras temporales de vistas (con `1 AS campo`), no el SQL real de definición. Se necesita acceso a la base de datos MySQL original para extraer las definiciones completas de las vistas.

### Lista de Vistas Identificadas (47 total):

| # | Nombre | Categoría |
|---|--------|-----------|
| 1 | vContabilidad | Administración |
| 2 | vCuotas | Administración |
| 3 | vPdfPartido1 | Partidos |
| 4 | vTelemPlayFutbol | Telemetría |
| 5 | vTelemPorAnunciante | Telemetría |
| 6 | vTelemPorAnuncianteNueva | Telemetría |
| 7 | vTelemPubli | Telemetría |
| 8 | vanalisis_jugadores_temporada_21_22 | Análisis |
| 9 | vanuncios | Publicidad |
| 10 | vcampos | Estadios |
| 11 | vcarnets | Usuarios |
| 12 | vclientes | Administración |
| 13 | vclubes | Clubes |
| 14 | vejercicios | Entrenamientos |
| 15 | vemails | Comunicación |
| 16 | ventradasScan | Accesos |
| 17 | ventrenadores | Usuarios |
| 18 | ventrenamiento_archivos | Entrenamientos |
| 19 | ventrenamientos | Entrenamientos |
| 20 | ventrenoCT | Entrenamientos |
| 21 | ventrenojugador | Entrenamientos |
| 22 | ventrenojugador_ant | Entrenamientos |
| 23 | vequipos | Equipos |
| 24 | vestadisticasjugador | Estadísticas |
| 25 | vestadisticaspordia | Estadísticas |
| 26 | vestadisticaspormes | Estadísticas |
| 27 | vestadisticasporsemana | Estadísticas |
| 28 | veventos | Partidos |
| 29 | veventospublicidad | Publicidad |
| 30 | vinformes | Documentos |
| 31 | vjugador | Jugadores |
| 32 | vjugador_estadisticas_json | Jugadores |
| 33 | vjugadores | Jugadores |
| 34 | vjugadoresFB | Firebase |
| 35 | vjugadoresFB_antigua | Firebase |
| 36 | vjugadores_stats_completa | Estadísticas |
| 37 | vjugadores_stats_completa_v2 | Estadísticas |
| 38 | vjugadores_stats_completa_v3 | Estadísticas |
| 39 | vjugadores_stats_completa_v3_real | Estadísticas |
| 40 | vjugsimple | Jugadores |
| 41 | vlavaropa | Administración |
| 42 | vpartido | Partidos |
| 43 | vpartidojugador | Partidos |
| 44 | vpartidosjugadores | Partidos |
| 45 | vpartidosjugadoresFB | Firebase |
| 46 | vpautaentrenamiento | Entrenamientos |
| 47 | vpublicidad | Publicidad |
| 48 | vroles | Usuarios |
| 49 | vrolesCarnet | Usuarios |
| 50 | vrolpeticion | Usuarios |
| 51 | vropa | Administración |
| 52 | vsponsors | Publicidad |
| 53 | vtallapeso | Jugadores |
| 54 | vusuarioroles | Usuarios |
| 55 | vusuarios | Usuarios |

---

## 3. Pasos de Migración

### Fase 1: Crear Funciones y Triggers en Supabase

1. Ejecutar cada función en el editor SQL de Supabase
2. Crear los triggers asociados
3. Verificar que no haya conflictos de nombres

### Fase 2: Migrar Vistas

**IMPORTANTE**: Se requiere acceso a MySQL original para extraer las definiciones reales de las vistas.

```bash
# Comando para extraer vistas de MySQL
mysqldump -u usuario -p --no-data --routines --triggers nombre_base | grep "CREATE VIEW"
```

Alternativa en MySQL:
```sql
SELECT VIEW_NAME, VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'nombre_base';
```

### Fase 3: Verificación

1. Probar cada trigger con operaciones CRUD
2. Verificar que las vistas retornan datos correctos
3. Comparar conteos de registros

---

## 4. Consideraciones PostgreSQL vs MySQL

| Aspecto | MySQL | PostgreSQL |
|---------|-------|------------|
| Delimitador | `DELIMITER ;;` | No necesario |
| Variables | `DECLARE x INT;` | `DECLARE x INTEGER;` |
| IF | `IF ... THEN ... END IF;` | Igual |
| NEW/OLD | `NEW.campo` | `NEW.campo` |
| RETURN | No tiene | `RETURN NEW/OLD;` |
| Crear trigger | `CREATE TRIGGER ... FOR EACH ROW BEGIN ... END` | `CREATE TRIGGER ... FOR EACH ROW EXECUTE FUNCTION fn();` |
| RANDOM | `RAND()` | `RANDOM()` |

---

## 5. Próximos Pasos

1. **Confirmar acceso a Supabase** para ejecutar migraciones
2. **Obtener definiciones reales de vistas** desde MySQL original
3. **Ejecutar migración de triggers** primero (son independientes)
4. **Ejecutar migración de vistas** después
5. **Validar integridad** con datos de prueba
