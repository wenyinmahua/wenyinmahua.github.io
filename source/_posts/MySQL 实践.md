---
title: MySQL 实践
date: 2023-05-23
updated: 2023-06-10
comments: true
category: MySQL
---

启动MySQL服务，登录，查看数据库，数据库里面有表，查看表的内容。
**DBA：DataBaseAdministrator：数据库管理员**

增删改查，又叫crud，crud时在公司程序员之间沟通的术语，一般很少说增删改查
C：Create（增）
R：Retrive（查，检索）
U：update（改）
D：Delete（删 ）

# 一、数据库概论

**数据库：** **D**ata**B**ase,简称DB。按照一定格式存储数据的一些文件的组合。（数据仓库）
顾名思义，就是存放数据的仓库，实际上就是一堆文件，这些文件存储了具有特定格式的数据。

**数据库管理系统：** **D**ata**B**ase**M**abagement **S**ystem，简称DBMS
数据库管理系统是专门用来管理数据库中的数据，它可以对数据库当中的数据进行增删改查。
常见的数据库管理系统有MySQL，Oracle、MS SQLserver、DB2、sybase等等

**SQL：**（**S**tructured **Q**uery **L**anguage，简称SQL）结构化查询语言

> - SQL语言是操作关系型数据库的编程语言，程序员需要学习SQL语句，程序员通过编写SQL，然后DBM负责执行SQL语句，最终来完成数据库中数据的增删改查。
> - SQL是一套标准，程序员主要学习的是SQL语句。
> - SQL语句可以单行或多行书写，以分号结尾。
> - SQL语句可以使用空格/缩进来增强语句的可读性。
> - MySQL数据库的SQL语句不区分大小写。
> - 注释：
>   - 单行注释：-- 注释内容   或   # 注释内容(MySQL特有)
>   - 多行注释： /* 注释内容 */

**三者之间的关系：**
DBMS---执行---> SQL ---操作---> DB

MySQL下载地址： http://downloads.mysql.com/archives/community/ 



## 1.MySQL安装

**关系型数据库（RDBMS）**：建立在关系模型基础上，由多张相互连接的**二维表**组成的数据库。

**端口号：**端口号port是任何一个软件/应用都会有的，端口号是应用的唯一代表。
端口号通常和IP地址在一块，IP地址用定位计算机的，端口号port是用来定位计算机上的某个服务/应用的
在同一台计算机上，端口号不能重复，具有唯一性。

**字符编码方式**MySQL数据库的字符编码方式为UTF8。
**服务名称**：MySQL
MySQL的超级管理用户名，一定是root
MySQL数据库超级管理员的密码：自己设计
设置密码的同时，可以激活root账户远程访问，激活后可以在外地访问

一个数据库服务器中可以创建多个数据库，一个数据库中也可以包含多张表，而一张表中又可以包含多行记录。



## 2.MySQL卸载

第一步：双击安装包卸载，安装包在E盘download，按remove，不用管，ok，
第二步：删除目录C:\Program Files\MySQL
			   删除目录C:\ProgramData\MySQL（查看-->显示-->显示隐藏项目名--才能找到）



## 3.MySQL服务的启动与停止

使用DOS命令 ：（需要管理员权限C:\Windows\System32下的cmd.exe，单击右键以管理员的身份运行）
			net  stop MySQL：关闭MySQL服务
			net  start MySQL：启动MySQL服务



## 4.MySQL语句

**命令不区分大小写，不见分号不执行**

**登陆命令：**`mysql -uroot -pmima`			`mysql -uroot -p（隐藏密码登录）`

```
mysql -u用户名 -p密码 [-h数据库服务器的IP地址 -P端口号]
```

>-h  参数不加，默认连接的是本地 127.0.0.1 的MySQL服务器
>
>-P  参数不加，默认连接的端口号是 3306

**退出命令：**`exit`，`quit`，`\q;`
**查看数据库：**`show databases;` 	注意以英文符号分号结尾
**选择使用的数据库：**`use 数据库名;`
**创建数据库：**`create database 数据库名;`
**删除数据库：** `drop  database  数据库名称;`
**查看某个数据库的表：**`show tables;`		必须使用该数据库
**导入数据：**`source SQL文件所在位置;`           （直接拖入到MySQL命令框中）**注意：**路径不能有中文
**查看表中数据：** `select * from 表名(查看的是所有的数据);`
			  `select 字段名 from 表名;`查看该表中的某一列（字段）数据；
**查看表的结构：**`desc 表名;`                不会查看数据      describe：描述，即表头信息
**查看数据库的版本号：** `select version();`
**查看当前使用的是哪个数据库：**`select database();`
**终止一条SQL语句：**输入   `\c    然后回车`

 MySQL自带四个数据库
数据库中最基本的单元是表：table
数据库当中是以表格的形式表示数据，因为表比较直观。



## 5.数据库中最基本的单元

**数据库中最基本的单元是表**：table
数据库当中是以表格的形式表示数据，因为表比较直观。

任何一张表中都有行(row)和列(colum)
主键：表的唯一标识
行：被称为数据/记录，一行记录就是对某个对象一条完整的记录
列：被称为字段，每一个字段都有：字段名、数据类型、约束、字段长度等属性；

**数据类型**有：int、varchar（字符串类型）、double、date（日期）、datetime等。是字符串、数字、日期等
**约束：**约束有很多，有非空约束、唯一性约束、主键约束、外键约束等。
**字段和数据（字面量/值）**的关系相当于 变量和变量值之间的关系。
**NULL：**不是一个值，什么也没有。

**NULL：**不是一个值，什么也没有。



## 6.SQL语句分类

> - **DQL：**数据查询语言（凡是带select关键字的都是查询语句）          **Data Qurey Language**
> - **DML：**数据操作语言（凡是对表当中的数据进行增删改的都是DML），这个操作主要是表的数据data
>   			insert增、delete删、update改；                  **Data Manipulation Language**
> - **DDL：**数据定义语句（凡是带有create(新建)、drop(删除)、alter(修改)的都是DDL。  **Data Definition Language**
>   - 这里的增删改和DML不同，这个主要是正对表结构进行操作。
> - **TCL：**事务控制语言，包括：事务提交（commit）、事务回滚（rollback）   **Transactional Comtrol Language**
> - **DCL：**数据控制语言，有授权（grant）、撤销权限（revoke）        **Data Control Language**



## 7. 导入数据 .sql文件

选择数据库之后，`source SQL文件所在位置；`    （也可以直接拖入到MySQL命令框中）**注意：**路径不能有中文



## 8. 命名规范：

所有的标识符的都是全部小写，单词和单词之间使用下划线进行连接。



## 9. 执行SQL脚本：source 脚本位置

脚本文件中写的是对数据库进行操作的命令。



## 10. 数据库优化阶段

- 通过数据库的优化来提高数据库的访问性能。优化手段：索引、SQL优化、分库分表等

# 二、简单查询语句DQL

**DQL** 英文全称是 Data Query Language (数据查询语言)，用来查询数据库表中的记录。

## 1.查询：select

**查询一个字段**

```mysql
select 字段名  from  表名;
```

**注意：**select和from都是关键字；表名和字段名都是标识符。
**强调：**对于SQL语句都是通用的，所有的SQL语句都是以分号为结尾的；SQL语句不区分大小写

当查找的字段名没有时会报错；
当查找的字面量没有时，会打印与表相同行数的字面量（数据的值是指定字面量），同时该列的字段也是字面量
**字面量：**字段对应的数据的统称；

**查询多个字段**

