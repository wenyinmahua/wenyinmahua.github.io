---
title: MySQL 精简版
date: 2023-06-11
updated: 2023-06-15
comments: true
category: MySQL
cover: https://tse3-mm.cn.bing.net/th/id/OIP-C.LvJiXW0ldtBwCwC5TBSh4QHaEK?w=321&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# mysql精简版

## 1.查看MySQL支持哪些存储引擎：

**show engines \G**			engine:引擎

常见参数详解

CASCADE(级联)：删除模式的同时把该模式中所有的数据库对象全部删除
RESTRICT(限制)：如果该模式中定义了下属的数据库对象（如表、视图等），则拒绝该删除语句的执行。
只有当该模式中没有任何下属的对象时才能执行。
应首先删除其中的对象

# 一、SQL语句分类和数据类型

## 1.SQL语句分类

**DQL：**数据查询语言（凡是带select关键字的都是查询语句）                                              **Data Qurey Language**
**DML：**数据操作语言（凡是对表当中的数据进行增删修改的都是DML），这个操作主要是表的数据data
			insert增、delete删、update改；                                                                               **Data Manipulation Language**
**DDL：**数据定义语句（凡是带有create(新建)、drop(删除)、alter(修改)的都是DDL。          **Data Definition Language**
		   这里的增删改和DML不同，这个主要是正对表结构进行操作。
**TCL：**事务控制语言，包括：事务提交（commit）、事务回滚（rollback）             **Transactional Comtrol Language**
**DCL：**数据控制语言，有授权（grant）、撤销权限（revoke）                                             **Data Control Language**

## 2.SQL数据类型

| 符号         | 代表                                       |
| ------------ | ------------------------------------------ |
| **字符串型** |                                            |
| varchar      | 可变长度字符串类型                         |
| char         | 定长字符串类型                             |
| **数字类型** |                                            |
| int          | 整型                                       |
| bigint       | 长整型                                     |
| float        | 单精度浮点型                               |
| double       | 双精度浮点型                               |
| smallint     | 短整型                                     |
| numeric(p,d) | 定点数，由p个数字组成，小数点后面有d位数字 |
| **日期类型** |                                            |
| date         | 日期，包含年月日，格式为YYYY-MM-DD         |
| time         | 时间，包含时分秒，格式为HH：MM：SS         |
| datetime     | 包含年月日时分秒                           |
| **对象**     |                                            |
| clob         | 字符大对象，超过255个字符都要采用这个类型  |
| blob         | 二进制大对象，图片、音频、视频等等         |



# 二、MySQL基本语句

| 操作                 | 命令                                                      |
| -------------------- | --------------------------------------------------------- |
| 登录MySQL            | MySQL -uroot -p密码;                                      |
| 退出MySQL            | exit;                                                     |
| 查看数据库           | show databases;                                           |
| 创建数据库           | **create database** databasename;                         |
| 使用数据库           | use databasename;                                         |
| 查看当前使用的数据库 | select database();                                        |
| 查看数据库版本       | select version();                                         |
| 查看数据库中的表     | show tables;                                              |
| 导入表               | source 表所在位置;               直接拖入，路径不能有中文 |
| 导入SQL语句操作      | source  SQL语句所在地址;         直接拖入                 |
| 删除数据库           | **drop database** databasename                            |
| 查看表的结构         | desc  tablename                          describe         |
| 终止一条SQL语句      | \c 回车                                                   |



# 三、DQL语句

**注意：**查询不会更改表的数据和结构。
基本语法：

```mysql
#简单查询字段
select 字段1,字段2 字段2的别名 from 表名;
#查询字段进行加减乘除
select 字段1*12,字段2 from 表名;
```

## 1.条件查询 where

where查询子句常用的条件：

| 查询条件 | 谓词                                         |
| -------- | -------------------------------------------- |
| 比较     | =,>,<,>=,<=,!=,<>,!>,!<;not+上述比较运行算符 |
| 确定范围 | between and,not between and                  |
| 确定集合 | in, not in                                   |
| 字符匹配 | like, not like                               |
| 空值     | is null, not is null                         |
| 多重条件 | and ,or, not                                 |

```mysql
#条件查询where\in\like匹配数据
select 字段1 from 表名 where 条件(筛选数据);
例： select name,sal,age from emp where sal < 7000 and age > 35;
select sal from emp where sal in (8000,9000,10000);
#like模糊查找
select 字段名 from 表名	where 字段名 like '%D%';
#选择在某范围的字段
select 字段名 from 表名 where 字段名 between 范围左区间值 and 范围右区间值;开区间
```

## 2.查询后排序  order by asc、desc

```mysql
select 字段名 from 表名 order by 需要进行排序的字段;	默认升序
升序： select 字段名 from 表名 order by 需要排序的字段 asc;
降序： select 字段名 from 表名 order by 需要排序的字段 desc；
复合： select 字段名 from 表名 order by 字段名1 desc,字段名2	desc; 当字段1相等时才比较字段2
```

