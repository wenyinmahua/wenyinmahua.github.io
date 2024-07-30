---
title: 乐观锁和悲观锁
date: 2023-04-01
updated: 2023-04-01
comments: true
category: java
tags: 
  - Lock
---
# 乐观锁和悲观锁

解决多线程安全问题就是加锁，通常有**乐观锁**和**悲观锁**两种方式：

![image-20240725235622622](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240725235622622.png)

**悲观锁：**

 悲观锁可以实现对于数据的串行化执行，比如syn，和lock都是悲观锁的代表，同时，悲观锁中又可以再细分为公平锁，非公平锁，可重入锁，等等

悲观锁是直接加上 synchronized ，是线程由并行变成并发

```java
synchronized(this){
     // 业务逻辑代码
}
```

如果有用户 id,可以通过用户 id 减小锁的粒度
```java
// userId.toString() 拿到的对象实际上是不同的对象，new出来的对象
// intern() 方法是从常量池中拿到数据
synchronized(userId.toString().intern()){
    // 业务逻辑代码
}
```



**乐观锁：**

 乐观锁：会有一个版本号，每次操作数据会对版本号+1，再提交回数据时，会去校验是否比之前的版本大1 ，如果大1 ，则进行操作成功，这套机制的核心逻辑在于，如果在操作过程中，版本号只比原来大1 ，那么就意味着操作过程中没有人对他进行过修改，他的操作就是安全的，如果不大1，则数据被修改过，当然乐观锁还有一些变种的处理方式比如cas  "Compare-and-Swap"（比较并交换）。



**乐观锁解决商品超卖问题：**

解决方案一：

```java
boolean success = seckillVoucherService.update()
            .setSql("stock= stock -1") //set stock = stock -1
            .eq("voucher_id", voucherId).eq("stock",voucher.getStock()).update(); //where id = ？ and stock = ?
```

解决方案二：

```java
boolean success = seckillVoucherService.update()
            .setSql("stock= stock -1")
            .eq("voucher_id", voucherId).update().gt("stock",0); //where id = ? and stock > 0
```

