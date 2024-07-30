---
title: Redis 实现签到功能
date: 2024-01-26
updated: 2024-01-26
tags: 
  - 实战
category: Redis
comments: true
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 实现签到功能

> 思路：
>
> - 使用 Redis 的 `BitMap` 来实现，把每一个bit位对应当月的每一天，形成了映射关系。用0和1标示业务状态，这种思路就称为位图（BitMap）。
> - 把年和月作为 BitMap 的 key，然后保存到一个 BitMap 中，每次签到就到对应的位上把数字从 0 变成 1 ，只要对应是 1 ，就表明说明这一天已经签到了，反之则没有签到。

Redis中是利用string类型数据结构实现BitMap，因此最大上限是512M，转换为bit则是 2^32个bit位。

> 提示：
>
> - 因为BitMap 底层是基于 String 数据结构，依次其操作也都封装在字符串相关操作中。

**代码实现：**

```java
@Override
public String sign() {
    Long userId = loginUser.getId();
    LocalDateTime now = LocalDateTime.now();
    String keySuffix = now.format(DateTimeFormatter.ofPattern(":yyyyMM"));
    String key = USER_SIGN_KEY + userId + keySuffix;
    // 获取今天是本月的第几天
    int dayOfMonth = now.getDayOfMonth();
    // 5.写入Redis SETBIT key offset 1，因为 bitMap 第一位从 0 开始的，而 dayOfMonth 第一位从 1 开始。
    stringRedisTemplate.opsForValue().setBit(key, dayOfMonth - 1, true);
    return "签到成功";
}
```



## 获取连续签到数

> 思路：
>
> - 从今天向前遍历，因为键存放的是每个月的全部签到记录，从今天所在的位置向前累加便能拿到连续签到数了。

```java
public Integer signCount(){
    Long userId = loginUser.getId();
    LocalDateTime now = LocalDateTime.now();
    // 拿到本年本月 如202401
    String keySuffix = now.format(DateTimeFormatter.ofPattern("yyyyMM"));
    String Key = USER_SIGN_IN + userId + keySuffix;
    int dayOfMonth = now.getDayOfMonth();
    List<Long> result = stringRedisTemplate.opsForValue().bitField(
        key,
        BitFieldSubCommands.create()
               .get(BitFieldSubCommands.BitFieldType.unsigned(dayOfMonth)).valueAt(0)
    );
    if (result == null || result.isEmpty()) {
        // 没有任何签到结果
        return 0;
    }
    Long num = result.get(0);
    if (num == null || num == 0) {
        return 0;
    }
     int count = 0;
    while (true) {
        // 让这个数字与 1 做与运算，得到数字的最后一个bit位  
        if ((num & 1) == 0) {
            break;
        }else {
            count++;
        }
        // 把数字右移一位，抛弃最后一个 bit 位，继续下一个bit位
        num >>>= 1;
    }
    return count;
}
```



> 解释：
>
> - `bitField()` 方法用于执行 Redis 的 `BITFIELD` 命令，该命令允许你对一个键的位字段进行多种操作，包括获取、设置、增加等。
>
> - `BitFieldSubCommands.create()` 用于创建一个 `BitFieldSubCommands` 实例，这是一个用于构建 `BITFIELD` 命令参数的类。
>
> - `.get(BitFieldSubCommands.BitFieldType.unsigned(dayOfMonth)).valueAt(0)`
>
>   这部分配置了 `BITFIELD` 命令的 `GET` 操作，用于获取指定位字段的值。
>
>   - `BitFieldSubCommands.BitFieldType.unsigned(dayOfMonth)` 指定了要获取的位字段类型和位字段的长度。在这里，`unsigned(dayOfMonth)` 表示一个无符号整数类型的位字段，长度为 `dayOfMonth` 位。
>   - `.valueAt(0)` 指定了从哪个偏移量开始获取位字段的值。这里的 `0` 表示从键的第一个位开始获取。
>
> 
>
> 这段代码的整体作用是获取 `key` 对应的字符串中从第 0 位开始的 `dayOfMonth` 位长的无符号整数值。这里的关键点是 `dayOfMonth` 决定了你要获取的位字段的长度。