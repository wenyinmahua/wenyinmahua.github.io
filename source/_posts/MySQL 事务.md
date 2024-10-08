```
title: MySQL 事务
date: 2024-08-20
updated: 2024-08-20
category: MySQL
cover: https://tse3-mm.cn.bing.net/th/id/OIP-C.LvJiXW0ldtBwCwC5TBSh4QHaEK?w=321&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
```

# MySQL 事务

## 事务

**事务：**是一组操作的集合，它是一个不可分割的工作单位，事务会把所有的操作作为一个整体一起向系统提交或撤销操作请求，即这些操作要么同时成功，要么同时失败。

> 注意：
>
> - 默认MySQL的事务是自动提交的，也就是说，当执行完一条DML语句时，MySQL会立即隐式的提交事务。

```SQL
SELECT @@autocommit ; # 查看事务提交方式
SET @@autocommit = 0 ; # 设置事务提交方式
START TRANSACTION 或 BEGIN ; # 开启事务
COMMIT; # 提交事务
ROLLBACK; # 回归事务
```



### ACID：事务的四大特性

- 原子性（Atomicity）：事务是不可分割的最小操作单元，要么全部成功，要么全部失败。
- 一致性（Consistency）：事务完成时，必须使所有的数据都保持一致状态。
- 隔离性（Isolation）：数据库系统提供的隔离机制，保证事务在不受外部并发操作影响的独立环境下运行。（即便有多个事务同时进行，每个事务都应该与其他事务隔离开来。事务所做的修改在最终提交之前对于其它事务来说是不可见的。不同的事务级别可以提供不同程度的隔离，但基本原则是事务不应该相互干扰。）
- 持久性（Durability）：事务一旦提交或回滚，它对数据库中的数据的改变就是永久的。



### 并发事务的问题

- 脏读：一个事务读到了另外一个事务还没有提交的数据
- 不可重复读：在一个事务中，先后读取同一条数据，但两次读取的数据不同，称为不可重复读。
- 幻读：一个事务按照条件查询数据时，没有对应的数据行，但是在插入数据时，又发现这行数据已经存在，好像出现了“幻影”。



### 事务的隔离级别

```SQL
SELECT @@TRANSACTION_ISOLATION; # 查看事务的隔离级别，早期版本不支持，早期版本支持如下
SELECT @@TX_ISOLATION; # 一些早期版本支持，8.0 版本也支持
SET [SESSION | GLOBAL] TRANSACTION ISOLATION LEVEL {READ UNCOMMITTED |READ COMMITTED | REPEATABLE READ | SERIALIZABLE}
```



| 隔离级别                | 脏读 | 不可重复读 | 幻读 |
| ----------------------- | ---- | ---------- | ---- |
| Read uncommitted        | √    | √          | √    |
| Read committed          | ×    | √          | √    |
| Repeatable Read（默认） | ×    | ×          | √    |
| Serializeable           | ×    | ×          | ×    |

> 注意：
>
> - 事务隔离级别越高，数据越安全，但是性能越低。



## 事务原理

> 事务：是一组操作的集合，是一个不可分割的工作单位。事务把所有的操作作为一个整体一起向系统提交或撤销操作请求，那么这些操作要么同时成功，要么同时失败。

- 原子性（Atomicity）：事务是不可分割的最小操作单元，要么全部成功，要么全部失败。
- 一致性（Consistency）：事务完成时，必须使所有的数据都保持一致状态。
- 隔离性（Isolation）：数据库系统提供的隔离机制，保证事务在不受外部并发操作影响的独立环境下运行。
- 持久性（Durability）：事务一旦提交或回滚，它对数据库中的数据的改变就是永久的。

而对于这四大特性，实际上分为两个部分。 其中的原子性、一致性、持久化，实际上是由 InnoDB 中的两份日志来保证的，一份是 redo log 日志，一份是 undo log 日志。 而**隔离性**是通过数据库的**锁**机制，加上 **MVCC** 来保证的。



### redo log 重做日志

**重做日志：**记录的是事务提交时数据页的**物理修改**，是用来实现事务的持久性。

- 重做日志缓冲（内存）
- 重做日志文件（磁盘）

该日志文件由两部分组成：重做日志缓冲（redo log buffer）以及重做日志文件（redo log file）,前者是在内存中，后者在磁盘中。当事务提交之后会把所有修改信息都存到该日志文件中，**用于在刷新脏页到磁盘，发生错误时，进行数据恢复使用。**

> Redo log 在 InnoDB 存储引擎中用于确保事务的持久性（durability）。当对缓冲池（buffer pool）中的数据进行修改时，InnoDB 会首先将这些修改记录在 redo log buffer 中。redo log buffer 是内存中的一个区域，用于暂存即将写入磁盘的 redo log 记录。

原理：

1. **修改数据页**：当事务对数据进行修改时，InnoDB 会首先在缓冲池中修改数据页，同时记录这些修改到 redo log buffer 中。
2. **事务提交**：当事务提交时，InnoDB 会将 redo log buffer 中的记录写入到 redo log file 中。这个过程称为“flush”，它确保了即使在系统崩溃的情况下，也可以通过 redo log 来恢复数据。
3. **刷新脏页**：InnoDB 会定期将缓冲池中的脏页（即被修改但尚未写入磁盘的数据页）写回磁盘。这个过程称为“checkpoint”。



