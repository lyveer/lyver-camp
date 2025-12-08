CREATE TABLE IF NOT EXISTS `lyver_camps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `heading` double NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`)
  
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE lyver_camps ADD COLUMN type VARCHAR(50) DEFAULT 'Small';