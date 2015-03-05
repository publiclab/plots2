-- MySQL dump 10.13  Distrib 5.5.34, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: plots2_empty
-- ------------------------------------------------------
-- Server version	5.5.34-0ubuntu0.13.10.1

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
-- Table structure for table `access`
--

DROP TABLE IF EXISTS `access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access` (
  `aid` int(11) NOT NULL AUTO_INCREMENT,
  `mask` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(255) NOT NULL DEFAULT '',
  `status` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access`
--

LOCK TABLES `access` WRITE;
/*!40000 ALTER TABLE `access` DISABLE KEYS */;
/*!40000 ALTER TABLE `access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accesslog`
--

DROP TABLE IF EXISTS `accesslog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accesslog` (
  `aid` int(11) NOT NULL AUTO_INCREMENT,
  `sid` varchar(64) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `url` text,
  `hostname` varchar(128) DEFAULT NULL,
  `uid` int(10) unsigned DEFAULT '0',
  `timer` int(10) unsigned NOT NULL DEFAULT '0',
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`),
  KEY `accesslog_timestamp` (`timestamp`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accesslog`
--

LOCK TABLES `accesslog` WRITE;
/*!40000 ALTER TABLE `accesslog` DISABLE KEYS */;
/*!40000 ALTER TABLE `accesslog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions` (
  `aid` varchar(255) NOT NULL DEFAULT '0',
  `type` varchar(32) NOT NULL DEFAULT '',
  `callback` varchar(255) NOT NULL DEFAULT '',
  `parameters` longtext NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions`
--

LOCK TABLES `actions` WRITE;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions_aid`
--

DROP TABLE IF EXISTS `actions_aid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions_aid` (
  `aid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`aid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions_aid`
--

LOCK TABLES `actions_aid` WRITE;
/*!40000 ALTER TABLE `actions_aid` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions_aid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity`
--

DROP TABLE IF EXISTS `activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity` (
  `aid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `op` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `nid` int(10) unsigned DEFAULT NULL,
  `eid` int(10) unsigned DEFAULT NULL,
  `created` int(10) unsigned NOT NULL,
  `actions_id` varchar(255) NOT NULL DEFAULT '0',
  `status` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`aid`),
  KEY `nid` (`nid`),
  KEY `eid` (`eid`),
  KEY `created` (`created`),
  KEY `actions_id` (`actions_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity`
--

LOCK TABLES `activity` WRITE;
/*!40000 ALTER TABLE `activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_access`
--

DROP TABLE IF EXISTS `activity_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_access` (
  `aid` int(10) unsigned NOT NULL,
  `realm` varchar(255) NOT NULL,
  `value` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`,`realm`,`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_access`
--

LOCK TABLES `activity_access` WRITE;
/*!40000 ALTER TABLE `activity_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_comments`
--

DROP TABLE IF EXISTS `activity_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_comments` (
  `cid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `aid` int(10) unsigned NOT NULL DEFAULT '0',
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `comment` varchar(255) NOT NULL DEFAULT '',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_comments`
--

LOCK TABLES `activity_comments` WRITE;
/*!40000 ALTER TABLE `activity_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_comments_stats`
--

DROP TABLE IF EXISTS `activity_comments_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_comments_stats` (
  `aid` int(10) unsigned NOT NULL DEFAULT '0',
  `changed` int(11) NOT NULL DEFAULT '0',
  `comment_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`),
  KEY `changed` (`changed`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_comments_stats`
--

LOCK TABLES `activity_comments_stats` WRITE;
/*!40000 ALTER TABLE `activity_comments_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_comments_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_messages`
--

DROP TABLE IF EXISTS `activity_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_messages` (
  `amid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `message` longtext NOT NULL,
  PRIMARY KEY (`amid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_messages`
--

LOCK TABLES `activity_messages` WRITE;
/*!40000 ALTER TABLE `activity_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_targets`
--

DROP TABLE IF EXISTS `activity_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_targets` (
  `aid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `amid` int(10) unsigned NOT NULL DEFAULT '0',
  `language` varchar(12) NOT NULL,
  PRIMARY KEY (`aid`,`uid`,`language`),
  UNIQUE KEY `amid` (`amid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_targets`
--

LOCK TABLES `activity_targets` WRITE;
/*!40000 ALTER TABLE `activity_targets` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `advanced_help_index`
--

DROP TABLE IF EXISTS `advanced_help_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advanced_help_index` (
  `sid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module` varchar(255) NOT NULL DEFAULT '',
  `topic` varchar(255) NOT NULL DEFAULT '',
  `language` varchar(12) NOT NULL DEFAULT '',
  PRIMARY KEY (`sid`),
  KEY `language` (`language`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advanced_help_index`
--

LOCK TABLES `advanced_help_index` WRITE;
/*!40000 ALTER TABLE `advanced_help_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `advanced_help_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregator_category`
--

DROP TABLE IF EXISTS `aggregator_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregator_category` (
  `cid` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` longtext NOT NULL,
  `block` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  UNIQUE KEY `title` (`title`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregator_category`
--

LOCK TABLES `aggregator_category` WRITE;
/*!40000 ALTER TABLE `aggregator_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregator_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregator_category_feed`
--

DROP TABLE IF EXISTS `aggregator_category_feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregator_category_feed` (
  `fid` int(11) NOT NULL DEFAULT '0',
  `cid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`,`fid`),
  KEY `fid` (`fid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregator_category_feed`
--

LOCK TABLES `aggregator_category_feed` WRITE;
/*!40000 ALTER TABLE `aggregator_category_feed` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregator_category_feed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregator_category_item`
--

DROP TABLE IF EXISTS `aggregator_category_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregator_category_item` (
  `iid` int(11) NOT NULL DEFAULT '0',
  `cid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`,`iid`),
  KEY `iid` (`iid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregator_category_item`
--

LOCK TABLES `aggregator_category_item` WRITE;
/*!40000 ALTER TABLE `aggregator_category_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregator_category_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregator_feed`
--

DROP TABLE IF EXISTS `aggregator_feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregator_feed` (
  `fid` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  `refresh` int(11) NOT NULL DEFAULT '0',
  `checked` int(11) NOT NULL DEFAULT '0',
  `link` varchar(255) NOT NULL DEFAULT '',
  `description` longtext NOT NULL,
  `image` longtext NOT NULL,
  `etag` varchar(255) NOT NULL DEFAULT '',
  `modified` int(11) NOT NULL DEFAULT '0',
  `block` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fid`),
  UNIQUE KEY `url` (`url`),
  UNIQUE KEY `title` (`title`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregator_feed`
--

LOCK TABLES `aggregator_feed` WRITE;
/*!40000 ALTER TABLE `aggregator_feed` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregator_feed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aggregator_item`
--

DROP TABLE IF EXISTS `aggregator_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregator_item` (
  `iid` int(11) NOT NULL AUTO_INCREMENT,
  `fid` int(11) NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL DEFAULT '',
  `link` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(255) NOT NULL DEFAULT '',
  `description` longtext NOT NULL,
  `timestamp` int(11) DEFAULT NULL,
  `guid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`iid`),
  KEY `fid` (`fid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aggregator_item`
--

LOCK TABLES `aggregator_item` WRITE;
/*!40000 ALTER TABLE `aggregator_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `aggregator_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `antispam_counter`
--

DROP TABLE IF EXISTS `antispam_counter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `antispam_counter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `provider` int(11) NOT NULL DEFAULT '0',
  `spam_detected` int(11) DEFAULT '0',
  `ham_detected` int(11) DEFAULT '0',
  `false_negative` int(11) DEFAULT '0',
  `false_positive` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `antispam_counter`
--

LOCK TABLES `antispam_counter` WRITE;
/*!40000 ALTER TABLE `antispam_counter` DISABLE KEYS */;
/*!40000 ALTER TABLE `antispam_counter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `antispam_moderator`
--

DROP TABLE IF EXISTS `antispam_moderator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `antispam_moderator` (
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `email_for` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`uid`),
  KEY `email_for` (`email_for`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `antispam_moderator`
--

LOCK TABLES `antispam_moderator` WRITE;
/*!40000 ALTER TABLE `antispam_moderator` DISABLE KEYS */;
/*!40000 ALTER TABLE `antispam_moderator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `antispam_spam_marks`
--

DROP TABLE IF EXISTS `antispam_spam_marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `antispam_spam_marks` (
  `content_type` varchar(20) NOT NULL DEFAULT '',
  `content_id` int(10) unsigned NOT NULL DEFAULT '0',
  `spam_created` int(10) unsigned NOT NULL DEFAULT '0',
  `hostname` varchar(128) NOT NULL DEFAULT '',
  `mail` varchar(128) NOT NULL DEFAULT '',
  `signature` varchar(40) DEFAULT '',
  `spaminess` float DEFAULT '1',
  `judge` varchar(40) DEFAULT '',
  KEY `spam_created` (`spam_created`),
  KEY `hostname` (`hostname`),
  KEY `mail` (`mail`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `antispam_spam_marks`
--

LOCK TABLES `antispam_spam_marks` WRITE;
/*!40000 ALTER TABLE `antispam_spam_marks` DISABLE KEYS */;
/*!40000 ALTER TABLE `antispam_spam_marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authmap`
--

DROP TABLE IF EXISTS `authmap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authmap` (
  `aid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL DEFAULT '0',
  `authname` varchar(128) NOT NULL DEFAULT '',
  `module` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`aid`),
  UNIQUE KEY `authname` (`authname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authmap`
--

LOCK TABLES `authmap` WRITE;
/*!40000 ALTER TABLE `authmap` DISABLE KEYS */;
/*!40000 ALTER TABLE `authmap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `autoload_registry`
--

DROP TABLE IF EXISTS `autoload_registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autoload_registry` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(9) NOT NULL DEFAULT '',
  `filename` varchar(255) NOT NULL,
  `module` varchar(255) NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`,`type`),
  KEY `hook` (`type`,`weight`,`module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autoload_registry`
--

LOCK TABLES `autoload_registry` WRITE;
/*!40000 ALTER TABLE `autoload_registry` DISABLE KEYS */;
/*!40000 ALTER TABLE `autoload_registry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `autoload_registry_file`
--

DROP TABLE IF EXISTS `autoload_registry_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autoload_registry_file` (
  `filename` varchar(255) NOT NULL,
  `hash` varchar(64) NOT NULL,
  PRIMARY KEY (`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autoload_registry_file`
--

LOCK TABLES `autoload_registry_file` WRITE;
/*!40000 ALTER TABLE `autoload_registry_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `autoload_registry_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backup_migrate_destinations`
--

DROP TABLE IF EXISTS `backup_migrate_destinations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backup_migrate_destinations` (
  `destination_id` varchar(32) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `type` varchar(32) NOT NULL,
  `location` text NOT NULL,
  `settings` text NOT NULL,
  PRIMARY KEY (`destination_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_migrate_destinations`
--

LOCK TABLES `backup_migrate_destinations` WRITE;
/*!40000 ALTER TABLE `backup_migrate_destinations` DISABLE KEYS */;
/*!40000 ALTER TABLE `backup_migrate_destinations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backup_migrate_profiles`
--

DROP TABLE IF EXISTS `backup_migrate_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backup_migrate_profiles` (
  `profile_id` varchar(32) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `filename` varchar(50) NOT NULL,
  `append_timestamp` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `timestamp_format` varchar(14) NOT NULL,
  `filters` text NOT NULL,
  PRIMARY KEY (`profile_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_migrate_profiles`
--

LOCK TABLES `backup_migrate_profiles` WRITE;
/*!40000 ALTER TABLE `backup_migrate_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `backup_migrate_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backup_migrate_schedules`
--

DROP TABLE IF EXISTS `backup_migrate_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backup_migrate_schedules` (
  `schedule_id` varchar(32) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `source_id` varchar(32) NOT NULL DEFAULT 'db',
  `destination_id` varchar(32) NOT NULL DEFAULT '0',
  `profile_id` varchar(32) NOT NULL DEFAULT '0',
  `keep` int(11) NOT NULL DEFAULT '0',
  `period` int(11) NOT NULL DEFAULT '0',
  `last_run` int(11) NOT NULL DEFAULT '0',
  `enabled` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `cron` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`schedule_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_migrate_schedules`
--

LOCK TABLES `backup_migrate_schedules` WRITE;
/*!40000 ALTER TABLE `backup_migrate_schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `backup_migrate_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batch`
--

DROP TABLE IF EXISTS `batch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch` (
  `bid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `token` varchar(64) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `batch` longtext,
  PRIMARY KEY (`bid`),
  KEY `token` (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch`
--

LOCK TABLES `batch` WRITE;
/*!40000 ALTER TABLE `batch` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocks`
--

DROP TABLE IF EXISTS `blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocks` (
  `bid` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(64) NOT NULL DEFAULT '',
  `delta` varchar(32) NOT NULL DEFAULT '0',
  `theme` varchar(64) NOT NULL DEFAULT '',
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  `region` varchar(64) NOT NULL DEFAULT '',
  `custom` tinyint(4) NOT NULL DEFAULT '0',
  `throttle` tinyint(4) NOT NULL DEFAULT '0',
  `visibility` tinyint(4) NOT NULL DEFAULT '0',
  `pages` text NOT NULL,
  `title` varchar(64) NOT NULL DEFAULT '',
  `cache` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`bid`),
  UNIQUE KEY `tmd` (`theme`,`module`,`delta`),
  KEY `list` (`theme`,`status`,`region`,`weight`,`module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocks`
--

LOCK TABLES `blocks` WRITE;
/*!40000 ALTER TABLE `blocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocks_roles`
--

DROP TABLE IF EXISTS `blocks_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocks_roles` (
  `module` varchar(64) NOT NULL,
  `delta` varchar(32) NOT NULL,
  `rid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`module`,`delta`,`rid`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocks_roles`
--

LOCK TABLES `blocks_roles` WRITE;
/*!40000 ALTER TABLE `blocks_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `blocks_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book` (
  `mlid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `bid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`mlid`),
  UNIQUE KEY `nid` (`nid`),
  KEY `bid` (`bid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boost_cache`
--

DROP TABLE IF EXISTS `boost_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boost_cache` (
  `hash` varchar(32) NOT NULL DEFAULT '',
  `filename` text NOT NULL,
  `base_dir` varchar(128) NOT NULL DEFAULT '',
  `expire` int(10) unsigned NOT NULL DEFAULT '0',
  `lifetime` int(11) NOT NULL DEFAULT '-1',
  `push` smallint(6) NOT NULL DEFAULT '-1',
  `page_callback` varchar(255) NOT NULL DEFAULT '',
  `page_type` varchar(255) NOT NULL DEFAULT '',
  `page_id` varchar(64) NOT NULL DEFAULT '',
  `extension` varchar(8) NOT NULL DEFAULT '',
  `timer` int(10) unsigned NOT NULL DEFAULT '0',
  `timer_average` float NOT NULL DEFAULT '0',
  `hash_url` varchar(32) NOT NULL DEFAULT '',
  `url` text NOT NULL,
  PRIMARY KEY (`hash`),
  KEY `expire` (`expire`),
  KEY `push` (`push`),
  KEY `base_dir` (`base_dir`),
  KEY `page_id` (`page_id`),
  KEY `timer` (`timer`),
  KEY `timer_average` (`timer_average`),
  KEY `page_callback` (`page_callback`),
  KEY `page_type` (`page_type`),
  KEY `extension` (`extension`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boost_cache`
--

LOCK TABLES `boost_cache` WRITE;
/*!40000 ALTER TABLE `boost_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `boost_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boost_cache_relationships`
--

DROP TABLE IF EXISTS `boost_cache_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boost_cache_relationships` (
  `hash` varchar(32) NOT NULL DEFAULT '',
  `base_dir` varchar(128) NOT NULL DEFAULT '',
  `page_callback` varchar(255) NOT NULL DEFAULT '',
  `page_type` varchar(255) NOT NULL DEFAULT '0',
  `page_id` varchar(64) NOT NULL DEFAULT '',
  `child_page_callback` varchar(255) NOT NULL DEFAULT '',
  `child_page_type` varchar(255) NOT NULL DEFAULT '0',
  `child_page_id` varchar(64) NOT NULL DEFAULT '',
  `hash_url` varchar(32) NOT NULL DEFAULT '',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`hash`),
  KEY `base_dir` (`base_dir`),
  KEY `page_callback` (`page_callback`),
  KEY `page_type` (`page_type`),
  KEY `page_id` (`page_id`),
  KEY `child_page_callback` (`child_page_callback`),
  KEY `child_page_type` (`child_page_type`),
  KEY `child_page_id` (`child_page_id`),
  KEY `hash_url` (`hash_url`),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boost_cache_relationships`
--

LOCK TABLES `boost_cache_relationships` WRITE;
/*!40000 ALTER TABLE `boost_cache_relationships` DISABLE KEYS */;
/*!40000 ALTER TABLE `boost_cache_relationships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boost_cache_settings`
--

DROP TABLE IF EXISTS `boost_cache_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boost_cache_settings` (
  `csid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `base_dir` varchar(128) NOT NULL DEFAULT '',
  `page_callback` varchar(255) NOT NULL DEFAULT '',
  `page_type` varchar(255) NOT NULL DEFAULT '0',
  `page_id` varchar(64) NOT NULL DEFAULT '',
  `extension` varchar(8) NOT NULL DEFAULT '',
  `lifetime` int(11) NOT NULL DEFAULT '-1',
  `push` smallint(6) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`csid`),
  KEY `page_callback` (`page_callback`),
  KEY `page_type` (`page_type`),
  KEY `base_dir` (`base_dir`),
  KEY `page_id` (`page_id`),
  KEY `extension` (`extension`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boost_cache_settings`
--

LOCK TABLES `boost_cache_settings` WRITE;
/*!40000 ALTER TABLE `boost_cache_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `boost_cache_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boost_crawler`
--

DROP TABLE IF EXISTS `boost_crawler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boost_crawler` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `hash` varchar(32) NOT NULL DEFAULT '',
  `url` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hash` (`hash`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boost_crawler`
--

LOCK TABLES `boost_crawler` WRITE;
/*!40000 ALTER TABLE `boost_crawler` DISABLE KEYS */;
/*!40000 ALTER TABLE `boost_crawler` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boxes`
--

DROP TABLE IF EXISTS `boxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `boxes` (
  `bid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `body` longtext,
  `info` varchar(128) NOT NULL DEFAULT '',
  `format` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`bid`),
  UNIQUE KEY `info` (`info`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boxes`
--

LOCK TABLES `boxes` WRITE;
/*!40000 ALTER TABLE `boxes` DISABLE KEYS */;
/*!40000 ALTER TABLE `boxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_block`
--

DROP TABLE IF EXISTS `cache_block`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_block` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_block`
--

LOCK TABLES `cache_block` WRITE;
/*!40000 ALTER TABLE `cache_block` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_block` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_content`
--

DROP TABLE IF EXISTS `cache_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_content` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_content`
--

LOCK TABLES `cache_content` WRITE;
/*!40000 ALTER TABLE `cache_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_filter`
--

DROP TABLE IF EXISTS `cache_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_filter` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_filter`
--

LOCK TABLES `cache_filter` WRITE;
/*!40000 ALTER TABLE `cache_filter` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_filter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_form`
--

DROP TABLE IF EXISTS `cache_form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_form` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_form`
--

LOCK TABLES `cache_form` WRITE;
/*!40000 ALTER TABLE `cache_form` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_form` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_gravatar`
--

DROP TABLE IF EXISTS `cache_gravatar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_gravatar` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_gravatar`
--

LOCK TABLES `cache_gravatar` WRITE;
/*!40000 ALTER TABLE `cache_gravatar` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_gravatar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_menu`
--

DROP TABLE IF EXISTS `cache_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_menu` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_menu`
--

LOCK TABLES `cache_menu` WRITE;
/*!40000 ALTER TABLE `cache_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_mollom`
--

DROP TABLE IF EXISTS `cache_mollom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_mollom` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_mollom`
--

LOCK TABLES `cache_mollom` WRITE;
/*!40000 ALTER TABLE `cache_mollom` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_mollom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_page`
--

DROP TABLE IF EXISTS `cache_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_page` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_page`
--

LOCK TABLES `cache_page` WRITE;
/*!40000 ALTER TABLE `cache_page` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_rules`
--

DROP TABLE IF EXISTS `cache_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_rules` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_rules`
--

LOCK TABLES `cache_rules` WRITE;
/*!40000 ALTER TABLE `cache_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_update`
--

DROP TABLE IF EXISTS `cache_update`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_update` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_update`
--

LOCK TABLES `cache_update` WRITE;
/*!40000 ALTER TABLE `cache_update` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_update` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_views`
--

DROP TABLE IF EXISTS `cache_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_views` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_views`
--

LOCK TABLES `cache_views` WRITE;
/*!40000 ALTER TABLE `cache_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_views_data`
--

DROP TABLE IF EXISTS `cache_views_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_views_data` (
  `cid` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  `expire` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `headers` text,
  `serialized` smallint(6) NOT NULL DEFAULT '1',
  PRIMARY KEY (`cid`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_views_data`
--

LOCK TABLES `cache_views_data` WRITE;
/*!40000 ALTER TABLE `cache_views_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_views_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `captcha_points`
--

DROP TABLE IF EXISTS `captcha_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `captcha_points` (
  `form_id` varchar(128) NOT NULL DEFAULT '',
  `module` varchar(64) DEFAULT NULL,
  `captcha_type` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`form_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `captcha_points`
--

LOCK TABLES `captcha_points` WRITE;
/*!40000 ALTER TABLE `captcha_points` DISABLE KEYS */;
/*!40000 ALTER TABLE `captcha_points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `captcha_sessions`
--

DROP TABLE IF EXISTS `captcha_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `captcha_sessions` (
  `csid` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(64) DEFAULT NULL,
  `uid` int(11) NOT NULL DEFAULT '0',
  `sid` varchar(64) NOT NULL DEFAULT '',
  `ip_address` varchar(128) DEFAULT NULL,
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `form_id` varchar(128) NOT NULL,
  `solution` varchar(128) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `attempts` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`csid`),
  KEY `csid_ip` (`csid`,`ip_address`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `captcha_sessions`
--

LOCK TABLES `captcha_sessions` WRITE;
/*!40000 ALTER TABLE `captcha_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `captcha_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_notify`
--

DROP TABLE IF EXISTS `comment_notify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_notify` (
  `cid` int(10) unsigned NOT NULL,
  `notify` tinyint(4) NOT NULL,
  `notify_hash` varchar(32) NOT NULL DEFAULT '',
  `notified` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  KEY `notify_hash` (`notify_hash`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_notify`
--

LOCK TABLES `comment_notify` WRITE;
/*!40000 ALTER TABLE `comment_notify` DISABLE KEYS */;
/*!40000 ALTER TABLE `comment_notify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_notify_user_settings`
--

DROP TABLE IF EXISTS `comment_notify_user_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_notify_user_settings` (
  `uid` int(10) unsigned NOT NULL,
  `node_notify` tinyint(4) NOT NULL DEFAULT '0',
  `comment_notify` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_notify_user_settings`
--

LOCK TABLES `comment_notify_user_settings` WRITE;
/*!40000 ALTER TABLE `comment_notify_user_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `comment_notify_user_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `cid` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL DEFAULT '0',
  `nid` int(11) NOT NULL DEFAULT '0',
  `uid` int(11) NOT NULL DEFAULT '0',
  `subject` varchar(64) NOT NULL DEFAULT '',
  `comment` longtext NOT NULL,
  `hostname` varchar(128) NOT NULL DEFAULT '',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `format` smallint(6) NOT NULL DEFAULT '0',
  `thread` varchar(255) NOT NULL,
  `name` varchar(60) DEFAULT NULL,
  `mail` varchar(64) DEFAULT NULL,
  `homepage` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cid`),
  KEY `pid` (`pid`),
  KEY `nid` (`nid`),
  KEY `status` (`status`),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_tags`
--

DROP TABLE IF EXISTS `community_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `community_tags` (
  `tid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `date` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tid`,`uid`,`nid`),
  KEY `tid` (`tid`),
  KEY `nid` (`nid`),
  KEY `uid` (`uid`),
  KEY `tid_nid` (`tid`,`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_tags`
--

LOCK TABLES `community_tags` WRITE;
/*!40000 ALTER TABLE `community_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `community_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact` (
  `cid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(255) NOT NULL DEFAULT '',
  `recipients` longtext NOT NULL,
  `reply` longtext NOT NULL,
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  `selected` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cid`),
  UNIQUE KEY `category` (`category`),
  KEY `list` (`weight`,`category`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact`
--

LOCK TABLES `contact` WRITE;
/*!40000 ALTER TABLE `contact` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_field_bbox`
--

DROP TABLE IF EXISTS `content_field_bbox`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_field_bbox` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `delta` int(10) unsigned NOT NULL DEFAULT '0',
  `field_bbox_geo` geometry DEFAULT NULL,
  PRIMARY KEY (`vid`,`delta`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_field_bbox`
--

LOCK TABLES `content_field_bbox` WRITE;
/*!40000 ALTER TABLE `content_field_bbox` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_field_bbox` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_field_image_gallery`
--

DROP TABLE IF EXISTS `content_field_image_gallery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_field_image_gallery` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `delta` int(10) unsigned NOT NULL DEFAULT '0',
  `field_image_gallery_fid` int(11) DEFAULT NULL,
  `field_image_gallery_list` tinyint(4) DEFAULT NULL,
  `field_image_gallery_data` text,
  PRIMARY KEY (`vid`,`delta`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_field_image_gallery`
--

LOCK TABLES `content_field_image_gallery` WRITE;
/*!40000 ALTER TABLE `content_field_image_gallery` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_field_image_gallery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_field_main_image`
--

DROP TABLE IF EXISTS `content_field_main_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_field_main_image` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `field_main_image_fid` int(11) DEFAULT NULL,
  `field_main_image_list` tinyint(4) DEFAULT NULL,
  `field_main_image_data` text,
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_field_main_image`
--

LOCK TABLES `content_field_main_image` WRITE;
/*!40000 ALTER TABLE `content_field_main_image` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_field_main_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_field_map`
--

DROP TABLE IF EXISTS `content_field_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_field_map` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `field_map_openlayers_wkt` longtext,
  `delta` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`,`delta`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_field_map`
--

LOCK TABLES `content_field_map` WRITE;
/*!40000 ALTER TABLE `content_field_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_field_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_field_map_editor`
--

DROP TABLE IF EXISTS `content_field_map_editor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_field_map_editor` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `delta` int(10) unsigned NOT NULL DEFAULT '0',
  `field_map_editor_value` longtext,
  PRIMARY KEY (`vid`,`delta`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_field_map_editor`
--

LOCK TABLES `content_field_map_editor` WRITE;
/*!40000 ALTER TABLE `content_field_map_editor` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_field_map_editor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_field_mappers`
--

DROP TABLE IF EXISTS `content_field_mappers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_field_mappers` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `delta` int(10) unsigned NOT NULL DEFAULT '0',
  `field_mappers_value` longtext,
  PRIMARY KEY (`vid`,`delta`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_field_mappers`
--

LOCK TABLES `content_field_mappers` WRITE;
/*!40000 ALTER TABLE `content_field_mappers` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_field_mappers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_group`
--

DROP TABLE IF EXISTS `content_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_group` (
  `group_type` varchar(32) NOT NULL DEFAULT 'standard',
  `type_name` varchar(32) NOT NULL DEFAULT '',
  `group_name` varchar(32) NOT NULL DEFAULT '',
  `label` varchar(255) NOT NULL DEFAULT '',
  `settings` mediumtext NOT NULL,
  `weight` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`type_name`,`group_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_group`
--

LOCK TABLES `content_group` WRITE;
/*!40000 ALTER TABLE `content_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_group_fields`
--

DROP TABLE IF EXISTS `content_group_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_group_fields` (
  `type_name` varchar(32) NOT NULL DEFAULT '',
  `group_name` varchar(32) NOT NULL DEFAULT '',
  `field_name` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`type_name`,`group_name`,`field_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_group_fields`
--

LOCK TABLES `content_group_fields` WRITE;
/*!40000 ALTER TABLE `content_group_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_group_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_node_field`
--

DROP TABLE IF EXISTS `content_node_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_node_field` (
  `field_name` varchar(32) NOT NULL DEFAULT '',
  `type` varchar(127) NOT NULL DEFAULT '',
  `global_settings` mediumtext NOT NULL,
  `required` tinyint(4) NOT NULL DEFAULT '0',
  `multiple` tinyint(4) NOT NULL DEFAULT '0',
  `db_storage` tinyint(4) NOT NULL DEFAULT '1',
  `module` varchar(127) NOT NULL DEFAULT '',
  `db_columns` mediumtext NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT '0',
  `locked` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`field_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_node_field`
--

LOCK TABLES `content_node_field` WRITE;
/*!40000 ALTER TABLE `content_node_field` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_node_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_node_field_instance`
--

DROP TABLE IF EXISTS `content_node_field_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_node_field_instance` (
  `field_name` varchar(32) NOT NULL DEFAULT '',
  `type_name` varchar(32) NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  `label` varchar(255) NOT NULL DEFAULT '',
  `widget_type` varchar(32) NOT NULL DEFAULT '',
  `widget_settings` mediumtext NOT NULL,
  `display_settings` mediumtext NOT NULL,
  `description` mediumtext NOT NULL,
  `widget_module` varchar(127) NOT NULL DEFAULT '',
  `widget_active` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`field_name`,`type_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_node_field_instance`
--

LOCK TABLES `content_node_field_instance` WRITE;
/*!40000 ALTER TABLE `content_node_field_instance` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_node_field_instance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_blog`
--

DROP TABLE IF EXISTS `content_type_blog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_blog` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_blog`
--

LOCK TABLES `content_type_blog` WRITE;
/*!40000 ALTER TABLE `content_type_blog` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_blog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_map`
--

DROP TABLE IF EXISTS `content_type_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_map` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `field_publication_date_value` varchar(20) DEFAULT NULL,
  `field_capture_date_value` varchar(20) DEFAULT NULL,
  `field_geotiff_url_value` longtext,
  `field_google_maps_url_value` longtext,
  `field_openlayers_url_value` longtext,
  `field_tms_url_value` longtext,
  `field_jpg_url_value` longtext,
  `field_license_value` longtext,
  `field_raw_images_value` longtext,
  `field_cartographer_notes_value` longtext,
  `field_cartographer_notes_format` int(10) unsigned DEFAULT NULL,
  `field_notes_value` longtext,
  `field_notes_format` int(10) unsigned DEFAULT NULL,
  `field_mbtiles_url_value` longtext,
  `field_zoom_min_value` int(11) DEFAULT NULL,
  `field_ground_resolution_value` decimal(10,2) DEFAULT NULL,
  `field_geotiff_filesize_value` decimal(10,1) DEFAULT NULL,
  `field_jpg_filesize_value` decimal(10,1) DEFAULT NULL,
  `field_raw_images_filesize_value` decimal(10,1) DEFAULT NULL,
  `field_tms_tile_type_value` longtext,
  `field_zoom_max_value` int(11) DEFAULT NULL,
  `authorship` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_map`
--

LOCK TABLES `content_type_map` WRITE;
/*!40000 ALTER TABLE `content_type_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_note`
--

DROP TABLE IF EXISTS `content_type_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_note` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_note`
--

LOCK TABLES `content_type_note` WRITE;
/*!40000 ALTER TABLE `content_type_note` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_page`
--

DROP TABLE IF EXISTS `content_type_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_page` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `field_toc_value` int(11) DEFAULT NULL,
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_page`
--

LOCK TABLES `content_type_page` WRITE;
/*!40000 ALTER TABLE `content_type_page` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_place`
--

DROP TABLE IF EXISTS `content_type_place`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_place` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `field_host_logo_fid` int(11) DEFAULT NULL,
  `field_host_logo_list` tinyint(4) DEFAULT NULL,
  `field_host_logo_data` text,
  `field_host_name_value` longtext,
  `field_host_name_format` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_place`
--

LOCK TABLES `content_type_place` WRITE;
/*!40000 ALTER TABLE `content_type_place` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_place` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_report`
--

DROP TABLE IF EXISTS `content_type_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_report` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_report`
--

LOCK TABLES `content_type_report` WRITE;
/*!40000 ALTER TABLE `content_type_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_type_tool`
--

DROP TABLE IF EXISTS `content_type_tool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_type_tool` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_type_tool`
--

LOCK TABLES `content_type_tool` WRITE;
/*!40000 ALTER TABLE `content_type_tool` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_type_tool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `context`
--

DROP TABLE IF EXISTS `context`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `context` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `tag` varchar(255) NOT NULL DEFAULT '',
  `conditions` text,
  `reactions` text,
  `condition_mode` int(11) DEFAULT '0',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `context`
--

LOCK TABLES `context` WRITE;
/*!40000 ALTER TABLE `context` DISABLE KEYS */;
/*!40000 ALTER TABLE `context` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ctools_access_ruleset`
--

DROP TABLE IF EXISTS `ctools_access_ruleset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ctools_access_ruleset` (
  `rsid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `admin_title` varchar(255) DEFAULT NULL,
  `admin_description` longtext,
  `requiredcontexts` longtext,
  `contexts` longtext,
  `relationships` longtext,
  `access` longtext,
  PRIMARY KEY (`rsid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ctools_access_ruleset`
--

LOCK TABLES `ctools_access_ruleset` WRITE;
/*!40000 ALTER TABLE `ctools_access_ruleset` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctools_access_ruleset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ctools_css_cache`
--

DROP TABLE IF EXISTS `ctools_css_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ctools_css_cache` (
  `cid` varchar(128) NOT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `css` longtext,
  `filter` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`cid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ctools_css_cache`
--

LOCK TABLES `ctools_css_cache` WRITE;
/*!40000 ALTER TABLE `ctools_css_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctools_css_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ctools_custom_content`
--

DROP TABLE IF EXISTS `ctools_custom_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ctools_custom_content` (
  `cid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `admin_title` varchar(255) DEFAULT NULL,
  `admin_description` longtext,
  `category` varchar(255) DEFAULT NULL,
  `settings` longtext,
  PRIMARY KEY (`cid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ctools_custom_content`
--

LOCK TABLES `ctools_custom_content` WRITE;
/*!40000 ALTER TABLE `ctools_custom_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctools_custom_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ctools_object_cache`
--

DROP TABLE IF EXISTS `ctools_object_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ctools_object_cache` (
  `sid` varchar(64) NOT NULL,
  `name` varchar(128) NOT NULL,
  `obj` varchar(32) NOT NULL,
  `updated` int(10) unsigned NOT NULL DEFAULT '0',
  `data` longtext,
  PRIMARY KEY (`sid`,`obj`,`name`),
  KEY `updated` (`updated`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ctools_object_cache`
--

LOCK TABLES `ctools_object_cache` WRITE;
/*!40000 ALTER TABLE `ctools_object_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctools_object_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_breadcrumb`
--

DROP TABLE IF EXISTS `custom_breadcrumb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_breadcrumb` (
  `bid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `titles` varchar(255) NOT NULL DEFAULT '',
  `paths` varchar(255) DEFAULT NULL,
  `visibility_php` mediumtext NOT NULL,
  `node_type` varchar(64) DEFAULT 'AND',
  PRIMARY KEY (`bid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_breadcrumb`
--

LOCK TABLES `custom_breadcrumb` WRITE;
/*!40000 ALTER TABLE `custom_breadcrumb` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_breadcrumb` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_default`
--

DROP TABLE IF EXISTS `dashboard_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_default` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `thumbnail` int(11) DEFAULT NULL,
  `tags` varchar(255) NOT NULL,
  `default_enabled` tinyint(4) NOT NULL,
  `widget_type` varchar(32) NOT NULL,
  `subtype` varchar(64) NOT NULL,
  `conf` longblob NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_default`
--

LOCK TABLES `dashboard_default` WRITE;
/*!40000 ALTER TABLE `dashboard_default` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_default` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_page`
--

DROP TABLE IF EXISTS `dashboard_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_page` (
  `page_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `path` varchar(22) NOT NULL,
  `weight` tinyint(3) unsigned NOT NULL,
  `title` varchar(20) NOT NULL,
  PRIMARY KEY (`page_id`),
  UNIQUE KEY `uid_path` (`uid`,`path`),
  KEY `uid_weight` (`uid`,`weight`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_page`
--

LOCK TABLES `dashboard_page` WRITE;
/*!40000 ALTER TABLE `dashboard_page` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_widget`
--

DROP TABLE IF EXISTS `dashboard_widget`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_widget` (
  `widget_id` int(10) unsigned NOT NULL,
  `page_id` int(10) unsigned NOT NULL,
  `type` varchar(32) DEFAULT '',
  `subtype` varchar(64) DEFAULT '',
  `conf` longblob,
  `col` tinyint(3) unsigned NOT NULL,
  `weight` tinyint(3) unsigned NOT NULL,
  KEY `page_id_weight` (`page_id`,`weight`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_widget`
--

LOCK TABLES `dashboard_widget` WRITE;
/*!40000 ALTER TABLE `dashboard_widget` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_widget` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `date_format_locale`
--

DROP TABLE IF EXISTS `date_format_locale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `date_format_locale` (
  `format` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `type` varchar(200) NOT NULL,
  `language` varchar(12) NOT NULL,
  PRIMARY KEY (`type`,`language`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `date_format_locale`
--

LOCK TABLES `date_format_locale` WRITE;
/*!40000 ALTER TABLE `date_format_locale` DISABLE KEYS */;
/*!40000 ALTER TABLE `date_format_locale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `date_format_types`
--

DROP TABLE IF EXISTS `date_format_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `date_format_types` (
  `type` varchar(200) NOT NULL,
  `title` varchar(255) NOT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `date_format_types`
--

LOCK TABLES `date_format_types` WRITE;
/*!40000 ALTER TABLE `date_format_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `date_format_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `date_formats`
--

DROP TABLE IF EXISTS `date_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `date_formats` (
  `dfid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `format` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `type` varchar(200) NOT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dfid`),
  UNIQUE KEY `formats` (`format`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `date_formats`
--

LOCK TABLES `date_formats` WRITE;
/*!40000 ALTER TABLE `date_formats` DISABLE KEYS */;
/*!40000 ALTER TABLE `date_formats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devel_queries`
--

DROP TABLE IF EXISTS `devel_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devel_queries` (
  `qid` int(11) NOT NULL AUTO_INCREMENT,
  `function` varchar(255) NOT NULL DEFAULT '',
  `query` text NOT NULL,
  `hash` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`hash`),
  KEY `qid` (`qid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devel_queries`
--

LOCK TABLES `devel_queries` WRITE;
/*!40000 ALTER TABLE `devel_queries` DISABLE KEYS */;
/*!40000 ALTER TABLE `devel_queries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devel_times`
--

DROP TABLE IF EXISTS `devel_times`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devel_times` (
  `tid` int(11) NOT NULL AUTO_INCREMENT,
  `qid` int(11) NOT NULL DEFAULT '0',
  `time` float DEFAULT NULL,
  PRIMARY KEY (`tid`),
  KEY `qid` (`qid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devel_times`
--

LOCK TABLES `devel_times` WRITE;
/*!40000 ALTER TABLE `devel_times` DISABLE KEYS */;
/*!40000 ALTER TABLE `devel_times` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `event_start` datetime NOT NULL,
  `event_end` datetime NOT NULL,
  `timezone` int(11) NOT NULL DEFAULT '0',
  `start_in_dst` int(11) NOT NULL DEFAULT '0',
  `end_in_dst` int(11) NOT NULL DEFAULT '0',
  `has_time` int(11) NOT NULL DEFAULT '1',
  `has_end_date` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`nid`),
  KEY `event_start` (`event_start`),
  KEY `event_end` (`event_end`),
  KEY `timezone` (`timezone`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event`
--

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_timezones`
--

DROP TABLE IF EXISTS `event_timezones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_timezones` (
  `timezone` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `offset` time NOT NULL DEFAULT '00:00:00',
  `offset_dst` time NOT NULL DEFAULT '00:00:00',
  `dst_region` int(11) NOT NULL DEFAULT '0',
  `is_dst` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`timezone`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_timezones`
--

LOCK TABLES `event_timezones` WRITE;
/*!40000 ALTER TABLE `event_timezones` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_timezones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feeds_imagegrabber`
--

DROP TABLE IF EXISTS `feeds_imagegrabber`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feeds_imagegrabber` (
  `feed_nid` int(10) unsigned NOT NULL DEFAULT '0',
  `enabled` int(10) unsigned NOT NULL DEFAULT '0',
  `id_class` int(10) unsigned NOT NULL DEFAULT '0',
  `id_class_desc` varchar(128) DEFAULT NULL,
  `feeling_lucky` int(10) unsigned NOT NULL DEFAULT '0',
  `exec_time` int(10) unsigned NOT NULL DEFAULT '10',
  PRIMARY KEY (`feed_nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feeds_imagegrabber`
--

LOCK TABLES `feeds_imagegrabber` WRITE;
/*!40000 ALTER TABLE `feeds_imagegrabber` DISABLE KEYS */;
/*!40000 ALTER TABLE `feeds_imagegrabber` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feeds_importer`
--

DROP TABLE IF EXISTS `feeds_importer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feeds_importer` (
  `id` varchar(128) NOT NULL DEFAULT '',
  `config` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feeds_importer`
--

LOCK TABLES `feeds_importer` WRITE;
/*!40000 ALTER TABLE `feeds_importer` DISABLE KEYS */;
/*!40000 ALTER TABLE `feeds_importer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feeds_node_item`
--

DROP TABLE IF EXISTS `feeds_node_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feeds_node_item` (
  `nid` int(10) unsigned NOT NULL,
  `id` varchar(128) NOT NULL DEFAULT '',
  `feed_nid` int(10) unsigned NOT NULL,
  `imported` int(11) NOT NULL DEFAULT '0',
  `url` text NOT NULL,
  `guid` text NOT NULL,
  `hash` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`nid`),
  KEY `id` (`id`),
  KEY `feed_nid` (`feed_nid`),
  KEY `imported` (`imported`),
  KEY `url` (`url`(255)),
  KEY `guid` (`guid`(255))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feeds_node_item`
--

LOCK TABLES `feeds_node_item` WRITE;
/*!40000 ALTER TABLE `feeds_node_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `feeds_node_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feeds_push_subscriptions`
--

DROP TABLE IF EXISTS `feeds_push_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feeds_push_subscriptions` (
  `domain` varchar(128) NOT NULL DEFAULT '',
  `subscriber_id` int(10) unsigned NOT NULL DEFAULT '0',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `hub` text NOT NULL,
  `topic` text NOT NULL,
  `secret` varchar(128) NOT NULL DEFAULT '',
  `status` varchar(64) NOT NULL DEFAULT '',
  `post_fields` text,
  PRIMARY KEY (`domain`,`subscriber_id`),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feeds_push_subscriptions`
--

LOCK TABLES `feeds_push_subscriptions` WRITE;
/*!40000 ALTER TABLE `feeds_push_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `feeds_push_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feeds_source`
--

DROP TABLE IF EXISTS `feeds_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feeds_source` (
  `id` varchar(128) NOT NULL DEFAULT '',
  `feed_nid` int(10) unsigned NOT NULL DEFAULT '0',
  `config` text,
  `source` text NOT NULL,
  `batch` longtext,
  PRIMARY KEY (`id`,`feed_nid`),
  KEY `id` (`id`),
  KEY `feed_nid` (`feed_nid`),
  KEY `id_source` (`id`,`source`(128))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feeds_source`
--

LOCK TABLES `feeds_source` WRITE;
/*!40000 ALTER TABLE `feeds_source` DISABLE KEYS */;
/*!40000 ALTER TABLE `feeds_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feeds_term_item`
--

DROP TABLE IF EXISTS `feeds_term_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feeds_term_item` (
  `tid` int(10) unsigned NOT NULL DEFAULT '0',
  `id` varchar(128) NOT NULL DEFAULT '',
  `feed_nid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`tid`),
  KEY `id_feed_nid` (`id`,`feed_nid`),
  KEY `feed_nid` (`feed_nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feeds_term_item`
--

LOCK TABLES `feeds_term_item` WRITE;
/*!40000 ALTER TABLE `feeds_term_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `feeds_term_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `fid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `filepath` varchar(255) NOT NULL DEFAULT '',
  `filemime` varchar(255) NOT NULL DEFAULT '',
  `filesize` int(10) unsigned NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`fid`),
  KEY `uid` (`uid`),
  KEY `status` (`status`),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filter_formats`
--

DROP TABLE IF EXISTS `filter_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filter_formats` (
  `format` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `roles` varchar(255) NOT NULL DEFAULT '',
  `cache` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`format`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filter_formats`
--

LOCK TABLES `filter_formats` WRITE;
/*!40000 ALTER TABLE `filter_formats` DISABLE KEYS */;
/*!40000 ALTER TABLE `filter_formats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filters`
--

DROP TABLE IF EXISTS `filters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filters` (
  `fid` int(11) NOT NULL AUTO_INCREMENT,
  `format` int(11) NOT NULL DEFAULT '0',
  `module` varchar(64) NOT NULL DEFAULT '',
  `delta` tinyint(4) NOT NULL DEFAULT '0',
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fid`),
  UNIQUE KEY `fmd` (`format`,`module`,`delta`),
  KEY `list` (`format`,`weight`,`module`,`delta`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filters`
--

LOCK TABLES `filters` WRITE;
/*!40000 ALTER TABLE `filters` DISABLE KEYS */;
/*!40000 ALTER TABLE `filters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flood`
--

DROP TABLE IF EXISTS `flood`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flood` (
  `fid` int(11) NOT NULL AUTO_INCREMENT,
  `event` varchar(64) NOT NULL DEFAULT '',
  `hostname` varchar(128) NOT NULL DEFAULT '',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fid`),
  KEY `allow` (`event`,`hostname`,`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flood`
--

LOCK TABLES `flood` WRITE;
/*!40000 ALTER TABLE `flood` DISABLE KEYS */;
/*!40000 ALTER TABLE `flood` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `freelinking`
--

DROP TABLE IF EXISTS `freelinking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `freelinking` (
  `hash` char(32) NOT NULL,
  `phrase` varchar(200) NOT NULL,
  `path` varchar(200) NOT NULL,
  `args` varchar(200) NOT NULL,
  PRIMARY KEY (`hash`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freelinking`
--

LOCK TABLES `freelinking` WRITE;
/*!40000 ALTER TABLE `freelinking` DISABLE KEYS */;
/*!40000 ALTER TABLE `freelinking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `geo`
--

DROP TABLE IF EXISTS `geo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `geo` (
  `gid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `handler` varchar(32) NOT NULL,
  `table_name` varchar(255) DEFAULT NULL,
  `column_name` varchar(255) DEFAULT NULL,
  `geo_type` int(11) NOT NULL,
  `srid` int(11) NOT NULL DEFAULT '-1',
  `indexed` tinyint(4) DEFAULT '0',
  `data` text,
  PRIMARY KEY (`gid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `geo`
--

LOCK TABLES `geo` WRITE;
/*!40000 ALTER TABLE `geo` DISABLE KEYS */;
/*!40000 ALTER TABLE `geo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `nid` int(11) NOT NULL DEFAULT '0',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`,`nid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `history`
--

LOCK TABLES `history` WRITE;
/*!40000 ALTER TABLE `history` DISABLE KEYS */;
/*!40000 ALTER TABLE `history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imagecache_action`
--

DROP TABLE IF EXISTS `imagecache_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imagecache_action` (
  `actionid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `presetid` int(10) unsigned NOT NULL DEFAULT '0',
  `weight` int(11) NOT NULL DEFAULT '0',
  `module` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  `data` longtext NOT NULL,
  PRIMARY KEY (`actionid`),
  KEY `presetid` (`presetid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imagecache_action`
--

LOCK TABLES `imagecache_action` WRITE;
/*!40000 ALTER TABLE `imagecache_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `imagecache_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imagecache_preset`
--

DROP TABLE IF EXISTS `imagecache_preset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imagecache_preset` (
  `presetid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `presetname` varchar(255) NOT NULL,
  PRIMARY KEY (`presetid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imagecache_preset`
--

LOCK TABLES `imagecache_preset` WRITE;
/*!40000 ALTER TABLE `imagecache_preset` DISABLE KEYS */;
/*!40000 ALTER TABLE `imagecache_preset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `nid` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `version` int(11) DEFAULT '0',
  `photo_file_name` varchar(255) DEFAULT NULL,
  `photo_content_type` varchar(255) DEFAULT NULL,
  `photo_file_size` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invite`
--

DROP TABLE IF EXISTS `invite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invite` (
  `iid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reg_code` varchar(8) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `uid` int(11) NOT NULL DEFAULT '0',
  `invitee` int(11) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `expiry` int(11) NOT NULL DEFAULT '0',
  `joined` int(11) NOT NULL DEFAULT '0',
  `canceled` tinyint(4) NOT NULL DEFAULT '0',
  `resent` tinyint(4) NOT NULL DEFAULT '0',
  `data` text NOT NULL,
  PRIMARY KEY (`iid`),
  UNIQUE KEY `reg_code` (`reg_code`),
  KEY `email` (`email`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invite`
--

LOCK TABLES `invite` WRITE;
/*!40000 ALTER TABLE `invite` DISABLE KEYS */;
/*!40000 ALTER TABLE `invite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invite_notifications`
--

DROP TABLE IF EXISTS `invite_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invite_notifications` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `invitee` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `uid_invitee` (`uid`,`invitee`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invite_notifications`
--

LOCK TABLES `invite_notifications` WRITE;
/*!40000 ALTER TABLE `invite_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `invite_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_schedule`
--

DROP TABLE IF EXISTS `job_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_schedule` (
  `callback` varchar(128) NOT NULL DEFAULT '',
  `type` varchar(128) NOT NULL DEFAULT '',
  `id` int(10) unsigned NOT NULL DEFAULT '0',
  `last` int(10) unsigned NOT NULL DEFAULT '0',
  `period` int(10) unsigned NOT NULL DEFAULT '0',
  `next` int(10) unsigned NOT NULL DEFAULT '0',
  `periodic` smallint(5) unsigned NOT NULL DEFAULT '0',
  `scheduled` int(10) unsigned NOT NULL DEFAULT '0',
  KEY `callback_type_id` (`callback`,`type`,`id`),
  KEY `callback_type` (`callback`,`type`),
  KEY `next` (`next`),
  KEY `scheduled` (`scheduled`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_schedule`
--

LOCK TABLES `job_schedule` WRITE;
/*!40000 ALTER TABLE `job_schedule` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `language` varchar(12) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `native` varchar(64) NOT NULL DEFAULT '',
  `direction` int(11) NOT NULL DEFAULT '0',
  `enabled` int(11) NOT NULL DEFAULT '0',
  `plurals` int(11) NOT NULL DEFAULT '0',
  `formula` varchar(128) NOT NULL DEFAULT '',
  `domain` varchar(128) NOT NULL DEFAULT '',
  `prefix` varchar(128) NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  `javascript` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`language`),
  KEY `list` (`weight`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locales_source`
--

DROP TABLE IF EXISTS `locales_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locales_source` (
  `lid` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(255) NOT NULL DEFAULT '',
  `textgroup` varchar(255) NOT NULL DEFAULT 'default',
  `source` blob NOT NULL,
  `version` varchar(20) NOT NULL DEFAULT 'none',
  PRIMARY KEY (`lid`),
  KEY `source` (`source`(30))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locales_source`
--

LOCK TABLES `locales_source` WRITE;
/*!40000 ALTER TABLE `locales_source` DISABLE KEYS */;
/*!40000 ALTER TABLE `locales_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locales_target`
--

DROP TABLE IF EXISTS `locales_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locales_target` (
  `lid` int(11) NOT NULL DEFAULT '0',
  `translation` blob NOT NULL,
  `language` varchar(12) NOT NULL DEFAULT '',
  `plid` int(11) NOT NULL DEFAULT '0',
  `plural` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`language`,`lid`,`plural`),
  KEY `lid` (`lid`),
  KEY `plid` (`plid`),
  KEY `plural` (`plural`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locales_target`
--

LOCK TABLES `locales_target` WRITE;
/*!40000 ALTER TABLE `locales_target` DISABLE KEYS */;
/*!40000 ALTER TABLE `locales_target` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mailhandler`
--

DROP TABLE IF EXISTS `mailhandler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailhandler` (
  `mid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mail` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `port` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `security` tinyint(3) unsigned NOT NULL,
  `replies` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `fromheader` varchar(128) DEFAULT NULL,
  `commands` text,
  `sigseparator` varchar(128) DEFAULT NULL,
  `enabled` tinyint(4) DEFAULT NULL,
  `folder` varchar(255) NOT NULL,
  `imap` tinyint(3) unsigned NOT NULL,
  `mime` varchar(128) DEFAULT NULL,
  `mailto` varchar(255) NOT NULL,
  `delete_after_read` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `extraimap` varchar(255) NOT NULL,
  `format` int(11) NOT NULL DEFAULT '0',
  `authentication` varchar(255) NOT NULL DEFAULT 'mailhandler_default',
  PRIMARY KEY (`mid`),
  KEY `mail` (`mail`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mailhandler`
--

LOCK TABLES `mailhandler` WRITE;
/*!40000 ALTER TABLE `mailhandler` DISABLE KEYS */;
/*!40000 ALTER TABLE `mailhandler` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_custom`
--

DROP TABLE IF EXISTS `menu_custom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_custom` (
  `menu_name` varchar(32) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  PRIMARY KEY (`menu_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_custom`
--

LOCK TABLES `menu_custom` WRITE;
/*!40000 ALTER TABLE `menu_custom` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_custom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_links`
--

DROP TABLE IF EXISTS `menu_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_links` (
  `menu_name` varchar(32) NOT NULL DEFAULT '',
  `mlid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `plid` int(10) unsigned NOT NULL DEFAULT '0',
  `link_path` varchar(255) NOT NULL DEFAULT '',
  `router_path` varchar(255) NOT NULL DEFAULT '',
  `link_title` varchar(255) NOT NULL DEFAULT '',
  `options` text,
  `module` varchar(255) NOT NULL DEFAULT 'system',
  `hidden` smallint(6) NOT NULL DEFAULT '0',
  `external` smallint(6) NOT NULL DEFAULT '0',
  `has_children` smallint(6) NOT NULL DEFAULT '0',
  `expanded` smallint(6) NOT NULL DEFAULT '0',
  `weight` int(11) NOT NULL DEFAULT '0',
  `depth` smallint(6) NOT NULL DEFAULT '0',
  `customized` smallint(6) NOT NULL DEFAULT '0',
  `p1` int(10) unsigned NOT NULL DEFAULT '0',
  `p2` int(10) unsigned NOT NULL DEFAULT '0',
  `p3` int(10) unsigned NOT NULL DEFAULT '0',
  `p4` int(10) unsigned NOT NULL DEFAULT '0',
  `p5` int(10) unsigned NOT NULL DEFAULT '0',
  `p6` int(10) unsigned NOT NULL DEFAULT '0',
  `p7` int(10) unsigned NOT NULL DEFAULT '0',
  `p8` int(10) unsigned NOT NULL DEFAULT '0',
  `p9` int(10) unsigned NOT NULL DEFAULT '0',
  `updated` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mlid`),
  KEY `path_menu` (`link_path`(128),`menu_name`),
  KEY `menu_plid_expand_child` (`menu_name`,`plid`,`expanded`,`has_children`),
  KEY `menu_parents` (`menu_name`,`p1`,`p2`,`p3`,`p4`,`p5`,`p6`,`p7`,`p8`,`p9`),
  KEY `router_path` (`router_path`(128))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_links`
--

LOCK TABLES `menu_links` WRITE;
/*!40000 ALTER TABLE `menu_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_router`
--

DROP TABLE IF EXISTS `menu_router`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_router` (
  `path` varchar(255) NOT NULL DEFAULT '',
  `load_functions` text NOT NULL,
  `to_arg_functions` text NOT NULL,
  `access_callback` varchar(255) NOT NULL DEFAULT '',
  `access_arguments` text,
  `page_callback` varchar(255) NOT NULL DEFAULT '',
  `page_arguments` text,
  `fit` int(11) NOT NULL DEFAULT '0',
  `number_parts` smallint(6) NOT NULL DEFAULT '0',
  `tab_parent` varchar(255) NOT NULL DEFAULT '',
  `tab_root` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `title_callback` varchar(255) NOT NULL DEFAULT '',
  `title_arguments` varchar(255) NOT NULL DEFAULT '',
  `type` int(11) NOT NULL DEFAULT '0',
  `block_callback` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `position` varchar(255) NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  `file` mediumtext,
  PRIMARY KEY (`path`),
  KEY `fit` (`fit`),
  KEY `tab_parent` (`tab_parent`),
  KEY `tab_root_weight_title` (`tab_root`(64),`weight`,`title`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_router`
--

LOCK TABLES `menu_router` WRITE;
/*!40000 ALTER TABLE `menu_router` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_router` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messaging_message_parts`
--

DROP TABLE IF EXISTS `messaging_message_parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messaging_message_parts` (
  `type` varchar(100) NOT NULL DEFAULT '',
  `method` varchar(50) NOT NULL DEFAULT '',
  `msgkey` varchar(100) NOT NULL DEFAULT '',
  `module` varchar(255) NOT NULL DEFAULT '',
  `message` longtext NOT NULL,
  KEY `type` (`type`),
  KEY `method` (`method`),
  KEY `msgkey` (`msgkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messaging_message_parts`
--

LOCK TABLES `messaging_message_parts` WRITE;
/*!40000 ALTER TABLE `messaging_message_parts` DISABLE KEYS */;
/*!40000 ALTER TABLE `messaging_message_parts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messaging_store`
--

DROP TABLE IF EXISTS `messaging_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messaging_store` (
  `mqid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `sender` int(10) unsigned NOT NULL DEFAULT '0',
  `method` varchar(255) NOT NULL DEFAULT '',
  `destination` varchar(255) NOT NULL DEFAULT '',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `body` longtext NOT NULL,
  `params` longtext NOT NULL,
  `created` int(11) NOT NULL DEFAULT '0',
  `sent` int(11) NOT NULL DEFAULT '0',
  `cron` tinyint(4) NOT NULL DEFAULT '0',
  `queue` tinyint(4) NOT NULL DEFAULT '0',
  `log` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mqid`),
  KEY `cron` (`cron`),
  KEY `queue` (`queue`),
  KEY `log` (`log`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messaging_store`
--

LOCK TABLES `messaging_store` WRITE;
/*!40000 ALTER TABLE `messaging_store` DISABLE KEYS */;
/*!40000 ALTER TABLE `messaging_store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mollom`
--

DROP TABLE IF EXISTS `mollom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mollom` (
  `entity` varchar(32) NOT NULL DEFAULT '',
  `id` varchar(32) NOT NULL DEFAULT '',
  `session_id` varchar(255) NOT NULL DEFAULT '',
  `form_id` varchar(255) NOT NULL DEFAULT '',
  `changed` int(11) NOT NULL DEFAULT '0',
  `spam` tinyint(4) DEFAULT NULL,
  `quality` float DEFAULT NULL,
  `profanity` float DEFAULT NULL,
  `languages` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`entity`,`id`),
  KEY `session_id` (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mollom`
--

LOCK TABLES `mollom` WRITE;
/*!40000 ALTER TABLE `mollom` DISABLE KEYS */;
/*!40000 ALTER TABLE `mollom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mollom_form`
--

DROP TABLE IF EXISTS `mollom_form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mollom_form` (
  `form_id` varchar(255) NOT NULL DEFAULT '',
  `mode` tinyint(4) NOT NULL DEFAULT '0',
  `checks` text,
  `discard` tinyint(4) NOT NULL DEFAULT '1',
  `enabled_fields` text,
  `strictness` varchar(8) NOT NULL DEFAULT 'normal',
  `module` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`form_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mollom_form`
--

LOCK TABLES `mollom_form` WRITE;
/*!40000 ALTER TABLE `mollom_form` DISABLE KEYS */;
/*!40000 ALTER TABLE `mollom_form` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node`
--

DROP TABLE IF EXISTS `node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node` (
  `nid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` varchar(32) NOT NULL DEFAULT '',
  `language` varchar(12) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `uid` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '1',
  `created` int(11) NOT NULL DEFAULT '0',
  `changed` int(11) NOT NULL DEFAULT '0',
  `comment` int(11) NOT NULL DEFAULT '0',
  `promote` int(11) NOT NULL DEFAULT '0',
  `moderate` int(11) NOT NULL DEFAULT '0',
  `sticky` int(11) NOT NULL DEFAULT '0',
  `tnid` int(10) unsigned NOT NULL DEFAULT '0',
  `translate` int(11) NOT NULL DEFAULT '0',
  `cached_likes` int(11) DEFAULT '0',
  PRIMARY KEY (`nid`),
  UNIQUE KEY `vid` (`vid`),
  KEY `node_changed` (`changed`),
  KEY `node_created` (`created`),
  KEY `node_moderate` (`moderate`),
  KEY `node_promote_status` (`promote`,`status`),
  KEY `node_status_type` (`status`,`type`,`nid`),
  KEY `node_title_type` (`title`,`type`(4)),
  KEY `node_type` (`type`(4)),
  KEY `uid` (`uid`),
  KEY `tnid` (`tnid`),
  KEY `translate` (`translate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node`
--

LOCK TABLES `node` WRITE;
/*!40000 ALTER TABLE `node` DISABLE KEYS */;
/*!40000 ALTER TABLE `node` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_access`
--

DROP TABLE IF EXISTS `node_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_access` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `gid` int(10) unsigned NOT NULL DEFAULT '0',
  `realm` varchar(255) NOT NULL DEFAULT '',
  `grant_view` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `grant_update` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `grant_delete` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`nid`,`gid`,`realm`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_access`
--

LOCK TABLES `node_access` WRITE;
/*!40000 ALTER TABLE `node_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_comment_statistics`
--

DROP TABLE IF EXISTS `node_comment_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_comment_statistics` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `last_comment_timestamp` int(11) NOT NULL DEFAULT '0',
  `last_comment_name` varchar(60) DEFAULT NULL,
  `last_comment_uid` int(11) NOT NULL DEFAULT '0',
  `comment_count` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`nid`),
  KEY `node_comment_timestamp` (`last_comment_timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_comment_statistics`
--

LOCK TABLES `node_comment_statistics` WRITE;
/*!40000 ALTER TABLE `node_comment_statistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_comment_statistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_counter`
--

DROP TABLE IF EXISTS `node_counter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_counter` (
  `nid` int(11) NOT NULL DEFAULT '0',
  `totalcount` bigint(20) unsigned NOT NULL DEFAULT '0',
  `daycount` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_counter`
--

LOCK TABLES `node_counter` WRITE;
/*!40000 ALTER TABLE `node_counter` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_counter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_images`
--

DROP TABLE IF EXISTS `node_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_images` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `filepath` varchar(255) NOT NULL DEFAULT '',
  `filemime` varchar(255) NOT NULL DEFAULT '',
  `filesize` int(10) unsigned NOT NULL DEFAULT '0',
  `thumbpath` varchar(255) NOT NULL DEFAULT '',
  `thumbsize` int(10) unsigned NOT NULL DEFAULT '0',
  `status` smallint(5) unsigned NOT NULL DEFAULT '1',
  `weight` smallint(6) NOT NULL DEFAULT '0',
  `description` varchar(255) NOT NULL DEFAULT '',
  `timestamp` int(10) unsigned DEFAULT '0',
  `list` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  KEY `nid_status` (`nid`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_images`
--

LOCK TABLES `node_images` WRITE;
/*!40000 ALTER TABLE `node_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_revisions`
--

DROP TABLE IF EXISTS `node_revisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_revisions` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `vid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL DEFAULT '',
  `body` longtext NOT NULL,
  `teaser` longtext NOT NULL,
  `log` longtext NOT NULL,
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `format` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `nid` (`nid`),
  KEY `uid` (`uid`),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_revisions`
--

LOCK TABLES `node_revisions` WRITE;
/*!40000 ALTER TABLE `node_revisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_revisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_selections`
--

DROP TABLE IF EXISTS `node_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_selections` (
  `user_id` int(11) DEFAULT NULL,
  `nid` int(11) DEFAULT NULL,
  `following` tinyint(1) DEFAULT '0',
  `liking` tinyint(1) DEFAULT '0',
  UNIQUE KEY `index_node_selections_on_user_id_and_nid` (`user_id`,`nid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_selections`
--

LOCK TABLES `node_selections` WRITE;
/*!40000 ALTER TABLE `node_selections` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_selections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `node_type`
--

DROP TABLE IF EXISTS `node_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_type` (
  `type` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `module` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `help` mediumtext NOT NULL,
  `has_title` tinyint(3) unsigned NOT NULL,
  `title_label` varchar(255) NOT NULL DEFAULT '',
  `has_body` tinyint(3) unsigned NOT NULL,
  `body_label` varchar(255) NOT NULL DEFAULT '',
  `min_word_count` smallint(5) unsigned NOT NULL,
  `custom` tinyint(4) NOT NULL DEFAULT '0',
  `modified` tinyint(4) NOT NULL DEFAULT '0',
  `locked` tinyint(4) NOT NULL DEFAULT '0',
  `orig_type` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `node_type`
--

LOCK TABLES `node_type` WRITE;
/*!40000 ALTER TABLE `node_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `node_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `sid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `conditions` int(10) unsigned NOT NULL,
  `send_interval` int(11) DEFAULT NULL,
  `send_method` varchar(255) NOT NULL,
  `cron` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `module` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  `destination` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`sid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications_event`
--

DROP TABLE IF EXISTS `notifications_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications_event` (
  `eid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `oid` int(10) unsigned NOT NULL DEFAULT '0',
  `language` varchar(255) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `params` text,
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `counter` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`eid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications_event`
--

LOCK TABLES `notifications_event` WRITE;
/*!40000 ALTER TABLE `notifications_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications_fields`
--

DROP TABLE IF EXISTS `notifications_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications_fields` (
  `sid` int(10) unsigned NOT NULL,
  `field` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `intval` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`sid`,`field`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications_fields`
--

LOCK TABLES `notifications_fields` WRITE;
/*!40000 ALTER TABLE `notifications_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications_queue`
--

DROP TABLE IF EXISTS `notifications_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications_queue` (
  `sqid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `eid` int(10) unsigned NOT NULL DEFAULT '0',
  `sid` int(10) unsigned NOT NULL DEFAULT '0',
  `uid` int(11) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `send_interval` int(11) DEFAULT NULL,
  `send_method` varchar(255) DEFAULT NULL,
  `sent` int(10) unsigned NOT NULL DEFAULT '0',
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `cron` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `conditions` int(10) unsigned NOT NULL DEFAULT '0',
  `module` varchar(255) DEFAULT NULL,
  `destination` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`sqid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications_queue`
--

LOCK TABLES `notifications_queue` WRITE;
/*!40000 ALTER TABLE `notifications_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications_sent`
--

DROP TABLE IF EXISTS `notifications_sent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications_sent` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `send_interval` int(11) NOT NULL DEFAULT '0',
  `send_method` varchar(50) NOT NULL,
  `sent` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`,`send_interval`,`send_method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications_sent`
--

LOCK TABLES `notifications_sent` WRITE;
/*!40000 ALTER TABLE `notifications_sent` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications_sent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notify`
--

DROP TABLE IF EXISTS `notify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notify` (
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `node` tinyint(4) NOT NULL DEFAULT '0',
  `comment` tinyint(4) NOT NULL DEFAULT '0',
  `attempts` tinyint(4) NOT NULL DEFAULT '0',
  `teasers` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notify`
--

LOCK TABLES `notify` WRITE;
/*!40000 ALTER TABLE `notify` DISABLE KEYS */;
/*!40000 ALTER TABLE `notify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openid_association`
--

DROP TABLE IF EXISTS `openid_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openid_association` (
  `idp_endpoint_uri` varchar(255) DEFAULT NULL,
  `assoc_handle` varchar(255) NOT NULL,
  `assoc_type` varchar(32) DEFAULT NULL,
  `session_type` varchar(32) DEFAULT NULL,
  `mac_key` varchar(255) DEFAULT NULL,
  `created` int(11) NOT NULL DEFAULT '0',
  `expires_in` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`assoc_handle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openid_association`
--

LOCK TABLES `openid_association` WRITE;
/*!40000 ALTER TABLE `openid_association` DISABLE KEYS */;
/*!40000 ALTER TABLE `openid_association` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openid_nonce`
--

DROP TABLE IF EXISTS `openid_nonce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openid_nonce` (
  `idp_endpoint_uri` varchar(255) DEFAULT NULL,
  `nonce` varchar(255) DEFAULT NULL,
  `expires` int(11) NOT NULL DEFAULT '0',
  KEY `nonce` (`nonce`),
  KEY `expires` (`expires`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openid_nonce`
--

LOCK TABLES `openid_nonce` WRITE;
/*!40000 ALTER TABLE `openid_nonce` DISABLE KEYS */;
/*!40000 ALTER TABLE `openid_nonce` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openid_provider_association`
--

DROP TABLE IF EXISTS `openid_provider_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openid_provider_association` (
  `assoc_handle` varchar(255) NOT NULL DEFAULT '',
  `assoc_type` varchar(32) NOT NULL DEFAULT '',
  `session_type` varchar(32) NOT NULL DEFAULT '',
  `mac_key` varchar(255) NOT NULL DEFAULT '',
  `created` int(11) NOT NULL DEFAULT '0',
  `expires_in` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`assoc_handle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openid_provider_association`
--

LOCK TABLES `openid_provider_association` WRITE;
/*!40000 ALTER TABLE `openid_provider_association` DISABLE KEYS */;
/*!40000 ALTER TABLE `openid_provider_association` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openid_provider_relying_party`
--

DROP TABLE IF EXISTS `openid_provider_relying_party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openid_provider_relying_party` (
  `rpid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `realm` varchar(255) NOT NULL DEFAULT '',
  `first_time` int(11) NOT NULL DEFAULT '0',
  `last_time` int(11) NOT NULL DEFAULT '0',
  `auto_release` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`rpid`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openid_provider_relying_party`
--

LOCK TABLES `openid_provider_relying_party` WRITE;
/*!40000 ALTER TABLE `openid_provider_relying_party` DISABLE KEYS */;
/*!40000 ALTER TABLE `openid_provider_relying_party` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openlayers_layers`
--

DROP TABLE IF EXISTS `openlayers_layers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openlayers_layers` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `data` text,
  PRIMARY KEY (`name`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openlayers_layers`
--

LOCK TABLES `openlayers_layers` WRITE;
/*!40000 ALTER TABLE `openlayers_layers` DISABLE KEYS */;
/*!40000 ALTER TABLE `openlayers_layers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openlayers_map_presets`
--

DROP TABLE IF EXISTS `openlayers_map_presets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openlayers_map_presets` (
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `data` text NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openlayers_map_presets`
--

LOCK TABLES `openlayers_map_presets` WRITE;
/*!40000 ALTER TABLE `openlayers_map_presets` DISABLE KEYS */;
/*!40000 ALTER TABLE `openlayers_map_presets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openlayers_styles`
--

DROP TABLE IF EXISTS `openlayers_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openlayers_styles` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `data` text,
  PRIMARY KEY (`name`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openlayers_styles`
--

LOCK TABLES `openlayers_styles` WRITE;
/*!40000 ALTER TABLE `openlayers_styles` DISABLE KEYS */;
/*!40000 ALTER TABLE `openlayers_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_manager_handlers`
--

DROP TABLE IF EXISTS `page_manager_handlers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_manager_handlers` (
  `did` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `task` varchar(64) DEFAULT NULL,
  `subtask` varchar(64) NOT NULL DEFAULT '',
  `handler` varchar(64) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  `conf` longtext NOT NULL,
  PRIMARY KEY (`did`),
  UNIQUE KEY `name` (`name`),
  KEY `fulltask` (`task`,`subtask`,`weight`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_manager_handlers`
--

LOCK TABLES `page_manager_handlers` WRITE;
/*!40000 ALTER TABLE `page_manager_handlers` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_manager_handlers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_manager_pages`
--

DROP TABLE IF EXISTS `page_manager_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_manager_pages` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `task` varchar(64) DEFAULT 'page',
  `admin_title` varchar(255) DEFAULT NULL,
  `admin_description` longtext,
  `path` varchar(255) DEFAULT NULL,
  `access` longtext NOT NULL,
  `menu` longtext NOT NULL,
  `arguments` longtext NOT NULL,
  `conf` longtext NOT NULL,
  PRIMARY KEY (`pid`),
  UNIQUE KEY `name` (`name`),
  KEY `task` (`task`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_manager_pages`
--

LOCK TABLES `page_manager_pages` WRITE;
/*!40000 ALTER TABLE `page_manager_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_manager_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_manager_weights`
--

DROP TABLE IF EXISTS `page_manager_weights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_manager_weights` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `weight` int(11) DEFAULT NULL,
  PRIMARY KEY (`name`),
  KEY `weights` (`name`,`weight`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_manager_weights`
--

LOCK TABLES `page_manager_weights` WRITE;
/*!40000 ALTER TABLE `page_manager_weights` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_manager_weights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permission` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL DEFAULT '0',
  `perm` longtext,
  `tid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`pid`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `print_node_conf`
--

DROP TABLE IF EXISTS `print_node_conf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `print_node_conf` (
  `nid` int(10) unsigned NOT NULL,
  `link` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `comments` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `url_list` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_node_conf`
--

LOCK TABLES `print_node_conf` WRITE;
/*!40000 ALTER TABLE `print_node_conf` DISABLE KEYS */;
/*!40000 ALTER TABLE `print_node_conf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `print_page_counter`
--

DROP TABLE IF EXISTS `print_page_counter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `print_page_counter` (
  `path` varchar(128) NOT NULL,
  `totalcount` bigint(20) unsigned NOT NULL DEFAULT '0',
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`path`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_page_counter`
--

LOCK TABLES `print_page_counter` WRITE;
/*!40000 ALTER TABLE `print_page_counter` DISABLE KEYS */;
/*!40000 ALTER TABLE `print_page_counter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `print_pdf_node_conf`
--

DROP TABLE IF EXISTS `print_pdf_node_conf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `print_pdf_node_conf` (
  `nid` int(10) unsigned NOT NULL,
  `link` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `comments` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `url_list` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_pdf_node_conf`
--

LOCK TABLES `print_pdf_node_conf` WRITE;
/*!40000 ALTER TABLE `print_pdf_node_conf` DISABLE KEYS */;
/*!40000 ALTER TABLE `print_pdf_node_conf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `print_pdf_page_counter`
--

DROP TABLE IF EXISTS `print_pdf_page_counter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `print_pdf_page_counter` (
  `path` varchar(128) NOT NULL,
  `totalcount` bigint(20) unsigned NOT NULL DEFAULT '0',
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`path`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_pdf_page_counter`
--

LOCK TABLES `print_pdf_page_counter` WRITE;
/*!40000 ALTER TABLE `print_pdf_page_counter` DISABLE KEYS */;
/*!40000 ALTER TABLE `print_pdf_page_counter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `private`
--

DROP TABLE IF EXISTS `private`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `private` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `private` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `private`
--

LOCK TABLES `private` WRITE;
/*!40000 ALTER TABLE `private` DISABLE KEYS */;
/*!40000 ALTER TABLE `private` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profile_fields`
--

DROP TABLE IF EXISTS `profile_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profile_fields` (
  `fid` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `explanation` text,
  `category` varchar(255) DEFAULT NULL,
  `page` varchar(255) DEFAULT NULL,
  `type` varchar(128) DEFAULT NULL,
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  `required` tinyint(4) NOT NULL DEFAULT '0',
  `register` tinyint(4) NOT NULL DEFAULT '0',
  `visibility` tinyint(4) NOT NULL DEFAULT '0',
  `autocomplete` tinyint(4) NOT NULL DEFAULT '0',
  `options` text,
  PRIMARY KEY (`fid`),
  UNIQUE KEY `name` (`name`),
  KEY `category` (`category`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profile_fields`
--

LOCK TABLES `profile_fields` WRITE;
/*!40000 ALTER TABLE `profile_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `profile_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profile_values`
--

DROP TABLE IF EXISTS `profile_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profile_values` (
  `fid` int(10) unsigned NOT NULL DEFAULT '0',
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `value` text,
  PRIMARY KEY (`uid`,`fid`),
  KEY `fid` (`fid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profile_values`
--

LOCK TABLES `profile_values` WRITE;
/*!40000 ALTER TABLE `profile_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `profile_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `protected_nodes`
--

DROP TABLE IF EXISTS `protected_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protected_nodes` (
  `nid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `passwd` char(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`nid`),
  KEY `protected_passwd` (`passwd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `protected_nodes`
--

LOCK TABLES `protected_nodes` WRITE;
/*!40000 ALTER TABLE `protected_nodes` DISABLE KEYS */;
/*!40000 ALTER TABLE `protected_nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `rid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`rid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rsessions`
--

DROP TABLE IF EXISTS `rsessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rsessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rsessions_on_session_id` (`session_id`),
  KEY `index_rsessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rsessions`
--

LOCK TABLES `rsessions` WRITE;
/*!40000 ALTER TABLE `rsessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `rsessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rules_rules`
--

DROP TABLE IF EXISTS `rules_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rules_rules` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules_rules`
--

LOCK TABLES `rules_rules` WRITE;
/*!40000 ALTER TABLE `rules_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `rules_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rules_scheduler`
--

DROP TABLE IF EXISTS `rules_scheduler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rules_scheduler` (
  `tid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `set_name` varchar(255) NOT NULL DEFAULT '',
  `date` datetime NOT NULL,
  `arguments` text,
  `identifier` varchar(255) DEFAULT '',
  PRIMARY KEY (`tid`),
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules_scheduler`
--

LOCK TABLES `rules_scheduler` WRITE;
/*!40000 ALTER TABLE `rules_scheduler` DISABLE KEYS */;
/*!40000 ALTER TABLE `rules_scheduler` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rules_sets`
--

DROP TABLE IF EXISTS `rules_sets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rules_sets` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `data` longblob,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules_sets`
--

LOCK TABLES `rules_sets` WRITE;
/*!40000 ALTER TABLE `rules_sets` DISABLE KEYS */;
/*!40000 ALTER TABLE `rules_sets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rusers`
--

DROP TABLE IF EXISTS `rusers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rusers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `openid_identifier` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT 'basic',
  `reset_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rusers`
--

LOCK TABLES `rusers` WRITE;
/*!40000 ALTER TABLE `rusers` DISABLE KEYS */;
/*!40000 ALTER TABLE `rusers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_autocomplete_forms`
--

DROP TABLE IF EXISTS `search_autocomplete_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_autocomplete_forms` (
  `fid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `selector` varchar(255) NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  `enabled` int(11) NOT NULL DEFAULT '0',
  `parent_fid` int(11) NOT NULL DEFAULT '0',
  `min_char` int(11) NOT NULL DEFAULT '3',
  `max_sug` int(11) NOT NULL DEFAULT '15',
  PRIMARY KEY (`fid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_autocomplete_forms`
--

LOCK TABLES `search_autocomplete_forms` WRITE;
/*!40000 ALTER TABLE `search_autocomplete_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_autocomplete_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_autocomplete_suggestions`
--

DROP TABLE IF EXISTS `search_autocomplete_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_autocomplete_suggestions` (
  `sid` int(11) NOT NULL DEFAULT '0',
  `sug_fid` int(11) NOT NULL DEFAULT '0',
  `sug_enabled` int(11) NOT NULL DEFAULT '0',
  `sug_prefix` varchar(15) NOT NULL DEFAULT '',
  `sug_title` varchar(255) NOT NULL DEFAULT '',
  `sug_name` varchar(255) NOT NULL DEFAULT '',
  `sug_dependencies` varchar(255) NOT NULL DEFAULT '',
  `sug_weight` int(11) NOT NULL DEFAULT '0',
  `sug_query` varchar(512) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_autocomplete_suggestions`
--

LOCK TABLES `search_autocomplete_suggestions` WRITE;
/*!40000 ALTER TABLE `search_autocomplete_suggestions` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_autocomplete_suggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_dataset`
--

DROP TABLE IF EXISTS `search_dataset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_dataset` (
  `sid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` varchar(16) DEFAULT NULL,
  `data` longtext NOT NULL,
  `reindex` int(10) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `sid_type` (`sid`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_dataset`
--

LOCK TABLES `search_dataset` WRITE;
/*!40000 ALTER TABLE `search_dataset` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_dataset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_index`
--

DROP TABLE IF EXISTS `search_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_index` (
  `word` varchar(50) NOT NULL DEFAULT '',
  `sid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` varchar(16) DEFAULT NULL,
  `score` float DEFAULT NULL,
  UNIQUE KEY `word_sid_type` (`word`,`sid`,`type`),
  KEY `sid_type` (`sid`,`type`),
  KEY `word` (`word`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_index`
--

LOCK TABLES `search_index` WRITE;
/*!40000 ALTER TABLE `search_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_node_links`
--

DROP TABLE IF EXISTS `search_node_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_node_links` (
  `sid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` varchar(16) NOT NULL DEFAULT '',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `caption` longtext,
  PRIMARY KEY (`sid`,`type`,`nid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_node_links`
--

LOCK TABLES `search_node_links` WRITE;
/*!40000 ALTER TABLE `search_node_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_node_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_total`
--

DROP TABLE IF EXISTS `search_total`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_total` (
  `word` varchar(50) NOT NULL DEFAULT '',
  `count` float DEFAULT NULL,
  PRIMARY KEY (`word`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_total`
--

LOCK TABLES `search_total` WRITE;
/*!40000 ALTER TABLE `search_total` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_total` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semaphore`
--

DROP TABLE IF EXISTS `semaphore`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `semaphore` (
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  `expire` double NOT NULL,
  PRIMARY KEY (`name`),
  KEY `expire` (`expire`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semaphore`
--

LOCK TABLES `semaphore` WRITE;
/*!40000 ALTER TABLE `semaphore` DISABLE KEYS */;
/*!40000 ALTER TABLE `semaphore` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `uid` int(10) unsigned NOT NULL,
  `sid` varchar(64) NOT NULL DEFAULT '',
  `hostname` varchar(128) NOT NULL DEFAULT '',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `cache` int(11) NOT NULL DEFAULT '0',
  `session` longtext,
  PRIMARY KEY (`sid`),
  KEY `timestamp` (`timestamp`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `simpleviews`
--

DROP TABLE IF EXISTS `simpleviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `simpleviews` (
  `svid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module` varchar(255) NOT NULL DEFAULT 'simpleviews',
  `path` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `header` varchar(255) NOT NULL DEFAULT '',
  `filter` varchar(128) NOT NULL DEFAULT 'all-posts',
  `style` varchar(128) NOT NULL DEFAULT '',
  `sort` varchar(128) NOT NULL DEFAULT 'newest',
  `argument` varchar(128) DEFAULT '',
  `rss` int(11) NOT NULL DEFAULT '0',
  `block` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`svid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `simpleviews`
--

LOCK TABLES `simpleviews` WRITE;
/*!40000 ALTER TABLE `simpleviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `simpleviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spamicide`
--

DROP TABLE IF EXISTS `spamicide`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spamicide` (
  `form_id` varchar(128) NOT NULL,
  `form_field` varchar(64) NOT NULL DEFAULT 'feed_me',
  `enabled` tinyint(4) NOT NULL DEFAULT '0',
  `removable` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`form_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spamicide`
--

LOCK TABLES `spamicide` WRITE;
/*!40000 ALTER TABLE `spamicide` DISABLE KEYS */;
/*!40000 ALTER TABLE `spamicide` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stylizer`
--

DROP TABLE IF EXISTS `stylizer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stylizer` (
  `sid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `admin_title` varchar(255) DEFAULT NULL,
  `admin_description` longtext,
  `settings` longtext,
  PRIMARY KEY (`sid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stylizer`
--

LOCK TABLES `stylizer` WRITE;
/*!40000 ALTER TABLE `stylizer` DISABLE KEYS */;
/*!40000 ALTER TABLE `stylizer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system`
--

DROP TABLE IF EXISTS `system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system` (
  `filename` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(255) NOT NULL DEFAULT '',
  `owner` varchar(255) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `throttle` tinyint(4) NOT NULL DEFAULT '0',
  `bootstrap` int(11) NOT NULL DEFAULT '0',
  `schema_version` smallint(6) NOT NULL DEFAULT '-1',
  `weight` int(11) NOT NULL DEFAULT '0',
  `info` text,
  PRIMARY KEY (`filename`),
  KEY `modules` (`type`(12),`status`,`weight`,`filename`),
  KEY `bootstrap` (`type`(12),`status`,`bootstrap`,`weight`,`filename`),
  KEY `type_name` (`type`(12),`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system`
--

LOCK TABLES `system` WRITE;
/*!40000 ALTER TABLE `system` DISABLE KEYS */;
/*!40000 ALTER TABLE `system` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tableofcontents_node_toc`
--

DROP TABLE IF EXISTS `tableofcontents_node_toc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tableofcontents_node_toc` (
  `nid` int(11) NOT NULL,
  `toc_automatic` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tableofcontents_node_toc`
--

LOCK TABLES `tableofcontents_node_toc` WRITE;
/*!40000 ALTER TABLE `tableofcontents_node_toc` DISABLE KEYS */;
/*!40000 ALTER TABLE `tableofcontents_node_toc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag_selections`
--

DROP TABLE IF EXISTS `tag_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_selections` (
  `user_id` int(11) DEFAULT NULL,
  `tid` int(11) DEFAULT NULL,
  `following` tinyint(1) DEFAULT '0',
  UNIQUE KEY `index_tag_selections_on_user_id_and_tid` (`user_id`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag_selections`
--

LOCK TABLES `tag_selections` WRITE;
/*!40000 ALTER TABLE `tag_selections` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag_selections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `body` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxonomy_manager_merge`
--

DROP TABLE IF EXISTS `taxonomy_manager_merge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxonomy_manager_merge` (
  `main_tid` int(10) unsigned NOT NULL DEFAULT '0',
  `merged_tid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`merged_tid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxonomy_manager_merge`
--

LOCK TABLES `taxonomy_manager_merge` WRITE;
/*!40000 ALTER TABLE `taxonomy_manager_merge` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxonomy_manager_merge` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_data`
--

DROP TABLE IF EXISTS `term_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `term_data` (
  `tid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` longtext,
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`tid`),
  KEY `taxonomy_tree` (`vid`,`weight`,`name`),
  KEY `vid_name` (`vid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term_data`
--

LOCK TABLES `term_data` WRITE;
/*!40000 ALTER TABLE `term_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `term_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_hierarchy`
--

DROP TABLE IF EXISTS `term_hierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `term_hierarchy` (
  `tid` int(10) unsigned NOT NULL DEFAULT '0',
  `parent` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tid`,`parent`),
  KEY `parent` (`parent`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term_hierarchy`
--

LOCK TABLES `term_hierarchy` WRITE;
/*!40000 ALTER TABLE `term_hierarchy` DISABLE KEYS */;
/*!40000 ALTER TABLE `term_hierarchy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_node`
--

DROP TABLE IF EXISTS `term_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `term_node` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `tid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tid`,`vid`),
  KEY `vid` (`vid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term_node`
--

LOCK TABLES `term_node` WRITE;
/*!40000 ALTER TABLE `term_node` DISABLE KEYS */;
/*!40000 ALTER TABLE `term_node` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_relation`
--

DROP TABLE IF EXISTS `term_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `term_relation` (
  `trid` int(11) NOT NULL AUTO_INCREMENT,
  `tid1` int(10) unsigned NOT NULL DEFAULT '0',
  `tid2` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`trid`),
  UNIQUE KEY `tid1_tid2` (`tid1`,`tid2`),
  KEY `tid2` (`tid2`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term_relation`
--

LOCK TABLES `term_relation` WRITE;
/*!40000 ALTER TABLE `term_relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `term_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_synonym`
--

DROP TABLE IF EXISTS `term_synonym`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `term_synonym` (
  `tsid` int(11) NOT NULL AUTO_INCREMENT,
  `tid` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`tsid`),
  KEY `tid` (`tid`),
  KEY `name_tid` (`name`,`tid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term_synonym`
--

LOCK TABLES `term_synonym` WRITE;
/*!40000 ALTER TABLE `term_synonym` DISABLE KEYS */;
/*!40000 ALTER TABLE `term_synonym` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `to_do`
--

DROP TABLE IF EXISTS `to_do`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `to_do` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `item_status` int(10) unsigned DEFAULT '0',
  `priority` int(10) unsigned DEFAULT '0',
  `start_date` int(11) DEFAULT NULL,
  `deadline` int(11) DEFAULT NULL,
  `date_finished` int(11) DEFAULT NULL,
  `deadline_event` tinyint(4) DEFAULT '0',
  `auto_close` tinyint(4) DEFAULT '0',
  `mark_permissions` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `deadline` (`deadline`),
  KEY `auto_close` (`auto_close`,`deadline`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `to_do`
--

LOCK TABLES `to_do` WRITE;
/*!40000 ALTER TABLE `to_do` DISABLE KEYS */;
/*!40000 ALTER TABLE `to_do` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `to_do_assigned_users`
--

DROP TABLE IF EXISTS `to_do_assigned_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `to_do_assigned_users` (
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `uid` int(10) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`vid`,`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `to_do_assigned_users`
--

LOCK TABLES `to_do_assigned_users` WRITE;
/*!40000 ALTER TABLE `to_do_assigned_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `to_do_assigned_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `to_do_block_user_preferences`
--

DROP TABLE IF EXISTS `to_do_block_user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `to_do_block_user_preferences` (
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `sidebar_items` int(10) unsigned DEFAULT '5',
  `low_priority_items_display` tinyint(3) unsigned DEFAULT '1'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `to_do_block_user_preferences`
--

LOCK TABLES `to_do_block_user_preferences` WRITE;
/*!40000 ALTER TABLE `to_do_block_user_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `to_do_block_user_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `token_custom`
--

DROP TABLE IF EXISTS `token_custom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `token_custom` (
  `tkid` mediumint(9) NOT NULL AUTO_INCREMENT,
  `id` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `type` varchar(32) NOT NULL,
  `php` longtext NOT NULL,
  PRIMARY KEY (`tkid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token_custom`
--

LOCK TABLES `token_custom` WRITE;
/*!40000 ALTER TABLE `token_custom` DISABLE KEYS */;
/*!40000 ALTER TABLE `token_custom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trigger_assignments`
--

DROP TABLE IF EXISTS `trigger_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trigger_assignments` (
  `hook` varchar(32) NOT NULL DEFAULT '',
  `op` varchar(32) NOT NULL DEFAULT '',
  `aid` varchar(255) NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`hook`,`op`,`aid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trigger_assignments`
--

LOCK TABLES `trigger_assignments` WRITE;
/*!40000 ALTER TABLE `trigger_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `trigger_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upload`
--

DROP TABLE IF EXISTS `upload`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `upload` (
  `fid` int(10) unsigned NOT NULL DEFAULT '0',
  `nid` int(10) unsigned NOT NULL DEFAULT '0',
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `description` varchar(255) NOT NULL DEFAULT '',
  `list` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`,`fid`),
  KEY `fid` (`fid`),
  KEY `nid` (`nid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upload`
--

LOCK TABLES `upload` WRITE;
/*!40000 ALTER TABLE `upload` DISABLE KEYS */;
/*!40000 ALTER TABLE `upload` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `url_alias`
--

DROP TABLE IF EXISTS `url_alias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `url_alias` (
  `pid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `src` varchar(128) NOT NULL DEFAULT '',
  `dst` varchar(128) NOT NULL DEFAULT '',
  `language` varchar(12) NOT NULL DEFAULT '',
  PRIMARY KEY (`pid`),
  UNIQUE KEY `dst_language_pid` (`dst`,`language`,`pid`),
  KEY `src_language_pid` (`src`,`language`,`pid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `url_alias`
--

LOCK TABLES `url_alias` WRITE;
/*!40000 ALTER TABLE `url_alias` DISABLE KEYS */;
/*!40000 ALTER TABLE `url_alias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_selections`
--

DROP TABLE IF EXISTS `user_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_selections` (
  `self_id` int(11) DEFAULT NULL,
  `other_id` int(11) DEFAULT NULL,
  `following` tinyint(1) DEFAULT '0',
  UNIQUE KEY `index_user_selections_on_self_id_and_other_id` (`self_id`,`other_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_selections`
--

LOCK TABLES `user_selections` WRITE;
/*!40000 ALTER TABLE `user_selections` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_selections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL DEFAULT '',
  `pass` varchar(32) NOT NULL DEFAULT '',
  `mail` varchar(64) DEFAULT '',
  `mode` tinyint(4) NOT NULL DEFAULT '0',
  `sort` tinyint(4) DEFAULT '0',
  `threshold` tinyint(4) DEFAULT '0',
  `theme` varchar(255) NOT NULL DEFAULT '',
  `signature` varchar(255) NOT NULL DEFAULT '',
  `signature_format` smallint(6) NOT NULL DEFAULT '0',
  `created` int(11) NOT NULL DEFAULT '0',
  `access` int(11) NOT NULL DEFAULT '0',
  `login` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `timezone` varchar(8) DEFAULT NULL,
  `language` varchar(12) NOT NULL DEFAULT '',
  `picture` varchar(255) NOT NULL DEFAULT '',
  `init` varchar(64) DEFAULT '',
  `data` longtext,
  `timezone_id` int(11) NOT NULL DEFAULT '0',
  `timezone_name` varchar(50) NOT NULL DEFAULT '',
  `lat` decimal(20,10) DEFAULT '0.0000000000',
  `lon` decimal(20,10) DEFAULT '0.0000000000',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `name` (`name`),
  KEY `access` (`access`),
  KEY `created` (`created`),
  KEY `mail` (`mail`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_roles`
--

DROP TABLE IF EXISTS `users_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_roles` (
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `rid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`,`rid`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_roles`
--

LOCK TABLES `users_roles` WRITE;
/*!40000 ALTER TABLE `users_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `variable`
--

DROP TABLE IF EXISTS `variable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `variable` (
  `name` varchar(128) NOT NULL DEFAULT '',
  `value` longtext NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variable`
--

LOCK TABLES `variable` WRITE;
/*!40000 ALTER TABLE `variable` DISABLE KEYS */;
/*!40000 ALTER TABLE `variable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `view_node_like_count`
--

DROP TABLE IF EXISTS `view_node_like_count`;
/*!50001 DROP VIEW IF EXISTS `view_node_like_count`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_node_like_count` (
  `nid` tinyint NOT NULL,
  `num_likes` tinyint NOT NULL,
  `cached_likes` tinyint NOT NULL,
  `title` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `views_display`
--

DROP TABLE IF EXISTS `views_display`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `views_display` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `id` varchar(64) NOT NULL DEFAULT '',
  `display_title` varchar(64) NOT NULL DEFAULT '',
  `display_plugin` varchar(64) NOT NULL DEFAULT '',
  `position` int(11) DEFAULT '0',
  `display_options` longtext,
  PRIMARY KEY (`vid`,`id`),
  KEY `vid` (`vid`,`position`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `views_display`
--

LOCK TABLES `views_display` WRITE;
/*!40000 ALTER TABLE `views_display` DISABLE KEYS */;
/*!40000 ALTER TABLE `views_display` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `views_object_cache`
--

DROP TABLE IF EXISTS `views_object_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `views_object_cache` (
  `sid` varchar(64) DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `obj` varchar(32) DEFAULT NULL,
  `updated` int(10) unsigned NOT NULL DEFAULT '0',
  `data` longtext,
  KEY `sid_obj_name` (`sid`,`obj`,`name`),
  KEY `updated` (`updated`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `views_object_cache`
--

LOCK TABLES `views_object_cache` WRITE;
/*!40000 ALTER TABLE `views_object_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `views_object_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `views_view`
--

DROP TABLE IF EXISTS `views_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `views_view` (
  `vid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT '',
  `tag` varchar(255) DEFAULT '',
  `view_php` blob,
  `base_table` varchar(64) NOT NULL DEFAULT '',
  `is_cacheable` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`vid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `views_view`
--

LOCK TABLES `views_view` WRITE;
/*!40000 ALTER TABLE `views_view` DISABLE KEYS */;
/*!40000 ALTER TABLE `views_view` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vocabulary`
--

DROP TABLE IF EXISTS `vocabulary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vocabulary` (
  `vid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` longtext,
  `help` varchar(255) NOT NULL DEFAULT '',
  `relations` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `hierarchy` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `multiple` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `required` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `tags` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `module` varchar(255) NOT NULL DEFAULT '',
  `weight` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `list` (`weight`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vocabulary`
--

LOCK TABLES `vocabulary` WRITE;
/*!40000 ALTER TABLE `vocabulary` DISABLE KEYS */;
/*!40000 ALTER TABLE `vocabulary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vocabulary_node_types`
--

DROP TABLE IF EXISTS `vocabulary_node_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vocabulary_node_types` (
  `vid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`type`,`vid`),
  KEY `vid` (`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vocabulary_node_types`
--

LOCK TABLES `vocabulary_node_types` WRITE;
/*!40000 ALTER TABLE `vocabulary_node_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `vocabulary_node_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `watchdog`
--

DROP TABLE IF EXISTS `watchdog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `watchdog` (
  `wid` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL DEFAULT '0',
  `type` varchar(16) NOT NULL DEFAULT '',
  `message` longtext NOT NULL,
  `variables` longtext NOT NULL,
  `severity` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `link` varchar(255) NOT NULL DEFAULT '',
  `location` text NOT NULL,
  `referer` text,
  `hostname` varchar(128) NOT NULL DEFAULT '',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`wid`),
  KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `watchdog`
--

LOCK TABLES `watchdog` WRITE;
/*!40000 ALTER TABLE `watchdog` DISABLE KEYS */;
/*!40000 ALTER TABLE `watchdog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wysiwyg`
--

DROP TABLE IF EXISTS `wysiwyg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wysiwyg` (
  `format` int(11) NOT NULL DEFAULT '0',
  `editor` varchar(128) NOT NULL DEFAULT '',
  `settings` text,
  PRIMARY KEY (`format`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wysiwyg`
--

LOCK TABLES `wysiwyg` WRITE;
/*!40000 ALTER TABLE `wysiwyg` DISABLE KEYS */;
/*!40000 ALTER TABLE `wysiwyg` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `view_node_like_count`
--

/*!50001 DROP TABLE IF EXISTS `view_node_like_count`*/;
/*!50001 DROP VIEW IF EXISTS `view_node_like_count`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`publiclaboratory`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_node_like_count` AS select `node_selections`.`nid` AS `nid`,sum(`node_selections`.`liking`) AS `num_likes`,`node`.`cached_likes` AS `cached_likes`,`node`.`title` AS `title` from (`node_selections` join `node`) where (`node`.`nid` = `node_selections`.`nid`) group by `node_selections`.`nid` */;
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

-- Dump completed on 2014-03-06 11:49:18
