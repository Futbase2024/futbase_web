-- ============================================
-- Migration: Actualizar vista vropa para incluir campos de devolución
-- Fecha: 2025-12-03
-- ============================================

-- Primero eliminar la vista existente
DROP VIEW IF EXISTS vropa;

-- Recrear la vista con los nuevos campos
CREATE VIEW vropa AS
SELECT
    t.id,
    t.fecha,
    t.idjugador,
    t.idclub,
    t.idtemporada,
    t.idprenda,
    t.pvp,
    t.descuento,
    t.acuenta,
    t.entregado,
    t.talla,
    t.tipopago,
    t.avisado,
    t.nombre,
    t.devuelto,
    t.fechadevolucion,
    p.descripcion,
    p.icono,
    j.nombre AS nombre_jugador,
    j.apellidos,
    e.idequipo,
    e.equipo
FROM
    tropa t
    LEFT JOIN tprendas p ON t.idprenda = p.id
    LEFT JOIN vjugadores j ON t.idjugador = j.id
    LEFT JOIN vequipos e ON j.idequipo = e.idequipo
ORDER BY
    t.fecha DESC;

-- Verificar la vista
SELECT 'Vista vropa actualizada correctamente ✅' AS Resultado;

-- Mostrar estructura de la vista
DESCRIBE vropa;
