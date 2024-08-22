---
title: Redis 基础
date: 2024-01-19
updated: 2024-01-19
tags:
  - 基础
category: Redis
comments: true
top_single_background: https://tse2-mm.cn.bing.net/th/id/OIP-C.og0rQ01xv6I7e1LpSbNIVQAAAA?w=311&h=106&c=7&r=0&o=5&dpr=1.3&pid=1.7
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# Redis 基础

> 总结：
>
> - Redis 的数据结构：
>
>   - String、Hash、List、Set、SortedSet、GEO、BitMap、HyperLog、streams。
>
> - Redis 数据结构使用场景：
>
>   - String：缓存（set、get）、计数器（incr、incrby）、分布式锁（setnx）
>   - Hash：存储复杂对象（修改时直接修改字段值）
>   - List：分页显示、消息系统、消息队列、点赞列表
>   - Set：共同好友、用户收藏的文章
>   - SortedSet：排行榜、任务调度
>   - GEO：存储地理信息、查找附近的人
>   - BitMap：用户权限管理、访问网站的天数、bloom 过滤器
>   - HyperLog（超级集合）：UV（独立访客统计）
>   - Streams：消息队列。
>
>   如果实现一个简单的缓存，字符串类型就足够了；
>
>   如果处理复杂的数据结构，如用户信息，那么哈希类型将是一个不错的选择。
>
> - Redis 为啥这么快？
>
>   - **基于内存：**数据存储在内存中，读写速度非常快，因为内存访问速度比硬盘访问速度快多了。
>   - **单线程模型：**Redis 使用单线程模型，所有的操作都是在同一个线程内完成的，不需要线程切换和上下文切换。这大大提高了 Redis 的运行效率和响应速度。
>   - **多路复用I/O模型：**在单线程的基础上采用 I/O（数据传输）多路复用，实现了单个线程处理多个客户端连接的能力，从而提高了 Redis 的并发性能。
>   - **高效的数据结构：** Redis 提供了多种高效的数据结构，如哈希表、有序集合、列表等，这些数据结构都被实现得非常高效，能在 O(1) 的时间复杂度内完成数据读写操作。
>   - **多线程的引入：**在 Redis6.0 中为了进一步**提高 I/O 的性能**。采用多线程，使得网络处理的请求可以并发进行，大大提高了性能，减少了网络 I/O 等待造成的影响，还可以充分利用 CPU 的多喝优势。（增加了后台线程来处理一些耗时的操作，如数据持久化、网络 I/O 等，以减轻主线程的压力。）

## 概念

**Redis：**Remote Dictionary Server，远程词典服务器，是一个**基于内存**的键值型NoSQL数据库。使用RESP（REdis Serialization Protocol）协议（基于 TCP 协议）

**特性：**

- 键值型（Key-Value型），value支持多种不同数据结构，功能丰富；

- 单线程，每个命令具备原子性；

- 低延迟、速度快（基于内存、IO多路复用、良好的编码【C语言写的】）；

  > 访问 Redis 数据的速度是**微秒级**

- 支持数据持久化（AOF、RDB）；

- 支持主从集群、分片集群；

- 支持多语言客户端。

Redis 的 **I/O 多路复用**主要用于处理对外的网络连接，而不是对内部数据的操作。具体来说，I/O 多路复用技术用于**管理和监控**客户端与 Redis 服务器之间的网络通信，而不是 Redis 服务器内部的数据处理或存储操作。

Redis 采用单线程**处理命令**（数据的读写）的主要原因是为了简化实现、保证数据一致性和易于调试。

Redis 通过多线程来**加速 I/O 操作和后台任务**，以提高整体性能并充分利用现代多核处理器的能力。

这种混合模型让 Redis 既能在高性能下运行，又能保持数据的一致性和安全性。

虽然命令处理本身是单线程的，但在 I/O 层面，Redis 可能使用多个线程来处理客户端的**连接请求和数据传输**。例如，一个线程可能专门用于读取客户端数据（客户端发送的命令），另一个线程用于写回响应，而核心的**命令处理**则由主线程完成。



### Redis 应用程序

- redis-cli：是 Redis 提供的命令行客户端
- redis-server：是 Redis 的服务端启动脚本
- redis-sentinel：是 Redis 的哨兵启动脚本



