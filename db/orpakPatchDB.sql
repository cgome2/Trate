--
-- Table structure for table `ci_pases`
--

DROP TABLE IF EXISTS `ci_pases`;

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
  `mean_contingencia` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=200000001 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `ci_pases`
--

LOCK TABLES `ci_pases` WRITE;
/*!40000 ALTER TABLE `ci_pases` DISABLE KEYS */;
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
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
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
ifnull(old.status,""), '" "',
ifnull(new.mean_contingencia,""), '" "',
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