## 3.单行处理函数

基本语法：

```mysql
select 函数名(字段名) from 表名;
```

常见单行处理函数：

| 函数名                                   | 操作结果                               |
| :--------------------------------------- | -------------------------------------- |
| lower                                    | 转换将数据为小写                       |
| upper                                    | 将数据转换为大写                       |
| substr(截取的字符串，起始下标，截取长度) | 取字符串的子串                         |
| length                                   | 取数据的长度                           |
| trim                                     | 去空格                                 |
| round                                    | 四舍五入                               |
| rand                                     | 生成随机数                             |
| str_to_date('01-01-2000','%d-%m-%Y')     | 将字符串式的日期转换为日期格式         |
| date_format('01-01-2000','%d-%m-%Y')     | 将日期格式的日期格式换转换为字符串格式 |

## 4.多行处理函数

| 函数名  | 操作结果 |
| ------- | -------- |
| count() | 取记录数 |
| sum()   | 求和     |
| avg()   | 求平均值 |
| max()   | 求最大值 |
| min()   | 求最小值 |

**注意：**分组函数不能写在where后面，因为此时含没有完成分组，放在where后面就会出错

## 5.分组查询 group by

```mysql
select * from tablename group by 字段名1;
#将全表按着字段名1进行分组，相同的归为一组
```

## 6.having语句

```mysql
select * from tablename group by 字段名 having 过滤条件;
```

having后面的过滤条件可以跟分组函数。

## 7.结果去重：distinct

```mysql
select distinct 字段名1，字段名2,... from tablename;
#注意distinct前面不能出现字段名。
```

## 8.***连接查询join on

```mysql
select A.id,B.id from tableA A join tableB B on 连接条件; 
```

连接条件有等值连接（用=连接）				连接的编号相等
和
非等值连接（用between…and…连接） 	连接的值在两个值之间，比如根据成绩确定等级ABC

## 9.自连接

```mysql
select A.id,B.id from tablename A join tableB on 连接条件;
```

## 10.外连接

```mysql
select A.id,b.id from tablename A left/ right join tablename B on 连接条件;
```

将左右连接表示左边的表或者右边的表的数据全部查询出来，因为当连接提交乙方为空的时候，这条数据会失效，MySQL会自动删除这条查询记录。

## 10.多张表进行连接

```mysql
select
	……
from
	a
join
	b
on		a和b的连接条件
join
	c
on		a和c的连接条件
join
	d
on		a和d的连接条件
………………………………
```

## 11.子查询语句select嵌套使用

```mysql
select
	..(select)..
from
	..(select) newtablename..
#这里是基于派生表的查询，需要给派生表起个别名
where
	..(select)..
```

## 12、联合查询union

```mysql
select A.id from tableA A
union
select B.id from tableB B;
将两次查询的结果合成为一张表，要求查询的结果必须拥有相同的列数。
```

## 13.将查询的结果分页显示limit

```mysql
select * from tabelname limit startIndex,length;
#从表中的第start+1项开始，查找length项。
每页显示pagesize条记录：
	第pageNo页：limit ?,pagesize		? = (pageNo - 1) * (pagesize )
limit (pageNo - 1)*pagesize,pagesize
```



## 14.DQL大总结

```mysql
select ……
from ……			#程序首先从这里开始
where ……
group by ……
having			#在这之后执行select语句
order by ……
limit ……
```

# 四、DDL数据库定义语句

## 1.创建表create table

```mysql
create table tablename(
    字段名1 数据类型,
    字段名2 数据类型(规定长度),
    字段名3 数据类型,
    ……
);
#注意，最后一个创建字段不需要用逗号结尾，其他都需要逗号结尾
```

## 2.复制表

```mysql
create table newtable as select * from oldtable;
```

## 3.删除表的结构 drop table

```mysql
#删除全表
drop table tablename [CASCADE|RESTRICT];#CASCADE可以删除与该表有联系的视图
drop table if exists tablename;
```

## 4.删除表中的数据：truncate

```mysql
truncate table tablename;
#注意这种删除不支持回滚
delete删除的数据支持回滚 rollback
```

## 5.修改表的结构：alter

```mysql
插入字段： ALTER TABLE TABLENAME ADD 字段名 字段数据类型 完整性约束条件
插入表级约束： ALTER TABLE TABLENAME ADD 表级约束
删除约束： ALTER TABLE TABLENAME DROP 约束名
删除字段： ALTER TABLE TABLENAME DROP COLUMN 字段名
修改列的结构： ALTER TABLE TABLENAME ALTER COLUMN 列名 数据类型
```



# 五、DML语句insert、delete、update、select

## 1.插入insert

