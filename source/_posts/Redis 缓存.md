---
title: Redis 缓存
date: 2024-01-20
updated: 2024-01-20
tags: 
  - 实战
  - 面试
category: Redis
comments: true
top_single_background: https://tse2-mm.cn.bing.net/th/id/OIP-C.og0rQ01xv6I7e1LpSbNIVQAAAA?w=311&h=106&c=7&r=0&o=5&dpr=1.3&pid=1.7
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Redis 缓存
> 总结:
> - **缓存穿透：**因为查询一个数据库中没有的数据，缓存不命中，请求穿过缓存，直接请求数据库了。
>   - 布隆过滤器（会误判一个元素存在与集合中，但是实际上不存在。说不存在一定不存在，但是存在不一定存在）原理：bitmap + hash 函数；布隆过滤器需要放在访问缓存的之前执行。
>   - 缓存空结果（null，注意要设置缓存过期时间，不然有了数据还会查询出为 null）
> - **缓存雪崩：**某一个时间段内**大量的 key** 过期失效或 Redis 宕机，导致所有的请求全部落到数据库上，造成数据库瞬间压力过大。
>   - 设置缓存过期的时间为随机。防止很多缓存同时过期
>   - 使用高可用的缓存架构，当缓存服务出问题时，通过备份机制快速恢复
>   - 设置热点数据**静态化**，即把访问量较大的数据做静态化处理，减少数据库的访问。（静态化指将动态内容转换为静态文件或数据。）
> - **缓存击穿：**一个**热点 key** 在缓存**有效期过期的瞬间**，大量请求同时涌入数据库去查询这个数据，导致数据库瞬间压力过大。注意这里是一个热点 Key 失效了。
>   - 热点数据永不过期：需要系统判断哪些是热点数据。（不会更新的热点数据）
>   - 逻辑过期：设置一个逻辑过期时间，当访问该数据时，取出逻辑过期时间，判断有没有过期，如果过期就删除或更新该数据。
>   - 加互斥锁：设置一个逻辑过期时间，当缓存过期后，这个数据仍然能够返回，但是还是需要一个请求去数据库中查询并更新缓存，其他请求返回旧数据，直到缓存更新。



> 缓存一致性问题：
>
> 缓存一致性问题是指数据在多个地方（数据库、缓存）存储时，这些地方的数据出现了不一致的情况，可能是由于：缓存更新滞后、系统故障或其他元婴引起的。
>
> 实时一致性：在任何时刻，所有的客户端看到的数据都是一样的（都能看到操作的结果）。
>
> 最终一致性：结果足够的时间后使数据达到一致的状态（暂时出现数据不一致）
>
> 解决方案：
>
> - 先更新数据库，再更新缓存（脏读）
> - 先更新缓存，再更新数据库（需要考虑数据库更新失败导致的缓存不一致）
> - 先删除缓存，再更新数据库（窗口期一致性问题）
> - 延时双删（先删除缓存、更新数据库，然后过一段时间后删除缓存）✅（系统复杂度高，需要合适的机制来定时执行第二次操作，而且第二次删除时间不易确定）



> 缓存更新策略：
>
> - Write through cache（直写缓存）：先将数据写入缓存，之后立即将新的缓存数据复制到数据库。（可以保证写操作的一致性，但是可能会影响写操作的性能）
> - Write back cache（写回缓存）：数据库首先写入缓存，然后由缓存异步写入数据库（提高了写操作的性能，但是增加了数据丢失的风险）
> - Write around cache（绕写缓存）：绕过缓存，直接写数据库，然后依据需要更新缓存或使缓存失效。（适用于更频繁读写操作的场景）



> 缓存失效策略：
>
> - 主动更新（增加了系统的复杂度）
> - 定时失效（无法解决数据在两次加载过程之间变化导致的一致性问题）
> - 惰性加载：只有在请求特定数据且发现缓存失效或缓存中没有该数据的时候才会加载该数据

### 概念

**缓存：**是存贮数据的临时地方，也可以说是缓存区的数据，一般读写性能较高（基于内存）。

**优点：**

- 降低后端负载：缓存可以减少对后端数据库或其他持久化存储系统的访问频率，直接访问缓存，从而减轻这些系统的负担（因为这些数据库的数据存放在硬盘中而不是内存中）。
- 提高读写效率，降低响应时间：由于缓存通常基于内存，其读写速度远高于磁盘存储，因此可以显著提高应用程序的响应速度。

