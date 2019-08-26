# mysql-deadlocks

在工作过程中偶尔会遇到死锁问题，虽然这种问题遇到的概率不大，但每次遇到的时候要想彻底弄懂其原理并找到解决方案却并不容易。这个项目收集了一些常见的 MySQL 死锁案例，大多数案例都来源于网络，并对其进行分类汇总，试图通过死锁日志分析出每种死锁的原因，还原出死锁现场。

实际上，我们在定位死锁问题时，不仅应该对死锁日志进行分析，还应该结合具体的业务代码，或者根据 binlog，理出每个事务执行的 SQL 语句。

我将这些死锁按事务执行的语句和正在等待或已持有的锁进行分类汇总：

|事务一语句|事务二语句|事务一等待锁|事务二等待锁|事务二持有锁|案例|
|---------|-----------|---------|-----------|-----------|---|
|insert|insert|lock_mode X insert intention|lock_mode X insert intention|lock_mode X|[1](/1.md)|
|insert|insert|lock_mode X locks gap before rec insert intention|lock_mode X locks gap before rec insert intention|lock_mode X locks gap before rec|[14](/14.md)|
|insert|insert|lock_mode X insert intention|lock_mode X insert intention|lock_mode S|[2](/2.md)|
|insert|insert|lock mode S|lock_mode X locks gap before rec insert intention|lock_mode X locks rec but not gap|[15](/15.md)|
|delete|insert|lock_mode X locks rec but not gap|lock mode S|lock_mode X locks rec but not gap|[18](/18.md)|
|delete|delete|lock_mode X|lock mode S|lock_mode X locks rec but not gap|[4](/4.md)|
|delete|delete|lock_mode X|lock mode X|lock_mode X locks rec but not gap|[6](/6.md)|
|delete|delete|lock_mode X locks rec but not gap|lock_mode X|lock_mode X|[3](/3.md)|
|delete|delete|lock_mode X locks rec but not gap|lock mode X|lock_mode X locks rec but not gap|[7](/7.md)|
|delete|delete|lock_mode X locks rec but not gap|lock_mode X locks rec but not gap|lock_mode X locks rec but not gap|[8](/8.md),[9](/9.md)|
|delete|insert|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode X locks rec but not gap|[5](/5.md)|
|delete|insert|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode S|[10](/10.md)|
|delete|insert|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode X|[12](/12.md)|
|delete|insert|lock_mode X|lock mode S|lock_mode X locks rec but not gap|[13](/13.md)|
|update|update|lock_mode X locks rec but not gap|lock mode S|lock_mode X locks rec but not gap|[11](/11.md)|
|update|update|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode X locks rec but not gap|[16](/16.md)|
|update|update|lock_mode X locks gap before rec insert intention|lock_mode X locks gap before rec insert intention|lock_mode X|[17](/17.md)|
|update|delete|lock_mode X locks rec but not gap|lock_mode X|lock mode S|[19](/19.md)|
|update|update|lock_mode X locks rec but not gap waiting|lock_mode X locks rec but not gap waiting|lock_mode X locks rec but not gap|[20](/20.md)|

表中的语句虽然大多数只列出了 delete 和 insert，但实际上绝大多数的 delete 语句和 update 或 select ... for update 加锁机制是一样的，所以为了避免重复，对于 update 语句就不在一起汇总了（当然也有例外，譬如使用 update 对索引进行更新时加锁机制和 delete 是有区别的，这种情况我会单独列出，如案例 11）。

对每一个死锁场景，我都会定义一个死锁名称（实际上就是事务等待和持有的锁），每一篇分析，我都分成了 死锁特征、死锁日志、表结构、重现步骤、分析和参考 这几个部分。

对于这种分类方法我感觉并不是很好，但也想不出什么其他更好的方案，如果你有更好的建议，欢迎讨论。另外，如果你有新的死锁案例，或者对某个死锁的解释有异议，欢迎给我提 Issue 或 PR。

## 死锁分析

之前写过关于死锁的一系列博客，供参考。

* [解决死锁之路 - 学习事务与隔离级别](https://www.aneasystone.com/archives/2017/10/solving-dead-locks-one.html)
* [解决死锁之路 - 了解常见的锁类型](https://www.aneasystone.com/archives/2017/11/solving-dead-locks-two.html)
* [解决死锁之路 - 常见 SQL 语句的加锁分析](https://www.aneasystone.com/archives/2017/12/solving-dead-locks-three.html)
* [解决死锁之路（终结篇） - 再见死锁](https://www.aneasystone.com/archives/2018/04/solving-dead-locks-four.html)
* [读 MySQL 源码再看 INSERT 加锁流程](https://www.aneasystone.com/archives/2018/06/insert-locks-via-mysql-source-code.html)

## 死锁重现

docker 目录下包含了各个死锁重现的测试脚本，测试步骤如下：

1. 创建数据库和初始数据

```
# cd docker
# docker-compose up -d
```

确保机器上安装了 docker 和 docker-compose，上面的命令会启动一个 mysql:5.7 的容器，并创建一个名为 dldb 的数据库，初始密码为 123456，并通过 `docker-entrypoint-initdb.d` 初始化所有案例所需要的表和数据。

2. 等待容器启动结束

```
# docker logs -f dldb
```

使用 `dockere logs` 查看容器启动日志，如果出现数据初始化完成的提示，如下所示，则进入下一步。

```
MySQL init process in progress...
Warning: Unable to load '/usr/share/zoneinfo/iso3166.tab' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/leap-seconds.list' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/zone.tab' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/zone1970.tab' as time zone. Skipping it.

/usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/t16.sql
mysql: [Warning] Using a password on the command line interface can be insecure.

/usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/t18.sql
mysql: [Warning] Using a password on the command line interface can be insecure.

/usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/t8.sql
mysql: [Warning] Using a password on the command line interface can be insecure.

MySQL init process done. Ready for start up.
```

3. 进入容器执行测试脚本

首先进入容器：

```
# docker exec -it dldb bash
```

然后执行测试脚本，测试脚本在每一个案例对应的 SQL 文件中，比如案例 18 对应的测试脚本如下：

```
# mysqlslap --create-schema dldb -q "begin; delete from t18 where id = 4; insert into t18 (id) values (4); rollback;" --number-of-queries=100000 -uroot -p123456 &
# mysqlslap --create-schema dldb -q "begin; delete from t18 where id = 4; rollback;" --number-of-queries=100000 -uroot -p123456 &
```

测试脚本通过 `mysqlslap` 工具并发执行两个事务，每个事务执行 N 次（N = 100000），如果两个事务会出现死锁，则我们可以通过死锁日志看到。

4. 检查是否出现死锁日志

```
# tail -f /var/log/mysql/error.log
```

## TODO

- [ ] 重现案例 1
- [ ] 重现案例 2
- [ ] 重现案例 3
- [ ] 重现案例 4
- [ ] 重现案例 5
- [ ] 重现案例 6
- [ ] 重现案例 7
- [x] 重现案例 8
- [ ] 重现案例 9
- [ ] 重现案例 10
- [ ] 重现案例 11
- [ ] 重现案例 12
- [ ] 重现案例 13
- [ ] 重现案例 14
- [ ] 重现案例 15
- [x] 重现案例 16
- [ ] 重现案例 17
- [x] 重现案例 18
- [ ] 重现案例 19
- [ ] 重现案例 20
- [ ] 由于相同的测试脚本在并发的时候可能产生不同的死锁，后续可以写个脚本来解析 error.log 看看发生了多少次死锁
- [ ] 使用 mysqlslap 测试不太方面，后续可以写个脚本来模拟并发事务
