-- Adminer 4.7.0 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `matomo_access`;
CREATE TABLE `matomo_access` (
  `idaccess` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(100) NOT NULL,
  `idsite` int(10) unsigned NOT NULL,
  `access` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`idaccess`),
  KEY `index_loginidsite` (`login`,`idsite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_archive_invalidations`;
CREATE TABLE `matomo_archive_invalidations` (
  `idinvalidation` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `idarchive` int(10) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `idsite` int(10) unsigned NOT NULL,
  `date1` date NOT NULL,
  `date2` date NOT NULL,
  `period` tinyint(3) unsigned NOT NULL,
  `ts_invalidated` datetime DEFAULT NULL,
  `ts_started` datetime DEFAULT NULL,
  `status` tinyint(1) unsigned DEFAULT '0',
  `report` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idinvalidation`),
  KEY `index_idsite_dates_period_name` (`idsite`,`date1`,`period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_archive_numeric_2021_04`;
CREATE TABLE `matomo_archive_numeric_2021_04` (
  `idarchive` int(10) unsigned NOT NULL,
  `name` varchar(190) NOT NULL,
  `idsite` int(10) unsigned DEFAULT NULL,
  `date1` date DEFAULT NULL,
  `date2` date DEFAULT NULL,
  `period` tinyint(3) unsigned DEFAULT NULL,
  `ts_archived` datetime DEFAULT NULL,
  `value` double DEFAULT NULL,
  PRIMARY KEY (`idarchive`,`name`),
  KEY `index_idsite_dates_period` (`idsite`,`date1`,`date2`,`period`,`ts_archived`),
  KEY `index_period_archived` (`period`,`ts_archived`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_brute_force_log`;
CREATE TABLE `matomo_brute_force_log` (
  `id_brute_force_log` bigint(11) NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(60) DEFAULT NULL,
  `attempted_at` datetime NOT NULL,
  PRIMARY KEY (`id_brute_force_log`),
  KEY `index_ip_address` (`ip_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_brute_force_log` (`id_brute_force_log`, `ip_address`, `attempted_at`) VALUES
(1,	'::1',	'2021-04-26 06:28:00'),
(2,	'::1',	'2021-04-27 06:35:30');

DROP TABLE IF EXISTS `matomo_custom_dimensions`;
CREATE TABLE `matomo_custom_dimensions` (
  `idcustomdimension` bigint(20) unsigned NOT NULL,
  `idsite` bigint(20) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `index` smallint(5) unsigned NOT NULL,
  `scope` varchar(10) NOT NULL,
  `active` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `extractions` text NOT NULL,
  `case_sensitive` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`idcustomdimension`,`idsite`),
  UNIQUE KEY `uniq_hash` (`idsite`,`scope`,`index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_goal`;
CREATE TABLE `matomo_goal` (
  `idsite` int(11) NOT NULL,
  `idgoal` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `match_attribute` varchar(20) NOT NULL,
  `pattern` varchar(255) NOT NULL,
  `pattern_type` varchar(25) NOT NULL,
  `case_sensitive` tinyint(4) NOT NULL,
  `allow_multiple` tinyint(4) NOT NULL,
  `revenue` double NOT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `event_value_as_revenue` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`idsite`,`idgoal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_locks`;
CREATE TABLE `matomo_locks` (
  `key` varchar(70) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `expiry_time` bigint(20) unsigned DEFAULT '9999999999',
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_logger_message`;
CREATE TABLE `matomo_logger_message` (
  `idlogger_message` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tag` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  `level` varchar(16) DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`idlogger_message`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_log_action`;
CREATE TABLE `matomo_log_action` (
  `idaction` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(4096) DEFAULT NULL,
  `hash` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned DEFAULT NULL,
  `url_prefix` tinyint(2) DEFAULT NULL,
  PRIMARY KEY (`idaction`),
  KEY `index_type_hash` (`type`,`hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_log_conversion`;
CREATE TABLE `matomo_log_conversion` (
  `idvisit` bigint(10) unsigned NOT NULL,
  `idsite` int(10) unsigned NOT NULL,
  `idvisitor` binary(8) NOT NULL,
  `server_time` datetime NOT NULL,
  `idaction_url` int(10) unsigned DEFAULT NULL,
  `idlink_va` bigint(10) unsigned DEFAULT NULL,
  `idgoal` int(10) NOT NULL,
  `buster` int(10) unsigned NOT NULL,
  `idorder` varchar(100) DEFAULT NULL,
  `items` smallint(5) unsigned DEFAULT NULL,
  `url` varchar(4096) NOT NULL,
  `revenue` float DEFAULT NULL,
  `revenue_shipping` double DEFAULT NULL,
  `revenue_subtotal` double DEFAULT NULL,
  `revenue_tax` double DEFAULT NULL,
  `revenue_discount` double DEFAULT NULL,
  `visitor_returning` tinyint(1) DEFAULT NULL,
  `visitor_seconds_since_first` int(11) unsigned DEFAULT NULL,
  `visitor_seconds_since_order` int(11) unsigned DEFAULT NULL,
  `visitor_count_visits` int(11) unsigned NOT NULL DEFAULT '0',
  `referer_keyword` varchar(255) DEFAULT NULL,
  `referer_name` varchar(255) DEFAULT NULL,
  `referer_type` tinyint(1) unsigned DEFAULT NULL,
  `config_browser_name` varchar(40) DEFAULT NULL,
  `config_client_type` tinyint(1) DEFAULT NULL,
  `config_device_brand` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `config_device_model` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `config_device_type` tinyint(100) DEFAULT NULL,
  `location_city` varchar(255) DEFAULT NULL,
  `location_country` char(3) DEFAULT NULL,
  `location_latitude` decimal(9,6) DEFAULT NULL,
  `location_longitude` decimal(9,6) DEFAULT NULL,
  `location_region` char(3) DEFAULT NULL,
  `custom_dimension_1` varchar(255) DEFAULT NULL,
  `custom_dimension_2` varchar(255) DEFAULT NULL,
  `custom_dimension_3` varchar(255) DEFAULT NULL,
  `custom_dimension_4` varchar(255) DEFAULT NULL,
  `custom_dimension_5` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idvisit`,`idgoal`,`buster`),
  UNIQUE KEY `unique_idsite_idorder` (`idsite`,`idorder`),
  KEY `index_idsite_datetime` (`idsite`,`server_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_log_conversion_item`;
CREATE TABLE `matomo_log_conversion_item` (
  `idsite` int(10) unsigned NOT NULL,
  `idvisitor` binary(8) NOT NULL,
  `server_time` datetime NOT NULL,
  `idvisit` bigint(10) unsigned NOT NULL,
  `idorder` varchar(100) NOT NULL,
  `idaction_sku` int(10) unsigned NOT NULL,
  `idaction_name` int(10) unsigned NOT NULL,
  `idaction_category` int(10) unsigned NOT NULL,
  `idaction_category2` int(10) unsigned NOT NULL,
  `idaction_category3` int(10) unsigned NOT NULL,
  `idaction_category4` int(10) unsigned NOT NULL,
  `idaction_category5` int(10) unsigned NOT NULL,
  `price` double NOT NULL,
  `quantity` int(10) unsigned NOT NULL,
  `deleted` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`idvisit`,`idorder`,`idaction_sku`),
  KEY `index_idsite_servertime` (`idsite`,`server_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_log_link_visit_action`;
CREATE TABLE `matomo_log_link_visit_action` (
  `idlink_va` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `idsite` int(10) unsigned NOT NULL,
  `idvisitor` binary(8) NOT NULL,
  `idvisit` bigint(10) unsigned NOT NULL,
  `idaction_url_ref` int(10) unsigned DEFAULT '0',
  `idaction_name_ref` int(10) unsigned DEFAULT NULL,
  `custom_float` double DEFAULT NULL,
  `pageview_position` mediumint(8) unsigned DEFAULT NULL,
  `server_time` datetime NOT NULL,
  `idpageview` char(6) DEFAULT NULL,
  `idaction_name` int(10) unsigned DEFAULT NULL,
  `idaction_url` int(10) unsigned DEFAULT NULL,
  `search_cat` varchar(200) DEFAULT NULL,
  `search_count` int(10) unsigned DEFAULT NULL,
  `time_spent_ref_action` int(10) unsigned DEFAULT NULL,
  `idaction_product_cat` int(10) unsigned DEFAULT NULL,
  `idaction_product_cat2` int(10) unsigned DEFAULT NULL,
  `idaction_product_cat3` int(10) unsigned DEFAULT NULL,
  `idaction_product_cat4` int(10) unsigned DEFAULT NULL,
  `idaction_product_cat5` int(10) unsigned DEFAULT NULL,
  `idaction_product_name` int(10) unsigned DEFAULT NULL,
  `product_price` double DEFAULT NULL,
  `idaction_product_sku` int(10) unsigned DEFAULT NULL,
  `idaction_event_action` int(10) unsigned DEFAULT NULL,
  `idaction_event_category` int(10) unsigned DEFAULT NULL,
  `idaction_content_interaction` int(10) unsigned DEFAULT NULL,
  `idaction_content_name` int(10) unsigned DEFAULT NULL,
  `idaction_content_piece` int(10) unsigned DEFAULT NULL,
  `idaction_content_target` int(10) unsigned DEFAULT NULL,
  `time_dom_completion` mediumint(10) unsigned DEFAULT NULL,
  `time_dom_processing` mediumint(10) unsigned DEFAULT NULL,
  `time_network` mediumint(10) unsigned DEFAULT NULL,
  `time_on_load` mediumint(10) unsigned DEFAULT NULL,
  `time_server` mediumint(10) unsigned DEFAULT NULL,
  `time_transfer` mediumint(10) unsigned DEFAULT NULL,
  `time_spent` int(10) unsigned DEFAULT NULL,
  `custom_dimension_1` varchar(255) DEFAULT NULL,
  `custom_dimension_2` varchar(255) DEFAULT NULL,
  `custom_dimension_3` varchar(255) DEFAULT NULL,
  `custom_dimension_4` varchar(255) DEFAULT NULL,
  `custom_dimension_5` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idlink_va`),
  KEY `index_idvisit` (`idvisit`),
  KEY `index_idsite_servertime` (`idsite`,`server_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_log_profiling`;
CREATE TABLE `matomo_log_profiling` (
  `query` text NOT NULL,
  `count` int(10) unsigned DEFAULT NULL,
  `sum_time_ms` float DEFAULT NULL,
  `idprofiling` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`idprofiling`),
  UNIQUE KEY `query` (`query`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_log_visit`;
CREATE TABLE `matomo_log_visit` (
  `idvisit` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `idsite` int(10) unsigned NOT NULL,
  `idvisitor` binary(8) NOT NULL,
  `visit_last_action_time` datetime NOT NULL,
  `config_id` binary(8) NOT NULL,
  `location_ip` varbinary(16) NOT NULL,
  `profilable` tinyint(1) DEFAULT NULL,
  `user_id` varchar(200) DEFAULT NULL,
  `visit_first_action_time` datetime NOT NULL,
  `visit_goal_buyer` tinyint(1) DEFAULT NULL,
  `visit_goal_converted` tinyint(1) DEFAULT NULL,
  `visitor_returning` tinyint(1) DEFAULT NULL,
  `visitor_seconds_since_first` int(11) unsigned DEFAULT NULL,
  `visitor_seconds_since_order` int(11) unsigned DEFAULT NULL,
  `visitor_count_visits` int(11) unsigned NOT NULL DEFAULT '0',
  `visit_entry_idaction_name` int(10) unsigned DEFAULT NULL,
  `visit_entry_idaction_url` int(11) unsigned DEFAULT NULL,
  `visit_exit_idaction_name` int(10) unsigned DEFAULT NULL,
  `visit_exit_idaction_url` int(10) unsigned DEFAULT '0',
  `visit_total_actions` int(11) unsigned DEFAULT NULL,
  `visit_total_interactions` mediumint(8) unsigned DEFAULT '0',
  `visit_total_searches` smallint(5) unsigned DEFAULT NULL,
  `referer_keyword` varchar(255) DEFAULT NULL,
  `referer_name` varchar(255) DEFAULT NULL,
  `referer_type` tinyint(1) unsigned DEFAULT NULL,
  `referer_url` varchar(1500) DEFAULT NULL,
  `location_browser_lang` varchar(20) DEFAULT NULL,
  `config_browser_engine` varchar(10) DEFAULT NULL,
  `config_browser_name` varchar(40) DEFAULT NULL,
  `config_browser_version` varchar(20) DEFAULT NULL,
  `config_client_type` tinyint(1) DEFAULT NULL,
  `config_device_brand` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `config_device_model` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `config_device_type` tinyint(100) DEFAULT NULL,
  `config_os` char(3) DEFAULT NULL,
  `config_os_version` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `visit_total_events` int(11) unsigned DEFAULT NULL,
  `visitor_localtime` time DEFAULT NULL,
  `visitor_seconds_since_last` int(11) unsigned DEFAULT NULL,
  `config_resolution` varchar(18) DEFAULT NULL,
  `config_cookie` tinyint(1) DEFAULT NULL,
  `config_flash` tinyint(1) DEFAULT NULL,
  `config_java` tinyint(1) DEFAULT NULL,
  `config_pdf` tinyint(1) DEFAULT NULL,
  `config_quicktime` tinyint(1) DEFAULT NULL,
  `config_realplayer` tinyint(1) DEFAULT NULL,
  `config_silverlight` tinyint(1) DEFAULT NULL,
  `config_windowsmedia` tinyint(1) DEFAULT NULL,
  `visit_total_time` int(11) unsigned NOT NULL,
  `location_city` varchar(255) DEFAULT NULL,
  `location_country` char(3) DEFAULT NULL,
  `location_latitude` decimal(9,6) DEFAULT NULL,
  `location_longitude` decimal(9,6) DEFAULT NULL,
  `location_region` char(3) DEFAULT NULL,
  `last_idlink_va` bigint(20) unsigned DEFAULT NULL,
  `custom_dimension_1` varchar(255) DEFAULT NULL,
  `custom_dimension_2` varchar(255) DEFAULT NULL,
  `custom_dimension_3` varchar(255) DEFAULT NULL,
  `custom_dimension_4` varchar(255) DEFAULT NULL,
  `custom_dimension_5` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idvisit`),
  KEY `index_idsite_config_datetime` (`idsite`,`config_id`,`visit_last_action_time`),
  KEY `index_idsite_datetime` (`idsite`,`visit_last_action_time`),
  KEY `index_idsite_idvisitor` (`idsite`,`idvisitor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_option`;
CREATE TABLE `matomo_option` (
  `option_name` varchar(191) NOT NULL,
  `option_value` longtext NOT NULL,
  `autoload` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`option_name`),
  KEY `autoload` (`autoload`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_option` (`option_name`, `option_value`, `autoload`) VALUES
('fingerprint_salt_1_2021-04-24',	'{\"value\":\"tni02m34wh86vy0cask1rbo4t91fzupn\",\"time\":1619418438}',	0),
('fingerprint_salt_1_2021-04-25',	'{\"value\":\"9ac1gd8a7mcxf304wnt9othyo088byhf\",\"time\":1619418438}',	0),
('fingerprint_salt_1_2021-04-26',	'{\"value\":\"489cul3p0bu79stt33ghvidppx8tt52s\",\"time\":1619418438}',	0),
('fingerprint_salt_1_2021-04-27',	'{\"value\":\"tt2dymly6i99lyzk7vxt5czx6zl83lcj\",\"time\":1619418438}',	0),
('geoip2.loc_db_url',	'https://download.db-ip.com/free/dbip-city-lite-2021-04.mmdb.gz',	0),
('geoip2.updater_last_run_time',	'1619395200',	0),
('geoip2.updater_period',	'month',	0),
('install_mail_sent',	'1',	0),
('install_version',	'4.2.1',	0),
('LastPluginActivation.MyPlugin',	'1619601061',	0),
('MatomoUpdateHistory',	'4.2.1,',	0),
('MobileMessaging_DelegatedManagement',	'false',	0),
('PrivacyManager.doNotTrackEnabled',	'1',	0),
('PrivacyManager.ipAnonymizerEnabled',	'1',	0),
('SitesManager_DefaultCurrency',	'DZD',	0),
('SitesManager_DefaultTimezone',	'Africa/Algiers',	0),
('TaskScheduler.timetable',	'a:1:{s:45:\"Piwik\\Plugins\\GeoIp2\\GeoIP2AutoUpdater.update\";i:1620172809;}',	0),
('TransactionLevel.testOption',	'1',	0),
('UpdateCheck_LastTimeChecked',	'1619600686',	1),
('UpdateCheck_LatestVersion',	'4.2.1',	0),
('usercountry.location_provider',	'geoip2php',	0),
('usercountry.switchtoisoregions',	'1619418489',	0),
('useridsalt',	'91CpDcwtz4THSPBndE0VWf6tSNcDBNJBIIHx3oaG',	1),
('UsersManager.lastSeen.admin',	'1619600443',	1),
('UsersManager.lastSeen.super user was set',	'1619418452',	1),
('version_Actions',	'4.2.1',	1),
('version_Annotations',	'4.2.1',	1),
('version_API',	'4.2.1',	1),
('version_BulkTracking',	'4.2.1',	1),
('version_Contents',	'4.2.1',	1),
('version_core',	'4.2.1',	1),
('version_CoreAdminHome',	'4.2.1',	1),
('version_CoreConsole',	'4.2.1',	1),
('version_CoreHome',	'4.2.1',	1),
('version_CorePluginsAdmin',	'4.2.1',	1),
('version_CoreUpdater',	'4.2.1',	1),
('version_CoreVisualizations',	'4.2.1',	1),
('version_CustomDimensions',	'4.2.1',	1),
('version_CustomJsTracker',	'4.2.1',	1),
('version_customvariables',	'4.2.1',	1),
('version_Dashboard',	'4.2.1',	1),
('version_DevicePlugins',	'4.2.1',	1),
('version_DevicesDetection',	'4.2.1',	1),
('version_Diagnostics',	'4.2.1',	1),
('version_Ecommerce',	'4.2.1',	1),
('version_Events',	'4.2.1',	1),
('version_Feedback',	'4.2.1',	1),
('version_GeoIp2',	'4.2.1',	1),
('version_Goals',	'4.2.1',	1),
('version_Heartbeat',	'4.2.1',	1),
('version_ImageGraph',	'4.2.1',	1),
('version_Insights',	'4.2.1',	1),
('version_Installation',	'4.2.1',	1),
('version_Intl',	'4.2.1',	1),
('version_IntranetMeasurable',	'4.2.1',	1),
('version_LanguagesManager',	'4.2.1',	1),
('version_Live',	'4.2.1',	1),
('version_Login',	'4.2.1',	1),
('version_log_conversion.revenue',	'float default NULL',	1),
('version_log_link_visit_action.idaction_content_interaction',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idaction_content_name',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idaction_content_piece',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idaction_content_target',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idaction_event_action',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idaction_event_category',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idaction_name',	'INTEGER(10) UNSIGNED',	1),
('version_log_link_visit_action.idaction_product_cat',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_product_cat2',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_product_cat3',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_product_cat4',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_product_cat5',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_product_name',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_product_sku',	'INT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.idaction_url',	'INTEGER(10) UNSIGNED DEFAULT NULL',	1),
('version_log_link_visit_action.idpageview',	'CHAR(6) NULL DEFAULT NULL',	1),
('version_log_link_visit_action.product_price',	'DOUBLE NULL',	1),
('version_log_link_visit_action.search_cat',	'VARCHAR(200) NULL',	1),
('version_log_link_visit_action.search_count',	'INTEGER(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.server_time',	'DATETIME NOT NULL',	1),
('version_log_link_visit_action.time_dom_completion',	'MEDIUMINT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.time_dom_processing',	'MEDIUMINT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.time_network',	'MEDIUMINT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.time_on_load',	'MEDIUMINT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.time_server',	'MEDIUMINT(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.time_spent_ref_action',	'INTEGER(10) UNSIGNED NULL',	1),
('version_log_link_visit_action.time_transfer',	'MEDIUMINT(10) UNSIGNED NULL',	1),
('version_log_visit.config_browser_engine',	'VARCHAR(10) NULL',	1),
('version_log_visit.config_browser_name',	'VARCHAR(40) NULL1',	1),
('version_log_visit.config_browser_version',	'VARCHAR(20) NULL',	1),
('version_log_visit.config_client_type',	'TINYINT( 1 ) NULL DEFAULT NULL1',	1),
('version_log_visit.config_cookie',	'TINYINT(1) NULL',	1),
('version_log_visit.config_device_brand',	'VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL1',	1),
('version_log_visit.config_device_model',	'VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL1',	1),
('version_log_visit.config_device_type',	'TINYINT( 100 ) NULL DEFAULT NULL1',	1),
('version_log_visit.config_flash',	'TINYINT(1) NULL',	1),
('version_log_visit.config_java',	'TINYINT(1) NULL',	1),
('version_log_visit.config_os',	'CHAR(3) NULL',	1),
('version_log_visit.config_os_version',	'VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL',	1),
('version_log_visit.config_pdf',	'TINYINT(1) NULL',	1),
('version_log_visit.config_quicktime',	'TINYINT(1) NULL',	1),
('version_log_visit.config_realplayer',	'TINYINT(1) NULL',	1),
('version_log_visit.config_resolution',	'VARCHAR(18) NULL',	1),
('version_log_visit.config_silverlight',	'TINYINT(1) NULL',	1),
('version_log_visit.config_windowsmedia',	'TINYINT(1) NULL',	1),
('version_log_visit.location_browser_lang',	'VARCHAR(20) NULL',	1),
('version_log_visit.location_city',	'varchar(255) DEFAULT NULL1',	1),
('version_log_visit.location_country',	'CHAR(3) NULL1',	1),
('version_log_visit.location_latitude',	'decimal(9, 6) DEFAULT NULL1',	1),
('version_log_visit.location_longitude',	'decimal(9, 6) DEFAULT NULL1',	1),
('version_log_visit.location_region',	'char(3) DEFAULT NULL1',	1),
('version_log_visit.profilable',	'TINYINT(1) NULL',	1),
('version_log_visit.referer_keyword',	'VARCHAR(255) NULL1',	1),
('version_log_visit.referer_name',	'VARCHAR(255) NULL1',	1),
('version_log_visit.referer_type',	'TINYINT(1) UNSIGNED NULL1',	1),
('version_log_visit.referer_url',	'VARCHAR(1500) NULL',	1),
('version_log_visit.user_id',	'VARCHAR(200) NULL',	1),
('version_log_visit.visitor_count_visits',	'INT(11) UNSIGNED NOT NULL DEFAULT 01',	1),
('version_log_visit.visitor_localtime',	'TIME NULL',	1),
('version_log_visit.visitor_returning',	'TINYINT(1) NULL1',	1),
('version_log_visit.visitor_seconds_since_first',	'INT(11) UNSIGNED NULL1',	1),
('version_log_visit.visitor_seconds_since_last',	'INT(11) UNSIGNED NULL',	1),
('version_log_visit.visitor_seconds_since_order',	'INT(11) UNSIGNED NULL1',	1),
('version_log_visit.visit_entry_idaction_name',	'INTEGER(10) UNSIGNED NULL',	1),
('version_log_visit.visit_entry_idaction_url',	'INTEGER(11) UNSIGNED NULL  DEFAULT NULL',	1),
('version_log_visit.visit_exit_idaction_name',	'INTEGER(10) UNSIGNED NULL',	1),
('version_log_visit.visit_exit_idaction_url',	'INTEGER(10) UNSIGNED NULL DEFAULT 0',	1),
('version_log_visit.visit_first_action_time',	'DATETIME NOT NULL',	1),
('version_log_visit.visit_goal_buyer',	'TINYINT(1) NULL',	1),
('version_log_visit.visit_goal_converted',	'TINYINT(1) NULL',	1),
('version_log_visit.visit_total_actions',	'INT(11) UNSIGNED NULL',	1),
('version_log_visit.visit_total_events',	'INT(11) UNSIGNED NULL',	1),
('version_log_visit.visit_total_interactions',	'MEDIUMINT UNSIGNED DEFAULT 0',	1),
('version_log_visit.visit_total_searches',	'SMALLINT(5) UNSIGNED NULL',	1),
('version_log_visit.visit_total_time',	'INT(11) UNSIGNED NOT NULL',	1),
('version_Marketplace',	'4.2.1',	1),
('version_MobileMessaging',	'4.2.1',	1),
('version_Monolog',	'4.2.1',	1),
('version_Morpheus',	'4.2.1',	1),
('version_MultiSites',	'4.2.1',	1),
('version_MyPlugin',	'1.0',	1),
('version_Overlay',	'4.2.1',	1),
('version_PagePerformance',	'4.2.1',	1),
('version_PrivacyManager',	'4.2.1',	1),
('version_ProfessionalServices',	'4.2.1',	1),
('version_Proxy',	'4.2.1',	1),
('version_Referrers',	'4.2.1',	1),
('version_Resolution',	'4.2.1',	1),
('version_RssWidget',	'1.0',	1),
('version_ScheduledReports',	'4.2.1',	1),
('version_SegmentEditor',	'4.2.1',	1),
('version_SEO',	'4.2.1',	1),
('version_SitesManager',	'4.2.1',	1),
('version_TestRunner',	'0.1.0',	1),
('version_Tour',	'4.2.1',	1),
('version_Transitions',	'4.2.1',	1),
('version_TwoFactorAuth',	'4.2.1',	1),
('version_UserCountry',	'4.2.1',	1),
('version_UserCountryMap',	'4.2.1',	1),
('version_UserId',	'4.2.1',	1),
('version_UserLanguage',	'4.2.1',	1),
('version_UsersManager',	'4.2.1',	1),
('version_VisitFrequency',	'4.2.1',	1),
('version_VisitorInterest',	'4.2.1',	1),
('version_VisitsSummary',	'4.2.1',	1),
('version_VisitTime',	'4.2.1',	1),
('version_WebsiteMeasurable',	'4.2.1',	1),
('version_Widgetize',	'4.2.1',	1);

DROP TABLE IF EXISTS `matomo_plugin_setting`;
CREATE TABLE `matomo_plugin_setting` (
  `plugin_name` varchar(60) NOT NULL,
  `setting_name` varchar(255) NOT NULL,
  `setting_value` longtext NOT NULL,
  `json_encoded` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `user_login` varchar(100) NOT NULL DEFAULT '',
  `idplugin_setting` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`idplugin_setting`),
  KEY `plugin_name` (`plugin_name`,`user_login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_privacy_logdata_anonymizations`;
CREATE TABLE `matomo_privacy_logdata_anonymizations` (
  `idlogdata_anonymization` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `idsites` text,
  `date_start` datetime NOT NULL,
  `date_end` datetime NOT NULL,
  `anonymize_ip` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `anonymize_location` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `anonymize_userid` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `unset_visit_columns` text NOT NULL,
  `unset_link_visit_action_columns` text NOT NULL,
  `output` mediumtext,
  `scheduled_date` datetime DEFAULT NULL,
  `job_start_date` datetime DEFAULT NULL,
  `job_finish_date` datetime DEFAULT NULL,
  `requester` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`idlogdata_anonymization`),
  KEY `job_start_date` (`job_start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_report`;
CREATE TABLE `matomo_report` (
  `idreport` int(11) NOT NULL AUTO_INCREMENT,
  `idsite` int(11) NOT NULL,
  `login` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `idsegment` int(11) DEFAULT NULL,
  `period` varchar(10) NOT NULL,
  `hour` tinyint(4) NOT NULL DEFAULT '0',
  `type` varchar(10) NOT NULL,
  `format` varchar(10) NOT NULL,
  `reports` text NOT NULL,
  `parameters` text,
  `ts_created` timestamp NULL DEFAULT NULL,
  `ts_last_sent` timestamp NULL DEFAULT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `evolution_graph_within_period` tinyint(4) NOT NULL DEFAULT '0',
  `evolution_graph_period_n` int(11) NOT NULL,
  `period_param` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`idreport`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_report_subscriptions`;
CREATE TABLE `matomo_report_subscriptions` (
  `idreport` int(11) NOT NULL,
  `token` varchar(100) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `ts_subscribed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ts_unsubscribed` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`idreport`,`email`),
  UNIQUE KEY `unique_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_segment`;
CREATE TABLE `matomo_segment` (
  `idsegment` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `definition` text NOT NULL,
  `login` varchar(100) NOT NULL,
  `enable_all_users` tinyint(4) NOT NULL DEFAULT '0',
  `enable_only_idsite` int(11) DEFAULT NULL,
  `auto_archive` tinyint(4) NOT NULL DEFAULT '0',
  `ts_created` timestamp NULL DEFAULT NULL,
  `ts_last_edit` timestamp NULL DEFAULT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`idsegment`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_sequence`;
CREATE TABLE `matomo_sequence` (
  `name` varchar(120) NOT NULL,
  `value` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_sequence` (`name`, `value`) VALUES
('matomo_archive_numeric_2021_04',	0);

DROP TABLE IF EXISTS `matomo_session`;
CREATE TABLE `matomo_session` (
  `id` varchar(191) NOT NULL,
  `modified` int(11) DEFAULT NULL,
  `lifetime` int(11) DEFAULT NULL,
  `data` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_session` (`id`, `modified`, `lifetime`, `data`) VALUES
('0f71fcadcbb182ba765f78af6116fafe7b27c5e6ce09546df81429d23a5132f57ff8fcad49ec56d417d3ef4991f5fb23be15a3f947280b50cf724af257fea5fd',	1619600688,	1209600,	'a:1:{s:4:\"data\";s:2364:\"YToxNDp7czo0OiJfX1pGIjthOjk6e3M6MTE6IkxvZ2luLmxvZ2luIjthOjE6e3M6NDoiRU5WVCI7YToxOntzOjU6Im5vbmNlIjtpOjE2MTk2MDEwMzA7fX1zOjI0OiJNYXJrZXRwbGFjZS51cGRhdGVQbHVnaW4iO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTYwMTA2ODt9fXM6MzE6IkNvcmVQbHVnaW5zQWRtaW4uYWN0aXZhdGVQbHVnaW4iO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTYwMTA2ODt9fXM6MzI6IkNvcmVQbHVnaW5zQWRtaW4udW5pbnN0YWxsUGx1Z2luIjthOjE6e3M6NDoiRU5WVCI7YToxOntzOjU6Im5vbmNlIjtpOjE2MTk2MDEwNjg7fX1zOjMzOiJDb3JlUGx1Z2luc0FkbWluLmRlYWN0aXZhdGVQbHVnaW4iO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTYwMTA2ODt9fXM6MjU6Ik1hcmtldHBsYWNlLmluc3RhbGxQbHVnaW4iO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTYwMTA2OTt9fXM6Mjg6IlByaXZhY3lNYW5hZ2VyLmRlYWN0aXZhdGVEbnQiO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTYwMTExMzt9fXM6MjY6IlByaXZhY3lNYW5hZ2VyLmFjdGl2YXRlRG50IjthOjE6e3M6NDoiRU5WVCI7YToxOntzOjU6Im5vbmNlIjtpOjE2MTk2MDExMTM7fX1zOjEyOiJQaXdpa19PcHRPdXQiO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTYwNDE4NTt9fX1zOjk6InVzZXIubmFtZSI7czo1OiJhZG1pbiI7czoyMjoidHdvZmFjdG9yYXV0aC52ZXJpZmllZCI7aTowO3M6MjA6InVzZXIudG9rZW5fYXV0aF90ZW1wIjtzOjMyOiJkZWJmNDk4OThkZTExYzYzOTQxOTU2M2NmZWQzYjM5MCI7czoxMjoic2Vzc2lvbi5pbmZvIjthOjM6e3M6MjoidHMiO2k6MTYxOTYwMDQ0MjtzOjEwOiJyZW1lbWJlcmVkIjtiOjA7czoxMDoiZXhwaXJhdGlvbiI7aToxNjE5NjA0Mjg2O31zOjEyOiJub3RpZmljYXRpb24iO2E6MTp7czoxMzoibm90aWZpY2F0aW9ucyI7YTowOnt9fXM6MjQ6Ik1hcmtldHBsYWNlLnVwZGF0ZVBsdWdpbiI7YToxOntzOjU6Im5vbmNlIjtzOjMyOiJlZjYxMTdmMDE3ZmVmMzljMzUxNzhiZjBjOTI1ZjAzNSI7fXM6MzE6IkNvcmVQbHVnaW5zQWRtaW4uYWN0aXZhdGVQbHVnaW4iO2E6MTp7czo1OiJub25jZSI7czozMjoiZWE1OGE2ZjMwMTJjYTA5MzUzMzQxNGYwYzM3YjQ1OWQiO31zOjMyOiJDb3JlUGx1Z2luc0FkbWluLnVuaW5zdGFsbFBsdWdpbiI7YToxOntzOjU6Im5vbmNlIjtzOjMyOiIzMzYwOTgzNTJjM2I0NTMyZDc4ODczNDE0MTkyNTAxZCI7fXM6MzM6IkNvcmVQbHVnaW5zQWRtaW4uZGVhY3RpdmF0ZVBsdWdpbiI7YToxOntzOjU6Im5vbmNlIjtzOjMyOiI1MTdiM2QwMGIwNjY0Yzc0ZWQ1OTJlY2NmZmFhMGFhZiI7fXM6MjU6Ik1hcmtldHBsYWNlLmluc3RhbGxQbHVnaW4iO2E6MTp7czo1OiJub25jZSI7czozMjoiMTNjMTIwMjY1MGVkZWQ0MzZkMGQ3MjI1YjQxYWRiNzciO31zOjI4OiJQcml2YWN5TWFuYWdlci5kZWFjdGl2YXRlRG50IjthOjE6e3M6NToibm9uY2UiO3M6MzI6IjdlODZhZDM4NDA3ZThhZGI5ZWVmYzQ4ODEwMGNjNDk0Ijt9czoyNjoiUHJpdmFjeU1hbmFnZXIuYWN0aXZhdGVEbnQiO2E6MTp7czo1OiJub25jZSI7czozMjoiODVlZDM1YTE3MjVhNzc5N2E2MDZjNTM3NDkyODNlZDIiO31zOjEyOiJQaXdpa19PcHRPdXQiO2E6MTp7czo1OiJub25jZSI7czozMjoiOTgwNmQ5NjYyYTE1ZjEwZjZmZjIwNWE1Y2U5NDI0YjAiO319\";}'),
('317428a860325ed96a9a5afffd8a78ff493d7e36b11f51f2d3c8ad3c8e04dfd2b3e0187e0fde616dd028feebc6b247ea8f55e43a96ea9b0325a62b9bec707d91',	1619600462,	1209600,	'a:1:{s:4:\"data\";s:8:\"YTowOnt9\";}'),
('4cbd15b890d035c1fd9f56cea5079a724c012965bb9eeb8ead84f135e21624d4222982f0ce7b256876a02f80d5e23b7895ac36b7f1e595a9eefe413978079833',	1619505473,	1209600,	'a:1:{s:4:\"data\";s:1808:\"YToxMjp7czoxMjoibm90aWZpY2F0aW9uIjthOjE6e3M6MTM6Im5vdGlmaWNhdGlvbnMiO2E6MDp7fX1zOjI0OiJNYXJrZXRwbGFjZS51cGRhdGVQbHVnaW4iO2E6MDp7fXM6MzE6IkNvcmVQbHVnaW5zQWRtaW4uYWN0aXZhdGVQbHVnaW4iO2E6MDp7fXM6MzI6IkNvcmVQbHVnaW5zQWRtaW4udW5pbnN0YWxsUGx1Z2luIjthOjA6e31zOjMzOiJDb3JlUGx1Z2luc0FkbWluLmRlYWN0aXZhdGVQbHVnaW4iO2E6MDp7fXM6MjU6Ik1hcmtldHBsYWNlLmluc3RhbGxQbHVnaW4iO2E6MDp7fXM6NDoiX19aRiI7YTo3OntzOjExOiJMb2dpbi5sb2dpbiI7YToxOntzOjQ6IkVOVlQiO2E6MTp7czo1OiJub25jZSI7aToxNjE5NTA1OTUzO319czoxOToiY2hhbmdlUGFzc3dvcmROb25jZSI7YToxOntzOjQ6IkVOVlQiO2E6MTp7czo1OiJub25jZSI7aToxNjE5NTA1OTc2O319czoyMDoiZGVsZXRlQXV0aFRva2VuTm9uY2UiO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTUwNTk3Njt9fXM6Mjk6IlR3b0ZhY3RvckF1dGguZGlzYWJsZUF1dGhDb2RlIjthOjE6e3M6NDoiRU5WVCI7YToxOntzOjU6Im5vbmNlIjtpOjE2MTk1MDU5NzY7fX1zOjU6IkxvZ2luIjthOjE6e3M6NDoiRU5WVCI7YToyOntzOjE0OiJyZWRpcmVjdFBhcmFtcyI7aToxNjE5NTA3MTkxO3M6MTY6Imxhc3RQYXNzd29yZEF1dGgiO2k6MTYxOTUwNzE5MTt9fXM6MTU6ImNvbmZpcm1QYXNzd29yZCI7YToxOntzOjQ6IkVOVlQiO2E6MTp7czo1OiJub25jZSI7aToxNjE5NTA1OTgzO319czoxNzoiYWRkQXV0aFRva2VuTm9uY2UiO2E6MTp7czo0OiJFTlZUIjthOjE6e3M6NToibm9uY2UiO2k6MTYxOTUwNTk5MTt9fX1zOjE5OiJjaGFuZ2VQYXNzd29yZE5vbmNlIjthOjE6e3M6NToibm9uY2UiO3M6MzI6ImU2YjljM2MxMWRlODZhZWI0YTI1MGNiNWMxNTA0YTA4Ijt9czoyMDoiZGVsZXRlQXV0aFRva2VuTm9uY2UiO2E6MTp7czo1OiJub25jZSI7czozMjoiOGI1NDdhZTgzNDIzYjBjZmMwMDgxZjdkMjUxODM2MmQiO31zOjI5OiJUd29GYWN0b3JBdXRoLmRpc2FibGVBdXRoQ29kZSI7YToxOntzOjU6Im5vbmNlIjtzOjMyOiIxNTcxMmI1MTFiMjczZWJlNDBjNTk2ZTk1MjU4Nzk0ZCI7fXM6NToiTG9naW4iO2E6Mjp7czoxNDoicmVkaXJlY3RQYXJhbXMiO2E6Mjp7czo2OiJtb2R1bGUiO3M6MTI6IlVzZXJzTWFuYWdlciI7czo2OiJhY3Rpb24iO3M6MTE6ImFkZE5ld1Rva2VuIjt9czoxNjoibGFzdFBhc3N3b3JkQXV0aCI7czoxOToiMjAyMS0wNC0yNyAwNjozNjozMSI7fXM6MTU6ImNvbmZpcm1QYXNzd29yZCI7YToxOntzOjU6Im5vbmNlIjtzOjMyOiI5YzAzZTFlN2UwY2ExNTg4YzIwNjQxNTg0YjM2Y2Q5NiI7fX0=\";}'),
('6e0d103ee14e414c3262a31840d8b3395d6fd9d4f205b7b26612b3b936bd4480e2b2f38eaf42a69cc919fd88cc1f05f8a8c333dd410bbb18181196645e4b62d2',	1619505374,	1209600,	'a:1:{s:4:\"data\";s:8:\"YTowOnt9\";}'),
('82d082ba1d4430bd0845825abbca78deb4fec68294ed9b121e9a3cf7aa76da9b918dec71f785cdf72c9d9e0576720f6e498debcaf613532ceecab31a2b48ceea',	1619418531,	1209600,	'a:1:{s:4:\"data\";s:8:\"YTowOnt9\";}'),
('9606e6bc4814c277a3eb1933c1eea04925e8902e5054bb2e41080462371d58b33fd8ad9c1537994c3110872f4a0246774464ca8de32580dc4f7ce9e6bdce28c3',	1619418506,	1209600,	'a:1:{s:4:\"data\";s:8:\"YTowOnt9\";}');

DROP TABLE IF EXISTS `matomo_site`;
CREATE TABLE `matomo_site` (
  `idsite` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(90) NOT NULL,
  `main_url` varchar(255) NOT NULL,
  `ts_created` timestamp NULL DEFAULT NULL,
  `ecommerce` tinyint(4) DEFAULT '0',
  `sitesearch` tinyint(4) DEFAULT '1',
  `sitesearch_keyword_parameters` text NOT NULL,
  `sitesearch_category_parameters` text NOT NULL,
  `timezone` varchar(50) NOT NULL,
  `currency` char(3) NOT NULL,
  `exclude_unknown_urls` tinyint(1) DEFAULT '0',
  `excluded_ips` text NOT NULL,
  `excluded_parameters` text NOT NULL,
  `excluded_user_agents` text NOT NULL,
  `group` varchar(250) NOT NULL,
  `type` varchar(255) NOT NULL,
  `keep_url_fragment` tinyint(4) NOT NULL DEFAULT '0',
  `creator_login` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idsite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_site` (`idsite`, `name`, `main_url`, `ts_created`, `ecommerce`, `sitesearch`, `sitesearch_keyword_parameters`, `sitesearch_category_parameters`, `timezone`, `currency`, `exclude_unknown_urls`, `excluded_ips`, `excluded_parameters`, `excluded_user_agents`, `group`, `type`, `keep_url_fragment`, `creator_login`) VALUES
(1,	'Example',	'https://example.com',	'2021-04-26 00:57:18',	0,	1,	'',	'',	'Africa/Algiers',	'DZD',	0,	'',	'',	'',	'',	'website',	0,	'anonymous');

DROP TABLE IF EXISTS `matomo_site_setting`;
CREATE TABLE `matomo_site_setting` (
  `idsite` int(10) unsigned NOT NULL,
  `plugin_name` varchar(60) NOT NULL,
  `setting_name` varchar(255) NOT NULL,
  `setting_value` longtext NOT NULL,
  `json_encoded` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `idsite_setting` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`idsite_setting`),
  KEY `idsite` (`idsite`,`plugin_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_site_url`;
CREATE TABLE `matomo_site_url` (
  `idsite` int(10) unsigned NOT NULL,
  `url` varchar(190) NOT NULL,
  PRIMARY KEY (`idsite`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_tracking_failure`;
CREATE TABLE `matomo_tracking_failure` (
  `idsite` bigint(20) unsigned NOT NULL,
  `idfailure` smallint(5) unsigned NOT NULL,
  `date_first_occurred` datetime NOT NULL,
  `request_url` mediumtext NOT NULL,
  PRIMARY KEY (`idsite`,`idfailure`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_twofactor_recovery_code`;
CREATE TABLE `matomo_twofactor_recovery_code` (
  `idrecoverycode` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(100) NOT NULL,
  `recovery_code` varchar(40) NOT NULL,
  PRIMARY KEY (`idrecoverycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_user`;
CREATE TABLE `matomo_user` (
  `login` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `twofactor_secret` varchar(40) NOT NULL DEFAULT '',
  `superuser_access` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `date_registered` timestamp NULL DEFAULT NULL,
  `ts_password_modified` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_user` (`login`, `password`, `email`, `twofactor_secret`, `superuser_access`, `date_registered`, `ts_password_modified`) VALUES
('admin',	'$2y$10$cEPhFmcD67vZ9kZBh8zrGOjY0rbqW/mv9xN8kJVO2xfKHej3LGzCy',	'admin@constient.com',	'',	1,	'2021-04-26 00:56:46',	'2021-04-26 00:56:46'),
('anonymous',	'',	'anonymous@example.org',	'',	0,	'2021-04-26 00:51:09',	'2021-04-26 00:51:09');

DROP TABLE IF EXISTS `matomo_user_dashboard`;
CREATE TABLE `matomo_user_dashboard` (
  `login` varchar(100) NOT NULL,
  `iddashboard` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `layout` text NOT NULL,
  PRIMARY KEY (`login`,`iddashboard`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_user_language`;
CREATE TABLE `matomo_user_language` (
  `login` varchar(100) NOT NULL,
  `language` varchar(10) NOT NULL,
  `use_12_hour_clock` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `matomo_user_token_auth`;
CREATE TABLE `matomo_user_token_auth` (
  `idusertokenauth` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `password` varchar(191) NOT NULL,
  `hash_algo` varchar(30) NOT NULL,
  `system_token` tinyint(1) NOT NULL DEFAULT '0',
  `last_used` datetime DEFAULT NULL,
  `date_created` datetime NOT NULL,
  `date_expired` datetime DEFAULT NULL,
  PRIMARY KEY (`idusertokenauth`),
  UNIQUE KEY `uniq_password` (`password`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matomo_user_token_auth` (`idusertokenauth`, `login`, `description`, `password`, `hash_algo`, `system_token`, `last_used`, `date_created`, `date_expired`) VALUES
(1,	'anonymous',	'anonymous default token',	'c0924a818b402b399dccab97dd4b26190c9ae2954ce8012b15f2bec69a874d89c65271ba17dcc360145b656d355fe1210e202ba955ee85536bb3beaa6e30be62',	'sha512',	0,	'2021-04-28 08:57:15',	'2021-04-26 06:21:09',	NULL),
(2,	'admin',	'API Token',	'bc27c1cf1b04d6a1a9bb144606015dec2303160460882ff68ffc90605ab17d55d88501bd882c6b680d1a15f186977cff4407bb442968b8f66c57d31aa363565a',	'sha512',	0,	NULL,	'2021-04-27 06:36:39',	NULL);

-- 2021-04-28 09:13:13