```mysql
select 字段1, 字段2, 字段3 from  表名;
```

**注意：**字段名之间使用逗号隔开

**查询所有的字段**

方法一：把每个字段名都写上，使用逗号分隔；

```mysql
select a,b,c,d...... from tablenname;
```

方法二：可以使用*；

```mysql
select	*	from	tablename；
```

方法二缺点：

1. 效率低；
2. 可读性差
   在开发者不建议使用，因为在开发中的表相当大，但是自己玩没问题

**给查询列起别名**：as

```mysql
select 字段1 as 别名1, 字段2 as 别名2 from  表名;  # as可以省略
select 字段1 别名1, 字段2 别名2 from  表名; 
```

**注意：**只是将现实的查询结果列名显示为修改后的名，并没有把原表的列名修改
**记住：**select语句永远都不会进行修改操作，因为select是查询语句
**附：**as可以使用空格代替，也有起别名的作用：**select	字段名	新名	from	tablename;**
当查询的名字有空格时，可以使用**单引号**括起来，不然会报错，必须使用**单引号**！！！！！**单引号**！！！！！

**去除重复记录**：distinct

~~~mysql
select distinct 字段列表 from  表名;
~~~

**数字类型的字段的操作：**加减乘除

```mysql
select	字段名*12	from	tablename;
得到的是该字段的值*12后的值，该字段可以进行加减乘除等操作；
```



## 2.条件查询：where：in、like

**条件查询：**查询出复合条件的数据
**语法：**

```sql
select 字段1,字段2,字段3.... from 表名 where 条件;
```

**具体的条件：**

常用的比较运算符如下: 

| **比较运算符**       | **功能**                                 |
| -------------------- | ---------------------------------------- |
| >                    | 大于                                     |
| >=                   | 大于等于                                 |
| <                    | 小于                                     |
| <=                   | 小于等于                                 |
| =                    | 等于                                     |
| <> 或 !=             | 不等于                                   |
| between ...  and ... | 在某个范围之内(含最小、最大值)           |
| in(...)              | 在in之后的列表中的值，多选一             |
| like 占位符          | 模糊匹配(_匹配单个字符, %匹配任意个字符) |
| is null              | 是null                                   |

常用的逻辑运算符如下:

| **逻辑运算符** | **功能**                    |
| -------------- | --------------------------- |
| and 或 &&      | 并且 (多个条件同时成立)     |
| or 或 \|\|     | 或者 (多个条件任意一个成立) |
| not 或 !       | 非 , 不是                   |



> - 使用between必须遵循`左小右大`between and是闭区间，包括两端的值;
> - 在数据库当中null不能使用等号进行衡量，需要使用的是 is null;
> - and和or同时出现，and优先级比or高，如果想让and先执行，可以加上小括号；



**in：**

```mysql
select * from tablename where 字段 in（具体的值1，具体的值2，具体的值3....）;
```

- in后面跟的是具体的值，不是区间。



**like:**模糊查询

> %和_都是特殊符号

```java
select 字段名 from tablename where 字段名 like '%D%';
```

>- '%D%'：模糊查找字段中含有D的数据
>- '%D'：模糊查找字段以D结尾的数据
>- 'D%'：模糊查找字段以D开头的数据。
>
>

**模糊匹配下划线语法：**

```mysql
select	字段名	from	tablename	where	字段名	like	'_D%';
```

> like后面的'_D%'中，是查找第二个字符为D的数据
> 有几个下划线就查找第（几+1）个字符为“？”的数据

如何查询带下划线的数据:

```mysql
select	字段名	from	tablename	where	字段名	like	'%\_%';  # 其中\为转义字符
```



## 3.排序:order by

排序方式：

- ASC ：升序（默认值）

- DESC：降序

**3.1单字段排序：**

排序语句：

```mysql
select 字段名组合 from tablename order by 字段名;    # 默认的是升序排序；
```

降序排序：

```mysql
select 字段名组合 from tablename	order by 字段名 desc；
```

升序排序：

```mysql
select	字段名组合	from	tablename	order	by	字段名	asc；
```



**3.2多字段排序：**

```mysql
select  字段列表  
from   表名   
[where  条件列表] 
[group by  分组字段 ] 
order  by  字段1  排序方式1 , 字段2  排序方式2 … ;
```

**规则：**字段1在前，起主导作用，只有当字段1相等时，才会启动字段2的排序。

> 注意事项：如果是多字段排序，当第一个字段值相同时，才会根据第二个字段进行排序 



**3.3根据字段的位置进行排序**

解释：就是将该字段所在列进行排序

即对选择的字段组合的第二列（第二个字段）的数据进行排序

```mysql
select	字段名组合	from	tablename	order	by	2;
```


不建议在开发者使用，不健壮。

**3.4选择合适的范围进行排序**

**截取该字段复合某范围的数据进行排序**
**语法：**

```mysql
select 字段组合 from tablename where 截取的字段 between 区间值1 and 区间值2 order by 排序的字段
```


执行的顺序：1.from	2.where	3.select	4.order by（排序总是在最后执行）

## 4.单行处理函数

单行处理函数、数据处理函数

单行处理函数：是一行一行处理的
**特点：**一个输入对应一个输出。
和它相对的是多行处理函数，多个输入对应一个输出
**使用方法：**

```java
select 单行处理函数（操作对象） from dataname;
```

**常见的单行处理函数**

**case 表达式 when 值1 then 结果1  when 值2  then  结果2 ...  else  result  end：当什么时怎么样**

```mysql 
select case 字段名 when '字面量' then 对字面量的操作。

select (case   字段    
		when   值1   then  结果1   
		[when 值2  then  结果2 ...]     
		[else result]     
		end) AS 统一字段名称,
		count(*) AS 人数
from tablename
group by 字段 
```

```mysql
select (case job
             when 1 then '班主任'
             when 2 then '讲师'
             when 3 then '学工主管'
             when 4 then '教研主管'
             else '未分配职位'
        end) AS 职位 ,
       count(*) AS 人数
from tb_emp
group by job;
```

**if(条件表达式, true取值 , false取值)**

```mysql
-- if(条件表达式, true取值 , false取值)
select if(gender=1,'男性员工','女性员工') AS 性别, count(*) AS 人数
from tb_emp
group by gender;
```

> if(表达式, tvalue, fvalue) ：当表达式为true时，取值tvalue；当表达式为false时，取值fvalue

![1674052927356](C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1674052927356.png)

![1674052941376](C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1674052941376.png)

附：concate(字符串1，字符串2)函数：进行字符串的拼接
**首字母转换为大写使用：**select  concate(upper(substr(name,1,1)),substr(name,2,length(name)-1))，后面的length函数可以省略。为什么-1呢？因为第三个参数是截取的长度，当首字母别截取后，字符串长度不变，但是必须-1才能截取到恰当的长度。

- 使用方法：**select  函数名(字段名),函数名(字段名)... from tablename;**可以通过取别名来修改表头显示的信息
- substr(被截取的字符串（字段名）,起始下标，截取的长度)，起始下标是从1开始的，截取的是对应字段的数据的长度。
- round(数字，保留的小数位):四舍五入，当是负数时就是保留的整数位；正往右进，负往左进。
- rand()：生成0-1的随机数，生成1-100的随机整数：round(rand()*100,0);
- ifnull:空处理函数	**select	ifnull(数据，被当作的值)    from   dataname;**
  所有的数据库中，只要有NULL参数参与的数学运算，结果都是NULL；为了避免这个现象，因此使用ifnull的值；
