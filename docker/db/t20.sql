CREATE DATABASE /*!32312 IF NOT EXISTS*/`dldb` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

USE `dldb`;

CREATE TABLE `t20` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `a` int(11) DEFAULT NULL,
  `b` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `a` (`a`),
  KEY `b` (`b`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO t20(a, b) VALUES(1,5);
INSERT INTO t20(a, b) VALUES(1,10);
INSERT INTO t20(a, b) VALUES(2,5);
INSERT INTO t20(a, b) VALUES(2,10);
INSERT INTO t20(a, b) VALUES(3,5);
INSERT INTO t20(a, b) VALUES(3,10);
INSERT INTO t20(a, b) VALUES(4,5);
INSERT INTO t20(a, b) VALUES(4,10);
INSERT INTO t20(a, b) VALUES(5,5);
INSERT INTO t20(a, b) VALUES(5,10);

/*
mysqlslap --create-schema dldb -q "begin; DELETE FROM t20 WHERE a = 3 AND b = 10; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; DELETE FROM t20 WHERE a = 5 AND b = 10; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/
