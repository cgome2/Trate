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
  `status` smallint(6) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  `transaction_id` bigint(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
  PRIMARY KEY (`reception_unique_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Dumping routines for database 'orpak'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-11-23  1:04:59