- trim：去首尾的空格，不能去之间的空格：    where job =trim('mamager        ');
- str_to_date:将字符串varchar类型转换为date类型           语法：**str_to_date('字符串格式','日期格式')；**，详细见数据类型date。
- date_format:将date类型转换为具有一定格式的varchar字符串类型。语法：**date_format(日期类型数据,'日期格式')，即date_format(表示日期的字段名,'%d-%m-%Y')**          注意：日期类型数据不能加上引号**。
  如select name,date_format(birth,'%d-%m-%Y') from t_birth;

## 5.聚合函数

多行处理函数、分组函数、聚合函数

多行处理函数的特点：输入多行、最终输出一行

> **注意：**
>
> - 分组函数在使用的时候，必须先进行分组，然后才能用  ,如果没有对数据分组，整个表就会当成一组
> - 分组函数自动忽略NULL；不需要提前对NULL进行处理；
> - 分组函数不能够直接使用在where语句中；
> - 所有的分组函数可以组合起来使用

常用聚合函数：

| **函数** | **功能** |
| -------- | -------- |
| count    | 统计数量 |
| max      | 最大值   |
| min      | 最小值   |
| avg      | 平均值   |
| sum      | 求和     |

> count ：按照列去统计有多少行数据。
>
> - 在根据指定的列统计的时候，如果这一列中有null的行，该行不会被统计在其中。
>
> sum ：计算指定列的数值和，如果不是数值类型，那么计算结果为0
>
> max ：计算指定列的最大值
>
> min ：计算指定列的最小值
>
> avg ：计算指定列的平均值

count(\*) 和 count(字段) 的区别：
	count(\*) ：统计表中的行数（只要有一行数据不全为空，那么 count++ ）
	count(字段) ：统计该字段下所有不为 NULL 的元素的总数。

## 6.分组查询

### 1.分组查询 GROUP BY

需要先分组然后对每一组的数据进行操作，这个时候使用分组查询。

分组： 按照某一列或者某几列，把相同的数据进行合并输出。

> 分组其实就是按列进行分类(指定列下相同的数据归为一类)，然后可以对分类完的数据进行合并计算。
>
> 分组查询通常会使用聚合函数进行计算。

**语法：**

```sql
select  字段列表  from  表名  [where 条件]  group by 分组字段名  [having 分组后过滤条件];
```

```mysql
select job, count(*)
from tb_emp
where entrydate <= '2015-01-01'   -- 分组前条件
group by job                      -- 按照job字段分组,job字段下相同数的据为一组
having count(*) >= 2;             -- 分组后条件
```



### 2.执行顺序

语法：

```sql
SELECT 字段名 FROM TABLENAME WHERE... GROUP BY... ORDER BY... 
执行顺序如下：
1.FROM选择表
2.where选择表中符合条件的数据
3.group by 选择分组
4.select	查询
5.order by	排序输出
在select执行的时候 group by 已经执行了，没有写 group by的话，分组得到的将是整个表
 *******这就是为什么分组函数不能写在where后面，因为还没有分组，没有分组就不能使用分组函数。
 不能在where后面使用分组函数并不是不能使用where
```

在一条 select 语句中，如果有 group by 语句的话，select 后面只能跟：参加分组的字段和分组函数，其他一律不能跟，oracle 会报错，MySQL 会输出无意义的数据。



### 3.having语句

使用having语句可以分组之后的语句进一步过滤。**having只是起了一个过滤作用，使选择分组的字段要达到某个条件才能显示出来。**

having不能单独使用，having不能代替where，having必须和group by 联合使用

语法：

```mysql
 select 字段名 from tablename group by 字段名 having 过滤条件;
```

where效率比having高，优先选择where，where完成不了的再选择having

> 注意事项:
>
> ​	• 分组之后，查询的字段一般为聚合函数和分组字段，查询其他字段无任何意义
>
> ​	• 执行顺序：where > 聚合函数 > having 



> **where与having区别**
>
> - 执行时机不同：where是分组之前进行过滤，不满足where条件，不参与分组；而having是分组之后对结果进行过滤。
> - 判断条件不同：where不能对聚合函数进行判断，而having可以。



## 7.总结（一）

语法：

```mysql
select
	字段名
from
	tablename
where
	条件
group by 
	需要分组的字段
having
	分组后需要过滤的字段
order by
	选择字段对查询后的结果进行排序；
********************************************************以上关键字只能按这个顺序来，不能颠倒
```

执行过程：

```mysql
1.from														从某张表中查询数据，
2.where														先经过where条件栓选出有价值的数据，
3.group by													对这些有价值的数据进行分组，
4.having													分组之后可以使用having继续筛选；
5.select													select查询出来
6.order by													最后排序输出；
```



## 8.查询结果去除：distinct

**distinct：**把查询结果去重，distinct前面不能出现字段名，因此distinct只能会出现在所有的字段前面

```mysql
select distinct 字段名组合 from tablename;
```



## 9.连接查询

### 9.1概念

**连接查询：**也叫跨表查询，需要关联多个表进行查询。

### 9.2连接查询的分类

- 按照语法的年代分类：SQL92、SQL99
- 根据表连接的方式分类：
  			**内连接：**等值连接、非等值连接、自链接
        			**外连接：**左外连接（左连接）、右外连接（右连接）
        			**全连接：**不常用

### 9.3笛卡尔积现象

select  字段1，字段2  form  表1，表2		得到的记录的数目是两个表数据数目的乘积
当两张表进行连接查询，没有任何条件限制的时候，最终查询结果条数，是两张表条数的乘积，也就是笛卡尔积现象

#### 怎么避免笛卡尔积？

连接时附加条件，将满足这个条件的记录被筛选出来！（根据这个条件进行匹配）
语法一：**select  字段1，字段2  from  表1，表2   where  表1.字段名3 = 表2.字段名3;**
注：字段1、字段二都要从表1，表2中查找一次，效率较低，表1.字段名3 = 表2.字段名3; 字段3是表1和表2共同拥有的
这种在匹配的过程中，**匹配的次数并没有减少。**

**注意：**加条件只是为了避免笛卡尔积现象，只是为了查询出有效的组合记录。
匹配的次数一次都没有减少。

![1674222628126](C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1674222628126.png)

语法二：可以提高效率，就是不用在两张表里面查找位置的字段。

```sql
select
	e.ename,d.dname
from
	emp e,dept d			//起别名
where
	e.deptno = p.deptno;     //SQL92语法
	//这种SQL92语法在进一步筛选的时候，会出现结构不清晰的情况，如下：
where
	e.deptno = p.deptno and…(进行下一步筛选);//显而易见，这里的表连接和后继筛选的条件放在一起，结构不清晰，用SQL99语法解决

#SQL99语法是两张表使用join连接
```

**注意：**通过笛卡尔积现象可以得出，表的连接次数越多效率越低，尽量避免表的连接次数。



## 10.内连接    join on

内连接的特点：将完全能够匹配连接条件的数据查询出来，不匹配的数据将不会显示。



### 10.1等值连接：=

SQL99语法有点：表连接的条件是独立的，连接之后，如果还需要进行进一步筛选，再往后继续添加where语句

```sql
select
	……
from
	a
(inner //内部，可以省略//) join       //带上inner可读性更好，一眼就可以看出来是内连接
	b
on
	a和b的连接条件         a.deptno = b.deptno //因为条件是等量的，因此称为等值连接
```



### 10.2非等值连接  between and

