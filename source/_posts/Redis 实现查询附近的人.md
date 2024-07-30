---
title: Redis 实现查询附近的人
date: 2024-01-26
updated: 2024-01-26
tags: 
  - 实战
category: Redis
comments: true
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 实现查询附近的人

> 实现原理：利用 Redis 的 `GEO` 数据结构：
>
> - 将数据库表中的数据导入到redis中去，redis中的GEO，GEO在 redis 中存储的是一个member和一个经纬度，把x和y轴传入到redis做的经纬度位置去。

GEO就是Geolocation的简写形式，代表地理坐标。Redis在3.2版本中加入了对GEO的支持，允许存储地理坐标信息，可以根据经纬度来检索数据。常见的命令有：

* GEOADD：添加一个地理空间信息，包含：经度（longitude）、纬度（latitude）、值（member）
* GEODIST：计算指定的两个点之间的距离并返回
* GEOHASH：将指定member的坐标转为hash字符串形式并返回
* GEOPOS：返回指定member的坐标
* GEORADIUS：指定圆心、半径，找到该圆内包含的所有member，并按照与圆心之间的距离排序后返回。6.以后已废弃
* GEOSEARCH：在指定范围内搜索member，并按照与指定点之间的距离排序后返回。范围可以是圆形或矩形。6.2.新功能
* GEOSEARCHSTORE：与GEOSEARCH功能一致，不过可以把结果存储到一个指定的key。 6.2.新功能



## 将用户的信息导入到 Redis 中

```java
List<User> users = userService.list();
List<RedisGeoCommands.GeoLocation<String>> locations = new ArrayList<>(users.size());
for(User user : users){
    locations.add(new RedisGeoCommands.GeoLocation<>(
        user.getId().toString(),
        new Point(user.getLongitude(),user.getLatitude())
    ));
}
stringRedisTemplate.opsForGeo().add(key, locations);
```



如果有特殊情况，比如查询不同类型的用户（一个用户只有一个类型）距离自己的附近距离

```java
List<User> list = userService.list();
// 2.把用户分组，按照typeId分组，typeId一致的放到一个集合
Map<Long, List<User>> map = list.stream()
    .collect(Collectors.groupingBy(User::getTypeId));
// 3.分批完成写入Redis
for (Map.Entry<Long, List<User>> entry : map.entrySet()) {
    // 3.1.获取类型id
    Long typeId = entry.getKey();
    String key = USER_GEO_KEY + typeId;
    // 3.2.获取同类型的用户的集合
    List<User> value = entry.getValue();
    List<RedisGeoCommands.GeoLocation<String>> locations = new ArrayList<>(value.size());
    // 3.3.写入redis GEOADD key 经度 纬度 member
    for (User user : value) {
        locations.add(new RedisGeoCommands.GeoLocation<>(
            user.getId().toString(),
            new Point(user.getLongitude(),user.getLatitude())
        ));
    }
    stringRedisTemplate.opsForGeo().add(key, locations);
}
```



## 获取最近的人

GEOSEARCH 命令是 Redis 6.2 提供的，SpringDataRedis 可能不支持，这时需要修改 Pom.xml 文件

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
    <exclusions>
        <exclusion>
            <artifactId>spring-data-redis</artifactId>
            <groupId>org.springframework.data</groupId>
        </exclusion>
        <exclusion>
            <artifactId>lettuce-core</artifactId>
            <groupId>io.lettuce</groupId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-redis</artifactId>
    <version>2.6.2</version>
</dependency>
<dependency>
    <groupId>io.lettuce</groupId>
    <artifactId>lettuce-core</artifactId>
    <version>6.1.6.RELEASE</version>
</dependency>
```

**以分类查询附近的用户为例：**

```java
public List<User> queryShopByType(Integer typeId, Integer current, Double x, Double y) {
    // 1.判断是否需要根据坐标查询
    if (x == null || y == null) {
        // 不需要坐标查询，按数据库查询
        Page<User> page = query()
                .eq("type_id", typeId)
                .page(new Page<>(current, SystemConstants.DEFAULT_PAGE_SIZE));
        // 返回数据
        return page.getRecords();
    }

    // 2.计算分页参数
    int from = (current - 1) * SystemConstants.DEFAULT_PAGE_SIZE;
    int end = current * SystemConstants.DEFAULT_PAGE_SIZE;

    // 3.查询redis、按照距离排序、分页。结果：userId、distance
    String key = USER_GEO_KEY + typeId;
    GeoResults<RedisGeoCommands.GeoLocation<String>> results = stringRedisTemplate.opsForGeo() // GEOSEARCH key BYLONLAT x y BYRADIUS 10 WITHDISTANCE
            .search(
                    key,
                    GeoReference.fromCoordinate(x, y),
                    new Distance(5000),  
 RedisGeoCommands.GeoSearchCommandArgs.newGeoSearchArgs().includeDistance().limit(end)
            );
    // 4.解析出id
    if (results == null) {
        return Collections.emptyList();
    }
    List<GeoResult<RedisGeoCommands.GeoLocation<String>>> list = results.getContent();
    if (list.size() <= from) {
        // 没有下一页了，结束
        return Collections.emptyList();
    }
    // 4.1.截取 from ~ end的部分
    List<Long> ids = new ArrayList<>(list.size());
    Map<String, Distance> distanceMap = new HashMap<>(list.size());
    list.stream().skip(from).forEach(result -> {
        // 4.2.获取用户id
        String userIdStr = result.getContent().getName();
        ids.add(Long.valueOf(shopIdStr));
        // 4.3.获取距离
        Distance distance = result.getDistance();
        distanceMap.put(userIdStr, distance);
    });
    // 5.根据id查询Shop
    String idStr = StrUtil.join(",", ids);
    List<User> users = query().in("id", ids).last("ORDER BY FIELD(id," + idStr + ")").list();
    for (User user : users) {
        user.setDistance(distanceMap.get(user.getId().toString()).getValue());
    }
    // 6.返回
    return users;
}
```



























































