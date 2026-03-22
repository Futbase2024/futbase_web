-- Prueba de la query batch de entrenos jugadores
-- Ejecutar esto directamente en phpMyAdmin o tu cliente MySQL

-- 1. Verificar que existe la vista ventrenojugador
SELECT COUNT(*) as existe_vista
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name = 'ventrenojugador';

-- 2. Ver estructura de la vista
DESCRIBE ventrenojugador;

-- 3. Verificar que existe la tabla tjugadores
SELECT COUNT(*) as existe_tabla
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name = 'tjugadores';

-- 4. Probar la query batch (cambiar valores si es necesario)
SELECT ej.*
FROM ventrenojugador ej
INNER JOIN tjugadores j ON ej.idjugador = j.idjugador
WHERE j.idequipo = 800 AND ej.idtemporada = 6
ORDER BY ej.idjugador, ej.fecha DESC
LIMIT 10;

-- 5. Contar resultados totales
SELECT COUNT(*) as total_rows
FROM ventrenojugador ej
INNER JOIN tjugadores j ON ej.idjugador = j.idjugador
WHERE j.idequipo = 800 AND ej.idtemporada = 6;

-- 6. Ver cuántos jugadores únicos hay
SELECT COUNT(DISTINCT ej.idjugador) as jugadores_unicos
FROM ventrenojugador ej
INNER JOIN tjugadores j ON ej.idjugador = j.idjugador
WHERE j.idequipo = 800 AND ej.idtemporada = 6;