**缺点：**

- 数据不一致：缓存的数据与数据库中的数据不一致；（数据库中的数据改了，可能缓存还没改）
- 缓存击穿/雪崩
- 资源消耗
- 缓存更新策略复杂



>将数据库中的常用的数据查询出来之后保存在 Redis 中，每一次查询后台数据时，都先在 Redis 中查询是否有缓存，
>
>- 有缓存，使用 JSONUtils 工具将**从缓存中取出的数据**转换为相应的数据类型返回；
>- 无缓存，从数据库中查找对应的数据，将查询的数据通过 JSONUtils 工具转换为 JSON 格式的数据返回。（查不到数据，就返回一个空值，注意设置 缓存失效的时间）



### 缓存更新策略

- 内存淘汰（达到 max-memery 自动淘汰）
- 超时剔除（设置 ttl有效期）
- 主动更新（手动删除）

|          | 内存淘汰                                                     | 超时剔除                                                    | 主动更新                                     |
| :------: | ------------------------------------------------------------ | :---------------------------------------------------------- | :------------------------------------------- |
|   说明   | 不用自己维护，利用 Redis 的内存淘汰机制，当内存不足时自动淘汰部分数据。下次查询时更新缓存。 | 给缓存数据增加TTL时间，到期后自动删除。下次查询时更新缓存。 | 编写业务逻辑，在修改数据库的同时，更新缓存。 |
|  一致性  | 差                                                           | 一般                                                        | 好                                           |
| 维护成本 | 无                                                           | 低                                                          | 高                                           |

**业务场景：**

- 低一致性：使用 Redis 自带的内存淘汰机制。例如不常变的查询缓存。
- 高一致性：主动更新，并以超时剔除作为兜底方案。例如常变的数据的缓存。



#### 数据库和缓存可能存在不一致性

缓存来源于数据库，数据库里面的数据是发生变化的，依次，如果当数据库中的数据发生变化，而缓存却没有同步，此时就出现了一致性问题，导致用户从缓存中拿到的数据不是最新的数据，可能会产生安全问题。





#### 数据库缓存不一致性解决方案：

- Cache Aside Pattern 人工编码方式：缓存调用者在更新完数据库后再去更新缓存，也称之为**双写方案**
- Read/Write Through Pattern : 由系统本身完成，数据库与缓存的问题交由系统本身去处理
- Write Behind Caching Pattern ：调用者只操作缓存，其他线程去异步处理数据库，实现最终一致



> **由缓存的调用者，在更新数据库的同时删除缓存**  
>
> - 注意这里涉及到事务，数据库的更新和缓存的删除需要一致性操作，数据库没有更新成功，则不会删除缓存，缓存没有删除，则不会更新数据库。

操作缓存和数据库时有三个问题需要考虑：

1. 删除缓存还是更新缓存？
   - 更新缓存：每次更新数据库都要更新缓存，无效写操作较多。❌
   - 删除缓存：更新数据库时让缓存失效，查询时再更新缓存。✔️
2. 如何保证缓存与数据库的操作的同时成功或失败？
   - 单体系统：将缓存与数据库操作放在一个事务
   - 分布式系统：利用 TCC 等分布式事务方案
3. 先删除缓存还是先操作数据库？
   - 先删除缓存，再操作数据库：❌
   - 先操作数据库，再删除缓存：✔️

**读操作：**

- 缓存命中则直接返回；
- 缓存未命中则查询数据库，并写入缓存，设定超时时间。

**写操作：**

- 先写数据库，然后再删除缓存；（安全性问题更低）
- 要确保数据库与缓存操作的原子性。



### 缓存穿透

**缓存穿透：**是指客户端请求的数据在缓存和数据库中都不存在，缓存永不会生效，这些请求一直直接请求数据库。（**没有护甲，即没有数据**）

用户请求的数据在缓存中和数据库中都不存在，不断发起这样的请求，给数据库带来巨大的压力。

**解决方案：**

- 缓存空对象
  - 优点：实现简单，维护方便
  - 缺点：
    - 额外的内存消耗
    - 可能造成短期的不一致
- 布隆过滤：客户端和 Redis 之间加入一层布隆过滤器（bit数组）
  - 优点：内存占用较少，Redis 中没有多余的 key
  - 缺点：
    - 实现复杂
    - 存在误判可能（布隆过滤中不存在时数据库中一定不存在，过滤器中存在时数据库中不一定存在）
