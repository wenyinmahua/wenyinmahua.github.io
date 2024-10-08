---
title: MySQL
date: 2024-08-17
updated: 2024-08-19
category: MySQL
cover: https://tse3-mm.cn.bing.net/th/id/OIP-C.LvJiXW0ldtBwCwC5TBSh4QHaEK?w=321&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# MySQL

## 1.数据库的基本概念

数据(Data)：所有能输入计算机中，并被计算机程序处理的符号总称叫做数据。数据可以是符号，也可以是文字、数字、语音、图像、视频等等。

数据库(Database)：简称DB，数据库是**按照一定的结构来组织、存储和管理数据的仓库**。

数据库管理系统(Database Management System)：简称 DBMS，数据库管理系统是一种**操纵和管理数据库的大型软件**，用于创建、使用和维护数据库。



## 2. 数据库分类

数据库分为关系数据库和非关系数据库两类：

**关系型数据库**(Relational Database Management System)：是建立在**关系模型**的基础上，由若干个相互关联的**二维表**组成的数据库。

关系型数据库特点：

1、使用二维表来存储数据，格式统一，便于维护。

2、使用SQL语句操作数据库，标准统一，使用方便。

3、数据存储在磁盘中，相对安全。

**非关系型数据库**：NoSQL（Not Only SQL），是对关系型数据库的补充。这类数据库与传统的关系型数据库在设计和结构上有很大的不同，它们更强调数据库数据的高并发读写和存储大数据。目前几种主流的非关系型数据库包括：键值(Key-Value)存储数据库(如Redis)、列存储数据库(如HBase)、文档型数据库(如MongoDB)等。

非关系型数据库特点：

1、易扩展。

2、大数据量、高性能。

3、灵活的数据模型。



## 3. 关系型数据库介绍

关系型数据库是应用最广泛的一种数据库。以表、行和列的结构来组织和处理数据。

**表：**是一个命名的**存储空间**，也称实体，用来保存数据。

**列：**是表中一组命名的**属性**，也称字段。每个列都有自己的数据类型，比如数值型、字符型、日期型等。列用来定义表的结构。

**行：**是表中的一条数据，也称记录。



## SQL 分类

SQL语言可分为如下5种，本课程需重点掌握DML、DQL、TCL语言，理解DDL语言、了解DCL即可

| **分类**                           | **名称**     | **用途**                           | **代表关键字**                                   |
| ---------------------------------- | ------------ | ---------------------------------- | ------------------------------------------------ |
| DDL (Data Definition Language)     | 数据定义语言 | 用来定义数据库、表及其它对象的结构 | CREATE、DROP、ALTER                              |
| DML (Data Manipulation Language)   | 数据操作语言 | 用来增加、修改、删除表中的数据     | INSERT、DELETE、UPDATE                           |
| DQL (Data Query Language)          | 数据查询语言 | 用来查询表中的数据                 | SELECT、FROM、WHERE、ORDER BY 、GROUP BY、HAVING |
| DCL (Data Control Language)        | 数据控制语言 | 用来授予和收回权限                 | GRANT、REVOKE                                    |
| TCL (Transaction Control Language) | 事务处理语言 | 用来对数据进行提交和回滚           | COMMIT、ROLLBACK                                 |



> 注意：
>
> - 空值参与算术运算后，结果仍为空值
> - 用ifnull(field,0)来解决空值的问题，如果 field 不为空，就返回原值 ，如果为空则返回默认值 0

起别名：as 或 空格

消除重复行：distinct 后面跟多个 field 时，是联合查询消除重复 field



like 匹配：

- %  : 百分号，代表匹配零个或任意个字符。
- _   : 下划线，代表匹配1个任意字符。



区分大小写：  BINARY

查询空值不能使用 =null 而是使用 IS NULL

逻辑运算符包含逻辑与 AND，逻辑或 OR，逻辑非 NOT 【 NOT (job='CLERK')  \  !=  \  <> 】都代表NOT。



