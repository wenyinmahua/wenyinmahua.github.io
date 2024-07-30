---
title: Redis 实现共同关注
date: 2024-01-26
updated: 2024-01-26
tags: 
  - 实战
category: Redis
comments: true
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 实现共同关注

实现获得 **共同关注** 的前提是：将自己和好友的关注的用户放在各自的 `Set` 集合中。使用 Set 的求交集的方法拿到共同关注。

```shell
SINTERSTORE destination key [key ...]
summary: Intersect multiple sets and store the resulting set in a key
since: 1.0.0
```

**java 代码**

```java
// 1.获取当前用户
Long userId = loginUser.getId();
String key = "follows:" + userId;
// 2.求交集，这个 id 指的是另外一个人的id
String key2 = "follows:" + id;

Set<String> intersect = stringRedisTemplate.opsForSet().intersect(key, key2);

if (intersect == null || intersect.isEmpty()) {
    // 无交集
    return Collections.emptyList();
}
// 3.解析id集合
List<Long> ids = intersect.stream().map(Long::valueOf).collect(Collectors.toList());
// 4.查询用户
List<User> users = userService.listByIds(ids);
```

