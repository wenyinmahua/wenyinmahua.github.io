---
title: Caffeine 的使用
date: 2024-1-19 
updated: 2024-1-19
tags: 
  - 缓存
category: Caffeine
comments: true
cover: https://img2.baidu.com/it/u=1737613515,863944832&fm=253&fmt=auto&app=138&f=PNG?w=500&h=500
---
# Caffeine 的使用

 经过本地主机 + 远程 Redis 数据库测试，在加入缓存 Caffeine 后，查询时间从 230 ms 左右缩短至 120 ms左右

Caffeine 的默认驱逐策略是基于容量的 LRU（Least Recently Used，最近最少使用）算法。这意味着当缓存的大小达到预先设定的最大容量时，它会淘汰最近最少使用的条目来为新的条目腾出空间。这种策略是通过内部实现的双队列结构来优化的，结合了 LRU 和 LFU（Least Frequently Used，最少使用频率）的一些特性，使其更加灵活和适应不同的访问模式。

1. 引入 maven 依赖，注意最新版本不一定适配 jdk8

   ```xml
        <dependency>
            <groupId>com.github.ben-manes.caffeine</groupId>
            <artifactId>caffeine</artifactId>
            <version>2.9.3</version>
        </dependency>
   ```

2. 配置 Caffeine

   ```java
   @Configuration
   public class CacheConfig {
   
       @Bean
       public Cache<String, List<UserVO>> userCache() {
           return Caffeine.newBuilder()
                   // 设置最后一次写入后经过固定时间过期
                   .expireAfterWrite(24, TimeUnit.HOURS)
                   // 初始的缓存空间大小
                   .initialCapacity(100)
                   // 缓存的最大条数
                   .maximumSize(1000)
                   .build();
       }
   
   }
   ```

3. 使用 Caffeine 将数据放入缓存中

   1. 注入 userCache

   ```java
   @Resource
   private Cache<String,List<UserVO>> userCache;
   ```

   2. 使用 userCache 查询缓存

   ```java
   List<UserVO> userVOList = userCache.get(String.valueOf(loginUser.getId()), (key) ->
   	userService.matchUsers(num, loginUser));
   ```

