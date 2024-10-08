---
title: MySQL 优化
date: 2024-08-19
updated: 2024-08-19
category: MySQL
cover: https://tse3-mm.cn.bing.net/th/id/OIP-C.LvJiXW0ldtBwCwC5TBSh4QHaEK?w=321&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7

---

# MySQL 优化

## SQL 性能分析

### SQL 执行效率

通过` show [session|global] status` 命令可以提供服务器状态信息。通过如下指令，可以查看当前数据库的`INSERT、UPDATE、DELETE、SELECT` 的访问频次：

```SQL
 SHOW GLOBAL STATUS LIKE 'Com_______'; # (七个下杠，一个_+6个单词)
```

![sql 性能分析](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240819144421200.png)

> 通过上述指令，可以查看到当前数据库到底是以查询为主，还是以增删改为主，从而为数据库优化提供参考依据。 如果是以增删改为主，可以考虑不对其进行索引的优化。 如果是以查询为主，那么就要考虑对数据库的索引进行优化了。



### 慢查询日志

慢查询日志记录了所有执行时间超过指定参数（long_query_time，单位：秒，默认10秒）的所有 SQL 语句的日志。

MySQL 的慢查询日志默认没有开启，同一通过系统变量查看 `slow_query_log`。

```SQL
SHOW VARIABLES LIKE 'slow_query_log'; # 关闭显示 OFF，开启显示 ON
```

开启慢查询日志，需要在 MySQL 的`配置文件` （/etc/my.cnf）中配置如下：

```sql
# 开启MySQL慢日志查询开关
slow_query_log=1
# 设置慢日志的时间为2秒，SQL语句执行时间超过2秒，就会视为慢查询，记录慢查询日志
long_query_time=2
```

配置完毕之后，通过以下指令重新启动MySQL服务器进行测试，查看慢日志文件中记录的信息 `/var/lib/mysql/localhost-slow.log`。

```SHELL
systemctl restart mysqld
```



### profile 

`show profiles` 能够在做 SQL 优化时帮助我们了解时间都耗费到哪里去了。通过`have_profiling` 参数，能够看到当前 MySQL 是否支持 profile 操作。

MySQL是支持 profile操作的，但是开关是关闭的。可以通过set语句在 session/global级别开启profiling：

```SQL
SELECT @@have_profiling;
SET peofile = 1;
```



```SQL
-- 查看每一条SQL的耗时基本情况
show profiles;
-- 查看指定query_id的SQL语句各个阶段的耗时情况
show profile for query query_id;
-- 查看指定query_id的SQL语句CPU的使用情况
show profile cpu for query query_id;
```



### explain

EXPLAIN 或者 DESC 命令获取 MySQL 如何执行 SELECT 语句的信息，包括在 SELECT 语句执行过程中表如何连接和连接的顺序。

```SQL
EXPLAIN SELECT 字段列表 FROM 表名 WHERE 条件;
```

![explain 的使用](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240819152504591.png)

| 字段         | 含义                                                         |
| ------------ | ------------------------------------------------------------ |
| id           | select查询的序列号，表示查询中执行select子句或者是操作表的顺序(id相同，执行顺序从上到下；id不同，值越大，越先执行)。 |
| select_type  | 表示 SELECT 的类型，常见的取值有 SIMPLE（简单表，即不使用表连接或者子查询）、PRIMARY（主查询，即外层的查询）、UNION（UNION 中的第二个或者后面的查询语句）、SUBQUERY（SELECT/WHERE之后包含了子查询）等 |
| type         | 表示连接类型，性能由好到差的连接类型为NULL、system、const、eq_ref、ref、range、 index、all 。 |
| possible_key | 显示可能应用在这张表上的索引，一个或多个。                   |
| key          | 实际使用的索引，如果为NULL，则没有使用索引。                 |
| key_len      | 表示索引中使用的字节数， 该值为索引字段最大可能长度，并非实际使用长度，在不损失精确性的前提下， 长度越短越好 。 |
| rows         | MySQL认为必须要执行查询的行数，在 innodb 引擎的表中，是一个估计值，可能并不总是准确的。 |
| filtered     | 表示返回结果的行数占需读取行数的百分比， filtered 的值越大越好。 |
| Extra        | 提供了关于查询执行过程中的一些额外信息                       |



## SQL 优化

### insert 优化

一次性往数据库表中插入多条数据，可以通过以下三个方面来优化：

- 批量插入
- 手动控制事务
- 主键顺序插入（性能要高于乱序插入）

如果一次性需要插入大批量数据(比如: 几百万的记录)，使用`insert`语句插入性能较低，此时可以使用MySQL数据库提供的load指令进行插入。



```sql
-- 客户端连接服务端时，加上参数 -–local-infile
mysql –-local-infile -u root -p
-- 设置全局参数local_infile为1，开启从本地加载文件导入数据的开关
set global local_infile = 1;
-- 执行load指令将准备好的数据，加载到表结构中
load data local infile '/root/sql1.sql' into table table_name fields terminated by ',' lines terminated by '\n' ;
```



#### 主键优化

主键不按顺序插入可能会出现 `页分裂` 现象，比较耗费性能。

