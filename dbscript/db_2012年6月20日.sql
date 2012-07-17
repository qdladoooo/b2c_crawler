/*
SQLyog Trial v8.5 
MySQL - 5.1.39-log : Database - yr_match
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`yr_match` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `yr_match`;

/*Table structure for table `brand` */

DROP TABLE IF EXISTS `brand`;

CREATE TABLE `brand` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `alias_refer_to` int(11) NOT NULL DEFAULT '-1' COMMENT '为0是“真名”；为正数说明与所指id为同一品牌（中英文，惯用称呼，网站编辑错别字等等情况）；为-1表示不确定',
  `source` tinyint(4) unsigned DEFAULT NULL COMMENT '来源有两种：1品牌抓取专用爬虫，2抓取产品信息时创建',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=109 DEFAULT CHARSET=utf8;

/*Table structure for table `category` */

DROP TABLE IF EXISTS `category`;

CREATE TABLE `category` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `alias_refer_to` int(11) NOT NULL DEFAULT '-1' COMMENT '为0是“真名”；为正数说明与所指id为同一品牌（中英文，惯用称呼，网站编辑错别字等等情况）；为-1表示不确定',
  `source` tinyint(1) unsigned DEFAULT '0' COMMENT '来源有两种：1品牌抓取专用爬虫，2抓取产品信息时创建',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

/*Table structure for table `domain` */

DROP TABLE IF EXISTS `domain`;

CREATE TABLE `domain` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `page_code` varchar(255) DEFAULT NULL COMMENT '页面编码',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

/*Table structure for table `keywords` */

DROP TABLE IF EXISTS `keywords`;

CREATE TABLE `keywords` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `cat_id` int(11) unsigned DEFAULT NULL,
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*Table structure for table `product_on_sale` */

DROP TABLE IF EXISTS `product_on_sale`;

CREATE TABLE `product_on_sale` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name_full` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL COMMENT '去除品牌和噪音的name',
  `aka` varchar(20) NOT NULL COMMENT '{$domain_id}_{网站内部编号}，用来做唯一标识',
  `price` float unsigned DEFAULT NULL,
  `brand_id` int(11) unsigned DEFAULT NULL,
  `cat_id` int(11) unsigned DEFAULT NULL,
  `domain_id` int(11) unsigned DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `pic_source_url` varchar(255) DEFAULT NULL,
  `width` varchar(255) DEFAULT '0',
  `height` varchar(255) DEFAULT '0',
  `pic_local_path` varchar(255) DEFAULT NULL,
  `task_id` int(11) unsigned DEFAULT NULL,
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `aka` (`aka`)
) ENGINE=MyISAM AUTO_INCREMENT=504 DEFAULT CHARSET=utf8;

/*Table structure for table `product_source` */

DROP TABLE IF EXISTS `product_source`;

CREATE TABLE `product_source` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name_full` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL COMMENT '除去品牌和噪音的name',
  `aka` varchar(20) NOT NULL COMMENT '{$domain_id}_{网站内部编号}，用来做唯一标识',
  `price` float unsigned DEFAULT NULL,
  `brand_id` int(11) unsigned DEFAULT NULL,
  `cat_id` int(11) unsigned DEFAULT NULL,
  `domain_id` int(11) unsigned DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `pic_source_url` varchar(255) DEFAULT NULL,
  `width` varchar(255) DEFAULT NULL,
  `height` varchar(255) DEFAULT NULL,
  `pic_local_path` varchar(255) DEFAULT NULL,
  `task_id` int(11) unsigned DEFAULT NULL,
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*Table structure for table `s2os_mapping` */

DROP TABLE IF EXISTS `s2os_mapping`;

CREATE TABLE `s2os_mapping` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sid` int(11) unsigned DEFAULT NULL,
  `osid` int(11) unsigned DEFAULT NULL,
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sid` (`sid`,`osid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*Table structure for table `task_url` */

DROP TABLE IF EXISTS `task_url`;

CREATE TABLE `task_url` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  `domain_id` int(11) unsigned DEFAULT NULL,
  `cat_id` int(11) unsigned DEFAULT NULL,
  `status` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '0未处理，1处理中，2处理完毕',
  `processer` varchar(255) DEFAULT ' ' COMMENT '临时存储爬虫进程号，状态为1是才会出现',
  `product_count` int(11) unsigned NOT NULL DEFAULT '0',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`)
) ENGINE=MyISAM AUTO_INCREMENT=779 DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