> **NOT运算符还可以和BETWEEN…AND、IN、LIKE、IS NULL一起使用，表示的含义分别为：**
>
> NOT BETWEEN .. AND .. :不在某个区间
>
> NOT IN (集合）：不在某个集合内
>
> NOT LIKE    ：不像.....
>
> IS NOT NULL:  不是空



排序: order by 

> - ASC表示按升序排序(默认值), DESC表示按降序排序。
> - ORDER BY 子句必须写在SELECT语句的最后
> - 可以同时按照多个列名进行排序  ORDER BY  deptno ASC, sal DESC;





连接的本质就是过滤掉或者避免产生无意义的两个表的组合数据。

> N 张表进行连接至少需要 N-1 个连接条件

多表连接分类：

- 按连接条件分：

  - 等值连接：等值连接就是对连接条件进行有效的等值判断。

  - 非等值连接

- 按其他连接方法分：

  - 外连接

  - 内连接



笛卡尔积，在数据库中表示将A表中每条记录与B表中的每条记录进行连接，连接后的查询结果就是笛卡尔积，也叫交叉连接。

> 在实际应用中，笛卡尔积本身大多没有什么实际用处，而且还有一个附加问题：产生一个巨表。
>
> - 笛卡尔积在下列情况产生：
>
> - 连接条件被省略
> - 连接条件是无效的
>
> - 为了避免笛卡尔积的产生，通常需要在 WHERE 子句中包含一个有效的连接条件



自连接：是一个表通过某种条件和本身进行连接的一种方式，就如同多个表连接一样。



外连接：

> - 在多表连接时，可以使用外部连接来查看没有匹配连接条件的数据行。
>
> - 左外连接以 LEFT OUTER JOIN 关键字左边的表为基表，该表所有行数据按照连接条件无论是否与右边表能匹配上，都会被显示出来。(右边匹配不上为 null)
> - 右外连接以RIGHT OUTER JOIN子句中的右边表为基表，该表所有行数据按照连接条件无论是否与左边表能匹配上，都会被显示出来。（左边匹配不上为 null）



分组查询

| **分组函数** | **含义** |
| ------------ | -------- |
| MAX          | 求最大值 |
| MIN          | 求最小值 |
| SUM          | 求和     |
| AVG          | 求平均值 |
| COUNT        | 求个数   |



```sql
SELECT    列名, 分组函数
FROM      表名
WHERE    条件表达式
ORDER BY 列名;
```



```sql
MIN( [ DISTINCT | ALL ] 列名 | 表达式 )
MAX( [ DISTINCT | ALL ] 列名 | 表达式 )
```



```sql
SUM( [ DISTINCT | ALL ] 列名 | 表达式 )
AVG( [ DISTINCT | ALL ] 列名 | 表达式 )
```



COUNT函数用来返回满足条件的每组记录个数，语法如下：

1. COUNT(*)：返回满足条件的每组记录个数。
2. COUNT( [ DISTINCT | ALL ] 列名 | 表达式 )：返回满足条件的每组**非空**记录个数。

说明：

**5个分组函数，除COUNT(\*)不忽略掉空值外，其余函数都是忽略掉空值再进行运算。**





SELECT 子句、FROM 子句、WHERE 子句、GROUP BY 子句、 HAVING 子句、ORDER BY 子句，书写直接按照此顺序就可以。那么这一条完整的 SELECT 子句发送到数据库服务器，执行顺序是如何的，可以通过案例来了解一下。

如下SQL语句：

```sql
SELECT    deptno,job,avg(sal) 
FROM      emp 
WHERE      job in ('SALESMAN','MANAGER','CLERK') 
GROUP BY  deptno,job 
HAVING avg(sal)>1000 
ORDER BY  3 DESC; 
```

**执行过程：**

1、通过 FROM 子句中找到需要查询的表；

2、通过 WHERE 子句进行非分组函数筛选判断；

3、通过 GROUP BY 子句完成分组操作；

4、通过HAVING子句完成组函数筛选判断；

5、通过SELECT子句选择显示的列或表达式及组函数；

6、通过ORDER BY子句进行排序操作。





分页查询：

```sql
SELECT 字段列表
FROM 数据源
LIMIT [start,]length;
```





## DDL（数据定义语言）

> 用来定义数据对象（数据库、表、字段）

### 数据库操作

```sql
show databases;
select database();
create database [ if not exists]  数据库名 [ default charset 字符集(utf8mb4) ] [collate 排序规则 ];
delete database [if exists] 数据库名;
use 数据库名;
```

### 表操作

```sql
select tables;
desc 表名;
show create table 表名; # 查询指定表的建表语句
```

#### 创建表的结构

```sql
CREATE TABLE 表名(
    字段1 字段1类型 [ COMMENT 字段1注释 ],
    字段2 字段2类型 [COMMENT 字段2注释 ],
    字段3 字段3类型 [COMMENT 字段3注释 ],
    ......
    字段n 字段n类型 [COMMENT 字段n注释 ]
) [ COMMENT 表注释 ] ;
```



#### 数据类型

- 数值类型：TINYINT、SMALLINT、MEDIUMINT、INT/INTRGRT、BIGINT、FLOAT、DOUBLE、DECIMAL
  - TINYINT UNSIGNED（不会出现负数）
  - DOUBLE(4,1):100.0
- 字符串类型：CHAR(1)、VARCHAR(90)、TINYBLOB、BLOB、TEXT、MEDIUMBLOB、MEDIUMTEXT、BIGBLOB、BIGTEXT;
  - CHAR：定长字符串，需要指定长度，最大255
  - VARCHAR：变长字符串，需要指定长度，最大65535
- 时间类型：DATE、TIME、YEAR、DATETIMR、TIMESTAMP



#### 修改表的结构

```sql
ALTER TABLE 表名 ADD 字段名 类型（长度） [ COMMENT 注释 ][ 约束 ];
ALTER TABLE　MODIFY 字段名 新数据类型（长度）;
ALTER TABLE 表名 CHANGE 旧字段名 新字段名 类型(长度) [ COMMENT 注释 ] [约束];
ALTER TABLE 表名 DROP 字段名;
ALTER TABLE 表名 RENAME TO 新表名;
```



```sql
DROP TABLE [IF EXISTS] 表名;
TRUNCATE TABLE 表名; # 删除并重建表
```



## DML 数据操作语言

> 对数据库中表的数据进行增、删、改操作
>
> - INSERT
> - UPDATE
> - DELETE



### 增

```sql
INSERT INTO 表名 (字段名1，字段名2，……) VALUES (值1，值2，……);
INSERT INTO 表名 VALUES (值1，值2，……); # 给全部字段添加数据
INSERT INTO 表名 VALUES (值1，值2，……),(值1，值2，……);
```



### 改

```sql
UPDATE 表名 SET 字段名1 = 值1, 字段名2 = 值2,…… [WHERE 条件]; 
```

> 注意事项：
>
> - 修改语句的条件可以有，也可以没有，如果没有条件，则会修改整张表的所有数据。



### 删

```SQL
DELETE FROM 表名 [WHERE 条件];
```

> 注意事项：
>
> - DELETE 语句的条件可以有，也可以没有，如果没有条件，则会删除整张表的所有数据。
> - DELETE 语句不能删除某一个字段的值(可以使用UPDATE，将该字段值置为NULL即可)。



## DQL 数据查询语言

> 用来查询数据库中表的记录
>
> - SELECT

编写顺序

```SQL
SELECT
	字段列表
FROM
	表名列表
WHERE
	条件列表
GROUP BY
	分组字段列表
HAVING
	分组后条件列表
ORDER BY
	排序字段列表
LIMIT
	分页参数
```

执行顺序

```SQL
FROM
	表名列表
WHERE
	条件列表
GROUP BY
	分组字段列表
HAVING
	分组后条件列表
SELECT
	字段列表
ORDER BY
	排序字段列表
LIMIT
	分页参数
```

> DQL语句的执行顺序为： from ... where ... group by ... having ... select ... order by ... limit ...

查询语句：

```SQL
SELECT 字段1，字段2，字段2，…… FROM 表名 WHERE 条件列表;
SELECT 字段1 [AS 别名1]，…… FROM 表名; # AS 可以省略
SELECT DISTINCT 字段列表 FROM 表名;
SELECT * FROM 表名; 
```

> 注意：
>
> *  **\*** 号代表查询所有字段，在实际开发中尽量少用（不直观、影响效率）。



### 条件

#### 比较运算符

| 比较运算符      | 功能                                       |
| --------------- | ------------------------------------------ |
| >               |                                            |
| >=              |                                            |
| <               |                                            |
| <=              |                                            |
| =               |                                            |
| <> / !=         |                                            |
| BETWEEN … AND … | 包含最大、最小                             |
| IN(…)           |                                            |
| LIKE 占位符     | 模糊匹配（_匹配单个字符、%匹配人一个字符） |
| IS NULL         |                                            |

#### 逻辑运算符

| 逻辑运算符 | 功能 |
| ---------- | ---- |
| AND / &&   |      |
| OR / \|\|  |      |
| NOT /!     |      |



### 聚合函数

> 将一列数据作为一个整体，进行纵向计算

| 函数  | 功能     |
| ----- | -------- |
| COUNT | 统计数量 |
| MAX   | 最大值   |
| MIN   | 最小值   |
| AVG   | 平均值   |
| SUM   | 求和     |

> 注意：
>
> - NULL 值是不参与所有的聚合函数运算的。

```SQL
SELECT 聚合函数(字段列表) FROM  表名;
```



### 分组查询

```SQL
SELECT 字段列表 FROM 表名 [WHERE 条件] GROUP BY 分组字段名 [HAVING 分组后过滤条件];
```

>  where与having区别
>
> - 执行时机不同：where是分组之前进行过滤，不满足where条件，不参与分组；而having是分组之后对结果进行过滤。
>
> - 判断条件不同：where不能对聚合函数进行判断，而having可以。

> 注意事项:
>
> -  分组之后，查询的字段一般为聚合函数和分组字段，查询其他字段无任何意义。
> - 执行顺序: where > 聚合函数 > having 。
>
> - 支持多字段分组, 具体语法为 : group by columnA,columnB



### 排序

```SQL
SELECT 字段列表 FROM 表名 ORDER BY 字段1 排序方式1， 字段2 排序方式2；
```

排序方式：

- ASC : 升序(默认值)

+ DESC: 降序

> 注意事项：
>
> - 如果是升序, 可以不指定排序方式ASC ;
> - 如果是多字段排序，当第一个字段值相同时，才会根据第二个字段进行排序 ;



### 分页查询

```SQL
SELECT 字段列表 FROM 表名 LIMIT 起始索引，查询记录数;
```

> 注意事项： 
>
> - 起始索引从0开始，起始索引 = （查询页码 - 1）* 每页显示记录数。
> - 分页查询是数据库的方言，不同的数据库有不同的实现，MySQL中是LIMIT。
> - 如果查询的是第一页数据，起始索引可以省略，直接简写为 limit 10。



## DCL 数据控制语言

> 用来管理数据库用户、控制数据库的访问权限

```SQL
SELECT * FROM MYSQL.USER; # 查询用户
CREATE USER '用户名'@'主机名' IDENTIFIED BY '密码';
ALTER USER '用户名'@'主机名' IDENTIFIED WITH mysql_native_password BY '新密码' ;
DROP USER '用户名'@'主机名' ;
```

> 注意事项:
>
> - 在MySQL中需要通过用户名@主机名的方式，来唯一标识一个用户。
> - 主机名可以使用 % 通配。
> - 这类SQL开发人员操作的比较少，主要是DBA（ Database Administrator 数据库管理员）使用。

权限分类

| 权限              | 说明               |
| ----------------- | ------------------ |
| ALL,ALL PRIVLEGES | 所有权限           |
| SELECT            | 查询数据           |
| INSERT            | 插入数据           |
| UPDATE            | 修改数据           |
| DELETE            | 删除数据           |
| ALTER             | 修改表             |
| DROP              | 删除数据库/视图/表 |
| CREATE            | 创建数据库/表      |



 ```SQL
 SHOW GRANRS FOR '用户名'@'主机名';
 GRANT 权限列表 ON  数据库名.表名 TO '用户名'@'主机名';
 REVOKE 权限列表 ON 数据库名.表名 TO '用户名'@'主机名';
 ```

> 注意事项：
>
> - 多个权限之间，使用逗号分隔
> - 授权时， 数据库名和表名可以使用 * 进行通配，代表所有。



## 函数

### 字符串函数

| 函数                     | 功能                                                    |
| ------------------------ | ------------------------------------------------------- |
| CONCAT(S1,S2,…,Sn)       | 字符串拼接                                              |
| LOWER(str)               | 将字符串 str 全部转为小写                               |
| UPPER(str)               | 转大写                                                  |
| LPAD(STR,N,PAD)          | 左填充，用字符串pad对str的左边进行填充，达到n个字符长度 |
| RPAD(str,n,pad)          | 右填充，用字符串pad对str的右边进行填充，达到n个字符长度 |
| TRIM(str)                | 去掉字符串头部和尾部的空格                              |
| SUBSTRING(str,start,len) | 返回从字符串str从start位置起的len个长度的字符串         |



### 数值函数

| 函数       | 功能                                   |
| ---------- | -------------------------------------- |
| CEIL(X)    | 向上取整                               |
| FLOOR(X)   | 向下取整                               |
| MOD(X,Y)   | 返回 x/y 的模                          |
| RAND()     | 返回 0~1 内的随机数                    |
| ROUND(X,Y) | 求参数 x 的四舍五入的值，保留 y 位小数 |



### 日期函数

| 函数                           | 功能                                                |
| ------------------------------ | --------------------------------------------------- |
| CURDATE()                      | 返回当前日期                                        |
| CURTIME()                      | 返回当前时间                                        |
| NOW()                          | 返回当前的日期和时间                                |
| YEAR(date)                     | 获取指定 date 的年份                                |
| MINTH(date)                    |                                                     |
| DAY(date)                      |                                                     |
| DATE_ADD(date, INTER,exprtype) | 返回一个日期/时间值加上一个时间间隔 expr 后的时间值 |
| DATEDIFF(date1,date2)          | 返回其实时间 date1 和 结束时间 date2 之间的天数     |



### 流程函数

| 函数                                                         | 功能                                                       |
| ------------------------------------------------------------ | ---------------------------------------------------------- |
| IF(value , t , f)                                            | 如果value为true，则返回t，否则返回f                        |
| IFNULL(value1 , value2)                                      | 如果value1不为空，返回value1，否则返回value2               |
| CASE WHEN [ val1 ] THEN [res1] ... ELSE [ default ] END      | 如果val1为true，返回res1，... 否                           |
| CASE [ expr ] WHEN [ val1 ] THEN [res1] ... ELSE [ default ] END | 如果expr的值等于val1，返回 res1，... 否则返回default默认值 |



## 约束

> 概念：约束是作用于表中字段上的规则，用于限制存储在表中的数据。
>
> 目的：保证数据库中数据的正确、有效性和完整性。

分类：

| 约束                       | 描述                                                     | 关键字      |
| -------------------------- | -------------------------------------------------------- | ----------- |
| 非空约束                   | 限制该字段的数据不能为null                               | NOT NULL    |
| 唯一约束                   | 保证该字段的所有数据都是唯一、不重复的                   | UNIQUE      |
| 主键约束                   | 主键是一行数据的唯一标识，要求非空且唯一                 | PRIMARY KEY |
| 默认约束                   | 保存数据时，如果未指定该字段的值，则采用默认值           | DEFAULT     |
| 检查约束（8.0.16版本之后） | 保证字段值满足某一个条件                                 | CHECK       |
| 外键约束                   | 用来让两张表的数据之间建立连接，保证数据的一致性和完整性 | FOREIGN KEY |

> 注意：
>
> - 约束是作用于表中字段上的，可以在创建表/修改表的时候添加约束。
> - 在为字段添加约束时，只需要在字段之后加上约束的关键字即可



增加外键

```SQL
[CONSTRAINT] [外键名称] FOREIGN KEY (外键字段名) REFERENCES 主表 (主表列名)
---------
ALTER TABLE 表名 ADD CONSTRAINT 外键名称 FOREIGN KEY (外键字段名) REFERENCES 主表 (主表列名) ;
```



删除外键

```SQL
ALTER TABLE 表名 DROP FOREIGN KEY 外键名称;
```





## 多表查询

- 一对一：在任意一方加入外键，关联另外一方的主键，并且设置外键为唯一的(UNIQUE)
- 一对多：在多的一方建立外键，指向另一方的主键。
- 多对多：建立第三张中间表，中间表至少包含两个外键，分别关联两方主键

> 会出现的问题：
>
> 笛卡尔积：笛卡尔乘积是指在数学中，两个集合 A 集合 和 B 集合的所有组合情况。在多表查询中，需要消除无效的笛卡尔积的，只保留两张表关联部分的数据。（给多表查询加上连接查询的条件即可消除笛卡尔积）

连接查询

- 内连接：相当于查询两张表交集部分数据。分为： 隐式内连接、显式内连接。
  - 如果某一行在其中一个表中有匹配而在另一个表中没有，则该行不会出现在结果集中。

- 外连接：
  - 外连接不仅返回满足连接条件的记录，还会返回某个表中不匹配的记录，并用 NULL 填充另一侧表的字段。
- 左外连接：查询左表所有数据，以及两张表交集部分数据
- 右外连接：查询右表所有数据，以及两张表交集部分数据
- 自连接：当前表与自身的连接查询，自连接必须使用表别名

子查询



### 连接查询



#### 内连接

```SQL
SELECT 字段列表 FROM 表1，表2 WHERE 条件…;
# 显示内连接
SELECT 字段列表 FROM 表1 [INNER] JOIN 表2 ON  连接条件…；
```



#### 外连接

```SQL
# 左外连接
SELECT 字段列表 FROM 表1 LEFT [OUTER] JOIN 表2 ON 条件;
# 右外连接
SELECT 字段列表 FROM 表1 RIGHT [OUTER] JOIN 表2 ON 条件;
```

> 左外连接和右外连接是可以相互替换的，只需要调整在连接查询时 SQL 中表的先后顺序就可以了。而在日常开发使用时，更偏向于左外连接。



#### 自连接

顾名思义，就是自己连接自己，也就是把一张表连接查询多次

```SQL
SELECT 字段列表 FROM 表A 别名A JOIN 表A 别名B ON 条件 ... ;
```

> 注意：
>
> - 在自连接查询中，必须要为表起别名，要不然我们不清楚所指定的条件、返回的字段，到底是哪一张表的字段。



#### 联合查询

对于 union 查询，就是把多次查询的结果合并起来，形成一个新的查询结果集。

> 先查询出来，在合并成一个结果集

```SQL
SELECT 字段列表 FROM 表A ...
UNION [ ALL ]
SELECT 字段列表 FROM 表B ....;
```

- 对于联合查询的多张表的列数必须保持一致，字段类型也需要保持一致。
- **UNION**：合并两个或多个 SELECT 语句的结果，并且自动去除重复行。
- **UNION ALL**：合并两个或多个 SELECT 语句的结果，并且保留所有行，包括重复行。



### 子查询

> SQL语句中嵌套SELECT语句，称为嵌套查询，又称子查询。
>
> - 子查询外部的语句可以是 INSERT / UPDATE / DELETE / SELECT 的任何一个。

```SQL
SELECT * FROM t1 WHERE column1 = ( SELECT column1 FROM t2 );
```

根据子查询结果不同，分为：

A. 标量子查询（子查询结果为单个值）

B. 列子查询(子查询结果为一列)

| 操作符 | 描述                                        |
| ------ | ------------------------------------------- |
| IN     | 在指定的集合范围之内，多选一                |
| NOT IN | 不在指定集合范围之内                        |
| ANY    | 子查询返回列表中，有任意一个满足即可        |
| SOME   | 与 ANY 等同，使用 SOME 的地方都可以使用 ANY |
| ALL    | 子查询返回列表的所有值都必须满足            |

C. 行子查询(子查询结果为一行)

D. 表子查询(子查询结果为多行多列)



根据子查询位置，分为：

A. WHERE 之后

B. FROM 之后

C. SELECT 之后



## 视图

**视图：**是一种虚拟存在的表。视图中的数据并不在数据库中实际存在，行和列数据来自定义视图的查询中使用的表，并且是在使用视图时动态生成的。

> 通俗的讲，视图只保存了查询的 SQL 逻辑，不保存查询结果。

```SQL
CREATE [OR REPLACE] VIEW 视图名称[(列名列表)] AS SELECT语句 [ WITH [CASCADED | LOCAL ] CHECK OPTION ]

SHOW CREATE VIEW 视图名称; # 查看创建视图语句
SELECT * FROM 视图名称 ...... ; # 查看视图数据

```

修改视图：

```SQL
CREATE [OR REPLACE] VIEW 视图名称[(列名列表)] AS SELECT语句 [ WITH [ CASCADED | LOCAL ] CHECK OPTION ];

ALTER VIEW 视图名称[(列名列表)] AS SELECT语句 [ WITH [ CASCADED |
LOCAL ] CHECK OPTION ];
```



删除视图

```SQL
DROP VIEW [IF EXISTS] 视图名称 [,视图名称] ...
```



> 对视图的操作会影响原表
>
> 如果定义视图时，如果指定了条件，然后在插入、修改、删除数据时，是否可以做到必须满足条件才能操作，否则不能够操作呢？ 答案是可以的，这就需要借助于视图的检查选项了。



### 检查选项

当使用`WITH CHECK OPTION`子句创建视图时，MySQL 会通过视图检查正在更改的每个行，例如 插入，更新，删除，以使其符合视图的定义。 MySQL 允许基于另一个视图创建视图，它还会检查依赖视图中的规则以保持一致性。为了确定检查的范围，MySQL 提供了两个选项： CASCADED 和 LOCAL，默认值为 CASCADED 。

#### CASCADED

级联。

比如，v2 视图是基于 v1 视图的，如果在 v2 视图创建的时候指定了检查选项为 cascaded，但是 v1 视图创建时未指定检查选项。 则在执行检查时，不仅会检查 v2，还**会级联检查 v2 的关联视图 v1**。

```SQL
create view v1 as select id,name from user where id <= 20;
create view v2 as select * from v1 where if >= 10 with cascaded check option;
```



####  LOCAL

本地。

比如，v2 视图是基于 v1 视图的，如果在 v2 视图创建的时候指定了检查选项为 local ，但是 v1 视图创建时未指定检查选项。 则在执行检查时，只会检查 v2，**不会检查 v2 的关联视图 v1**。

```SQL
create view v1 as select id,name from user where id <= 20;
create view v2 as select * from v1 where if >= 10 with local check option;
```



### 视图的更新

要使视图可更新，视图中的行与基础表中的行之间必须存在一对一的关系。如果视图包含以下任何一项，则该视图不可更新：

- 聚合函数或窗口函数（SUM()、 MIN()、 MAX()、 COUNT()等）
- DISTINCT
- GROUP BY
- HAVING
- UNION 或者 UNION ALL



### 视图的作用

> - 简单：视图不仅可以简化用户对数据的理解，也可以简化他们的操作。那些被经常使用的查询可以被定义为视图，从而使得用户不必为以后的操作每次指定全部的条件。
>
> - 安全：数据库可以授权，但不能授权到数据库特定行和特定的列上。通过视图用户只能查询和修改他们所能见到的数据
>
> - 数据独立：视图可帮助用户屏蔽真实表结构变化带来的影响。





