-- MySQL dump 10.16  Distrib 10.1.26-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: orpak
-- ------------------------------------------------------
-- Server version	10.1.26-MariaDB-0+deb9u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ci_configuration`
--

DROP TABLE IF EXISTS `ci_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ci_configuration` (
  `dbname` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `status` smallint(6) DEFAULT NULL,
  `estacion` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ci_configuration`
--

LOCK TABLES `ci_configuration` WRITE;
/*!40000 ALTER TABLE `ci_configuration` DISABLE KEYS */;
INSERT INTO `ci_configuration` VALUES ('trate','pruebas','ÎÔýrŸ',0,1423),('master','trateusr','ŽìºOf•¯',1,1423);
/*!40000 ALTER TABLE `ci_configuration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ci_cortes`
--

DROP TABLE IF EXISTS `ci_cortes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ci_cortes` (
  `fecha_hora` datetime DEFAULT NULL COMMENT 'Fecha y hora del corte',
  `estacion` smallint(10) DEFAULT NULL COMMENT 'Número de la estación',
  `entrega_turno` int(11) DEFAULT NULL COMMENT 'No. De empleado (fragua)',
  `recibe_turno` int(11) DEFAULT NULL COMMENT 'No. De empleado (fragua)',
  `fecha_hora_recep` datetime DEFAULT NULL,
  `inventario_recibido_lts` decimal(10,4) DEFAULT NULL COMMENT 'Inventario inicial del turno en litros',
  `movtos_turno_lts` decimal(10,4) DEFAULT NULL COMMENT 'Entradas – Salidas durante el turno en litros',
  `inventario_entregado_lts` decimal(10,4) DEFAULT NULL COMMENT 'Lectura de litros en el tanque al momento del corte',
  `diferencia_lts` decimal(10,4) DEFAULT NULL COMMENT 'Diferencia entre Inventario_entregado_lts – (Inventario_recibido_lts + Movtos_turno_lts)',
  `inventario_recibido_cto` decimal(10,4) DEFAULT NULL COMMENT 'Inventario_recibido_lts * Costo al momento del corte',
  `movtos_turno_cto` decimal(10,4) DEFAULT NULL COMMENT 'Movtos_turno_lts * Costo al momento del corte',
  `inventario_entregado_cto` decimal(10,4) DEFAULT NULL COMMENT 'Inventario_entregado_cto * Costo al momento del corte',
  `diferencia_cto` decimal(10,4) DEFAULT NULL COMMENT 'Diferencia_lts * Costo al momento del corte',
  `autorizo_dif` int(11) DEFAULT NULL,
  `contador_inicial` int(11) DEFAULT NULL,
  `folio` int(11) NOT NULL AUTO_INCREMENT,
  `contador_final` int(11) DEFAULT NULL,
  `vserie` char(10) DEFAULT NULL,
  `procesada` char(1) DEFAULT NULL,
  PRIMARY KEY (`folio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ci_cortes`
--

LOCK TABLES `ci_cortes` WRITE;
/*!40000 ALTER TABLE `ci_cortes` DISABLE KEYS */;
/*!40000 ALTER TABLE `ci_cortes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_cortes_after_insert` AFTER INSERT ON `ci_cortes` FOR EACH ROW BEGIN
SET @exec_var = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/insertar_corte_informix.pl "',
ifnull(new.fecha_hora,""), '" "',
ifnull(new.estacion,""), '" "',
ifnull(new.entrega_turno,""), '" "',
ifnull(new.recibe_turno,""), '" "',
ifnull(new.fecha_hora_recep,""), '" "',
ifnull(new.inventario_recibido_lts,""), '" "',
ifnull(new.movtos_turno_lts,""), '" "',
ifnull(new.inventario_entregado_lts,""), '" "',
ifnull(new.diferencia_lts,""), '" "',
ifnull(new.inventario_recibido_cto,""), '" "',
ifnull(new.movtos_turno_cto,""), '" "',
ifnull(new.inventario_entregado_cto,""), '" "',
ifnull(new.diferencia_cto,""), '" "',
ifnull(new.autorizo_dif,""), '" "',
ifnull(new.contador_inicial,""), '" "',
ifnull(new.folio,""), '" "',
ifnull(new.contador_final,""), '" "',
ifnull(new.vserie,""), '" "',
ifnull(new.procesada,""), '" &'));
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_cortes_after_update` AFTER UPDATE ON `ci_cortes` FOR EACH ROW BEGIN
SET @exec_var = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/actualizar_corte_informix.pl "',
ifnull(new.fecha_hora,""), '" "',
ifnull(new.estacion,""), '" "',
ifnull(new.entrega_turno,""), '" "',
ifnull(new.recibe_turno,""), '" "',
ifnull(new.fecha_hora_recep,""), '" "',
ifnull(new.inventario_recibido_lts,""), '" "',
ifnull(new.movtos_turno_lts,""), '" "',
ifnull(new.inventario_entregado_lts,""), '" "',
ifnull(new.diferencia_lts,""), '" "',
ifnull(new.inventario_recibido_cto,""), '" "',
ifnull(new.movtos_turno_cto,""), '" "',
ifnull(new.inventario_entregado_cto,""), '" "',
ifnull(new.diferencia_cto,""), '" "',
ifnull(new.autorizo_dif,""), '" "',
ifnull(new.contador_inicial,""), '" "',
ifnull(new.folio,""), '" "',
ifnull(new.contador_final,""), '" "',
ifnull(new.vserie,""), '" "',
ifnull(new.procesada,""), '" &'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `ci_movimientos`
--

DROP TABLE IF EXISTS `ci_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ci_movimientos` (
  `fecha_hora` datetime DEFAULT NULL,
  `estacion` smallint(6) DEFAULT NULL,
  `dispensador` smallint(6) DEFAULT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `despachador` int(11) DEFAULT NULL,
  `viaje` int(11) DEFAULT NULL,
  `camion` smallint(6) DEFAULT NULL,
  `chofer` int(11) DEFAULT NULL,
  `sello` char(20) DEFAULT NULL,
  `tipo_referencia` smallint(6) DEFAULT NULL,
  `serie` char(20) DEFAULT NULL,
  `referencia` int(11) DEFAULT NULL,
  `movimiento` smallint(6) DEFAULT NULL,
  `litros_esp` decimal(11,4) DEFAULT NULL,
  `litros_real` decimal(11,4) DEFAULT NULL,
  `costo_esp` decimal(12,4) DEFAULT NULL,
  `costo_real` decimal(12,4) DEFAULT NULL,
  `iva` decimal(12,4) DEFAULT NULL,
  `ieps` decimal(12,4) DEFAULT NULL,
  `status` smallint(6) DEFAULT NULL,
  `procesada` char(1) DEFAULT NULL,
  `transaction_id` bigint(15) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ci_movimientos`
--

LOCK TABLES `ci_movimientos` WRITE;
/*!40000 ALTER TABLE `ci_movimientos` DISABLE KEYS */;
INSERT INTO `ci_movimientos` VALUES ('2018-10-08 16:40:17',1423,1,0,0,0,0,0,'NULL',3,'NULL',0,2,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0,'N',300089227,1);
/*!40000 ALTER TABLE `ci_movimientos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_movimientos_after_insert` AFTER INSERT ON `ci_movimientos` FOR EACH ROW BEGIN
SET @exec_var = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/movimiento_from_transporter_to_trate.pl "',
ifnull(new.fecha_hora,""), '" "',
ifnull(new.estacion,""), '" "',
ifnull(new.dispensador,""), '" "',
ifnull(new.supervisor,""), '" "',
ifnull(new.despachador,""), '" "',
ifnull(new.viaje,""), '" "',
ifnull(new.camion,""), '" "',
ifnull(new.chofer,""), '" "',
ifnull(new.tipo_referencia,""), '" "',
ifnull(new.serie,""), '" "',
ifnull(new.referencia,""), '" "',
ifnull(new.movimiento,""), '" "',
ifnull(new.litros_esp,""), '" "',
ifnull(new.litros_real,""), '" "',
ifnull(new.costo_esp,""), '" "',
ifnull(new.costo_real,""), '" "',
ifnull(new.iva,""), '" "',
ifnull(new.ieps,""), '" "',
ifnull(new.status,""), '" "',
ifnull(new.procesada,""), '" "',
ifnull(new.transaction_id,""), '" &'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `ci_pases`
--

DROP TABLE IF EXISTS `ci_pases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ci_pases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_solicitud` datetime DEFAULT NULL COMMENT 'Fecha y hora de generación del pase',
  `pase` int(11) DEFAULT NULL COMMENT 'Folio del pase generado',
  `viaje` int(11) DEFAULT NULL COMMENT 'Número de viaje asignado',
  `camion` varchar(200) DEFAULT NULL COMMENT 'Número económico de camión asignado',
  `chofer` int(11) DEFAULT NULL COMMENT 'No. De empleado del chofer (Fragua)',
  `litros` decimal(11,4) DEFAULT NULL COMMENT 'Litros a despachar 0 Libre, > 0 Carga fija',
  `contingencia` decimal(11,4) DEFAULT NULL,
  `status` char(1) DEFAULT NULL COMMENT 'A = Activo',
  `litros_real` decimal(11,4) DEFAULT NULL,
  `litros_esp` decimal(11,4) DEFAULT NULL,
  `viaje_sust` int(11) DEFAULT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `observaciones` varchar(200) DEFAULT NULL,
  `ultima_modificacion` timestamp NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ci_pases`
--

LOCK TABLES `ci_pases` WRITE;
/*!40000 ALTER TABLE `ci_pases` DISABLE KEYS */;
INSERT INTO `ci_pases` VALUES (1,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-23 07:39:47'),(15,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:48:59'),(16,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:49:04'),(17,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:50:07'),(18,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:51:41'),(19,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:52:33'),(20,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:53:21'),(21,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:54:01'),(22,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 02:59:55'),(23,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:01:48'),(24,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:02:31'),(25,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:05:35'),(26,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:05:43'),(27,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:08:02'),(28,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:11:33'),(29,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:11:56'),(30,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:33:33'),(31,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:36:02'),(32,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:44:23'),(33,'2018-10-01 00:00:00',3000,100,'AutoTag',3001,120.0000,0.0000,'A',98.0000,99.0000,0,0,'NULL','2018-11-01 03:52:51'),(34,'2018-10-01 00:00:00',4000,101,'AutoTag',3001,11.0000,0.0000,'A',9.0000,9.0000,0,0,'NULL','2018-11-01 04:17:49'),(35,'2018-10-01 00:00:00',5000,102,'AutoTag',3001,9.0000,0.0000,'A',9.0000,9.0000,0,0,'NULL','2018-11-01 04:24:10'),(36,'2018-10-01 00:00:00',5000,102,'AutoTag',3001,9.0000,0.0000,'A',9.0000,9.0000,0,0,'NULL','2018-11-05 21:19:05'),(37,'2018-11-22 18:14:26',5001,102,'AutoTag',2001,100.0000,0.0000,'A',NULL,NULL,NULL,NULL,NULL,'2018-11-23 00:14:26'),(38,'2018-11-22 18:15:00',5001,102,'AutoTag',2001,100.0000,0.0000,'A',NULL,NULL,NULL,NULL,NULL,'2018-11-23 00:15:00'),(39,'2018-11-22 18:23:01',5001,102,'AutoTag',2001,100.0000,0.0000,'A',NULL,NULL,NULL,NULL,NULL,'2018-11-23 00:23:01');
/*!40000 ALTER TABLE `ci_pases` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_pases_after_insert` AFTER INSERT ON `ci_pases` FOR EACH ROW BEGIN
SET @exec_var = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/assign_pase_orcu.pl ',new.pase, ' ', new.camion, ' ', new.litros, ' &'));
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_pases_after_update` BEFORE UPDATE ON `ci_pases` FOR EACH ROW BEGIN
SET @exec_var = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/actualizar_pase_informix.pl "',
ifnull(new.id,""), '" "',
ifnull(new.fecha_solicitud,""), '" "',
ifnull(new.pase,""), '" "',
ifnull(new.viaje,""), '" "',
ifnull(new.camion,""), '" "',
ifnull(new.chofer,""), '" "',
ifnull(new.litros,""), '" "',
ifnull(new.contingencia,""), '" "',
ifnull(new.status,""), '" "',
ifnull(new.litros_real,""), '" "',
ifnull(new.litros_esp,""), '" "',
ifnull(new.viaje_sust,""), '" "',
ifnull(new.supervisor,""), '" "',
ifnull(new.observaciones,""), '" "',
ifnull(new.ultima_modificacion,""), '" &'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `despachadores`
--

DROP TABLE IF EXISTS `despachadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `despachadores` (
  `iddespachadores` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `tipo` int(11) DEFAULT '1' COMMENT '1 despachador, 2 jefe de turno',
  `estatus` int(11) DEFAULT '1' COMMENT '1 activo, 0 inactivo',
  PRIMARY KEY (`iddespachadores`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `despachadores`
--

LOCK TABLES `despachadores` WRITE;
/*!40000 ALTER TABLE `despachadores` DISABLE KEYS */;
/*!40000 ALTER TABLE `despachadores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jarreos_t`
--

DROP TABLE IF EXISTS `jarreos_t`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jarreos_t` (
  `transaction_id` bigint(15) NOT NULL DEFAULT '0',
  `transaction_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `transaction_dispensed_quantity` decimal(11,4) DEFAULT NULL,
  `transaction_ppv` decimal(11,4) DEFAULT NULL,
  `transaction_total_price` decimal(12,4) DEFAULT NULL,
  `transaction_iva` decimal(11,4) DEFAULT NULL,
  `transaction_ieps` decimal(11,4) DEFAULT NULL,
  `transaction_pump_head_external_code` int(3) DEFAULT NULL,
  `return_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `return_total_price` decimal(12,4) DEFAULT NULL,
  `return_tank_object_id` bigint(15) DEFAULT NULL,
  `return_date` date DEFAULT NULL,
  `return_time` time DEFAULT NULL,
  `status_code` int(1) DEFAULT '2',
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jarreos_t`
--

LOCK TABLES `jarreos_t` WRITE;
/*!40000 ALTER TABLE `jarreos_t` DISABLE KEYS */;
/*!40000 ALTER TABLE `jarreos_t` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modelos`
--

DROP TABLE IF EXISTS `modelos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modelos` (
  `idmodelos` int(111) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `capacidad` double(10,2) DEFAULT NULL,
  `rendimiento` double(10,2) DEFAULT NULL,
  `descripcion` varchar(50) DEFAULT NULL,
  `clase` varchar(50) DEFAULT NULL,
  `rendimiento2` double(10,2) DEFAULT NULL,
  PRIMARY KEY (`idmodelos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modelos`
--

LOCK TABLES `modelos` WRITE;
/*!40000 ALTER TABLE `modelos` DISABLE KEYS */;
/*!40000 ALTER TABLE `modelos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_ieps`
--

DROP TABLE IF EXISTS `product_ieps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_ieps` (
  `product_id` bigint(15) NOT NULL DEFAULT '0',
  `product_ieps` decimal(11,4) DEFAULT NULL,
  `product_iva` decimal(5,4) DEFAULT NULL,
  `configuration_applies_from` date NOT NULL DEFAULT '0000-00-00',
  `configuration_applies_until` date NOT NULL DEFAULT '0000-00-00',
  `status` smallint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_ieps`
--

LOCK TABLES `product_ieps` WRITE;
/*!40000 ALTER TABLE `product_ieps` DISABLE KEYS */;
INSERT INTO `product_ieps` VALUES (142300000000001,0.2988,0.1600,'2011-09-07','2011-10-30',2),(142300000000001,0.0000,0.1600,'2011-10-30','0000-00-00',1);
/*!40000 ALTER TABLE `product_ieps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tank_delivery_readings_t`
--

DROP TABLE IF EXISTS `tank_delivery_readings_t`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tank_delivery_readings_t` (
  `reception_unique_id` int(11) NOT NULL DEFAULT '0',
  `tank_id` int(11) DEFAULT '0',
  `start_volume` float DEFAULT '0',
  `end_volume` float DEFAULT '0',
  `end_temp` float DEFAULT '0',
  `start_delivery_timestamp` datetime DEFAULT '0000-00-00 00:00:00',
  `end_delivery_timestamp` datetime DEFAULT '0000-00-00 00:00:00',
  `rui` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT '0',
  `start_tc_volume` float DEFAULT '0',
  `end_tc_volume` float DEFAULT '0',
  `start_height` float DEFAULT '0',
  `end_height` float DEFAULT '0',
  `start_water` float DEFAULT '0',
  `end_water` float DEFAULT '0',
  `start_temp` float DEFAULT '0',
  `stn_id` int(11) DEFAULT '0',
  `sent_to_fho` int(11) DEFAULT '0',
  `sent_to_dho` int(11) DEFAULT '0',
  `sent_to_file` int(11) DEFAULT '0',
  `used_for_delivery` int(11) DEFAULT '0',
  `sales_volume_adjustment` float DEFAULT '0',
  `received_timestamp` datetime DEFAULT '0000-00-00 00:00:00',
  `quantity_match` int(11) DEFAULT '0',
  `start_density` float DEFAULT '0',
  `end_density` float DEFAULT '0',
  `start_tc_density` float DEFAULT '0',
  `end_tc_density` float DEFAULT '0',
  `start_total_tc_density_offset` float DEFAULT '0',
  `end_total_tc_density_offset` float DEFAULT '0',
  `quantity_tran` float DEFAULT NULL,
  `quantity_tls` float DEFAULT NULL,
  `net_volume_during_decant` float DEFAULT '0',
  `ci_movimientos` int(11) DEFAULT NULL,
  PRIMARY KEY (`reception_unique_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tank_delivery_readings_t`
--

LOCK TABLES `tank_delivery_readings_t` WRITE;
/*!40000 ALTER TABLE `tank_delivery_readings_t` DISABLE KEYS */;
INSERT INTO `tank_delivery_readings_t` VALUES (200000021,200000017,34837.1,75734.1,23.8752,'2018-11-23 15:30:00','2018-11-23 15:32:00',200000002,0,32479.1,70628.1,1132.55,2081.08,49.0731,49.0622,23.8975,0,0,0,0,0,0,'2018-11-23 15:37:28',0,0,0,0,0,0,0,40896.9,0,0,NULL);
/*!40000 ALTER TABLE `tank_delivery_readings_t` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transacciones`
--

DROP TABLE IF EXISTS `transacciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transacciones` (
  `idtransacciones` bigint(20) NOT NULL,
  `idproductos` int(11) DEFAULT '1',
  `idcortes` int(11) DEFAULT NULL,
  `idvehiculos` int(11) DEFAULT NULL,
  `iddespachadores` int(11) DEFAULT NULL,
  `idtanques` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `bomba` int(5) DEFAULT NULL,
  `manguera` int(5) DEFAULT NULL,
  `cantidad` double(20,4) DEFAULT NULL,
  `odometro` int(11) DEFAULT NULL,
  `odometroAnterior` int(11) DEFAULT NULL,
  `horasMotor` int(11) DEFAULT NULL,
  `horasMotorAnterior` int(11) DEFAULT NULL,
  `placa` varchar(50) DEFAULT NULL,
  `recibo` int(11) DEFAULT NULL,
  `totalizador` int(11) DEFAULT NULL,
  `totalizador_anterior` int(11) DEFAULT NULL,
  `ppv` double(20,4) DEFAULT NULL,
  `sale` double(20,4) DEFAULT NULL,
  `pase` int(11) DEFAULT NULL,
  PRIMARY KEY (`idtransacciones`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transacciones`
--

LOCK TABLES `transacciones` WRITE;
/*!40000 ALTER TABLE `transacciones` DISABLE KEYS */;
INSERT INTO `transacciones` VALUES (300089227,2,0,200000018,0,200000010,'2018-10-08 16:40:17',1,1,0.0000,0,0,0,0,'AutoTag',300089227,0,0,10.0000,0.0000,0);
/*!40000 ALTER TABLE `transacciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `idusuarios` int(11) unsigned NOT NULL,
  `usuario` varchar(50) DEFAULT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `nivel` int(11) DEFAULT '1',
  `estatus` int(11) DEFAULT '1',
  `session_id` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`idusuarios`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehiculos`
--

DROP TABLE IF EXISTS `vehiculos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehiculos` (
  `idvehiculos` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `odometro` int(11) DEFAULT NULL,
  `horasMotor` double(10,2) DEFAULT NULL,
  `estatus` int(11) DEFAULT NULL,
  `rendimiento` double(10,2) DEFAULT NULL,
  `rendimiento2` double(10,2) DEFAULT NULL,
  `idmodelos` int(11) DEFAULT NULL,
  `placa` varchar(50) DEFAULT NULL,
  `tipo` int(11) DEFAULT NULL COMMENT '1 vehiculo, 2 jarreo, 3 contingencia',
  PRIMARY KEY (`idvehiculos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehiculos`
--

LOCK TABLES `vehiculos` WRITE;
/*!40000 ALTER TABLE `vehiculos` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehiculos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-11-23 18:49:02
