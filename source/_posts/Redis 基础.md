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

## 概念

**Redis：**Remote Dictionary Server，远程词典服务器，是一个基于内存的键值型NoSQL数据库

![Redis](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8)

**特性：**

- 键值型（Key-Value型），value支持多种不同数据结构，功能丰富；

- 单线程，每个命令具备原子性；

- 低延迟、速度快（基于内存、IO多路复用、良好的编码【C语言写的】）；

  > 访问 Redis 数据的速度是**微秒级**

- 支持数据持久化；

- 支持主从集群、分片集群；

- 支持多语言客户端。



### Redis 应用程序

- redis-cli：是redis提供的命令行客户端
- redis-server：是redis的服务端启动脚本
- redis-sentinel：是redis的哨兵启动脚本



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
- INCR：让一个整型的 key 自增 1
- INCRBY：让一个整型的 key 自增并指定补偿，如：INCRBY age 1 让age值自增1
- INCRBYFLOAT：让一个浮点类型的数字自增并指定步长
- SETNX：添加一个 String 类型的键值对，前提是这个 key 不存在，否则就不会执行
- SETEX：添加一个 String 类型的键值对，并且指定有效期





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

Redis 中的 SortedSet 是一个可排序的 set 集合，与 Java 中的 TreeSet 有些类似，但底层数据结构却差别很大。SortedSet 中的每一个元素都带有一个 score 属性，可以基于 score 属性对元素排序，底层的实现是一个跳表（SkipList）加 hash表

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