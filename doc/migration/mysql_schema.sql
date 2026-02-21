-- MySQL dump 10.13  Distrib 8.0.38, for macos14 (x86_64)
--
-- Host: qanf664.futbase.es    Database: qanf664
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `entrenamiento_archivos`
--

DROP TABLE IF EXISTS `entrenamiento_archivos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrenamiento_archivos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identrenamiento` int NOT NULL,
  `urlarchivo` varchar(255) COLLATE latin1_spanish_ci NOT NULL,
  `tipo` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `nombreoriginal` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fechasubida` datetime DEFAULT CURRENT_TIMESTAMP,
  `familia` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `orden` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=902 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `talineacionrival`
--

DROP TABLE IF EXISTS `talineacionrival`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `talineacionrival` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpartido` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `titular` int DEFAULT '0',
  `goles` int DEFAULT '0',
  `penalti` int DEFAULT '0',
  `tam` int DEFAULT '0',
  `tro` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `jugando` int DEFAULT '0',
  `dorsal` int DEFAULT '0',
  `posX` double DEFAULT NULL,
  `posY` double DEFAULT NULL,
  `posAlineacion` int DEFAULT '0',
  `posXCambio` double DEFAULT NULL,
  `posYCambio` double DEFAULT NULL,
  `posAlineacionCambio` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2361 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tanunciante`
--

DROP TABLE IF EXISTS `tanunciante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tanunciante` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idlocalidad` int DEFAULT '0',
  `idprovincia` int DEFAULT '0',
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `direccion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `cif` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `web` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urlImagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taplicacion`
--

DROP TABLE IF EXISTS `taplicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taplicacion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `aplicacion` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `versionandroid` int DEFAULT NULL,
  `versionios` int DEFAULT NULL,
  `linkios` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `linkandroid` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `novedades` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tappconfig`
--

DROP TABLE IF EXISTS `tappconfig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tappconfig` (
  `id` int NOT NULL,
  `appname` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `calidadimagen` int DEFAULT NULL,
  `testing` int DEFAULT NULL,
  `token` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fcmkey` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tayuda`
--

DROP TABLE IF EXISTS `tayuda`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tayuda` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pantalla` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `icono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `texto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcamisetas`
--

DROP TABLE IF EXISTS `tcamisetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcamisetas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idcolor` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=156 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcampos`
--

DROP TABLE IF EXISTS `tcampos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcampos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `campo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `direccion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `cesped` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idprovincia` int DEFAULT '0',
  `idlocalidad` int DEFAULT '0',
  `posX` double DEFAULT NULL,
  `posY` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_idprovincia_idx` (`idprovincia`),
  KEY `fk_idlocalidad_idx` (`idlocalidad`),
  KEY `idx_tcampos_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1637 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcarnets`
--

DROP TABLE IF EXISTS `tcarnets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcarnets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `iduser` int DEFAULT '0',
  `idrol` int DEFAULT '0',
  `idclub` int DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  `color` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `nsocio` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `qr` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `categoria` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urlimagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1573 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcarnetsimg`
--

DROP TABLE IF EXISTS `tcarnetsimg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcarnetsimg` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urlimagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idtemporada` int DEFAULT NULL,
  `colorletras` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idtipo` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcategorias`
--

DROP TABLE IF EXISTS `tcategorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcategorias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `categoria` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `edad1` int DEFAULT NULL,
  `edad2` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tclientes`
--

DROP TABLE IF EXISTS `tclientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tclientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `random` int DEFAULT NULL,
  `fechaalta` datetime DEFAULT CURRENT_TIMESTAMP,
  `cliente` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idestado` int DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tclubes`
--

DROP TABLE IF EXISTS `tclubes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tclubes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idprovincia` int NOT NULL,
  `idlocalidad` int NOT NULL,
  `idcampo` int DEFAULT '1',
  `club` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `codigo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `cif` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `cpostal` int DEFAULT NULL,
  `domicilio` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `escudo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `web` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `ncorto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `validado` int DEFAULT '0',
  `asociado` int DEFAULT '0',
  `primeraeq` int DEFAULT '21',
  `segundaeq` int DEFAULT '20',
  `terceraeq` int DEFAULT '7',
  `primeraeqpor` int DEFAULT '29',
  `segundaeqpor` int DEFAULT '30',
  `terceraeqpor` int DEFAULT '28',
  PRIMARY KEY (`id`),
  KEY `idx_id` (`id`),
  KEY `idx_tclubes_id` (`id`),
  KEY `idx_clubes_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=230 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcolores`
--

DROP TABLE IF EXISTS `tcolores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcolores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `color` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `codigo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tconfig`
--

DROP TABLE IF EXISTS `tconfig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tconfig` (
  `id` tinyint NOT NULL AUTO_INCREMENT,
  `idtemporada` int NOT NULL,
  `temporada` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `correoentrenos` int DEFAULT '1',
  `correopartidos` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tconfigcuotas`
--

DROP TABLE IF EXISTS `tconfigcuotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tconfigcuotas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `cantidad` double DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=264 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcontabilidad`
--

DROP TABLE IF EXISTS `tcontabilidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcontabilidad` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `familia` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT '',
  `concepto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ingreso` int DEFAULT '0',
  `gasto` int DEFAULT '0',
  `cantidad` double DEFAULT NULL,
  `idcuota` int DEFAULT '0',
  `idpagoper` int DEFAULT '0',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha` datetime DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `idestado` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18587 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcontrol_deuda_temporada`
--

DROP TABLE IF EXISTS `tcontrol_deuda_temporada`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcontrol_deuda_temporada` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int NOT NULL,
  `idjugador` int NOT NULL,
  `idtemporada` int NOT NULL,
  `total_temporada` decimal(10,2) NOT NULL DEFAULT '0.00',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_jugador_temporada` (`idclub`,`idjugador`,`idtemporada`),
  KEY `idx_club` (`idclub`),
  KEY `idx_jugador` (`idjugador`),
  KEY `idx_temporada` (`idtemporada`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tconvpartidos`
--

DROP TABLE IF EXISTS `tconvpartidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tconvpartidos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpartido` int DEFAULT NULL,
  `idjugador` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `convocado` int DEFAULT NULL,
  `idmotivo` int DEFAULT NULL,
  `titular` int DEFAULT '0',
  `minutos` int DEFAULT '0',
  `mentra` int DEFAULT '0',
  `asistencias` int DEFAULT '0',
  `goles` int DEFAULT '0',
  `golpp` int DEFAULT '0',
  `penalti` int DEFAULT '0',
  `tam` int DEFAULT '0',
  `tro` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `lavaropa` int DEFAULT '0',
  `valoracion` int DEFAULT '0',
  `finalizado` int DEFAULT '0',
  `capitan` int DEFAULT '0',
  `lesion` int DEFAULT '0',
  `visto` int DEFAULT '0',
  `jugando` int DEFAULT '0',
  `dorsal` int DEFAULT '0',
  `posX` double DEFAULT '0',
  `posY` double DEFAULT '0',
  `posAlineacion` int DEFAULT '0',
  `posXCambio` double DEFAULT '0',
  `posYCambio` double DEFAULT '0',
  `posAlineacionCambio` int DEFAULT '0',
  `estado` int DEFAULT '0',
  `pfScore` int DEFAULT '0',
  `valjugador` int DEFAULT '0',
  `valcoordinador` int DEFAULT '0',
  `nodisponible` int DEFAULT '0',
  `perdidas` tinyint unsigned DEFAULT '0' COMMENT 'Pérdidas de balón',
  `recuperaciones` tinyint unsigned DEFAULT '0' COMMENT 'Recuperaciones de balón',
  `fjuego` tinyint unsigned DEFAULT '0' COMMENT 'Faltas de juego',
  `faltacom` tinyint unsigned DEFAULT '0' COMMENT 'Faltas cometidas',
  `faltarec` tinyint unsigned DEFAULT '0' COMMENT 'Faltas recibidas',
  `tiroap` tinyint unsigned DEFAULT '0' COMMENT 'Tiros a puerta',
  `tirofuera` tinyint unsigned DEFAULT '0' COMMENT 'Tiros fuera',
  `paradas` tinyint unsigned DEFAULT '0' COMMENT 'Paradas (portero)',
  `despejes` tinyint unsigned DEFAULT '0' COMMENT 'Despejes (portero)',
  `salidas` tinyint unsigned DEFAULT '0' COMMENT 'Salidas del área (portero)',
  `fallos` tinyint unsigned DEFAULT '0' COMMENT 'Fallos/Errores (portero)',
  PRIMARY KEY (`id`),
  KEY `fkpartido_idx` (`idpartido`),
  KEY `fkjugador_idx` (`idjugador`),
  KEY `fkclub_idx` (`idclub`),
  KEY `fkconvtemporada_idx` (`idtemporada`),
  KEY `fkconvequipo_idx` (`idequipo`),
  KEY `idx_partido_jugador` (`idpartido`,`idjugador`),
  KEY `idx_conv_partido_convocado` (`idpartido`,`convocado`,`idjugador`),
  KEY `idx_conv_partido_titular` (`idpartido`,`titular`,`idjugador`),
  CONSTRAINT `fk_tconv_jugador` FOREIGN KEY (`idjugador`) REFERENCES `tjugadores` (`id`),
  CONSTRAINT `fkconvtemporada` FOREIGN KEY (`idtemporada`) REFERENCES `ttemporadas` (`id`),
  CONSTRAINT `fkpartido` FOREIGN KEY (`idpartido`) REFERENCES `tpartidos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=225183 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tconvpartidos_AFTER_UPDATE` AFTER UPDATE ON `tconvpartidos` FOR EACH ROW BEGIN
  DECLARE tarAma, tarAma2 INT;
  DECLARE minjug, trN, taN, ta2N, golN, golppN, asisN, pjN, ptN, pLe, penal INT;
  DECLARE perdN, recN, fjN, fcomN, frecN, tapN, tfuN, parN, despN, salN, fallN INT;
  DECLARE tarAmSancion INT;
  DECLARE nuevoPFScore INT;
  DECLARE anteriorPFScore INT;
  DECLARE nuevaEvol INT;

  -- Calcular tarjetas amarillas simples o dobles
  IF NEW.tam = 2 THEN 
    SET tarAma2 = 1;
    SET tarAma = 1;
  ELSE 
    SET tarAma = NEW.tam;
    SET tarAma2 = 0;
  END IF;

  -- Solo ejecutar si el partido está finalizado y sin valoración aún
  IF NEW.finalizado = 1 AND NEW.valoracion = 0 THEN 
    SELECT 
      minutos, ta, ta2, tr, goles, golpp, asistencias, pj, ptitular, plesionado, penalti, pfScore,
      perdidas, recuperaciones, fjuego, faltacom, faltarec,
      tiroap, tirofuera, paradas, despejes, salidas, fallos
    INTO 
      minjug, taN, ta2N, trN, golN, golppN, asisN, pjN, ptN, pLe, penal, anteriorPFScore,
      perdN, recN, fjN, fcomN, frecN, tapN, tfuN, parN, despN, salN, fallN
    FROM testadisticasjugador
    WHERE idjugador = NEW.idjugador AND idtemporada = NEW.idtemporada;

    -- Actualizar estadísticas acumuladas de temporada
    UPDATE testadisticasjugador SET 
      pj = pjN + NEW.convocado,
      ptitular = ptN + NEW.titular,
      plesionado = pLe + NEW.lesion,
      goles = golN + NEW.goles,
      golpp = golppN + NEW.golpp,
      asistencias = asisN + NEW.asistencias,
      minutos = minjug + NEW.minutos,
      tr = trN + NEW.tro,
      ta = taN + tarAma,
      ta2 = ta2N + tarAma2,
      penalti = penal + NEW.penalti,
      perdidas = perdN + NEW.perdidas,
      recuperaciones = recN + NEW.recuperaciones,
      fjuego = fjN + NEW.fjuego,
      faltacom = fcomN + NEW.faltacom,
      faltarec = frecN + NEW.faltarec,
      tiroap = tapN + NEW.tiroap,
      tirofuera = tfuN + NEW.tirofuera,
      paradas = parN + NEW.paradas,
      despejes = despN + NEW.despejes,
      salidas = salN + NEW.salidas,
      fallos = fallN + NEW.fallos
    WHERE idjugador = NEW.idjugador AND visible = 1 AND idtemporada = NEW.idtemporada;    

    -- Calcular evolución del PFScore
    SET nuevoPFScore = NEW.pfScore;
    IF nuevoPFScore > anteriorPFScore THEN
      SET nuevaEvol = 1;
    ELSEIF nuevoPFScore < anteriorPFScore THEN
      SET nuevaEvol = 2;
    ELSE
      SET nuevaEvol = 0;
    END IF;   

    -- Sanciones por acumulación de amarillas
    SET tarAmSancion = taN + tarAma;
    IF (tarAmSancion IN (5, 10, 15, 20)) AND tarAma = 1 THEN
      UPDATE tjugadores 
      SET idestado = 3 
      WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
    END IF;

    -- Roja directa => sanción
    IF NEW.tro = 1 THEN
      UPDATE tjugadores 
      SET idestado = 3 
      WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
    END IF;

    -- Quitar estado convocado al finalizar partido
    UPDATE tjugadores 
    SET convocado = 0 
    WHERE id = NEW.idjugador AND idtemporada = NEW.idtemporada;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tconvpartidos_BEFORE_DELETE` BEFORE DELETE ON `tconvpartidos` FOR EACH ROW BEGIN
	UPDATE tjugadores SET convocado= 0 WHERE id = old.idjugador and idtemporada= old.idtemporada;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tconvpartidos_AFTER_DELETE` AFTER DELETE ON `tconvpartidos` FOR EACH ROW BEGIN
  DECLARE tarAma, tarAma2 INT;
  DECLARE minjug, trN, taN, ta2N, golN, golppN, asisN, pjN, ptN, pLe, val, penal INT;
  DECLARE perdN, recN, fjN, fcomN, frecN, tapN, tfuN, parN, despN, salN, fallN INT;

  -- Determinar tipo de amarilla (simple o doble)
  IF OLD.tam = 2 THEN 
    SET tarAma2 = 1;
    SET tarAma = 1;
  ELSE 
    SET tarAma = OLD.tam;
    SET tarAma2 = 0;
  END IF;

  -- Solo si el partido eliminado estaba finalizado
  IF OLD.finalizado = 1 THEN 
    SELECT 
      minutos, ta, ta2, tr, goles, golpp, asistencias, pj, ptitular, plesionado, valoracion, penalti,
      perdidas, recuperaciones, fjuego, faltacom, faltarec,
      tiroap, tirofuera, paradas, despejes, salidas, fallos
    INTO 
      minjug, taN, ta2N, trN, golN, golppN, asisN, pjN, ptN, pLe, val, penal,
      perdN, recN, fjN, fcomN, frecN, tapN, tfuN, parN, despN, salN, fallN
    FROM testadisticasjugador 
    WHERE idjugador = OLD.idjugador AND idtemporada = OLD.idtemporada;

    -- Restar estadísticas del partido eliminado
    UPDATE testadisticasjugador SET 
      pj = pjN - OLD.convocado,
      ptitular = ptN - OLD.titular,
      plesionado = pLe - OLD.lesion,
      goles = golN - OLD.goles,
      golpp = golppN - OLD.golpp,
      asistencias = asisN - OLD.asistencias,            
      minutos = minjug - OLD.minutos,
      tr = trN - OLD.tro,
      ta = taN - tarAma,
      ta2 = ta2N - tarAma2,
      valoracion = val - OLD.valoracion,
      penalti = penal - OLD.penalti,
      perdidas = perdN - OLD.perdidas,
      recuperaciones = recN - OLD.recuperaciones,
      fjuego = fjN - OLD.fjuego,
      faltacom = fcomN - OLD.faltacom,
      faltarec = frecN - OLD.faltarec,
      tiroap = tapN - OLD.tiroap,
      tirofuera = tfuN - OLD.tirofuera,
      paradas = parN - OLD.paradas,
      despejes = despN - OLD.despejes,
      salidas = salN - OLD.salidas,
      fallos = fallN - OLD.fallos
    WHERE idjugador = OLD.idjugador AND visible = 1 AND idtemporada = OLD.idtemporada;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tctecnico`
--

DROP TABLE IF EXISTS `tctecnico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tctecnico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `apodo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `edad` int DEFAULT '0',
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `puesto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `equipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tcuotas`
--

DROP TABLE IF EXISTS `tcuotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcuotas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idjugador` int DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `mes` int DEFAULT NULL,
  `year` int DEFAULT NULL,
  `idestado` int DEFAULT NULL,
  `cantidad` double DEFAULT NULL,
  `idtipocuota` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17901 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tdispositivos`
--

DROP TABLE IF EXISTS `tdispositivos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tdispositivos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idusuario` int DEFAULT NULL,
  `deviceid` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tokenfcm` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tdivision`
--

DROP TABLE IF EXISTS `tdivision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tdivision` (
  `id` int NOT NULL AUTO_INCREMENT,
  `division` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tejercicios`
--

DROP TABLE IF EXISTS `tejercicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tejercicios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `familia` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `club` int DEFAULT '186',
  `tipo` int DEFAULT '0',
  `url` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fechasubida` datetime DEFAULT CURRENT_TIMESTAMP,
  `autor` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temails`
--

DROP TABLE IF EXISTS `temails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temails` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idusuario` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `asunto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `mensaje` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `leido` int DEFAULT '0',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `timestampleido` datetime DEFAULT CURRENT_TIMESTAMP,
  `idremitente` int DEFAULT '0',
  `registro` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_temails_idusuario_leido` (`idusuario`,`leido`),
  KEY `idx_temails_idremitente` (`idremitente`)
) ENGINE=InnoDB AUTO_INCREMENT=183377 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tentradasScan`
--

DROP TABLE IF EXISTS `tentradasScan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentradasScan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date DEFAULT NULL,
  `hora` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `entrasale` int DEFAULT '0',
  `idcarnet` int DEFAULT '0',
  `idclub` int DEFAULT '0',
  `nsocio` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=320 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tentrenamiento_archivos`
--

DROP TABLE IF EXISTS `tentrenamiento_archivos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentrenamiento_archivos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identrenamiento` int NOT NULL,
  `urlarchivo` varchar(255) COLLATE latin1_spanish_ci NOT NULL,
  `tipo` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `nombreoriginal` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fechasubida` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_tentrenamientos` (`identrenamiento`),
  CONSTRAINT `fk_tentrenamientos` FOREIGN KEY (`identrenamiento`) REFERENCES `tentrenamientos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tentrenamientos`
--

DROP TABLE IF EXISTS `tentrenamientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentrenamientos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idtemporada` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idlugar` int DEFAULT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fecha` date DEFAULT NULL,
  `hinicio` tinytext CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `hfin` tinytext CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `finalizado` int DEFAULT NULL,
  `notificado` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsentrenador` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `informe` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idsesion` int DEFAULT '0',
  `tlimite` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fkidtemporada_idx` (`idtemporada`),
  KEY `fkidclub_idx` (`idclub`),
  KEY `fkidequipo_idx` (`idequipo`),
  KEY `fkidlugar_idx` (`idlugar`),
  KEY `idx_temporada_club_equipo` (`idtemporada`,`idclub`,`idequipo`),
  KEY `idx_entrenamientos_temp_club_equipo_fecha` (`idtemporada`,`idclub`,`idequipo`,`fecha`),
  KEY `idx_temporada_fecha` (`idtemporada`,`fecha` DESC),
  KEY `idx_temporada_fecha_desc` (`idtemporada`,`fecha` DESC),
  KEY `idx_tte_idtemporada` (`idtemporada`),
  KEY `idx_entrenamientos_idequipo_fecha` (`idequipo`,`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=26706 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tentrenamientos_AFTER_INSERT` AFTER INSERT ON `tentrenamientos` FOR EACH ROW BEGIN
  -- Insertar jugadores
  INSERT INTO tentrenojugador(idjugador, identrenamiento, idequipo, idclub, asiste, motivo, observaciones, tlimite)
  SELECT id, NEW.id, NEW.idequipo, NEW.idclub, 0, 0, '', NEW.tlimite
  FROM tjugadores
  WHERE idequipo = NEW.idequipo 
    AND activo = 1;

  -- Insertar entrenadores (tipo 2 y tipo 12)
  INSERT INTO tentrenoct (identrenador, identrenamiento, idequipo, idclub, asiste, motivo, observaciones)
  SELECT id, NEW.id, NEW.idequipo, NEW.idclub, 0, 0, ''
  FROM troles
  WHERE idequipo = NEW.idequipo 
    AND tipo IN (2, 12);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tentrenoct`
--

DROP TABLE IF EXISTS `tentrenoct`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentrenoct` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identrenador` int DEFAULT NULL,
  `identrenamiento` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `asiste` int NOT NULL,
  `motivo` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60609 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tentrenojugador`
--

DROP TABLE IF EXISTS `tentrenojugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentrenojugador` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idjugador` int NOT NULL,
  `identrenamiento` int NOT NULL,
  `idequipo` smallint unsigned NOT NULL,
  `idclub` smallint unsigned NOT NULL,
  `asiste` tinyint unsigned NOT NULL,
  `confirmado` tinyint unsigned DEFAULT '0',
  `confirmadotutor` tinyint unsigned DEFAULT '0',
  `confirmadoentrenador` tinyint unsigned DEFAULT '0',
  `motivo` tinyint unsigned DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `visto` tinyint unsigned DEFAULT '0',
  `mensaje` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `rpe` tinyint unsigned DEFAULT '1',
  `tlimite` smallint unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_jugador_entrenamiento` (`idjugador`,`identrenamiento`),
  KEY `idx_entrenamiento_equipo_club` (`identrenamiento`,`idequipo`,`idclub`),
  KEY `idx_tj_motivo` (`motivo`),
  CONSTRAINT `fkentrenamiento` FOREIGN KEY (`identrenamiento`) REFERENCES `tentrenamientos` (`id`),
  CONSTRAINT `fkjugador` FOREIGN KEY (`idjugador`) REFERENCES `tjugadores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=702181 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tequipos`
--

DROP TABLE IF EXISTS `tequipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tequipos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int NOT NULL,
  `idcategoria` int NOT NULL,
  `idtemporada` int NOT NULL,
  `equipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `ncorto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `titulares` int DEFAULT '0',
  `minutos` int DEFAULT '0',
  `informe` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `informejugadores` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `informeestadisticas` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `informeestadisticasjug` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `sistema` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `camiseta` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_equipo_categoria_idx` (`idcategoria`),
  KEY `fk_equipo_temporada_idx` (`idtemporada`),
  KEY `fk_equipo_club_idx` (`idclub`),
  KEY `idx_id` (`id`),
  KEY `idx_tequipos_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1101 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `terrores`
--

DROP TABLE IF EXISTS `terrores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `terrores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pantalla` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `descripcion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idusuario` int DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `resuelto` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tescudos`
--

DROP TABLE IF EXISTS `tescudos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tescudos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `equipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `url` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadios`
--

DROP TABLE IF EXISTS `testadios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadios` (
  `id` int NOT NULL,
  `campo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `direccion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `cesped` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idprovincia` int DEFAULT NULL,
  `idlocalidad` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `posX` double DEFAULT NULL,
  `posY` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadisticasjugador`
--

DROP TABLE IF EXISTS `testadisticasjugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadisticasjugador` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT '0',
  `idequipo` int DEFAULT '0',
  `idjugador` int NOT NULL,
  `idtemporada` int NOT NULL,
  `pj` int NOT NULL DEFAULT '0',
  `ptitular` int NOT NULL DEFAULT '0',
  `plesionado` int NOT NULL DEFAULT '0',
  `asistencias` int NOT NULL DEFAULT '0',
  `goles` int NOT NULL DEFAULT '0',
  `golpp` int NOT NULL DEFAULT '0',
  `ta` int NOT NULL DEFAULT '0',
  `ta2` int NOT NULL DEFAULT '0',
  `tr` int NOT NULL DEFAULT '0',
  `minutos` int DEFAULT '0',
  `valoracion` int DEFAULT '0',
  `capitan` int DEFAULT '0',
  `penalti` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obspadre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `visible` int DEFAULT '1',
  `pfScore` int DEFAULT '82',
  `evolucion` int DEFAULT '0',
  `valcoordinador` int DEFAULT '0',
  `lavaropa` int DEFAULT '0',
  `perdidas` smallint unsigned DEFAULT '0' COMMENT 'Total pérdidas temporada',
  `recuperaciones` smallint unsigned DEFAULT '0' COMMENT 'Total recuperaciones temporada',
  `paradas` smallint unsigned DEFAULT '0' COMMENT 'Total paradas temporada (portero)',
  `despejes` smallint unsigned DEFAULT '0' COMMENT 'Total despejes temporada (portero)',
  `salidas` smallint unsigned DEFAULT '0' COMMENT 'Total salidas temporada (portero)',
  `fallos` smallint unsigned DEFAULT '0' COMMENT 'Total fallos temporada (portero)',
  `fjuego` tinyint unsigned DEFAULT '0' COMMENT 'Faltas de juego',
  `faltacom` tinyint unsigned DEFAULT '0' COMMENT 'Faltas cometidas',
  `faltarec` tinyint unsigned DEFAULT '0' COMMENT 'Faltas recibidas',
  `tiroap` tinyint unsigned DEFAULT '0' COMMENT 'Tiros a puerta',
  `tirofuera` tinyint unsigned DEFAULT '0' COMMENT 'Tiros fuera',
  PRIMARY KEY (`id`),
  KEY `idx_jugador` (`idjugador`),
  KEY `idx_visible_jugador_temp` (`visible`,`idjugador`,`idtemporada`),
  KEY `idx_jugador_visible_temp` (`idjugador`,`visible`,`idtemporada`),
  KEY `idx_testadisticasjugador_visible_idjugador_idtemporada` (`visible`,`idjugador`,`idtemporada` DESC),
  KEY `idx_stats_jugador_temp` (`idjugador`,`idtemporada`),
  KEY `idx_stats_equipo_temp` (`idequipo`,`idtemporada`),
  KEY `idx_stats_jugador_temp_visible` (`idjugador`,`idtemporada`,`visible`),
  KEY `idx_estadisticas_jugador_temp_visible` (`idjugador`,`idtemporada`,`visible`),
  KEY `idx_estadisticas_club_temp_visible` (`idclub`,`idtemporada`,`visible`),
  KEY `idx_jugador_temp_visible` (`idjugador`,`idtemporada`,`visible`)
) ENGINE=InnoDB AUTO_INCREMENT=15386 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadisticasjugadorJunio2023`
--

DROP TABLE IF EXISTS `testadisticasjugadorJunio2023`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadisticasjugadorJunio2023` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT '0',
  `idequipo` int DEFAULT '0',
  `idjugador` int NOT NULL,
  `idtemporada` int NOT NULL,
  `pj` int NOT NULL DEFAULT '0',
  `ptitular` int NOT NULL DEFAULT '0',
  `plesionado` int NOT NULL DEFAULT '0',
  `goles` int NOT NULL DEFAULT '0',
  `ta` int NOT NULL DEFAULT '0',
  `ta2` int NOT NULL DEFAULT '0',
  `tr` int NOT NULL DEFAULT '0',
  `minutos` int DEFAULT '0',
  `valoracion` int DEFAULT '0',
  `capitan` int DEFAULT '0',
  `penalti` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obspadre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `visible` int DEFAULT '1',
  `pfScore` int DEFAULT '82',
  `evolucion` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4478 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadisticasjugadorSep2022`
--

DROP TABLE IF EXISTS `testadisticasjugadorSep2022`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadisticasjugadorSep2022` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT '0',
  `idequipo` int DEFAULT '0',
  `idjugador` int NOT NULL,
  `idtemporada` int NOT NULL,
  `pj` int NOT NULL DEFAULT '0',
  `ptitular` int NOT NULL DEFAULT '0',
  `plesionado` int NOT NULL DEFAULT '0',
  `goles` int NOT NULL DEFAULT '0',
  `ta` int NOT NULL DEFAULT '0',
  `ta2` int NOT NULL DEFAULT '0',
  `tr` int NOT NULL DEFAULT '0',
  `minutos` int DEFAULT '0',
  `valoracion` int DEFAULT '0',
  `capitan` int DEFAULT '0',
  `penalti` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obspadre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `visible` int DEFAULT '1',
  `pfScore` int DEFAULT '82',
  `evolucion` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3960 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadisticaspartido`
--

DROP TABLE IF EXISTS `testadisticaspartido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadisticaspartido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpartido` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `faltaf` int DEFAULT '0',
  `faltac` int DEFAULT '0',
  `cornerf` int DEFAULT '0',
  `cornerc` int DEFAULT '0',
  `disparosf` int DEFAULT '0',
  `disparosc` int DEFAULT '0',
  `disparosfap` int DEFAULT '0',
  `disparoscap` int DEFAULT '0',
  `fjuegof` int DEFAULT '0',
  `fjuegoc` int DEFAULT '0',
  `perdidas` smallint unsigned DEFAULT '0' COMMENT 'Total pérdidas del equipo',
  `recuperaciones` smallint unsigned DEFAULT '0' COMMENT 'Total recuperaciones del equipo',
  `paradas` smallint unsigned DEFAULT '0' COMMENT 'Total paradas del portero',
  `despejes` smallint unsigned DEFAULT '0' COMMENT 'Total despejes del portero',
  `salidas` smallint unsigned DEFAULT '0' COMMENT 'Total salidas del portero',
  `fallos` smallint unsigned DEFAULT '0' COMMENT 'Total fallos del portero',
  `llegadasf` int DEFAULT '0' COMMENT 'Llegadas a favor',
  `llegadasc` int DEFAULT '0' COMMENT 'Llegadas en contra',
  `ocasionesf` int DEFAULT '0' COMMENT 'Ocasiones a favor',
  `ocasionesc` int DEFAULT '0' COMMENT 'Ocasiones en contra',
  PRIMARY KEY (`id`),
  KEY `fk_estadisticas_partido_idx` (`idpartido`),
  KEY `fk_estadisticas_club_idx` (`idclub`),
  KEY `fk_estadisticas_temporada_idx` (`idtemporada`),
  KEY `fk_estadisticasp_equipop_idx` (`idequipo`)
) ENGINE=InnoDB AUTO_INCREMENT=12458 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadisticaspartidoJunio2023`
--

DROP TABLE IF EXISTS `testadisticaspartidoJunio2023`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadisticaspartidoJunio2023` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpartido` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `faltaf` int DEFAULT '0',
  `faltac` int DEFAULT '0',
  `cornerf` int DEFAULT '0',
  `cornerc` int DEFAULT '0',
  `disparosf` int DEFAULT '0',
  `disparosc` int DEFAULT '0',
  `disparosfap` int DEFAULT '0',
  `disparoscap` int DEFAULT '0',
  `fjuegof` int DEFAULT '0',
  `fjuegoc` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_estadisticas_partido_idx` (`idpartido`),
  KEY `fk_estadisticas_club_idx` (`idclub`),
  KEY `fk_estadisticas_temporada_idx` (`idtemporada`),
  KEY `fk_estadisticasp_equipop_idx` (`idequipo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadocliente`
--

DROP TABLE IF EXISTS `testadocliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadocliente` (
  `id` int NOT NULL,
  `estado` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadocobro`
--

DROP TABLE IF EXISTS `testadocobro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadocobro` (
  `id` int NOT NULL AUTO_INCREMENT,
  `estado` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `icono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testadojugador`
--

DROP TABLE IF EXISTS `testadojugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testadojugador` (
  `id` int NOT NULL AUTO_INCREMENT,
  `estado` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testjugador`
--

DROP TABLE IF EXISTS `testjugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testjugador` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT '0',
  `idequipo` int DEFAULT '0',
  `idjugador` int NOT NULL,
  `idtemporada` int NOT NULL,
  `pj` int NOT NULL DEFAULT '0',
  `ptitular` int NOT NULL DEFAULT '0',
  `plesionado` int NOT NULL DEFAULT '0',
  `goles` int NOT NULL DEFAULT '0',
  `ta` int NOT NULL DEFAULT '0',
  `ta2` int NOT NULL DEFAULT '0',
  `tr` int NOT NULL DEFAULT '0',
  `minutos` int DEFAULT '0',
  `valoracion` int DEFAULT '0',
  `capitan` int DEFAULT '0',
  `penalti` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obspadre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `activo` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_est_jugadores_idx` (`idjugador`)
) ENGINE=InnoDB AUTO_INCREMENT=1202 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `teventospartido`
--

DROP TABLE IF EXISTS `teventospartido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teventospartido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpartido` int DEFAULT NULL,
  `idjugador` int DEFAULT NULL,
  `idtemporada` tinyint DEFAULT NULL,
  `tam` tinyint unsigned DEFAULT '0',
  `tamriv` tinyint unsigned DEFAULT '0',
  `tam2` tinyint unsigned DEFAULT '0',
  `tro` tinyint unsigned DEFAULT '0',
  `troriv` tinyint unsigned DEFAULT '0',
  `dorsal` tinyint unsigned DEFAULT '0',
  `gol` int DEFAULT '0',
  `asistencia` int DEFAULT '0',
  `golpropiopuerta` tinyint unsigned DEFAULT '0',
  `minuto` varchar(10) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `sale` tinyint unsigned DEFAULT '0',
  `entra` tinyint unsigned DEFAULT '0',
  `golencajado` tinyint unsigned DEFAULT '0',
  `min` int DEFAULT '0',
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `lesion` tinyint unsigned DEFAULT '0',
  `inicio` tinyint unsigned DEFAULT '0',
  `descanso` tinyint unsigned DEFAULT '0',
  `segundamitad` tinyint unsigned DEFAULT '0',
  `fin` tinyint unsigned DEFAULT '0',
  `penalti` int DEFAULT '0',
  `penaltiparado` tinyint unsigned DEFAULT '0',
  `penaltiparadocontra` tinyint unsigned DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`),
  KEY `idx_idpartido_min` (`idpartido`,`min`),
  KEY `idx_partido_min` (`idpartido`,`min`),
  KEY `idx_partido_jugador` (`idpartido`,`idjugador`)
) ENGINE=InnoDB AUTO_INCREMENT=300857 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `teventospartido_AFTER_INSERT` AFTER INSERT ON `teventospartido` FOR EACH ROW BEGIN
	DECLARE idEqJugador, casfue INT;
    DECLARE jugTA, minjug, minent, minexp INT; 
	
	IF NEW.gol = 1 THEN 
		IF NEW.penalti = 1 THEN 
			UPDATE tconvpartidos SET goles = goles + 1, penalti = penalti + 1 WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
			
			UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, goles = goles + 1 WHERE id = NEW.idpartido;
		ELSE
			UPDATE tconvpartidos SET goles = goles + 1 WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
			
			UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, goles = goles + 1 WHERE id = NEW.idpartido;
        END IF;
	END IF;
    IF NEW.asistencia = 1 THEN 		
		UPDATE tconvpartidos SET asistencias = asistencias + 1 WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;					
	END IF;
    IF NEW.golencajado = 1 THEN 
		UPDATE tconvpartidos SET goles = goles + 1 WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;		
        SELECT casafuera INTO casfue FROM tpartidos WHERE id = NEW.idpartido;
		IF NEW.idjugador <> 1 THEN
			UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min, golesrival = golesrival + 1 WHERE id = NEW.idpartido;
        END IF;        
	END IF;
    IF NEW.inicio = 1 THEN 
		UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
	END IF;
    IF NEW.descanso = 1 THEN 
		UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
	END IF;
    IF NEW.fin = 1 THEN 
		UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
	END IF;
    IF NEW.lesion = 1 THEN 
		UPDATE tconvpartidos SET lesion = 1 WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
	END IF;
    IF NEW.tam = 1 OR NEW.tam2 = 1 THEN
		SELECT tam INTO jugTA FROM tconvpartidos WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
        SELECT minutos, mentra INTO minjug, minent FROM tconvpartidos WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
        IF (jugTA = 0 ) THEN
			UPDATE tconvpartidos SET tam = tam + 1 WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
			
		ELSEIF (jugTA = 1) THEN
            UPDATE tconvpartidos SET 
                tam = tam + 1, 
                tro = tro + 1, 
                jugando = 0, 
                minutos = (NEW.min - minent) + minjug 
            WHERE idjugador = NEW.idjugador AND idpartido = NEW.idpartido;
            
        END IF;
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
	END IF;
    IF NEW.tro = 1 and NEW.tam2 = 0 THEN 
		SELECT minutos, mentra INTO minjug, minent FROM tconvpartidos WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
		UPDATE tconvpartidos SET tro = tro + 1, jugando = 0, minutos=(NEW.min - minent) + minjug WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
		
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
	END IF;
    IF NEW.sale = 1 THEN 
        SELECT minutos, mentra INTO minjug, minent FROM tconvpartidos WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
        UPDATE tpartidos SET minuto = NEW.minuto, min = NEW.min WHERE id = NEW.idpartido;
        
        UPDATE tconvpartidos SET jugando = 0, minutos=(NEW.min - minent) + minjug, mentra = NEW.min WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
	END IF;
    IF NEW.entra = 1 THEN 
        SELECT minutos, mentra INTO minjug, minent FROM tconvpartidos WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
        UPDATE tconvpartidos SET jugando = 1, mentra = NEW.min WHERE idjugador = NEW.idjugador and idpartido = NEW.idpartido;
	END IF;
    
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `teventospartido_AFTER_DELETE` AFTER DELETE ON `teventospartido` FOR EACH ROW BEGIN
	DECLARE idEqJugador, casfue INT;
    DECLARE jugTA, minjug, minent, minexp, jugTit INT;
	
	IF old.gol = 1 THEN 
		IF old.penalti = 1 THEN 
			UPDATE tconvpartidos SET goles = goles - 1, penalti = penalti - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
			UPDATE tpartidos SET  goles = goles - 1 WHERE id = old.idpartido;
		ELSE
			UPDATE tconvpartidos SET goles = goles - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
			UPDATE tpartidos SET  goles = goles - 1 WHERE id = old.idpartido;
		END IF;
	END IF;
    IF old.asistencia = 1 THEN 		
		UPDATE tconvpartidos SET asistencias = asistencias - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;		
	END IF;
    IF old.golencajado = 1 THEN 
		UPDATE tconvpartidos SET goles = goles - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
        SELECT casafuera INTO casfue FROM tpartidos WHERE id = old.idpartido;
		IF old.idjugador <> 1 THEN
			UPDATE tpartidos SET golesrival = golesrival - 1 WHERE id = old.idpartido;
        END IF; 
	END IF;
    IF old.tam = 1 THEN 
		SELECT tam, titular INTO jugTA, jugTit FROM tconvpartidos WHERE idjugador = old.idjugador and idpartido = old.idpartido;
        SELECT minutos, mentra INTO minjug, minent FROM tconvpartidos WHERE idjugador = old.idjugador and idpartido = old.idpartido;
        IF (jugTA = 1 ) THEN
			UPDATE tconvpartidos SET tam = tam - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
		ELSEIF (jugTA = 2) THEN
			UPDATE tconvpartidos SET tam = tam - 1, tro = tro - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
        END IF;
	END IF;
    IF old.tro = 1 and old.tam2 = 0 THEN 
		UPDATE tconvpartidos SET tro = tro - 1 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
	END IF;
    IF old.lesion = 1 THEN 
		UPDATE tconvpartidos SET lesion = 0 WHERE idjugador = old.idjugador and idpartido = old.idpartido;
        UPDATE tjugadores SET idestado = 1 WHERE id = old.idjugador;
        DELETE FROM tlesiones WHERE idjugador = old.idjugador and idpartido = old.idpartido;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tfamiliaejercicio`
--

DROP TABLE IF EXISTS `tfamiliaejercicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tfamiliaejercicio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `familia` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `imagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `vistaejercicio` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tfans`
--

DROP TABLE IF EXISTS `tfans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tfans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `uid` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `password` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `colores` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tgastos`
--

DROP TABLE IF EXISTS `tgastos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tgastos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `concepto` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `idclub` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tgestionescliente`
--

DROP TABLE IF EXISTS `tgestionescliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tgestionescliente` (
  `id` int NOT NULL AUTO_INCREMENT,
  `random` int DEFAULT NULL,
  `idcliente` int DEFAULT NULL,
  `fechagestion` datetime DEFAULT NULL,
  `gestion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `usuario` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tgrupos`
--

DROP TABLE IF EXISTS `tgrupos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tgrupos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `grupo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `ncorto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `timgmenu`
--

DROP TABLE IF EXISTS `timgmenu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timgmenu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `menu` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `imagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ruta` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tinformes`
--

DROP TABLE IF EXISTS `tinformes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tinformes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idusuario` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `tipo` int DEFAULT NULL,
  `informe` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urldocumento` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fechasubida` datetime DEFAULT CURRENT_TIMESTAMP,
  `idtemporada` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10778 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tingresos`
--

DROP TABLE IF EXISTS `tingresos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tingresos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `concepto` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `idclub` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tjornadas`
--

DROP TABLE IF EXISTS `tjornadas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tjornadas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idtemporada` int DEFAULT NULL,
  `jornada` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ncorto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tjugador`
--

DROP TABLE IF EXISTS `tjugador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tjugador` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idcategoria` int NOT NULL,
  `idclub` int NOT NULL,
  `idequipo` int NOT NULL,
  `idposicion` int NOT NULL,
  `idpiedominante` int NOT NULL,
  `idestado` int NOT NULL,
  `idtemporada` int DEFAULT '0',
  `idtutor1` int DEFAULT '0',
  `idtutor2` int DEFAULT '0',
  `idprovincia` int NOT NULL,
  `idlocalidad` int DEFAULT '0',
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apodo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `foto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `fechanacimiento` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `fechaalta` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `activo` int DEFAULT '1',
  `convocado` int DEFAULT '0',
  `conventreno` int DEFAULT '0',
  `peso` double DEFAULT NULL,
  `altura` int DEFAULT '0',
  `domicilio` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `dni` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `emailtutor1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `emailtutor2` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tutor1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tutor2` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `codigoactivacion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idtipocuota` int DEFAULT '0',
  `dorsal` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=963 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tjugador_AFTER_INSERT` AFTER INSERT ON `tjugador` FOR EACH ROW BEGIN
	INSERT INTO testjugador 
    (idclub, idequipo, idjugador, idtemporada, pj, ptitular, plesionado, goles, ta, ta2, tr, minutos, valoracion)
    VALUES 
    (NEW.idclub, NEW.idequipo, NEW.id, NEW.idtemporada , 0,0,0,0,0,0,0,0,0);
    
    IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
		IF NEW.emailtutor1 <> "null" THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, ROUND(rand()*1000000, 0) ,0, 1);
		END IF;
	END IF;
    IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
		IF NEW.emailtutor2 <> "null" THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, ROUND(rand()*1000000, 0) ,0, 2);
		END IF;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tjugador_AFTER_UPDATE` AFTER UPDATE ON `tjugador` FOR EACH ROW BEGIN
	IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
		IF (NEW.emailtutor1 <> "null" OR NEW.emailtutor1 = old.emailtutor1) THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, ROUND(rand()*1000000, 0) ,0, 1);
		END IF; 
	END IF; 
    IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
		IF (NEW.emailtutor2 <> "null" OR NEW.emailtutor2 = old.emailtutor2) THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, ROUND(rand()*1000000, 0) ,0, 2);
		END IF;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tjugadores`
--

DROP TABLE IF EXISTS `tjugadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tjugadores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idcategoria` int NOT NULL,
  `idclub` int NOT NULL,
  `idequipo` int NOT NULL,
  `idposicion` int NOT NULL,
  `idpiedominante` int NOT NULL,
  `idestado` int NOT NULL,
  `idtutor1` int DEFAULT '0',
  `idtutor2` int DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  `idprovincia` int NOT NULL,
  `idlocalidad` int DEFAULT '0',
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apodo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `foto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `fechanacimiento` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `fechaalta` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `activo` int DEFAULT '1',
  `convocado` int DEFAULT '0',
  `conventreno` int DEFAULT '0',
  `peso` double DEFAULT NULL,
  `altura` int DEFAULT '0',
  `domicilio` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `dni` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `emailtutor1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `emailtutor2` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tutor1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tutor2` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `codigoactivacion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idtipocuota` int DEFAULT '0',
  `dorsal` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obspadre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ficha` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `informe` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `recmedico` int DEFAULT '0',
  `fecharecmedico` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `nota` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`),
  KEY `idx_categoria` (`idcategoria`),
  KEY `idx_tjugadores_id` (`id`),
  KEY `idx_activo_categoria` (`activo`,`idcategoria`),
  KEY `idx_tjugadores_club_temp_activo` (`idclub`,`idtemporada`,`activo`) COMMENT 'Optimiza consultas por club, temporada y estado activo',
  KEY `idx_tjugadores_equipo_temp_activo` (`idequipo`,`idtemporada`,`activo`) COMMENT 'Optimiza consultas por equipo, temporada y estado activo',
  KEY `idx_jugadores_id` (`id`),
  KEY `idx_jugadores_idequipo_idtemporada` (`idequipo`,`idtemporada`),
  KEY `idx_jugadores_activo` (`activo`)
) ENGINE=InnoDB AUTO_INCREMENT=13117 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tjugadores_AFTER_INSERT` AFTER INSERT ON `tjugadores` FOR EACH ROW BEGIN
	INSERT INTO testadisticasjugador 
    (idclub, idequipo, idjugador, idtemporada, pj, ptitular, plesionado, goles, ta, ta2, tr, minutos, valoracion)
    VALUES 
    (NEW.idclub, NEW.idequipo, NEW.id, NEW.idtemporada , 0,0,0,0,0,0,0,0,0);
    
    IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
		IF NEW.emailtutor1 <> null or NEW.emailtutor1 <> "null" THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, ROUND(rand()*1000000, 0) ,0, 1);
		END IF;
	END IF;
    IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
		IF NEW.emailtutor2 <> "null" THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, ROUND(rand()*1000000, 0) ,0, 2);
		END IF;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tjugadores_AFTER_UPDATE` AFTER UPDATE ON `tjugadores` FOR EACH ROW BEGIN
	IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor1) THEN
		IF (NEW.emailtutor1 <> "null" OR NEW.emailtutor1 = old.emailtutor1) THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor1, ROUND(rand()*1000000, 0) ,0, 1);
		END IF; 
	END IF; 
    IF NOT EXISTS (SELECT * FROM tregpadres WHERE emaildestino = NEW.emailtutor2) THEN
		IF (NEW.emailtutor2 <> "null" OR NEW.emailtutor2 = old.emailtutor2) THEN 
			INSERT INTO tregpadres
			(idclub, idequipo, idjugador, emaildestino, codigoactivacion, estado, tutor)
			VALUES
			(NEW.idclub, NEW.idequipo, NEW.id, NEW.emailtutor2, ROUND(rand()*1000000, 0) ,0, 2);
		END IF;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tjugdestacados`