```mysql
insert into tablename (需要插入的字段) values(相关的值，一一对应)
insert into tablename values(所有的字段对应的值);
#值必须写全
insert into tablename values(),(),();#一次插入多条记录
#插入子查询结果
insert into tablename select * from tablename;#注意两个表的字段数据要一一对应才有意义。 

```

## 2.更新数据update tablename set ……where 

```mysql
update tablename set 字段名1 = '值',字段名2 = '值'…… where 需要修改的查找条件,用来确定需要修改的记录所在位置。 
#一定要指明修改的条件，因为不指明会将数据库中的所有的数据全部修改
```

## 3.逻辑删除delete from tablename  恢复：rollback

```mysql
delete from tablename where 删除记录所在位置;
#没有where，将会删除整张表的数据。
```

逻辑删除支持回滚（rollback）将数据恢复

delete删除原理：表中的数据被删除，但是这个数据在硬盘上的真实存储空间不会被释放
缺点：删除的效率比较低，删除大量数据会花费一定的时间。
优点：支持回滚，数据删除后可以恢复  **回滚命令：rollback**

## 4.物理删除：truncate   属于DDL语句

语法格式：

```mysql
truncate table tablename;
#这种删除的效率比较高，表被一次截断，物理删除
一次把所有的数据全部删除，不能删单条，
```

缺点：不支持回滚，删除之后无法恢复；不能随便使用，使用该命令时，必须提前了解该表中数据是否还有存在的意义。
优点：能快速删除，删除速度比delete高，快速删除大量数据。

# 六、约束

| 约束              | 描述                                                   |            |
| ----------------- | ------------------------------------------------------ | ---------- |
| not null          | 代表这个字段的值不能为空                               | 列级       |
| unique            | 代表这个字段的值不能重复，但是可以为NULL               | 列级和行级 |
| primary key(pk)   | 代表这个字段的值不能为空且不能重复（一张表只能有一个） | 列级和行级 |
| foreign key（fk） | 代表这个字段受外界影响，不能超过规定的内容             |            |
| check             | 用户用来限制该字段的取值范围                           |            |

```mysql
MySQL外键链接语法：
foreign key (本表中需要增加外键的字段) references 父表(连接到父表的字段)
SEX CAHR(2) CHECK(SEK IN ('男','女'))
```

# 七、事务

## 1.事务的实现

```mysql
start transaction;/*begin transaction*/
insert into tablenane values("");
insert into tablenane values("");
insert into tablenane values("");
rollback(撤销事务) /	commit(提交事务);
```

## 2.事务的隔离性

1. 读未提交	：read	uncommitted;
2. 读已提交    :  read     committed;
3. 可重复读    :  repeatable    read
4. 序列化/串行化   : serializable

```mysql
#查看隔离级别
select @@session.tx_isolation
select @@tx.isolation
select @@transaction_isolation
设置事务的隔离级别：
set global transaction isolation level 事务的隔离级别 ;
```

# 八、索引

## 1.创建、删除索引

```mysql
create index 索引名 on tablename(字段名);
drop index 索引名 on tablename;
```

## 2.查看一个SQL语句是否使用了索引进行检索

```mysql
explain select * from tablename where 字段名 = “匹配值”;
#如果type = ALL，锁门没有使用索引，如果type = ref，说明使用了索引
```

## 3.索引失效情况

1. 模糊扫描以“%”开始，如：“%D”
2. 使用or，如果使用or走索引，那么要求or两边的字段都要有索引，一方没有，那么不会走索引。
3. 使用复合索引时，内有使用左侧的列查找，索引失效。见下列解释。
4. 在where当中索引列参加了数学运算，索引失效。
5. 在where当中索引使用了函数

# 九、视图

## 创建、删除索引对象

```mysql
create view 视图名 as select * from 表名;as后面必须是查询语句
drop view 视图名;
```

# 十、授权与撤销权限

```mysql
grant 权限 on table tablename(字段1，字段2...) to 用户名(public) with grant option;
grant all privileges on table tablename(字段1，字段2...) to 用户名
revoke 权限 on table tablename(字段1，字段2...) to 用户名
revoke 权限 on table tablename(字段1，字段2...) to 用户名
```

# 十一、模式

定义模式实际上就是定义了一个命名空间（或容器）。在这个空间可以定义该模式包含的数据库对象，定义模式可以更好的管理数据库的对象

```mysql
CREATE SCHEMA SCHEMANAME AUTHORIZATION USERNAME;
如果没有指定模式名，那么模式名隐含为用户名
DROP SCHEMA SCHEMANAME [CASCADE|RESTRICT]
```

CASCADE(级联)：删除模式的同时把该模式中所有的数据库对象全部删除
RESTRICT(限制)：如果该模式中定义了下属的数据库对象（如表、视图等），则拒绝该删除语句的执行。
只有当该模式中没有任何下属的对象时才能执行。
应首先删除其中的对象