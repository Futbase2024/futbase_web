-- ============================================================================
-- EJECUTAR EN MYSQL WORKBENCH PARA EXPORTAR VISTAS
-- ============================================================================
-- Copiar el resultado y pegarlo en un archivo para que Claude lo procese
-- ============================================================================

SELECT
    VIEW_NAME as nombre_vista,
    VIEW_DEFINITION as definicion
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'qanf664'
ORDER BY VIEW_NAME;

-- ============================================================================
-- O usar SHOW CREATE VIEW para cada vista:
-- ============================================================================

SHOW CREATE VIEW vContabilidad;
SHOW CREATE VIEW vCuotas;
SHOW CREATE VIEW vPdfPartido1;
SHOW CREATE VIEW vTelemPlayFutbol;
SHOW CREATE VIEW vTelemPorAnunciante;
SHOW CREATE VIEW vTelemPorAnuncianteNueva;
SHOW CREATE VIEW vTelemPubli;
SHOW CREATE VIEW vanalisis_jugadores_temporada_21_22;
SHOW CREATE VIEW vanuncios;
SHOW CREATE VIEW vcampos;
SHOW CREATE VIEW vcarnets;
SHOW CREATE VIEW vclientes;
SHOW CREATE VIEW vclubes;
SHOW CREATE VIEW vejercicios;
SHOW CREATE VIEW vemails;
SHOW CREATE VIEW ventradasScan;
SHOW CREATE VIEW ventrenadores;
SHOW CREATE VIEW ventrenamiento_archivos;
SHOW CREATE VIEW ventrenamientos;
SHOW CREATE VIEW ventrenoCT;
SHOW CREATE VIEW ventrenojugador;
SHOW CREATE VIEW ventrenojugador_ant;
SHOW CREATE VIEW vequipos;
SHOW CREATE VIEW vestadisticasjugador;
SHOW CREATE VIEW vestadisticaspordia;
SHOW CREATE VIEW vestadisticaspormes;
SHOW CREATE VIEW vestadisticasporsemana;
SHOW CREATE VIEW veventos;
SHOW CREATE VIEW veventospublicidad;
SHOW CREATE VIEW vinformes;
SHOW CREATE VIEW vjugador;
SHOW CREATE VIEW vjugador_estadisticas_json;
SHOW CREATE VIEW vjugadores;
SHOW CREATE VIEW vjugadoresFB;
SHOW CREATE VIEW vjugadoresFB_antigua;
SHOW CREATE VIEW vjugadores_stats_completa;
SHOW CREATE VIEW vjugadores_stats_completa_v2;
SHOW CREATE VIEW vjugadores_stats_completa_v3;
SHOW CREATE VIEW vjugadores_stats_completa_v3_real;
SHOW CREATE VIEW vjugsimple;
SHOW CREATE VIEW vlavaropa;
SHOW CREATE VIEW vpartido;
SHOW CREATE VIEW vpartidojugador;
SHOW CREATE VIEW vpartidosjugadores;
SHOW CREATE VIEW vpartidosjugadoresFB;
SHOW CREATE VIEW vpautaentrenamiento;
SHOW CREATE VIEW vpublicidad;
SHOW CREATE VIEW vroles;
SHOW CREATE VIEW vrolesCarnet;
SHOW CREATE VIEW vrolpeticion;
SHOW CREATE VIEW vropa;
SHOW CREATE VIEW vsponsors;
SHOW CREATE VIEW vtallapeso;
SHOW CREATE VIEW vusuarioroles;
SHOW CREATE VIEW vusuarios;
