---
title: Redis 实现点赞排行榜
date: 2024-01-26
updated: 2024-01-29
tags: 
  - 实战
category: Redis
comments: true
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 实现点赞功能



## Redis 中的集合数据结构对比

|          |         List         |    Set     |     SortedSet     |
| -------- | :------------------: | :--------: | :---------------: |
| 排序方式 |    按添加顺序排序    |  无法排序  | 根据 score 值排序 |
| 唯一性   |        不唯一        |    唯一    |       唯一        |
| 查找顺序 | 按索引查找或首尾查找 | 按元素查找 |   根据元素查找    |

> 由此可以发现，Set 比较适合点赞功能，SortedSet 比较适合点赞排行榜功能。



## Redis 实现点赞功能

> 使用Redis 的 Set 实现点赞功能
>
> - 查询是否是 Set 中的一员
>   - 是，此处是取消点赞的操作（remove）
>   - 否，此处是进行点赞的操作（add）

**实现代码：**

```java
// 点赞操作
boolean isMebver = stringRedisTemplate.opsForSet().isMember(key,userId.toString());
if(BooleanUtil.isFalse(isMember)){
     boolean isSuccess = update().setSql("liked = liked + 1").eq("id", id).update();
     if(isSuccess){
        stringRedisTemplate.opsForSet().add(key,userId.toString());
     }
}else{
    boolean isSuccess = update().setSql("liked = liked - 1").eq("id", id).update();
    if(isSuccess){
        stringRedisTemplate.opsForSet().remove(key,userId.toString());
    }
}
```

> 注意这里还要将 Redis 中的点赞数据持久化到数据库
>
> 对于将 Redis 中的数据持久化到数据库的操作，可以采用几种不同的策略：
>
> 1. **实时同步（Real-time Synchronization）**:
>    - 在每次用户点赞或者取消点赞时，直接更新数据库中的点赞计数。每发生一次点赞/取消点赞事件，就立即更新数据库中的记录。
>    - 这种方式简单直接，但是可能会导致较高的数据库写入频率，尤其是在高并发场景下。
> 2. **定时任务（Scheduled Jobs / Batch Processing）**:
>    - 定期（比如每分钟、每小时等）执行一个定时任务，从 Redis 中读取所有点赞用户的集合，然后根据集合中的变化情况批量更新数据库。
>    - 这种方法减少了数据库的写入频率，减轻了数据库的压力，但可能会有短暂的数据不一致问题，即数据库中的点赞数与 Redis 中的实际点赞数不同步。
> 3. **消息队列（Message Queues）**:
>    - 使用如 Kafka、RabbitMQ 等消息队列系统，在每次点赞/取消点赞时发送一条消息。
>    - 另一个后台服务监听这些消息，汇总一定数量的消息后，批量处理并更新数据库。
>    - 这种方式可以很好地解耦前端服务和数据库，同时保证数据的一致性和系统的高可用性。



## Redis 实现点赞排行榜

> 使用 Redis 的 SortedSet 实现点赞排行榜



### Redis 实现用户点赞排行榜

**此处指的是实现查询一个博客的前几位用户点赞排行榜。**

**实现代码：**

1. 使用 Redis 的 SortedSet 实现点赞功能 

> 思路:
>
> - 用户点赞先判断是否已经点赞（是否存在 SortedSet 集合中，通义通过 score 方法 拿到用户的 score）
>   - 如果 source 为空，那么就说明用户没有进行点赞操作，进行点赞操作（add），source 为时间戳。
>   - 如果 source 不为空，那么就说明用户在进行取消点赞操作，进行取消点赞（remove）。

```java
Double score = stringRedisTemplate.opsForZSet().score(key,userId.toString());
if(score == null){
    boolean isSuccess = update().setSql("liked = liked + 1").eq("id", id).update();
    if (isSuccess) {
        // 这里使用了时间戳作为点赞的分数
        stringRedisTemplate.opsForZSet().add(key, userId.toString(), System.currentTimeMillis());
}else {
    boolean isSuccess = update().setSql("liked = liked - 1").eq("id", id).update();
    if (isSuccess) {
        stringRedisTemplate.opsForZSet().remove(key, userId.toString());
    }
}
```

2. 查询点赞用户排行榜前5位的数据

