---
title: Java 操作 Redis 
date: 2024-01-20
updated: 2024-1-21
category: Redis
comments: true
top_single_background: https://tse2-mm.cn.bing.net/th/id/OIP-C.og0rQ01xv6I7e1LpSbNIVQAAAA?w=311&h=106&c=7&r=0&o=5&dpr=1.3&pid=1.7
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.Jed-UVwaIqf16oq5f8ATDQHaE8?w=251&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# Java 操作 Redis


## Redis 的 Java 客户端

- Jedis：以 Redis 命令作为方法名称，学习成本低，简单易用。但是Jedis实例时线程不安全的，多线程环境下需要基于连接池来使用；
- lettuce：Lettuce 是基于 Netty 实现的，支持同步、异步和响应式编程方式，并且是线程安全的。支持 Redis 的哨兵模式、集群模式和管道模式；
- Redisson：Redisson 是一个基于 Redis 实现的分布式、可伸缩的 Java 数据结构集合。包含了诸如 Map，Queue，Lock、Semaphore（信号量）、AtomicLong（原子类）等强大功能



### Jedis 的使用

1. 引入依赖
   ```xml
   <dependency>
       <groupId>redis.clients</groupId>
       <artifactId>jedis</artifactId>
       <version>4.4.3</version>
   </dependency>
   ```

2. 创建 jedis 对象，建立连接
   ```java
   class RedisApplicationTests {
   	private Jedis jedis;
   	@BeforeEach
   	void setUp(){
   		//1. 建立连接
   		jedis = new Jedis("192.168.25.147",6379);
   		//2. 设置密码
   		jedis.auth("030109");
   		//3. 选择库
   		jedis.select(0);
   	}
   	@Test
   	void testString() {
   		String result = jedis.set("name", "mahua");
   		System.out.println(result);
   		String name = jedis.get("name");
   		System.out.println(name);
   	}
   	@AfterEach
   	void tearDown(){
   		if(jedis != null){
   			jedis.close();
   		}
   	}
   
   }
   ```

3. 使用 jedis，方法名与 Redis 命令一致

4. 释放资源



**Jedis 连接池**


Jedis 本身是线程不安全的，并且频繁的创建和销毁连接会有性能损耗，因此使用 Jedis 连接池替代 Jedis 的直连方式。

```java
public class JedisConnectionFactory {
	//使用了final修饰符，表示该变量的值在初始化后不能被修改。
	private static final JedisPool jedisPool;

	static {
		// 配置连接池
		JedisPoolConfig poolConfig = new JedisPoolConfig();
		// 配置连接池的最大连接数（连接池允许的最大活动或闲置的连接总数）
		poolConfig.setMaxTotal(8);
		// 配置连接池的最大空闲连接数（连接池中允许保持空闲状态的连接的最大数量。）
		poolConfig.setMaxIdle(8);
        // 最小空闲连接数
		poolConfig.setMinIdle(0);
		// 配置连接池的最大等待时间，单位是ms
		poolConfig.setMaxWaitMillis(1000);
		// 创建连接池对象
		jedisPool = new JedisPool(poolConfig,"192.168.25.147",6379,1000,"030109");
	}

	public static Jedis getJedis(){
		return jedisPool.getResource();
	}
}

```

### 

### SpringDataRedis 

SpringData 是 Spring 中数据操作的模块，包含对各种数据库的集成，其中对 Redis 的集成模块是 SpringDataRedis

SpringDataRedis 提供了 RedisTemplate 工具类，其中封装了各种对 Reids 的操作。并且将不同数据类型的操作 API 封装到不同的类型中。

|             API             |   返回值类型    |          说明           |
| :-------------------------: | :-------------: | :---------------------: |
| redisTemplate.opsForValue() | ValueOperations |  操作 String 类型数据   |
| redisTemplate.opsForHash()  | HashOperations  |   操作 Hash 类型数据    |
| redisTemplate.opsForList()  | ListOperations  |   操作 List 类型数据    |
|  redisTemplate.opsForSet()  |  SetOperations  |    操作 Set 类型数据    |
| redisTemplate.opsForZSet()  | ZSetOperations  | 操作 SortedSet 类型数据 |
|        redisTemplate        |                 |       通用的命令        |

#### SpringDataRedis入门

**SpringDataJpa使用起来非常简单，记住如下几个步骤即可**

SpringDataRedis的使用步骤：

* 引入spring-boot-starter-data-redis依赖
* 在application.yml配置Redis信息
* 注入RedisTemplate