--

DROP TABLE IF EXISTS `tjugdestacados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tjugdestacados` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpartido` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `idclubdestaca` int DEFAULT NULL,
  `idusuario` int DEFAULT NULL,
  `rival` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `jugador` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `posicion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `dorsal` int DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `destacado` int DEFAULT '0',
  `informe` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tjugtemporada`
--

DROP TABLE IF EXISTS `tjugtemporada`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tjugtemporada` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idjugador` int DEFAULT NULL,
  `idclub` int NOT NULL,
  `idequipo` int NOT NULL,
  `idestado` int NOT NULL,
  `idtutor1` int DEFAULT '0',
  `idtutor2` int DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  `activo` int DEFAULT '1',
  `convocado` int DEFAULT '0',
  `conventreno` int DEFAULT '0',
  `emailtutor1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `emailtutor2` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tutor1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tutor2` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `codigoactivacion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idtipocuota` int DEFAULT '0',
  `dorsal` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obspadre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=959 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tlesiones`
--

DROP TABLE IF EXISTS `tlesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tlesiones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT '0',
  `idequipo` int DEFAULT '0',
  `idjugador` int DEFAULT NULL,
  `lesion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `observaciones` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fechainicio` date DEFAULT NULL,
  `fechafin` date DEFAULT NULL,
  `duracion` int DEFAULT '0',
  `idpartido` int DEFAULT '0',
  `identrenamiento` int DEFAULT '0',
  `idtemporada` int DEFAULT '5',
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2119 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tligas`
--

DROP TABLE IF EXISTS `tligas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tligas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competicion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `categoria` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `temporada` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `federacion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `delegacion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `division` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `grupo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tlocalidades`
--

DROP TABLE IF EXISTS `tlocalidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tlocalidades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `localidad` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `cpostal` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `idprovincia` int DEFAULT NULL,
  `provincia` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmateriales`
--

DROP TABLE IF EXISTS `tmateriales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tmateriales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `material` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmensajeria`
--

DROP TABLE IF EXISTS `tmensajeria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tmensajeria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identrenador` int DEFAULT NULL,
  `idtutor` int DEFAULT NULL,
  `idjugador` int DEFAULT NULL,
  `mensaje` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `leido` int DEFAULT NULL,
  `enventrenador` int DEFAULT NULL,
  `envtutor` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmenus`
--

