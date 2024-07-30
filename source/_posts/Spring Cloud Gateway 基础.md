---
title: Spring Cloud Gateway 基础
date: 2024-05-27
updated: 2024-05-27
tags: 
  - 基础
category: SpringCloud
comments: true
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.WS81HpzJpyOwdEy8Tw1RHgAAAA?w=302&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Spring Cloud Gateway 基础

> **Spring Cloud Gateway：**基于 Spring 的 WebFlux 技术，完全支持响应式编程，吞吐能力更强。
>
> 官网：[Spring Cloud Gateway](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/)
>
> **Gateway：**网关，Spring 世界的边境检查站。
>
> - **网关**：**网**络的**关**口。数据在网络间传输，从一个网络传输到另一网络时就需要经过网关来做数据的**路由和转发以及数据安全的校验**。
> - **路由：**判断选择服务的地址。



**前端请求不能直接访问微服务，而是要请求网关：**

- 网关可以做安全控制，也就是登录身份校验，校验通过才放行
- 通过认证后，网关再根据请求判断应该访问哪个微服务，将请求转发过去



![网关](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/download_image.jpg)



## Spring Cloud Gateway的角色



1. **统一入口：**
   - 类似于边境检查站是进入一个国家的第一个接触点，Spring Cloud Gateway 作为微服务架构的统一入口，处理所有的外部请求。
2. **路由转发：**
   - 边境检查站会指引旅客前往不同的目的地，Spring Cloud Gateway 则根据预定义的规则将请求路由到正确的微服务。
3. **权限验证：**
   - 边境检查站需要验证旅客的身份，Spring Cloud Gateway 可以执行类似的功能，比如进行身份验证和授权检查。
4. **监控和日志记录：**
   - 边境检查站记录进出人员的信息，Spring Cloud Gateway 也可以记录请求的详细信息，用于监控和调试。
5. **安全保护：**
   - 边境检查站保护国家不受非法入侵，Spring Cloud Gateway同样可以提供安全防护措施，例如DDoS防护、限流、熔断等。
6. **其他非业务逻辑处理：**
   - 除了上述功能外，Spring Cloud Gateway还可以处理一些非业务相关的逻辑，如缓存、压缩、重试策略等。



## Spring Cloud Gateway 入门

Spring Cloud Gateway 通常是一个微服务中新的 module 。在这个 module 中完成 Spring Cloud Gateway  需要实现的功能，如路由转发、权限校验等。



### 依赖

```xml
<!--网关-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
<!--负载均衡-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-loadbalancer</artifactId>
</dependency>
```