### Redis通用指令

- KEYS：查看符合模板的所有的 key（使用 * 模糊匹配），不建议在生产环境设备上使用（会阻塞请求）
- DEL：删除一个指定的 key
- EXISTS：判断 key 是否存在
- EXPIRE：给 key 设置有效期，有效期到期时该 key 会被自动删除，单位是**秒**
- TTL：查看一个 key 的剩余有效期

```sql
help [command] # 查看当前指令怎么使用：help DEL 
help @[command] # 查看某个数据结构的所有指令： help @string
KEYS a*
DEL age
EXPIRE age 20 # 单位时间是秒
TTL age
```



### Redis key 的结构

Redis 的 key 允许有多个单词形成**层级结构**，多个单词之间使用“:”隔开，格式如下：

```
项目名：业务名：类型：id
```



## Redis 数据结构

Redis 是一个 key-value 的数据库，key 一般是 String 类型，不过 value 的类型多种多样：String、Hash、List、Set、SortedSet、GEO、BitMap、HyperLog



### 1. String 类型

String 类型，也就是字符串类型，是 Redis 中最简单的存储类型

其value是字符串，不过根据字符串的格式不同，又可以分为3类：

- string：普通字符串
- int：整型类型，可以做自增、自减操作
- float：浮点类型，可以做自增、自减操作

不管是哪一种格式，底层都是字节数组形式存储，只不过是编码方式不同（数字直接转换为二进制作为字节去存储，字符串是把字符转换为对应的字节码后存储）。字符串类型的最大空间不能超过 512 M。



**String 类型常用指令**

- SET：添加或修改已经存在的一个 String 类型的键值对
- GET：根据 key 获取 String 类型的 value
- MSET：批量添加多个 String 类型的键值对
- MGET：根据多个 key 获取多个 String 类型的 value
- INCR：让一个值（value）为整型的 key 的 value 自增 1
- INCRBY：让一个值为整型的 key 的vlaue自增指定的步长，如：INCRBY age 1 让age值自增1
- INCRBYFLOAT：让一个浮点类型的数字自增并指定步长
- SETNX：添加一个 String 类型的键值对，前提是这个 key 不存在，否则就不会执行
- SETEX：添加一个 String 类型的键值对，并且指定有效期

![String 指令演示](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240822192854198.png)



### 2. Hash 类型

Hash （散列）类型，其 value 是一个无序字典，类似于 Java 中的 HashMap 结构。

> 存储对象时
>
> - String 结构是将对象序列化为 JSON 字符串后存储，当要修改对象某个字段时很不方便
>   - {"name":"jack","age":"18"}
> - Hash结构可以将对象中的每个字段独立存储，可以针对单个字段做CRUD
>   - name:jack
>   - age:18



**Hash 类型的常见命令**


- HSET key field value：添加或修改 hash 类型 key 的 field 的值
- HGET key field：获取一个 hash 类型 key 的 field 的值
- HMSET：批量添加多个 hsah 类型的 key 的 filed 的值
- HMGET：批量获取多个 hash 类型的key 的 filed 的值
- HGETALL：获取一个 hash 类型的 key 中的所有的 field 的 value
- HKEYS：获取一个 hsah 类型的 key 中的所有的 field
- HVALS：获取一个 hash 类型的 key 中的所有的 value
- HINCRBY：让一个 hash 类型的 key 的字段值自增并指定步长
- HSETNX：添加一个 hash 类型的 key 的 field 值，前提是这个 field 不存在，否则不执行

![Hash 指令演示](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240822193326070.png)



### 3. List 类型

Redis 中的 List 类型与 Java 中的 LinkedList 类似，底层可以看作是一个双向链表结构。既支持正向检索，也支持反向检索。

特征也与 LinkedList 类似：

- 有序
- 元素可以重复
- 插入和删除快
- 查询速度一般

> 使用场景：常用来存储一个有序数据，例如：朋友圈点赞列表，评论列表等

**List 常见的指令**


- LPUSH key element ...：向列表左侧插入一个或多个元素
- LPOP key：移除并返回列表左侧的第一个元素，没有则返回nil
- RPUSH key element ...：向列表右侧插入一个或多个元素
- RPOP key：移除并返回列表右侧的第一个元素
- LRANGE key star end：返回一段角标范围内的所有的元素
- BLPOP和BRPOP：与 LPOP 和RPOP类似，只不过在没有元素时等待指定时间，而不是直接返回nil

