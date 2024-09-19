---
title: Nacos 实践
date: 2024-07-25
updated: 2024-07-27
tags: 
  - 实战
category: SpringCloud
comments: true
cover: https://ts1.cn.mm.bing.net/th?id=OIP-C.ICOYnUeFkm4f4DDBsk82sgHaDU&w=349&h=157&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2
---
# Nacos 实践

> **Nacos(Dynamic Naming and Configuration Service):** 一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。[Nacos官网](https://nacos.io/)



> 单体项目完成微服务拆分之后，如何找到并调用其他微服务提供的服务？
>
> 通过 Nacos 提供的服务注册和发现的功能来实现。
>
> - 需要使用 Docker 部署 Nacos 注册中心；（需要 MySQL 数据库存储数据）
> - 需要引入 nacos 服务注册发现的依赖；`spring-cloud-starter-alibaba-nacos-discovery`
> - 需要在 yml 文件中配置 Nacos 的地址`cloud.nacos.server-addr`
> - 启动服务之后便可发现该服务已经被注册到 Nacos 中了。
>
> 注意这里的服务发现是将一整个服务都注册到 Nacos 中，而不是服务的某个方法。
>
> - 服务发现通过 DiscoveryClient 对象发现服务实例列表，该对象已被 SpringCloud 自动装配
>   - 通过这个对象的 getInstances 方法可以拿到一个服务的示例列表 instances，通过 instances 的 get 方法使用负载均衡拿到一个实例

 

## PRC

**RPC：**服务之间的远程调用被称为 RPC（**R**emote **P**roduce **C**all），即远程过程调用。

在微服务远程调用的过程中，包括两个角色：

- 服务提供者：提供接口供其它微服务访问；
- 服务消费者：调用其它微服务提供的接口。

在大型微服务项目中，服务提供者的数量会非常多，为了管理这些服务就引入了**注册中心**的概念。注册中心、服务提供者、服务消费者三者间关系如下：

![注册中心、服务提供者、服务消费者三者间关系](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image.png)



流程如下：

- 服务启动时就会注册自己的服务信息**（服务名、IP、端口）**到注册中心；就确定了后期的 OpenFeign 可以通过服务名来实现远程调用；
- 调用者可以从注册中心订阅想要的服务，获取服务对应的实例列表（1个服务可能多实例部署）
- 调用者自己对实例列表负载均衡（随机、轮询），挑选一个实例；
- 调用者向该实例发起远程调用；



当服务提供者的实例宕机或者启动新实例时，调用者如何得知呢？

- 服务提供者会定期向注册中心发送请求，报告自己的健康状态（心跳请求）；
- 当注册中心长时间收不到提供者的心跳时，会认为该实例宕机，将其从服务的实例列表中剔除；
- 当服务有新实例启动时，会发送注册服务请求，其信息会被记录在注册中心的服务实例列表；
- 当注册中心服务列表变更时，会主动通知微服务，更新本地服务列表。





**为什么使用Nacos？**

在微服务架构中，随着服务数量的增多，服务之间的相互调用变得更加复杂，这就需要一个统一的**服务治理**平台来管理这些服务。Nacos 提供了一系列功能来解决这些问题。

> 服务治理：
>
> - 服务注册与发现
> - 负载均衡
> - 容错机制
> - 路由策略
> - 限流
> - 熔断
> - 服务健康检查
> - 服务版本管理
> - 安全性和认证
> - 监控与追踪

在微服务项目中，各个微服务之间需要进行远程调用RPC，而 Nacos 可以扮演 RPC 中的`注册中心`，实现服务的注册与发现、配置管理、健康检查。



**Nacos 能干什么？**

“Nacos 提供了一组简单易用的特性集，帮助您快速实现动态服务发现、服务配置、服务元数据及流量管理。”



> **Nacos 的特性：**
>
> - 服务发现和服务健康监测
> - 动态服务配置
> - 动态 DNS 服务
> - 服务及其元数据管理





## 1. Docker 安装 Nacos

接下来时Docker 从  0 开始部署 Nacos 



注意提前创建一个通用网络 `mahua`，保证容器通信不出问题，参考命令

```powershell
docker network create mahua
```

注意 Docker 需要提前准备好 Mysql，并加入 `mahua` 网络中



### 1.准备 MySQL 数据库表

> 准备MySQL数据库表，用来存储Nacos的数据。

[Nacos 的 MySQL 配置的 sql 文件](https://github.com/alibaba/nacos/blob/master/config/src/main/resources/META-INF/mysql-schema.sql)

复制里面的 sql 建表语句，黏贴到一个 naocs.sql 文件中

有数据库就将表 `nacos.sql` 上传到 root 目录下，之后直接导入数据库

```powershell
docker exec mysql mysql -u root -p123456 < /root/nacos.sql
```



没有数据库就参考 **Docker 部署 MySQL** 一文直接部署数据库



### 2.使用 Docker 安装 Nacos

准备一个 `custom.env` 文件，里面黏贴如下代码，注意修改 MySQL 所在的`虚拟机地址` 和 `密码`

```tex
PREFER_HOST_MODE=hostname
MODE=standalone
SPRING_DATASOURCE_PLATFORM=mysql
MYSQL_SERVICE_HOST=192.168.183.137
MYSQL_SERVICE_DB_NAME=nacos
MYSQL_SERVICE_PORT=3306
MYSQL_SERVICE_USER=root
MYSQL_SERVICE_PASSWORD=123456
MYSQL_SERVICE_DB_PARAM=characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai
```



将文件上传至虚拟机的 root 目录下，执行如下 Docker 指令

```powershell
docker run -d \
    --name nacos \
    --env-file ./nacos/custom.env \
    -p 8848:8848 \
    -p 9848:9848 \
    -p 9849:9849 \
    --restart=always \
    --network mahua \
    nacos/nacos-server:v2.1.0-slim
```



如果下载时间过慢，那么如果能找到 nacos 的压缩包（如：nacos.tar），直接使用压缩包加载镜像，之后再执行上述 Docker 指令创建并运行 nacos 容器实例。

```powershell
docker load -i nacos.tar
```



启动完成后，访问下面地址：http://192.168.183.137:8848/nacos/，注意将`192.168.183.137`替换为你自己的虚拟机IP地址。如果能跳转 Nacos 登录页，就说明 Nacos 部署成功了，Nacos 默认的登录账号和密码都是`nacos`.





## 2. 服务注册

> 如果想让别人使用自己提供的服务，那么就要想办法曝光自己的服务接口（服务注册）
>
> 假设 provider-service 作为服务的提供者， caller-service 作为服务的调用者。



**使用 Nacos 实现 `provider-serevice` 中相关的服务注册：**

打开 provider-service 项目

1. 在 pom.xml 文件中引入 Nacos 依赖

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```

这个依赖中同时包含了服务注册和发现的功能。因为任何一个微服务都可以调用别人，也可以被别人调用，即可以是调用者，也可以是提供者。

2. 在 applicatiom.yml 文件中配置 Nacos 所在的地址以及端口号

```yaml
spring:
  application:
    name: provider-service # 服务名称
  cloud:
    nacos:
      server-addr: 192.168.183.137:8848 # nacos地址
```

3. 启动服务实例，访问 nacos 控制台[http://192.168.183.137:8848/nacos/]，便可以发现服务注册成功。**需要注意自己的虚拟机地址。**





## 3. 服务发现

> 如果想要调用 Nacos 中注册的服务，就要找到该 Nacos 提供的服务在哪里（服务发现）
>
> 假设 provider-service 作为服务的提供者， caller-service 作为服务的调用者。



**使用 Nacos 实现 `caller-serevice` 调用 Nacos 中注册的 `provider-service` 服务：**

打开 caller-service 项目

1. 在 pom.xml 文件中引入 Nacos 依赖

```XML
<!--nacos 服务注册发现-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```

2. 在 applicatiom.yml 文件中配置 Nacos 所在的地址以及端口号

```yaml
spring:
  application:
    name: caller-service # 服务名称
  cloud:
    nacos:
      server-addr: 192.168.183.137:8848 # nacos地址
```

3. 通过 DiscoveryClient 根据去发现服务实例列表

```java
@Resource
private DiscoveryClient discoveryClient;

@Resource
private RestTemplate restTemplate;

// 假设 Nacos 里面注册了 多个 provider-service 服务
List<ServiceInstance> instances = discoverClient.getInstances("provider.service");
// 通过负载均衡算法拿到其中的一个实例
ServiceInstance instance = instances.get(RandomUtil.randomInt(instance.size()));
// 通过 RestTemplate 远程调用该接口(根据 id 获取用户)
ResponseEntity<User> response = restTemplate.exchange(
    instance.getUri() + "/user?id={id}",
    HttpMethon.GET, // 请求方式
    null, // 请求实体
    new ParameterizedTypeReference<User>() {}, // 返回值类型
    id
);
```



但是以上代码相比于单体项目（直接一行代码调用）而言确实过于复杂，有没有更简单的调用方式呢？

> 答案是有的，如 OpenFeign、Dubbo 等等，让**远程调用像本地方法调用一样简单**。



## 负载均衡

上述服务发现中提到了负载均衡，负载均衡指的是一个服务有多个实例，但是只需要使用其中的一个（从多个实例中挑选一个去访问）。

> 常见的负载均衡算法有：
>
> - 随机
> - 轮询
> - IP的hash
> - 最近最少访问
> - ...























































































































































































































问题解决：



[如何完美解决 “error pulling image configuration: download failed after attempts=6: dial tcp 59.188.250.54-腾讯云开发者社区-腾讯云 (tencent.com)](https://cloud.tencent.com/developer/article/2429585)



1. 打开 Docker 的配置文件

```bash
sudo nano /etc/docker/daemon.json
```



2.修改源为下面第二个

修改前：原阿里云镜像加速器地址

```json
{
  "registry-mirrors": ["https://XXXXXXXX.mirror.aliyuncs.com"]
}
```

修改后：

```json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```



3.保存配置文件，并重启Docker

```shell
sudo systemctl daemon-reload
sudo systemctl restart docker
```





































































































































































