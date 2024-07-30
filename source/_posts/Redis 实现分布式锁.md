---
title: Redis 实现分布式锁
date: 2024-01-25
updated: 2024-01-29
tags: 
  - 实战
  - Lock
category: Redis
comments: true
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 实现分布式锁

**分布式锁：**满足分布式系统或集群模式下多进程可见并且互斥的锁。

> 分布式锁应该满足的条件：
>
> - 可见性：多个线程都能看到相同的结果，注意：这个地方说的可见性并不是并发编程中指的内存可见性，只是说多个进程之间都能感知到变化的意思
> - 互斥：互斥是分布式锁的最基本的条件，使得程序串行执行
> - 高可用：程序不易崩溃，时时刻刻都保证较高的可用性
> - 高性能：由于加锁本身就让性能降低，所有对于分布式锁本身需要他就较高的加锁性能和释放锁性能
> - 安全性：安全也是程序中必不可少的一环



分布式锁的核心是实现多进程之间的互斥，而满足这一点的方式有多种，常见的有三种：

|        |            MySQL            |           Redis           |            Zookeeper             |
| :----: | :-------------------------: | :-----------------------: | :------------------------------: |
|  互斥  | 利用 mysql 本身的互斥锁机制 | 利用 setnx 这样的互斥命令 | 利用节点的唯一性和有序性实现互斥 |
| 高可用 |         好（主从）          |     好（主从、集群）      |                好                |
| 高性能 |            一般             |            好             |               一般               |
| 安全性 |    断开连接，自动释放锁     | 利用锁超时时间，到期释放  |    临时节点，断开连接自动释放    |



## 分布式锁实现核心思路

实现分布式锁时需要实现的两个基本方法：

* 获取锁：

  * 互斥：确保只能有一个线程获取锁
  * 非阻塞：尝试一次，成功返回true，失败返回false

* 释放锁：

  * 手动释放
  * 超时释放：获取锁时添加一个超时时间

**核心思路：**

利用 redis 的 setNx 方法，当有多个线程进入时，我们就利用 setNx 方法，第一个线程进入时，访问 redis 并加锁（设置 key），redis 中就有这个 key 了，返回了1，如果结果是1，则表示他抢到了锁，那么他去执行业务，然后再删除锁，退出锁逻辑，没有抢到锁的线程，等待一定时间后重试即可。



### 实现分布式锁（一）

1. 编写锁的接口

```java
public interface ILock{
    boolean tryLock(long timeoutSec);
    
    void unlock(Sting name);
}
```

2. 实现 ILock 接口并实现其方法

```java
@Override
public boolean tryLock(long timeoutSec) {
    // 获取线程标示
    String threadId = Thread.currentThread().getId()
    // 获取锁
    Boolean success = stringRedisTemplate.opsForValue()
            .setIfAbsent(KEY_PREFIX + keySuffixName, threadId + "", timeoutSec, TimeUnit.SECONDS);
    return Boolean.TRUE.equals(success);
}

@Override
public void unlock() {
    //通过del删除锁
    stringRedisTemplate.delete(KEY_PREFIX + keySuffixName);
}
```



## 分布式锁的误删

逻辑说明：

持有锁的线程在锁的内部出现了阻塞，导致他的锁**自动释放**，这时其他线程，线程2来尝试获得锁，就拿到了这把锁，然后线程2在持有锁执行过程中，线程1反应过来，继续执行，而线程1执行过程中，走到了删除锁逻辑，此时就会把本应该**属于线程2的锁**进行删除，这就是误删别人锁的情况说明

解决方案：解决方案就是在每个线程释放锁的时候，**去判断一下当前这把锁是否属于自己**，如果属于自己，则不进行锁的删除，假设还是上边的情况，线程1卡顿，锁自动释放，线程2进入到锁的内部执行逻辑，此时线程1反应过来，然后删除锁，但是线程1，一看当前这把锁不是属于自己，于是不进行删除锁逻辑，当线程2走到删除锁逻辑时，如果没有卡过自动释放锁的时间点，则判断当前这把锁是属于自己的，于是删除这把锁。

![image-20240726005813664](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240726005813664.png)



### 解决方案

修改之前的分布式锁实现，在获取锁时存入线程标示（可以用UUID表示），
在释放锁时先获取锁中的线程标示，判断是否与当前线程标示一致：

* 如果一致则释放锁
* 如果不一致则不释放锁

> 核心逻辑：
>
> - 在存入锁时，放入自己线程的标识，在删除锁时，判断当前这把锁的标识是不是自己存入的，如果是，则进行删除，如果不是，则不进行删除。