![List 指令演示](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240822194039466.png)

### 4. Set 类型

Redis 的 Set 结构与 Java 中的 HashSet 类似，可以看作是一个 value 为 null 的 HashMap。因为也是一个 hash 表，因此具备与 HashSet 类似的特征：

- 无须
- 元素不可重复
- 查找快
- 支持交集、并集、差集等功能。

**Set 类型常见的命令**


- SADD key member：向 set 中添加一个或多个元素
- SREM key member：移除 set 中的指定的元素
- SCARD key：返回 set 中元素的个数
- SISMEMBER key member：判断一个元素是否存在于 set 中
- SMEMBERS：获取 set 中的所有的元素

- SINTER key1 key2 ...：求 key1 与 key2 的交集
- SDIFF key1 key2 ...：求 key1 与 key2 的差集
- SUNION key1 key2 ...：求 key1 与 key2 的并集





### 5. SortedSet类型

Redis 中的 SortedSet 是一个可排序的 set 集合，SortedSet 中的每一个元素都带有一个 score 属性，可以基于 score 属性对元素排序，底层的实现是一个跳表（SkipList）加 hash 表

SortedSet 具备下列特性：

- 可排序
- 元素不可重复
- 查询速度快

> 使用场景：因为 SortedSet 的可排序特性，经常被用来实现**排行榜**这样的功能。

**SortedSet 类型的常用指令**


- ZADD key score member：添加一个或多个元素到 sortedset，如果已经存在则更新其 score 值
- ZREM key member：删除 sorted set 中的一个指定的元素
- ZSCORE key member：获取 sorted set 中的指定元素的 score 值
- ZRANK key member：获取 sorted set 中指定元素的排名
- ZCARD key：获取 sorted set 中的元素的个数
- ZCOUNT key min max：统计 score 值在指定范围内的所有元素的个数
- ZINCRBY key increment member：让 sorted set 中的指定元素自增，步长为指定的 increment 的值
- ZRANGE key min max：按照 score 排序后，获取指定排名范围内的元素；
- ZRANGEBYSCORE key min max：按照 score 排序后，获取指定 score 范围内的元素
- ZDIFF、ZINTER、ZUNION：求差集、交集、并集。

> 注意：所有的排名默认都是升序，如果要降序则在命令的 Z 后面添加 REV（reverse）即可。

![SortedSet 指令演示](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240822202044162.png)



### 6. GEO数据类型

GEO是Geolocation的简写形式，代表地理坐标。Redis 在 3.2版本后加入了对 GEO 的支持，允许存储地理图标信息，帮助我们根据经纬度检索数据。

**GEO 类型的常用指令**

- GEOADD：添加一个地理空间，包含经度（longitude）和纬度（latitude）、值（member）
- GEODIST：计算两个点之间的距离并返回
- GEOHASH：将指定 member 的坐标转换为hash字符串形式返回
- GEOPOS：返回指定 member 的坐标
- GEORADIUS：指定圆心、半径，找到该圆内所包含的全部的 member，并按照与圆心的距离排序后返回。6.1后已废弃
- GEOSEARCH：在指定范围内搜索 member，并按照与指定之间的距离排序后返回，范围可以是圆形或矩形。6.2新功能
- GEOSEARCHSTORE：与 GEOSEARCH 功能一致，不过可以把结果存储到一个指定的 key 中；



### 7. BitMap 用法

Redis 是利用 string 类型数据结构实现 BitMap，因此最大上限是 512 M，转换为 bit 则是2^32 个 bit 位

**BitMap 类型的常用指令**

- SETBIT：向指定位置存入一个 0 或 1
- GETBIT：获取指定位置的 bit 值
- BITCOUNT：统计 BitMap 中值为 1 的 bit 位的数量
- BITFIELD：操作（查询、修改、自增）BitMap中 bit 数组中的指定位置的值
- BITFIELD_RO：获取 BitMap 中的 bit 数组，并以十进制形式返回
- BITOP：将多个 BitMap 的结果做位运算
- BITPOS：查找 bit 数组中指定范围内第一个 0 或 1 出现的位置