```SQL
SELECT
	T1.字段名,	T2.字段名
FROM 
	TABLE1 T1
JOIN
	TABLE2 T2
ON
	字段名	
BETWEEN	T2.条件1（字段名1）	AND		T2.条件2（字段名2）（连接条件);
	
 如：select t2.grade,t1.ename,t1.sal,t2.grade from  emp t1 join salgrade t2 on t1.sal between t2.losal and t2.hisal;
```

如上，条件不是一个等价关系，称为非等值连接。



### 10.3自连接

一张表堪称两张表进行连接。

```mysql
select
	a.ename as '员工名',b.ename as '领导名' 
from
	emp a join emp b
on 
	a.mgr = b.empno;
```

![1675933784136](C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1675933784136.png)



## 11.外连接 left/right  （outer）join

将主表的数据全部选出来

右外连接：right join

```mysql
select a.name,b.name from a right join b on a.字段 = b.字段;
```

right：表示将join关键字右边的表b看成主表，主要是为了将表b的数据全部查询出来，捎带着关联查询左边的表a.

在外连接中，两张表在连接中形成了主次关系。

左外连接：left join

外连接的查询结果条数一定是大约等于内连接的查询结果条数。

### 如何使用内外连接

如果两个表都是平等的，那就使用内连接，如果煮茶其中的一张表，另一张表是捎带查的，就是要外连接
如查找员工的上司：主要查找的是员工表，捎带查的是他的领导，有些员工就没有了领导了，这时使用内连接就不会显示该员工的信息 



## 12.多张表进行连接

语法：

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

一条SQL语句中内连接和外连接可以混合出现。



## 13.子查询语句

子查询：select语句中嵌套select语句，被嵌套的select语句称为子查询。

语法：

```mysql
select
	..(select)..
from
	..(select)..
where
	..(select)..
```

**where中的子查询：**select sal rom emp where sal > (select min(sal) from emp);
**from中的子查询：**select  * from (select ...) as newtablename;
**注意：**from后面的子查询，可以将子查询的查询结果当作一张临时表，必须给from后面的的总查询表起个别名
select t.*,s.grade from
	**(select job,avg(sal) as avgsal from emp group by job) as t**
 join salgrade s on t.avgsal between s.losal and s.hisal;



## 14.union合并查询集

```mysql
原：select ename,job from emp where job in("manager","salesman");
/union：
select ename,job from emp where job = 'manager'
union
select ename,job from emp where job = 'salesman';
#两者都是查询，union就是将两次查询的结果合并成一张表。union效率更高一些。
对于表连接来说，每一次连接新表，则匹配的次数满足笛卡尔积，成倍的翻。union能减少匹配的次数，还可以完成两个结果集的拼接。
```

**注意事项：**union在进行结果集合并的时候，要求两个结果集的列数相同（最好完全相同）。



## 15. 分页查询limit

limit是将查询结果集的一部分取出来，提倡使用在分页查询当中。
分页的作用是为了提高用户体验，因为一次全部查询出来，用户体验差，可以一页一页翻看。

**用法**

```mysql
select  字段列表  from   表名  limit  起始索引, 查询记录数 ;
```

完整用法：

```mysql
 limit startIndex,length; #startIndex是起始下标，length是长度。stratIndex默认是从0开始的。
```

缺省用法：

```mysql
limit length;
select ename,sal from emp order by sal desc limit 5;
```

![1676797627788](C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1676797627788.png)

### 注意

在MySQL中 limit 在 order by 之后执行

### 分页

每页显示pagesize条记录：

> 第pageNo页：limit pageDataIndex,pagesize		**pageDataIndex = (pageNo - 1) * (pagesize )**
> limit (pageNo - 1)*pagesize,pagesize
>
> > 注意事项:
> >
> > 1. 起始索引从0开始。        计算公式 ：   起始索引 = （查询页码 - 1）* 每页显示记录数
> >
> > 2. 分页查询是数据库的方言，不同的数据库有不同的实现，MySQL中是LIMIT
> >
> > 3. 如果查询的是第一页数据，起始索引可以省略，直接简写为 limit  条数
>

## DQL大总结

- 基本查询（不带任何条件）
- 条件查询（where）
- 分组查询（group by）
- 排序查询（order by）
- 分页查询（limit）

```mysql
SELECT
	字段列表
FROM
	表名列表
WHERE
	条件列表
GROUP  BY
	分组字段列表
HAVING
	分组后条件列表
ORDER BY
	排序字段列表
LIMIT
	分页参数
```

# 三、DDL创建表



**设计表流程**

> 设计一张表，基本的流程如下：
>
> 1. 阅读页面原型及需求文档
>
> 2. 基于页面原型和需求文档，确定原型字段(类型、长度限制、约束)
>
> 3. 再增加表设计所需要的业务基础字段(id主键、插入时间、修改时间)

**DDL** 英文全称是 Data Definition Language (数据定义语言)，用来定义数据库对象(数据库、表)。

**DDL** 中数据库的常见操作：查询、创建、使用、删除。

注意：在同一个数据库服务器中，不能创建两个名称相同的数据库

```mysql
create database [ if not exists ] 数据库名;  # 创建数据库
show databases;     # 查询所有数据库
use 数据库名;        # 使用数据库
select database();  # 查询当前数据库
drop database [ if exists ] 数据库名 ;    # 删除数据库
# 上述语法中的database，也可以替换成 schema
```



## 1.数据类型：

MySQL中的数据类型有很多，主要分为三类：字符串类型、数值类型、日期时间类型。

### 1.字符串类型

> **varchar(字符串长度255)：**可变长度的字符串，节省空间，会根据实际的数据长度分配空间。
> 优点：节省空间
> 缺点：需要动态分配空间，速度慢。
>
> **char(字符串长度255)：**定长字符串，不管实际的数据长度是多少，分配固定的空间去存储数据。使用不恰当是会造成空间的浪费。
> 优点：不需要多态分配空间，速度快
> 缺点：使用不当可能会导致空间的浪费。
>
> **如何选择：**根据字段的数据长度是否固定灵活使用varchar和char；
>
> 注意：一个中文也是一个长度

**字符串类型**

| 类型       | 大小                  | 描述                         |
| ---------- | --------------------- | ---------------------------- |
| CHAR       | 0-255 bytes           | 定长字符串(需要指定长度)     |
| VARCHAR    | 0-65535 bytes         | 变长字符串(需要指定长度)     |
| TINYBLOB   | 0-255 bytes           | 不超过255个字符的二进制数据  |
| TINYTEXT   | 0-255 bytes           | 短文本字符串                 |
| BLOB       | 0-65 535 bytes        | 二进制形式的长文本数据       |
| TEXT       | 0-65 535 bytes        | 长文本数据                   |
| MEDIUMBLOB | 0-16 777 215 bytes    | 二进制形式的中等长度文本数据 |
| MEDIUMTEXT | 0-16 777 215 bytes    | 中等长度文本数据             |
| LONGBLOB   | 0-4 294 967 295 bytes | 二进制形式的极大文本数据     |
| LONGTEXT   | 0-4 294 967 295 bytes | 极大文本数据                 |

char 与 varchar 都可以描述字符串，char是定长字符串，指定长度多长，就占用多少个字符，和字段值的长度无关 。而varchar是变长字符串，指定的长度为最大占用长度 。相对来说，char的性能会更高些。

### 2.数字类型

> **int：11** 数字的整数型，等同于Java中的int
>
> **bigint：**数字的长整型，相当于Java中的long
>
> **float：**单精度浮点数型数据
>
> **double：**双精度浮点数型数据

