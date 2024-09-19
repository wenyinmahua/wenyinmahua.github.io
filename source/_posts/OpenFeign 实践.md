---
title: OpenFeign 实践
date: 2024-07-26
updated: 2024-08-19
tags: 
  - 实战
category: SpringCloud
comments: true
cover: https://ts2.cn.mm.bing.net/th?id=OIP-C.KgHvzGJ_yB1eB3vRjQ3eJAHaEK&w=333&h=187&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2
---
# OpenFeign 实践

OpenFeign 是一个声明式的 HTTP 客户端库，主要用于简化 HTTP API 的调用，通常与 Spring Cloud 生态系统一起使用。

> - OpenFeign 远程调用就像发送 HTTP 请求一样简单 。
> - OpenFeign 利用 SpringMVC 的相关注解来声明`请求方式`、`请求路径`、`请求参数`、`返回值类型`4个参数，然后基于动态代理生成远程调用的代码。
> - OpenFeign 不是一种传统的 RPC (Remote Procedure Call) 框架。
> - 尽管 OpenFeign 可以实现远程服务调用，但它的工作原理和传统 RPC 框架（如 Dubbo）有所不同，因为使用的是 HTTP 实现的远程调用。

> OpenFeign 需要进行如下操作：
>
> - 安装并开启 `Nacos` 注册中心
> - 引入并下载 `OpenFeign 依赖`以及负载均衡` loadbalancer `依赖
> - 通过 `@EnableFeignClients` 注解启动 OpenFeign
> - 编写 `FeignClient` 客户端
>   - 一个`接口`，里面编写的方法，类似于 Controller 层代码，具有着 RESTful 风格。
>   - 需要加上 `@FeignClient("server-name") `注解并配置服务名，方便在 Nacos 注册中心实现服务发现和调用相关服务。
> - 直接使用 `FeignClient` 客户端完成远程调用。
>
> FeignClient 和 调用者不在同一个 model 中时，可以通过在 `@EnableFeignClients` 注解中加上 basePackages 属性扫描 Feign 所在的包 



## OpenFeign 与 RPC 的区别

- **协议**：
  - OpenFeign 使用 HTTP 协议进行服务间通信，而传统的 RPC 框架如 Dubbo 使用专有的 RPC 协议。
- **调用方式**：
  - OpenFeign 的调用方式类似于 RESTful API 调用，使用 HTTP 方法（GET, POST, PUT, DELETE 等）和 URL 路径。
  - RPC 框架通常使用类似本地函数调用的方式，调用方直接调用远程服务的方法，而无需关心网络细节。
- **性能**：
  - RPC 框架通常提供更高的性能，因为它们通常使用二进制协议，减少了序列化/反序列化的开销。
  - OpenFeign 由于使用 HTTP 协议，可能不如 RPC 框架那样高效，尤其是在高吞吐量场景下。
- **服务治理**：
  - RPC 框架通常提供更丰富的服务治理功能，如服务版本控制、服务分组等。
  - OpenFeign 可以结合 Spring Cloud 的其他组件（如 Eureka、Hystrix 等）来实现服务治理。



## OpenFeign 入门

> 既然要实现远程调用，那么需要有三个角色：
>
> - 服务提供者：`provider-service`服务，提供根据 id 查询用户的服务。
> - 服务调用者：`caller-service`服务，需要远程调用 `provider-service` 提供的根据 id 查询用户的服务。
> - 注册中心：`Nacos` 注册中心管理提供了`服务注册`和`服务发现`的功能。



### 1. 引入依赖

在`服务调用者` caller-service 服务的 pom.xml 中引入 `OpenFeign` 的依赖和 `loadBalancer` 依赖：

```XML
  <!--openFeign-->
  <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-openfeign</artifactId>
  </dependency>
  <!--负载均衡器-->
  <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-loadbalancer</artifactId>
  </dependency>
```



### 2. 通过注解启动 OpenFeign

在主启动类上上加上如下注解，启动 OpenFeign 功能

```java
@EnableOpenFeignClients
```



### 3. 编写 OpenFeign 客户端

编写 OpenFeign 客户端，实际上是一个接口，之后就会发现什么叫做 **让远程调用像本地方法调用一样简单**

```java
@FeignClient("provider-service")
public interface ProviderClient {

    @GetMapping("/user")
    User queryUserById(@RequestParam("id") Long id);
}
```



接口中的几个关键信息：

- `@FeignClient("provider-service")` ：声明服务名称，这个服务与 Nacos 中注册的服务名称一致。
- `@GetMapping` ：声明请求方式
- `@GetMapping("/user")` ：声明请求路径
- `@RequestParam("id") Long id` ：声明请求参数
- `User` ：返回值类型

有了上述信息，OpenFeign 就可以利用动态代理实现这个方法，并且向 `http://provider-service/user` 发送一个 `GET` 请求，携带 `id` 为请求参数，并自动将返回值处理为 `User`。只需要直接调用这个方法，即可实现远程调用了。



### 4. 使用 OpenFeign 客户端

```java
@Resource
private ProviderClient ProviderClient;

@Overrider
public User getById(Long id){
    // 调用 OpenFeign 客户端
    User user = new User;
    user = providerClient.queryUserById(id);
    return user;
}
```

feign 完成了服务拉取、负载均衡、发送http请求的所有工作。



### 5. OpenFeign 日志配置

OpenFeign 只会在 FeignClient 所在包的日志级别为 **DEBUG** 时，才会输出日志。而且其日志级别有4级：

- **NONE**：不记录任何日志信息，这是默认值。
- **BASIC**：仅记录请求的方法，URL以及响应状态码和执行时间
- **HEADERS**：在BASIC的基础上，额外记录了请求和响应的头信息
- **FULL**：记录所有请求和响应的明细，包括头信息、请求体、元数据。

Feign默认的日志级别就是NONE，所以默认看不到请求日志。



#### 5.1 定义日志级别

注意这里并没有加上 @Configuration 相关的注解，而是通过`@EnableFeignClients`注解配置 `defaultConfiguration` 属性完成配置。 

```java
public class DefaultFeignConfig {
    @Bean
    public Logger.Level feignLogLevel(){
        return Logger.Level.FULL;
    }
}
```



#### 5.2 配置

接下来，要让日志级别生效，还需要配置这个类。有两种方式：

- **局部**生效：在某个`FeignClient`中配置，只对当前`FeignClient`生效

```Java
@FeignClient(value = "provider-service", configuration = DefaultFeignConfig.class)
```

- **全局**生效：在`@EnableFeignClients`中配置，针对所有`FeignClient`生效。

```Java
@EnableFeignClients(defaultConfiguration = DefaultFeignConfig.class)
```























