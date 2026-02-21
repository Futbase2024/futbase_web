-- ============================================================================
-- MIGRACIÓN DE TRIGGERS MySQL -> PostgreSQL (Supabase)
-- Futbase 3.0
-- ============================================================================
-- Ejecutar este script en el Editor SQL de Supabase
-- ============================================================================

-- ============================================================================
-- 1. TRIGGERS PARA tconvpartidos
-- ============================================================================

-- 1.1 Función: tconvpartidos_AFTER_UPDATE
-- Actualiza estadísticas acumuladas de temporada cuando se finaliza un partido
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_convpartidos_after_update()
RETURNS TRIGGER AS $$
DECLARE
    v_tar_ama INTEGER;
    v_tar_ama2 INTEGER;
    v_pj INTEGER;
    v_ptitular INTEGER;
    v_plesionado INTEGER;
    v_goles INTEGER;
    v_golpp INTEGER;
    v_asistencias INTEGER;
    v_minutos INTEGER;
    v_tr INTEGER;
    v_ta INTEGER;
    v_ta2 INTEGER;
    v_penalti INTEGER;
    v_perdidas INTEGER;
    v_recuperaciones INTEGER;
    v_fjuego INTEGER;
    v_faltacom INTEGER;
    v_faltarec INTEGER;
    v_tiroap INTEGER;
    v_tirofuera INTEGER;
    v_paradas INTEGER;
    v_despejes INTEGER;
    v_salidas INTEGER;
    v_fallos INTEGER;
    v_anterior_pf_score INTEGER;
    v_tar_am_sancion INTEGER;
BEGIN
    -- Calcular tarjetas amarillas simples o dobles
    IF NEW.tam = 2 THEN
        v_tar_ama2 := 1;
        v_tar_ama := 1;
    ELSE
        v_tar_ama := COALESCE(NEW.tam, 0);
        v_tar_ama2 := 0;
    END IF;

    -- Solo ejecutar si el partido está finalizado y sin valoración aún
    IF NEW.finalizado = 1 AND NEW.valoracion = 0 THEN
        -- Obtener estadísticas actuales de temporada
        SELECT
            COALESCE(pj, 0), COALESCE(ptitular, 0), COALESCE(plesionado, 0),
            COALESCE(goles, 0), COALESCE(golpp, 0), COALESCE(asistencias, 0),
            COALESCE(minutos, 0), COALESCE(tr, 0), COALESCE(ta, 0), COALESCE(ta2, 0),
            COALESCE(penalti, 0), COALESCE(perdidas, 0), COALESCE(recuperaciones, 0),
            COALESCE(fjuego, 0), COALESCE(faltacom, 0), COALESCE(faltarec, 0),
            COALESCE(tiroap, 0), COALESCE(tirofuera, 0), COALESCE(paradas, 0),
            COALESCE(despejes, 0), COALESCE(salidas, 0), COALESCE(fallos, 0), COALESCE(pfscore, 82)
        INTO
            v_pj, v_ptitular, v_plesionado, v_goles, v_golpp, v_asistencias,
            v_minutos, v_tr, v_ta, v_ta2, v_penalti, v_perdidas, v_recuperaciones,
            v_fjuego, v_faltacom, v_faltarec, v_tiroap, v_tirofuera, v_paradas,
            v_despejes, v_salidas, v_fallos, v_anterior_pf_score
        FROM testadisticasjugador
        WHERE idjugador = NEW.idjugador AND idtemporada = NEW.idtemporada;

        -- Actualizar estadísticas acumuladas de temporada
        UPDATE testadisticasjugador SET
            pj = v_pj + COALESCE(NEW.convocado, 0),
            ptitular = v_ptitular + COALESCE(NEW.titular, 0),
            plesionado = v_plesionado + COALESCE(NEW.lesion, 0),
            goles = v_goles + COALESCE(NEW.goles, 0),
            golpp = v_golpp + COALESCE(NEW.golpp, 0),
            asistencias = v_asistencias + COALESCE(NEW.asistencias, 0),
            minutos = v_minutos + COALESCE(NEW.minutos, 0),
            tr = v_tr + COALESCE(NEW.tro, 0),
            ta = v_ta + v_tar_ama,
            ta2 = v_ta2 + v_tar_ama2,
            penalti = v_penalti + COALESCE(NEW.penalti, 0),
            perdidas = v_perdidas + COALESCE(NEW.perdidas, 0),
            recuperaciones = v_recuperaciones + COALESCE(NEW.recuperaciones, 0),
            fjuego = v_fjuego + COALESCE(NEW.fjuego, 0),
            faltacom = v_faltacom + COALESCE(NEW.faltacom, 0),
            faltarec = v_faltarec + COALESCE(NEW.faltarec, 0),
            tiroap = v_tiroap + COALESCE(NEW.tiroap, 0),
            tirofuera = v_tirofuera + COALESCE(NEW.tirofuera, 0),
            paradas = v_paradas + COALESCE(NEW.paradas, 0),
            despejes = v_despejes + COALESCE(NEW.despejes, 0),
            salidas = v_salidas + COALESCE(NEW.salidas, 0),
            fallos = v_fallos + COALESCE(NEW.fallos, 0),
            updated_at = NOW()
        WHERE idjugador = NEW.idjugador AND visible = 1 AND idtemporada = NEW.idtemporada;

        -- Sanciones por acumulación de amarillas (5, 10, 15, 20)
        v_tar_am_sancion := v_ta + v_tar_ama;
        IF v_tar_am_sancion IN (5, 10, 15, 20) AND v_tar_ama = 1 THEN
            UPDATE tjugadores SET idestado = 3, updated_at = NOW()
            WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
        END IF;

        -- Roja directa => sanción
        IF NEW.tro = 1 THEN
            UPDATE tjugadores SET idestado = 3, updated_at = NOW()
            WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
        END IF;

        -- Quitar estado convocado al finalizar partido
        UPDATE tjugadores SET convocado = 0, updated_at = NOW()
        WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