- 增强 id 的复杂度，避免被猜测 id 规律
- 做好数据的基础规格校验
- 加强用户权限校验
- 做好热点参数的限流



**布隆过滤：**布隆过滤器其实采用的是哈希思想来解决这个问题，通过一个庞大的二进制数组，走哈希思想去判断当前这个要查询的这个数据是否存在，如果布隆过滤器判断存在，则放行，这个请求会去访问redis，哪怕此时redis中的数据过期了，但是数据库中一定存在这个数据，在数据库中查询出来这个数据后，再将其放入到redis中，

假设布隆过滤器判断这个数据不存在，则直接返回

这种方式优点在于节约内存空间，存在误判，误判原因在于：布隆过滤器走的是哈希思想，只要哈希思想，就可能存在哈希冲突。

![缓存穿透解决方案](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240725194039878.png)



### 缓存雪崩

**缓存雪崩：**是指在同一时段大量的缓存 key 同时失效或者 Redis 服务宕机，导致大量请求到达数据库，带来巨大压力。（存在的崩了，导致了严重的灾难）

解决方案：

* 给不同的Key的TTL添加随机值
* 利用Redis集群提高服务的可用性
* 给缓存业务添加降级限流策略
* 给业务添加多级缓存

![缓存雪崩](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240725194348592.png)



### 缓存击穿

**缓存击穿：**也叫热点Key问题，就是一个被高并发访问并且缓存重建业务较复杂的 key 突然失效了，无数的请求访问会在瞬间给数据库带来巨大的冲击。（一个键[箭 🏹 ] 击穿了）

![缓存击穿](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240725194955316.png)

常见的解决方案有两种：

* 互斥锁（查询的性能从并行变成了串行，即保证只有一个请求访问数据库，其他请求（休眠）等待这个请求拿到的数据放入缓存并失去锁之后才能拿到数据，这时访问的是缓存中的数据。）

  > 互斥锁的实现是通过 redis 的 setnx 原理。

* 逻辑过期（不给 key 直接加上过期时间，直接在 value 中加上过期时间，拿到之后判断有没有过期，如果过期，那么就开启一个线程持有锁去重构数据。）



<img src="https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240725195135561.png" alt="互斥锁解决思路" style="zoom:60%;display:block; float:left" />
<img src="https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240725195301733.png" alt="逻辑过期思路" style="zoom:50%;display:block; float:right" />

<br/><br/>
<br/><br/>
<br/>
<br/>
<br/>
<br/>


#### 互斥锁的实现

核心思路就是利用 redis 的 setnx 方法来表示获取锁，该方法含义是 redis 中如果没有这个key，则插入成功，返回 1，在 stringRedisTemplate 中返回 true，  如果有这个 key 则插入失败，则返回0，在 stringRedisTemplate 返回false，我们可以通过 true，或者是 false，来表示是否有线程成功插入 key，成功插入的 key 的线程我们认为他就是获得到锁的线程。





















1. 互斥锁工具封装

```java
public class LockUtil{
    public static boolean tryLock(String key) {
        Boolean flag = stringRedisTemplate.opsForValue().setIfAbsent(key, "1", 10, TimeUnit.SECONDS);
        return BooleanUtil.isTrue(flag);
    }

    public static void unlock(String key) {
        stringRedisTemplate.delete(key);
    }
}
```

2. 使用互斥锁操作代码拿到用户信息

- 先从缓存中获取数据

  - 有，直接返回对应的数据

    > 注意：
    >
    > - **" "** 直接返回 null，因为这里缓存的是一个空值，代表数据库中没有对应的数据 

  - 无，加锁

    - 加锁成功，从数据库中查询数据，加入缓存

      > 注意：
      >
      > - 查询结果为 null 时，缓存 "" 空字符串而不是 null

    - 加锁失败，当前线程休眠，之后重新调用当前方法获取数据。

