-- MySQL dump 10.13  Distrib 5.6.6-m9, for Linux (x86_64)
--
-- Host: localhost    Database: tpch
-- ------------------------------------------------------
-- Server version	5.6.6-m9-56-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `C_CUSTKEY` int(11) NOT NULL,
  `C_NAME` varchar(25) NOT NULL,
  `C_ADDRESS` varchar(40) NOT NULL,
  `C_NATIONKEY` int(11) NOT NULL,
  `C_PHONE` char(15) NOT NULL,
  `C_ACCTBAL` decimal(15,2) NOT NULL,
  `C_MKTSEGMENT` char(10) NOT NULL,
  `C_COMMENT` varchar(117) NOT NULL,
  PRIMARY KEY (`C_CUSTKEY`),
  KEY `CUSTOMER_FK1` (`C_NATIONKEY`),
  CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`C_NATIONKEY`) REFERENCES `nation` (`N_NATIONKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lineitem`
--

DROP TABLE IF EXISTS `lineitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lineitem` (
  `L_ORDERKEY` int(11) NOT NULL,
  `L_PARTKEY` int(11) NOT NULL,
  `L_SUPPKEY` int(11) NOT NULL,
  `L_LINENUMBER` int(11) NOT NULL,
  `L_QUANTITY` decimal(15,2) NOT NULL,
  `L_EXTENDEDPRICE` decimal(15,2) NOT NULL,
  `L_DISCOUNT` decimal(15,2) NOT NULL,
  `L_TAX` decimal(15,2) NOT NULL,
  `L_RETURNFLAG` char(1) NOT NULL,
  `L_LINESTATUS` char(1) NOT NULL,
  `L_SHIPDATE` date NOT NULL,
  `L_COMMITDATE` date NOT NULL,
  `L_RECEIPTDATE` date NOT NULL,
  `L_SHIPINSTRUCT` char(25) NOT NULL,
  `L_SHIPMODE` char(10) NOT NULL,
  `L_COMMENT` varchar(44) NOT NULL,
  PRIMARY KEY (`L_ORDERKEY`,`L_LINENUMBER`),
  KEY `lineitem_k2` (`L_QUANTITY`,`L_PARTKEY`),
  KEY `lineitem_k3` (`L_QUANTITY`,`L_SHIPMODE`,`L_SHIPINSTRUCT`),
  KEY `lineitem_k4` (`L_PARTKEY`,`L_SUPPKEY`,`L_SHIPDATE`),
  KEY `lineitem_k5` (`L_SHIPDATE`,`L_RETURNFLAG`,`L_LINESTATUS`),
  KEY `lineitem_k6` (`L_SHIPDATE`,`L_DISCOUNT`,`L_QUANTITY`),
  CONSTRAINT `LINEITEM_FK1` FOREIGN KEY (`L_ORDERKEY`) REFERENCES `orders` (`O_ORDERKEY`),
  CONSTRAINT `LINEITEM_FK2` FOREIGN KEY (`L_PARTKEY`, `L_SUPPKEY`) REFERENCES `partsupp` (`PS_PARTKEY`, `PS_SUPPKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nation`
--

DROP TABLE IF EXISTS `nation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nation` (
  `N_NATIONKEY` int(11) NOT NULL,
  `N_NAME` char(25) NOT NULL,
  `N_REGIONKEY` int(11) NOT NULL,
  `N_COMMENT` varchar(152) DEFAULT NULL,
  PRIMARY KEY (`N_NATIONKEY`),
  KEY `NATION_FK1` (`N_REGIONKEY`),
  CONSTRAINT `NATION_FK1` FOREIGN KEY (`N_REGIONKEY`) REFERENCES `region` (`R_REGIONKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `O_ORDERKEY` int(11) NOT NULL,
  `O_CUSTKEY` int(11) NOT NULL,
  `O_ORDERSTATUS` char(1) NOT NULL,
  `O_TOTALPRICE` decimal(15,2) NOT NULL,
  `O_ORDERDATE` date NOT NULL,
  `O_ORDERPRIORITY` char(15) NOT NULL,
  `O_CLERK` char(15) NOT NULL,
  `O_SHIPPRIORITY` int(11) NOT NULL,
  `O_COMMENT` varchar(79) NOT NULL,
  PRIMARY KEY (`O_ORDERKEY`),
  KEY `ORDERS_FK1` (`O_CUSTKEY`),
  CONSTRAINT `ORDERS_FK1` FOREIGN KEY (`O_CUSTKEY`) REFERENCES `customer` (`C_CUSTKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `part`
--

DROP TABLE IF EXISTS `part`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `part` (
  `P_PARTKEY` int(11) NOT NULL,
  `P_NAME` varchar(55) NOT NULL,
  `P_MFGR` char(25) NOT NULL,
  `P_BRAND` char(10) NOT NULL,
  `P_TYPE` varchar(25) NOT NULL,
  `P_SIZE` int(11) NOT NULL,
  `P_CONTAINER` char(10) NOT NULL,
  `P_RETAILPRICE` decimal(15,2) NOT NULL,
  `P_COMMENT` varchar(23) NOT NULL,
  PRIMARY KEY (`P_PARTKEY`),
  KEY `part_k1` (`P_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `partsupp`
--

DROP TABLE IF EXISTS `partsupp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partsupp` (
  `PS_PARTKEY` int(11) NOT NULL,
  `PS_SUPPKEY` int(11) NOT NULL,
  `PS_AVAILQTY` int(11) NOT NULL,
  `PS_SUPPLYCOST` decimal(15,2) NOT NULL,
  `PS_COMMENT` varchar(199) NOT NULL,
  PRIMARY KEY (`PS_PARTKEY`,`PS_SUPPKEY`),
  KEY `PARTSUPP_FK1` (`PS_SUPPKEY`),
  CONSTRAINT `PARTSUPP_FK1` FOREIGN KEY (`PS_SUPPKEY`) REFERENCES `supplier` (`S_SUPPKEY`),
  CONSTRAINT `PARTSUPP_FK2` FOREIGN KEY (`PS_PARTKEY`) REFERENCES `part` (`P_PARTKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `region`
--

DROP TABLE IF EXISTS `region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `region` (
  `R_REGIONKEY` int(11) NOT NULL,
  `R_NAME` char(25) NOT NULL,
  `R_COMMENT` varchar(152) DEFAULT NULL,
  PRIMARY KEY (`R_REGIONKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `revenue0`
--

DROP TABLE IF EXISTS `revenue0`;
/*!50001 DROP VIEW IF EXISTS `revenue0`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `revenue0` (
  `supplier_no` int(11),
  `total_revenue` decimal(53,4)
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier` (
  `S_SUPPKEY` int(11) NOT NULL,
  `S_NAME` char(25) NOT NULL,
  `S_ADDRESS` varchar(40) NOT NULL,
  `S_NATIONKEY` int(11) NOT NULL,
  `S_PHONE` char(15) NOT NULL,
  `S_ACCTBAL` decimal(15,2) NOT NULL,
  `S_COMMENT` varchar(101) NOT NULL,
  PRIMARY KEY (`S_SUPPKEY`),
  KEY `supplier_k1` (`S_SUPPKEY`,`S_NATIONKEY`,`S_NAME`),
  KEY `SUPPLIER_FK1` (`S_NATIONKEY`),
  CONSTRAINT `supplier_ibfk_1` FOREIGN KEY (`S_NATIONKEY`) REFERENCES `nation` (`N_NATIONKEY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Final view structure for view `revenue0`
--

/*!50001 DROP TABLE IF EXISTS `revenue0`*/;
/*!50001 DROP VIEW IF EXISTS `revenue0`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `revenue0` AS select `lineitem`.`L_SUPPKEY` AS `supplier_no`,sum((`lineitem`.`L_EXTENDEDPRICE` * (1 - `lineitem`.`L_DISCOUNT`))) AS `total_revenue` from `lineitem` where ((`lineitem`.`L_SHIPDATE` >= DATE'1993-01-01') and (`lineitem`.`L_SHIPDATE` < (DATE'1993-01-01' + interval '3' month))) group by `lineitem`.`L_SUPPKEY` */;
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

-- Dump completed on 2012-11-27 15:53:23