DROP TRIGGER IF EXISTS tr_convpartidos_after_update ON tconvpartidos;
CREATE TRIGGER tr_convpartidos_after_update
AFTER UPDATE ON tconvpartidos
FOR EACH ROW EXECUTE FUNCTION fn_convpartidos_after_update();

-- ============================================================================
-- 1.2 Función: tconvpartidos_BEFORE_DELETE
-- Quita estado convocado antes de eliminar
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_convpartidos_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE tjugadores SET convocado = 0, updated_at = NOW()
    WHERE id = OLD.idjugador AND idtemporada = OLD.idtemporada;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_convpartidos_before_delete ON tconvpartidos;
CREATE TRIGGER tr_convpartidos_before_delete
BEFORE DELETE ON tconvpartidos
FOR EACH ROW EXECUTE FUNCTION fn_convpartidos_before_delete();

-- ============================================================================
-- 1.3 Función: tconvpartidos_AFTER_DELETE
-- Resta estadísticas cuando se elimina un partido finalizado
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_convpartidos_after_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_tar_ama INTEGER;
    v_tar_ama2 INTEGER;
    v_pj INTEGER;
    v_ptitular INTEGER;
    v_plesionado INTEGER;
    v_goles INTEGER;
    v_golpp INTEGER;
    v_asistencias INTEGER;
    v_minutos INTEGER;
    v_tr INTEGER;
    v_ta INTEGER;
    v_ta2 INTEGER;
    v_valoracion INTEGER;
    v_penalti INTEGER;
    v_perdidas INTEGER;
    v_recuperaciones INTEGER;
    v_fjuego INTEGER;
    v_faltacom INTEGER;
    v_faltarec INTEGER;
    v_tiroap INTEGER;
    v_tirofuera INTEGER;
    v_paradas INTEGER;
    v_despejes INTEGER;
    v_salidas INTEGER;
    v_fallos INTEGER;
