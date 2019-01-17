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
  `camion` varchar(255) DEFAULT NULL,
  `chofer` varchar(255) DEFAULT NULL,
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
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_recepcion` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=287 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ci_movimientos`
--

LOCK TABLES `ci_movimientos` WRITE;
/*!40000 ALTER TABLE `ci_movimientos` DISABLE KEYS */;
INSERT INTO `ci_movimientos` VALUES ('2018-09-06 09:05:00',1423,0,4500,0,0,'','','',0,'',0,0,0.0000,80586.4000,0.0000,805864.0000,0.0000,0.0000,0,'N',0,245,NULL),('2018-09-06 09:07:00',1423,0,4500,0,0,'','','9658965',2,'RP',9999,1,650.0000,639.6000,6500.0000,6396.0000,5513.8000,651.0000,0,'N',0,246,NULL),('2018-11-25 00:00:00',1423,1,0,0,0,'','','NULL',3,'NULL',0,2,0.0000,6.1020,0.0000,61.0200,0.0000,0.0000,0,'N',300089268,247,NULL),('2019-01-07 00:00:00',1423,1,0,0,0,'','','NULL',3,'NULL',0,2,0.0000,1.9450,0.0000,19.4500,0.0000,0.0000,0,'N',300089273,249,NULL),('2019-01-08 00:00:00',1423,1,0,0,10003,'1234','1003','NULL',3,'NULL',30003,2,200.0000,2.0870,0.0000,20.8700,0.0000,0.0000,0,'N',300089274,250,NULL),('2019-01-08 00:00:00',1423,1,0,0,0,'','','NULL',3,'NULL',0,2,0.0000,46.1870,0.0000,461.8700,0.0000,0.0000,0,'N',300089275,251,NULL),('2019-01-09 00:00:00',1423,1,0,0,0,'','','NULL',3,'NULL',0,2,0.0000,23.8800,0.0000,238.8000,0.0000,0.0000,0,'N',300089281,254,0),('2018-11-23 15:32:00',1423,0,99998,0,0,'NULL','NULL','NULL',0,'NULL',0,0,0.0000,103553.8100,0.0000,2071076.2000,1.0000,1.0000,0,'N',0,255,4),('2018-11-23 15:32:00',1423,0,99998,0,0,'NULL','NULL','NULL',0,'NULL',0,0,0.0000,103553.8100,0.0000,2071076.2000,1.0000,1.0000,0,'N',0,256,4),('2018-11-23 15:32:00',1423,0,99998,0,0,'NULL','NULL','NULL',0,'NULL',0,0,0.0000,103553.8100,0.0000,2071076.2000,1.0000,1.0000,0,'N',0,257,4),('2018-11-23 15:32:00',1423,0,99998,0,0,'NULL','NULL','NULL',0,'NULL',0,0,0.0000,103553.8100,0.0000,2071076.2000,1.0000,1.0000,0,'N',0,258,4),('2019-01-09 00:00:00',1423,1,99998,0,0,'0','0','NULL',3,'NULL',0,3,0.0000,23.8800,0.0000,10.0000,0.0000,0.0000,0,'N',300089281,283,0),('2019-01-09 00:00:00',1423,1,99998,0,0,'0','0','NULL',3,'NULL',0,3,0.0000,23.8800,0.0000,10.0000,0.0000,0.0000,0,'N',300089281,284,0),('2019-01-09 00:00:00',1423,1,99998,0,0,'0','0','NULL',3,'NULL',0,3,0.0000,23.8800,0.0000,10.0000,0.0000,0.0000,0,'N',300089281,285,0),('2019-01-09 00:00:00',1423,1,99998,0,0,'0','0','NULL',3,'NULL',0,3,0.0000,23.8800,0.0000,10.0000,0.0000,0.0000,0,'N',300089281,286,0);
/*!40000 ALTER TABLE `ci_movimientos` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_movimientos_before_insert` BEFORE INSERT ON `ci_movimientos` FOR EACH ROW BEGIN
SET @exec_var = sys_eval(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/inserta_movimiento_trate.pl "',
ifnull(new.fecha_hora,""), '" "',
ifnull(new.estacion,""), '" "',
ifnull(new.dispensador,""), '" "',
ifnull(new.supervisor,""), '" "',
ifnull(new.despachador,""), '" "',
ifnull(new.viaje,""), '" "',
ifnull(new.camion,""), '" "',
ifnull(new.sello,""), '" "',
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

#SET @exec_vari = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/debug_trigger.pl ',@exec_var,' &'));

if(@exec_var <> 1) THEN
	SIGNAL SQLSTATE '12345'
		SET MESSAGE_TEXT = 'You just woke up Cthulhu';
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
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_movimientos_after_insert` AFTER INSERT ON `ci_movimientos` FOR EACH ROW BEGIN
IF(new.movimiento = 1) THEN 
	UPDATE tank_delivery_readings_t tdrt SET tdrt.ci_movimientos=new.id,tdrt.status=1 WHERE tdrt.end_delivery_timestamp=new.fecha_hora lIMIT 1;
END IF;
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
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ci_pases`
--

LOCK TABLES `ci_pases` WRITE;
/*!40000 ALTER TABLE `ci_pases` DISABLE KEYS */;
INSERT INTO `ci_pases` VALUES (49,'2016-11-01 19:59:00',30001,10001,'1001',1001,200.0000,NULL,'A',0.0000,200.0000,NULL,0,'','2018-12-14 18:24:34'),(50,'2016-11-01 18:59:00',30002,10002,'01',1002,200.0000,NULL,'A',10.5820,200.0000,NULL,0,'','2018-12-11 04:11:16'),(51,'2016-11-01 17:59:00',30003,10003,'9999',1003,200.0000,NULL,'T',30.9370,200.0000,NULL,1,'','2019-01-09 03:27:20'),(52,'2016-11-01 17:19:00',30004,10004,'1000',1004,200.0000,NULL,'A',1.0000,200.0000,NULL,999999,'Razon por la cual se esta reasignando como contingencia el pase','2018-12-11 06:39:14'),(53,'2016-11-02 17:19:00',30005,10005,'AutoTag',1005,200.0000,NULL,'D',11.0000,200.0000,NULL,0,'','2018-12-01 04:51:02'),(54,'2016-11-01 19:59:00',30010,10006,'AutoTag',1006,200.0000,NULL,'D',12.1120,200.0000,NULL,0,'','2018-12-01 04:56:02'),(55,'2016-11-01 19:59:00',30007,10007,'AutoTag',1007,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:56:03'),(56,'2016-11-01 18:59:00',30008,10008,'AutoTag',1008,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:58:03'),(57,'2016-11-01 17:59:00',30009,10009,'AutoTag',1009,200.0000,NULL,'D',135.2250,200.0000,NULL,0,'','2018-12-01 07:13:03'),(58,'2016-11-01 17:19:00',30010,10010,'AutoTag',1010,200.0000,NULL,'D',12.1120,200.0000,NULL,0,'','2018-12-01 04:56:02'),(59,'2016-11-02 17:19:00',30011,10011,'AutoTag',1011,200.0000,NULL,'D',10.0000,200.0000,NULL,0,'','2018-12-01 04:51:03'),(60,'2016-11-01 19:59:00',30012,10012,'AutoTag',1012,200.0000,NULL,'D',24.5000,200.0000,NULL,0,'','2018-12-01 04:56:06'),(61,'2016-11-01 19:59:00',30013,10013,'AutoTag',1013,200.0000,NULL,'D',10.0000,200.0000,NULL,0,'','2018-12-01 04:56:08'),(62,'2016-11-01 18:59:00',30014,10014,'AutoTag',1014,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:58:05'),(63,'2016-11-01 17:59:00',30015,10015,'AutoTag',1015,200.0000,NULL,'D',10.0000,200.0000,NULL,0,'','2018-12-01 07:13:05'),(64,'2016-11-01 17:19:00',30016,10016,'AutoTag',1016,200.0000,NULL,'D',1.0000,200.0000,NULL,0,'','2018-12-01 07:15:02'),(65,'2016-11-02 17:19:00',30017,10017,'AutoTag',1017,200.0000,NULL,'D',16.2700,200.0000,NULL,0,'','2018-12-01 04:51:04'),(66,'2016-11-01 19:59:00',30018,10018,'AutoTag',1018,200.0000,NULL,'D',5.1970,200.0000,NULL,0,'','2018-12-01 04:56:10'),(67,'2016-11-01 19:59:00',30019,10019,'AutoTag',1019,200.0000,NULL,'D',2.1600,200.0000,NULL,0,'','2018-12-01 04:57:04'),(68,'2016-11-01 18:59:00',30020,10020,'AutoTag',1020,200.0000,NULL,'D',1.1800,200.0000,NULL,0,'','2018-12-01 04:58:08'),(69,'2016-11-01 17:59:00',30021,10021,'AutoTag',1021,200.0000,NULL,'D',12.5170,200.0000,NULL,0,'','2018-12-01 07:14:04'),(70,'2016-11-01 17:19:00',30022,10022,'AutoTag',1022,200.0000,NULL,'D',1.0000,200.0000,NULL,0,'','2018-12-01 07:15:04'),(71,'2016-11-02 17:19:00',30023,10023,'AutoTag',1023,200.0000,NULL,'D',8.7200,200.0000,NULL,0,'','2018-12-01 04:51:08'),(72,'2016-11-01 19:59:00',30024,10024,'AutoTag',1024,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:57:04'),(73,'2016-11-01 19:59:00',30025,10025,'AutoTag',1025,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:57:06'),(74,'2016-11-01 18:59:00',30026,10026,'01',1026,200.0000,NULL,'D',5.5270,200.0000,NULL,0,'','2018-12-01 07:14:06'),(75,'2016-11-01 17:59:00',30027,10027,'AutoTag',1027,200.0000,NULL,'D',9.0000,200.0000,NULL,0,'','2018-12-01 07:14:04'),(76,'2016-11-01 17:19:00',30028,10028,'AutoTag',1028,200.0000,NULL,'D',6.1020,200.0000,NULL,0,'','2018-12-01 07:15:06'),(77,'2016-11-02 17:19:00',30029,10029,'AutoTag',1029,200.0000,NULL,'D',7.8500,200.0000,NULL,0,'','2018-12-01 04:51:10'),(78,'2016-11-01 19:59:00',30030,10030,'AutoTag',1030,200.0000,NULL,'D',0.0210,200.0000,NULL,0,'','2018-12-01 04:57:09'),(79,'2016-11-01 19:59:00',30031,10031,'01',1031,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 07:13:02'),(80,'2016-11-01 18:59:00',30032,10032,'AutoTag',1032,200.0000,NULL,'D',6.7170,200.0000,NULL,0,'','2018-12-01 04:58:10'),(81,'2016-11-01 17:59:00',30033,10033,'AutoTag',1033,200.0000,NULL,'D',0.0310,200.0000,NULL,0,'','2018-12-01 07:14:07'),(82,'2016-11-01 17:19:00',30034,10034,'AutoTag',1034,200.0000,NULL,'D',0.0090,200.0000,NULL,0,'','2018-12-01 07:15:08'),(83,'2016-11-02 17:19:00',30035,10035,'AutoTag',1035,200.0000,NULL,'D',34.0070,200.0000,NULL,0,'','2018-12-01 04:51:11'),(84,'2016-11-01 19:59:00',30036,10036,'AutoTag',1036,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:57:10'),(85,'2016-11-01 19:59:00',30037,10037,'AutoTag',1037,200.0000,NULL,'D',0.0000,200.0000,NULL,0,'','2018-12-01 04:58:02');
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
SET @exec_var = sys_exec(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/actualiza_status_mean_orcu.pl ', new.camion,
' ',
IF(new.status='A',2,1),
' &'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `ci_pases_before_update` BEFORE UPDATE ON `ci_pases` FOR EACH ROW BEGIN
SET  @exec_var = sys_eval(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/actualiza_pase_trate.pl ',
IF(new.status IN ('A','R','T'),2,1),' "',
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
ifnull(new.ultima_modificacion,""), '" "',
ifnull(old.camion,""), '" &'));

if(@exec_var <> 1) THEN
	SIGNAL SQLSTATE '12345'
		SET MESSAGE_TEXT = 'You just woke up Cthulhu';
END IF;

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
-- Table structure for table `errores_sql_informix`
--

DROP TABLE IF EXISTS `errores_sql_informix`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `errores_sql_informix` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sql_statement` text,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `errores_sql_informix`
--

LOCK TABLES `errores_sql_informix` WRITE;
/*!40000 ALTER TABLE `errores_sql_informix` DISABLE KEYS */;
INSERT INTO `errores_sql_informix` VALUES (1,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3007','2018-11-28 17:48:48'),(2,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3001','2018-11-30 19:48:53'),(3,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3002','2018-11-30 19:48:55'),(4,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3003','2018-11-30 19:48:58'),(5,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3004','2018-11-30 19:49:01'),(6,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3005','2018-11-30 19:49:03'),(7,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3006','2018-11-30 19:49:05'),(8,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'NULL\', litros_real=CASE WHEN litros_real IS NULL THEN 98.0000 ELSE litros_real + 98.0000 END WHERE pase=3007','2018-11-30 19:49:09'),(9,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 108.0000 ELSE litros_real + 108.0000 END WHERE pase=3002','2018-11-30 19:49:50'),(10,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 109.0000 ELSE litros_real + 109.0000 END WHERE pase=3001','2018-11-30 19:49:51'),(11,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:16:09'),(12,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:16:21'),(13,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:16:28'),(14,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:16:34'),(15,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:16:43'),(16,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:16:59'),(17,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 24.5000 ELSE litros_real + 24.5000 END WHERE pase=30004','2018-11-30 20:17:00'),(18,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:20:41'),(19,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:22:34'),(20,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:22:36'),(21,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:22:39'),(22,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:22:42'),(23,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:22:46'),(24,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:22:48'),(25,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:22:51'),(26,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:22:53'),(27,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:22:55'),(28,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:24:57'),(29,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:24:59'),(30,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:25:00'),(31,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:25:03'),(32,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:25:03'),(33,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 6.7170 ELSE litros_real + 6.7170 END WHERE pase=30001','2018-11-30 20:25:48'),(34,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 1.1800 ELSE litros_real + 1.1800 END WHERE pase=30005','2018-11-30 20:25:51'),(35,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 3.1550 ELSE litros_real + 3.1550 END WHERE pase=30004','2018-11-30 20:26:02'),(36,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 6.7170 ELSE litros_real + 6.7170 END WHERE pase=30001','2018-11-30 20:28:08'),(37,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:28:09'),(38,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 3.1550 ELSE litros_real + 3.1550 END WHERE pase=30004','2018-11-30 20:28:14'),(39,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:28:14'),(40,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:28:15'),(41,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 1.1800 ELSE litros_real + 1.1800 END WHERE pase=30005','2018-11-30 20:28:16'),(42,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:28:16'),(43,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 6.7170 ELSE litros_real + 6.7170 END WHERE pase=30001','2018-11-30 20:28:17'),(44,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:28:18'),(45,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:28:18'),(46,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 6.7170 ELSE litros_real + 6.7170 END WHERE pase=30001','2018-11-30 20:28:21'),(47,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:28:27'),(48,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.5820 ELSE litros_real + 10.5820 END WHERE pase=30002','2018-11-30 20:28:46'),(49,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 26.9050 ELSE litros_real + 26.9050 END WHERE pase=30003','2018-11-30 20:28:46'),(50,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 11.0000 ELSE litros_real + 11.0000 END WHERE pase=30005','2018-11-30 20:28:48'),(51,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.0000 ELSE litros_real + 10.0000 END WHERE pase=30001','2018-11-30 20:28:48'),(52,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.0000 ELSE litros_real + 10.0000 END WHERE pase=30001','2018-11-30 20:31:03'),(53,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.5820 ELSE litros_real + 10.5820 END WHERE pase=30002','2018-11-30 20:31:03'),(54,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 26.9050 ELSE litros_real + 26.9050 END WHERE pase=30003','2018-11-30 20:31:07'),(55,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 11.0000 ELSE litros_real + 11.0000 END WHERE pase=30005','2018-11-30 20:31:10'),(56,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:31:14'),(57,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:31:16'),(58,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:31:20'),(59,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:31:24'),(60,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:31:34'),(61,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:31:36'),(62,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:31:39'),(63,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:31:42'),(64,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:31:45'),(65,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:31:46'),(66,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:31:48'),(67,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:31:49'),(68,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30010','2018-11-30 20:32:08'),(69,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:32:20'),(70,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:32:22'),(71,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:32:26'),(72,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30004','2018-11-30 20:32:31'),(73,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:32:34'),(74,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30010','2018-11-30 20:32:36'),(75,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30036','2018-11-30 20:43:06'),(76,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30030','2018-11-30 20:43:06'),(77,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30010','2018-11-30 20:43:28'),(78,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30008','2018-11-30 20:43:29'),(79,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30009','2018-11-30 20:43:30'),(80,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30012','2018-11-30 20:43:33'),(81,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30014','2018-11-30 20:43:34'),(82,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30015','2018-11-30 20:43:36'),(83,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30018','2018-11-30 20:43:41'),(84,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30020','2018-11-30 20:43:41'),(85,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30021','2018-11-30 20:43:43'),(86,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30024','2018-11-30 20:43:45'),(87,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30026','2018-11-30 20:43:48'),(88,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30027','2018-11-30 20:43:50'),(89,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30032','2018-11-30 20:43:53'),(90,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30033','2018-11-30 20:43:55'),(91,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:44:15'),(92,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30025','2018-11-30 20:45:10'),(93,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30036','2018-11-30 20:45:23'),(94,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30025','2018-11-30 20:46:57'),(95,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30026','2018-11-30 20:47:00'),(96,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30030','2018-11-30 20:47:02'),(97,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30031','2018-11-30 20:47:06'),(98,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:49:31'),(99,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.5820 ELSE litros_real + 10.5820 END WHERE pase=30002','2018-11-30 20:49:32'),(100,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 26.9050 ELSE litros_real + 26.9050 END WHERE pase=30003','2018-11-30 20:49:33'),(101,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 11.0000 ELSE litros_real + 11.0000 END WHERE pase=30005','2018-11-30 20:49:34'),(102,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.0000 ELSE litros_real + 10.0000 END WHERE pase=30011','2018-11-30 20:49:36'),(103,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:53:23'),(104,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:53:26'),(105,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:53:31'),(106,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:53:32'),(107,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30011','2018-11-30 20:53:35'),(108,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:53:37'),(109,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:53:39'),(110,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:53:43'),(111,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:53:46'),(112,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30011','2018-11-30 20:53:49'),(113,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:53:50'),(114,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:53:53'),(115,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:53:57'),(116,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:53:58'),(117,'UPDATE ci_pases SET status=\'D\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30011','2018-11-30 20:54:02'),(118,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 20:54:05'),(119,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30002','2018-11-30 20:54:07'),(120,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30003','2018-11-30 20:54:08'),(121,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30005','2018-11-30 20:54:10'),(122,'UPDATE ci_pases SET status=\'A\', supervisor=\'\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30011','2018-11-30 20:54:13'),(123,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 11.0000 ELSE litros_real + 11.0000 END WHERE pase=30005','2018-11-30 22:51:04'),(124,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.0000 ELSE litros_real + 10.0000 END WHERE pase=30011','2018-11-30 22:51:05'),(125,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 16.2700 ELSE litros_real + 16.2700 END WHERE pase=30017','2018-11-30 22:51:07'),(126,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 8.7200 ELSE litros_real + 8.7200 END WHERE pase=30023','2018-11-30 22:51:09'),(127,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 7.8500 ELSE litros_real + 7.8500 END WHERE pase=30029','2018-11-30 22:51:12'),(128,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 34.0070 ELSE litros_real + 34.0070 END WHERE pase=30035','2018-11-30 22:51:13'),(129,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 12.1120 ELSE litros_real + 12.1120 END WHERE pase=30010','2018-11-30 22:56:04'),(130,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 12.1120 ELSE litros_real + 12.1120 END WHERE pase=30010','2018-11-30 22:56:04'),(131,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30007','2018-11-30 22:56:05'),(132,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 24.5000 ELSE litros_real + 24.5000 END WHERE pase=30012','2018-11-30 22:56:07'),(133,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.0000 ELSE litros_real + 10.0000 END WHERE pase=30013','2018-11-30 22:56:09'),(134,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 5.1970 ELSE litros_real + 5.1970 END WHERE pase=30018','2018-11-30 22:56:12'),(135,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 2.1600 ELSE litros_real + 2.1600 END WHERE pase=30019','2018-11-30 22:57:06'),(136,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30024','2018-11-30 22:57:07'),(137,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30025','2018-11-30 22:57:08'),(138,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0210 ELSE litros_real + 0.0210 END WHERE pase=30030','2018-11-30 22:57:11'),(139,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30036','2018-11-30 22:57:12'),(140,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30037','2018-11-30 22:58:04'),(141,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30008','2018-11-30 22:58:07'),(142,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30014','2018-11-30 22:58:08'),(143,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 1.1800 ELSE litros_real + 1.1800 END WHERE pase=30020','2018-11-30 22:58:10'),(144,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 6.7170 ELSE litros_real + 6.7170 END WHERE pase=30032','2018-11-30 22:58:12'),(145,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-11-30 23:04:03'),(146,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.5820 ELSE litros_real + 10.5820 END WHERE pase=30002','2018-11-30 23:04:04'),(147,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 26.9050 ELSE litros_real + 26.9050 END WHERE pase=30003','2018-11-30 23:04:04'),(148,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30031','2018-12-01 01:13:04'),(149,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 135.2250 ELSE litros_real + 135.2250 END WHERE pase=30009','2018-12-01 01:13:04'),(150,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.0000 ELSE litros_real + 10.0000 END WHERE pase=30015','2018-12-01 01:13:06'),(151,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 12.5170 ELSE litros_real + 12.5170 END WHERE pase=30021','2018-12-01 01:14:05'),(152,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 9.0000 ELSE litros_real + 9.0000 END WHERE pase=30027','2018-12-01 01:14:06'),(153,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 5.5270 ELSE litros_real + 5.5270 END WHERE pase=30026','2018-12-01 01:14:08'),(154,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0310 ELSE litros_real + 0.0310 END WHERE pase=30033','2018-12-01 01:14:09'),(155,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 1.0000 ELSE litros_real + 1.0000 END WHERE pase=30004','2018-12-01 01:14:10'),(156,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 1.0000 ELSE litros_real + 1.0000 END WHERE pase=30016','2018-12-01 01:15:05'),(157,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 1.0000 ELSE litros_real + 1.0000 END WHERE pase=30022','2018-12-01 01:15:06'),(158,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 6.1020 ELSE litros_real + 6.1020 END WHERE pase=30028','2018-12-01 01:15:08'),(159,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0090 ELSE litros_real + 0.0090 END WHERE pase=30034','2018-12-01 01:15:09'),(160,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 20:51:42'),(161,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.5820 ELSE litros_real + 10.5820 END WHERE pase=30002','2018-12-10 20:52:02'),(162,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:26:31'),(163,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:32:03'),(164,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:34:05'),(165,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:34:42'),(166,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:37:15'),(167,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:39:36'),(168,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:40:39'),(169,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 21:41:03'),(170,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 22:07:07'),(171,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 22:07:40'),(172,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 22:09:35'),(173,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 22:11:14'),(174,'UPDATE ci_pases SET status=\'A\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 10.5820 ELSE litros_real + 10.5820 END WHERE pase=30002','2018-12-10 22:11:17'),(175,'UPDATE ci_pases SET status=\'D\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 26.9050 ELSE litros_real + 26.9050 END WHERE pase=30003','2018-12-10 22:11:21'),(176,'UPDATE ci_pases SET status=\'\', supervisor=\'0\', observaciones=\'\', litros_real=CASE WHEN litros_real IS NULL THEN 0.0000 ELSE litros_real + 0.0000 END WHERE pase=30001','2018-12-10 22:11:33');
/*!40000 ALTER TABLE `errores_sql_informix` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `info`
--

DROP TABLE IF EXISTS `info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `info` (
  `info` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `info`
--

LOCK TABLES `info` WRITE;
/*!40000 ALTER TABLE `info` DISABLE KEYS */;
/*!40000 ALTER TABLE `info` ENABLE KEYS */;
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
INSERT INTO `jarreos_t` VALUES (300089281,'2019-01-09 06:00:00',23.8800,10.0000,238.8000,1.0000,1.0000,1,'2019-01-15 18:34:40',238.8000,NULL,'2019-01-15','12:34:40',1);
/*!40000 ALTER TABLE `jarreos_t` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `means`
--

DROP TABLE IF EXISTS `means`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `means` (
  `NAME` text CHARACTER SET utf8mb4,
  `string` text CHARACTER SET utf8mb4,
  `TYPE` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` int(11) DEFAULT '2',
  `rule` int(11) DEFAULT '200000000',
  `hardware_type` text CHARACTER SET utf8mb4,
  `pump` int(11) DEFAULT '0',
  `employee_type` int(11) DEFAULT '0',
  `plate` text CHARACTER SET utf8mb4,
  `model_id` int(11) DEFAULT '0',
  `YEAR` int(11) DEFAULT '0',
  `capacity` decimal(10,0) DEFAULT '0',
  `consumption` decimal(10,0) DEFAULT '0',
  `odometer` text CHARACTER SET utf8mb4,
  `cust_id` text CHARACTER SET utf8mb4,
  `address` text CHARACTER SET utf8mb4,
  `fleet_id` int(11) DEFAULT '200000003',
  `dept_id` int(11) DEFAULT '200000129',
  `acctyp` int(11) DEFAULT '0',
  `available_amount` decimal(10,0) DEFAULT '0',
  `update_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fcc_bos_cleared` int(11) DEFAULT '0',
  `use_pin_code` int(11) DEFAULT '0',
  `pin_code` text CHARACTER SET utf8mb4,
  `auth_pin_from` int(11) DEFAULT '0',
  `nr_pin_retries` int(11) DEFAULT '0',
  `block_if_pin_retries_fail` int(11) DEFAULT '0',
  `opos_prompt_for_plate` int(11) DEFAULT '0',
  `opos_prompt_for_odometer` int(11) DEFAULT '0',
  `do_odo_reasonability_check` int(11) DEFAULT '0',
  `max_odo_delta_allowed` int(11) DEFAULT '0',
  `nr_odo_retries` int(11) DEFAULT '0',
  `driver_id_type_required` int(11) DEFAULT '0',
  `price_list_id` int(11) DEFAULT '0',
  `day_volume` decimal(10,0) DEFAULT '0',
  `week_volume` decimal(10,0) DEFAULT '0',
  `month_volume` decimal(10,0) DEFAULT '0',
  `day_money` decimal(10,0) DEFAULT '0',
  `week_money` decimal(10,0) DEFAULT '0',
  `month_money` decimal(10,0) DEFAULT '0',
  `day_visits` int(11) DEFAULT '0',
  `week_visits` int(11) DEFAULT '0',
  `month_visits` int(11) DEFAULT '0',
  `sent_to_dho` int(11) DEFAULT '0',
  `sent_to_fho` int(11) DEFAULT '0',
  `auttyp` int(11) DEFAULT NULL,
  `engine_hours` decimal(10,0) DEFAULT '0',
  `original_engine_hours` decimal(10,0) DEFAULT '0',
  `target_engine_hours` decimal(10,0) DEFAULT '0',
  `price_list` int(11) DEFAULT '0',
  `need_ho_update` int(11) DEFAULT '0',
  `opos_prompt_for_engine_hours` int(11) DEFAULT '0',
  `address2` text CHARACTER SET utf8mb4,
  `city` text CHARACTER SET utf8mb4,
  `state` text CHARACTER SET utf8mb4,
  `zip` text CHARACTER SET utf8mb4,
  `phone` text CHARACTER SET utf8mb4,
  `user_data1` text CHARACTER SET utf8mb4,
  `user_data2` text CHARACTER SET utf8mb4,
  `user_data3` text CHARACTER SET utf8mb4,
  `user_data4` text CHARACTER SET utf8mb4,
  `user_data5` text CHARACTER SET utf8mb4,
  `start_odometer` decimal(10,0) DEFAULT '0',
  `consumption2` decimal(10,0) DEFAULT '0',
  `is_burned` int(11) DEFAULT '1',
  `viu_serial` varchar(32) CHARACTER SET utf8mb4 DEFAULT '',
  `allow_id_replacement` int(11) DEFAULT '0',
  `num_of_strings` int(11) DEFAULT '1',
  `string2` varchar(50) CHARACTER SET utf8mb4 DEFAULT '',
  `string3` varchar(50) CHARACTER SET utf8mb4 DEFAULT '',
  `string4` varchar(50) CHARACTER SET utf8mb4 DEFAULT '',
  `string5` varchar(50) CHARACTER SET utf8mb4 DEFAULT '',
  `opos_plate_check_type` int(11) DEFAULT '0',
  `nr_plate_retries` int(11) DEFAULT '0',
  `block_if_plate_retries_fail` int(11) DEFAULT '0',
  `chassis_number` varchar(32) CHARACTER SET utf8mb4 DEFAULT '0',
  `sent_to_olic` int(11) DEFAULT '0',
  `issued_date` datetime DEFAULT NULL,
  `last_used` datetime DEFAULT NULL,
  `disable_viu_two_stage` int(11) DEFAULT '0',
  `prompt_always_for_viu` int(11) DEFAULT '0',
  `discovered` int(11) DEFAULT '0',
  `expire` int(11) DEFAULT '0',
  `expire_date` varchar(4) CHARACTER SET utf8mb4 DEFAULT '',
  `year_volume` decimal(10,0) DEFAULT '0',
  `year_money` decimal(10,0) DEFAULT '0',
  `sent_to_client` int(11) DEFAULT '0',
  `do_eh_reasonability_check` int(11) DEFAULT '0',
  `max_eh_delta_allowed` int(11) DEFAULT '0',
  `nr_eh_retries` int(11) DEFAULT '0',
  `reject_if_eh_check_fails` int(11) DEFAULT '0',
  `deposit_date` datetime DEFAULT NULL,
  `cash_on_hand` decimal(10,0) DEFAULT '0',
  `max_cash_allowed` decimal(10,0) DEFAULT '0',
  `block_fueling` int(11) DEFAULT '0',
  `add_dp_approved` int(11) DEFAULT '0',
  `add_dp_approval_date` datetime DEFAULT NULL,
  `add_dp_completion_date` datetime DEFAULT NULL,
  `reject_if_odm_check_fails` int(11) DEFAULT '0',
  `route_prompt` int(11) DEFAULT '0',
  `pressure_level` int(11) DEFAULT '0',
  `attendant_required` int(11) DEFAULT '0',
  `notify_expire` int(11) DEFAULT '0',
  `notification_days` int(11) DEFAULT '14',
  `max_cash_allowed_at_night` decimal(10,0) DEFAULT '0',
  `high_cash_allowed` decimal(10,0) DEFAULT '0',
  `high_cash_allowed_at_night` decimal(10,0) DEFAULT '0',
  `daytime_start` int(11) DEFAULT NULL,
  `nighttime_start` int(11) DEFAULT NULL,
  `shift_instance_id` int(11) DEFAULT NULL,
  `prompt_for_jobcode` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=200002653 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `means`
--

LOCK TABLES `means` WRITE;
/*!40000 ALTER TABLE `means` DISABLE KEYS */;
INSERT INTO `means` VALUES ('1000','CFAA2690',3,200002517,2,200000000,'6',0,0,'1000',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 01:37:42',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('Despachador1','771015005001067604125504114165',4,200002518,2,200000000,'1',0,0,'Despachador',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2019-01-17 00:21:30',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1001','CFAA269000000011111111',3,200002519,2,200000000,'6',0,0,'1001',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 01:25:02',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1005','77907700654345',2,200002521,2,200000000,'1',0,0,'1005',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2019-01-13 15:58:52',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('9999','7710770050010960',2,200002522,1,200000000,'1',0,0,'9999',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-20 09:11:44',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1003','77107700654345',2,200002637,2,200000000,'6',0,0,'1003',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 07:57:15',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('jarreo1','77107700654345',2,200002643,2,200000000,'6',0,0,'jarreo1',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2019-01-13 16:14:00',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,21,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('Despachador2','779017700654345',4,200002645,2,200000000,'6',0,0,'1004',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2019-01-17 00:21:44',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1006','711017700654345',2,200002646,2,200000000,'6',0,0,'1006',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 08:51:21',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1007','711017710654345',2,200002647,2,200000000,'6',0,0,'1007',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 08:52:57',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1008','711017710624345',2,200002649,2,200000000,'6',0,0,'1008',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 09:01:46',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1009','711017710024345',2,200002650,2,200000000,'1',0,0,'1009',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 09:11:58',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('1010','741017710024345',2,200002651,2,200000000,'1',0,0,'1010',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-13 09:15:00',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0),('8888','7710771077718888',2,200002652,2,200000000,'1',0,0,'8888',0,0,0,0,NULL,NULL,NULL,200000003,200000129,0,0,'2018-12-21 07:07:22',0,0,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,'',0,1,'','','','',0,0,0,'0',0,NULL,NULL,0,0,0,0,'',0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,0,0,0,0,0,14,0,0,0,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `means` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `after_insert_mean` AFTER INSERT ON `means` FOR EACH ROW BEGIN

SET @exec_var = sys_eval(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/envia_mean_orcu.pl "',
ifnull(new.id,""), '" "',
ifnull(new.rule,""), '" "',
ifnull(new.dept_id,""), '" "',
ifnull(new.employee_type,""), '" "',
ifnull(new.available_amount,""), '" "',
ifnull(new.fleet_id,""), '" "',
ifnull(new.hardware_type,""), '" "',
ifnull(new.auttyp,""), '" "',
ifnull(new.model_id,""), '" "',
ifnull(new.name,""), '" "',
ifnull(new.odometer,""), '" "',
ifnull(new.plate,""), '" "',
ifnull(new.status,""), '" "',
ifnull(new.string,""), '" "',
ifnull(new.type,""), '" &'));

if(@exec_var <> 1) THEN
	DELETE FROM means WHERE id = LAST_INSERT_ID();
	SET insert_id=LAST_INSERT_ID();
	SIGNAL SQLSTATE '12345'
		SET MESSAGE_TEXT = 'You just woke up Cthulhu';
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
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `after_update_mean` AFTER UPDATE ON `means` FOR EACH ROW BEGIN

SET @exec_var = sys_eval(concat('/usr/bin/perl -I /usr/local/orpak/perl /usr/local/orpak/perl/Trate/bin/envia_mean_orcu.pl "',
ifnull(new.id,""), '" "',
ifnull(new.rule,""), '" "',
ifnull(new.dept_id,""), '" "',
ifnull(new.employee_type,""), '" "',
ifnull(new.available_amount,""), '" "',
ifnull(new.fleet_id,""), '" "',
ifnull(new.hardware_type,""), '" "',
ifnull(new.auttyp,""), '" "',
ifnull(new.model_id,""), '" "',
ifnull(new.name,""), '" "',
ifnull(new.odometer,""), '" "',
ifnull(new.plate,""), '" "',
ifnull(new.status,""), '" "',
ifnull(new.string,""), '" "',
ifnull(new.type,""), '" &'));

if(@exec_var <> 1) THEN
	SIGNAL SQLSTATE '12345'
		SET MESSAGE_TEXT = 'You just woke up Cthulhu';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `status` tinyint(1) unsigned DEFAULT '2',
  `price` decimal(11,2) DEFAULT NULL,
  `NAME` varchar(255) NOT NULL DEFAULT 'Diesel',
  `code` int(11) DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `next_update` datetime DEFAULT NULL,
  `next_price` decimal(11,2) DEFAULT NULL,
  `usuario` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (200000008,2,18.00,'Magna',1,'2019-01-15 21:50:39',NULL,NULL,NULL),(200000009,2,21.20,'Premium',2,'2019-01-15 21:48:06',NULL,NULL,NULL);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores_trate`
--

DROP TABLE IF EXISTS `proveedores_trate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedores_trate` (
  `id` int(11) NOT NULL,
  `proveedor` varchar(255) NOT NULL,
  `status` int(1) unsigned NOT NULL DEFAULT '2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores_trate`
--

LOCK TABLES `proveedores_trate` WRITE;
/*!40000 ALTER TABLE `proveedores_trate` DISABLE KEYS */;
INSERT INTO `proveedores_trate` VALUES (15002,'PEMEX REFINACION',2),(107101,'PETROLEOS DE OCCIDENTE SA DE CV',2);
/*!40000 ALTER TABLE `proveedores_trate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recepciones_combustible`
--

DROP TABLE IF EXISTS `recepciones_combustible`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recepciones_combustible` (
  `id_recepcion` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_recepcion` datetime DEFAULT NULL,
  `fecha_documento` date DEFAULT NULL,
  `terminal_embarque` varchar(255) DEFAULT NULL,
  `sello_pemex` varchar(255) DEFAULT NULL,
  `folio_documento` varchar(255) DEFAULT NULL,
  `tipo_documento` varchar(10) DEFAULT NULL,
  `serie_documento` varchar(10) DEFAULT NULL,
  `numero_proveedor` int(11) DEFAULT '15002',
  `empleado_captura` int(11) DEFAULT NULL,
  `litros_documento` decimal(11,2) DEFAULT NULL,
  `ppv_documento` decimal(11,2) DEFAULT NULL,
  `importe_documento` decimal(11,2) DEFAULT NULL,
  `iva_documento` decimal(11,2) DEFAULT NULL,
  `ieps_documento` decimal(11,4) DEFAULT NULL,
  `status` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`id_recepcion`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recepciones_combustible`
--

LOCK TABLES `recepciones_combustible` WRITE;
/*!40000 ALTER TABLE `recepciones_combustible` DISABLE KEYS */;
INSERT INTO `recepciones_combustible` VALUES (2,'2019-01-09 20:05:24','2019-01-09','1990','721912','294001','Factura','RP',15002,99998,20000.00,19.29,385800.00,53213.79,1879.2000,2),(3,'2019-01-09 20:05:24','2019-01-09','1989','721912','294001','Factura','RP',15002,99998,20000.00,19.29,385800.00,53213.79,1879.2000,1);
/*!40000 ALTER TABLE `recepciones_combustible` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tank_delivery_readings_t`
--

DROP TABLE IF EXISTS `tank_delivery_readings_t`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tank_delivery_readings_t` (
  `id_tank_delivery_reading` int(11) NOT NULL AUTO_INCREMENT,
  `reception_unique_id` int(11) DEFAULT '0',
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
  `start_temp` float DEFAULT '0',
  `start_water` float DEFAULT '0',
  `end_water` float DEFAULT '0',
  `tank_name` varchar(255) DEFAULT '0',
  `tank_number` int(11) DEFAULT '0',
  `quantity_tls` float DEFAULT NULL,
  `quantity_tran` float DEFAULT NULL,
  `ci_movimientos` int(11) DEFAULT NULL,
  `origen_registro` varchar(10) DEFAULT 'TLS',
  `id_recepcion` int(11) DEFAULT NULL,
  `ppv` decimal(11,2) DEFAULT NULL,
  PRIMARY KEY (`id_tank_delivery_reading`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tank_delivery_readings_t`
--

LOCK TABLES `tank_delivery_readings_t` WRITE;
/*!40000 ALTER TABLE `tank_delivery_readings_t` DISABLE KEYS */;
INSERT INTO `tank_delivery_readings_t` VALUES (1,200000003,200000017,79946.8,80586.4,21.2744,'2018-09-06 09:05:00','2018-09-06 09:07:00',200000002,0,76245,76850.6,2183.15,2198.9,21.2681,0,0,'Magna1',1,639.664,0,NULL,'TLS',NULL,NULL),(2,200000005,200000017,43372.3,79632.6,23.792,'2018-06-22 18:18:00','2018-06-22 18:20:00',200000002,1,40491.9,74318.5,1333.12,2175.45,23.7536,0,0,'Magna1',1,36260.3,0,NULL,'TLS',2,NULL),(3,200000007,200000017,10844,43372.3,22.554,'2018-06-22 13:09:00','2018-06-22 13:12:00',200000002,1,10238.4,40912.1,495.803,1333.1,22.4412,0,0,'Magna1',1,32528.3,0,NULL,'TLS',2,NULL),(4,200000009,200000017,46025.6,82051.2,26.9582,'2018-06-18 16:54:00','2018-06-18 16:56:00',200000002,0,41790.2,74469.9,1394.34,2235.18,26.9092,0,0,'Magna1',1,36025.6,0,NULL,'TLS',NULL,NULL),(5,200000011,200000017,26381.5,77974.8,27.1088,'2018-06-18 16:32:00','2018-06-18 16:37:00',200000002,0,23921.2,70673.5,1446.28,2135.05,27.0605,0,0,'Magna1',1,51593.3,0,NULL,'TLS',NULL,NULL),(6,200000013,200000017,3005.29,21741,27.5451,'2018-06-18 15:11:00','2018-06-18 15:15:00',200000002,0,2781.98,19629,352.931,1446.13,24.6026,0,0,'Magna1',1,18735.8,0,NULL,'TLS',NULL,NULL),(7,200000019,200000017,41415.5,52808.3,24.2019,'2018-10-11 14:20:00','2018-10-11 14:22:00',200000002,0,38527.5,49106.6,1287.64,1549.91,24.1635,49.1705,49.1994,'Magna1',1,11392.8,0,NULL,'TLS',NULL,NULL),(8,200000021,200000017,34837.1,75734.1,23.8752,'2018-11-23 15:30:00','2018-11-23 15:32:00',200000002,0,32479.1,70628.1,1132.55,2081.08,23.8975,49.0731,49.0622,'Magna1',1,40896.9,0,NULL,'TLS',NULL,NULL);
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
  `idvehiculos` varchar(255) DEFAULT NULL,
  `iddespachadores` varchar(255) DEFAULT NULL,
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
INSERT INTO `transacciones` VALUES (300089268,2,0,'AutoTag','0',0,'2018-11-25 00:00:00',1,1,6.1020,0,0,0,0,'0',0,0,0,10.0000,61.0200,0),(300089269,2,0,'AutoTag','0',0,'2018-11-25 00:00:00',1,1,0.0090,0,0,0,0,'0',0,0,0,10.0000,0.0870,0),(300089271,2,0,'1234','Despachador',0,'2019-01-07 00:00:00',1,1,4.5270,0,0,0,0,'1234',0,0,0,10.0000,45.2700,30003),(300089272,2,0,'1234','Despachador',0,'2019-01-07 00:00:00',1,1,5.2070,0,0,0,0,'1234',0,0,0,10.0000,52.0700,30003),(300089273,2,0,'1234','Despachador',0,'2019-01-07 00:00:00',1,1,1.9450,0,0,0,0,'1234',0,0,0,10.0000,19.4500,0),(300089274,2,0,'1234','Despachador',0,'2019-01-08 00:00:00',1,1,2.0870,0,0,0,0,'1234',0,0,0,10.0000,20.8700,30003),(300089275,2,0,'1234','Despachador',0,'2019-01-08 00:00:00',1,1,46.1870,0,0,0,0,'1234',0,0,0,10.0000,461.8700,0),(300089276,2,0,'1234','Despachador',0,'2019-01-08 00:00:00',1,1,0.7600,0,0,0,0,'1234',0,0,0,10.0000,7.6000,0),(300089277,2,0,'1234','Despachador',0,'2019-01-08 00:00:00',1,1,43.0820,0,0,0,0,'1234',0,0,0,10.0000,430.8200,0),(300089278,2,0,'1234','Despachador',0,'2019-01-08 00:00:00',1,1,5.8350,0,0,0,0,'1234',0,0,0,10.0000,58.3500,0),(300089279,2,0,'9999','0',0,'2019-01-08 00:00:00',1,1,0.0170,0,0,0,0,'9999',0,0,0,10.0000,0.1750,0),(300089280,2,0,'9999','Despachador',0,'2019-01-08 00:00:00',1,1,0.0140,0,0,0,0,'9999',0,0,0,10.0000,0.1370,0),(300089281,2,0,'jarreo1','Despachador',0,'2019-01-09 00:00:00',1,1,23.8800,0,0,0,0,'jarreo1',0,0,0,10.0000,238.8000,0);
/*!40000 ALTER TABLE `transacciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `turno_bombas`
--

DROP TABLE IF EXISTS `turno_bombas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `turno_bombas` (
  `id_turno` int(11) DEFAULT NULL,
  `id_bomba` int(11) DEFAULT NULL,
  `id_manguera` int(11) DEFAULT NULL,
  `totalizador_al_abrir` decimal(12,2) DEFAULT NULL,
  `totalizador_al_cerrar` decimal(12,2) DEFAULT NULL,
  `timestamp_abrir` datetime DEFAULT NULL,
  `timestamp_cerrar` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `turno_bombas`
--

LOCK TABLES `turno_bombas` WRITE;
/*!40000 ALTER TABLE `turno_bombas` DISABLE KEYS */;
INSERT INTO `turno_bombas` VALUES (1,1,1,100.00,NULL,'2019-01-16 18:18:40',NULL),(1,2,1,50.00,NULL,'2019-01-16 18:18:53',NULL);
/*!40000 ALTER TABLE `turno_bombas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `turno_means`
--

DROP TABLE IF EXISTS `turno_means`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `turno_means` (
  `id_turno` int(11) DEFAULT NULL,
  `mean_id` int(11) DEFAULT NULL,
  `timestamp_add` datetime DEFAULT NULL,
  `timestamp_rm` datetime DEFAULT NULL,
  `usuario_add` int(11) DEFAULT NULL,
  `usuario_rm` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `turno_means`
--

LOCK TABLES `turno_means` WRITE;
/*!40000 ALTER TABLE `turno_means` DISABLE KEYS */;
INSERT INTO `turno_means` VALUES (1,200002518,'2019-01-16 18:22:04',NULL,99998,NULL),(1,200002645,'2019-01-16 18:22:38',NULL,99998,NULL);
/*!40000 ALTER TABLE `turno_means` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `turno_tanques`
--

DROP TABLE IF EXISTS `turno_tanques`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `turno_tanques` (
  `id_turno` int(11) DEFAULT NULL,
  `tank_id` int(11) DEFAULT NULL,
  `volumen_inicial` decimal(12,2) DEFAULT NULL,
  `volumen_final` decimal(12,2) DEFAULT NULL,
  `timestamp_inicial` datetime DEFAULT NULL,
  `timestamp_final` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `turno_tanques`
--

LOCK TABLES `turno_tanques` WRITE;
/*!40000 ALTER TABLE `turno_tanques` DISABLE KEYS */;
INSERT INTO `turno_tanques` VALUES (1,1,15600.00,NULL,'2019-01-16 18:24:04',NULL);
/*!40000 ALTER TABLE `turno_tanques` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `turnos`
--

DROP TABLE IF EXISTS `turnos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `turnos` (
  `id_turno` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_abierto` datetime DEFAULT NULL,
  `usuario_abre` int(11) DEFAULT NULL,
  `fecha_cierre` datetime DEFAULT NULL,
  `usuario_cierra` int(11) DEFAULT NULL,
  `status` int(1) unsigned DEFAULT '2',
  PRIMARY KEY (`id_turno`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `turnos`
--

LOCK TABLES `turnos` WRITE;
/*!40000 ALTER TABLE `turnos` DISABLE KEYS */;
INSERT INTO `turnos` VALUES (1,'2019-01-16 18:04:10',9998,NULL,NULL,2);
/*!40000 ALTER TABLE `turnos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `idusuarios` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `usuario` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb4 DEFAULT NULL,
  `password` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
  `nivel` int(11) DEFAULT '1',
  `estatus` int(11) DEFAULT '1',
  `session_id` varchar(150) CHARACTER SET utf8mb4 DEFAULT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL,
  `caducidad_token` datetime DEFAULT NULL,
  `numero_empleado` int(11) DEFAULT NULL,
  PRIMARY KEY (`idusuarios`,`usuario`),
  UNIQUE KEY `idx_usuario` (`usuario`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin','Administrador','896aaa556c2ac9ab6a3415540b8111d17328ce01',1,1,NULL,'915ba0481ffc18a687b81a3662e1d161fd4ad8e6','2019-01-08 22:29:08',46),(2,'tecflo','Tecflo','896aaa556c2ac9ab6a3415540b8111d17328ce01',1,1,NULL,'a87e9d31a8ef61fca8c4acda9a3c8ecbffa9ec07','2019-01-16 20:31:40',99998),(3,'cgomez','Carlos Gomez','896aaa556c2ac9ab6a3415540b8111d17328ce01',1,1,NULL,NULL,NULL,NULL),(4,'luis','Luis Angel Morales Romo','2d25b85d53a57f3a064d821d4f640977ccab63dd',2,1,NULL,'d7bb8d26d1e2074906df3b5a28466a222a66b94b','2019-01-08 22:44:24',1),(6,'josue','Josue Jimenez','',1,1,NULL,NULL,NULL,NULL),(7,'test','Usuario de Prueba','7c4a8d09ca3762af61e59520943dc26494f8941b',3,0,NULL,NULL,NULL,NULL),(8,'Mario','Mario Alberto','2d25b85d53a57f3a064d821d4f640977ccab63dd',1,0,NULL,NULL,NULL,5);
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

-- Dump completed on 2019-01-16 23:47:37