```java
private static final String ID_PREFIX = UUID.randomUUID().toString(true) + "-";
@Override
public boolean tryLock(long timeoutSec) {
   // 获取线程标示
   String threadId = ID_PREFIX + Thread.currentThread().getId();
   // 获取锁
   Boolean success = stringRedisTemplate.opsForValue()
                .setIfAbsent(KEY_PREFIX + keySuffixName, threadId, timeoutSec, TimeUnit.SECONDS);
   return Boolean.TRUE.equals(success);
}

@Override
public void unlock() {
    // 获取线程标示
    String threadId = ID_PREFIX + Thread.currentThread().getId();
    // 获取锁中的标示
    String id = stringRedisTemplate.opsForValue().get(KEY_PREFIX + keySuffixName);
    // 判断标示是否一致
    if(threadId.equals(id)) {
        // 释放锁
        stringRedisTemplate.delete(KEY_PREFIX + keySuffixName);
    }
}
```



> 基于Redis的分布式锁实现思路：
>
> * 利用set nx ex获取锁，并设置过期时间，保存线程标示
> * 释放锁时先判断线程标示是否与自己一致，一致则删除锁
>   * 特性：
>     * 利用set nx满足互斥性
>     * 利用set ex保证故障时锁依然能释放，避免死锁，提高安全性
>     * 利用Redis集群保证高可用和高并发特性
>
> 
>
> 基于 setnx 实现的分布式锁存在下面的问题：
>
> **重入问题**：重入问题是指 获得锁的线程可以再次进入到相同的锁的代码块中，可重入锁的意义在于防止死锁。synchronized和Lock锁都是可重入的。
>
> **不可重试**：是指目前的分布式只能尝试一次，合理的情况是：当线程在获得锁失败后，他应该能再次尝试获得锁。
>
> **超时释放：**我们在加锁时增加了过期时间，这样的我们可以防止死锁，但是如果卡顿的时间超长，有安全隐患
>
> **主从一致性：** 如果Redis提供了主从集群，当向集群写数据时，主机需要异步的将数据同步给从机，而万一在同步过去之前，主机宕机了，就会出现死锁问题。



## Redisson 实现分布式锁

Redisson是一个在Redis的基础上实现的Java驻内存数据网格（In-Memory Data Grid）。它不仅提供了一系列的分布式的Java常用对象，还提供了许多分布式服务，其中就包含了各种分布式锁的实现。

Redission提供了分布式锁的多种多样的功能

官方文档：[目录 · redisson/redisson Wiki (github.com)](https://github.com/redisson/redisson/wiki/目录)



### 使用 Redisson

1. 引入依赖

```xml
<dependency>
	<groupId>org.redisson</groupId>
	<artifactId>redisson</artifactId>
	<version>3.13.6</version>
</dependency>
```

2. 配置 Redisson 客户端

```java
@Configuration
public class RedissonConfig {

    @Bean
    public RedissonClient redissonClient(){
        // 配置
        Config config = new Config();
        config.useSingleServer().setAddress("redis://192.168.183.137:6379")
            .setPassword("123456");
        // 创建RedissonClient对象
        return Redisson.create(config);
    }
}
```

3. 使用 Redisson 的分布式锁

```java
@Resource
private RedissionClient redissonClient;

@Test
void testRedisson() throws Exception{
    //获取锁(可重入)，指定锁的名称
    RLock lock = redissonClient.getLock("anyLock");
    //尝试获取锁，参数分别是：获取锁的最大等待时间(期间会重试)，锁自动释放时间，时间单位
    boolean isLock = lock.tryLock(1,10,TimeUnit.SECONDS);
    //判断获取锁成功
    if(isLock){
        try{
            System.out.println("执行业务");          
        }finally{
            //释放锁
            lock.unlock();
        }
    } 
}
```



### Redisson 看门狗机制

> Redisson 中提供的续期机制

开一个监听线程，每隔一段时间监听方法执行情况，如果方法没有执行完，就重置 Redis 锁的过期时间

原理：

1. 监听当前线程，每10秒续期一次，补到30秒（防止当前服务器宕机之后，因为加锁时间过长，导致其他服务器无法使用该资源）
2. 如果线程挂掉（注意debug模式也会被它当作服务器宕机《线程挂了》），则不会续期。

```java
void testWatchDog(){
    Rlock lock = redissonClient.getLock("lockKey");
    try{
        if(lock.tryLock(0,-1,TimeUtil.MILLISECONDS)){
            // todo 要执行的方法
            doSomething();
            System.out.println("getLock",Thread.currentThread().getId())
        }
    }catch (InterruptedException e) {
			log.error("doCacheRecommendUser err",e);
		}finally {
			if(lock.isHeldByCurrentThread()){
				System.out.println("release lock：" + Thread.currentThread().getId());
				lock.unlock();
			}
		}
}
```