BEGIN
    -- Determinar tipo de amarilla (simple o doble)
    IF OLD.tam = 2 THEN
        v_tar_ama2 := 1;
        v_tar_ama := 1;
    ELSE
        v_tar_ama := COALESCE(OLD.tam, 0);
        v_tar_ama2 := 0;
    END IF;

    -- Solo si el partido eliminado estaba finalizado
    IF OLD.finalizado = 1 THEN
        -- Obtener estadísticas actuales
        SELECT
            COALESCE(pj, 0), COALESCE(ptitular, 0), COALESCE(plesionado, 0),
            COALESCE(goles, 0), COALESCE(golpp, 0), COALESCE(asistencias, 0),
            COALESCE(minutos, 0), COALESCE(tr, 0), COALESCE(ta, 0), COALESCE(ta2, 0),
            COALESCE(valoracion, 0), COALESCE(penalti, 0), COALESCE(perdidas, 0),
            COALESCE(recuperaciones, 0), COALESCE(fjuego, 0), COALESCE(faltacom, 0),
            COALESCE(faltarec, 0), COALESCE(tiroap, 0), COALESCE(tirofuera, 0),
            COALESCE(paradas, 0), COALESCE(despejes, 0), COALESCE(salidas, 0), COALESCE(fallos, 0)
        INTO
            v_pj, v_ptitular, v_plesionado, v_goles, v_golpp, v_asistencias,
            v_minutos, v_tr, v_ta, v_ta2, v_valoracion, v_penalti, v_perdidas,
            v_recuperaciones, v_fjuego, v_faltacom, v_faltarec, v_tiroap,
            v_tirofuera, v_paradas, v_despejes, v_salidas, v_fallos
        FROM testadisticasjugador
        WHERE idjugador = OLD.idjugador AND idtemporada = OLD.idtemporada;

        -- Restar estadísticas del partido eliminado
        UPDATE testadisticasjugador SET
            pj = v_pj - COALESCE(OLD.convocado, 0),
            ptitular = v_ptitular - COALESCE(OLD.titular, 0),
            plesionado = v_plesionado - COALESCE(OLD.lesion, 0),
            goles = v_goles - COALESCE(OLD.goles, 0),
            golpp = v_golpp - COALESCE(OLD.golpp, 0),
            asistencias = v_asistencias - COALESCE(OLD.asistencias, 0),
            minutos = v_minutos - COALESCE(OLD.minutos, 0),
            tr = v_tr - COALESCE(OLD.tro, 0),
            ta = v_ta - v_tar_ama,
            ta2 = v_ta2 - v_tar_ama2,
            valoracion = v_valoracion - COALESCE(OLD.valoracion, 0),
            penalti = v_penalti - COALESCE(OLD.penalti, 0),
            perdidas = v_perdidas - COALESCE(OLD.perdidas, 0),
            recuperaciones = v_recuperaciones - COALESCE(OLD.recuperaciones, 0),
            fjuego = v_fjuego - COALESCE(OLD.fjuego, 0),
            faltacom = v_faltacom - COALESCE(OLD.faltacom, 0),
            faltarec = v_faltarec - COALESCE(OLD.faltarec, 0),
            tiroap = v_tiroap - COALESCE(OLD.tiroap, 0),
            tirofuera = v_tirofuera - COALESCE(OLD.tirofuera, 0),
            paradas = v_paradas - COALESCE(OLD.paradas, 0),
            despejes = v_despejes - COALESCE(OLD.despejes, 0),
            salidas = v_salidas - COALESCE(OLD.salidas, 0),
            fallos = v_fallos - COALESCE(OLD.fallos, 0),
            updated_at = NOW()
        WHERE idjugador = OLD.idjugador AND visible = 1 AND idtemporada = OLD.idtemporada;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_convpartidos_after_delete ON tconvpartidos;
CREATE TRIGGER tr_convpartidos_after_delete
AFTER DELETE ON tconvpartidos
FOR EACH ROW EXECUTE FUNCTION fn_convpartidos_after_delete();

-- ============================================================================
-- 2. TRIGGERS PARA tentrenamientos
-- ============================================================================

-- 2.1 Función: tentrenamientos_AFTER_INSERT
-- Inserta jugadores y entrenadores automáticamente al crear entrenamiento
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_entrenamientos_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar jugadores activos del equipo en tentrenojugador
    INSERT INTO tentrenojugador(idjugador, identrenamiento, idequipo, idclub, asiste, motivo, observaciones, tlimite)
    SELECT id, NEW.id, NEW.idequipo, NEW.idclub, 0, 0, '', NEW.tlimite
    FROM tjugadores
    WHERE idequipo = NEW.idequipo AND activo = 1;

    -- Insertar entrenadores (tipo 2 y 12) en tentrenoct
    INSERT INTO tentrenoct(identrenador, identrenamiento, idequipo, idclub, asiste, motivo, observaciones)
    SELECT id, NEW.id, NEW.idequipo, NEW.idclub, 0, 0, ''
    FROM troles
    WHERE idequipo = NEW.idequipo AND tipo IN (2, 12);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_entrenamientos_after_insert ON tentrenamientos;
CREATE TRIGGER tr_entrenamientos_after_insert
AFTER INSERT ON tentrenamientos
FOR EACH ROW EXECUTE FUNCTION fn_entrenamientos_after_insert();

-- ============================================================================
-- 3. TRIGGERS PARA teventospartido
-- ============================================================================

-- 3.1 Función: teventospartido_AFTER_INSERT
-- Actualiza goles, tarjetas, minutos en tiempo real durante el partido
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_eventospartido_after_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_jug_ta INTEGER;
    v_min_jug INTEGER;
    v_min_ent INTEGER;
    v_casa_fue INTEGER;