```java
 public User queryWithMutex(Long id)  {
        String key = CACHE_KEY + id;
        // 1、从redis中查询缓存
        String userJson = stringRedisTemplate.opsForValue().get("key");
        // 2、判断是否存在
        if (StrUtil.isNotBlank(userJson)) {
            // 存在,直接返回
            return JSONUtil.toBean(userJson, User.class);
        }
        //判断命中的值是否是空值
        if (userJson != null) {
            //返回一个错误信息
            return null;
        }
        // 4.实现缓存重构
        //4.1 获取互斥锁
        String lockKey = "lock:user:" + id;
        User user = null;
        try {
            boolean isLock = tryLock(lockKey);
            // 4.2 判断否获取成功
            if(!isLock){
                //4.3 失败，则休眠重试
                Thread.sleep(50);
                // 重新调用这个方法获取数据
                return queryWithMutex(id);
            }
            //4.4 成功，根据id查询数据库
             user = getById(id);
            // 5.不存在，返回错误
            if(user == null){
                 //将空值写入redis
                stringRedisTemplate.opsForValue().set(key,"",CACHE_NULL_TTL,TimeUnit.MINUTES);
                //返回错误信息
                return null;
            }
            //6.写入redis
            stringRedisTemplate.opsForValue().set(key,JSONUtil.toJsonStr(user),CACHE_NULL_TTL,TimeUnit.MINUTES);

        }catch (Exception e){
            throw new RuntimeException(e);
        }
        finally {
            //7.释放互斥锁
            unlock(lockKey);
        }
        return user;
    }
```



#### 逻辑过期实现

思路分析：在有**缓存预热**的前提下，当用户开始查询 redis 时，判断是否命中，如果没有命中则直接返回空数据，不查询数据库，而一旦命中后，将 value 取出，判断 value 中的过期时间是否满足，如果没有过期，则直接返回redis中的数据，如果过期，则在开启独立线程后直接返回之前的数据，独立线程去重构数据，重构完成后释放互斥锁。

1. 构建逻辑过期的对象的实体类

```java
@Data
public class RedisData {    
    private LocalDateTime expireTime;
    private Object data;
}
```

2. 查询数据

```java
public class UserService {
    @Resource
    private StringRedisTemplate stringRedisTemplate; 
    private static final ExecutorService CACHE_REBUILD_EXECUTOR = Executors.newFixedThreadPool(10);
    public User queryWithLogicalExpire( Long id ){
        String key = CACHE_USER_KEY + id;
        // 1.从redis查询商铺缓存
        String json = stringRedisTemplate.opsForValue().get(key);
        // 2.判断是否存在
        if (StrUtil.isBlank(json)) {
            // 3.存在，直接返回
            return null;
        }
        // 4.命中，需要先把json反序列化为对象
        RedisData redisData = JSONUtil.toBean(json, RedisData.class);
        User user = JSONUtil.toBean((JSONObject) redisData.getData(), User.class);
        LocalDateTime expireTime = redisData.getExpireTime();
        // 5.判断是否过期
        if(expireTime.isAfter(LocalDateTime.now())) {
            // 5.1.未过期，直接返回用户信息
            return user;
        }
        // 5.2.已过期，需要缓存重建
        // 6.缓存重建
        // 6.1.获取互斥锁
        String lockKey = LOCK_User_KEY + id;
        boolean isLock = tryLock(lockKey);
        // 6.2.判断是否获取锁成功
        if (isLock){
            CACHE_REBUILD_EXECUTOR.submit( ()->{

                try{
                    // 查询数据库中的数据并放入缓存操作
                    this.saveUserToRedis(id,USER_EXPIRE_TIME);
                }catch (Exception e){
                    throw new RuntimeException(e);
                }finally {
                    unlock(lockKey);
                }
            });
        }
        // 6.4.返回过期的用户信息
        return user;
    }
    // 查询用户信息并保存到 Redis 中
    public void saveUserToRedis(id, expireSeconds){
        // 查询数据库
        User user = this.getById(id);
        RedisData redisData  = new RedisData();
        // 设置数据
        redisData.setData(user);
        // 设置逻辑过期时间
        redisData.setExpireTime(LocalDataTime.now().plusSeconds(expireSeconds));
        // 放入缓存
        stringRedisTemplate.opsForValue.set(CACHE_KEY+id,JSONUtil.toJsonStr(redisData));
    }
}
```



### 如何异步更新？

```java
private static final ExecutorService CACHE_REBUILD_EXECUTOR = Executors.newFixedThreadPool(10);
public void updateCache(){
     CACHE_REBUILD_EXECUTOR.submit( ()->{
        try{
            this.updateCache();
        }catch (Exception e){
            throw new RuntimeException(e);
        }finally {
            unlock(lockKey);
        }
    });
}
```





























