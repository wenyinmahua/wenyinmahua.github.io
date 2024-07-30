---
title: Redis 实现 UV 统计功能
date: 2024-01-26 
updated: 2024-01-26
tags: 
  - 实战
category: Redis
comments: true
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 实现 UV 统计

UV：全称Unique Visitor，也叫独立访客量，是指通过互联网访问、浏览这个网页的自然人。1天内同一个用户多次访问该网站，只记录1次。

Hyperloglog(HLL)是从 Loglog 算法派生的概率算法，用于确定非常大的集合的基数，而不需要存储其所有值。相关算法原理参考：https://juejin.cn/post/6844903785744056333#heading-0
Redis 中的 HLL 是基于 String 结构实现的，单个HLL的内存**永远小于 16 kb**！作为代价，其测量结果是概率性的，**有小于0.81％的误差**。不过对于UV统计来说，这完全可以忽略。

## 统计一个博客的 UV 

**访问时向 HyperLogLog 添加数据**

```java
stringRedisTemplate.opsForHyperLogLog
    .add(blog.getId().toString(), user.getId().toString());
```

**拿到统计数量**

```java
Long size = stringRedisTemplate.opsForHyperLogLog.size(blog.getId().toString());
```