DROP TABLE IF EXISTS `tmenus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tmenus` (
  `id` int NOT NULL,
  `idperfil` int DEFAULT NULL,
  `menu` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `asseturl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `widget` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ruta` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `asseturl1` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmotivoasistencia`
--

DROP TABLE IF EXISTS `tmotivoasistencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tmotivoasistencia` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idasistencia` int DEFAULT NULL,
  `motivo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`),
  KEY `idx_tmotivoasistencia_id` (`idasistencia`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmotivoconvocatoria`
--

DROP TABLE IF EXISTS `tmotivoconvocatoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tmotivoconvocatoria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idconvocatoria` int DEFAULT NULL,
  `motivo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tnoticias`
--

DROP TABLE IF EXISTS `tnoticias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tnoticias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `imagepath` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fecha` datetime DEFAULT NULL,
  `title` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `subtitle` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urllink` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `visible` int DEFAULT '0',
  `noticia` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tpadres`
--

DROP TABLE IF EXISTS `tpadres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpadres` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `uid` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `password` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `colores` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tpagopersonal`
--

DROP TABLE IF EXISTS `tpagopersonal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpagopersonal` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `iduser` int DEFAULT NULL,
  `concepto` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `tipo` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `importe` double DEFAULT NULL,
  `fecha` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tpartidos`
--

DROP TABLE IF EXISTS `tpartidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpartidos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idjornada` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `idcategoria` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idrival` int DEFAULT NULL,
  `rival` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `escudorival` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idlugar` int DEFAULT '1',
  `fecha` date DEFAULT NULL,
  `goles` int DEFAULT NULL,
  `golesrival` int DEFAULT NULL,
  `finalizado` int DEFAULT NULL,
  `primTiempo` int DEFAULT '0',
  `descanso` int DEFAULT '0',
  `directo` int DEFAULT '0',
  `minuto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `hora` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `horaconvocatoria` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `min` int DEFAULT '0',
  `casafuera` int DEFAULT '0',
  `veralineacion` int DEFAULT '0',
  `verConvocatoria` int DEFAULT '0',
  `color1L` varchar(10) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT '0xFF2196f3',
  `color2L` varchar(10) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT '0xFF000000',
  `color3L` varchar(10) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT '0xFFf44336',
  `color5L` varchar(10) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT '0xFFFFFFFF',
  `color4L` varchar(10) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT '0xFF000000',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsconvocatoria` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `informe` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `infconvocatoria` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `dispositivo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `arbitro` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `obsarbitro` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `cronica` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `previa` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `sistema` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `sistemafinal` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `camiseta` int DEFAULT '0',
  `camisetapor` int DEFAULT '0',
  `visto` int DEFAULT '0',
  `obscoordinador` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `alrival` int DEFAULT '0',
  `camisetarival` int DEFAULT '0',
  `sistemarival` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `minutosporparte` int DEFAULT '0',
  `numeropartes` int DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `crono_estado` varchar(20) COLLATE latin1_spanish_ci DEFAULT 'detenido' COMMENT 'Estado actual: detenido, corriendo, pausado, descanso, finalizado',
  `crono_timestamp_inicio` bigint DEFAULT NULL COMMENT 'Timestamp (ms) cuando se inició el cronómetro por primera vez',
  `crono_timestamp_ultima_accion` bigint DEFAULT NULL COMMENT 'Timestamp (ms) de la última acción (pausa/reanudación)',
  `crono_segundos_acumulados` int DEFAULT '0' COMMENT 'Segundos acumulados cuando está pausado (incluye tiempo antes de pausas)',
  `crono_segundos_descanso` int DEFAULT '0' COMMENT 'Segundos en descanso (separados del tiempo de juego)',
  PRIMARY KEY (`id`),
  KEY `fkjornada_idx` (`idjornada`),
  KEY `fktemporada_idx` (`idtemporada`),
  KEY `fkcategoria_idx` (`idcategoria`),
  KEY `idx_temporada_categoria_jornada` (`idtemporada`,`idcategoria`,`idjornada`),
  KEY `idx_partidos_temporada_fecha` (`idtemporada`,`fecha`),
  KEY `idx_idtemporada_fecha` (`idtemporada`,`fecha`),
  KEY `idx_tpartidos_temp_fecha` (`idtemporada`,`fecha`,`finalizado`),
  KEY `idx_tpartidos_updated` (`updated_at`),
  KEY `idx_tpartidos_equipo` (`idequipo`,`idtemporada`,`fecha`),
  KEY `idx_tpartidos_club` (`idclub`,`idtemporada`,`fecha`),
  KEY `idx_crono_estado` (`crono_estado`),
  KEY `idx_crono_timestamp` (`crono_timestamp_ultima_accion`),
  KEY `idx_partidos_idequipo_fecha` (`idequipo`,`fecha`),
  KEY `idx_partidos_idtemporada_fecha` (`idtemporada`,`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=11889 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tpartidos_AFTER_UPDATE` AFTER UPDATE ON `tpartidos` FOR EACH ROW BEGIN
    IF NEW.finalizado = 1 THEN 
        UPDATE tconvpartidos SET jugando = 0, finalizado= 1 WHERE idpartido = NEW.id and jugando=0;
        UPDATE tconvpartidos SET jugando = 0, finalizado= 1, minutos=(NEW.min - mentra) + minutos WHERE idpartido = NEW.id and jugando=1;
    END IF;
    IF NEW.goles = 0 and NEW.golesrival = 0 and NEW.finalizado = 0 and NEW.minuto = "00:00" and NEW.min = 0 THEN
		UPDATE tconvpartidos SET minutos = 0, mentra = 0, jugando=titular WHERE idpartido = NEW.id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`qanf664`@`%`*/ /*!50003 TRIGGER `tpartidos_BEFORE_DELETE` BEFORE DELETE ON `tpartidos` FOR EACH ROW BEGIN
	DELETE FROM tconvpartidos WHERE idpartido = old.id;
    DELETE FROM testadisticaspartido WHERE idpartido = old.id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tpautaentrenamiento`
--

DROP TABLE IF EXISTS `tpautaentrenamiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpautaentrenamiento` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idsesion` int DEFAULT '0',
  `idclub` int DEFAULT NULL,
  `idejercicio` int DEFAULT NULL,
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `tiempo` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tperfilesusuario`
--

DROP TABLE IF EXISTS `tperfilesusuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tperfilesusuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `musuarios` int DEFAULT NULL,
  `mjugadores` int DEFAULT NULL,
  `mclubes` int DEFAULT NULL,
  `mequipos` int DEFAULT NULL,
  `mentrenamientos` int DEFAULT NULL,
  `mpartidos` int DEFAULT NULL,
  `mligas` int DEFAULT NULL,
  `mconfiguracion` int DEFAULT NULL,
  `mresultados` int DEFAULT NULL,
  `mrankings` int DEFAULT NULL,
  `perfil` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `mjugador` int DEFAULT NULL,
  `mjugdestacado` int DEFAULT NULL,
  `minformes` int DEFAULT NULL,
  `descripcion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tpiedominante`
--

DROP TABLE IF EXISTS `tpiedominante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpiedominante` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pie` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tposdestacado`
--

DROP TABLE IF EXISTS `tposdestacado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tposdestacado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `posicion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `linea` int DEFAULT NULL,
  `ordenenlinea` int DEFAULT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tposiciones`
--

DROP TABLE IF EXISTS `tposiciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tposiciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `posicion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tprendas`
--

DROP TABLE IF EXISTS `tprendas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tprendas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  `descripcion` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `pvp` double DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tprovincias`
--

DROP TABLE IF EXISTS `tprovincias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tprovincias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idprovincia` int DEFAULT NULL,
  `provincia` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tpublicidad`
--

DROP TABLE IF EXISTS `tpublicidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpublicidad` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idequipo` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idanunciante` int DEFAULT NULL,
  `evento` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urlImagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `activo` int DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  `mensaje` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `posicion` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_temporada_activo_posicion` (`idtemporada`,`activo`,`posicion`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tpublicidad2020`
--

DROP TABLE IF EXISTS `tpublicidad2020`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpublicidad2020` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idequipo` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idanunciante` int DEFAULT NULL,
  `evento` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `urlImagen` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `activo` int DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  `mensaje` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trecibos_pagos`
--

DROP TABLE IF EXISTS `trecibos_pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trecibos_pagos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int NOT NULL,
  `idjugador` int NOT NULL,
  `idtemporada` int NOT NULL,
  `idcontrol_deuda` int DEFAULT NULL,
  `cantidad` decimal(10,2) NOT NULL DEFAULT '0.00',
  `fecha_pago` datetime NOT NULL,
  `concepto` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'Pago de cuota',
  `metodo_pago` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'EFECTIVO',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_club` (`idclub`),
  KEY `idx_jugador` (`idjugador`),
  KEY `idx_temporada` (`idtemporada`),
  KEY `idx_control_deuda` (`idcontrol_deuda`),
  KEY `idx_fecha_pago` (`fecha_pago`),
  CONSTRAINT `fk_recibos_control_deuda` FOREIGN KEY (`idcontrol_deuda`) REFERENCES `tcontrol_deuda_temporada` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tregpadres`
--

DROP TABLE IF EXISTS `tregpadres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tregpadres` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idjugador` int DEFAULT NULL,
  `emaildestino` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `codigoactivacion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `estado` int DEFAULT '0',
  `tutor` int DEFAULT '0',
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trivales`
--

DROP TABLE IF EXISTS `trivales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trivales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `club` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ncortoclub` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `equipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `ncorto` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `escudo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `troles`
--

DROP TABLE IF EXISTS `troles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `troles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo` int NOT NULL,
  `idusuario` int NOT NULL,
  `idtemporada` int NOT NULL,
  `uid` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `selectedrol` tinyint(1) NOT NULL,
  `idclub` int NOT NULL DEFAULT '0',
  `idequipo` int NOT NULL DEFAULT '0',
  `idjugador` int NOT NULL DEFAULT '0',
  `idjugador2` int NOT NULL DEFAULT '0',
  `idjugador3` int NOT NULL DEFAULT '0',
  `idjugador4` int NOT NULL DEFAULT '0',
  `idcarnet` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_tipo_idjugador` (`tipo`,`idjugador`),
  KEY `idx_roles_jugador_tipo` (`idjugador`,`tipo`),
  KEY `idx_troles_idusuario_selectedrol` (`idusuario`,`selectedrol`),
  KEY `idx_troles_idjugador_idequipo` (`idjugador`,`idequipo`)
) ENGINE=InnoDB AUTO_INCREMENT=7114 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trolpeticion`
--

DROP TABLE IF EXISTS `trolpeticion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trolpeticion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` datetime DEFAULT NULL,
  `uid` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `idusuario` int NOT NULL DEFAULT '0',
  `idtemporada` int NOT NULL DEFAULT '0',
  `tipo` int NOT NULL DEFAULT '16',
  `estado` int NOT NULL DEFAULT '0',
  `idclub` int NOT NULL DEFAULT '0',
  `idequipo` int NOT NULL DEFAULT '0',
  `idjugador` int NOT NULL DEFAULT '0',
  `comentario` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_estado` (`estado`),
  KEY `idx_idequipo` (`idequipo`),
  KEY `idx_idclub` (`idclub`),
  KEY `idx_estado_idequipo` (`estado`,`idequipo`)
) ENGINE=InnoDB AUTO_INCREMENT=3630 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tropa`
--

DROP TABLE IF EXISTS `tropa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tropa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idjugador` int DEFAULT '0',
  `idtemporada` int DEFAULT '0',
  `idclub` int DEFAULT '0',
  `idprenda` int DEFAULT '0',
  `pvp` double DEFAULT '0',
  `descuento` double DEFAULT '0',
  `acuenta` double DEFAULT '0',
  `entregado` int DEFAULT '0',
  `nombre` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `tipopago` int DEFAULT '0',
  `talla` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `fechaentrega` datetime DEFAULT NULL,
  `avisado` int DEFAULT '0',
  `devuelto` tinyint(1) DEFAULT '0' COMMENT 'Indica si la prenda fue devuelta (0=No, 1=Sí)',
  `fechadevolucion` datetime DEFAULT NULL COMMENT 'Fecha en que se realizó la devolución',
  PRIMARY KEY (`id`),
  KEY `idx_devuelto` (`devuelto`)
) ENGINE=InnoDB AUTO_INCREMENT=395 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsesionesentrenos`
--

DROP TABLE IF EXISTS `tsesionesentrenos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsesionesentrenos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int DEFAULT NULL,
  `sesion` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fecha` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsistemas`
--

DROP TABLE IF EXISTS `tsistemas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsistemas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sistema` varchar(45) DEFAULT NULL,
  `tipocampo` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsolicitudesinfo`
--

DROP TABLE IF EXISTS `tsolicitudesinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsolicitudesinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fechaalta` datetime DEFAULT CURRENT_TIMESTAMP,
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `club` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `estado` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsubmenus`
--

DROP TABLE IF EXISTS `tsubmenus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsubmenus` (
  `id` int NOT NULL,
  `idperfil` int DEFAULT NULL,
  `menu` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `submenu` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `asseturl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsuscripcion`
--

DROP TABLE IF EXISTS `tsuscripcion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsuscripcion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idusuario` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idjugador` int DEFAULT NULL,
  `idtemporada` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3925 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttallapeso`
--

DROP TABLE IF EXISTS `ttallapeso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttallapeso` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idjugador` int DEFAULT NULL,
  `peso` double DEFAULT NULL,
  `altura` int DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `difa` int DEFAULT '0',
  `difp` double DEFAULT '0',
  `imc` double DEFAULT '0',
  `pesoideal` double DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1954 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttelemetriapubli`
--

DROP TABLE IF EXISTS `ttelemetriapubli`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttelemetriapubli` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idpublicidad` int DEFAULT NULL,
  `idanunciante` int DEFAULT NULL,
  `visto` int DEFAULT NULL,
  `click` int DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `idperfil` int DEFAULT NULL,
  `idusuario` int DEFAULT NULL,
  `evento` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `idtemporada` int DEFAULT '3',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=665981 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttelepubli`
--

DROP TABLE IF EXISTS `ttelepubli`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttelepubli` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idanunciante` int DEFAULT '0',
  `totalimpre` int DEFAULT '0',
  `totalinter` int DEFAULT '0',
  `impre1` int DEFAULT '0',
  `inter1` int DEFAULT '0',
  `impre2` int DEFAULT '0',
  `inter2` int DEFAULT '0',
  `impre3` int DEFAULT '0',
  `inter3` int DEFAULT '0',
  `impre4` int DEFAULT '0',
  `inter4` int DEFAULT '0',
  `impre5` int DEFAULT '0',
  `inter5` int DEFAULT '0',
  `impre6` int DEFAULT '0',
  `inter6` int DEFAULT '0',
  `impre7` int DEFAULT '0',
  `inter7` int DEFAULT '0',
  `impre8` int DEFAULT '0',
  `inter8` int DEFAULT '0',
  `impre9` int DEFAULT '0',
  `inter9` int DEFAULT '0',
  `impre10` int DEFAULT '0',
  `inter10` int DEFAULT '0',
  `impre11` int DEFAULT '0',
  `inter11` int DEFAULT '0',
  `impre12` int DEFAULT '0',
  `inter12` int DEFAULT '0',
  `ctr` double DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttemporadas`
--

DROP TABLE IF EXISTS `ttemporadas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttemporadas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idtemporada` int DEFAULT NULL,
  `temporada` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_id` (`id`),
  KEY `idx_ttemporadas_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttextoslegales`
--

DROP TABLE IF EXISTS `ttextoslegales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttextoslegales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `titulo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `valor` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttipocategoria`
--

DROP TABLE IF EXISTS `ttipocategoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttipocategoria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `jugadores` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttiporol`
--

DROP TABLE IF EXISTS `ttiporol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttiporol` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo` int DEFAULT NULL,
  `name` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `title` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `description` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ttopic`
--

DROP TABLE IF EXISTS `ttopic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ttopic` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idusuario` int DEFAULT NULL,
  `topic` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `fecha` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47503 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tusuarios`
--

DROP TABLE IF EXISTS `tusuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tusuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int NOT NULL,
  `idequipo` int NOT NULL DEFAULT '0',
  `idtemporada` int DEFAULT NULL,
  `uid` text CHARACTER SET big5 COLLATE big5_chinese_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `dni` varchar(20) COLLATE latin1_spanish_ci DEFAULT NULL,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `user` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `password` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `permisos` int NOT NULL DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `col1` int NOT NULL DEFAULT '1',
  `col2` int DEFAULT '1',
  `col3` int DEFAULT '1',
  `estadentro` int DEFAULT '0',
  `conhijos` int DEFAULT '0',
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `notificar` int DEFAULT '1',
  `dorsal` int DEFAULT '0',
  `idjugador` int DEFAULT '0',
  `estadisticas` int DEFAULT '1',
  `entrenamientos` int DEFAULT '1',
  `partidos` int DEFAULT '1',
  `tallapeso` int DEFAULT '1',
  `lesiones` int DEFAULT '1',
  `cuotas` int DEFAULT '0',
  `valoracion` double DEFAULT '0',
  `valpartidos` double DEFAULT '0',
  `valentrenos` double DEFAULT '0',
  `firmaproteccion` int DEFAULT '0',
  `idempresa` int DEFAULT '0',
  `hacerfotos` int DEFAULT '1',
  `clubcompleto` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_jugador` (`idjugador`),
  KEY `idx_usuario_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3263 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tusuariosJunio2023`
--

DROP TABLE IF EXISTS `tusuariosJunio2023`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tusuariosJunio2023` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idclub` int NOT NULL,
  `idequipo` int NOT NULL DEFAULT '0',
  `idtemporada` int DEFAULT NULL,
  `uid` text CHARACTER SET big5 COLLATE big5_chinese_ci,
  `email` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `nombre` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` text CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `telefono` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `photourl` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `user` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `password` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `permisos` int NOT NULL DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  `col1` int NOT NULL DEFAULT '1',
  `col2` int DEFAULT '1',
  `col3` int DEFAULT '1',
  `estadentro` int DEFAULT '0',
  `conhijos` int DEFAULT '0',
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `notificar` int DEFAULT '1',
  `dorsal` int DEFAULT '0',
  `idjugador` int DEFAULT '0',
  `estadisticas` int DEFAULT '1',
  `entrenamientos` int DEFAULT '1',
  `partidos` int DEFAULT '1',
  `tallapeso` int DEFAULT '1',
  `lesiones` int DEFAULT '1',
  `cuotas` int DEFAULT '0',
  `valoracion` double DEFAULT '0',
  `valpartidos` double DEFAULT '0',
  `valentrenos` double DEFAULT '0',
  `firmaproteccion` int DEFAULT '0',
  `idempresa` int DEFAULT '0',
  `hacerfotos` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2591 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tvalentrenadores`
--

DROP TABLE IF EXISTS `tvalentrenadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tvalentrenadores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `identrenador` int DEFAULT NULL,
  `idclub` int DEFAULT NULL,
  `idequipo` int DEFAULT NULL,
  `idpartido` int DEFAULT NULL,
  `identrenamiento` int DEFAULT NULL,
  `valoracion` int DEFAULT '0',
  `observaciones` text CHARACTER SET latin1 COLLATE latin1_spanish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `vContabilidad`
--

DROP TABLE IF EXISTS `vContabilidad`;
/*!50001 DROP VIEW IF EXISTS `vContabilidad`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vContabilidad` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `familia`,
 1 AS `concepto`,
 1 AS `ingreso`,
 1 AS `gasto`,
 1 AS `cantidad`,
 1 AS `equipo`,
 1 AS `timestamp`,
 1 AS `fecha`,
 1 AS `idtemporada`,
 1 AS `temporada`,
 1 AS `idcuota`,
 1 AS `idpagoper`,
 1 AS `idestado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vCuotas`
--

DROP TABLE IF EXISTS `vCuotas`;
/*!50001 DROP VIEW IF EXISTS `vCuotas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vCuotas` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `equipo`,
 1 AS `idjugador`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `timestamp`,
 1 AS `mes`,
 1 AS `year`,
 1 AS `idestado`,
 1 AS `idtemporada`,
 1 AS `temporada`,
 1 AS `estado`,
 1 AS `cantidad`,
 1 AS `idtipocuota`,
 1 AS `tipo`,
 1 AS `icono`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vPdfPartido1`
--

DROP TABLE IF EXISTS `vPdfPartido1`;
/*!50001 DROP VIEW IF EXISTS `vPdfPartido1`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vPdfPartido1` AS SELECT 
 1 AS `id`,
 1 AS `idpartido`,
 1 AS `idjugador`,
 1 AS `idtemporada`,
 1 AS `enventoPartido`,
 1 AS `minuto`,
 1 AS `min`,
 1 AS `foto`,
 1 AS `apodo`,
 1 AS `activo`,
 1 AS `club`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vTelemPlayFutbol`
--

DROP TABLE IF EXISTS `vTelemPlayFutbol`;
/*!50001 DROP VIEW IF EXISTS `vTelemPlayFutbol`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vTelemPlayFutbol` AS SELECT 
 1 AS `anunciantes`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vTelemPorAnunciante`
--

DROP TABLE IF EXISTS `vTelemPorAnunciante`;
/*!50001 DROP VIEW IF EXISTS `vTelemPorAnunciante`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vTelemPorAnunciante` AS SELECT 
 1 AS `idanunciante`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`,
 1 AS `idtemporada`,
 1 AS `idequipo`,
 1 AS `imagen`,
 1 AS `equipo`,
 1 AS `idclub`,
 1 AS `club`,
 1 AS `anunciante`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vTelemPorAnuncianteNueva`
--

DROP TABLE IF EXISTS `vTelemPorAnuncianteNueva`;
/*!50001 DROP VIEW IF EXISTS `vTelemPorAnuncianteNueva`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vTelemPorAnuncianteNueva` AS SELECT 
 1 AS `idanunciante`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vTelemPubli`
--

DROP TABLE IF EXISTS `vTelemPubli`;
/*!50001 DROP VIEW IF EXISTS `vTelemPubli`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vTelemPubli` AS SELECT 
 1 AS `id`,
 1 AS `idpublicidad`,
 1 AS `idanunciante`,
 1 AS `visto`,
 1 AS `click`,
 1 AS `fecha`,
 1 AS `idperfil`,
 1 AS `perfil`,
 1 AS `idusuario`,
 1 AS `evento`,
 1 AS `idequipo`,
 1 AS `imagen`,
 1 AS `equipo`,
 1 AS `idclub`,
 1 AS `club`,
 1 AS `nombre`,
 1 AS `direccion`,
 1 AS `cif`,
 1 AS `email`,
 1 AS `web`,
 1 AS `telefono`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vanalisis_jugadores_temporada_21_22`
--

DROP TABLE IF EXISTS `vanalisis_jugadores_temporada_21_22`;
/*!50001 DROP VIEW IF EXISTS `vanalisis_jugadores_temporada_21_22`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vanalisis_jugadores_temporada_21_22` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `obsclub`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vanuncios`
--

DROP TABLE IF EXISTS `vanuncios`;
/*!50001 DROP VIEW IF EXISTS `vanuncios`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vanuncios` AS SELECT 
 1 AS `id`,
 1 AS `idsponsor`,
 1 AS `sponsor`,
 1 AS `idclub`,
 1 AS `club`,
 1 AS `evento`,
 1 AS `urlImagen`,
 1 AS `activo`,
 1 AS `idtemporada`,
 1 AS `mensaje`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vcampos`
--

DROP TABLE IF EXISTS `vcampos`;
/*!50001 DROP VIEW IF EXISTS `vcampos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vcampos` AS SELECT 
 1 AS `id`,
 1 AS `campo`,
 1 AS `direccion`,
 1 AS `cesped`,
 1 AS `tipo`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `provincia`,
 1 AS `localidad`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vcarnets`
--

DROP TABLE IF EXISTS `vcarnets`;
/*!50001 DROP VIEW IF EXISTS `vcarnets`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vcarnets` AS SELECT 
 1 AS `id`,
 1 AS `iduser`,
 1 AS `idrol`,
 1 AS `idclub`,
 1 AS `idtemporada`,
 1 AS `color`,
 1 AS `nsocio`,
 1 AS `nombre`,
 1 AS `qr`,
 1 AS `categoria`,
 1 AS `email`,
 1 AS `urlimagen`,
 1 AS `colorletras`,
 1 AS `club`,
 1 AS `escudo`,
 1 AS `idappuser`,
 1 AS `user`,
 1 AS `password`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vclientes`
--

DROP TABLE IF EXISTS `vclientes`;
/*!50001 DROP VIEW IF EXISTS `vclientes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vclientes` AS SELECT 
 1 AS `id`,
 1 AS `timestamp`,
 1 AS `timestampgestiones`,
 1 AS `random`,
 1 AS `fechaalta`,
 1 AS `cliente`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `telefono`,
 1 AS `email`,
 1 AS `observaciones`,
 1 AS `idestado`,
 1 AS `estado`,
 1 AS `numgestiones`,
 1 AS `fechaultgestion`,
 1 AS `diasultgestion`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vclubes`
--

DROP TABLE IF EXISTS `vclubes`;
/*!50001 DROP VIEW IF EXISTS `vclubes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vclubes` AS SELECT 
 1 AS `id`,
 1 AS `validado`,
 1 AS `asociado`,
 1 AS `idlocalidad`,
 1 AS `idprovincia`,
 1 AS `idcampo`,
 1 AS `club`,
 1 AS `codigo`,
 1 AS `cif`,
 1 AS `domicilio`,
 1 AS `localidad`,
 1 AS `cpostal`,
 1 AS `provincia`,
 1 AS `email`,
 1 AS `escudo`,
 1 AS `telefono`,
 1 AS `web`,
 1 AS `ncorto`,
 1 AS `campo`,
 1 AS `primeraeq`,
 1 AS `segundaeq`,
 1 AS `terceraeq`,
 1 AS `primeraeqpor`,
 1 AS `segundaeqpor`,
 1 AS `terceraeqpor`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vejercicios`
--

DROP TABLE IF EXISTS `vejercicios`;
/*!50001 DROP VIEW IF EXISTS `vejercicios`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vejercicios` AS SELECT 
 1 AS `id`,
 1 AS `nombre`,
 1 AS `familia`,
 1 AS `idclub`,
 1 AS `tipo`,
 1 AS `url`,
 1 AS `fechasubida`,
 1 AS `idautor`,
 1 AS `club`,
 1 AS `nomautor`,
 1 AS `apeautor`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vemails`
--

DROP TABLE IF EXISTS `vemails`;
/*!50001 DROP VIEW IF EXISTS `vemails`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vemails` AS SELECT 
 1 AS `id`,
 1 AS `idusuario`,
 1 AS `idclub`,
 1 AS `club`,
 1 AS `asunto`,
 1 AS `idremitente`,
 1 AS `remitente`,
 1 AS `mensaje`,
 1 AS `leido`,
 1 AS `timestamp`,
 1 AS `timestampleido`,
 1 AS `registro`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventradasScan`
--

DROP TABLE IF EXISTS `ventradasScan`;
/*!50001 DROP VIEW IF EXISTS `ventradasScan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventradasScan` AS SELECT 
 1 AS `id`,
 1 AS `fecha`,
 1 AS `hora`,
 1 AS `entrasale`,
 1 AS `idcarnet`,
 1 AS `idclub`,
 1 AS `nsocio`,
 1 AS `nombre`,
 1 AS `qr`,
 1 AS `categoria`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventrenadores`
--

DROP TABLE IF EXISTS `ventrenadores`;
/*!50001 DROP VIEW IF EXISTS `ventrenadores`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventrenadores` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idtemporada`,
 1 AS `email`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `photourl`,
 1 AS `password`,
 1 AS `permisos`,
 1 AS `idusuario`,
 1 AS `club`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventrenamiento_archivos`
--

DROP TABLE IF EXISTS `ventrenamiento_archivos`;
/*!50001 DROP VIEW IF EXISTS `ventrenamiento_archivos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventrenamiento_archivos` AS SELECT 
 1 AS `id`,
 1 AS `identrenamiento`,
 1 AS `urlarchivo`,
 1 AS `tipo`,
 1 AS `nombreoriginal`,
 1 AS `fechasubida`,
 1 AS `familia`,
 1 AS `orden`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventrenamientos`
--

DROP TABLE IF EXISTS `ventrenamientos`;
/*!50001 DROP VIEW IF EXISTS `ventrenamientos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventrenamientos` AS SELECT 
 1 AS `id`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idprovincia`,
 1 AS `idequipo`,
 1 AS `idlugar`,
 1 AS `nombre`,
 1 AS `fecha`,
 1 AS `hinicio`,
 1 AS `hfin`,
 1 AS `finalizado`,
 1 AS `notificado`,
 1 AS `observaciones`,
 1 AS `obsentrenador`,
 1 AS `informe`,
 1 AS `tlimite`,
 1 AS `temporada`,
 1 AS `club`,
 1 AS `campo`,
 1 AS `equipo`,
 1 AS `categoria`,
 1 AS `dia`,
 1 AS `mes`,
 1 AS `idsesion`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventrenoCT`
--

DROP TABLE IF EXISTS `ventrenoCT`;
/*!50001 DROP VIEW IF EXISTS `ventrenoCT`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventrenoCT` AS SELECT 
 1 AS `id`,
 1 AS `identrenador`,
 1 AS `identrenamiento`,
 1 AS `asiste`,
 1 AS `idmotivo`,
 1 AS `motivo`,
 1 AS `observaciones`,
 1 AS `idequipo`,
 1 AS `idclub`,
 1 AS `finalizado`,
 1 AS `idtemporada`,
 1 AS `idusuario`,
 1 AS `photourl`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `temporada`,
 1 AS `club`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventrenojugador`
--

DROP TABLE IF EXISTS `ventrenojugador`;
/*!50001 DROP VIEW IF EXISTS `ventrenojugador`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventrenojugador` AS SELECT 
 1 AS `id`,
 1 AS `idjugador`,
 1 AS `identrenamiento`,
 1 AS `asiste`,
 1 AS `confirmado`,
 1 AS `confirmadotutor`,
 1 AS `confirmadoentrenador`,
 1 AS `idmotivo`,
 1 AS `rpe`,
 1 AS `motivo`,
 1 AS `observaciones`,
 1 AS `msgeneral`,
 1 AS `mensaje`,
 1 AS `visto`,
 1 AS `nombre`,
 1 AS `idequipo`,
 1 AS `idclub`,
 1 AS `fecha`,
 1 AS `hinicio`,
 1 AS `hfin`,
 1 AS `finalizado`,
 1 AS `idtemporada`,
 1 AS `tlimite`,
 1 AS `foto`,
 1 AS `apodo`,
 1 AS `nombrejug`,
 1 AS `apellidos`,
 1 AS `idposicion`,
 1 AS `dni`,
 1 AS `telefono`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `temporada`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `campo`,
 1 AS `dia`,
 1 AS `mes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `ventrenojugador_ant`
--

DROP TABLE IF EXISTS `ventrenojugador_ant`;
/*!50001 DROP VIEW IF EXISTS `ventrenojugador_ant`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `ventrenojugador_ant` AS SELECT 
 1 AS `id`,
 1 AS `idjugador`,
 1 AS `identrenamiento`,
 1 AS `asiste`,
 1 AS `confirmado`,
 1 AS `confirmadotutor`,
 1 AS `confirmadoentrenador`,
 1 AS `idmotivo`,
 1 AS `rpe`,
 1 AS `motivo`,
 1 AS `observaciones`,
 1 AS `msgeneral`,
 1 AS `mensaje`,
 1 AS `visto`,
 1 AS `nombre`,
 1 AS `idequipo`,
 1 AS `idclub`,
 1 AS `fecha`,
 1 AS `hinicio`,
 1 AS `hfin`,
 1 AS `finalizado`,
 1 AS `idtemporada`,
 1 AS `tlimite`,
 1 AS `foto`,
 1 AS `apodo`,
 1 AS `nombrejug`,
 1 AS `apellidos`,
 1 AS `idposicion`,
 1 AS `dni`,
 1 AS `telefono`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `temporada`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `campo`,
 1 AS `dia`,
 1 AS `mes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vequipos`
--

DROP TABLE IF EXISTS `vequipos`;
/*!50001 DROP VIEW IF EXISTS `vequipos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vequipos` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idprovincia`,
 1 AS `idcategoria`,
 1 AS `idtemporada`,
 1 AS `equipo`,
 1 AS `ncorto`,
 1 AS `titulares`,
 1 AS `minutos`,
 1 AS `informe`,
 1 AS `informejugadores`,
 1 AS `informeestadisticas`,
 1 AS `informeestadisticasjug`,
 1 AS `sistema`,
 1 AS `camiseta`,
 1 AS `categoria`,
 1 AS `temporada`,
 1 AS `club`,
 1 AS `escudo`,
 1 AS `jugadores`,
 1 AS `clubequipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vestadisticasjugador`
--

DROP TABLE IF EXISTS `vestadisticasjugador`;
/*!50001 DROP VIEW IF EXISTS `vestadisticasjugador`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vestadisticasjugador` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idjugador`,
 1 AS `idtemporada`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `asistencias`,
 1 AS `goles`,
 1 AS `golpp`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `valcoordinador`,
 1 AS `capitan`,
 1 AS `penalti`,
 1 AS `observaciones`,
 1 AS `obsclub`,
 1 AS `obspadre`,
 1 AS `visible`,
 1 AS `pfScore`,
 1 AS `lavaropa`,
 1 AS `PFS`,
 1 AS `evolucion`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vestadisticaspordia`
--

DROP TABLE IF EXISTS `vestadisticaspordia`;
/*!50001 DROP VIEW IF EXISTS `vestadisticaspordia`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vestadisticaspordia` AS SELECT 
 1 AS `idsponsor`,
 1 AS `sponsor`,
 1 AS `idanuncio`,
 1 AS `anyo`,
 1 AS `mes`,
 1 AS `dia`,
 1 AS `semana`,
 1 AS `fecha`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`,
 1 AS `urlanuncio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vestadisticaspormes`
--

DROP TABLE IF EXISTS `vestadisticaspormes`;
/*!50001 DROP VIEW IF EXISTS `vestadisticaspormes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vestadisticaspormes` AS SELECT 
 1 AS `idsponsor`,
 1 AS `sponsor`,
 1 AS `idanuncio`,
 1 AS `anyo`,
 1 AS `mes`,
 1 AS `dia`,
 1 AS `semana`,
 1 AS `fecha`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`,
 1 AS `urlanuncio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vestadisticasporsemana`
--

DROP TABLE IF EXISTS `vestadisticasporsemana`;
/*!50001 DROP VIEW IF EXISTS `vestadisticasporsemana`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vestadisticasporsemana` AS SELECT 
 1 AS `idsponsor`,
 1 AS `sponsor`,
 1 AS `idanuncio`,
 1 AS `anyo`,
 1 AS `mes`,
 1 AS `dia`,
 1 AS `semana`,
 1 AS `fecha`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`,
 1 AS `urlanuncio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `veventos`
--

DROP TABLE IF EXISTS `veventos`;
/*!50001 DROP VIEW IF EXISTS `veventos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `veventos` AS SELECT 
 1 AS `id`,
 1 AS `idpartido`,
 1 AS `idjugador`,
 1 AS `idtemporada`,
 1 AS `minuto`,
 1 AS `tam`,
 1 AS `tam2`,
 1 AS `tro`,
 1 AS `tamriv`,
 1 AS `troriv`,
 1 AS `dorsal`,
 1 AS `gol`,
 1 AS `asistencia`,
 1 AS `golpropiopuerta`,
 1 AS `sale`,
 1 AS `entra`,
 1 AS `golencajado`,
 1 AS `lesion`,
 1 AS `min`,
 1 AS `fecha`,
 1 AS `inicio`,
 1 AS `descanso`,
 1 AS `segundamitad`,
 1 AS `fin`,
 1 AS `penalti`,
 1 AS `penaltiparado`,
 1 AS `penaltiparadocontra`,
 1 AS `foto`,
 1 AS `apodo`,
 1 AS `activo`,
 1 AS `club`,
 1 AS `observaciones`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `veventospublicidad`
--

DROP TABLE IF EXISTS `veventospublicidad`;
/*!50001 DROP VIEW IF EXISTS `veventospublicidad`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `veventospublicidad` AS SELECT 
 1 AS `id`,
 1 AS `idanuncio`,
 1 AS `idsponsor`,
 1 AS `timestamp`,
 1 AS `fecha`,
 1 AS `anyo`,
 1 AS `mes`,
 1 AS `semana`,
 1 AS `dia`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `idperfil`,
 1 AS `idusuario`,
 1 AS `evento`,
 1 AS `temporada`,
 1 AS `urlanuncio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vinformes`
--

DROP TABLE IF EXISTS `vinformes`;
/*!50001 DROP VIEW IF EXISTS `vinformes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vinformes` AS SELECT 
 1 AS `id`,
 1 AS `idequipo`,
 1 AS `idusuario`,
 1 AS `idclub`,
 1 AS `tipo`,
 1 AS `informe`,
 1 AS `urldocumento`,
 1 AS `fechasubida`,
 1 AS `idtemporada`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugador`
--

DROP TABLE IF EXISTS `vjugador`;
/*!50001 DROP VIEW IF EXISTS `vjugador`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugador` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `activo`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `idtemporada`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `obsclub`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `temporada`,
 1 AS `club`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugador_estadisticas_json`
--

DROP TABLE IF EXISTS `vjugador_estadisticas_json`;
/*!50001 DROP VIEW IF EXISTS `vjugador_estadisticas_json`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugador_estadisticas_json` AS SELECT 
 1 AS `idjugador`,
 1 AS `estadisticas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadores`
--

DROP TABLE IF EXISTS `vjugadores`;
/*!50001 DROP VIEW IF EXISTS `vjugadores`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadores` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `nota`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadoresFB`
--

DROP TABLE IF EXISTS `vjugadoresFB`;
/*!50001 DROP VIEW IF EXISTS `vjugadoresFB`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadoresFB` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `iduser`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadoresFB_antigua`
--

DROP TABLE IF EXISTS `vjugadoresFB_antigua`;
/*!50001 DROP VIEW IF EXISTS `vjugadoresFB_antigua`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadoresFB_antigua` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `iduser`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadores_stats_completa`
--

DROP TABLE IF EXISTS `vjugadores_stats_completa`;
/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadores_stats_completa` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `nota`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`,
 1 AS `estadisticas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadores_stats_completa_v2`
--

DROP TABLE IF EXISTS `vjugadores_stats_completa_v2`;
/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa_v2`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadores_stats_completa_v2` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `nota`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`,
 1 AS `estadisticas`,
 1 AS `roljugador`,
 1 AS `troles`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadores_stats_completa_v3`
--

DROP TABLE IF EXISTS `vjugadores_stats_completa_v3`;
/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa_v3`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadores_stats_completa_v3` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `nota`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `asistencias`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`,
 1 AS `pfScore`,
 1 AS `evolucion`,
 1 AS `valcoordinador`,
 1 AS `lavaropa`,
 1 AS `perdidas`,
 1 AS `recuperaciones`,
 1 AS `paradas`,
 1 AS `despejes`,
 1 AS `salidas`,
 1 AS `fallos`,
 1 AS `fjuego`,
 1 AS `faltacom`,
 1 AS `faltarec`,
 1 AS `tiroap`,
 1 AS `tirofuera`,
 1 AS `estad_observaciones`,
 1 AS `estad_obsclub`,
 1 AS `estad_obspadre`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `estadisticas`,
 1 AS `roljugador`,
 1 AS `tutores`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugadores_stats_completa_v3_real`
--

DROP TABLE IF EXISTS `vjugadores_stats_completa_v3_real`;
/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa_v3_real`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugadores_stats_completa_v3_real` AS SELECT 
 1 AS `id`,
 1 AS `idcategoria`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idestado`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `activo`,
 1 AS `idprovjuega`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `ficha`,
 1 AS `fechanacimiento`,
 1 AS `fechaalta`,
 1 AS `convocado`,
 1 AS `conventreno`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `domicilio`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `dni`,
 1 AS `emailtutor1`,
 1 AS `emailtutor2`,
 1 AS `tutor1`,
 1 AS `tutor2`,
 1 AS `codigoactivacion`,
 1 AS `idtipocuota`,
 1 AS `dorsal`,
 1 AS `observaciones`,
 1 AS `obspadre`,
 1 AS `nota`,
 1 AS `obsclub`,
 1 AS `informe`,
 1 AS `recmedico`,
 1 AS `fecharecmedico`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `categoria`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `estado`,
 1 AS `imgposicion`,
 1 AS `imgestado`,
 1 AS `pj`,
 1 AS `ptitular`,
 1 AS `plesionado`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `visible`,
 1 AS `asistencias`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `temporada`,
 1 AS `goles`,
 1 AS `penalti`,
 1 AS `ta`,
 1 AS `ta2`,
 1 AS `tr`,
 1 AS `minutos`,
 1 AS `valoracion`,
 1 AS `capitan`,
 1 AS `estadisticas`,
 1 AS `roljugador`,
 1 AS `tutores`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vjugsimple`
--

DROP TABLE IF EXISTS `vjugsimple`;
/*!50001 DROP VIEW IF EXISTS `vjugsimple`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vjugsimple` AS SELECT 
 1 AS `id`,
 1 AS `idposicion`,
 1 AS `idpiedominante`,
 1 AS `idprovincia`,
 1 AS `idlocalidad`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `fechanacimiento`,
 1 AS `domicilio`,
 1 AS `localidad`,
 1 AS `provincia`,
 1 AS `posicion`,
 1 AS `pie`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `club`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vlavarropa`
--

DROP TABLE IF EXISTS `vlavarropa`;
/*!50001 DROP VIEW IF EXISTS `vlavarropa`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vlavarropa` AS SELECT 
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `id`,
 1 AS `idpartido`,
 1 AS `idjugador`,
 1 AS `idequipo`,
 1 AS `idtemporada`,
 1 AS `convocado`,
 1 AS `lavaropa`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vpartido`
--

DROP TABLE IF EXISTS `vpartido`;
/*!50001 DROP VIEW IF EXISTS `vpartido`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vpartido` AS SELECT 
 1 AS `id`,
 1 AS `idjornada`,
 1 AS `idtemporada`,
 1 AS `idcategoria`,
 1 AS `idequipo`,
 1 AS `idrival`,
 1 AS `ncortorival`,
 1 AS `ncortoclubrival`,
 1 AS `rival`,
 1 AS `idclub`,
 1 AS `idprovincia`,
 1 AS `idlugar`,
 1 AS `fecha`,
 1 AS `goles`,
 1 AS `golesrival`,
 1 AS `finalizado`,
 1 AS `primTiempo`,
 1 AS `directo`,
 1 AS `descanso`,
 1 AS `minuto`,
 1 AS `hora`,
 1 AS `horaconvocatoria`,
 1 AS `casafuera`,
 1 AS `veralineacion`,
 1 AS `verConvocatoria`,
 1 AS `jornada`,
 1 AS `jcorta`,
 1 AS `temporada`,
 1 AS `categoria`,
 1 AS `club`,
 1 AS `escudo`,
 1 AS `ncortoclub`,
 1 AS `equipo`,
 1 AS `ncortoequipo`,
 1 AS `titulares`,
 1 AS `minpar`,
 1 AS `campo`,
 1 AS `min`,
 1 AS `minutosporparte`,
 1 AS `numeropartes`,
 1 AS `color1L`,
 1 AS `color2L`,
 1 AS `color3L`,
 1 AS `color4L`,
 1 AS `color5L`,
 1 AS `observaciones`,
 1 AS `obsconvocatoria`,
 1 AS `informe`,
 1 AS `infconvocatoria`,
 1 AS `dispositivo`,
 1 AS `arbitro`,
 1 AS `obsarbitro`,
 1 AS `cronica`,
 1 AS `previa`,
 1 AS `sistema`,
 1 AS `sistemafinal`,
 1 AS `idcamiseta`,
 1 AS `idcamisetapor`,
 1 AS `camiseta`,
 1 AS `camisetapor`,
 1 AS `idN`,
 1 AS `idNP`,
 1 AS `alrival`,
 1 AS `camisetarival`,
 1 AS `sistemarival`,
 1 AS `visto`,
 1 AS `obscoordinador`,
 1 AS `idclubrival`,
 1 AS `escudorival`,
 1 AS `clubequipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vpartidojugador`
--

DROP TABLE IF EXISTS `vpartidojugador`;
/*!50001 DROP VIEW IF EXISTS `vpartidojugador`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vpartidojugador` AS SELECT 
 1 AS `id`,
 1 AS `idjugador`,
 1 AS `convocado`,
 1 AS `jugando`,
 1 AS `idpartido`,
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `idposicion`,
 1 AS `idequipo`,
 1 AS `idclub`,
 1 AS `activo`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `posicion`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `convJugador`,
 1 AS `estado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vpartidosjugadores`
--

DROP TABLE IF EXISTS `vpartidosjugadores`;
/*!50001 DROP VIEW IF EXISTS `vpartidosjugadores`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vpartidosjugadores` AS SELECT 
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `idposicion`,
 1 AS `id`,
 1 AS `idpartido`,
 1 AS `idjugador`,
 1 AS `idequipo`,
 1 AS `idtemporada`,
 1 AS `convocado`,
 1 AS `idmotivo`,
 1 AS `motivo`,
 1 AS `jugando`,
 1 AS `titular`,
 1 AS `minutos`,
 1 AS `mentra`,
 1 AS `goles`,
 1 AS `golpp`,
 1 AS `tam`,
 1 AS `tro`,
 1 AS `observaciones`,
 1 AS `lavaropa`,
 1 AS `valPartido`,
 1 AS `pfScore`,
 1 AS `valjugador`,
 1 AS `capitan`,
 1 AS `lesion`,
 1 AS `penalti`,
 1 AS `visto`,
 1 AS `dorsal`,
 1 AS `posX`,
 1 AS `posY`,
 1 AS `estado`,
 1 AS `fecha`,
 1 AS `golesequipo`,
 1 AS `golesrival`,
 1 AS `finalizado`,
 1 AS `obsconvocatoria`,
 1 AS `minuto`,
 1 AS `hora`,
 1 AS `jornada`,
 1 AS `equipo`,
 1 AS `club`,
 1 AS `posicion`,
 1 AS `escudo`,
 1 AS `casafuera`,
 1 AS `idclubR`,
 1 AS `escudoRival`,
 1 AS `ncorto`,
 1 AS `ncortorival`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vpartidosjugadoresFB`
--

DROP TABLE IF EXISTS `vpartidosjugadoresFB`;
/*!50001 DROP VIEW IF EXISTS `vpartidosjugadoresFB`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vpartidosjugadoresFB` AS SELECT 
 1 AS `apodo`,
 1 AS `foto`,
 1 AS `idtutor1`,
 1 AS `idtutor2`,
 1 AS `idposicion`,
 1 AS `id`,
 1 AS `idpartido`,
 1 AS `idjugador`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idtemporada`,
 1 AS `convocado`,
 1 AS `nodisponible`,
 1 AS `idmotivo`,
 1 AS `motivo`,
 1 AS `jugando`,
 1 AS `titular`,
 1 AS `minutos`,
 1 AS `mentra`,
 1 AS `asistencias`,
 1 AS `goles`,
 1 AS `tam`,
 1 AS `tro`,
 1 AS `observaciones`,
 1 AS `obsconvocatoria`,
 1 AS `lavaropa`,
 1 AS `valPartido`,
 1 AS `pfScore`,
 1 AS `valjugador`,
 1 AS `valcoordinador`,
 1 AS `capitan`,
 1 AS `lesion`,
 1 AS `penalti`,
 1 AS `visto`,
 1 AS `dorsal`,
 1 AS `posX`,
 1 AS `posY`,
 1 AS `posAlineacion`,
 1 AS `posXCambio`,
 1 AS `posYCambio`,
 1 AS `posAlineacionCambio`,
 1 AS `estado`,
 1 AS `fecha`,
 1 AS `golesequipo`,
 1 AS `golesrival`,
 1 AS `finalizado`,
 1 AS `minuto`,
 1 AS `hora`,
 1 AS `verConvocatoria`,
 1 AS `jornada`,
 1 AS `equipo`,
 1 AS `club`,
 1 AS `primeraeq`,
 1 AS `segundaeq`,
 1 AS `terceraeq`,
 1 AS `primeraeqpor`,
 1 AS `segundaeqpor`,
 1 AS `terceraeqpor`,
 1 AS `posicion`,
 1 AS `escudo`,
 1 AS `casafuera`,
 1 AS `idclubR`,
 1 AS `escudoRival`,
 1 AS `ncorto`,
 1 AS `ncortorival`,
 1 AS `ncortoclubrival`,
 1 AS `rival`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vpautaentrenamiento`
--

DROP TABLE IF EXISTS `vpautaentrenamiento`;
/*!50001 DROP VIEW IF EXISTS `vpautaentrenamiento`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vpautaentrenamiento` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idsesion`,
 1 AS `club`,
 1 AS `idejercicio`,
 1 AS `ejercicio`,
 1 AS `observaciones`,
 1 AS `tiempo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vpublicidad`
--

DROP TABLE IF EXISTS `vpublicidad`;
/*!50001 DROP VIEW IF EXISTS `vpublicidad`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vpublicidad` AS SELECT 
 1 AS `id`,
 1 AS `idequipo`,
 1 AS `idanunciante`,
 1 AS `evento`,
 1 AS `urlImagen`,
 1 AS `activo`,
 1 AS `idtemporada`,
 1 AS `idclub`,
 1 AS `posicion`,
 1 AS `impresiones`,
 1 AS `interacciones`,
 1 AS `ctr`,
 1 AS `equipo`,
 1 AS `idclub1`,
 1 AS `club`,
 1 AS `anunciante`,
 1 AS `direccion`,
 1 AS `cif`,
 1 AS `email`,
 1 AS `web`,
 1 AS `idlocalidad`,
 1 AS `idprovincia`,
 1 AS `telefono`,
 1 AS `mensaje`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vroles`
--

DROP TABLE IF EXISTS `vroles`;
/*!50001 DROP VIEW IF EXISTS `vroles`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vroles` AS SELECT 
 1 AS `id`,
 1 AS `tipo`,
 1 AS `idusuario`,
 1 AS `idtemporada`,
 1 AS `uid`,
 1 AS `selectedrol`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idjugador`,
 1 AS `idjugador2`,
 1 AS `idjugador3`,
 1 AS `idjugador4`,
 1 AS `idcarnet`,
 1 AS `name`,
 1 AS `title`,
 1 AS `description`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `user`,
 1 AS `password`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `nomjug1`,
 1 AS `apejug1`,
 1 AS `nomjug2`,
 1 AS `apejug2`,
 1 AS `nomjug3`,
 1 AS `apejug3`,
 1 AS `nomjug4`,
 1 AS `apejug4`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vrolesCarnet`
--

DROP TABLE IF EXISTS `vrolesCarnet`;
/*!50001 DROP VIEW IF EXISTS `vrolesCarnet`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vrolesCarnet` AS SELECT 
 1 AS `id`,
 1 AS `tipo`,
 1 AS `idusuario`,
 1 AS `idtemporada`,
 1 AS `uid`,
 1 AS `selectedrol`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idcarnet`,
 1 AS `name`,
 1 AS `title`,
 1 AS `description`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `email`,
 1 AS `telefono`,
 1 AS `user`,
 1 AS `password`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `idjugador`,
 1 AS `nomjug1`,
 1 AS `apejug1`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vrolpeticion`
--

DROP TABLE IF EXISTS `vrolpeticion`;
/*!50001 DROP VIEW IF EXISTS `vrolpeticion`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vrolpeticion` AS SELECT 
 1 AS `id`,
 1 AS `tipo`,
 1 AS `idusuario`,
 1 AS `idtemporada`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `email`,
 1 AS `uid`,
 1 AS `fecha`,
 1 AS `estado`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idjugador`,
 1 AS `comentario`,
 1 AS `name`,
 1 AS `title`,
 1 AS `description`,
 1 AS `club`,
 1 AS `equipo`,
 1 AS `jugador`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vropa`
--

DROP TABLE IF EXISTS `vropa`;
/*!50001 DROP VIEW IF EXISTS `vropa`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vropa` AS SELECT 
 1 AS `id`,
 1 AS `idjugador`,
 1 AS `idclub`,
 1 AS `idtemporada`,
 1 AS `idprenda`,
 1 AS `pvp`,
 1 AS `descuento`,
 1 AS `entregado`,
 1 AS `acuenta`,
 1 AS `tipopago`,
 1 AS `talla`,
 1 AS `fecha`,
 1 AS `fechaentrega`,
 1 AS `avisado`,
 1 AS `descripcion`,
 1 AS `icono`,
 1 AS `estado`,
 1 AS `devuelto`,
 1 AS `fechadevolucion`,
 1 AS `nombre`,
 1 AS `idequipo`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vsponsors`
--

DROP TABLE IF EXISTS `vsponsors`;
/*!50001 DROP VIEW IF EXISTS `vsponsors`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vsponsors` AS SELECT 
 1 AS `id`,
 1 AS `nombre`,
 1 AS `direccion`,
 1 AS `cif`,
 1 AS `email`,
 1 AS `web`,
 1 AS `telefono`,
 1 AS `urlImagen`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vtallapeso`
--

DROP TABLE IF EXISTS `vtallapeso`;
/*!50001 DROP VIEW IF EXISTS `vtallapeso`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vtallapeso` AS SELECT 
 1 AS `id`,
 1 AS `idjugador`,
 1 AS `apodo`,
 1 AS `peso`,
 1 AS `altura`,
 1 AS `fecha`,
 1 AS `difp`,
 1 AS `difa`,
 1 AS `imc`,
 1 AS `pesoideal`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vusuarioroles`
--

DROP TABLE IF EXISTS `vusuarioroles`;
/*!50001 DROP VIEW IF EXISTS `vusuarioroles`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vusuarioroles` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idtemporada`,
 1 AS `uid`,
 1 AS `email`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `telefono`,
 1 AS `photourl`,
 1 AS `user`,
 1 AS `password`,
 1 AS `permisos`,
 1 AS `observaciones`,
 1 AS `col1`,
 1 AS `col2`,
 1 AS `col3`,
 1 AS `estadentro`,
 1 AS `conhijos`,
 1 AS `notificar`,
 1 AS `dorsal`,
 1 AS `idjugador`,
 1 AS `estadisticas`,
 1 AS `entrenamientos`,
 1 AS `partidos`,
 1 AS `tallapeso`,
 1 AS `lesiones`,
 1 AS `cuotas`,
 1 AS `hacerfotos`,
 1 AS `firmaproteccion`,
 1 AS `idempresa`,
 1 AS `clubcompleto`,
 1 AS `club`,
 1 AS `perfil`,
 1 AS `equipo`,
 1 AS `roles`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vusuarios`
--

DROP TABLE IF EXISTS `vusuarios`;
/*!50001 DROP VIEW IF EXISTS `vusuarios`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vusuarios` AS SELECT 
 1 AS `id`,
 1 AS `idclub`,
 1 AS `idequipo`,
 1 AS `idtemporada`,
 1 AS `uid`,
 1 AS `email`,
 1 AS `nombre`,
 1 AS `apellidos`,
 1 AS `telefono`,
 1 AS `photourl`,
 1 AS `user`,
 1 AS `password`,
 1 AS `permisos`,
 1 AS `observaciones`,
 1 AS `col1`,
 1 AS `col2`,
 1 AS `col3`,
 1 AS `estadentro`,
 1 AS `conhijos`,
 1 AS `notificar`,
 1 AS `dorsal`,
 1 AS `idjugador`,
 1 AS `estadisticas`,
 1 AS `entrenamientos`,
 1 AS `partidos`,
 1 AS `tallapeso`,
 1 AS `lesiones`,
 1 AS `cuotas`,
 1 AS `hacerfotos`,
 1 AS `firmaproteccion`,
 1 AS `idempresa`,
 1 AS `clubcompleto`,
 1 AS `club`,
 1 AS `perfil`,
 1 AS `equipo`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'qanf664'
--
/*!50003 DROP FUNCTION IF EXISTS `calcularFBScore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`qanf664`@`%` FUNCTION `calcularFBScore`(
  goles INT,
  asistencias INT,
  minutos INT,
  tr INT,
  ta INT,
  titular INT,
  capitan INT,
  idposicion INT,
  golesPartido INT,
  golesRival INT,
  minutosTotales INT
) RETURNS int
BEGIN
  DECLARE score DOUBLE DEFAULT 65;
  DECLARE valorGol INT DEFAULT 0;
  DECLARE penalizacionGoles DOUBLE DEFAULT 0;
  DECLARE ratioMinutos DOUBLE DEFAULT 0;

  -- Ponderación gol según posición
  SET valorGol = CASE idposicion
    WHEN 1 THEN 5 -- portero
    WHEN 2 THEN 4 -- defensa
    WHEN 3 THEN 3 -- centrocampista
    WHEN 4 THEN 2 -- delantero
    ELSE 0
  END;

  -- Añadir titular y capitán
  IF titular = 1 THEN
    SET score = score + 3;
  END IF;

  IF capitan = 1 THEN
    SET score = score + 1;
  END IF;

  -- Goles (máx 12 puntos), solo si no portero
  IF idposicion != 1 THEN
    SET score = score + LEAST(goles * valorGol, 12);
  END IF;

  -- Asistencias (máx 3)
  SET score = score + LEAST(asistencias, 3);

  -- Tarjetas
  SET score = score - (ta * 2);
  SET score = score - (tr * 5);

  -- Penalización goles encajados
  IF idposicion IN (1, 2) THEN
    SET penalizacionGoles = golesRival * 1;
  ELSEIF idposicion IN (3, 4) THEN
    SET penalizacionGoles = golesRival * 0.4;
  ELSE
    SET penalizacionGoles = 0;
  END IF;

  SET score = score - LEAST(penalizacionGoles, 6);

  -- Minutos jugados (hasta 6 puntos)
  IF minutosTotales > 0 THEN
    SET ratioMinutos = minutos / minutosTotales;
    SET score = score + LEAST(ratioMinutos * 6, 6);
  END IF;

  -- Resultado partido
  IF golesPartido > golesRival THEN
    SET score = score + 5;
  ELSEIF golesPartido = golesRival THEN
    SET score = score + 2;
  END IF;

  -- Limitar entre 0 y 100 y devolver
  RETURN CAST(GREATEST(0, LEAST(score, 100)) AS SIGNED);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vContabilidad`
--

/*!50001 DROP VIEW IF EXISTS `vContabilidad`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vContabilidad` AS select `tcontabilidad`.`id` AS `id`,`tcontabilidad`.`idclub` AS `idclub`,`tcontabilidad`.`idequipo` AS `idequipo`,`tcontabilidad`.`familia` AS `familia`,`tcontabilidad`.`concepto` AS `concepto`,`tcontabilidad`.`ingreso` AS `ingreso`,`tcontabilidad`.`gasto` AS `gasto`,`tcontabilidad`.`cantidad` AS `cantidad`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `tcontabilidad`.`idequipo`)) AS `equipo`,`tcontabilidad`.`timestamp` AS `timestamp`,`tcontabilidad`.`fecha` AS `fecha`,`tcontabilidad`.`idtemporada` AS `idtemporada`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `tcontabilidad`.`idtemporada`)) AS `temporada`,`tcontabilidad`.`idcuota` AS `idcuota`,`tcontabilidad`.`idpagoper` AS `idpagoper`,`tcontabilidad`.`idestado` AS `idestado` from `tcontabilidad` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vCuotas`
--

/*!50001 DROP VIEW IF EXISTS `vCuotas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vCuotas` AS select `tcuotas`.`id` AS `id`,`tcuotas`.`idclub` AS `idclub`,`tcuotas`.`idequipo` AS `idequipo`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `tcuotas`.`idequipo`)) AS `equipo`,`tcuotas`.`idjugador` AS `idjugador`,(select `tjugadores`.`nombre` from `tjugadores` where (`tjugadores`.`id` = `tcuotas`.`idjugador`)) AS `nombre`,(select `tjugadores`.`apellidos` from `tjugadores` where (`tjugadores`.`id` = `tcuotas`.`idjugador`)) AS `apellidos`,`tcuotas`.`timestamp` AS `timestamp`,`tcuotas`.`mes` AS `mes`,`tcuotas`.`year` AS `year`,`tcuotas`.`idestado` AS `idestado`,`tcuotas`.`idtemporada` AS `idtemporada`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `tcuotas`.`idtemporada`)) AS `temporada`,`testadocobro`.`estado` AS `estado`,`tcuotas`.`cantidad` AS `cantidad`,`tcuotas`.`idtipocuota` AS `idtipocuota`,`tconfigcuotas`.`tipo` AS `tipo`,`testadocobro`.`icono` AS `icono` from (((`tcuotas` join `tjugadores` on((`tjugadores`.`id` = `tcuotas`.`idjugador`))) join `testadocobro` on((`testadocobro`.`id` = `tcuotas`.`idestado`))) join `tconfigcuotas` on((`tconfigcuotas`.`id` = `tcuotas`.`idtipocuota`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vPdfPartido1`
--

/*!50001 DROP VIEW IF EXISTS `vPdfPartido1`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vPdfPartido1` AS select `teventospartido`.`id` AS `id`,`teventospartido`.`idpartido` AS `idpartido`,`teventospartido`.`idjugador` AS `idjugador`,`teventospartido`.`idtemporada` AS `idtemporada`,(case `teventospartido`.`tam` when 1 then (case `teventospartido`.`tam2` when 1 then 'DOBLE AMARILLA Y EXPULSION' else 'TARJETA AMARILLA' end) else (case `teventospartido`.`tam2` when 1 then 'DOBLE AMARILLA Y EXPULSION' else (case `teventospartido`.`tro` when 1 then 'ROJA DIRECTA' else (case `teventospartido`.`gol` when 1 then (case `teventospartido`.`penalti` when 1 then 'GOOOOL DE PENALTI' else 'GOOOOL' end) else (case `teventospartido`.`sale` when 1 then 'SALE DEL TERRENO DE JUEGO' else (case `teventospartido`.`entra` when 1 then 'ENTRA EN EL TERRENO DE JUEGO' else (case `teventospartido`.`golencajado` when 1 then 'HA ENCAJADO UN GOL' else (case `teventospartido`.`lesion` when 1 then 'LESION' else (case `teventospartido`.`inicio` when 1 then 'COMIENZO DEL PARTIDO' else (case `teventospartido`.`descanso` when 1 then 'DESCANSO DEL PARTIDO' else (case `teventospartido`.`fin` when 1 then 'FINAL DEL PARTIDO' else (case `teventospartido`.`penaltiparado` when 1 then 'PENALTI FALLADO' else (case `teventospartido`.`penaltiparadocontra` when 1 then 'PENALTI FALLADO EQUIPO CONTRARIO' else '' end) end) end) end) end) end) end) end) end) end) end) end) end) AS `enventoPartido`,`teventospartido`.`minuto` AS `minuto`,`teventospartido`.`min` AS `min`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`activo` AS `activo`,`tclubes`.`club` AS `club` from ((`teventospartido` join `tjugadores` on((`tjugadores`.`id` = `teventospartido`.`idjugador`))) join `tclubes` on((`tclubes`.`id` = `tjugadores`.`idclub`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vTelemPlayFutbol`
--

/*!50001 DROP VIEW IF EXISTS `vTelemPlayFutbol`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vTelemPlayFutbol` AS select (select count(`vTelemPorAnunciante`.`idanunciante`) from `vTelemPorAnunciante`) AS `anunciantes`,sum(`vTelemPorAnunciante`.`impresiones`) AS `impresiones`,sum(`vTelemPorAnunciante`.`interacciones`) AS `interacciones`,round(((sum(`vTelemPorAnunciante`.`interacciones`) / sum(`vTelemPorAnunciante`.`impresiones`)) * 100),2) AS `ctr` from `vTelemPorAnunciante` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vTelemPorAnunciante`
--

/*!50001 DROP VIEW IF EXISTS `vTelemPorAnunciante`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vTelemPorAnunciante` AS select `ttelemetriapubli`.`idanunciante` AS `idanunciante`,sum(`ttelemetriapubli`.`visto`) AS `impresiones`,sum(`ttelemetriapubli`.`click`) AS `interacciones`,round(((sum(`ttelemetriapubli`.`click`) / sum(`ttelemetriapubli`.`visto`)) * 100),2) AS `ctr`,(select `tpublicidad`.`idtemporada` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `idtemporada`,(select `tpublicidad`.`idequipo` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `idequipo`,(select `tpublicidad`.`urlImagen` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `imagen`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `idequipo`)) AS `equipo`,(select `tequipos`.`idclub` from `tequipos` where (`tequipos`.`id` = `idequipo`)) AS `idclub`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `idclub`)) AS `club`,(select `tanunciante`.`nombre` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `anunciante` from `ttelemetriapubli` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vTelemPorAnuncianteNueva`
--

/*!50001 DROP VIEW IF EXISTS `vTelemPorAnuncianteNueva`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vTelemPorAnuncianteNueva` AS select `ttelemetriapubli`.`idanunciante` AS `idanunciante`,sum(`ttelemetriapubli`.`visto`) AS `impresiones`,sum(`ttelemetriapubli`.`click`) AS `interacciones`,round(((sum(`ttelemetriapubli`.`click`) / sum(`ttelemetriapubli`.`visto`)) * 100),2) AS `ctr` from `ttelemetriapubli` group by `ttelemetriapubli`.`idanunciante` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vTelemPubli`
--

/*!50001 DROP VIEW IF EXISTS `vTelemPubli`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vTelemPubli` AS select `ttelemetriapubli`.`id` AS `id`,`ttelemetriapubli`.`idpublicidad` AS `idpublicidad`,`ttelemetriapubli`.`idanunciante` AS `idanunciante`,`ttelemetriapubli`.`visto` AS `visto`,`ttelemetriapubli`.`click` AS `click`,`ttelemetriapubli`.`fecha` AS `fecha`,`ttelemetriapubli`.`idperfil` AS `idperfil`,(select `tperfilesusuario`.`perfil` from `tperfilesusuario` where (`tperfilesusuario`.`id` = `ttelemetriapubli`.`idperfil`)) AS `perfil`,`ttelemetriapubli`.`idusuario` AS `idusuario`,`ttelemetriapubli`.`evento` AS `evento`,(select `tpublicidad`.`idequipo` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `idequipo`,(select `tpublicidad`.`urlImagen` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `imagen`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `idequipo`)) AS `equipo`,(select `tequipos`.`idclub` from `tequipos` where (`tequipos`.`id` = `idequipo`)) AS `idclub`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `idclub`)) AS `club`,(select `tanunciante`.`nombre` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `nombre`,(select `tanunciante`.`direccion` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `direccion`,(select `tanunciante`.`cif` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `cif`,(select `tanunciante`.`email` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `email`,(select `tanunciante`.`web` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `web`,(select `tanunciante`.`telefono` from `tanunciante` where (`tanunciante`.`id` = `ttelemetriapubli`.`idanunciante`)) AS `telefono` from `ttelemetriapubli` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vanalisis_jugadores_temporada_21_22`
--

/*!50001 DROP VIEW IF EXISTS `vanalisis_jugadores_temporada_21_22`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vanalisis_jugadores_temporada_21_22` AS select `vjugadores`.`id` AS `id`,`vjugadores`.`idcategoria` AS `idcategoria`,`vjugadores`.`idposicion` AS `idposicion`,`vjugadores`.`idpiedominante` AS `idpiedominante`,`vjugadores`.`idestado` AS `idestado`,`vjugadores`.`idtutor1` AS `idtutor1`,`vjugadores`.`idtutor2` AS `idtutor2`,`vjugadores`.`activo` AS `activo`,`vjugadores`.`idprovjuega` AS `idprovjuega`,`vjugadores`.`idprovincia` AS `idprovincia`,`vjugadores`.`idlocalidad` AS `idlocalidad`,`vjugadores`.`nombre` AS `nombre`,`vjugadores`.`apellidos` AS `apellidos`,`vjugadores`.`apodo` AS `apodo`,`vjugadores`.`foto` AS `foto`,`vjugadores`.`fechanacimiento` AS `fechanacimiento`,`vjugadores`.`fechaalta` AS `fechaalta`,`vjugadores`.`convocado` AS `convocado`,`vjugadores`.`conventreno` AS `conventreno`,`vjugadores`.`peso` AS `peso`,`vjugadores`.`altura` AS `altura`,`vjugadores`.`domicilio` AS `domicilio`,`vjugadores`.`email` AS `email`,`vjugadores`.`telefono` AS `telefono`,`vjugadores`.`dni` AS `dni`,`vjugadores`.`emailtutor1` AS `emailtutor1`,`vjugadores`.`emailtutor2` AS `emailtutor2`,`vjugadores`.`tutor1` AS `tutor1`,`vjugadores`.`tutor2` AS `tutor2`,`vjugadores`.`codigoactivacion` AS `codigoactivacion`,`vjugadores`.`idtipocuota` AS `idtipocuota`,`vjugadores`.`dorsal` AS `dorsal`,`vjugadores`.`observaciones` AS `observaciones`,`vjugadores`.`obspadre` AS `obspadre`,`vjugadores`.`obsclub` AS `obsclub`,`vjugadores`.`localidad` AS `localidad`,`vjugadores`.`provincia` AS `provincia`,`vjugadores`.`categoria` AS `categoria`,`vjugadores`.`posicion` AS `posicion`,`vjugadores`.`pie` AS `pie`,`vjugadores`.`estado` AS `estado`,`vjugadores`.`imgposicion` AS `imgposicion`,`vjugadores`.`imgestado` AS `imgestado`,`vjugadores`.`pj` AS `pj`,`vjugadores`.`ptitular` AS `ptitular`,`vjugadores`.`plesionado` AS `plesionado`,`vjugadores`.`idtemporada` AS `idtemporada`,`vjugadores`.`idclub` AS `idclub`,`vjugadores`.`idequipo` AS `idequipo`,`vjugadores`.`visible` AS `visible`,`vjugadores`.`club` AS `club`,`vjugadores`.`equipo` AS `equipo`,`vjugadores`.`temporada` AS `temporada`,`vjugadores`.`goles` AS `goles`,`vjugadores`.`penalti` AS `penalti`,`vjugadores`.`ta` AS `ta`,`vjugadores`.`ta2` AS `ta2`,`vjugadores`.`tr` AS `tr`,`vjugadores`.`minutos` AS `minutos`,`vjugadores`.`valoracion` AS `valoracion`,`vjugadores`.`capitan` AS `capitan` from `vjugadores` where ((`vjugadores`.`idtemporada` = 2) and (`vjugadores`.`idclub` <> 135)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vanuncios`
--

/*!50001 DROP VIEW IF EXISTS `vanuncios`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vanuncios` AS select `tpublicidad`.`id` AS `id`,`tpublicidad`.`idanunciante` AS `idsponsor`,(select `tanunciante`.`nombre` from `tanunciante` where (`tanunciante`.`id` = `tpublicidad`.`idanunciante`)) AS `sponsor`,(select `tequipos`.`idclub` from `tequipos` where (`tequipos`.`id` = `tpublicidad`.`idequipo`)) AS `idclub`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `tpublicidad`.`idclub`)) AS `club`,`tpublicidad`.`evento` AS `evento`,`tpublicidad`.`urlImagen` AS `urlImagen`,`tpublicidad`.`activo` AS `activo`,`tpublicidad`.`idtemporada` AS `idtemporada`,`tpublicidad`.`mensaje` AS `mensaje` from `tpublicidad` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vcampos`
--

/*!50001 DROP VIEW IF EXISTS `vcampos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vcampos` AS select `tcampos`.`id` AS `id`,`tcampos`.`campo` AS `campo`,`tcampos`.`direccion` AS `direccion`,`tcampos`.`cesped` AS `cesped`,`tcampos`.`tipo` AS `tipo`,`tcampos`.`idprovincia` AS `idprovincia`,`tcampos`.`idlocalidad` AS `idlocalidad`,`tprovincias`.`provincia` AS `provincia`,`tlocalidades`.`localidad` AS `localidad` from ((`tcampos` join `tprovincias` on((`tprovincias`.`id` = `tcampos`.`idprovincia`))) join `tlocalidades` on((`tlocalidades`.`id` = `tcampos`.`idlocalidad`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vcarnets`
--

/*!50001 DROP VIEW IF EXISTS `vcarnets`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vcarnets` AS select `c`.`id` AS `id`,`c`.`iduser` AS `iduser`,`c`.`idrol` AS `idrol`,`c`.`idclub` AS `idclub`,`c`.`idtemporada` AS `idtemporada`,`c`.`color` AS `color`,`c`.`nsocio` AS `nsocio`,`c`.`nombre` AS `nombre`,`c`.`qr` AS `qr`,`c`.`categoria` AS `categoria`,`c`.`email` AS `email`,(select `tcarnetsimg`.`urlimagen` from `tcarnetsimg` where ((`tcarnetsimg`.`idclub` = `c`.`idclub`) and (`tcarnetsimg`.`tipo` = `c`.`categoria`) and (`tcarnetsimg`.`idtemporada` = `c`.`idtemporada`)) limit 1) AS `urlimagen`,(select `tcarnetsimg`.`colorletras` from `tcarnetsimg` where ((`tcarnetsimg`.`idclub` = `c`.`idclub`) and (`tcarnetsimg`.`tipo` = `c`.`categoria`) and (`tcarnetsimg`.`idtemporada` = `c`.`idtemporada`)) limit 1) AS `colorletras`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `c`.`idclub`) limit 1) AS `club`,(select `tclubes`.`escudo` from `tclubes` where (`tclubes`.`id` = `c`.`idclub`) limit 1) AS `escudo`,`vu`.`idusuario` AS `idappuser`,`vu`.`user` AS `user`,`vu`.`password` AS `password` from (`tcarnets` `c` left join `vroles` `vu` on((`vu`.`id` = `c`.`idrol`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vclientes`
--

/*!50001 DROP VIEW IF EXISTS `vclientes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vclientes` AS select `tclientes`.`id` AS `id`,`tclientes`.`timestamp` AS `timestamp`,(select max(`tgestionescliente`.`timestamp`) from `tgestionescliente` where (`tgestionescliente`.`idcliente` = `tclientes`.`id`)) AS `timestampgestiones`,`tclientes`.`random` AS `random`,`tclientes`.`fechaalta` AS `fechaalta`,`tclientes`.`cliente` AS `cliente`,`tclientes`.`nombre` AS `nombre`,`tclientes`.`apellidos` AS `apellidos`,`tclientes`.`telefono` AS `telefono`,`tclientes`.`email` AS `email`,`tclientes`.`observaciones` AS `observaciones`,`tclientes`.`idestado` AS `idestado`,(select `testadocliente`.`estado` from `testadocliente` where (`testadocliente`.`id` = `tclientes`.`idestado`)) AS `estado`,(select count(`tgestionescliente`.`id`) from `tgestionescliente` where (`tgestionescliente`.`idcliente` = `tclientes`.`id`)) AS `numgestiones`,(select max(`tgestionescliente`.`fechagestion`) from `tgestionescliente` where (`tgestionescliente`.`idcliente` = `tclientes`.`id`)) AS `fechaultgestion`,(select (to_days(now()) - to_days((select max(`tgestionescliente`.`fechagestion`) from `tgestionescliente` where (`tgestionescliente`.`idcliente` = `tclientes`.`id`))))) AS `diasultgestion` from `tclientes` order by `tclientes`.`fechaalta` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vclubes`
--

/*!50001 DROP VIEW IF EXISTS `vclubes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vclubes` AS select `tclubes`.`id` AS `id`,`tclubes`.`validado` AS `validado`,`tclubes`.`asociado` AS `asociado`,`tclubes`.`idlocalidad` AS `idlocalidad`,`tclubes`.`idprovincia` AS `idprovincia`,`tclubes`.`idcampo` AS `idcampo`,`tclubes`.`club` AS `club`,`tclubes`.`codigo` AS `codigo`,`tclubes`.`cif` AS `cif`,`tclubes`.`domicilio` AS `domicilio`,`tlocalidades`.`localidad` AS `localidad`,`tlocalidades`.`cpostal` AS `cpostal`,`tlocalidades`.`provincia` AS `provincia`,`tclubes`.`email` AS `email`,`tclubes`.`escudo` AS `escudo`,`tclubes`.`telefono` AS `telefono`,`tclubes`.`web` AS `web`,`tclubes`.`ncorto` AS `ncorto`,`tcampos`.`campo` AS `campo`,`tclubes`.`primeraeq` AS `primeraeq`,`tclubes`.`segundaeq` AS `segundaeq`,`tclubes`.`terceraeq` AS `terceraeq`,`tclubes`.`primeraeqpor` AS `primeraeqpor`,`tclubes`.`segundaeqpor` AS `segundaeqpor`,`tclubes`.`terceraeqpor` AS `terceraeqpor` from ((`tclubes` join `tlocalidades` on((`tclubes`.`idlocalidad` = `tlocalidades`.`id`))) join `tcampos` on((`tclubes`.`idcampo` = `tcampos`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vejercicios`
--

/*!50001 DROP VIEW IF EXISTS `vejercicios`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vejercicios` AS select `tejercicios`.`id` AS `id`,`tejercicios`.`nombre` AS `nombre`,`tejercicios`.`familia` AS `familia`,`tejercicios`.`club` AS `idclub`,`tejercicios`.`tipo` AS `tipo`,`tejercicios`.`url` AS `url`,`tejercicios`.`fechasubida` AS `fechasubida`,`tejercicios`.`autor` AS `idautor`,`tclubes`.`club` AS `club`,`tusuarios`.`nombre` AS `nomautor`,`tusuarios`.`apellidos` AS `apeautor` from ((`tejercicios` join `tclubes` on((`tclubes`.`id` = `tejercicios`.`club`))) join `tusuarios` on((`tusuarios`.`id` = `tejercicios`.`autor`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vemails`
--

/*!50001 DROP VIEW IF EXISTS `vemails`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vemails` AS select `temails`.`id` AS `id`,`temails`.`idusuario` AS `idusuario`,`temails`.`idclub` AS `idclub`,`tclubes`.`club` AS `club`,`temails`.`asunto` AS `asunto`,`temails`.`idremitente` AS `idremitente`,if((`temails`.`idremitente` = 0),`tclubes`.`club`,(select concat(`tusuarios`.`nombre`,' ',`tusuarios`.`apellidos`) from `tusuarios` where (`temails`.`idremitente` = `tusuarios`.`id`))) AS `remitente`,`temails`.`mensaje` AS `mensaje`,`temails`.`leido` AS `leido`,`temails`.`timestamp` AS `timestamp`,`temails`.`timestampleido` AS `timestampleido`,`temails`.`registro` AS `registro` from (`temails` join `tclubes` on((`temails`.`idclub` = `tclubes`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventradasScan`
--

/*!50001 DROP VIEW IF EXISTS `ventradasScan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventradasScan` AS select `tentradasScan`.`id` AS `id`,`tentradasScan`.`fecha` AS `fecha`,`tentradasScan`.`hora` AS `hora`,`tentradasScan`.`entrasale` AS `entrasale`,`tentradasScan`.`idcarnet` AS `idcarnet`,`tentradasScan`.`idclub` AS `idclub`,`tentradasScan`.`nsocio` AS `nsocio`,`tcarnets`.`nombre` AS `nombre`,`tcarnets`.`qr` AS `qr`,`tcarnets`.`categoria` AS `categoria` from (`tentradasScan` join `tcarnets` on((`tentradasScan`.`idcarnet` = `tcarnets`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventrenadores`
--

/*!50001 DROP VIEW IF EXISTS `ventrenadores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventrenadores` AS select `tusuarios`.`id` AS `id`,`troles`.`idclub` AS `idclub`,`troles`.`idequipo` AS `idequipo`,`tusuarios`.`idtemporada` AS `idtemporada`,`tusuarios`.`email` AS `email`,`tusuarios`.`nombre` AS `nombre`,`tusuarios`.`apellidos` AS `apellidos`,`tusuarios`.`telefono` AS `telefono`,`tusuarios`.`dni` AS `dni`,`tusuarios`.`photourl` AS `photourl`,`tusuarios`.`password` AS `password`,`troles`.`tipo` AS `permisos`,`troles`.`idusuario` AS `idusuario`,`tclubes`.`club` AS `club`,`tequipos`.`equipo` AS `equipo` from (((`troles` join `tusuarios` on((`tusuarios`.`id` = `troles`.`idusuario`))) join `tclubes` on((`tclubes`.`id` = `troles`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `troles`.`idequipo`))) where (`troles`.`tipo` in (2,12)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventrenamiento_archivos`
--

/*!50001 DROP VIEW IF EXISTS `ventrenamiento_archivos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventrenamiento_archivos` AS select `sub`.`id` AS `id`,`sub`.`identrenamiento` AS `identrenamiento`,`sub`.`urlarchivo` AS `urlarchivo`,`sub`.`tipo` AS `tipo`,`sub`.`nombreoriginal` AS `nombreoriginal`,`sub`.`fechasubida` AS `fechasubida`,`sub`.`familia` AS `familia`,`sub`.`orden` AS `orden` from (select `r`.`id` AS `id`,`r`.`identrenamiento` AS `identrenamiento`,`r`.`urlarchivo` AS `urlarchivo`,`r`.`tipo` AS `tipo`,`r`.`nombreoriginal` AS `nombreoriginal`,`r`.`fechasubida` AS `fechasubida`,`r`.`familia` AS `familia`,`r`.`orden` AS `orden`,row_number() OVER (PARTITION BY `r`.`nombreoriginal` ORDER BY `r`.`fechasubida` desc )  AS `rn` from `entrenamiento_archivos` `r`) `sub` where (`sub`.`rn` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventrenamientos`
--

/*!50001 DROP VIEW IF EXISTS `ventrenamientos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventrenamientos` AS select `tentrenamientos`.`id` AS `id`,`tentrenamientos`.`idtemporada` AS `idtemporada`,`tentrenamientos`.`idclub` AS `idclub`,`tclubes`.`idprovincia` AS `idprovincia`,`tentrenamientos`.`idequipo` AS `idequipo`,`tentrenamientos`.`idlugar` AS `idlugar`,`tentrenamientos`.`nombre` AS `nombre`,`tentrenamientos`.`fecha` AS `fecha`,`tentrenamientos`.`hinicio` AS `hinicio`,`tentrenamientos`.`hfin` AS `hfin`,`tentrenamientos`.`finalizado` AS `finalizado`,`tentrenamientos`.`notificado` AS `notificado`,`tentrenamientos`.`observaciones` AS `observaciones`,`tentrenamientos`.`obsentrenador` AS `obsentrenador`,`tentrenamientos`.`informe` AS `informe`,`tentrenamientos`.`tlimite` AS `tlimite`,`ttemporadas`.`temporada` AS `temporada`,`tclubes`.`club` AS `club`,`tcampos`.`campo` AS `campo`,`tequipos`.`equipo` AS `equipo`,`tcategorias`.`categoria` AS `categoria`,date_format(`tentrenamientos`.`fecha`,'%d') AS `dia`,date_format(`tentrenamientos`.`fecha`,'%m') AS `mes`,`tentrenamientos`.`idsesion` AS `idsesion` from (((((`tentrenamientos` join `ttemporadas` on((`ttemporadas`.`id` = `tentrenamientos`.`idtemporada`))) join `tcampos` on((`tcampos`.`id` = `tentrenamientos`.`idlugar`))) join `tclubes` on((`tclubes`.`id` = `tentrenamientos`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `tentrenamientos`.`idequipo`))) join `tcategorias` on((`tequipos`.`idcategoria` = `tcategorias`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventrenoCT`
--

/*!50001 DROP VIEW IF EXISTS `ventrenoCT`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventrenoCT` AS select `tentrenoct`.`id` AS `id`,`tentrenoct`.`identrenador` AS `identrenador`,`tentrenoct`.`identrenamiento` AS `identrenamiento`,`tentrenoct`.`asiste` AS `asiste`,`tentrenoct`.`motivo` AS `idmotivo`,`tmotivoasistencia`.`motivo` AS `motivo`,`tentrenoct`.`observaciones` AS `observaciones`,`tentrenoct`.`idequipo` AS `idequipo`,`tentrenoct`.`idclub` AS `idclub`,`tentrenamientos`.`finalizado` AS `finalizado`,`tentrenamientos`.`idtemporada` AS `idtemporada`,`troles`.`idusuario` AS `idusuario`,`tusuarios`.`photourl` AS `photourl`,`tusuarios`.`nombre` AS `nombre`,`tusuarios`.`apellidos` AS `apellidos`,`ttemporadas`.`temporada` AS `temporada`,`tclubes`.`club` AS `club`,`tequipos`.`equipo` AS `equipo` from ((((((((`tentrenoct` join `troles` on((`troles`.`id` = `tentrenoct`.`identrenador`))) join `tusuarios` on((`tusuarios`.`id` = `troles`.`idusuario`))) join `tentrenamientos` on((`tentrenamientos`.`id` = `tentrenoct`.`identrenamiento`))) join `ttemporadas` on((`ttemporadas`.`id` = `tentrenamientos`.`idtemporada`))) join `tclubes` on((`tclubes`.`id` = `tentrenoct`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `tentrenoct`.`idequipo`))) join `tcampos` on((`tcampos`.`id` = `tentrenamientos`.`idlugar`))) join `tmotivoasistencia` on((`tmotivoasistencia`.`idasistencia` = `tentrenoct`.`motivo`))) where (`troles`.`tipo` in (2,12)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventrenojugador`
--

/*!50001 DROP VIEW IF EXISTS `ventrenojugador`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventrenojugador` AS select `tjg`.`id` AS `id`,`tjg`.`idjugador` AS `idjugador`,`tjg`.`identrenamiento` AS `identrenamiento`,`tjg`.`asiste` AS `asiste`,`tjg`.`confirmado` AS `confirmado`,`tjg`.`confirmadotutor` AS `confirmadotutor`,`tjg`.`confirmadoentrenador` AS `confirmadoentrenador`,`tjg`.`motivo` AS `idmotivo`,`tjg`.`rpe` AS `rpe`,`tm`.`motivo` AS `motivo`,`tjg`.`observaciones` AS `observaciones`,`tte`.`observaciones` AS `msgeneral`,`tjg`.`mensaje` AS `mensaje`,`tjg`.`visto` AS `visto`,`tte`.`nombre` AS `nombre`,`tte`.`idequipo` AS `idequipo`,`tte`.`idclub` AS `idclub`,`tte`.`fecha` AS `fecha`,`tte`.`hinicio` AS `hinicio`,`tte`.`hfin` AS `hfin`,`tte`.`finalizado` AS `finalizado`,`tte`.`idtemporada` AS `idtemporada`,`tte`.`tlimite` AS `tlimite`,`tj`.`foto` AS `foto`,`tj`.`apodo` AS `apodo`,`tj`.`nombre` AS `nombrejug`,`tj`.`apellidos` AS `apellidos`,`tj`.`idposicion` AS `idposicion`,`tj`.`dni` AS `dni`,`tj`.`telefono` AS `telefono`,`tj`.`idtutor1` AS `idtutor1`,`tj`.`idtutor2` AS `idtutor2`,`tt`.`temporada` AS `temporada`,`tc`.`club` AS `club`,`te`.`equipo` AS `equipo`,`tca`.`campo` AS `campo`,date_format(`tte`.`fecha`,'%d') AS `dia`,date_format(`tte`.`fecha`,'%m') AS `mes` from (((((((`tentrenojugador` `tjg` join `tentrenamientos` `tte` on((`tte`.`id` = `tjg`.`identrenamiento`))) join `tmotivoasistencia` `tm` on((`tm`.`idasistencia` = `tjg`.`motivo`))) join `tclubes` `tc` on((`tc`.`id` = `tjg`.`idclub`))) join `tequipos` `te` on((`te`.`id` = `tjg`.`idequipo`))) join `tcampos` `tca` on((`tca`.`id` = `tte`.`idlugar`))) join `ttemporadas` `tt` on((`tt`.`id` = `tte`.`idtemporada`))) join `tjugadores` `tj` on((`tj`.`id` = `tjg`.`idjugador`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ventrenojugador_ant`
--

/*!50001 DROP VIEW IF EXISTS `ventrenojugador_ant`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `ventrenojugador_ant` AS select `tentrenojugador`.`id` AS `id`,`tentrenojugador`.`idjugador` AS `idjugador`,`tentrenojugador`.`identrenamiento` AS `identrenamiento`,`tentrenojugador`.`asiste` AS `asiste`,`tentrenojugador`.`confirmado` AS `confirmado`,`tentrenojugador`.`confirmadotutor` AS `confirmadotutor`,`tentrenojugador`.`confirmadoentrenador` AS `confirmadoentrenador`,`tentrenojugador`.`motivo` AS `idmotivo`,`tentrenojugador`.`rpe` AS `rpe`,`tmotivoasistencia`.`motivo` AS `motivo`,`tentrenojugador`.`observaciones` AS `observaciones`,`tentrenamientos`.`observaciones` AS `msgeneral`,`tentrenojugador`.`mensaje` AS `mensaje`,`tentrenojugador`.`visto` AS `visto`,`tentrenamientos`.`nombre` AS `nombre`,`tentrenamientos`.`idequipo` AS `idequipo`,`tentrenamientos`.`idclub` AS `idclub`,`tentrenamientos`.`fecha` AS `fecha`,`tentrenamientos`.`hinicio` AS `hinicio`,`tentrenamientos`.`hfin` AS `hfin`,`tentrenamientos`.`finalizado` AS `finalizado`,`tentrenamientos`.`idtemporada` AS `idtemporada`,`tentrenamientos`.`tlimite` AS `tlimite`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`nombre` AS `nombrejug`,`tjugadores`.`apellidos` AS `apellidos`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`dni` AS `dni`,`tjugadores`.`telefono` AS `telefono`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`ttemporadas`.`temporada` AS `temporada`,`tclubes`.`club` AS `club`,`tequipos`.`equipo` AS `equipo`,`tcampos`.`campo` AS `campo`,date_format(`tentrenamientos`.`fecha`,'%d') AS `dia`,date_format(`tentrenamientos`.`fecha`,'%m') AS `mes` from (((((((`tentrenojugador` join `tjugadores` on((`tjugadores`.`id` = `tentrenojugador`.`idjugador`))) join `tentrenamientos` on((`tentrenamientos`.`id` = `tentrenojugador`.`identrenamiento`))) join `ttemporadas` on((`ttemporadas`.`id` = `tentrenamientos`.`idtemporada`))) join `tclubes` on((`tclubes`.`id` = `tentrenojugador`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `tentrenojugador`.`idequipo`))) join `tcampos` on((`tcampos`.`id` = `tentrenamientos`.`idlugar`))) join `tmotivoasistencia` on((`tmotivoasistencia`.`idasistencia` = `tentrenojugador`.`motivo`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vequipos`
--

/*!50001 DROP VIEW IF EXISTS `vequipos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vequipos` AS select `tequipos`.`id` AS `id`,`tequipos`.`idclub` AS `idclub`,`tclubes`.`idprovincia` AS `idprovincia`,`tequipos`.`idcategoria` AS `idcategoria`,`tequipos`.`idtemporada` AS `idtemporada`,`tequipos`.`equipo` AS `equipo`,`tequipos`.`ncorto` AS `ncorto`,`tequipos`.`titulares` AS `titulares`,`tequipos`.`minutos` AS `minutos`,`tequipos`.`informe` AS `informe`,`tequipos`.`informejugadores` AS `informejugadores`,`tequipos`.`informeestadisticas` AS `informeestadisticas`,`tequipos`.`informeestadisticasjug` AS `informeestadisticasjug`,`tequipos`.`sistema` AS `sistema`,`tequipos`.`camiseta` AS `camiseta`,`tcategorias`.`categoria` AS `categoria`,`ttemporadas`.`temporada` AS `temporada`,`tclubes`.`club` AS `club`,`tclubes`.`escudo` AS `escudo`,(select count(`tjugadores`.`apodo`) from `tjugadores` where ((`tjugadores`.`idequipo` = `tequipos`.`id`) and (`tjugadores`.`activo` = 1))) AS `jugadores`,concat(`tclubes`.`club`,' - ',`tequipos`.`equipo`) AS `clubequipo` from (((`tequipos` join `tcategorias` on((`tcategorias`.`id` = `tequipos`.`idcategoria`))) join `ttemporadas` on((`ttemporadas`.`id` = `tequipos`.`idtemporada`))) join `tclubes` on((`tclubes`.`id` = `tequipos`.`idclub`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vestadisticasjugador`
--

/*!50001 DROP VIEW IF EXISTS `vestadisticasjugador`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vestadisticasjugador` AS select `testadisticasjugador`.`id` AS `id`,`testadisticasjugador`.`idclub` AS `idclub`,`testadisticasjugador`.`idequipo` AS `idequipo`,`testadisticasjugador`.`idjugador` AS `idjugador`,`testadisticasjugador`.`idtemporada` AS `idtemporada`,`testadisticasjugador`.`pj` AS `pj`,`testadisticasjugador`.`ptitular` AS `ptitular`,`testadisticasjugador`.`plesionado` AS `plesionado`,`testadisticasjugador`.`asistencias` AS `asistencias`,`testadisticasjugador`.`goles` AS `goles`,`testadisticasjugador`.`golpp` AS `golpp`,`testadisticasjugador`.`ta` AS `ta`,`testadisticasjugador`.`ta2` AS `ta2`,`testadisticasjugador`.`tr` AS `tr`,`testadisticasjugador`.`minutos` AS `minutos`,`testadisticasjugador`.`valoracion` AS `valoracion`,`testadisticasjugador`.`valcoordinador` AS `valcoordinador`,`testadisticasjugador`.`capitan` AS `capitan`,`testadisticasjugador`.`penalti` AS `penalti`,`testadisticasjugador`.`observaciones` AS `observaciones`,`testadisticasjugador`.`obsclub` AS `obsclub`,`testadisticasjugador`.`obspadre` AS `obspadre`,`testadisticasjugador`.`visible` AS `visible`,(select round(avg((`tconvpartidos`.`pfScore` * 1.0)),0) from `tconvpartidos` where ((`tconvpartidos`.`idjugador` = `testadisticasjugador`.`idjugador`) and (`tconvpartidos`.`idtemporada` = `testadisticasjugador`.`idtemporada`) and (`tconvpartidos`.`pfScore` > 0))) AS `pfScore`,`testadisticasjugador`.`lavaropa` AS `lavaropa`,`testadisticasjugador`.`pfScore` AS `PFS`,`testadisticasjugador`.`evolucion` AS `evolucion` from `testadisticasjugador` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vestadisticaspordia`
--

/*!50001 DROP VIEW IF EXISTS `vestadisticaspordia`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vestadisticaspordia` AS select (select `tpublicidad`.`idanunciante` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `idsponsor`,(select `tanunciante`.`nombre` from `tanunciante` where (`tanunciante`.`id` = `idsponsor`)) AS `sponsor`,`ttelemetriapubli`.`idpublicidad` AS `idanuncio`,year(`ttelemetriapubli`.`fecha`) AS `anyo`,month(`ttelemetriapubli`.`fecha`) AS `mes`,dayofmonth(`ttelemetriapubli`.`fecha`) AS `dia`,week(`ttelemetriapubli`.`fecha`,0) AS `semana`,cast(`ttelemetriapubli`.`fecha` as date) AS `fecha`,sum(`ttelemetriapubli`.`visto`) AS `impresiones`,sum(`ttelemetriapubli`.`click`) AS `interacciones`,truncate(((sum(`ttelemetriapubli`.`click`) / sum(`ttelemetriapubli`.`visto`)) * 100),2) AS `ctr`,(select `tpublicidad`.`urlImagen` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `urlanuncio` from `ttelemetriapubli` group by `ttelemetriapubli`.`idpublicidad`,year(`ttelemetriapubli`.`fecha`),month(`ttelemetriapubli`.`fecha`),dayofmonth(`ttelemetriapubli`.`fecha`) order by `fecha` desc,`ttelemetriapubli`.`idanunciante` desc,`idanuncio` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vestadisticaspormes`
--

/*!50001 DROP VIEW IF EXISTS `vestadisticaspormes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vestadisticaspormes` AS select (select `tpublicidad`.`idanunciante` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `idsponsor`,(select `tanunciante`.`nombre` from `tanunciante` where (`tanunciante`.`id` = `idsponsor`)) AS `sponsor`,`ttelemetriapubli`.`idpublicidad` AS `idanuncio`,year(`ttelemetriapubli`.`fecha`) AS `anyo`,month(`ttelemetriapubli`.`fecha`) AS `mes`,dayofmonth(`ttelemetriapubli`.`fecha`) AS `dia`,week(`ttelemetriapubli`.`fecha`,0) AS `semana`,cast(`ttelemetriapubli`.`fecha` as date) AS `fecha`,sum(`ttelemetriapubli`.`visto`) AS `impresiones`,sum(`ttelemetriapubli`.`click`) AS `interacciones`,truncate(((sum(`ttelemetriapubli`.`click`) / sum(`ttelemetriapubli`.`visto`)) * 100),2) AS `ctr`,(select `tpublicidad`.`urlImagen` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `urlanuncio` from `ttelemetriapubli` group by `ttelemetriapubli`.`idpublicidad`,year(`ttelemetriapubli`.`fecha`),month(`ttelemetriapubli`.`fecha`),`ttelemetriapubli`.`fecha` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vestadisticasporsemana`
--

/*!50001 DROP VIEW IF EXISTS `vestadisticasporsemana`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vestadisticasporsemana` AS select (select `tpublicidad`.`idanunciante` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `idsponsor`,(select `tanunciante`.`nombre` from `tanunciante` where (`tanunciante`.`id` = `idsponsor`)) AS `sponsor`,`ttelemetriapubli`.`idpublicidad` AS `idanuncio`,year(`ttelemetriapubli`.`fecha`) AS `anyo`,month(`ttelemetriapubli`.`fecha`) AS `mes`,dayofmonth(`ttelemetriapubli`.`fecha`) AS `dia`,week(`ttelemetriapubli`.`fecha`,0) AS `semana`,cast(`ttelemetriapubli`.`fecha` as date) AS `fecha`,sum(`ttelemetriapubli`.`visto`) AS `impresiones`,sum(`ttelemetriapubli`.`click`) AS `interacciones`,truncate(((sum(`ttelemetriapubli`.`click`) / sum(`ttelemetriapubli`.`visto`)) * 100),2) AS `ctr`,(select `tpublicidad`.`urlImagen` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `urlanuncio` from `ttelemetriapubli` group by `ttelemetriapubli`.`idpublicidad`,`semana` order by `semana` desc,`ttelemetriapubli`.`idanunciante` desc,`idanuncio` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `veventos`
--

/*!50001 DROP VIEW IF EXISTS `veventos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `veventos` AS select `teventospartido`.`id` AS `id`,`teventospartido`.`idpartido` AS `idpartido`,`teventospartido`.`idjugador` AS `idjugador`,`teventospartido`.`idtemporada` AS `idtemporada`,`teventospartido`.`minuto` AS `minuto`,`teventospartido`.`tam` AS `tam`,`teventospartido`.`tam2` AS `tam2`,`teventospartido`.`tro` AS `tro`,`teventospartido`.`tamriv` AS `tamriv`,`teventospartido`.`troriv` AS `troriv`,`teventospartido`.`dorsal` AS `dorsal`,`teventospartido`.`gol` AS `gol`,`teventospartido`.`asistencia` AS `asistencia`,`teventospartido`.`golpropiopuerta` AS `golpropiopuerta`,`teventospartido`.`sale` AS `sale`,`teventospartido`.`entra` AS `entra`,`teventospartido`.`golencajado` AS `golencajado`,`teventospartido`.`lesion` AS `lesion`,`teventospartido`.`min` AS `min`,`teventospartido`.`fecha` AS `fecha`,`teventospartido`.`inicio` AS `inicio`,`teventospartido`.`descanso` AS `descanso`,`teventospartido`.`segundamitad` AS `segundamitad`,`teventospartido`.`fin` AS `fin`,`teventospartido`.`penalti` AS `penalti`,`teventospartido`.`penaltiparado` AS `penaltiparado`,`teventospartido`.`penaltiparadocontra` AS `penaltiparadocontra`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`activo` AS `activo`,`tclubes`.`club` AS `club`,`teventospartido`.`observaciones` AS `observaciones` from ((`teventospartido` join `tjugadores` on((`tjugadores`.`id` = `teventospartido`.`idjugador`))) join `tclubes` on((`tclubes`.`id` = `tjugadores`.`idclub`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `veventospublicidad`
--

/*!50001 DROP VIEW IF EXISTS `veventospublicidad`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `veventospublicidad` AS select `ttelemetriapubli`.`id` AS `id`,`ttelemetriapubli`.`idpublicidad` AS `idanuncio`,`ttelemetriapubli`.`idanunciante` AS `idsponsor`,`ttelemetriapubli`.`fecha` AS `timestamp`,cast(`ttelemetriapubli`.`fecha` as date) AS `fecha`,year(`ttelemetriapubli`.`fecha`) AS `anyo`,month(`ttelemetriapubli`.`fecha`) AS `mes`,week(`ttelemetriapubli`.`fecha`,0) AS `semana`,dayofmonth(`ttelemetriapubli`.`fecha`) AS `dia`,`ttelemetriapubli`.`visto` AS `impresiones`,`ttelemetriapubli`.`click` AS `interacciones`,`ttelemetriapubli`.`idperfil` AS `idperfil`,`ttelemetriapubli`.`idusuario` AS `idusuario`,`ttelemetriapubli`.`evento` AS `evento`,`ttelemetriapubli`.`idtemporada` AS `temporada`,(select `tpublicidad`.`urlImagen` from `tpublicidad` where (`tpublicidad`.`id` = `ttelemetriapubli`.`idpublicidad`)) AS `urlanuncio` from `ttelemetriapubli` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vinformes`
--

/*!50001 DROP VIEW IF EXISTS `vinformes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vinformes` AS select `tinformes`.`id` AS `id`,`tinformes`.`idequipo` AS `idequipo`,`tinformes`.`idusuario` AS `idusuario`,`tinformes`.`idclub` AS `idclub`,`tinformes`.`tipo` AS `tipo`,`tinformes`.`informe` AS `informe`,`tinformes`.`urldocumento` AS `urldocumento`,`tinformes`.`fechasubida` AS `fechasubida`,`tinformes`.`idtemporada` AS `idtemporada`,`tequipos`.`equipo` AS `equipo` from (`tinformes` join `tequipos` on((`tequipos`.`id` = `tinformes`.`idequipo`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugador`
--

/*!50001 DROP VIEW IF EXISTS `vjugador`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugador` AS select `tjugador`.`id` AS `id`,`tjugador`.`idcategoria` AS `idcategoria`,`tjugador`.`idposicion` AS `idposicion`,`tjugador`.`idpiedominante` AS `idpiedominante`,`tjugador`.`idestado` AS `idestado`,`tjugador`.`idtutor1` AS `idtutor1`,`tjugador`.`idtutor2` AS `idtutor2`,`tjugador`.`idprovincia` AS `idprovincia`,`tjugador`.`idlocalidad` AS `idlocalidad`,`tjugador`.`nombre` AS `nombre`,`tjugador`.`apellidos` AS `apellidos`,`tjugador`.`apodo` AS `apodo`,`tjugador`.`foto` AS `foto`,`tjugador`.`fechanacimiento` AS `fechanacimiento`,`tjugador`.`fechaalta` AS `fechaalta`,`tjugador`.`activo` AS `activo`,`tjugador`.`convocado` AS `convocado`,`tjugador`.`conventreno` AS `conventreno`,`tjugador`.`peso` AS `peso`,`tjugador`.`altura` AS `altura`,`tjugador`.`domicilio` AS `domicilio`,`tjugador`.`email` AS `email`,`tjugador`.`telefono` AS `telefono`,`tjugador`.`dni` AS `dni`,`tjugador`.`emailtutor1` AS `emailtutor1`,`tjugador`.`emailtutor2` AS `emailtutor2`,`tjugador`.`tutor1` AS `tutor1`,`tjugador`.`tutor2` AS `tutor2`,`tjugador`.`codigoactivacion` AS `codigoactivacion`,`tjugador`.`idtipocuota` AS `idtipocuota`,`tjugador`.`dorsal` AS `dorsal`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tcategorias`.`categoria` AS `categoria`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testadojugador`.`estado` AS `estado`,`tposiciones`.`photourl` AS `imgposicion`,`testadojugador`.`photourl` AS `imgestado`,`testjugador`.`pj` AS `pj`,`testjugador`.`idtemporada` AS `idtemporada`,`testjugador`.`ptitular` AS `ptitular`,`testjugador`.`plesionado` AS `plesionado`,`testjugador`.`goles` AS `goles`,`testjugador`.`penalti` AS `penalti`,`testjugador`.`ta` AS `ta`,`testjugador`.`ta2` AS `ta2`,`testjugador`.`tr` AS `tr`,`testjugador`.`minutos` AS `minutos`,`testjugador`.`valoracion` AS `valoracion`,`testjugador`.`capitan` AS `capitan`,`testjugador`.`observaciones` AS `observaciones`,`testjugador`.`obspadre` AS `obspadre`,`testjugador`.`obsclub` AS `obsclub`,`testjugador`.`idclub` AS `idclub`,`testjugador`.`idequipo` AS `idequipo`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `testjugador`.`idtemporada`)) AS `temporada`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testjugador`.`idequipo`)) AS `equipo` from (((((((`tjugador` join `tcategorias` on((`tcategorias`.`id` = `tjugador`.`idcategoria`))) join `tposiciones` on((`tposiciones`.`id` = `tjugador`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugador`.`idpiedominante`))) join `testadojugador` on((`testadojugador`.`id` = `tjugador`.`idestado`))) join `testjugador` on((`testjugador`.`idjugador` = `tjugador`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugador`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugador`.`idprovincia`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugador_estadisticas_json`
--

/*!50001 DROP VIEW IF EXISTS `vjugador_estadisticas_json`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugador_estadisticas_json` AS select `testadisticasjugador`.`idjugador` AS `idjugador`,json_arrayagg(json_object('idtemporada',`testadisticasjugador`.`idtemporada`,'idclub',`testadisticasjugador`.`idclub`,'idequipo',`testadisticasjugador`.`idequipo`,'pj',`testadisticasjugador`.`pj`,'ptitular',`testadisticasjugador`.`ptitular`,'plesionado',`testadisticasjugador`.`plesionado`,'goles',`testadisticasjugador`.`goles`,'ta',`testadisticasjugador`.`ta`,'ta2',`testadisticasjugador`.`ta2`,'tr',`testadisticasjugador`.`tr`,'minutos',`testadisticasjugador`.`minutos`,'valoracion',(select avg(nullif(`tp`.`valoracion`,0)) from `tconvpartidos` `tp` where ((`tp`.`idjugador` = `testadisticasjugador`.`idjugador`) and (`tp`.`idtemporada` = `testadisticasjugador`.`idtemporada`) and (`tp`.`finalizado` = 1))),'capitan',`testadisticasjugador`.`capitan`,'penalti',`testadisticasjugador`.`penalti`,'observaciones',`testadisticasjugador`.`observaciones`,'visible',`testadisticasjugador`.`visible`,'asistencias',`testadisticasjugador`.`asistencias`,'pfScore',`testadisticasjugador`.`pfScore`,'evolucion',`testadisticasjugador`.`evolucion`)) AS `estadisticas` from `testadisticasjugador` group by `testadisticasjugador`.`idjugador` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadores`
--

/*!50001 DROP VIEW IF EXISTS `vjugadores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadores` AS select `tjugadores`.`id` AS `id`,`tjugadores`.`idcategoria` AS `idcategoria`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`idpiedominante` AS `idpiedominante`,`tjugadores`.`idestado` AS `idestado`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`activo` AS `activo`,(select `tclubes`.`idprovincia` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `idprovjuega`,`tjugadores`.`idprovincia` AS `idprovincia`,`tjugadores`.`idlocalidad` AS `idlocalidad`,`tjugadores`.`nombre` AS `nombre`,`tjugadores`.`apellidos` AS `apellidos`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`ficha` AS `ficha`,`tjugadores`.`fechanacimiento` AS `fechanacimiento`,`tjugadores`.`fechaalta` AS `fechaalta`,`tjugadores`.`convocado` AS `convocado`,`tjugadores`.`conventreno` AS `conventreno`,`tjugadores`.`peso` AS `peso`,`tjugadores`.`altura` AS `altura`,`tjugadores`.`domicilio` AS `domicilio`,`tjugadores`.`email` AS `email`,`tjugadores`.`telefono` AS `telefono`,`tjugadores`.`dni` AS `dni`,`tjugadores`.`emailtutor1` AS `emailtutor1`,`tjugadores`.`emailtutor2` AS `emailtutor2`,`tjugadores`.`tutor1` AS `tutor1`,`tjugadores`.`tutor2` AS `tutor2`,`tjugadores`.`codigoactivacion` AS `codigoactivacion`,`tjugadores`.`idtipocuota` AS `idtipocuota`,`tjugadores`.`dorsal` AS `dorsal`,`tjugadores`.`observaciones` AS `observaciones`,`tjugadores`.`obspadre` AS `obspadre`,`tjugadores`.`nota` AS `nota`,`tjugadores`.`obsclub` AS `obsclub`,`tjugadores`.`informe` AS `informe`,`tjugadores`.`recmedico` AS `recmedico`,`tjugadores`.`fecharecmedico` AS `fecharecmedico`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tcategorias`.`categoria` AS `categoria`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testadojugador`.`estado` AS `estado`,`tposiciones`.`photourl` AS `imgposicion`,`testadojugador`.`photourl` AS `imgestado`,`testadisticasjugador`.`pj` AS `pj`,`testadisticasjugador`.`ptitular` AS `ptitular`,`testadisticasjugador`.`plesionado` AS `plesionado`,`testadisticasjugador`.`idtemporada` AS `idtemporada`,`testadisticasjugador`.`idclub` AS `idclub`,`testadisticasjugador`.`idequipo` AS `idequipo`,`testadisticasjugador`.`visible` AS `visible`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testadisticasjugador`.`idequipo`)) AS `equipo`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `testadisticasjugador`.`idtemporada`)) AS `temporada`,`testadisticasjugador`.`goles` AS `goles`,`testadisticasjugador`.`penalti` AS `penalti`,`testadisticasjugador`.`ta` AS `ta`,`testadisticasjugador`.`ta2` AS `ta2`,`testadisticasjugador`.`tr` AS `tr`,`testadisticasjugador`.`minutos` AS `minutos`,`testadisticasjugador`.`valoracion` AS `valoracion`,`testadisticasjugador`.`capitan` AS `capitan` from (((((((`tjugadores` join `tcategorias` on((`tcategorias`.`id` = `tjugadores`.`idcategoria`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugadores`.`idpiedominante`))) join `testadojugador` on((`testadojugador`.`id` = `tjugadores`.`idestado`))) join `testadisticasjugador` on((`testadisticasjugador`.`idjugador` = `tjugadores`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugadores`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugadores`.`idprovincia`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadoresFB`
--

/*!50001 DROP VIEW IF EXISTS `vjugadoresFB`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadoresFB` AS select `j`.`id` AS `id`,`j`.`idcategoria` AS `idcategoria`,`j`.`idposicion` AS `idposicion`,`j`.`idpiedominante` AS `idpiedominante`,`j`.`idestado` AS `idestado`,`j`.`idtutor1` AS `idtutor1`,`j`.`idtutor2` AS `idtutor2`,`j`.`activo` AS `activo`,`c`.`idprovincia` AS `idprovjuega`,`j`.`idprovincia` AS `idprovincia`,`j`.`idlocalidad` AS `idlocalidad`,`j`.`nombre` AS `nombre`,`j`.`apellidos` AS `apellidos`,`j`.`apodo` AS `apodo`,`j`.`foto` AS `foto`,`j`.`ficha` AS `ficha`,`j`.`fechanacimiento` AS `fechanacimiento`,`j`.`fechaalta` AS `fechaalta`,`j`.`convocado` AS `convocado`,`j`.`conventreno` AS `conventreno`,`j`.`peso` AS `peso`,`j`.`altura` AS `altura`,`j`.`domicilio` AS `domicilio`,`j`.`email` AS `email`,`j`.`telefono` AS `telefono`,`j`.`dni` AS `dni`,`j`.`emailtutor1` AS `emailtutor1`,`j`.`emailtutor2` AS `emailtutor2`,`j`.`tutor1` AS `tutor1`,`j`.`tutor2` AS `tutor2`,`j`.`codigoactivacion` AS `codigoactivacion`,`j`.`idtipocuota` AS `idtipocuota`,`j`.`dorsal` AS `dorsal`,`j`.`observaciones` AS `observaciones`,`j`.`obspadre` AS `obspadre`,`j`.`obsclub` AS `obsclub`,`j`.`informe` AS `informe`,`j`.`recmedico` AS `recmedico`,`j`.`fecharecmedico` AS `fecharecmedico`,`l`.`localidad` AS `localidad`,`p`.`provincia` AS `provincia`,`cat`.`categoria` AS `categoria`,`pos`.`posicion` AS `posicion`,`pie`.`pie` AS `pie`,`est`.`estado` AS `estado`,`pos`.`photourl` AS `imgposicion`,`est`.`photourl` AS `imgestado`,`ej`.`pj` AS `pj`,`ej`.`ptitular` AS `ptitular`,`ej`.`plesionado` AS `plesionado`,`ej`.`idtemporada` AS `idtemporada`,`ej`.`idclub` AS `idclub`,`ej`.`idequipo` AS `idequipo`,`ej`.`visible` AS `visible`,`c`.`club` AS `club`,`e`.`equipo` AS `equipo`,`t`.`temporada` AS `temporada`,`u`.`idjugador` AS `iduser`,`ej`.`goles` AS `goles`,`ej`.`penalti` AS `penalti`,`ej`.`ta` AS `ta`,`ej`.`ta2` AS `ta2`,`ej`.`tr` AS `tr`,`ej`.`minutos` AS `minutos`,`ej`.`valoracion` AS `valoracion`,`ej`.`capitan` AS `capitan` from (((((((((((`tjugadores` `j` join `tcategorias` `cat` on((`cat`.`id` = `j`.`idcategoria`))) join `tposiciones` `pos` on((`pos`.`id` = `j`.`idposicion`))) join `tpiedominante` `pie` on((`pie`.`id` = `j`.`idpiedominante`))) join `testadojugador` `est` on((`est`.`id` = `j`.`idestado`))) join `testadisticasjugador` `ej` on((`ej`.`idjugador` = `j`.`id`))) left join `tclubes` `c` on((`c`.`id` = `ej`.`idclub`))) left join `tequipos` `e` on((`e`.`id` = `ej`.`idequipo`))) left join `ttemporadas` `t` on((`t`.`id` = `ej`.`idtemporada`))) left join `tusuarios` `u` on((`u`.`idjugador` = `j`.`id`))) join `tlocalidades` `l` on((`l`.`id` = `j`.`idlocalidad`))) join `tprovincias` `p` on((`p`.`id` = `j`.`idprovincia`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadoresFB_antigua`
--

/*!50001 DROP VIEW IF EXISTS `vjugadoresFB_antigua`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadoresFB_antigua` AS select `tjugadores`.`id` AS `id`,`tjugadores`.`idcategoria` AS `idcategoria`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`idpiedominante` AS `idpiedominante`,`tjugadores`.`idestado` AS `idestado`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`activo` AS `activo`,(select `tclubes`.`idprovincia` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `idprovjuega`,`tjugadores`.`idprovincia` AS `idprovincia`,`tjugadores`.`idlocalidad` AS `idlocalidad`,`tjugadores`.`nombre` AS `nombre`,`tjugadores`.`apellidos` AS `apellidos`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`ficha` AS `ficha`,`tjugadores`.`fechanacimiento` AS `fechanacimiento`,`tjugadores`.`fechaalta` AS `fechaalta`,`tjugadores`.`convocado` AS `convocado`,`tjugadores`.`conventreno` AS `conventreno`,`tjugadores`.`peso` AS `peso`,`tjugadores`.`altura` AS `altura`,`tjugadores`.`domicilio` AS `domicilio`,`tjugadores`.`email` AS `email`,`tjugadores`.`telefono` AS `telefono`,`tjugadores`.`dni` AS `dni`,`tjugadores`.`emailtutor1` AS `emailtutor1`,`tjugadores`.`emailtutor2` AS `emailtutor2`,`tjugadores`.`tutor1` AS `tutor1`,`tjugadores`.`tutor2` AS `tutor2`,`tjugadores`.`codigoactivacion` AS `codigoactivacion`,`tjugadores`.`idtipocuota` AS `idtipocuota`,`tjugadores`.`dorsal` AS `dorsal`,`tjugadores`.`observaciones` AS `observaciones`,`tjugadores`.`obspadre` AS `obspadre`,`tjugadores`.`obsclub` AS `obsclub`,`tjugadores`.`informe` AS `informe`,`tjugadores`.`recmedico` AS `recmedico`,`tjugadores`.`fecharecmedico` AS `fecharecmedico`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tcategorias`.`categoria` AS `categoria`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testadojugador`.`estado` AS `estado`,`tposiciones`.`photourl` AS `imgposicion`,`testadojugador`.`photourl` AS `imgestado`,`testadisticasjugador`.`pj` AS `pj`,`testadisticasjugador`.`ptitular` AS `ptitular`,`testadisticasjugador`.`plesionado` AS `plesionado`,`testadisticasjugador`.`idtemporada` AS `idtemporada`,`testadisticasjugador`.`idclub` AS `idclub`,`testadisticasjugador`.`idequipo` AS `idequipo`,`testadisticasjugador`.`visible` AS `visible`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testadisticasjugador`.`idequipo`)) AS `equipo`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `testadisticasjugador`.`idtemporada`)) AS `temporada`,(select `tusuarios`.`idjugador` from `tusuarios` where (`tusuarios`.`idjugador` = `tjugadores`.`id`)) AS `iduser`,`testadisticasjugador`.`goles` AS `goles`,`testadisticasjugador`.`penalti` AS `penalti`,`testadisticasjugador`.`ta` AS `ta`,`testadisticasjugador`.`ta2` AS `ta2`,`testadisticasjugador`.`tr` AS `tr`,`testadisticasjugador`.`minutos` AS `minutos`,`testadisticasjugador`.`valoracion` AS `valoracion`,`testadisticasjugador`.`capitan` AS `capitan` from (((((((`tjugadores` join `tcategorias` on((`tcategorias`.`id` = `tjugadores`.`idcategoria`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugadores`.`idpiedominante`))) join `testadojugador` on((`testadojugador`.`id` = `tjugadores`.`idestado`))) join `testadisticasjugador` on((`testadisticasjugador`.`idjugador` = `tjugadores`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugadores`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugadores`.`idprovincia`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadores_stats_completa`
--

/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadores_stats_completa` AS select `tjugadores`.`id` AS `id`,`tjugadores`.`idcategoria` AS `idcategoria`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`idpiedominante` AS `idpiedominante`,`tjugadores`.`idestado` AS `idestado`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`activo` AS `activo`,(select `tclubes`.`idprovincia` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `idprovjuega`,`tjugadores`.`idprovincia` AS `idprovincia`,`tjugadores`.`idlocalidad` AS `idlocalidad`,`tjugadores`.`nombre` AS `nombre`,`tjugadores`.`apellidos` AS `apellidos`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`ficha` AS `ficha`,`tjugadores`.`fechanacimiento` AS `fechanacimiento`,`tjugadores`.`fechaalta` AS `fechaalta`,`tjugadores`.`convocado` AS `convocado`,`tjugadores`.`conventreno` AS `conventreno`,`tjugadores`.`peso` AS `peso`,`tjugadores`.`altura` AS `altura`,`tjugadores`.`domicilio` AS `domicilio`,`tjugadores`.`email` AS `email`,`tjugadores`.`telefono` AS `telefono`,`tjugadores`.`dni` AS `dni`,`tjugadores`.`emailtutor1` AS `emailtutor1`,`tjugadores`.`emailtutor2` AS `emailtutor2`,`tjugadores`.`tutor1` AS `tutor1`,`tjugadores`.`tutor2` AS `tutor2`,`tjugadores`.`codigoactivacion` AS `codigoactivacion`,`tjugadores`.`idtipocuota` AS `idtipocuota`,`tjugadores`.`dorsal` AS `dorsal`,`tjugadores`.`observaciones` AS `observaciones`,`tjugadores`.`obspadre` AS `obspadre`,`tjugadores`.`nota` AS `nota`,`tjugadores`.`obsclub` AS `obsclub`,`tjugadores`.`informe` AS `informe`,`tjugadores`.`recmedico` AS `recmedico`,`tjugadores`.`fecharecmedico` AS `fecharecmedico`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tcategorias`.`categoria` AS `categoria`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testadojugador`.`estado` AS `estado`,`tposiciones`.`photourl` AS `imgposicion`,`testadojugador`.`photourl` AS `imgestado`,`testadisticasjugador`.`pj` AS `pj`,`testadisticasjugador`.`ptitular` AS `ptitular`,`testadisticasjugador`.`plesionado` AS `plesionado`,`testadisticasjugador`.`idtemporada` AS `idtemporada`,`testadisticasjugador`.`idclub` AS `idclub`,`testadisticasjugador`.`idequipo` AS `idequipo`,`testadisticasjugador`.`visible` AS `visible`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testadisticasjugador`.`idequipo`)) AS `equipo`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `testadisticasjugador`.`idtemporada`)) AS `temporada`,`testadisticasjugador`.`goles` AS `goles`,`testadisticasjugador`.`penalti` AS `penalti`,`testadisticasjugador`.`ta` AS `ta`,`testadisticasjugador`.`ta2` AS `ta2`,`testadisticasjugador`.`tr` AS `tr`,`testadisticasjugador`.`minutos` AS `minutos`,`testadisticasjugador`.`valoracion` AS `valoracion`,`testadisticasjugador`.`capitan` AS `capitan`,`ve`.`estadisticas` AS `estadisticas` from ((((((((`tjugadores` join `tcategorias` on((`tcategorias`.`id` = `tjugadores`.`idcategoria`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugadores`.`idpiedominante`))) join `testadojugador` on((`testadojugador`.`id` = `tjugadores`.`idestado`))) join `testadisticasjugador` on((`testadisticasjugador`.`idjugador` = `tjugadores`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugadores`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugadores`.`idprovincia`))) left join `vjugador_estadisticas_json` `ve` on((`ve`.`idjugador` = `tjugadores`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadores_stats_completa_v2`
--

/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa_v2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadores_stats_completa_v2` AS select `tjugadores`.`id` AS `id`,`tjugadores`.`idcategoria` AS `idcategoria`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`idpiedominante` AS `idpiedominante`,`tjugadores`.`idestado` AS `idestado`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`activo` AS `activo`,(select `tclubes`.`idprovincia` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `idprovjuega`,`tjugadores`.`idprovincia` AS `idprovincia`,`tjugadores`.`idlocalidad` AS `idlocalidad`,`tjugadores`.`nombre` AS `nombre`,`tjugadores`.`apellidos` AS `apellidos`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`ficha` AS `ficha`,`tjugadores`.`fechanacimiento` AS `fechanacimiento`,`tjugadores`.`fechaalta` AS `fechaalta`,`tjugadores`.`convocado` AS `convocado`,`tjugadores`.`conventreno` AS `conventreno`,`tjugadores`.`peso` AS `peso`,`tjugadores`.`altura` AS `altura`,`tjugadores`.`domicilio` AS `domicilio`,`tjugadores`.`email` AS `email`,`tjugadores`.`telefono` AS `telefono`,`tjugadores`.`dni` AS `dni`,`tjugadores`.`emailtutor1` AS `emailtutor1`,`tjugadores`.`emailtutor2` AS `emailtutor2`,`tjugadores`.`tutor1` AS `tutor1`,`tjugadores`.`tutor2` AS `tutor2`,`tjugadores`.`codigoactivacion` AS `codigoactivacion`,`tjugadores`.`idtipocuota` AS `idtipocuota`,`tjugadores`.`dorsal` AS `dorsal`,`tjugadores`.`observaciones` AS `observaciones`,`tjugadores`.`obspadre` AS `obspadre`,`tjugadores`.`nota` AS `nota`,`tjugadores`.`obsclub` AS `obsclub`,`tjugadores`.`informe` AS `informe`,`tjugadores`.`recmedico` AS `recmedico`,`tjugadores`.`fecharecmedico` AS `fecharecmedico`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tcategorias`.`categoria` AS `categoria`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testadojugador`.`estado` AS `estado`,`tposiciones`.`photourl` AS `imgposicion`,`testadojugador`.`photourl` AS `imgestado`,`testadisticasjugador`.`pj` AS `pj`,`testadisticasjugador`.`ptitular` AS `ptitular`,`testadisticasjugador`.`plesionado` AS `plesionado`,`testadisticasjugador`.`idtemporada` AS `idtemporada`,`testadisticasjugador`.`idclub` AS `idclub`,`testadisticasjugador`.`idequipo` AS `idequipo`,`testadisticasjugador`.`visible` AS `visible`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testadisticasjugador`.`idequipo`)) AS `equipo`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `testadisticasjugador`.`idtemporada`)) AS `temporada`,`testadisticasjugador`.`goles` AS `goles`,`testadisticasjugador`.`penalti` AS `penalti`,`testadisticasjugador`.`ta` AS `ta`,`testadisticasjugador`.`ta2` AS `ta2`,`testadisticasjugador`.`tr` AS `tr`,`testadisticasjugador`.`minutos` AS `minutos`,`testadisticasjugador`.`valoracion` AS `valoracion`,`testadisticasjugador`.`capitan` AS `capitan`,`ve`.`estadisticas` AS `estadisticas`,(select `vr`.`title` from `vroles` `vr` where ((`vr`.`tipo` = 5) and (`vr`.`idjugador` = `tjugadores`.`id`)) limit 1) AS `roljugador`,(select group_concat(distinct `vr2`.`title` separator ',') from `vroles` `vr2` where ((`vr2`.`tipo` = 4) and ((`vr2`.`idjugador` = `tjugadores`.`id`) or (`vr2`.`idjugador2` = `tjugadores`.`id`) or (`vr2`.`idjugador3` = `tjugadores`.`id`) or (`vr2`.`idjugador4` = `tjugadores`.`id`)))) AS `troles` from ((((((((`tjugadores` join `tcategorias` on((`tcategorias`.`id` = `tjugadores`.`idcategoria`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugadores`.`idpiedominante`))) join `testadojugador` on((`testadojugador`.`id` = `tjugadores`.`idestado`))) join `testadisticasjugador` on((`testadisticasjugador`.`idjugador` = `tjugadores`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugadores`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugadores`.`idprovincia`))) left join `vjugador_estadisticas_json` `ve` on((`ve`.`idjugador` = `tjugadores`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadores_stats_completa_v3`
--

/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa_v3`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadores_stats_completa_v3` AS select `tj`.`id` AS `id`,`tj`.`idcategoria` AS `idcategoria`,`tj`.`idposicion` AS `idposicion`,`tj`.`idpiedominante` AS `idpiedominante`,`tj`.`idestado` AS `idestado`,`tj`.`idtutor1` AS `idtutor1`,`tj`.`idtutor2` AS `idtutor2`,`tj`.`activo` AS `activo`,`c_juega`.`idprovincia` AS `idprovjuega`,`tj`.`idprovincia` AS `idprovincia`,`tj`.`idlocalidad` AS `idlocalidad`,`tj`.`nombre` AS `nombre`,`tj`.`apellidos` AS `apellidos`,`tj`.`apodo` AS `apodo`,`tj`.`foto` AS `foto`,`tj`.`ficha` AS `ficha`,`tj`.`fechanacimiento` AS `fechanacimiento`,`tj`.`fechaalta` AS `fechaalta`,`tj`.`convocado` AS `convocado`,`tj`.`conventreno` AS `conventreno`,`tj`.`peso` AS `peso`,`tj`.`altura` AS `altura`,`tj`.`domicilio` AS `domicilio`,`tj`.`email` AS `email`,`tj`.`telefono` AS `telefono`,`tj`.`dni` AS `dni`,`tj`.`emailtutor1` AS `emailtutor1`,`tj`.`emailtutor2` AS `emailtutor2`,`tj`.`tutor1` AS `tutor1`,`tj`.`tutor2` AS `tutor2`,`tj`.`codigoactivacion` AS `codigoactivacion`,`tj`.`idtipocuota` AS `idtipocuota`,`tj`.`dorsal` AS `dorsal`,`tj`.`observaciones` AS `observaciones`,`tj`.`obspadre` AS `obspadre`,`tj`.`nota` AS `nota`,`tj`.`obsclub` AS `obsclub`,`tj`.`informe` AS `informe`,`tj`.`recmedico` AS `recmedico`,`tj`.`fecharecmedico` AS `fecharecmedico`,`tl`.`localidad` AS `localidad`,`tp`.`provincia` AS `provincia`,`tc`.`categoria` AS `categoria`,`tp2`.`posicion` AS `posicion`,`tpd`.`pie` AS `pie`,`te`.`estado` AS `estado`,`tp2`.`photourl` AS `imgposicion`,`te`.`photourl` AS `imgestado`,`ls`.`pj` AS `pj`,`ls`.`ptitular` AS `ptitular`,`ls`.`plesionado` AS `plesionado`,`ls`.`idtemporada` AS `idtemporada`,`ls`.`idclub` AS `idclub`,`ls`.`idequipo` AS `idequipo`,`ls`.`visible` AS `visible`,`ls`.`asistencias` AS `asistencias`,`ls`.`goles` AS `goles`,`ls`.`penalti` AS `penalti`,`ls`.`ta` AS `ta`,`ls`.`ta2` AS `ta2`,`ls`.`tr` AS `tr`,`ls`.`minutos` AS `minutos`,`ls`.`valoracion` AS `valoracion`,`ls`.`capitan` AS `capitan`,`ls`.`pfScore` AS `pfScore`,`ls`.`evolucion` AS `evolucion`,`ls`.`valcoordinador` AS `valcoordinador`,`ls`.`lavaropa` AS `lavaropa`,`ls`.`perdidas` AS `perdidas`,`ls`.`recuperaciones` AS `recuperaciones`,`ls`.`paradas` AS `paradas`,`ls`.`despejes` AS `despejes`,`ls`.`salidas` AS `salidas`,`ls`.`fallos` AS `fallos`,`ls`.`fjuego` AS `fjuego`,`ls`.`faltacom` AS `faltacom`,`ls`.`faltarec` AS `faltarec`,`ls`.`tiroap` AS `tiroap`,`ls`.`tirofuera` AS `tirofuera`,`ls`.`observaciones` AS `estad_observaciones`,`ls`.`obsclub` AS `estad_obsclub`,`ls`.`obspadre` AS `estad_obspadre`,`c_juega`.`club` AS `club`,`e`.`equipo` AS `equipo`,`ttempor`.`temporada` AS `temporada`,`ve`.`estadisticas` AS `estadisticas`,`rdata`.`roljugador` AS `roljugador`,`rdata`.`tutores` AS `tutores` from ((((((((((((`tjugadores` `tj` left join (select `est`.`id` AS `id`,`est`.`idclub` AS `idclub`,`est`.`idequipo` AS `idequipo`,`est`.`idjugador` AS `idjugador`,`est`.`idtemporada` AS `idtemporada`,`est`.`pj` AS `pj`,`est`.`ptitular` AS `ptitular`,`est`.`plesionado` AS `plesionado`,`est`.`asistencias` AS `asistencias`,`est`.`goles` AS `goles`,`est`.`golpp` AS `golpp`,`est`.`ta` AS `ta`,`est`.`ta2` AS `ta2`,`est`.`tr` AS `tr`,`est`.`minutos` AS `minutos`,`est`.`valoracion` AS `valoracion`,`est`.`capitan` AS `capitan`,`est`.`penalti` AS `penalti`,`est`.`observaciones` AS `observaciones`,`est`.`obsclub` AS `obsclub`,`est`.`obspadre` AS `obspadre`,`est`.`visible` AS `visible`,`est`.`pfScore` AS `pfScore`,`est`.`evolucion` AS `evolucion`,`est`.`valcoordinador` AS `valcoordinador`,`est`.`lavaropa` AS `lavaropa`,`est`.`perdidas` AS `perdidas`,`est`.`recuperaciones` AS `recuperaciones`,`est`.`paradas` AS `paradas`,`est`.`despejes` AS `despejes`,`est`.`salidas` AS `salidas`,`est`.`fallos` AS `fallos`,`est`.`fjuego` AS `fjuego`,`est`.`faltacom` AS `faltacom`,`est`.`faltarec` AS `faltarec`,`est`.`tiroap` AS `tiroap`,`est`.`tirofuera` AS `tirofuera` from (`testadisticasjugador` `est` join (select `testadisticasjugador`.`idjugador` AS `idjugador`,max(`testadisticasjugador`.`idtemporada`) AS `max_temp` from `testadisticasjugador` where (`testadisticasjugador`.`visible` = 1) group by `testadisticasjugador`.`idjugador`) `ult` on(((`ult`.`idjugador` = `est`.`idjugador`) and (`ult`.`max_temp` = `est`.`idtemporada`)))) where (`est`.`visible` = 1)) `ls` on((`ls`.`idjugador` = `tj`.`id`))) left join `tclubes` `c_juega` on((`c_juega`.`id` = `ls`.`idclub`))) left join `tequipos` `e` on((`e`.`id` = `ls`.`idequipo`))) left join `ttemporadas` `ttempor` on((`ttempor`.`id` = `ls`.`idtemporada`))) left join `tlocalidades` `tl` on((`tl`.`id` = `tj`.`idlocalidad`))) left join `tprovincias` `tp` on((`tp`.`id` = `tj`.`idprovincia`))) left join `tcategorias` `tc` on((`tc`.`id` = `tj`.`idcategoria`))) left join `tposiciones` `tp2` on((`tp2`.`id` = `tj`.`idposicion`))) left join `tpiedominante` `tpd` on((`tpd`.`id` = `tj`.`idpiedominante`))) left join `testadojugador` `te` on((`te`.`id` = `tj`.`idestado`))) left join `vjugador_estadisticas_json` `ve` on((`ve`.`idjugador` = `tj`.`id`))) left join (select `r`.`idjugador` AS `idjugador_real`,min((case when (`r`.`tipo` = 5) then concat(`u`.`nombre`,' ',`u`.`apellidos`,' (',`u`.`email`,') - ',`tr`.`title`) end)) AS `roljugador`,json_arrayagg((case when (`r`.`tipo` = 4) then json_object('nombre',`u`.`nombre`,'apellidos',`u`.`apellidos`,'email',`u`.`email`,'title',`tr`.`title`) end)) AS `tutores` from ((`troles` `r` join `ttiporol` `tr` on((`tr`.`tipo` = `r`.`tipo`))) join `tusuarios` `u` on((`u`.`id` = `r`.`idusuario`))) where (`r`.`idjugador` is not null) group by `r`.`idjugador`) `rdata` on((`rdata`.`idjugador_real` = `tj`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugadores_stats_completa_v3_real`
--

/*!50001 DROP VIEW IF EXISTS `vjugadores_stats_completa_v3_real`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugadores_stats_completa_v3_real` AS select `tjugadores`.`id` AS `id`,`tjugadores`.`idcategoria` AS `idcategoria`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`idpiedominante` AS `idpiedominante`,`tjugadores`.`idestado` AS `idestado`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`activo` AS `activo`,(select `tclubes`.`idprovincia` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `idprovjuega`,`tjugadores`.`idprovincia` AS `idprovincia`,`tjugadores`.`idlocalidad` AS `idlocalidad`,`tjugadores`.`nombre` AS `nombre`,`tjugadores`.`apellidos` AS `apellidos`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`ficha` AS `ficha`,`tjugadores`.`fechanacimiento` AS `fechanacimiento`,`tjugadores`.`fechaalta` AS `fechaalta`,`tjugadores`.`convocado` AS `convocado`,`tjugadores`.`conventreno` AS `conventreno`,`tjugadores`.`peso` AS `peso`,`tjugadores`.`altura` AS `altura`,`tjugadores`.`domicilio` AS `domicilio`,`tjugadores`.`email` AS `email`,`tjugadores`.`telefono` AS `telefono`,`tjugadores`.`dni` AS `dni`,`tjugadores`.`emailtutor1` AS `emailtutor1`,`tjugadores`.`emailtutor2` AS `emailtutor2`,`tjugadores`.`tutor1` AS `tutor1`,`tjugadores`.`tutor2` AS `tutor2`,`tjugadores`.`codigoactivacion` AS `codigoactivacion`,`tjugadores`.`idtipocuota` AS `idtipocuota`,`tjugadores`.`dorsal` AS `dorsal`,`tjugadores`.`observaciones` AS `observaciones`,`tjugadores`.`obspadre` AS `obspadre`,`tjugadores`.`nota` AS `nota`,`tjugadores`.`obsclub` AS `obsclub`,`tjugadores`.`informe` AS `informe`,`tjugadores`.`recmedico` AS `recmedico`,`tjugadores`.`fecharecmedico` AS `fecharecmedico`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tcategorias`.`categoria` AS `categoria`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testadojugador`.`estado` AS `estado`,`tposiciones`.`photourl` AS `imgposicion`,`testadojugador`.`photourl` AS `imgestado`,`testadisticasjugador`.`pj` AS `pj`,`testadisticasjugador`.`ptitular` AS `ptitular`,`testadisticasjugador`.`plesionado` AS `plesionado`,`testadisticasjugador`.`idtemporada` AS `idtemporada`,`testadisticasjugador`.`idclub` AS `idclub`,`testadisticasjugador`.`idequipo` AS `idequipo`,`testadisticasjugador`.`visible` AS `visible`,`testadisticasjugador`.`asistencias` AS `asistencias`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testadisticasjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testadisticasjugador`.`idequipo`)) AS `equipo`,(select `ttemporadas`.`temporada` from `ttemporadas` where (`ttemporadas`.`id` = `testadisticasjugador`.`idtemporada`)) AS `temporada`,`testadisticasjugador`.`goles` AS `goles`,`testadisticasjugador`.`penalti` AS `penalti`,`testadisticasjugador`.`ta` AS `ta`,`testadisticasjugador`.`ta2` AS `ta2`,`testadisticasjugador`.`tr` AS `tr`,`testadisticasjugador`.`minutos` AS `minutos`,`testadisticasjugador`.`valoracion` AS `valoracion`,`testadisticasjugador`.`capitan` AS `capitan`,`ve`.`estadisticas` AS `estadisticas`,(select concat(`vr`.`nombre`,' ',`vr`.`apellidos`,' (',`vr`.`email`,') - ',`vr`.`title`) from `vroles` `vr` where ((`vr`.`tipo` = 5) and (`vr`.`idjugador` = `tjugadores`.`id`)) limit 1) AS `roljugador`,(select concat('[',group_concat(distinct concat('"',`vr2`.`nombre`,' ',`vr2`.`apellidos`,' (',`vr2`.`email`,') - ',`vr2`.`title`,'"') separator ','),']') from `vroles` `vr2` where ((`vr2`.`tipo` = 4) and ((`vr2`.`idjugador` = `tjugadores`.`id`) or (`vr2`.`idjugador2` = `tjugadores`.`id`) or (`vr2`.`idjugador3` = `tjugadores`.`id`) or (`vr2`.`idjugador4` = `tjugadores`.`id`)))) AS `tutores` from ((((((((`tjugadores` join `tcategorias` on((`tcategorias`.`id` = `tjugadores`.`idcategoria`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugadores`.`idpiedominante`))) join `testadojugador` on((`testadojugador`.`id` = `tjugadores`.`idestado`))) join (select `est`.`id` AS `id`,`est`.`idclub` AS `idclub`,`est`.`idequipo` AS `idequipo`,`est`.`idjugador` AS `idjugador`,`est`.`idtemporada` AS `idtemporada`,`est`.`pj` AS `pj`,`est`.`ptitular` AS `ptitular`,`est`.`plesionado` AS `plesionado`,`est`.`asistencias` AS `asistencias`,`est`.`goles` AS `goles`,`est`.`ta` AS `ta`,`est`.`ta2` AS `ta2`,`est`.`tr` AS `tr`,`est`.`minutos` AS `minutos`,`est`.`valoracion` AS `valoracion`,`est`.`capitan` AS `capitan`,`est`.`penalti` AS `penalti`,`est`.`observaciones` AS `observaciones`,`est`.`obsclub` AS `obsclub`,`est`.`obspadre` AS `obspadre`,`est`.`visible` AS `visible`,`est`.`pfScore` AS `pfScore`,`est`.`evolucion` AS `evolucion`,`est`.`valcoordinador` AS `valcoordinador`,`est`.`lavaropa` AS `lavaropa` from `testadisticasjugador` `est` where ((`est`.`visible` = 1) and (`est`.`idtemporada`,`est`.`idjugador`) in (select max(`testadisticasjugador`.`idtemporada`),`testadisticasjugador`.`idjugador` from `testadisticasjugador` where (`testadisticasjugador`.`visible` = 1) group by `testadisticasjugador`.`idjugador`))) `testadisticasjugador` on((`testadisticasjugador`.`idjugador` = `tjugadores`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugadores`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugadores`.`idprovincia`))) left join `vjugador_estadisticas_json` `ve` on((`ve`.`idjugador` = `tjugadores`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vjugsimple`
--

/*!50001 DROP VIEW IF EXISTS `vjugsimple`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vjugsimple` AS select `tjugador`.`id` AS `id`,`tjugador`.`idposicion` AS `idposicion`,`tjugador`.`idpiedominante` AS `idpiedominante`,`tjugador`.`idprovincia` AS `idprovincia`,`tjugador`.`idlocalidad` AS `idlocalidad`,`tjugador`.`nombre` AS `nombre`,`tjugador`.`apellidos` AS `apellidos`,`tjugador`.`apodo` AS `apodo`,`tjugador`.`foto` AS `foto`,`tjugador`.`fechanacimiento` AS `fechanacimiento`,`tjugador`.`domicilio` AS `domicilio`,`tlocalidades`.`localidad` AS `localidad`,`tprovincias`.`provincia` AS `provincia`,`tposiciones`.`posicion` AS `posicion`,`tpiedominante`.`pie` AS `pie`,`testjugador`.`idclub` AS `idclub`,`testjugador`.`idequipo` AS `idequipo`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `testjugador`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `testjugador`.`idequipo`)) AS `equipo` from (((((`tjugador` join `tposiciones` on((`tposiciones`.`id` = `tjugador`.`idposicion`))) join `tpiedominante` on((`tpiedominante`.`id` = `tjugador`.`idpiedominante`))) join `testjugador` on((`testjugador`.`idjugador` = `tjugador`.`id`))) join `tlocalidades` on((`tlocalidades`.`id` = `tjugador`.`idlocalidad`))) join `tprovincias` on((`tprovincias`.`id` = `tjugador`.`idprovincia`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vlavarropa`
--

/*!50001 DROP VIEW IF EXISTS `vlavarropa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vlavarropa` AS select `tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tconvpartidos`.`id` AS `id`,`tconvpartidos`.`idpartido` AS `idpartido`,`tconvpartidos`.`idjugador` AS `idjugador`,`tconvpartidos`.`idequipo` AS `idequipo`,`tconvpartidos`.`idtemporada` AS `idtemporada`,`tconvpartidos`.`convocado` AS `convocado`,`tconvpartidos`.`lavaropa` AS `lavaropa` from (`tconvpartidos` join `tjugadores` on((`tjugadores`.`id` = `tconvpartidos`.`idjugador`))) where (`tconvpartidos`.`lavaropa` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vpartido`
--

/*!50001 DROP VIEW IF EXISTS `vpartido`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vpartido` AS select `tpartidos`.`id` AS `id`,`tpartidos`.`idjornada` AS `idjornada`,`tpartidos`.`idtemporada` AS `idtemporada`,`tpartidos`.`idcategoria` AS `idcategoria`,`tpartidos`.`idequipo` AS `idequipo`,`tpartidos`.`idrival` AS `idrival`,if((`tpartidos`.`idrival` <> 14),`teqR`.`ncorto`,0) AS `ncortorival`,if((`tpartidos`.`idrival` <> 14),`tclubR`.`ncorto`,0) AS `ncortoclubrival`,`tpartidos`.`rival` AS `rival`,`tpartidos`.`idclub` AS `idclub`,(select `tclubes`.`idprovincia` from `tclubes` where (`tclubes`.`id` = `tpartidos`.`idclub`)) AS `idprovincia`,`tpartidos`.`idlugar` AS `idlugar`,`tpartidos`.`fecha` AS `fecha`,`tpartidos`.`goles` AS `goles`,`tpartidos`.`golesrival` AS `golesrival`,`tpartidos`.`finalizado` AS `finalizado`,`tpartidos`.`primTiempo` AS `primTiempo`,`tpartidos`.`directo` AS `directo`,`tpartidos`.`descanso` AS `descanso`,`tpartidos`.`minuto` AS `minuto`,`tpartidos`.`hora` AS `hora`,`tpartidos`.`horaconvocatoria` AS `horaconvocatoria`,`tpartidos`.`casafuera` AS `casafuera`,`tpartidos`.`veralineacion` AS `veralineacion`,`tpartidos`.`verConvocatoria` AS `verConvocatoria`,`tjornadas`.`jornada` AS `jornada`,`tjornadas`.`ncorto` AS `jcorta`,`ttemporadas`.`temporada` AS `temporada`,`tcategorias`.`categoria` AS `categoria`,`tclubL`.`club` AS `club`,`tclubL`.`escudo` AS `escudo`,`tclubL`.`ncorto` AS `ncortoclub`,`teqL`.`equipo` AS `equipo`,`teqL`.`ncorto` AS `ncortoequipo`,`teqL`.`titulares` AS `titulares`,`teqL`.`minutos` AS `minpar`,`tcampos`.`campo` AS `campo`,`tpartidos`.`min` AS `min`,`tpartidos`.`minutosporparte` AS `minutosporparte`,`tpartidos`.`numeropartes` AS `numeropartes`,`tpartidos`.`color1L` AS `color1L`,`tpartidos`.`color2L` AS `color2L`,`tpartidos`.`color3L` AS `color3L`,`tpartidos`.`color4L` AS `color4L`,`tpartidos`.`color5L` AS `color5L`,`tpartidos`.`observaciones` AS `observaciones`,`tpartidos`.`obsconvocatoria` AS `obsconvocatoria`,`tpartidos`.`informe` AS `informe`,`tpartidos`.`infconvocatoria` AS `infconvocatoria`,`tpartidos`.`dispositivo` AS `dispositivo`,`tpartidos`.`arbitro` AS `arbitro`,`tpartidos`.`obsarbitro` AS `obsarbitro`,`tpartidos`.`cronica` AS `cronica`,`tpartidos`.`previa` AS `previa`,`tpartidos`.`sistema` AS `sistema`,`tpartidos`.`sistemafinal` AS `sistemafinal`,`tpartidos`.`camiseta` AS `idcamiseta`,`tpartidos`.`camisetapor` AS `idcamisetapor`,`camL`.`url` AS `camiseta`,`camporL`.`url` AS `camisetapor`,`colorN`.`idcolor` AS `idN`,`colorNP`.`idcolor` AS `idNP`,`tpartidos`.`alrival` AS `alrival`,`tpartidos`.`camisetarival` AS `camisetarival`,`tpartidos`.`sistemarival` AS `sistemarival`,`tpartidos`.`visto` AS `visto`,`tpartidos`.`obscoordinador` AS `obscoordinador`,`teqR`.`idclub` AS `idclubrival`,if((`tpartidos`.`idrival` <> 14),`tclubR`.`escudo`,`tpartidos`.`escudorival`) AS `escudorival`,concat(`tclubL`.`club`,' - ',`teqL`.`equipo`) AS `clubequipo` from ((((((((((((`tpartidos` join `tjornadas` on((`tjornadas`.`id` = `tpartidos`.`idjornada`))) join `tcategorias` on((`tcategorias`.`id` = `tpartidos`.`idcategoria`))) join `ttemporadas` on((`ttemporadas`.`id` = `tpartidos`.`idtemporada`))) join `tclubes` `tclubL` on((`tclubL`.`id` = `tpartidos`.`idclub`))) join `tequipos` `teqL` on((`teqL`.`id` = `tpartidos`.`idequipo`))) join `tcampos` on((`tcampos`.`id` = `tpartidos`.`idlugar`))) join `tequipos` `teqR` on((`teqR`.`id` = `tpartidos`.`idrival`))) join `tclubes` `tclubR` on((`tclubR`.`id` = `teqR`.`idclub`))) left join `tcamisetas` `camL` on((`camL`.`id` = `tpartidos`.`camiseta`))) left join `tcamisetas` `camporL` on((`camporL`.`id` = `tpartidos`.`camisetapor`))) left join `tcamisetas` `colorN` on((`colorN`.`id` = `tpartidos`.`camiseta`))) left join `tcamisetas` `colorNP` on((`colorNP`.`id` = `tpartidos`.`camisetapor`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vpartidojugador`
--

/*!50001 DROP VIEW IF EXISTS `vpartidojugador`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vpartidojugador` AS select `tconvpartidos`.`id` AS `id`,`tconvpartidos`.`idjugador` AS `idjugador`,`tconvpartidos`.`convocado` AS `convocado`,`tconvpartidos`.`jugando` AS `jugando`,`tconvpartidos`.`idpartido` AS `idpartido`,`tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`idposicion` AS `idposicion`,`tjugadores`.`idequipo` AS `idequipo`,`tjugadores`.`idclub` AS `idclub`,`tjugadores`.`activo` AS `activo`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tposiciones`.`posicion` AS `posicion`,`tclubes`.`club` AS `club`,`tequipos`.`equipo` AS `equipo`,`tjugadores`.`convocado` AS `convJugador`,`testadojugador`.`estado` AS `estado` from (((((`tconvpartidos` join `tjugadores` on((`tjugadores`.`id` = `tconvpartidos`.`idjugador`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tclubes` on((`tclubes`.`id` = `tjugadores`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `tjugadores`.`idequipo`))) join `testadojugador` on((`testadojugador`.`id` = `tjugadores`.`idestado`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vpartidosjugadores`
--

/*!50001 DROP VIEW IF EXISTS `vpartidosjugadores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vpartidosjugadores` AS select `tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`idposicion` AS `idposicion`,`tconvpartidos`.`id` AS `id`,`tconvpartidos`.`idpartido` AS `idpartido`,`tconvpartidos`.`idjugador` AS `idjugador`,`tconvpartidos`.`idequipo` AS `idequipo`,`tconvpartidos`.`idtemporada` AS `idtemporada`,`tconvpartidos`.`convocado` AS `convocado`,`tconvpartidos`.`idmotivo` AS `idmotivo`,`tmotivoconvocatoria`.`motivo` AS `motivo`,`tconvpartidos`.`jugando` AS `jugando`,`tconvpartidos`.`titular` AS `titular`,`tconvpartidos`.`minutos` AS `minutos`,`tconvpartidos`.`mentra` AS `mentra`,`tconvpartidos`.`goles` AS `goles`,`tconvpartidos`.`golpp` AS `golpp`,`tconvpartidos`.`tam` AS `tam`,`tconvpartidos`.`tro` AS `tro`,`tconvpartidos`.`observaciones` AS `observaciones`,`tconvpartidos`.`lavaropa` AS `lavaropa`,`tconvpartidos`.`valoracion` AS `valPartido`,`tconvpartidos`.`pfScore` AS `pfScore`,`tconvpartidos`.`valjugador` AS `valjugador`,`tconvpartidos`.`capitan` AS `capitan`,`tconvpartidos`.`lesion` AS `lesion`,`tconvpartidos`.`penalti` AS `penalti`,`tconvpartidos`.`visto` AS `visto`,`tconvpartidos`.`dorsal` AS `dorsal`,`tconvpartidos`.`posX` AS `posX`,`tconvpartidos`.`posY` AS `posY`,`tconvpartidos`.`estado` AS `estado`,`tpartidos`.`fecha` AS `fecha`,`tpartidos`.`goles` AS `golesequipo`,`tpartidos`.`golesrival` AS `golesrival`,`tpartidos`.`finalizado` AS `finalizado`,`tpartidos`.`obsconvocatoria` AS `obsconvocatoria`,`tpartidos`.`minuto` AS `minuto`,`tpartidos`.`hora` AS `hora`,`tjornadas`.`ncorto` AS `jornada`,`tequipos`.`equipo` AS `equipo`,`tclubes`.`club` AS `club`,`tposiciones`.`posicion` AS `posicion`,`tclubes`.`escudo` AS `escudo`,`tpartidos`.`casafuera` AS `casafuera`,`tclubR`.`id` AS `idclubR`,`tclubR`.`escudo` AS `escudoRival`,`teq`.`ncorto` AS `ncorto`,`teqR`.`ncorto` AS `ncortorival` from ((((((((((`tconvpartidos` join `tjugadores` on((`tjugadores`.`id` = `tconvpartidos`.`idjugador`))) join `tpartidos` on((`tpartidos`.`id` = `tconvpartidos`.`idpartido`))) join `tjornadas` on((`tjornadas`.`id` = `tpartidos`.`idjornada`))) join `tclubes` on((`tclubes`.`id` = `tjugadores`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `tjugadores`.`idequipo`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tmotivoconvocatoria` on((`tmotivoconvocatoria`.`idconvocatoria` = `tconvpartidos`.`idmotivo`))) join `tequipos` `teqR` on((`teqR`.`id` = `tpartidos`.`idrival`))) join `tequipos` `teq` on((`teq`.`id` = `tpartidos`.`idequipo`))) join `tclubes` `tclubR` on((`tclubR`.`id` = `teqR`.`idclub`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vpartidosjugadoresFB`
--

/*!50001 DROP VIEW IF EXISTS `vpartidosjugadoresFB`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vpartidosjugadoresFB` AS select `tjugadores`.`apodo` AS `apodo`,`tjugadores`.`foto` AS `foto`,`tjugadores`.`idtutor1` AS `idtutor1`,`tjugadores`.`idtutor2` AS `idtutor2`,`tjugadores`.`idposicion` AS `idposicion`,`tconvpartidos`.`id` AS `id`,`tconvpartidos`.`idpartido` AS `idpartido`,`tconvpartidos`.`idjugador` AS `idjugador`,`tconvpartidos`.`idclub` AS `idclub`,`tconvpartidos`.`idequipo` AS `idequipo`,`tconvpartidos`.`idtemporada` AS `idtemporada`,`tconvpartidos`.`convocado` AS `convocado`,`tconvpartidos`.`nodisponible` AS `nodisponible`,`tconvpartidos`.`idmotivo` AS `idmotivo`,`tmotivoconvocatoria`.`motivo` AS `motivo`,`tconvpartidos`.`jugando` AS `jugando`,`tconvpartidos`.`titular` AS `titular`,`tconvpartidos`.`minutos` AS `minutos`,`tconvpartidos`.`mentra` AS `mentra`,`tconvpartidos`.`asistencias` AS `asistencias`,`tconvpartidos`.`goles` AS `goles`,`tconvpartidos`.`tam` AS `tam`,`tconvpartidos`.`tro` AS `tro`,`tconvpartidos`.`observaciones` AS `observaciones`,`tpartidos`.`obsconvocatoria` AS `obsconvocatoria`,`tconvpartidos`.`lavaropa` AS `lavaropa`,`tconvpartidos`.`valoracion` AS `valPartido`,`tconvpartidos`.`pfScore` AS `pfScore`,`tconvpartidos`.`valjugador` AS `valjugador`,`tconvpartidos`.`valcoordinador` AS `valcoordinador`,`tconvpartidos`.`capitan` AS `capitan`,`tconvpartidos`.`lesion` AS `lesion`,`tconvpartidos`.`penalti` AS `penalti`,`tconvpartidos`.`visto` AS `visto`,`tconvpartidos`.`dorsal` AS `dorsal`,`tconvpartidos`.`posX` AS `posX`,`tconvpartidos`.`posY` AS `posY`,`tconvpartidos`.`posAlineacion` AS `posAlineacion`,`tconvpartidos`.`posXCambio` AS `posXCambio`,`tconvpartidos`.`posYCambio` AS `posYCambio`,`tconvpartidos`.`posAlineacionCambio` AS `posAlineacionCambio`,`tconvpartidos`.`estado` AS `estado`,`tpartidos`.`fecha` AS `fecha`,`tpartidos`.`goles` AS `golesequipo`,`tpartidos`.`golesrival` AS `golesrival`,`tpartidos`.`finalizado` AS `finalizado`,`tpartidos`.`minuto` AS `minuto`,`tpartidos`.`hora` AS `hora`,`tpartidos`.`verConvocatoria` AS `verConvocatoria`,`tjornadas`.`ncorto` AS `jornada`,`tequipos`.`equipo` AS `equipo`,`tclubes`.`club` AS `club`,`cam1`.`url` AS `primeraeq`,`cam2`.`url` AS `segundaeq`,`cam3`.`url` AS `terceraeq`,`cam4`.`url` AS `primeraeqpor`,`cam5`.`url` AS `segundaeqpor`,`cam6`.`url` AS `terceraeqpor`,`tposiciones`.`posicion` AS `posicion`,`tclubL`.`escudo` AS `escudo`,`tpartidos`.`casafuera` AS `casafuera`,`tclubR`.`id` AS `idclubR`,if((`tpartidos`.`idrival` <> 14),`tclubR`.`escudo`,`tpartidos`.`escudorival`) AS `escudoRival`,`teq`.`ncorto` AS `ncorto`,if((`tpartidos`.`idrival` <> 14),`teqR`.`ncorto`,0) AS `ncortorival`,if((`tpartidos`.`idrival` <> 14),`tclubR`.`ncorto`,0) AS `ncortoclubrival`,`tpartidos`.`rival` AS `rival` from (((((((((((((((((`tconvpartidos` join `tjugadores` on((`tjugadores`.`id` = `tconvpartidos`.`idjugador`))) join `tpartidos` on((`tpartidos`.`id` = `tconvpartidos`.`idpartido`))) join `tjornadas` on((`tjornadas`.`id` = `tpartidos`.`idjornada`))) join `tclubes` on((`tclubes`.`id` = `tjugadores`.`idclub`))) join `tequipos` on((`tequipos`.`id` = `tjugadores`.`idequipo`))) join `tposiciones` on((`tposiciones`.`id` = `tjugadores`.`idposicion`))) join `tmotivoconvocatoria` on((`tmotivoconvocatoria`.`idconvocatoria` = `tconvpartidos`.`idmotivo`))) join `tequipos` `teqR` on((`teqR`.`id` = `tpartidos`.`idrival`))) join `tequipos` `teq` on((`teq`.`id` = `tpartidos`.`idequipo`))) join `tclubes` `tclubR` on((`tclubR`.`id` = `teqR`.`idclub`))) join `tclubes` `tclubL` on((`tclubL`.`id` = `teq`.`idclub`))) left join `tcamisetas` `cam1` on((`cam1`.`id` = `tclubes`.`primeraeq`))) left join `tcamisetas` `cam2` on((`cam2`.`id` = `tclubes`.`segundaeq`))) left join `tcamisetas` `cam3` on((`cam3`.`id` = `tclubes`.`terceraeq`))) left join `tcamisetas` `cam4` on((`cam4`.`id` = `tclubes`.`primeraeqpor`))) left join `tcamisetas` `cam5` on((`cam5`.`id` = `tclubes`.`segundaeqpor`))) left join `tcamisetas` `cam6` on((`cam6`.`id` = `tclubes`.`terceraeqpor`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vpautaentrenamiento`
--

/*!50001 DROP VIEW IF EXISTS `vpautaentrenamiento`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vpautaentrenamiento` AS select `tpautaentrenamiento`.`id` AS `id`,`tpautaentrenamiento`.`idclub` AS `idclub`,`tpautaentrenamiento`.`idsesion` AS `idsesion`,`tclubes`.`club` AS `club`,`tpautaentrenamiento`.`idejercicio` AS `idejercicio`,`tfamiliaejercicio`.`familia` AS `ejercicio`,`tpautaentrenamiento`.`observaciones` AS `observaciones`,`tpautaentrenamiento`.`tiempo` AS `tiempo` from ((`tpautaentrenamiento` join `tclubes` on((`tclubes`.`id` = `tpautaentrenamiento`.`idclub`))) join `tfamiliaejercicio` on((`tfamiliaejercicio`.`id` = `tpautaentrenamiento`.`idejercicio`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vpublicidad`
--

/*!50001 DROP VIEW IF EXISTS `vpublicidad`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vpublicidad` AS select `p`.`id` AS `id`,`p`.`idequipo` AS `idequipo`,`p`.`idanunciante` AS `idanunciante`,`p`.`evento` AS `evento`,`p`.`urlImagen` AS `urlImagen`,`p`.`activo` AS `activo`,`p`.`idtemporada` AS `idtemporada`,`p`.`idclub` AS `idclub`,`p`.`posicion` AS `posicion`,coalesce(sum(`t`.`visto`),0) AS `impresiones`,coalesce(sum(`t`.`click`),0) AS `interacciones`,round(((coalesce(sum(`t`.`click`),0) / nullif(sum(`t`.`visto`),0)) * 100),2) AS `ctr`,`e`.`equipo` AS `equipo`,`e`.`idclub` AS `idclub1`,`c`.`club` AS `club`,`a`.`nombre` AS `anunciante`,`a`.`direccion` AS `direccion`,`a`.`cif` AS `cif`,`a`.`email` AS `email`,`a`.`web` AS `web`,`a`.`idlocalidad` AS `idlocalidad`,`a`.`idprovincia` AS `idprovincia`,`a`.`telefono` AS `telefono`,`p`.`mensaje` AS `mensaje` from ((((`tpublicidad` `p` left join `tequipos` `e` on((`e`.`id` = `p`.`idequipo`))) left join `tclubes` `c` on((`c`.`id` = `p`.`idclub`))) left join `tanunciante` `a` on((`a`.`id` = `p`.`idanunciante`))) left join `ttelemetriapubli` `t` on((`t`.`idanunciante` = `p`.`idanunciante`))) group by `p`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vroles`
--

/*!50001 DROP VIEW IF EXISTS `vroles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vroles` AS select `r`.`id` AS `id`,`r`.`tipo` AS `tipo`,`r`.`idusuario` AS `idusuario`,`r`.`idtemporada` AS `idtemporada`,`r`.`uid` AS `uid`,`r`.`selectedrol` AS `selectedrol`,`r`.`idclub` AS `idclub`,`r`.`idequipo` AS `idequipo`,`r`.`idjugador` AS `idjugador`,`r`.`idjugador2` AS `idjugador2`,`r`.`idjugador3` AS `idjugador3`,`r`.`idjugador4` AS `idjugador4`,`r`.`idcarnet` AS `idcarnet`,`tr`.`name` AS `name`,`tr`.`title` AS `title`,`tr`.`description` AS `description`,`u`.`nombre` AS `nombre`,`u`.`apellidos` AS `apellidos`,`u`.`email` AS `email`,`u`.`telefono` AS `telefono`,`u`.`user` AS `user`,`u`.`password` AS `password`,(select `c`.`club` from `tclubes` `c` where (`c`.`id` = `r`.`idclub`) limit 1) AS `club`,(select `e`.`equipo` from `tequipos` `e` where (`e`.`id` = `r`.`idequipo`) limit 1) AS `equipo`,(select `j`.`nombre` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador`) limit 1) AS `nomjug1`,(select `j`.`apellidos` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador`) limit 1) AS `apejug1`,(select `j`.`nombre` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador2`) limit 1) AS `nomjug2`,(select `j`.`apellidos` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador2`) limit 1) AS `apejug2`,(select `j`.`nombre` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador3`) limit 1) AS `nomjug3`,(select `j`.`apellidos` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador3`) limit 1) AS `apejug3`,(select `j`.`nombre` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador4`) limit 1) AS `nomjug4`,(select `j`.`apellidos` from `tjugadores` `j` where (`j`.`id` = `r`.`idjugador4`) limit 1) AS `apejug4` from ((`troles` `r` join `ttiporol` `tr` on((`tr`.`tipo` = `r`.`tipo`))) join `tusuarios` `u` on((`u`.`id` = `r`.`idusuario`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vrolesCarnet`
--

/*!50001 DROP VIEW IF EXISTS `vrolesCarnet`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vrolesCarnet` AS select `t`.`id` AS `id`,`t`.`tipo` AS `tipo`,`t`.`idusuario` AS `idusuario`,`t`.`idtemporada` AS `idtemporada`,`t`.`uid` AS `uid`,`t`.`selectedrol` AS `selectedrol`,`j`.`idclub` AS `idclub`,`j`.`idequipo` AS `idequipo`,`t`.`idcarnet` AS `idcarnet`,`tr`.`name` AS `name`,`tr`.`title` AS `title`,`tr`.`description` AS `description`,`tu`.`nombre` AS `nombre`,`tu`.`apellidos` AS `apellidos`,`tu`.`email` AS `email`,`tu`.`telefono` AS `telefono`,`tu`.`user` AS `user`,`tu`.`password` AS `password`,`c`.`club` AS `club`,`e`.`equipo` AS `equipo`,`j`.`id` AS `idjugador`,`j`.`nombre` AS `nomjug1`,`j`.`apellidos` AS `apejug1` from (((((`troles` `t` join `ttiporol` `tr` on((`tr`.`tipo` = `t`.`tipo`))) join `tusuarios` `tu` on((`tu`.`id` = `t`.`idusuario`))) join `tjugadores` `j` on((`j`.`id` = `t`.`idjugador`))) left join `tclubes` `c` on((`c`.`id` = `j`.`idclub`))) left join `tequipos` `e` on((`e`.`id` = `j`.`idequipo`))) where (`t`.`idjugador` > 0) union all select `t`.`id` AS `id`,`t`.`tipo` AS `tipo`,`t`.`idusuario` AS `idusuario`,`t`.`idtemporada` AS `idtemporada`,`t`.`uid` AS `uid`,`t`.`selectedrol` AS `selectedrol`,`j`.`idclub` AS `idclub`,`j`.`idequipo` AS `idequipo`,`t`.`idcarnet` AS `idcarnet`,`tr`.`name` AS `name`,`tr`.`title` AS `title`,`tr`.`description` AS `description`,`tu`.`nombre` AS `nombre`,`tu`.`apellidos` AS `apellidos`,`tu`.`email` AS `email`,`tu`.`telefono` AS `telefono`,`tu`.`user` AS `user`,`tu`.`password` AS `password`,`c`.`club` AS `club`,`e`.`equipo` AS `equipo`,`j`.`id` AS `idjugador`,`j`.`nombre` AS `nomjug2`,`j`.`apellidos` AS `apejug2` from (((((`troles` `t` join `ttiporol` `tr` on((`tr`.`tipo` = `t`.`tipo`))) join `tusuarios` `tu` on((`tu`.`id` = `t`.`idusuario`))) join `tjugadores` `j` on((`j`.`id` = `t`.`idjugador2`))) left join `tclubes` `c` on((`c`.`id` = `j`.`idclub`))) left join `tequipos` `e` on((`e`.`id` = `j`.`idequipo`))) where (`t`.`idjugador2` > 0) union all select `t`.`id` AS `id`,`t`.`tipo` AS `tipo`,`t`.`idusuario` AS `idusuario`,`t`.`idtemporada` AS `idtemporada`,`t`.`uid` AS `uid`,`t`.`selectedrol` AS `selectedrol`,`j`.`idclub` AS `idclub`,`j`.`idequipo` AS `idequipo`,`t`.`idcarnet` AS `idcarnet`,`tr`.`name` AS `name`,`tr`.`title` AS `title`,`tr`.`description` AS `description`,`tu`.`nombre` AS `nombre`,`tu`.`apellidos` AS `apellidos`,`tu`.`email` AS `email`,`tu`.`telefono` AS `telefono`,`tu`.`user` AS `user`,`tu`.`password` AS `password`,`c`.`club` AS `club`,`e`.`equipo` AS `equipo`,`j`.`id` AS `idjugador`,`j`.`nombre` AS `nomjug3`,`j`.`apellidos` AS `apejug3` from (((((`troles` `t` join `ttiporol` `tr` on((`tr`.`tipo` = `t`.`tipo`))) join `tusuarios` `tu` on((`tu`.`id` = `t`.`idusuario`))) join `tjugadores` `j` on((`j`.`id` = `t`.`idjugador3`))) left join `tclubes` `c` on((`c`.`id` = `j`.`idclub`))) left join `tequipos` `e` on((`e`.`id` = `j`.`idequipo`))) where (`t`.`idjugador3` > 0) union all select `t`.`id` AS `id`,`t`.`tipo` AS `tipo`,`t`.`idusuario` AS `idusuario`,`t`.`idtemporada` AS `idtemporada`,`t`.`uid` AS `uid`,`t`.`selectedrol` AS `selectedrol`,`j`.`idclub` AS `idclub`,`j`.`idequipo` AS `idequipo`,`t`.`idcarnet` AS `idcarnet`,`tr`.`name` AS `name`,`tr`.`title` AS `title`,`tr`.`description` AS `description`,`tu`.`nombre` AS `nombre`,`tu`.`apellidos` AS `apellidos`,`tu`.`email` AS `email`,`tu`.`telefono` AS `telefono`,`tu`.`user` AS `user`,`tu`.`password` AS `password`,`c`.`club` AS `club`,`e`.`equipo` AS `equipo`,`j`.`id` AS `idjugador`,`j`.`nombre` AS `nomjug4`,`j`.`apellidos` AS `apejug4` from (((((`troles` `t` join `ttiporol` `tr` on((`tr`.`tipo` = `t`.`tipo`))) join `tusuarios` `tu` on((`tu`.`id` = `t`.`idusuario`))) join `tjugadores` `j` on((`j`.`id` = `t`.`idjugador4`))) left join `tclubes` `c` on((`c`.`id` = `j`.`idclub`))) left join `tequipos` `e` on((`e`.`id` = `j`.`idequipo`))) where (`t`.`idjugador4` > 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vrolpeticion`
--

/*!50001 DROP VIEW IF EXISTS `vrolpeticion`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vrolpeticion` AS select `trolpeticion`.`id` AS `id`,`trolpeticion`.`tipo` AS `tipo`,`trolpeticion`.`idusuario` AS `idusuario`,`trolpeticion`.`idtemporada` AS `idtemporada`,(select `tusuarios`.`nombre` from `tusuarios` where (`tusuarios`.`id` = `trolpeticion`.`idusuario`)) AS `nombre`,(select `tusuarios`.`apellidos` from `tusuarios` where (`tusuarios`.`id` = `trolpeticion`.`idusuario`)) AS `apellidos`,(select `tusuarios`.`email` from `tusuarios` where (`tusuarios`.`id` = `trolpeticion`.`idusuario`)) AS `email`,`trolpeticion`.`uid` AS `uid`,`trolpeticion`.`fecha` AS `fecha`,`trolpeticion`.`estado` AS `estado`,`trolpeticion`.`idclub` AS `idclub`,`trolpeticion`.`idequipo` AS `idequipo`,`trolpeticion`.`idjugador` AS `idjugador`,`trolpeticion`.`comentario` AS `comentario`,`ttiporol`.`name` AS `name`,`ttiporol`.`title` AS `title`,`ttiporol`.`description` AS `description`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `trolpeticion`.`idclub`)) AS `club`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `trolpeticion`.`idequipo`)) AS `equipo`,(select concat(`tjugadores`.`nombre`,' ',`tjugadores`.`apellidos`) from `tjugadores` where (`tjugadores`.`id` = `trolpeticion`.`idjugador`)) AS `jugador` from (`trolpeticion` join `ttiporol` on((`ttiporol`.`tipo` = `trolpeticion`.`tipo`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vropa`
--

/*!50001 DROP VIEW IF EXISTS `vropa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vropa` AS select `tr`.`id` AS `id`,`tr`.`idjugador` AS `idjugador`,`tr`.`idclub` AS `idclub`,`tr`.`idtemporada` AS `idtemporada`,`tr`.`idprenda` AS `idprenda`,`tr`.`pvp` AS `pvp`,`tr`.`descuento` AS `descuento`,`tr`.`entregado` AS `entregado`,`tr`.`acuenta` AS `acuenta`,`tr`.`tipopago` AS `tipopago`,`tr`.`talla` AS `talla`,`tr`.`fecha` AS `fecha`,`tr`.`fechaentrega` AS `fechaentrega`,`tr`.`avisado` AS `avisado`,`tp`.`descripcion` AS `descripcion`,`tc`.`icono` AS `icono`,`tc`.`estado` AS `estado`,`tr`.`devuelto` AS `devuelto`,`tr`.`fechadevolucion` AS `fechadevolucion`,(case when (`tr`.`idjugador` = 0) then `tr`.`nombre` else concat(`tj`.`nombre`,' ',`tj`.`apellidos`) end) AS `nombre`,(case when (`tr`.`idjugador` = 0) then '' else `tj`.`idequipo` end) AS `idequipo`,(case when (`tr`.`idjugador` = 0) then '' else `te`.`equipo` end) AS `equipo` from ((((`tropa` `tr` join `tprendas` `tp` on((`tr`.`idprenda` = `tp`.`id`))) left join `tjugadores` `tj` on((`tr`.`idjugador` = `tj`.`id`))) left join `tequipos` `te` on((`tj`.`idequipo` = `te`.`id`))) left join `testadocobro` `tc` on((`tr`.`tipopago` = `tc`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vsponsors`
--

/*!50001 DROP VIEW IF EXISTS `vsponsors`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vsponsors` AS select `tanunciante`.`id` AS `id`,`tanunciante`.`nombre` AS `nombre`,`tanunciante`.`direccion` AS `direccion`,`tanunciante`.`cif` AS `cif`,`tanunciante`.`email` AS `email`,`tanunciante`.`web` AS `web`,`tanunciante`.`telefono` AS `telefono`,`tanunciante`.`urlImagen` AS `urlImagen` from `tanunciante` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vtallapeso`
--

/*!50001 DROP VIEW IF EXISTS `vtallapeso`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vtallapeso` AS select `ttallapeso`.`id` AS `id`,`ttallapeso`.`idjugador` AS `idjugador`,`tjugadores`.`apodo` AS `apodo`,`ttallapeso`.`peso` AS `peso`,`ttallapeso`.`altura` AS `altura`,`ttallapeso`.`fecha` AS `fecha`,`ttallapeso`.`difp` AS `difp`,`ttallapeso`.`difa` AS `difa`,`ttallapeso`.`imc` AS `imc`,`ttallapeso`.`pesoideal` AS `pesoideal` from (`ttallapeso` join `tjugadores` on((`tjugadores`.`id` = `ttallapeso`.`idjugador`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vusuarioroles`
--

/*!50001 DROP VIEW IF EXISTS `vusuarioroles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vusuarioroles` AS select `tusuarios`.`id` AS `id`,`tusuarios`.`idclub` AS `idclub`,`tusuarios`.`idequipo` AS `idequipo`,`tusuarios`.`idtemporada` AS `idtemporada`,`tusuarios`.`uid` AS `uid`,`tusuarios`.`email` AS `email`,`tusuarios`.`nombre` AS `nombre`,`tusuarios`.`apellidos` AS `apellidos`,`tusuarios`.`telefono` AS `telefono`,`tusuarios`.`photourl` AS `photourl`,`tusuarios`.`user` AS `user`,`tusuarios`.`password` AS `password`,`tusuarios`.`permisos` AS `permisos`,`tusuarios`.`observaciones` AS `observaciones`,`tusuarios`.`col1` AS `col1`,`tusuarios`.`col2` AS `col2`,`tusuarios`.`col3` AS `col3`,`tusuarios`.`estadentro` AS `estadentro`,`tusuarios`.`conhijos` AS `conhijos`,`tusuarios`.`notificar` AS `notificar`,`tusuarios`.`dorsal` AS `dorsal`,`tusuarios`.`idjugador` AS `idjugador`,`tusuarios`.`estadisticas` AS `estadisticas`,`tusuarios`.`entrenamientos` AS `entrenamientos`,`tusuarios`.`partidos` AS `partidos`,`tusuarios`.`tallapeso` AS `tallapeso`,`tusuarios`.`lesiones` AS `lesiones`,`tusuarios`.`cuotas` AS `cuotas`,`tusuarios`.`hacerfotos` AS `hacerfotos`,`tusuarios`.`firmaproteccion` AS `firmaproteccion`,`tusuarios`.`idempresa` AS `idempresa`,`tusuarios`.`clubcompleto` AS `clubcompleto`,(select `tclubes`.`club` from `tclubes` where (`tclubes`.`id` = `tusuarios`.`idclub`)) AS `club`,(select `tperfilesusuario`.`perfil` from `tperfilesusuario` where (`tperfilesusuario`.`id` = `tusuarios`.`permisos`)) AS `perfil`,(select `tequipos`.`equipo` from `tequipos` where (`tequipos`.`id` = `tusuarios`.`idequipo`)) AS `equipo`,(select json_arrayagg(json_object('id',`ru`.`id`,'nombre',`ru`.`nombre`,'descripcion',`ru`.`description`,'codigo',`ru`.`tipo`)) from (`vroles` `ru` join `troles` `r` on((`r`.`id` = `ru`.`id`))) where (`ru`.`idusuario` = `tusuarios`.`id`)) AS `roles` from `tusuarios` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vusuarios`
--

/*!50001 DROP VIEW IF EXISTS `vusuarios`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`qanf664`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vusuarios` AS select `tusuarios`.`id` AS `id`,`tusuarios`.`idclub` AS `idclub`,`tusuarios`.`idequipo` AS `idequipo`,`tusuarios`.`idtemporada` AS `idtemporada`,`tusuarios`.`uid` AS `uid`,`tusuarios`.`email` AS `email`,`tusuarios`.`nombre` AS `nombre`,`tusuarios`.`apellidos` AS `apellidos`,`tusuarios`.`telefono` AS `telefono`,`tusuarios`.`photourl` AS `photourl`,`tusuarios`.`user` AS `user`,`tusuarios`.`password` AS `password`,`tusuarios`.`permisos` AS `permisos`,`tusuarios`.`observaciones` AS `observaciones`,`tusuarios`.`col1` AS `col1`,`tusuarios`.`col2` AS `col2`,`tusuarios`.`col3` AS `col3`,`tusuarios`.`estadentro` AS `estadentro`,`tusuarios`.`conhijos` AS `conhijos`,`tusuarios`.`notificar` AS `notificar`,`tusuarios`.`dorsal` AS `dorsal`,`tusuarios`.`idjugador` AS `idjugador`,`tusuarios`.`estadisticas` AS `estadisticas`,`tusuarios`.`entrenamientos` AS `entrenamientos`,`tusuarios`.`partidos` AS `partidos`,`tusuarios`.`tallapeso` AS `tallapeso`,`tusuarios`.`lesiones` AS `lesiones`,`tusuarios`.`cuotas` AS `cuotas`,`tusuarios`.`hacerfotos` AS `hacerfotos`,`tusuarios`.`firmaproteccion` AS `firmaproteccion`,`tusuarios`.`idempresa` AS `idempresa`,`tusuarios`.`clubcompleto` AS `clubcompleto`,(select `tclubes`.`club` from `tclubes` where (`tusuarios`.`idclub` = `tclubes`.`id`)) AS `club`,(select `tperfilesusuario`.`perfil` from `tperfilesusuario` where (`tusuarios`.`permisos` = `tperfilesusuario`.`id`)) AS `perfil`,(select `tequipos`.`equipo` from `tequipos` where (`tusuarios`.`idequipo` = `tequipos`.`id`)) AS `equipo` from `tusuarios` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-20  8:49:27