1. 引入依赖（spring-boot-starter-data-redis、commons-pool2 [ Redis 或者 JDBC 底层会基于该依赖实现连接池效果 ] ）
   ```xml
      <!--redis依赖-->
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-data-redis</artifactId>
     </dependency>
     <!--common-pool-->
     <dependency>
         <groupId>org.apache.commons</groupId>
         <artifactId>commons-pool2</artifactId>
     </dependency>
   
   ```

2. 配置yml文件

   ```yaml
   spring:
     data:
       redis:
         host: 192.168.25.147
         port: 6379
         password: "030109"
         lettuce:
           pool:
             max-active: 8 # 最大连接数
             max-idle: 8 # 最大空闲连接
             min-idle: 0 # 最小空闲连接
             max-wait: 100 # 连接等待时长
   ```

3. 注入 redisTemplate

   ```java
   @Autowired
   private RedisTemplate redisTemplate
   ```

4. 编写测试

   ```java
   @SpringBootTest
   class SpringDataRedisApplicationTests {
   
   	@Resource
   	private RedisTemplate redisTemplate;
   	@Test
   	void testString() {
   		ValueOperations valueOperations = redisTemplate.opsForValue();
   //		valueOperations.set("name","mahua");
   		Object name = valueOperations.get("name");
   		System.out.println(name);
   	}
   
   }
   // 注意 RedisTemplate 默认的序列化器（JdkSerializationRedisSerializer）使存储到 redis 数据库中的键和值都是乱码
   ```

#### SpringDataRedis 序列化

> SpringDataRedis两种序列化实践方案
>
> 方案一：
>
> 1. 自定义 RedisTemplate
> 2. 修改 RedisTemplate 的序列化器为 GenericJackson2JsonRedisSerializer
>
> 方案二：
>
> 1. 使用 StringRedisTemplate 和 ObjectMapper 对象 [进行序列化]
> 2. 写入 Redis 时，使用 ObjectMapper 对象的 `writeValueAsString` 方法手动把对象序列化为 JSON
> 3. 读取 Redis 时，使用 ObjectMapper 对象的 `readValue` 方法手动把读取到的 JSON 反序列化为对象



### 自定义 RedisTemplate


- key 通常是 String 类型的数据，使用 `new StringRedisSerializer()`序列化器进行序列化
- Value 通常是 Object 类型的数据，使用 `new GenericJackson2JsonRedisSerializer()`序列化器进行序列化

```java
@Configuration
public class RedisTemplateConfig {

	@Bean
	public RedisTemplate<String,Object> redisTemplate(RedisConnectionFactory redisConnectionFactory){
		RedisTemplate<String,Object> redisTemplate = new RedisTemplate<>();
		redisTemplate.setConnectionFactory(redisConnectionFactory);
                // 创建JSON序列化工具
        GenericJackson2JsonRedisSerializer jsonRedisSerializer = 
            							new GenericJackson2JsonRedisSerializer();
		redisTemplate.setKeySerializer(new StringRedisSerializer());
        //redisTemplate.setKeySerializer(RedisSerializer.string());
		redisTemplate.setHashKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(jsonRedisSerializer);
		//redisTemplate.setValueSerializer(new GenericJackson2JsonRedisSerializer());
		redisTemplate.setHashValueSerializer(jsonRedisSerializer);
		return redisTemplate;
	}
}
```

```json
{
  "@class": "com.mahua.springdataredis.pojo.User",
  "name": "mahua",
  "age": 21
}
```

> 上述有个问题就是含有"@class": "com.mahua.springdataredis.pojo.User"（JSON 序列化器会将类的 class 类型写入 json 结果中，存入 Redis，会带来额外的内存开销），比存储的数据还要大，比较浪费存储空间



### StringRedisTemplate 序列化

Spring 默认提供了一个 StringRedisTemplate 类，它的 key 和 value 的序列化方式默认就是 String 方式，省去了自定义 RedisTemplate 的过程。对于复杂类型的对象，通过 `ObjectMapper` 中的方法手动序列化 Java 对象。


```java
@Autowired
private StringRedisTemplate stringRedisTemplate;
// JSON序列化工具
private static final ObjectMapper mapper = new ObjectMapper();
@Test
void saveUserByHand() throws JsonProcessingException {
    User user = new User("mahua",21);
    // 手动序列化
    String json = mapper.writeValueAsString(user);
    //写入数据
    stringRedisTemplate.opsForValue().set("user:200",json);
    // 取出数据
    String s = stringRedisTemplate.opsForValue().get("user:200");
    //手动反序列化
    User user1 = mapper.readValue(s,User.class);
    System.out.println(user1);
}
```

```json
{
  "name": "mahua",
  "age": 21
}
```
