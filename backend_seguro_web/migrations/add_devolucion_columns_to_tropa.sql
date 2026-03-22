-- ============================================
-- Migration: Añadir campos de devolución a tabla tropa
-- Fecha: 2025-12-03
-- Descripción: Añade los campos necesarios para gestionar devoluciones de ropa
-- ============================================

-- Verificar si las columnas ya existen antes de crearlas

-- Añadir columna 'devuelto' (0 = no devuelto, 1 = devuelto)
ALTER TABLE tropa
ADD COLUMN IF NOT EXISTS devuelto TINYINT(1) DEFAULT 0 COMMENT 'Indica si la prenda fue devuelta (0=No, 1=Sí)';

-- Añadir columna 'fechadevolucion' (fecha de la devolución)
ALTER TABLE tropa
ADD COLUMN IF NOT EXISTS fechadevolucion DATETIME NULL DEFAULT NULL COMMENT 'Fecha en que se realizó la devolución';

-- Crear índice para optimizar búsquedas por devoluciones
CREATE INDEX IF NOT EXISTS idx_devuelto ON tropa(devuelto);

-- Verificar las columnas creadas
SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_COMMENT
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tropa'
    AND COLUMN_NAME IN ('devuelto', 'fechadevolucion');

-- ============================================
-- IMPORTANTE: Ejecutar este script en tu base de datos
--
-- Opciones:
-- 1. phpMyAdmin: Ir a SQL tab y pegar este script
-- 2. MySQL CLI: mysql -u usuario -p nombre_bd < add_devolucion_columns_to_tropa.sql
-- 3. Consola SQL de tu hosting
-- ============================================