### uodo log 回滚日志（撤销日志）

> 在 insert、update、delete 的时候产生的便于数据回滚的日志。
>
> - 当 insert 的时候，产生的 undo log 日志只在回滚时需要，在事务提交后，可被立即删除。
> - 而 update、delete 的时候，产生的undo log日志不仅在回滚时需要，在快照读时也需要，不会立即被删除。
>
> 用于记录数据被修改前的信息 , 作用包含两个 : 提供回滚(保证事务的原子性) 和 MVCC (多版本并发控制) 。

undo log 和 redo log 记录物理日志不一样，它是逻辑日志。可以认为当 delete 一条记录时，undo log 中会记录一条对应的 insert 记录，反之亦然，当 update 一条记录时，它记录一条对应相反的 update 记录。当执行 rollback 时，就可以从 undo log 中的逻辑记录读取到相应的内容并进行回滚。

undo log 销毁：undo log 在事务执行时产生，事务提交时，并不会立即删除 undo log，因为这些日志可能还用于MVCC。

undo log 存储：undo log 采用段的方式进行管理和记录，存放在 rollback segment 回滚段中，内部包含1024个 undo log segment。



## MVCC(多版本并发控制)

**当前读：**读取的是记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的记录进行加锁。对于我们日常的操作，如：select ... lock in share mode(共享锁)，select ... for update、update、insert、delete(排他锁)都是一种当前读。

**快照读：**简单的select（不加锁）就是快照读，快照读，读取的是记录数据的可见版本，有可能是历史数据，不加锁，是非阻塞读。

- Read Committed：每次select，都生成一个快照读。
- Repeatable Read：开启事务后第一个 select 语句才是快照读的地方。
- Serializable：快照读会退化为当前读。

> 普通的 select 是快照读，而在当前默认的 RR 隔离级别下，**开启事务**后第一个select 语句才是快照读的地方，后面执行相同的 select 语句都是从快照中获取数据，可能不是当前的最新数据，这样也就保证了可重复读。

**MVCC：**全称 Multi-Version Concurrency Control，多版本并发控制。指维护一个数据的多个版本，使得读写操作没有冲突，快照读为 MySQL 实现 MVCC 提供了一个非阻塞读功能。

MVCC 的具体实现，还需要依赖于数据库记录中的

- 三个隐式字段
- undo log 日志
- readView。



### 隐藏字段

InnoDB在创建表的时候会自动添加三个隐藏字段：

| 隐藏字段    | 含义                                                         |
| ----------- | ------------------------------------------------------------ |
| DB_TRX_ID   | 最近修改事务ID，记录插入这条记录或最后依次修改这条记录的事务ID； |
| DB_ROLL_PTR | 回滚指针，指向这条记录的上一个版本，用于配合 undo log，指向上一个版本。如果为 null，代表这条数据才插入，没有被更新过 |
| DB_ROW_ID   | 隐藏主键，如果表结构没有指定主键，则会生成改隐藏主键         |

而上述的前两个字段是肯定会添加的， 是否添加最后一个字段DB_ROW_ID，得看当前表有没有主键，如果有主键，则不会添加该隐藏字段。



通过`版本链`+ `DB_TRX_ID` + `DB_ROLL_PTR` 来实现

通过 update 会生成一个 undo log， DB_ROLL_PTR 会指向 undo log 日志中的一条记录，代表回滚到哪个版本

> 不同事务或相同事务对同一条记录进行修改，会导致该记录的undolog生成一条记录版本链表，链表的头部是最新的旧记录，链表尾部是最早的旧记录



### ReadView

ReadView（读视图）是 快照读 SQL 执行时 MVCC 提取数据的依据，记录并维护系统当前活跃的事务（未提交的）id。

ReadView中包含了四个核心字段：

|      字段      |                         含义                         |
| :------------: | :--------------------------------------------------: |
|     m_ids      |                 当前活跃的事务ID集合                 |
|   min_trx_id   |                    最小活跃事务ID                    |
|   max_trx_id   | 预分配事务ID，当前最大事务ID+1（因为事务ID是自增的） |
| creator_trx_id |                ReadView创建者的事务ID                |



不同的隔离级别，生成 ReadView 的时机不同：

- READ COMMITTED ：在事务中每一次执行快照读时生成 ReadView。
- REPEATABLE READ：仅在事务中第一次执行快照读时生成 ReadView，后续复用该  ReadView



而在readview中就规定了版本链数据的访问规则：

trx_id 代表当前undolog版本链对应事务ID。

| 条件                               | 是否可以访问                                  | 说明                                         |
| ---------------------------------- | --------------------------------------------- | -------------------------------------------- |
| trx_id ==creator_trx_id            | 可以访问该版本                                | 成立，说明数据是当前这个事务更改的。         |
| trx_id < min_trx_id                | 可以访问该版本                                | 成立，说明数据已经提交了。                   |
| trx_id > max_trx_id                | 不可以访问该版本                              | 成立，说明该事务是在 ReadView 生成后才开启。 |
| min_trx_id <= trx_id <= max_trx_id | 如果 trx_id 不在 m_ids 中，是可以访问该版本的 | 成立，说明数据已经提交。                     |





