### 路由规则示例

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: my_route
          uri: lb://my-service
          predicates:
            - Path=/api/my-service/**
          filters:
            - AddRequestHeader=key, value
            - RewritePath=/api/my-service/(?<segment>.*), /$\{segment}
```

> 在这个示例中，由 yaml 语法可以看出 routers 是一个集合，可以定义很多路由规则，其中的四个属性含义如下：
>
> - `id`: `my_route` 是该路由规则的唯一标识符。
>
> - `uri`: `lb://my-service` 表示通过负载均衡方式访问名为 `my-service` 的服务。
>
> - `predicates`: `- Path=/api/my-service/**` 表示任何以 `/api/my-service/` 开头的URL路径都会匹配此路由。
>
> - `filters`:
>   - `- AddRequestHeader=key, value` 会在每个请求上添加一个名为`key`的HTTP头，其值为`value`。
>   - `- RewritePath=/api/my-service/(?<segment>.*), /$\{segment}` 会重写路径，去掉前缀`/api/my-service/`。
>
> 这样配置后，所有符合 `/api/my-service/**` 模式的请求都将被转发到 `my-service` 服务，并且在转发之前会添加一个额外的请求头，并对路径进行重写。



**Spring Cloud Gateway** 中支持的断言 `predicates` 类型有很多：

| **名称**   | **说明**                       | **示例**                                                     |
| :--------- | :----------------------------- | :----------------------------------------------------------- |
| After      | 是某个时间点后的请求           | - After=2037-01-20T17:42:47.789-07:00[America/Denver]        |
| Before     | 是某个时间点之前的请求         | - Before=2031-04-13T15:14:47.433+08:00[Asia/Shanghai]        |
| Between    | 是某两个时间点之前的请求       | - Between=2037-01-20T17:42:47.789-07:00[America/Denver], 2037-01-21T17:42:47.789-07:00[America/Denver] |
| Cookie     | 请求必须包含某些cookie         | - Cookie=chocolate, ch.p                                     |
| Header     | 请求必须包含某些header         | - Header=X-Request-Id, \d+                                   |
| Host       | 请求必须是访问某个host（域名） | - Host=**.somehost.org,**.anotherhost.org                    |
| Method     | 请求方式必须是指定方式         | - Method=GET,POST                                            |
| Path       | 请求路径必须符合指定规则       | - Path=/red/{segment},/blue/**                               |
| Query      | 请求参数必须包含指定参数       | - Query=name, Jack或者- Query=name                           |
| RemoteAddr | 请求者的ip必须是指定范围       | - RemoteAddr=192.168.1.1/24                                  |
| weight     | 权重处理                       |                                                              |



### 网关过滤器

以登录校验为例，登录校验必须在请求转发到微服务之前做，否则就失去了意义。而网关的请求转发是`Gateway`内部代码实现的，要想在请求转发之前做登录校验，就必须了解`Gateway`内部工作的基本原理。

<img src="https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729151442566.png" alt="网关过滤器" style="zoom:90%;" />

如图所示：

1. 客户端请求进入网关后由 `HandlerMapping` 对请求做判断，找到与当前请求匹配的路由规则（`Route`），然后将请求交给 `WebHandler` 去处理。
2. `WebHandler` 则会加载当前路由下需要执行的过滤器链（**`Filter chain`**），然后按照顺序逐一执行过滤器`Filter`。
3. 图中 `Filter` 被虚线分为左右两部分，是因为`Filter`内部的逻辑分为`pre`和`post`两部分，分别会在请求路由到微服务**之前**和**之后**被执行。
4. 只有所有`Filter`的`pre`逻辑都依次顺序执行通过后，请求才会被路由到微服务。
5. 微服务返回结果后，再倒序执行`Filter`的`post`逻辑。
6. 最终把响应结果返回。

如图中所示，最终请求转发是有一个名为`NettyRoutingFilter`的过滤器来执行的，而且这个过滤器是整个过滤器链中顺序最靠后的一个。**如果能定义一个过滤器，在其中实现登录校验逻辑，并且将过滤器执行顺序定义到`NettyRoutingFilter`之前**，那么就能满足登录校验需求。

> NettyRoutingFilter 的作用:
>
> 1. **路由决策：**
>    - 根据定义好的路由规则和请求的元数据（如URL、方法类型等），`NettyRoutingFilter`决定哪个服务应该接收这个请求。
> 2. **负载均衡：**
>    - 当路由目标是带有`lb://`前缀的服务名时，`NettyRoutingFilter`会从服务发现组件获取服务实例列表，并使用负载均衡策略选择一个实例进行请求转发。
> 3. **过滤器链应用：**
>    - 在请求被路由之前或之后，`NettyRoutingFilter`会应用相应的过滤器链。这些过滤器可以用来修改请求或响应，执行安全检查，添加或修改HTTP头等。
>
> 
>
> 内部工作流程：
>
> 1. **请求到达：**
>    - 当请求到达Spring Cloud Gateway时，`NettyRoutingFilter`首先检查是否有匹配的路由规则。
> 2. **匹配路由规则：**
>    - 使用路由断言（`predicates`）来判断请求是否符合某条路由规则。如果符合，则继续处理；否则，将请求传递给下一个过滤器或返回错误响应。
> 3. **应用过滤器：**
>    - 对于匹配的路由规则，`NettyRoutingFilter`会应用该路由规则定义的过滤器。过滤器可以修改请求或响应。
> 4. **负载均衡选择：**
>    - 如果路由目标是服务名称加上`lb://`前缀，`NettyRoutingFilter`会从服务发现组件获取服务实例列表，并选择一个实例进行转发。
> 5. **转发请求：**
>    - 请求最终被转发到选定的服务实例。



网关过滤器链中的过滤器有两种：

- `GatewayFilter`：路由过滤器，作用范围比较灵活，可以是任意指定的路由`Route`. 
- `GlobalFilter`：全局过滤器，作用范围是所有路由，不可配置。

> **注意**：过滤器链之外还有一种过滤器，HttpHeadersFilter，用来处理传递到下游微服务的请求头。例如org.springframework.cloud.gateway.filter.headers.XForwardedHeadersFilter可以传递代理请求原本的host头到下游微服务。



`GatewayFilter`和`GlobalFilter`这两种过滤器的方法签名完全一致：

```Java
/**
 * 处理请求并将其传递给下一个过滤器
 * @param exchange 当前请求的上下文，其中包含request、response等各种数据
 * @param chain 过滤器链，基于它向下传递请求
 * @return 根据返回值标记当前请求是否被完成或拦截，chain.filter(exchange)就放行了。
 */
Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain);
```

`FilteringWebHandler`在处理请求时，会将`GlobalFilter`装饰为`GatewayFilter`，然后放到同一个过滤器链中，排序以后依次执行。





### 自定义过滤器

#### 1. 自定义 GateWayFilter

##### 1. 自定义过滤器类

> - 自定义`GatewayFilter`需要实现`AbstractGatewayFilterFactory`。
> - 自定义过滤器类的名称一定要以`GatewayFilterFactory`为后缀！
>   - Spring Cloud Gateway 在装配过滤器时，会根据约定自动识别和加载以 GatewayFilterFactory 结尾的类。这样可以避免手动配置或者指定类名，符合 Spring 的自动化装配机制。
> - 当前过滤器执行完成后，要调用过滤器链中的下一个过滤器。



```java
@Component
public class PrintAnyGatewayFilterFactory extends AbstractGatewayFilterFactory<Object> {
    @Override
    public GatewayFilter apply(Object config) {
        return new GatewayFilter() {
            @Override
            public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
                // 获取请求
                ServerHttpRequest request = exchange.getRequest();
                // 编写过滤器逻辑
                System.out.println("过滤器执行了");
                // 放行
                return chain.filter(exchange);
            }
        };
    }
}
```

> public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) 解释：
>
> - `exchange` 对象是网关内部上下文对象，用来保存网关内部共享的数据的，比如说 request、response、session或者是一些自定义的共享属性等等。所有的过滤器都可以从这个对象中存入数据也可以读取数据。
> - `chain` 这个对象是网关过滤器对象，当前过滤器执行完成后，要调用过滤器链中的下一个过滤器。



##### 2. 配置 yaml 文件

```yaml
spring:
  cloud:
    gateway:
      default-filters:
            - PrintAny # 此处直接以自定义的 GatewayFilterFactory 类名称前缀类声明过滤器
```



#### 2.自定义 GlobalFilter 

> 自定义 GlobalFilter 直接实现 `GlobalFilter` 即可
>
> 可以通过实现 Ordered 接口，重写 getOrder 方法来设置过滤器的执行顺序

```Java
@Component
public class PrintAnyGlobalFilter implements GlobalFilter, Ordered {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 编写过滤器逻辑
        System.out.println("未登录，无法访问");
        // 放行
        if(true){
        	return chain.filter(exchange);  
        }
        // 拦截
        ServerHttpResponse response = exchange.getResponse();
        response.setRawStatusCode(401);
        return response.setComplete();
    }

    @Override
    public int getOrder() {
        // 过滤器执行顺序，值越小，优先级越高
        return 0;
    }
}
```