| 类型        | 大小   | 有符号(SIGNED)范围                                    | 无符号(UNSIGNED)范围                                       | 描述               |
| ----------- | ------ | ----------------------------------------------------- | ---------------------------------------------------------- | ------------------ |
| TINYINT     | 1byte  | (-128，127)                                           | (0，255)                                                   | 小整数值           |
| SMALLINT    | 2bytes | (-32768，32767)                                       | (0，65535)                                                 | 大整数值           |
| MEDIUMINT   | 3bytes | (-8388608，8388607)                                   | (0，16777215)                                              | 大整数值           |
| INT/INTEGER | 4bytes | (-2147483648，2147483647)                             | (0，4294967295)                                            | 大整数值           |
| BIGINT      | 8bytes | (-2^63，2^63-1)                                       | (0，2^64-1)                                                | 极大整数值         |
| FLOAT       | 4bytes | (-3.402823466 E+38，3.402823466351 E+38)              | 0 和 (1.175494351  E-38，3.402823466 E+38)                 | 单精度浮点数值     |
| DOUBLE      | 8bytes | (-1.7976931348623157 E+308，1.7976931348623157 E+308) | 0 和  (2.2250738585072014 E-308，1.7976931348623157 E+308) | 双精度浮点数值     |
| DECIMAL     |        | 依赖于M(精度)和D(标度)的值                            | 依赖于M(精度)和D(标度)的值                                 | 小数值(精确定点数) |



### 3.日期类型

> - **date：**短日期类型
>  str_to_date('09-01-2003','%d-%m-%Y')：将字符串类型的日期转换为日期类型。
>   **年：%Y	月：%m	日：%d	时：%h	分：%i	秒：%s**
>    通常使用在insert阶段，因为插入时需要一个日期类型的数据，需要通过该函数将字符串转换为date；
>   如果字符串写成	**'%Y-%m-%d'**	格式，那么则不需要显式使用该函数，系统会自动转换数据类型。
>- **date_format('日期类型数据','日期格式')；**
>   这个函数通常使用在查询日期方面，设置展示的日期格式。
>    如：`select name,date_format(birth,'%d-%m-%Y') from t_birth;`
>   写入日期格式时，会自动调用str_to_date函数，同理，输出时也会自动调用**date_format函数。**
> - **datetime：**长日期类型
> 
> **date和datetime的区别：**
> date是短日期，只包括年月日信息。	      	%Y-%m-%d
> datetime是长日期，包括年月日时分秒信息。	%Y-%m-%d	%h:%i:%s	用空格间隔就行
> 
> 在MySQL当中获取当前时间的函数：now()函数

| 类型      | 大小 | 范围                                       | 格式                | 描述                     |
| --------- | ---- | ------------------------------------------ | ------------------- | ------------------------ |
| DATE      | 3    | 1000-01-01 至  9999-12-31                  | YYYY-MM-DD          | 日期值                   |
| TIME      | 3    | -838:59:59 至  838:59:59                   | HH:MM:SS            | 时间值或持续时间         |
| YEAR      | 1    | 1901 至 2155                               | YYYY                | 年份值                   |
| DATETIME  | 8    | 1000-01-01 00:00:00 至 9999-12-31 23:59:59 | YYYY-MM-DD HH:MM:SS | 混合日期和时间值         |
| TIMESTAMP | 4    | 1970-01-01 00:00:01 至 2038-01-19 03:14:07 | YYYY-MM-DD HH:MM:SS | 混合日期和时间值，时间戳 |

### 4.对象

> **clob：**(Character Large Object)字符大对象，最多可以存储内存为4G的字符串，比如：存储一篇文章、存储一个说明。超过255个字符的都要采用CLOB字符大对象来存储
>
> **blob：**(Binary Large Object)二进制大对象，专名原来存储图片、视频、音频等流媒体数据。往BLOB类型的字段插入数据时，需要使用IO流才可以插入数据。



## 2.表的创建（建表）和删除：



```mysql
show tables; # 查询数据库中的所有的表
desc 表名 ; #查看指定表结构 可以查看指定表的字段、字段的类型、是否可以为NULL、是否存在默认值等信息
show create table 表名 ; # 查询指定表的建表语句
```



表名：建议以  **t\_**或者  **tbl\_**开始，可读性强。最好见名知意。
字段名：要求见名知意（字段名类似于二维表中的表头、HTML表格的表头）
表明和字段名都属于标识符

**创建表的语法格式：**（建表属于DDL语句，包括：create创建、drop删除、alter）

```mysql
create table 表名 （
		字段名1 数据类型 [约束]  [comment  字段1注释 ],
		字段名2 数据类型 [约束]  [comment  字段2注释 ],
		字段名3 数据类型 [约束]  [comment  字段3注释 ],
		......
		字段名n 数据类型 [约束]  [comment  字段n注释 ]
）;
```

> 注意： [ ] 中的内容为可选参数； 最后一个字段后面没有逗号

<h3>创建表的语法：create

```mysql
create table t_student(
	ID int comment 'ID,唯一标识',
	name varchar(10) comment '用户名',
    sex char(1) default 'm'  comment '性别', # 没有输入数据的话，会输出默认值，而default将原来的默认值NULL修改为m。
    age int(3) comment '年龄',
    email varchar(225) comment '邮箱'
)comment '学生表';

```

**表的复制**

```mysql
create table newtable as select * from oldtable;
```

**修改表名**

```sql
rename table 表名 to  新表名;
```



<h3>删除表的语法：drop

```mysql
drop table 表名；
drop table t_student;  # 当这张表不存在时会报错。
drop table if exists t_student;  # 如果表存在就删除，不会报错，不能轻易使用, 在删除表时，表中的全部数据也会被删除。
```

>if exists ：只有表名存在时才会删除该表，表名不存在，则不执行删除操作(如果不加该参数项，删除一张不存在的表，执行将会报错)。

<h3>删除表中的数据：truncate 

```mysql
truncate table tablename;
#这种删除的效率比较高，表被物理删除
```

缺点：不支持回滚，删除之后无法恢复；不能随便使用，使用该命令时，必须提前了解该表中数据是否还有存在的意义。
优点：能快速删除，删除速度比delete高，快速删除大量数据。

## 3.对表的结构进行增删改：alter

==企业开发在数据库设计阶段继续设计，之后对表的结构修改通过可视化界面完成==

**添加字段**

```sql
alter table 表名 add  字段名  类型(长度)  [comment 注释]  [约束];
```

**修改数据类型**

```mysql
alter table 表名 modify  字段名  新数据类型(长度);
#alter table tablename modify columnname varchar(11);
```

**修改字段名**

```sql
alter table 表名 change  旧字段名  新字段名  类型(长度)  [comment 注释]  [约束];
```

**删除字段**

```sql
alter table 表名 drop 字段名;
```

**外键约束的语法**

```mysql
-- 创建表时指定
create table 表名(
	字段名    数据类型,
	...
	[constraint]   [外键名称]  foreign  key (外键字段名)   references   主表 (主表列名)	
);


-- 建完表后，添加外键
alter table  表名  add constraint  外键名称  foreign key(外键字段名) references 主表(主表列名);
```





# 四、DML语句

**DML** 英文全称是 Data Manipulation Language (数据操作语言)，用来对数据库中表的数据记录进行增、删、改操作。	

- 添加数据（INSERT）
- 修改数据（UPDATE）
- 删除数据（DELETE） 

## 1.插入数据：insert into ...  values

**语法格式：**

