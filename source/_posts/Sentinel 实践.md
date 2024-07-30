---
title: Sentinel 实践
date: 2024-05-29
updated: 2024-05-29
tags: 
  - 实战
category: SpringCloud
comments: true
cover: https://ts2.cn.mm.bing.net/th?id=OIP-C.Ie1OJXlcgu7ngem7TAwcFgHaDP&w=212&h=104&c=7&bgcl=2b6437&r=0&o=6&dpr=1.3&pid=13.1
---
# Sentinel 实践

>[Sentinel](https://sentinelguard.io/) （哨兵）是面向分布式、多语言异构化服务架构的流量治理组件，主要以流量为切入点，从流量路由、流量控制、流量整形、熔断降级、系统自适应过载保护、热点流量防护等多个维度来帮助开发者保障微服务的稳定性。
>
>Sentinel 的使用可以分为两个部分:
>
>- **核心库**（Jar包）：不依赖任何框架/库，能够运行于 Java 8 及以上的版本的运行时环境，同时对 Dubbo / Spring Cloud 等框架也有较好的支持。在项目中引入依赖即可实现服务限流、隔离、熔断等功能。
>- **控制台**（Dashboard）：Dashboard 主要负责管理推送规则、监控、管理机器信息等。[Sentinel 控制台 jar 包下载地址](https://github.com/alibaba/Sentinel/releases)



> 服务保护的方案：
>
> - 请求限流：就是**限制或控制**接口访问的并发流量，避免服务因流量激增而出现故障。
> - 线程隔离：限定每个接口可以使用的资源范围（可用线程数上线），也就是将其“隔离”起来。（轮船的舱壁模式）
> - 服务熔断：某个接口出现异常比例过高影响其他服务的情况，这时直接熔断该服务（拒绝调用该接口），走降级逻辑（自己编写）。



## Sentinel 控制台安装

>[Sentinel 控制台 jar 包下载地址](https://github.com/alibaba/Sentinel/releases)

拿到 Sentinel 的控制台安装包，通过下列指令启动控制台：

```shell
java -Dserver.port=8090 -Dcsp.sentinel.dashboard.server=localhost:8090 -Dproject.name=sentinel-dashboard -jar sentinel-dashboard.jar
```

访问[http://localhost:8090](http://localhost:8090)页面，就可以看到sentinel的控制台了：

![image-20240729221645359](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729221645359.png)

账号和密码，默认都是：sentinel



## 微服务整合 Sentinel



### 1.引入sentinel依赖

```XML
<!--sentinel-->
<dependency>
    <groupId>com.alibaba.cloud</groupId> 
    <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
</dependency>
```



### 2. 配置控制台

```YAML
spring:
  cloud: 
    sentinel:
      transport:
        dashboard: localhost:8090
      http-method-specify: true # 开启请求方式前缀
```

> 默认情况下Sentinel会把路径作为簇点资源的名称，无法区分路径相同但请求方式不同的接口，查询、删除、修改等都被识别为一个簇点资源，这里通过开启请求方式前缀来解决：把`请求方式 + 请求路径`作为簇点资源名



### 3. 测试

简单编写一个控制器，用来进行测试

```java
@RestController
public class UserController {

	@GetMapping("/username")
	public String getUserName(){
		return "mahua";
	}
}
```

访问路径：[localhost:8080/username](http://localhost:8080/username) 接口，可以看到sentinel控制台的**簇点链路**发生了变化：

![image-20240729233556505](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729233556505.png)



所谓簇点链路，就是单机调用链路，是一次请求进入服务后经过的每一个被`Sentinel`监控的资源。

默认情况下，`Sentinel`会监控`SpringMVC`的每一个`Endpoint`（接口），就是 SpringMVC 框架的 http 请求。

这个接口路径 [localhost:8080/username](http://localhost:8080/username) 就是其中一个簇点，可以对其进行限流、熔断、隔离等保护措施。



> 可以通过 Sentinel 控制台来进行请求限流、线程隔离、服务熔断等等操作。



## 1. 请求限流

使用 Jemeter 测试 [localhost:8080/username](http://localhost:8080/username) 接口，每秒发送 100/5 = 20个请求

![测试结果](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729234801903.png)

通过簇点链路的`流控`按钮，来实现限流配置：

![image-20240729233936333](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729233936333.png)

把访问这个簇点资源的最大QPS限制为 10

> QPS 是 "每秒查询数"（Queries Per Second）的缩写，它是一个衡量系统性能的指标，特别是在数据库、网络和服务器等领域中常常被用来评估系统的处理能力。
>
> 通俗地说，QPS 表示一个系统每秒钟能够处理的查询或请求的数量。这个指标通常用于衡量系统的吞吐量，即系统在单位时间内能够处理多少工作。在不同的上下文中，QPS 可以有不同的含义，但总的来说，它都表示每秒钟能够处理的操作数。

再次使用 Jemeter 测试，发现有一半请求请求失败，这边实现了请求限流

![Jmeter 测试结果树](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729235113942.png)



![Jemeter测试汇总报告](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729235233080.png)

可以看出`GET:/username`这个接口的通过QPS稳定在 10 附近，而拒绝的QPS在 10 附近，符合我们的预期。



## 2. 线程隔离

限流可以降低服务器压力，尽量减少因并发流量引起的服务故障的概率，但并不能完全避免服务故障。一旦某个服务出现故障，必须隔离对这个服务的调用，避免发生雪崩。

默认情况下 SpringBoot 项目的 tomcat 最大线程数是 200，允许的最大连接是 8492，单机测试很难打满。

需要修改 tomcat 连接：

```YAML
server:
  port: 8080
  tomcat:
    threads:
      max: 50 # 允许的最大线程数
    accept-count: 50 # 最大排队等待数量
    max-connections: 100 # 允许的最大连接
```

> 配置参数解读：
>
> - `max`: 这个配置项实际上是 `maxThreads` 的别名，表示线程池中可使用的最大线程数。当一个请求到达时，Tomcat会分配一个线程来处理该请求。
> - `accept-count`: 表示当所有线程都被占用时，可以接受并放入等待队列中的新连接的最大数量。
> - `max-connections`: 表示同时可以打开的最大连接数。这包括正在处理中的连接以及等待处理的连接。
>
> 通常情况下，`max-connections` 应该至少等于 `max` 加上 `accept-count` 的值，以确保所有请求都可以被接收和处理。但是，它也可以设置得更高，以适应某些特殊情况，比如一些连接可能被长时间保持但并不活跃。



> 详解：
>
> - 当Tomcat收到请求时，它会创建一个新的线程来处理该请求。
> - 如果所有 50 个线程都在使用中，并且还有更多的请求到来，那么最多 50 个额外的连接将被允许排队等待。
> - 如果排队的连接也达到了最大数量（这里是 50 ），那么任何进一步的尝试连接都将被拒绝，直到有连接被关闭或者有线程变得可用。
> - `max-connections`确保即使在所有线程都忙的情况下，仍然可以接受新连接并将其放入等待队列中。



修改 getUserName 方法，实现线程休眠 500 ms，提示在 UserController 中新增一个 getAge() 接口：

```java
@RestController
public class UserController {

	@GetMapping("/username")
	public String getUserName() throws InterruptedException {
		Thread.sleep(500);
		return "mahua";
	}

	@GetMapping("/age")
	public String getAge(){
		return "21";
	}
}
```

 正常情况下，访问 [localhost:8080/age](http://localhost:8080/age) 后端处理时间为 1ms 左右

![正常访问](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730002211614.png)



当通过 Jemeter 给 `\username` 请求每秒发送 100 的请求时，访问 `\age` 请求的时间变为 200ms ，严重时变为 500 ms，响应时间翻了几百倍，更不用说复杂的业务场景了。

![高并发下访问](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730002524818.png)

![高并发访问](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730002613688.png)



### 配置线程隔离

如果把 username 作为热点服务，那么对其进行线程隔离，通过`流控`按钮，配置并发线程数为 40，使这个查询功能最多使用 40 个线程，每个线程每秒能处理 2 个请求， QPS 为 80。而 tomcat 设置的最大线程数为 50，还有 10个线程用来处理 `\age` 请求。

![配置线程隔离](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730003220805.png)

再次访问高并发调用 `\username` 接口，同时调用 `\age` 接口，可以发现 后端处理  `\age` 接口 时间又恢复到 `1ms` 左右。



> 如果项目中通过 OpenFeign 远程调用某个接口，那么可以通过如下配置，使 OpenFeign 整合 Sentinel：
>
> ```YAML
> feign:
>   sentinel:
>     enabled: true # 开启feign对sentinel的支持
> ```



## 3. 服务熔断

> 某些服务长时间出现异常比例过高，这说明这个服务出现了问题，预期继续调用浪费服务器资源，不如直接返回拒绝调用该服务（服务熔断），使用兜底方案（降级处理）。
>
> - 即对于不健康的接口进行熔断，给出兜底方案。

Sentinel中的断路器不仅可以统计某个接口的**慢请求比例**，还可以统计**异常请求比例**。当这些比例超出阈值时，就会**熔断**该接口，即拦截访问该接口的一切请求，降级处理；当该接口恢复正常时，再放行对于该接口的请求。

断路器的工作状态切换有一个状态机来控制：

![image-20240730104628385](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730104628385.png)

状态机包括三个状态：

- **closed**：关闭状态，断路器放行所有请求，并开始统计异常比例、慢请求比例。超过阈值则切换到 open 状态
- **open**：打开状态，服务调用被**熔断**，访问被熔断服务的请求会被拒绝，快速失败，直接走降级逻辑。open 状态持续一段时间后会进入 half-open 状态
- **half-open**：半开状态，放行一次请求，根据执行结果来判断接下来的操作。 
  - 请求成功：则切换到 closed 状态
  - 请求失败：则切换到 open 状态

在控制台通过点击簇点后的**`熔断`**按钮来配置熔断策略：



### 服务熔断的实现

在弹出的表格中这样填写：

![服务熔断配置](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730105209464.png)

这种是按照慢调用比例来做熔断，上述配置的含义是：

- RT超过 200 毫秒的请求调用就是慢调用
- 统计最近 1000ms 内的最少 5 次请求，如果慢调用比例不低于 0.5，则触发熔断
- 熔断持续时长 20 s

配置完成后，再次利用Jemeter测试，可以发现，在一开始一段时间是允许访问的，后来触发熔断后，该接口通过QPS直接为0，所有请求都被熔断了。



### 基于具有 OpenFeign 项目编写降级逻辑

> 降级逻辑需要编写在 OpenFeign 客户端所在的 module 进行，Sentinel 不提供降级处理。

 触发限流或熔断后的请求不一定要直接报错，也可以返回一些默认数据或者友好提示，用户体验会更好。

给FeignClient编写失败后的降级逻辑有两种方式：

- 方式一：FallbackClass，无法对远程调用的异常做处理
- 方式二：FallbackFactory，可以对远程调用的异常做处理，我们一般选择这种方式。



#### 1. 定义降级处理类

降级处理类需要实现 FallbackFactory 接口

```java
@Slf4j
public class UserClientFallback implements FallbackFactory<User> {
    @Override
    public ItemClient create(Throwable cause) {
        return new ItemClient() {
            @Override
            public List<User> queryItemByIds(Collection<Long> ids) {
                log.error("远程调用UserService#queryItemByIds方法出现异常，参数：{}", ids, cause);
                // 查询用户列表允许失败，查询失败，返回空集合
                return CollUtils.emptyList();
            }
        };
    }
}
```



#### 2. 注册 Bean

在配置类中将降级处理类注册为一个 Bean

```java
public class DefaultFeignConfig{
    @Bean
    public UserClientFallback userClientFallback(){
        return new UserClientFallback();
    } 
} 
```



#### 3. 指定降级逻辑

在相关的 OpenFeign 客户端上指定服务调用的降级逻辑

```java
@FeignClient(value = "user-service", 
             configuration = DefaultFeignConfig.class,
             fallbackFactory = UserClientFallback.class)
public class UserClienr{
    
    @GetMapping("/users")
    public List<User> queryItemByIds(Collection<Long> ids) ;
}
```



重启后，再次测试，发现被限流的请求不再报错，走了降级逻辑。





































