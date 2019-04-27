CREATE DATABASE /*!32312 IF NOT EXISTS*/`dldb` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

USE `dldb`;

CREATE TABLE `t18` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT  INTO `t18`(`id`) VALUES (1);
INSERT  INTO `t18`(`id`) VALUES (2);
INSERT  INTO `t18`(`id`) VALUES (3);
INSERT  INTO `t18`(`id`) VALUES (4);
INSERT  INTO `t18`(`id`) VALUES (5);
INSERT  INTO `t18`(`id`) VALUES (6);
INSERT  INTO `t18`(`id`) VALUES (7);
INSERT  INTO `t18`(`id`) VALUES (8);

/*
mysqlslap --create-schema dldb -q "begin; delete from t18 where id = 4; insert into t18 (id) values (4); rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; delete from t18 where id = 4; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/