```mysql
insert into 表名(字段名1，字段名2，字段名3) values(值1，值2，值3);
# 字段名组可以省略，此时代表写上了这个表的所有的字段名，后面的值都要写上！！！！！！！！！！！
# 注意：字段名和值要一一对应：数量要对应，数据类型要对应。
insert into t_birth values(4,'wangke','1989-06-11',now()); # now()代表获取系统当前时间。
```

**注意：**insert语句一旦被执行成功，那么必然会多一条记录。没有输入数据的字段内容变成默认值（NULL）；
	   insert之后只有修改才能改变插入后的数据。

**一次插入多条语句：** **insert into tablename values(),(),().... ;**    插入几条记录values后面就要有几个括号。

```java
insert into 表名 values (值1, 值2, ...), (值1, 值2, ...);
```

**将查询结果插入到一张表中：**

```mysql
insert into tablename select * from 查询的规定数据
```

Insert操作的注意事项：

1. 插入数据时，指定的字段顺序需要与值的顺序是一一对应的。

2. 字符串和日期型数据应该包含在引号中。

3. 插入的数据大小，应该在字段的规定范围内。

## 2.修改update table set……where

语法格式：

```mysql
update	表名	set	字段名1 = 值1,字段名2 = 值2,字段名3 = 值3…… where 条件
#注意：没有条件限制会导致所有的数据全部更新
例：update t_birth set name = 'xueaiqi',birth = '2002-12-23',create_time = now() where id = 2;
update user set u_name = 'name',u_sex = 'sex',u_age = 'age',address = 'address',phone = 'phone',email = 'email' where u_account = '222'; 
```

> 注意事项:
>
> 1. 修改语句的条件可以有，也可以没有，如果没有条件，则会修改整张表的所有数据。
>
> 2. 在修改数据时，一般需要同时修改公共字段update_time，将其修改为当前操作时间。



## 3.逻辑删除delete from table

这里的删除指的是删除表中的数据，并没有删除表的结构。而且是在特定条件下是可恢复的

> 恢复（回滚）：rollback

语法格式：

```mysql
delete from 表名 [where 条件];
#注意：没有条件，整张表的数据会全部删除。
delete from t_birth where id = 3;
```

delete删除原理：表中的数据被删除，但是这个数据在硬盘上的正是存储空间不会被释放
缺点：删除的效率比较低，删除大量数据会花费一定的时间。
优点：支持回滚，数据删除后可以恢复  **回滚命令：rollback**

> 注意事项:
>
> ​	• DELETE 语句的条件可以有，也可以没有，如果没有条件，则会删除整张表的所有数据。
>
> ​	• DELETE 语句不能删除某一个字段的值(可以使用UPDATE，将该字段值置为NULL即可)。
>
> ​	• 当进行删除全部数据操作时，会提示询问是否确认删除所有数据，直接点击Execute即可。 ???



## 4.物理删除：truncate   属于DDL语句

语法格式：

```mysql
truncate table tablename;
#这种删除的效率比较高，表被一次截断，物理删除
一次把所有的数据全部删除，不能删单条，
```

缺点：不支持回滚，删除之后无法恢复；不能随便使用，使用该命令时，必须提前了解该表中数据是否还有存在的意义。
优点：能快速删除，删除速度比delete高，快速删除大量数据。



# 五、四大约束（非常重要）

## 1.约束

约束对应的英文单词是：constraint

在创建表的时候，我们可以给表中的字段加上一些约束，来保证这个表中数据的完整性和有效性，
约束的作用就是为了保证表中的数据有效。



## 2.约束的分类：

| **约束** | **描述**                                         | **关键字**  |                |
| -------- | ------------------------------------------------ | ----------- | -------------- |
| 非空约束 | 限制该字段值不能为null                           | not null    | 列级约束       |
| 唯一约束 | 保证字段的所有数据都是唯一、不重复的             | unique      | 列级和表级约束 |
| 主键约束 | 主键是一行数据的唯一标识，要求非空且唯一         | primary key | 列级和表级约束 |
| 默认约束 | 保存数据时，如果未指定该字段值，则采用默认值     | default     |                |
| 外键约束 | 让两张表的数据建立连接，保证数据的一致性和完整性 | foreign key |                |

> 注意：约束是作用于表中字段上的，可以在创建表/修改表的时候添加约束。
>
> 约束加在列后面时列级约束，约束在其他地方称为表级约束
>
> - 列级约束：完整性约束条件涉及到该表的当前一个属性列
> - 表级约束：完整性约束条件涉及到该表的一个或多个属性列

列级约束语法规范：

```mysql
create table t_vip(
	id int primary key auto_increment comment 'ID,唯一标识',  #主键自动增长
    name varchar(10) not null comment '姓名', 
    gender char(1) default '男' comment '性别'
);
```

表级约束语法规范：（多字段联合起来唯一）

```mysql
create table tablename(
	id int,
    name varchar(32),
    email varchar(32),
    unique(name,email)
);
#表示name和email联合起来不能一样，当name相同的时，email不一样才能插入数据，反之同理。
```

多个约束联合使用

```mysql
create table tablename(
	id int,
    name varchar(32),
    email varchar(32) not null unique,
    #两个约束联合使用
#在MySQL当中入轨一个字段同时被not null和unique约束的话，该字段自动变成主键约束（Oracle不一样）
);
```



### 1.主键约束（primary key， 简称pk）

**主键字段：**加了主键约束的字段
**主键值：**主键字段的每一个值
主键值是每一行记录的唯一标识，是每一行记录的身份证号。
任何一张表都要有主键，没有主键，这张表就无效。
主键值建议使用int、bigint、char来做主键，主键值一般都是定长的，所以不建议使用varchar当主键。

主键的特征：not null + unique（主键值不能为空，不能重复）
一个字段叫做单一主键，两个或两个以上字段联合起来的主键叫做复合主键。

语法规范：

```mysql
drop table if exists tablename;
create table tablename(
	id int primary key,
    name varchar(32),			#不可以再加上primary key了，主键只能有一个
    sex char(1)
    #primary key(id)
#primary key(id,name)   表示复合主键id和name至少有一个不一样
);

create table users(
	id int primary key auto_increment,
	name varchar(10) unique,
	psw varchar(20),
	email varchar(20)
);
```

开发中不建议使用复合主键，建议使用单一主键。**主键只能有一个，但是可以设置复合主键**

**主键的分类：**自然主键和业务主键
自然主键：主键值是一个自然数，意义不大
业务主键：主键值和业务紧密关联，例如拿银行卡账号做主键值。
再实际开发中使用自然主键比较多。尽量使用自然主键。

自动维护主键值： primary key auto_increment;			不需要自己增加主键，主键会从1开始自增

> 主键自增：auto_increment
>
> - 每次插入新的行记录时，数据库自动生成id字段(主键)下的值
> - 具有auto_increment的数据列是一个正数序列开始增长(从1开始自增)

### 2.外键约束（foreign key 简称fk）

**外键字段：**该字段添加了外键约束
**外键值：**外键约束当中的每一个值
外键约束是通过对外键字段进行约束，使这个字段里面的外键值在其父表的相关匹配字段值里；
外键约束用来进行两张表的相关数据的匹配，如班级号码匹配上班级，有外键约束的表为子表，另外表为父表

> 外键约束：让两张表的数据建立连接，保证数据的一致性和完整性。  
>
> 对应的关键字：foreign key

使用外键约束至少使用两张表
**创建表**的顺序：先创建父，再创建子。
**删除表**的顺序：先删除子，再删除父。
**插入数据**的顺序：先插入父，再插入子。
**删除数据**的顺序：先删除子，再删除父。

语法：