BEGIN
    -- GOL
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

    -- ASISTENCIA
    IF NEW.asistencia = 1 THEN
        UPDATE tconvpartidos SET asistencias = asistencias + 1
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    -- GOL ENCAJADO (portero)
    IF NEW.golencajado = 1 THEN
        UPDATE tconvpartidos SET goles = goles + 1
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        SELECT casafuera INTO v_casa_fue FROM tpartidos WHERE id = NEW.idpartido;
        IF NEW.idjugador <> 1 THEN
            UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, golesrival = golesrival + 1
            WHERE id = NEW.idpartido;
        END IF;
    END IF;

    -- EVENTOS DE TIEMPO (inicio, descanso, fin)
    IF NEW.inicio = 1 OR NEW.descanso = 1 OR NEW.fin = 1 THEN
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
    END IF;

    -- LESIÓN
    IF NEW.lesion = 1 THEN
        UPDATE tconvpartidos SET lesion = 1
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    -- TARJETAS AMARILLAS (tam o tam2)
    IF NEW.tam = 1 OR NEW.tam2 = 1 THEN
        SELECT COALESCE(tam, 0), COALESCE(minutos, 0), COALESCE(mentra, 0)
        INTO v_jug_ta, v_min_jug, v_min_ent
        FROM tconvpartidos
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        IF v_jug_ta = 0 THEN
            UPDATE tconvpartidos SET tam = tam + 1
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        ELSIF v_jug_ta = 1 THEN
            -- Segunda amarilla = roja
            UPDATE tconvpartidos SET
                tam = tam + 1,
                tro = tro + 1,
                jugando = 0,
                minutos = (NEW.min - v_min_ent) + v_min_jug
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        END IF;
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
    END IF;

    -- TARJETA ROJA DIRECTA
    IF NEW.tro = 1 AND NEW.tam2 = 0 THEN
        SELECT COALESCE(minutos, 0), COALESCE(mentra, 0) INTO v_min_jug, v_min_ent
        FROM tconvpartidos
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        UPDATE tconvpartidos SET tro = tro + 1, jugando = 0, minutos = (NEW.min - v_min_ent) + v_min_jug
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
    END IF;

    -- SALE (sustitución - jugador que sale)
    IF NEW.sale = 1 THEN
        SELECT COALESCE(minutos, 0), COALESCE(mentra, 0) INTO v_min_jug, v_min_ent
        FROM tconvpartidos
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;

        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
        UPDATE tconvpartidos SET jugando = 0, minutos = (NEW.min - v_min_ent) + v_min_jug, mentra = NEW.min
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    -- ENTRA (sustitución - jugador que entra)
    IF NEW.entra = 1 THEN
        UPDATE tconvpartidos SET jugando = 1, mentra = NEW.min
        WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_eventospartido_after_insert ON teventospartido;
CREATE TRIGGER tr_eventospartido_after_insert
AFTER INSERT ON teventospartido
FOR EACH ROW EXECUTE FUNCTION fn_eventospartido_after_insert();

-- ============================================================================
-- 3.2 Función: teventospartido_AFTER_DELETE
-- Revierte cambios al eliminar evento
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_eventospartido_after_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_jug_ta INTEGER;
BEGIN
    -- Revertir GOL
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

    -- Revertir ASISTENCIA
    IF OLD.asistencia = 1 THEN
        UPDATE tconvpartidos SET asistencias = asistencias - 1
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
    END IF;

    -- Revertir GOL ENCAJADO
    IF OLD.golencajado = 1 THEN
        UPDATE tconvpartidos SET goles = goles - 1
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        UPDATE tpartidos SET golesrival = golesrival - 1 WHERE id = OLD.idpartido;
    END IF;

    -- Revertir TARJETA AMARILLA
    IF OLD.tam = 1 THEN
        SELECT COALESCE(tam, 0) INTO v_jug_ta
        FROM tconvpartidos
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;

        IF v_jug_ta = 1 THEN
            UPDATE tconvpartidos SET tam = tam - 1
            WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        ELSIF v_jug_ta = 2 THEN
            UPDATE tconvpartidos SET tam = tam - 1, tro = tro - 1
            WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        END IF;
    END IF;

    -- Revertir TARJETA ROJA DIRECTA
    IF OLD.tro = 1 AND OLD.tam2 = 0 THEN
        UPDATE tconvpartidos SET tro = tro - 1
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
    END IF;

    -- Revertir LESIÓN
    IF OLD.lesion = 1 THEN
        UPDATE tconvpartidos SET lesion = 0
        WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
        UPDATE tjugadores SET idestado = 1 WHERE id = OLD.idjugador;
        DELETE FROM tlesiones WHERE idjugador = OLD.idjugador AND idpartido = OLD.idpartido;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_eventospartido_after_delete ON teventospartido;