**页合并：**当页中删除的记录达到 MERGE_THRESHOLD（默认为页的50%），InnoDB会开始寻找最靠近的页（前或后）看看是否可以将两个页合并以优化空间使用。

> MERGE_THRESHOLD：合并页的阈值，可以自己设置，在创建表或者创建索引时指定。



索引设计原则：

- 满足业务需求的情况下，尽量降低主键的长度。
- 插入数据时，尽量选择顺序插入，选择使用AUTO_INCREMENT自增主键。
- 尽量不要使用 UUID 做主键或者是其他自然主键，如身份证号。
- 业务操作时，避免对主键的修改。



### Order 优化

MySQL的排序，有两种方式：

Using filesort : 通过表的索引或全表扫描，读取满足条件的数据行，然后在排序缓冲区sort buffer中完成排序操作，所有不是通过索引直接返回排序结果的排序都叫 FileSort 排序。

Using index : 通过有序索引顺序扫描直接返回有序数据，这种情况即为 using index，不需要额外排序，操作效率高。

对于以上的两种排序方式，Using index的性能高，而Using filesort的性能低，我们在优化排序操作时，尽量要优化为 Using index。



#### Backward index scan

在MySQL中创建的索引，默认索引的叶子节点是从小到大排序的，而此时我们查询排序时，是从大到小，所以，在扫描时，就是反向扫描，就会出现 Backward index scan。

> 解决方案：创建联合索引同时设置排序方式

```SQL
create index idx_emp_age_sal on emp(age asc, sal desc);
```

order by 优化原则:

- 根据排序字段建立合适的索引，多字段排序时，也遵循最左前缀法则。
- 尽量使用覆盖索引。
- 多字段排序, 一个升序一个降序，此时需要注意联合索引在创建时的规则（ASC/DESC）。
- 如果不可避免的出现 filesort，大数据量排序时，可以适当增大排序缓冲区大小sort_buffer_size(默认256k)。



### groub by 优化

> group by 优化点：
>
> -  在分组操作时，可以通过索引来提高效率。
> -  分组操作时，索引的使用也是满足最左前缀法则的



### limit 优化

在数据量比较大时，如果进行limit分页查询，在查询时，越往后，分页查询效率越低。

优化思路：一般分页查询时，通过创建 **覆盖索引** 能够比较好地提高性能，可以通过覆盖索引加子查询形式进行优化。

```SQL
# 这里走了 覆盖索引 id 可以提高性能。
select * from tb_sku t , (select id from tb_sku order by id
limit 2000000,10) a where t.id = a.id;
```



### count 优化

如果数据量很大，在执行 count 操作时，是非常耗时的。

- MyISAM 引擎把一个表的总行数存在了磁盘上，因此执行 count(*) 的时候会直接返回这个数，效率很高； 但是如果是带条件的count，MyISAM 也慢。
- InnoDB 引擎就麻烦了，它执行 count(*) 的时候，需要把数据一行一行地从引擎里面读出来，然后累积计数。

要大幅度提升 InnoDB 表的 count 效率，主要的优化思路：自己计数(可以借助于 redis 这样的数据库进行,但是如果是带条件的 count 又比较麻烦了)。

count() 是一个聚合函数，对于返回的结果集，一行行地判断，如果 count 函数的参数不是 NULL，累计值就加 1，否则不加，最后返回累计值。

用法：count（*）、count（主键）、count（字段）、count（数字）

> 按照效率排序的话，count(字段) < count(主键 id) < count(1) ≈ count(\*)，所以尽量使用 count(\*)。

| count 用法    | 含义                                                         |
| ------------- | ------------------------------------------------------------ |
| count（主键） | InnoDB 引擎会遍历整张表，把每一行的 主键id 值都取出来，返回给服务层。服务层拿到主键后，直接按行进行累加(主键不可能为null) |
| count（字段） | 没有not null 约束 : InnoDB 引擎会遍历整张表把每一行的字段值都取出来，返回给服务层，服务层判断是否为null，不为null，计数累加。<br />有not null 约束：InnoDB 引擎会遍历整张表把每一行的字段值都取出来，返回给服务层，直接按行进行累加。 |
| count（数字） | InnoDB 引擎遍历整张表，但不取值。服务层对于返回的每一行，放一个数字“1”进去，直接按行进行累加。 |
| count（*）    | InnoDB引擎并不会把全部字段取出来，而是专门做了优化，不取值，服务层直接按行进行累加。 |



### update 优化

```sql
delete from user where id = 1;
```

在执行删除的SQL语句时，会锁定 id 为 1 这一行的数据，然后事务提交之后，行锁释放。

```mysql
update user set name = "zhan" where id = 1; 
```

当开启多个事务，在执行如下的 SQL 时，发现行锁升级为了表锁(因为没有走索引，走的是全表扫描)。 导致该 update 语句的性能大大降低。

```mysql
update user set name = "zhan" where name = "mahua"; 
```

> InnoDB 的行锁是针对索引加的锁，不是针对记录加的锁 ,并且该索引不能失效，否则会从行锁升级为表锁 。