```mysql
create table t_suptable(
    classno int primary key,
    class_name varchar(255)
);
create table t_subtable(
	ID int,
    name varchar(32),
    class int,
    foreign key(class) references t_suptable(classno),
    #foreign key(子表中的外键字段) references 父表（连接到父表的字段）；refernece:参考
    #foreign key(外键) references 被参照表(被参照字段)
    constraint fk_class foreign key(class) references t_suptable(classno)
);
```

子表中的外键引用的父表中的某个字段不一定是主键，但是必须有唯一性。因为外键值可以为NULL；

**物理外键和逻辑外键**

- 物理外键
  - 概念：使用foreign key定义外键关联另外一张表。
  - 缺点：
    - 影响增、删、改的效率（需要检查外键关系）。
    - 仅用于单节点数据库，不适用与分布式、集群场景。
    - 容易引发数据库的死锁问题，消耗性能。

- 逻辑外键
  - 概念：在业务层逻辑中，解决外键关联。
  - 通过逻辑外键，就可以很方便的解决上述问题。

> **在现在的企业开发中，很少会使用物理外键，都是使用逻辑外键。 甚至在一些数据库开发规范中，会明确指出禁止使用物理外键 foreign key **





# 六、存储引擎（简单了解）

存储引擎是MySQL特有的术语，其他数据库没有（Oracle有，但是不叫这个名字）
存储引擎是一个表存储/组织数据的方式，不同的存储引擎，表存储数据的方式不同。

在建表的时候，可以在最后一个小括号后面加上存储引擎
ENGINE来指定存储引擎
CHARSET来指定这张表的字符编码方式
MySQL默认的存储引擎是：InnoDB

语法：

```mysql
create table t_tablename(
    id int primary key
)engine = innodb default charset = gbk;
```

## 1.查看MySQL支持哪些存储引擎：

**show engines \G**			engine:引擎

MySQL支持九大存储引擎，版本不同，支持不同

## 2.MySQL常用的存储引擎

**MyISAM存储引擎：**管理的表具有以下特征，使用三个文件表示每个表
		格式文件：用来存储表结构的定义（mytable.frm）：desc 表名
		数据文件：用来存储表行的内容（mytable.MYD）： select * from tablename
		索引文件：用来存储表上的索引（mytable.MYI）：索引用来缩小扫描范围，提高查找效率的一种机制
		对于一张表来说，只要有主键或者加有unique约束的字段会自动创建索引
**特点：**可被转换为压缩、只读表来节省空间

**InnoDB存储引擎：**是MySQL默认的存储引擎，也是一个重量级的存储引擎
		InnoDB支持事务，支持数据库崩溃后自动恢复机制。
**特点：**支持事务，以保证数据的安全，非常安全，效率不是很高，不能压缩，不能转换为只读，不能很好的节省存储空间据+索引
<img src="C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1677042951193.png" alt="1677042951193" style="zoom:60%;" />

表空间是一个逻辑名称，表空间存储数

**MEMORY存储引擎：**
<img src="C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1677043371117.png" alt="1677043371117" style="zoom:60%;" />

# 七、事务（transaction）

> **重要**

## 1.事务

一个事务就是一个完整的业务逻辑，是一个最小的工作单元，不可再分。
本质上，一个事务就是批量的DML语句同时成功或者同时失败。

<img src="C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1677051461564.png" alt="1677051461564" style="zoom:60%;" />

只要DML语句才有事务这一说，其他语句和事务没有关系，如：insert、delete、update
只要操作一旦涉及数据的增删改，一定要考虑到数据的安全性

一个业务通常是需要多条DML语句共同执行才能完成的，为了保证数据的安全，必须要求同时成功之后再提交，所以不能执行一条就提交一条，因此才会使用事务。

## 2.事务时是何实现的？commit 、rollback

InnoDB引擎提供一组用来记录事务活动的日志文件，
在事务执行的过程中，每一条DML的操作都会记录在“事务性活动的日志文件”中。
在事务执行的过程中，我们可以提交事务、也可以回滚事务。

**提交事务：**清空事务性活动的日志文件，将数据全部彻底持久化到数据库表中。
				提交事务标志着，事务的结束。并且是一种全部成功的结束。

**回滚事务：**将之前执行的DML操作全部撤销，并且清空事务性活动的日志文件
				回滚事务标志着，事务的结束，并且是一种全部失败的结束。

## 3.怎么提交事务和回滚事务

提交事务：commit语句
回滚事务：rollback语句，回滚只能回滚到上一个提交点

在MySQL当中默认的事务行为时自动提交事务的，每执行一句DML语句，则提交一次

**关闭MySQL自动提交机制：**start transaction；

```mysql
#创建表
create table t_table(
    id int primary key,
    name varchar(32),
    sex char(1)
);
#开始事务
start transaction;
# 插入数据，此阶段的数据不会自动提交，支持回滚
insert into t_table values(1,'mamenghua','m');
insert into t_table values(2,'zhangsan','m');
insert into t_table values(3,'lisi','m');
# 事务回滚：注意一次回滚会取消这一次事务中进行增删改的所有的数据操作,此时事务也结束了，同时也没有提交的机会了，即撤回本次事务的修改。
rollback;
# 事务提交：注意事务提交之后不支持事务回滚了，数据已经全部提交,此时事务也结束了。
commit;
```

## 4.事务的四个特征

1. 原子性：说明事务时最小的工作单元
2. 一致性：所有的事务要求，再同一事务当中，所有的操作必须同时成功或者同时失败，以保证数据的一致性
3. 隔离性：事务A和事务B之间具有一定的隔离，对于一张表而言，同一时间只能有一个事务发生。
4. 持久性：事务最终结束的一个保障。事务提交，就相当于将没有保存到硬盘上的数据保存到硬盘上。

## 5.事务的隔离性

1.事务的四个隔离级别
**大多数数据可的隔离级别都是从读已提交开始的**
Oracle数据库默认的隔离级别是读已提交
MySQL数据库默认的隔离级别是可重复读

**读未提交：**read uncommitted	（最低隔离级别）
		事务A读到事务B未提交的数据。		
		这种现象叫做脏读现象（Dirty Read），称读到了脏数据。
**读已提交：**read committed	

- 事务A只能读到事务B提交的数据。	

- 解决了脏读现象，但是不能重复读取数据。事务开启之后，第一次读到的数据有3条，当前事务还没结束，其他事务对数据做了更改并提交，第二次读取时读到的数据可能是4条。

  
  
  
  

**可重复读：**repeatable read		提交之后也读不到，读取的都是刚开始事务时的数据。

- 事务A开启之后，不管时多久，每一次在事务A读取到的数据都是一样的。即使事务B将数据已经修改，并且提交了，但是事务A读到的数据还是没有发生改变，这就是可重复读。
- 会出现幻影读，读到的数据可能不真实。

**序列化/串行化：**serializable		（最高隔离级别，效率最低，解决了所有的问题）
 这种隔离级别表示事务插队，不能并发，

```mysql
#查看事务隔离级别
select @@session.tx_isolation
select @@tx.isolation
select @@transaction_isolation
#设置全局的事务隔离级别为读未提交
set global transaction isolation level read uncommitted;
#设置全局的事务隔离级别为读已提交
set global transaction isolation level read committed;
#设置全局的事务隔离级别为可重复读
set global transaction isolation level repeatable read; 
```

# 八、索引(index)

## 1.什么是索引？