CREATE TRIGGER tr_eventospartido_after_delete
AFTER DELETE ON teventospartido
FOR EACH ROW EXECUTE FUNCTION fn_eventospartido_after_delete();

-- ============================================================================
-- 4. TRIGGERS PARA tjugadores
-- ============================================================================

-- 4.1 Función: tjugadores_AFTER_INSERT
-- Crea registro de estadísticas y registro de padres al crear jugador
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_jugadores_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Crear registro de estadísticas vacío para la temporada
    INSERT INTO testadisticasjugador
    (idclub, idequipo, idjugador, idtemporada, pj, ptitular, plesionado, goles, ta, ta2, tr, minutos, valoracion)
    VALUES
    (NEW.idclub, NEW.idequipo, NEW.id, NEW.idtemporada, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    -- Registrar tutor 1 si no existe y tiene email válido
    IF NEW.emailtutor1 IS NOT NULL AND NEW.emailtutor1 <> 'null' AND NEW.emailtutor1 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, FLOOR(RANDOM() * 1000000)::INTEGER, 0, 1);
        END IF;
    END IF;

    -- Registrar tutor 2 si no existe y tiene email válido
    IF NEW.emailtutor2 IS NOT NULL AND NEW.emailtutor2 <> 'null' AND NEW.emailtutor2 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, FLOOR(RANDOM() * 1000000)::INTEGER, 0, 2);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_jugadores_after_insert ON tjugadores;
CREATE TRIGGER tr_jugadores_after_insert
AFTER INSERT ON tjugadores
FOR EACH ROW EXECUTE FUNCTION fn_jugadores_after_insert();

-- ============================================================================
-- 4.2 Función: tjugadores_AFTER_UPDATE
-- Actualiza registro de padres al modificar emails de tutores
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_jugadores_after_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar tutor 1 si cambió y no existe
    IF NEW.emailtutor1 IS NOT NULL AND NEW.emailtutor1 <> 'null' AND NEW.emailtutor1 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, FLOOR(RANDOM() * 1000000)::INTEGER, 0, 1);
        END IF;
    END IF;

    -- Registrar tutor 2 si cambió y no existe
    IF NEW.emailtutor2 IS NOT NULL AND NEW.emailtutor2 <> 'null' AND NEW.emailtutor2 <> '' THEN
        IF NOT EXISTS (SELECT 1 FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
            INSERT INTO tregpadres
            (idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
            VALUES
            (NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, FLOOR(RANDOM() * 1000000)::INTEGER, 0, 2);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_jugadores_after_update ON tjugadores;
CREATE TRIGGER tr_jugadores_after_update
AFTER UPDATE ON tjugadores
FOR EACH ROW EXECUTE FUNCTION fn_jugadores_after_update();

-- ============================================================================
-- 5. TRIGGERS PARA tpartidos
-- ============================================================================

-- 5.1 Función: tpartidos_AFTER_UPDATE
-- Finaliza convocatorias y calcula minutos finales cuando se finaliza partido
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_partidos_after_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se finaliza el partido
    IF NEW.finalizado = 1 THEN
        -- Jugadores que no estaban jugando
        UPDATE tconvpartidos SET jugando = 0, finalizado = 1
        WHERE idpartido = NEW.id AND jugando = 0;

        -- Jugadores que estaban jugando (calcular minutos finales)
        UPDATE tconvpartidos SET jugando = 0, finalizado = 1, minutos = (NEW.min - COALESCE(mentra, 0)) + COALESCE(minutos, 0)
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

DROP TRIGGER IF EXISTS tr_partidos_after_update ON tpartidos;
CREATE TRIGGER tr_partidos_after_update
AFTER UPDATE ON tpartidos
FOR EACH ROW EXECUTE FUNCTION fn_partidos_after_update();

-- ============================================================================
-- 5.2 Función: tpartidos_BEFORE_DELETE
-- Elimina registros relacionados antes de eliminar partido
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_partidos_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM tconvpartidos WHERE idpartido = OLD.id;
    DELETE FROM testadisticaspartido WHERE idpartido = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_partidos_before_delete ON tpartidos;
CREATE TRIGGER tr_partidos_before_delete
BEFORE DELETE ON tpartidos
FOR EACH ROW EXECUTE FUNCTION fn_partidos_before_delete();

-- ============================================================================
-- FIN DE MIGRACIÓN DE TRIGGERS
-- ============================================================================
-- Verificar triggers creados:
-- SELECT tgname, tgrelid::regclass FROM pg_trigger WHERE tgname LIKE 'tr_%';
-- ============================================================================
