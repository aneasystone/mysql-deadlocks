# mysql-deadlocks

在工作过程中偶尔会遇到死锁问题，虽然这种问题遇到的概率不大，但每次遇到的时候要想彻底弄懂其原理并找到解决方案却并不容易。这个项目收集了一些常见的 MySQL 死锁案例，大多数案例都来源于网络，并对其进行分类汇总，试图通过死锁日志分析出每种死锁的原因，还原出死锁现场。

实际上，我们在定位死锁问题时，不仅应该对死锁日志进行分析，还应该结合具体的业务代码，或者根据 binlog，理出每个事务执行的 SQL 语句。

我将这些死锁按事务执行的语句和正在等待或已持有的锁进行分类汇总：

|事务一语句|事务二语句|事务一等待锁|事务二等待锁|事务二持有锁|案例|
|---------|-----------|---------|-----------|-----------|---|
|insert|insert|lock_mode X insert intention|lock_mode X insert intention|lock_mode X|1|
|insert|insert|lock_mode X locks gap before rec insert intention|lock_mode X locks gap before rec insert intention|lock_mode X locks gap before rec|14|
|insert|insert|lock_mode X insert intention|lock_mode X insert intention|lock_mode S|2|
|insert|insert|lock mode S|lock_mode X locks gap before rec insert intention|lock_mode X locks rec but not gap|15|
|delete|delete|lock_mode X|lock mode S|lock_mode X locks rec but not gap|4|
|delete|delete|lock_mode X|lock mode X|lock_mode X locks rec but not gap|6|
|delete|delete|lock_mode X locks rec but not gap|lock_mode X|lock_mode X|3|
|delete|delete|lock_mode X locks rec but not gap|lock mode X|lock_mode X locks rec but not gap|7|
|delete|delete|lock_mode X locks rec but not gap|lock_mode X locks rec but not gap|lock_mode X locks rec but not gap|8,9|
|delete|insert|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode X locks rec but not gap|5|
|delete|insert|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode S|10|
|delete|insert|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode X|12|
|delete|insert|lock_mode X|lock mode S|lock_mode X locks rec but not gap|13|
|update|update|lock_mode X locks rec but not gap|lock mode S|lock_mode X locks rec but not gap|11|
|update|update|lock_mode X|lock_mode X locks gap before rec insert intention|lock_mode X locks rec but not gap|16|
|update|update|lock_mode X locks gap before rec insert intention|lock_mode X locks gap before rec insert intention|lock_mode X|17|
|delete|insert|lock mode S|lock_mode X locks rec but not gap||18|

表中的语句虽然大多数只列出了 delete 和 insert，但实际上绝大多数的 delete 语句和 update 或 select ... for update 加锁机制是一样的，所以为了避免重复，对于 update 语句就不在一起汇总了（当然也有例外，譬如使用 update 对索引进行更新时加锁机制和 delete 是有区别的，这种情况我会单独列出，如案例 11）。

对每一个死锁场景，我都会定义一个死锁名称（实际上就是事务等待和持有的锁），每一篇分析，我都分成了 死锁特征、死锁日志、表结构、重现步骤、分析和参考 这几个部分。

对于这种分类方法我感觉并不是很好，但也想不出什么其他更好的方案，如果你有更好的建议，欢迎讨论。另外，如果你有新的死锁案例，或者对某个死锁的解释有异议，欢迎给我提 Issue 或 PR。
