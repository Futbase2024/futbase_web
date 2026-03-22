-- ============================================
-- Script de Verificación Rápida
-- Ejecutar este script primero para ver el estado actual
-- ============================================

SELECT '=== VERIFICACIÓN DE COLUMNAS EN TABLA tropa ===' AS '';

-- Verificar si las columnas existen
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ La columna devuelto YA EXISTE'
        ELSE '❌ La columna devuelto NO EXISTE - NECESITA CREARSE'
    END AS resultado
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tropa'
    AND COLUMN_NAME = 'devuelto';

SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ La columna fechadevolucion YA EXISTE'
        ELSE '❌ La columna fechadevolucion NO EXISTE - NECESITA CREARSE'
    END AS resultado
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tropa'
    AND COLUMN_NAME = 'fechadevolucion';

SELECT '=== ESTRUCTURA ACTUAL DE LA TABLA tropa ===' AS '';

-- Mostrar todas las columnas de tropa
SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tropa'
ORDER BY
    ORDINAL_POSITION;

SELECT '=== VERIFICACIÓN DE VISTA vropa ===' AS '';

-- Verificar si la vista existe
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ La vista vropa EXISTE'
        ELSE '❌ La vista vropa NO EXISTE'
    END AS resultado
FROM
    INFORMATION_SCHEMA.VIEWS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'vropa';

-- Ver si vropa tiene las columnas de devolución
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ vropa incluye columna devuelto'
        ELSE '❌ vropa NO incluye devuelto - NECESITA ACTUALIZARSE'
    END AS resultado
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'vropa'
    AND COLUMN_NAME = 'devuelto';

SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ vropa incluye columna fechadevolucion'
        ELSE '❌ vropa NO incluye fechadevolucion - NECESITA ACTUALIZARSE'
    END AS resultado
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'vropa'
    AND COLUMN_NAME = 'fechadevolucion';

SELECT '=== FIN DE VERIFICACIÓN ===' AS '';
SELECT 'Basado en los resultados, ejecuta los scripts necesarios' AS 'SIGUIENTE PASO';
