-- MySQL dump 10.16  Distrib 10.1.37-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: orpak
-- ------------------------------------------------------
-- Server version	10.1.37-MariaDB-0+deb9u1

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

DROP TRIGGER IF EXISTS orpak.after_insert_mean;

/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
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
ifnull(new.num_of_strings,""), '" "',
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

DROP TRIGGER IF EXISTS orpak.after_update_mean;

/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
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
ifnull(new.num_of_strings,""), '" "',
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-03-12 17:10:53
