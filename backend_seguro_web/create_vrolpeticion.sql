-- Script para crear la vista vrolpeticion
-- Esta vista combina la tabla trolpeticion con información adicional de usuarios, clubes, equipos, etc.

CREATE OR REPLACE VIEW vrolpeticion AS
SELECT
    rp.id,
    rp.uid,
    rp.idusuario,
    rp.idtemporada,
    rp.tipo,
    rp.fecha,
    rp.estado,
    rp.idclub,
    rp.idequipo,
    rp.idjugador,
    rp.comentario,
    -- Información del usuario (si existe tabla usuarios)
    u.nombre as nombre_usuario,
    u.email as email_usuario,
    -- Información del tipo de rol
    tr.nombre as nombre_tipo_rol,
    -- Información del club (si es aplicable)
    c.nombre as nombre_club,
    -- Información del equipo (si es aplicable)
    e.nombre as nombre_equipo,
    -- Información del jugador (si es aplicable)
    j.nombre as nombre_jugador,
    j.apellidos as apellidos_jugador
FROM trolpeticion rp
LEFT JOIN tusuarios u ON rp.idusuario = u.id
LEFT JOIN ttiporol tr ON rp.tipo = tr.tipo
LEFT JOIN tclub c ON rp.idclub = c.id
LEFT JOIN tequipos e ON rp.idequipo = e.id
LEFT JOIN tjugadores j ON rp.idjugador = j.id;