```java
// 拿到 分数最小的 前五位，range 方法默认是拿到按照 score 从小到大排序的数据，如果需要 从大到小，需要 reverseRange 方法
Set<String> tops5 = stringRedisTemplate.opsForZset().range(0,4);
if(top5 == null || top5.isEmpty()){
    return Collections.emptyList();
}
// 由于 stringRedisTemplate 里面存放的是 String 类型的数据，需要转变成 Long 类型的数据；
List<Long> ids = top5.stream().map(Long::valueOf).collect(Collectors.toList());
List<User> users = userService.selectByIds(ids);
// 注意这里拿到的users 实际上是按 id 从小到大排序的，MySQL根据其内部优化逻辑来排序（根据索引）
```

3. 对 user 按照 ids 中的 id 的顺序进行排序

**方法一：**使用 Stream API

```java
Map<Long,User> userMap = users.stream().collect(Collectors.toMap(User::getId,User -> user));
List<User> sortedUser = IntStream.range(0,ids.size())
    .mapToObj(i -> userMap.get(id.get(i)))
    .collect(Collectors.toList());
```

**方法二：**使用 List 的 set 方法

创建空列表，然后按照 ids 的顺序填充用户对象

```java
Map<Long, User> userMap = new HashMap();
for(User user : users){
    userMap.put(user.getId(),user);
}
List<User> sortedUsers = new ArrayList<>(ids.size());
for(int i : ids){
    sortedUsers.add(userMap.get(i));
}
```



还有一种方式就是在 数据库中使用`FIELD()`函数排序后直接返回结果，使得数据库直接按照 `ids` 的顺序返回数据，避免在 Java 层面进行额外的排序操作。

```java
String idStr = StringUtils.join(",", ids);
// 3.根据用户id查询用户 WHERE id IN ( 5 , 1 ) ORDER BY FIELD(id, 5, 1)
List<User> user = userService.query()
        .in("id", ids).last("ORDER BY FIELD(id," + idStr + ")").list();
```

**性能比较**

1. **数据库排序**:
   - 使用 `FIELD()` 函数在数据库级别排序通常是最快的选项之一，因为它直接在数据库内部完成排序操作。
   - 数据库的排序算法通常比 Java 层面上的排序更加高效，特别是在处理大量数据时。
2. **Java 层面排序**:
   - 在 Java 层面上排序（例如使用 Stream API 或者传统的循环）可能会比数据库排序慢，尤其是当数据量很大时。
   - 这是因为 Java 层面的操作需要加载所有的数据到内存中，然后进行排序，这可能会消耗更多的 CPU 和内存资源。

**总结**

- 如果 `ids` 的顺序对于最终结果至关重要，且数据量较大，那么使用数据库级别的排序是最优选择。这种方式可以显著减少 Java 层面的处理负担，提高整体性能。
- 如果数据量不是很大，或者你已经将数据加载到了内存中并且不需要再次查询数据库，那么在 Java 层面进行排序也是可以接受的。

考虑到你的示例代码中已经使用了 `FIELD()` 函数来进行排序，这表明你已经在数据库级别完成了排序操作。这种方式通常比在 Java 层面进行排序更快，特别是当数据量较大时。



### Redis 实现博客排行榜

1. 在博客点赞的同时实现其 socore + 1；

```java
// 博客点赞操作之后加上
stringRedisTemplate.opsForZSet().incrementScore(key,blog.getId().toString(),1);
```

>具体来说，这行代码执行了以下操作：
>
>- opsForZSet(): 调用 StringRedisTemplate 的方法来操作 Redis 中的有序集合（Sorted Set）数据结构。
>- key: 这是有序集合的键（Key），标识了具体的有序博客集合。
>- blog.getId(): 这是有序集合中的一个成员（Member）。在有序集合中，每个成员都有一个与之关联的分数，用于排序。
>- 1: 这是增量值，表示要增加到成员 blog.getId() 当前分数上的数值。
>  综上所述，这行代码的作用是将有序集合 key 中成员 blog.getId() 的分数增加 1。如果 blog.getId() 成员之前不存在于该集合中，它将被添加，并且其分数设置为 1。如果已经存在，则其分数将从当前值增加 1。



2. 查询点赞排行榜前 5 的博客

代码省略，参考 [Redis 实现用户点赞排行榜](#Redis 实现用户点赞排行榜) 的第二步。





























































































