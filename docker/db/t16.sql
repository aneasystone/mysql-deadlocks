CREATE DATABASE /*!32312 IF NOT EXISTS*/`dldb` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

USE `dldb`;

CREATE TABLE `t16` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `xid` int(11) DEFAULT NULL,
  `valid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `xid_valid` (`xid`,`valid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO t16(id, xid, valid) VALUES(1, 1, 0);
INSERT INTO t16(id, xid, valid) VALUES(2, 2, 1);
INSERT INTO t16(id, xid, valid) VALUES(3, 3, 1);
INSERT INTO t16(id, xid, valid) VALUES(4, 1, 0);
INSERT INTO t16(id, xid, valid) VALUES(5, 2, 0);
INSERT INTO t16(id, xid, valid) VALUES(6, 3, 1);
INSERT INTO t16(id, xid, valid) VALUES(7, 1, 1);
INSERT INTO t16(id, xid, valid) VALUES(8, 2, 1);
INSERT INTO t16(id, xid, valid) VALUES(9, 3, 0);
INSERT INTO t16(id, xid, valid) VALUES(10, 1, 1);

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 0 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 0 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 0 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/

/*
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 1 where xid = 3; rollback;" --number-of-queries=100000 -uroot -p123456 &
mysqlslap --create-schema dldb -q "begin; update t16 set xid = 3, valid = 0 where xid = 2; rollback;" --number-of-queries=100000 -uroot -p123456 &
*/
