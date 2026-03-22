-- ============================================
-- Actualización de vista vropa - VERSIÓN REAL
-- Basada en tu estructura actual
-- ============================================

-- Eliminar vista existente
DROP VIEW IF EXISTS `vropa`;

-- Recrear vista con los nuevos campos devuelto y fechadevolucion
CREATE
    ALGORITHM = UNDEFINED
    DEFINER = `qanf664`@`%`
    SQL SECURITY DEFINER
VIEW `vropa` AS
    SELECT
        `tr`.`id` AS `id`,
        `tr`.`idjugador` AS `idjugador`,
        `tr`.`idclub` AS `idclub`,
        `tr`.`idtemporada` AS `idtemporada`,
        `tr`.`idprenda` AS `idprenda`,
        `tr`.`pvp` AS `pvp`,
        `tr`.`descuento` AS `descuento`,
        `tr`.`entregado` AS `entregado`,
        `tr`.`acuenta` AS `acuenta`,
        `tr`.`tipopago` AS `tipopago`,
        `tr`.`talla` AS `talla`,
        `tr`.`fecha` AS `fecha`,
        `tr`.`fechaentrega` AS `fechaentrega`,
        `tr`.`avisado` AS `avisado`,
        `tr`.`devuelto` AS `devuelto`,
        `tr`.`fechadevolucion` AS `fechadevolucion`,
        `tp`.`descripcion` AS `descripcion`,
        `tc`.`icono` AS `icono`,
        `tc`.`estado` AS `estado`,
        (CASE
            WHEN (`tr`.`idjugador` = 0) THEN `tr`.`nombre`
            ELSE CONCAT(`tj`.`nombre`, ' ', `tj`.`apellidos`)
        END) AS `nombre`,
        (CASE
            WHEN (`tr`.`idjugador` = 0) THEN ''
            ELSE `tj`.`idequipo`
        END) AS `idequipo`,
        (CASE
            WHEN (`tr`.`idjugador` = 0) THEN ''
            ELSE `te`.`equipo`
        END) AS `equipo`
    FROM
        ((((`tropa` `tr`
        JOIN `tprendas` `tp` ON ((`tr`.`idprenda` = `tp`.`id`)))
        LEFT JOIN `tjugadores` `tj` ON ((`tr`.`idjugador` = `tj`.`id`)))
        LEFT JOIN `tequipos` `te` ON ((`tj`.`idequipo` = `te`.`id`)))
        LEFT JOIN `testadocobro` `tc` ON ((`tr`.`tipopago` = `tc`.`id`)));

-- Verificación
SELECT 'Vista vropa actualizada correctamente ✅' AS Resultado;

-- Verificar que las nuevas columnas están
SELECT
    COUNT(*) AS columnas_devolucion_agregadas
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'vropa'
    AND COLUMN_NAME IN ('devuelto', 'fechadevolucion');