索引是在数据库表的字段上添加的，是为了提高查找效率（缩小扫描范围）存在的一种机制。是各种数据库进行优化的重要手段，优化的时候优先考虑的因素是索引。
一张表的一个字段可以添加一个索引，多个字段联合起来也可以添加索引。每个字段都可以加上索引，但是不能随便加。
查找没有增加索引的字段，MySQL会将该字段的每一个值都进行比较，效率比较低，叫做全扫描。

**MySQL查询主要有两种查询方式：**
	第一种：全表扫描
	第二种：根据索引检索

在MySQL中索引式需要排序的，并且这个索引的排序和TreeSet数据结构相同。
TreeSet（TreeMap）底层是一个自平衡的二叉树！在MySQL当中索引是一个B-Tree数据结构
遵循左小右大原则存放，采用中序遍历方式便利获取数据。

**提醒1：**在任何数据库当中主键上都会自动添加索引对象。
	  另外在MySQL当中，一个字段上如果有unique约束，也会自动创建索引对象。
**提醒2：**在任何数据库当中，任何一张表的任何一条记录在硬盘存储上都有一个硬盘的物理存储编号。
**提醒3：**在MySQL当中，索引是一个单独的对象，不同存储引擎以不同的形式存在
			在MyISAM中，索引存储在一个.MYI文件中；
			在InnoDB中，索引引擎存储在一个逻辑名称叫tablespace当中
			在MEMORY中，索引引擎存储在内存当中
	不管存储引擎在哪里，索引在MySQL当中都是一个树的形式存在（自平衡的二叉树B-Tree，最好说是这个）
实际上底层是（数组+树的结合体）

<img src="C:\Users\50184\AppData\Roaming\Typora\typora-user-images\1677118512177.png" alt="1677118512177" style="zoom:70%;" />

## 2.什么是给字段增加索引

**条件1：**数据庞大（到底有多么庞大算庞大，这个需要测试，因为每一个硬件的环境不同）
**条件2：**该字段经常出现在where之后，一条件的形式存在，也就是说该字段总是被扫描。
**条件3：**该字段很少进行DML(insert、delete、update)操作，因为DML之后，索引需要重新排序

建议不要随便增加索引，因为索引也需要维护的，太多的话反而会降低系统的性能。
建议通过主键查询，建议通过unique约束的字段进行查询，效率比较高

## 3.创建、删除索引

```mysql
#创建索引
create index 索引名_index on 表名(字段名);
给表的字段添加索引，起名为索引名_index;底层二叉树就产生了
#删除索引
drop index 索引名_index on 表名;
将表中的名叫 “索引名_index” 的索引对象删除 
```

## 4.怎么查看一个SQL语句是否使用了索引进行检索

```mysql
explain select * from 表名 where 字段名 = “匹配条件”;
#当扫描的记录过多时，说明没有使用索引。type = ALL 说明时全表扫描
#type = ref 时说明使用的就是索引，检索次数等于1：rows = 1;
```

## 5.索引失效情况

1. 模糊扫描以“%”开始，如：“%D”
2. 使用or，如果使用 or 走索引，那么要求 or 两边的字段都要有索引，一方没有，那么不会走索引。
3. 使用复合索引时，没有使用左侧的列查找，索引失效。见下列解释。
4. 在where当中索引列参加了数学运算，索引失效。
5. 在where当中索引使用了函数

union联合查询不会让索引失效
**解释3：**复合索引：两个或多个字段联合起来增加索引，叫做复合索引。
create index 索引名 on 表名(字段1,字段2);查询时只查字段1不会失效，只查字段2会失效。

## 6.索引的分类

单一索引：一个字段上添加的索引
复合索引：两个字段或者更多字段上添加索引。
主键索引：主键上添加的索引。
唯一性索引：具有unique约束的字段上添加的索引。

**注意：**在唯一性不高的（有重复数据）字段上添加索引用处不大。

# 九、视图

## 1.什么是视图

view：站在不同的角度去看待同一份数据

我们可以面向视图对象进行增删改查，对试图对象的增删改查，会导致原表被操作。（对试图的操作会影响到原表的数据）方便、简化开发，利于维护。

## 2.创建和删除视图对象

```mysql
create view 视图名 as select * from 表名;as后面必须是DQL语句
#注意只要DQL语句才能以view的形式创建
drop view 视图名;
```

## 3.创建视图的作用

以下列SQL语句为例：

```mysql
create view 视图名
as
	select
		a.name,b.score
	from 
		表a a（起别名）
	join 
		表b b
	on
		a.id = b.id
```

因为修改视图后表a和表b的内容也会发生改变。
假设有一条非常复杂的SQL语句，而这条语句需要在不同的位置上反复使用，每一次将这条语句重新编写，非常麻烦。
可以把这条非常复杂的语句以视图对象的形式新建，在需要编写这条SQL语句时直接使用视图对象，可以大大简化开发，从一定程度上会节省代码量。
并且便于后期的维护，因为修改的时候也只需要修改一个位置就像，只需要修改视图对象所映射的SQL语句。

视图对象是一个文件，在数据库当中也是以文件的形式存在，视图存在在硬盘上，**关机重启不会消失**。
在面向视图开发中，使用视图就像使用表一样，可以对视图就像增删改操作。

# 十、DBA命令

语法加粗部分需要自定义

**新建用户：**	create user **username** identified by '**password**';
**授权：**grant all privileges on **dbname**.**tbname** to '**username**'@'**login ip**' identified by '**password**' with grant option;
		dbname = * 表示所有数据库
 		tbname = * 表示所有表
		login ip = % 代表任何ip
		password 为空，表示不需要密码即可登录
		with grant option 表示该用户还可以授权给其他用户
**回收权限：**revoke all privileges on dbname[.tbname] from username;

## 数据的导入和导出（数据备份）

**数据导入：**source 数据所在的位置（拖入即可）。
**注意：**需要先登录到MySQL数据库服务器上，

然后创建数据库：          create database 数据库名
使用数据库：		         use databasename
然后初始化数据库：      source 数据库所在的位置 

**数据导出：**在Windows的DOS界面使用**mysqldump dataname > D:\dataname.sql -uroot -p密码**，注意不要加分号
导出指定表：**mysqldump dataname tablename > D:\name.sql -uroot -p密码**

# 十一、***数据库设计的三范式（面试问）

数据库设计三范式是数据库表的设计依据。

**第一范式：**要求每一张表必须有一个主键，每一个字段原子性，不可再分（最核心，最主要）
**第二范式：**建立在第一范式的基础之上，要求所有非主键字段完全依赖主键，不要产生部分依赖。
**第三范式：**建立在第二范式的基础之上，要求所有非主键字段直接依赖主键，不要产生传递依赖。

设计数据库表的时候，按照以上的范式，可以避免表中数据的冗余，空间的浪费

> - 多对多：三张表，关系表两个外键
> - 一对多：两张表，多的表加外键
>   - 在数据库表中多的一方，添加字段，来关联属于该字段对应表的主键。
> - 一对一：放一张表，在实际开发中，可能会存在一张表的字段太多，太庞大了，这个时候要拆分表，拆分之后的表使用外键连接.
>   - 在任意一方加入外键，关联另外一方的主键，并且设置外键为唯一的(UNIQUE)

数据库设计三范式是理论上的，数据和理论有的时候会存在偏差，最终的目的都是为了满足客户的需求，有的时候用冗余换执行速度，因为在SQL当中，表和表之间连接次数阅读，效率越低（笛卡尔积），有时候可能会存在冗余，但是为了减少表的连接次数，这样做也是合理的，并且对于开发人员来说，SQL语句的编写难度也会降低。

