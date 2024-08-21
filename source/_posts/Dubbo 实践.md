---
title: Dubbo 实践
date: 2024-07-25
updated: 2024-07-25
tags: 
   - 实战
category: Dubbo
comments: true
cover: https://tse3-mm.cn.bing.net/th/id/OIP-C.2YGuY0r8mqY9G52TWYvfgwHaER?w=257&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Dubbo 实践

> 总结：
>
> Dubbo 的主要配置有
>
> - maven 依赖：Dubbo、nacos-client 
> - yaml 的配置内容：dubbo 的 application、protocol、register
> - `@EnableDubbo`：开启 Dubbo 功能
> - `@DubboService`：主要用于服务端，注册为 Dubbo 服务
> - `@DubboReference` ： 主要用于消费端，从 Dubbo 获取了一个 RPC 订阅





> **Apache Dubbo** 是一款 RPC 服务开发框架，用于解决微服务架构下的服务治理与通信问题。
>
> **Dubbo 官网：**[Apache Dubbo](https://cn.dubbo.apache.org/zh-cn/)
>
> - 使用 Dubbo 开发的微服务原生具备相互之间的远程地址发现与通信能力， 利用 Dubbo 提供的丰富服务治理特性，可以实现诸如服务发现、负载均衡、流量调度等服务治理诉求。Dubbo 被设计为高度可扩展，用户可以方便的实现流量拦截、选址的各种定制逻辑。
> - Dubbo 提供了内置 RPC 通信协议实现，但它不仅仅是一款 RPC 框架。首先，它不绑定某一个具体的 RPC 协议，开发者可以在基于 Dubbo 开发的微服务体系中使用多种通信协议；其次，除了 RPC 通信之外，Dubbo 提供了丰富的服务治理能力与生态。
> - Dubbo 框架提供了自定义的高性能 RPC 通信协议：基于 HTTP/2 的 Triple 协议 和 基于 TCP 的 Dubbo2 协议。除此之外，Dubbo 框架支持任意第三方通信协议，如官方支持的 gRPC、Thrift、REST、JsonRPC、Hessian2 等，更多协议可以通过自定义扩展实现。这对于微服务实践中经常要处理的多协议通信场景非常有用。


Dubbo 可以帮助解决如下微服务实践问题：

- **微服务编程范式和工具**

Dubbo 支持基于 IDL 或语言特定方式的服务定义，提供多种形式的服务调用形式（如同步、异步、流式等）

- **高性能的 RPC 通信**

Dubbo 帮助解决微服务组件之间的通信问题，提供了基于 HTTP、HTTP/2、TCP 等的多种高性能通信协议实现，并支持序列化协议扩展，在实现上解决网络连接管理、数据传输等基础问题。

- **微服务监控与治理**

Dubbo 官方提供的服务发现、动态配置、负载均衡、流量路由等基础组件可以很好的帮助解决微服务基础实践的问题。除此之外，您还可以用 Admin 控制台监控微服务状态，通过周边生态完成限流降级、数据一致性、链路追踪等能力。

- **部署在多种环境**

Dubbo 服务可以直接部署在容器、Kubernetes、Service Mesh等多种架构下。

- **活跃的社区**

Dubbo 项目托管在 Apache 社区，有来自国际、国内的活跃贡献者维护着超 10 个生态项目，贡献者包括来自海外、阿里巴巴、工商银行、携程、蚂蚁、腾讯等知名企业技术专家，确保 Dubbo 及时解决项目缺陷、需求及安全漏洞，跟进业界最新技术发展趋势。

- **庞大的用户群体**

Dubbo3 已在阿里巴巴成功落地，实现了对老版本 HSF2 框架全面升级，成为阿里集团面向云原生时代的统一服务框架底座，庞大的用户群体是 Dubbo 保持稳定性、需求来源、先进性的基础。



## 基于 Spring Boot Starter 开发微服务应用

> 与 RPC 概念类似，RPC 需要服务提供者、服务调用者，而Dubbo 项目最少有三个子模块：
>
> - **interface：**共享 API 模块
>   - 通过接口，消费者知道如何调用服务，而提供者知道如何实现服务。
> - **consumer：**消费者模块
>   - 消费者使用 Dubbo 的客户端 API 来调用服务，不需要关心服务的具体位置和实现细节。
> - **provider：**服务端模块
>   - 提供者负责实现接口定义的方法，并将服务发布到 Dubbo 注册中心，以便被消费者发现和调用。
>
> > 其中 `interface` 模块被 `consumer` 和 `provider` 两个模块共同依赖，存储 RPC 通信使用的 API 接口。
>
> 此外，Dubbo 还需要通过注册中心实现服务的注册与发现等服务治理功能。



### 1.准备项目架构：

1. 搭建基础项目，创建 `dubbo-spring-boot-demo-interface` 、`dubbo-spring-boot-demo-provider` 和 `dubbo-spring-boot-demo-consumer` 三个子模块。



2. 创建了三个子模块之后，需要创建一下几个文件夹：
   1. 在 `dubbo-spring-boot-demo-consumer/src/main/java` 下创建 `org.apache.dubbo.springboot.demo.consumer` package
   2. 在 `dubbo-spring-boot-demo-interface/src/main/java` 下创建 `org.apache.dubbo.springboot.demo` package
   3. 在 `dubbo-spring-boot-demo-provider/src/main/java` 下创建 `org.apache.dubbo.springboot.demo.provider` package



如图所示：

<img src="https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240731190214872.png" alt="Dubbo 项目架构" style="zoom:80%;" />



### 2.增加 maven 依赖

以 Nacos 注册中心为例

```java
<dependency>
    <groupId>org.apache.dubbo</groupId>
    <artifactId>dubbo</artifactId>
    <version>3.0.9</version>
</dependency>
<dependency>
    <groupId>com.alibaba.nacos</groupId>
    <artifactId>nacos-client</artifactId>
    <version>2.1.0</version>
</dependency>
```



### 3. 定义服务接口

服务接口是 Dubbo 中沟通消费端和服务端的桥梁。

在 `dubbo-spring-boot-demo-interface` 模块的 `org.apache.dubbo.samples.api` 下建立 `DemoService` 接口，定义如下：

```java
package org.apache.dubbo.springboot.demo.api;

public interface DemoService {

    String printName(String name);
}
```

在 `DemoService` 中，定义了 `printName` 这个方法。后续服务端发布的服务，消费端订阅的服务都是围绕着 `DemoService` 接口展开的。



### 4.定义服务端实现以及消费端调用

**服务端实现：**

定义服务接口之后，可以在服务端这一侧定义对应的**实现**，这部分的实现相对于消费端来说是远端的实现，本地没有相关的信息。

在`dubbo-spring-boot-demo-provider` 模块的 `org.apache.dubbo.samples.provider` 下建立 `DemoServiceImpl` 类，定义如下：

```java
package org.apache.dubbo.springboot.demo.provider;

import org.apache.dubbo.config.annotation.DubboService;
import org.apache.dubbo.springboot.demo.api.DemoService;

@DubboService
public class DemoServiceImpl implements DemoService {
	@Override
	public String printName(String name) {
		return "my name is：" +name;
	}
}
```

> 注：
>
> - 在`DemoServiceImpl` 类中添加了 `@DubboService` 注解，通过这个配置可以基于 Spring Boot 去发布 Dubbo 服务。



**消费端调用：**

> - **@DubboReference:**这个注解用于声明 demoService 是一个远程服务引用，即 demoService 将从 Dubbo 注册中心查找并引用一个远程的服务实例。
> - **实现 CommandLineRunner 接口：**Task 类实现了 CommandLineRunner 接口，这意味着当应用启动完成之后，Spring 会调用 run 方法。这个方法通常用于执行一些初始化任务或命令行参数处理。

在 `dubbo-spring-boot-demo-consumer` 模块的 `org.apache.dubbo.springboot.demo.consumer` 下建立 `Task` 类，定义如下：

```java
package org.apache.dubbo.springboot.demo.consumer;

import org.apache.dubbo.config.annotation.DubboReference;
import org.apache.dubbo.springboot.demo.api.DemoService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class Task implements CommandLineRunner {
    @DubboReference
    private DemoService demoService;

    @Override
    public void run(String... args){
        String result = demoService.printName("mahua");
        System.out.println("Receive result ======> " + result);
    }
}
```





### 5. 配置yml 配置文件

> 配置 服务端 和 消费端 的yml文件

```YML
server:
  port: 8081
dubbo:
  application:
    name: dubbo-springboot-demo-consumer
  protocol:
    name: dubbo # 指定 Dubbo 使用的通信协议
    port: -1 # 指定 Dubbo 服务暴露的端口。-1 表示不指定具体端口，Dubbo 将随机选择一个可用端口。
  registry:
    id: nacos-registry
    address: nacos://192.168.183.137:8848
```

在这个配置文件中，定义了 Dubbo 的应用名、Dubbo 协议信息、Dubbo 使用的注册中心地址。



### 6.基于 Spring 配置启动类

> 配置服务端和消费端的启动类
>
> - 在 `dubbo-spring-boot-demo-provider` 模块的 `org.apache.dubbo.springboot.demo.provider` 下建立 `ProviderApplication` 类，定义如下；
> - 使用 `@EnableDubbo` 注解开启 Dubbo 的功能。

```java
package org.apache.dubbo.springboot.demo.provider;

import org.apache.dubbo.config.spring.context.annotation.EnableDubbo;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableDubbo
public class ProviderApplication {
    public static void main(String[] args) {
       SpringApplication.run(ProviderApplication.class,args);
    }
}
```



最终项目结构如图：

<img src="https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240731195735358.png" alt="Dubbo 项目最终结构" style="zoom:67%;" />



### 7.启动应用

启动项目后，可以在消费端的控制台看到结果如图所示：

![结果](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240731195932951.png)

> 先启动服务端，后启动消费端。



打开 Nacos 控制台可以看到服务已经注册成功了：

![Dubbo 服务注册到 Nacos 中](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240731212809487.png)