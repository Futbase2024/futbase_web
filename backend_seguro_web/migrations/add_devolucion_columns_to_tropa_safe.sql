-- ============================================
-- Migration SEGURA: Añadir campos de devolución a tabla tropa
-- Fecha: 2025-12-03
-- Compatible con MySQL 5.x y MariaDB antiguas
-- ============================================

-- Esta versión maneja errores si las columnas ya existen

-- Verificar columnas existentes
SELECT 'Verificando columnas existentes...' AS Paso;

SELECT
    COUNT(*) as columna_devuelto_existe
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tropa'
    AND COLUMN_NAME = 'devuelto';

SELECT
    COUNT(*) as columna_fechadevolucion_existe
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tropa'
    AND COLUMN_NAME = 'fechadevolucion';

-- ============================================
-- EJECUTAR MANUALMENTE (una por una):
-- ============================================

-- Si columna_devuelto_existe = 0, ejecutar:
ALTER TABLE tropa
ADD COLUMN devuelto TINYINT(1) DEFAULT 0 COMMENT 'Indica si la prenda fue devuelta (0=No, 1=Sí)';

-- Si columna_fechadevolucion_existe = 0, ejecutar:
ALTER TABLE tropa
ADD COLUMN fechadevolucion DATETIME NULL DEFAULT NULL COMMENT 'Fecha en que se realizó la devolución';

-- Crear índice (si da error, ignorar - ya existe):
CREATE INDEX idx_devuelto ON tropa(devuelto);

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================
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
    AND COLUMN_NAME IN ('devuelto', 'fechadevolucion')
ORDER BY
    COLUMN_NAME;

SELECT 'Migration completada! ✅' AS Resultado;
