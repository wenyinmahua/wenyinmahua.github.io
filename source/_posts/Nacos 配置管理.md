---
title: Nacos 配置管理
date: 2024-07-28
updated: 2024-07-28
tags: 
  - 实战
category: SpringCloud
comments: true
cover: https://ts1.cn.mm.bing.net/th?id=OIP-C.ICOYnUeFkm4f4DDBsk82sgHaDU&w=349&h=157&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2
---
# Nacos 配置管理

[Java SDK (nacos.io)](https://nacos.io/zh-cn/docs/sdk.html)

在开发微服务时出现了如下问题：

- 网关路由在配置文件中写死了，如果变更必须重启微服务
- 某些业务配置在配置文件中写死了，每次修改都要重启服务
- 每个微服务都有很多重复的配置，维护成本高

这些问题都可以通过统一的**配置管理器服务**解决。而 Nacos 不仅仅具备注册中心功能，也具备配置管理的功能：

![NacosPeizhi](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/NacosPeizhi.jpg)

微服务共享的配置可以统一交给 Nacos 保存和管理，在Nacos控制台修改配置后，Nacos 会将配置变更推送给相关的微服务，并且无需重启即可生效，实现配置热更新。

网关的路由同样是配置，因此同样可以基于这个功能实现动态路由功能，无需重启网关即可修改路由配置。



可以把微服务共享的配置抽取到 Nacos 中统一管理，这样就不需要每个微服务都重复配置了。分为两步：

- 在 Nacos 中添加共享配置
- 微服务拉取配置



## 1. 添加共享配置

在`配置管理`->`配置列表`中点击`+`新建一个配置：

![Nacos 新建配置](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729194049052.png)



在弹出的表单填写信息：

![Nacos 配置信息](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729194426334.png)

> 注意文件的dataId格式：
>
> ```Plain
> [配置名|服务名]-[spring.active.profile].[后缀名]
> ```
>
> 文件名称由三部分组成：
>
> - `配置名`：共享 jdbc 配置，所以是`shared-jdbc`
> - `spring.active.profile`：就是 spring boot 中的`spring.active.profile`，可以省略，则所有profile共享该配置
> - `后缀名`：例如yaml



```yaml
spring:
  datasource:
    url: jdbc:mysql://${my.db.host}:3306/${my.db.database}?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: root
    password: ${my.db.pw:123456}   # 默认值是 123456
mybatis-plus:
  configuration:
    default-enum-type-handler: com.baomidou.mybatisplus.core.handlers.MybatisEnumTypeHandler
  global-config:
    db-config:
      update-strategy: not_null
      id-type: auto
```





## 2. 拉取共享配置

> 在微服务拉取共享配置。将拉取到的共享配置与本地的`application.yaml`配置合并，完成项目上下文的初始化。

读取 Nacos 配置是 SpringCloud 上下文（`ApplicationContext`）初始化时处理的，发生在项目的引导阶段。然后才会初始化 SpringBoot 上下文，去读取 `application.yaml`。

SpringCloud 在初始化上下文的时候会先读取一个名为 `bootstrap.yaml` (或者 `bootstrap.properties`  )的文件，将 nacos 地址配置到 `bootstrap.yaml` 中，那么在项目引导阶段就可以读取 nacos 中的配置了。

![初始化上下文](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/bf5d376b-5493-4988-b6b4-2137709d7b63.jpg)



## 3. 整合 Nacos 配置管理

微服务整合 Nacos 配置管理的步骤如下：



### 3.1 引入依赖

引入如下配置：

```XML
  <!--nacos配置管理-->
  <dependency>
      <groupId>com.alibaba.cloud</groupId>
      <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
  </dependency>
  <!--读取bootstrap文件-->
  <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-bootstrap</artifactId>
  </dependency>
```



### 3.2 新建bootstrap.yaml

在 resources 目录新建一个 bootstrap.yaml 文件，内容如下：

```YAML
spring:
  application:
    name: my-service # 服务名称
  profiles:
    active: dev
  cloud:
    nacos:
      server-addr: 192.168.183.137 # nacos地址
      config:
        file-extension: yaml # 文件后缀名
        shared-configs: # 共享配置
          - dataId: shared-jdbc.yaml # 共享mybatis配置
```



### 3.3 修改application.yaml

由于一些配置挪到了bootstrap.yaml，因此application.yaml需要修改为：

```YAML
server:
  port: 8081
my:
  db:
    host: 192.168.183.137
    database: my-database
    pw: 123456
```



### 3.4 重启服务，使所有配置生效。





## 4. 配置热更新

**问题：**有很多的业务相关参数，将来可能会根据实际情况临时调整。这些业务相关参数可能写在 yml 配置文件中，但是，即便写在配置文件中，修改了配置还是需要重新打包、重启服务才能生效。能不能不用重启，直接生效呢？

> 这就要用到Nacos的配置热更新能力了，分为两步：
>
> - 在Nacos中添加配置
> - 在微服务读取配置



### 4.1 添加配置到 Nacos

![Nacos 热更新配置](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729200352128.png)

提交配置。



### 4.2 配置热更新

在微服务中读取配置，实现配置热更新。



1. 新建一个属性读取类

```java
@Data
@Component
@ConfigurationProperties(prefix = "mahua.my")
public class MyProperties {
    private String name;
}
```



2. 业务中使用该属性加载类

```java
public class MyServiceImpl implements MyService{
    @Resource
    private MyProperties myProperties;
    
    @Override
    public String SayMyName(){
        return myProperties.getName();
    }
} 
```

重启服务之后，测试，之后修改 name，无需重启服务，配置热更新就生效了！





## 5. 动态路由

> **网关**的路由配置全部是在项目启动时由`org.springframework.cloud.gateway.route.CompositeRouteDefinitionLocator`在项目启动的时候加载，并且一经加载就会缓存到内存中的路由表内（一个Map），不会改变。也不会监听路由变更，无法利用配置热更新来实现路由更新。

必须监听Nacos的配置变更，然后手动把最新的路由更新到路由表中。这里有两个难点：

- 如何监听Nacos配置变更？
- 如何把路由信息更新到路由表？



如果希望 Nacos 推送配置变更，可以使用 Nacos 动态监听配置接口来实现。

```Java
public void addListener(String dataId, String group, Listener listener)
```

请求参数说明：

| **参数名** | **参数类型** | **描述**                                                     |
| :--------- | :----------- | :----------------------------------------------------------- |
| dataId     | string       | 配置 ID，保证全局唯一性，只允许英文字符和 4 种特殊字符（"."、":"、"-"、"_"）。不超过 256 字节。 |
| group      | string       | 配置分组，一般是默认的DEFAULT_GROUP。                        |
| listener   | Listener     | 监听器，配置变更进入监听器的回调函数。                       |



### 5.1 引入依赖

在网关模块中引入如下依赖：

```XML
<!--统一配置管理-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
</dependency>
<!--加载bootstrap-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bootstrap</artifactId>
</dependency>
```



### 5.2 整理配置文件

1. 创建 bootstrap.yml 文件，补充内容如下

```YAML
spring:
  application:
    name: gateway
  cloud:
    nacos:
      server-addr: 192.168.150.101
```



2. 创建 application.yml 文件，补充内容如下：

```yaml
server:
  port: 8080 # 端口
```



### 5.3 定义路由信息

在 Nacos 控制台上添加路由，路由的文件格式为 `json` ，路由文件名为 `gateway-routes.json`

![网关路由配置](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240729212053420.png)

配置内容如下：

```json
[
    {
        "id": "provider",
        "predicates": [{
            "name": "Path",
            "args": {"_genkey_0":"/provider/**", "_genkey_1":"/search/**"}
        }],
        "filters": [],
        "uri": "lb://provider-service"
    },
    {
        "id": "caller、",
        "predicates": [{
            "name": "Path",
            "args": {"_genkey_0":"/caller/**"}
        }],
        "filters": [],
        "uri": "lb://caller-service"
    }
]
```



### 5.3 定义配置监听器

```java
@Slf4j
@Component
@RequiredArgsConstructor
public class DynamicRouteLoader {

    private final RouteDefinitionWriter writer;
    private final NacosConfigManager nacosConfigManager;

    // 路由配置文件的id和分组，这里也可以
    private final String dataId = "gateway-routes.json";
    private final String group = "DEFAULT_GROUP";
    // 保存更新过的路由id
    private final Set<String> routeIds = new HashSet<>();

    @PostConstruct
    public void initRouteConfigListener() throws NacosException {
        // 1.注册监听器并首次拉取配置
        String configInfo = nacosConfigManager.getConfigService()
                .getConfigAndSignListener(dataId, group, 5000, new Listener() {
                    @Override
                    public Executor getExecutor() {
                        return null;
                    }

                    @Override
                    public void receiveConfigInfo(String configInfo) {
                        updateConfigInfo(configInfo);
                    }
                });
        // 2.首次启动时，更新一次配置
        updateConfigInfo(configInfo);
    }

    private void updateConfigInfo(String configInfo) {
        log.debug("监听到路由配置变更，{}", configInfo);
        // 1.反序列化
        List<RouteDefinition> routeDefinitions = JSONUtil.toList(configInfo, RouteDefinition.class);
        // 2.更新前先清空旧路由
        // 2.1.清除旧路由
        for (String routeId : routeIds) {
            writer.delete(Mono.just(routeId)).subscribe();
        }
        routeIds.clear();
        // 2.2.判断是否有新的路由要更新
        if (CollUtils.isEmpty(routeDefinitions)) {
            // 无新路由配置，直接结束
            return;
        }
        // 3.更新路由
        routeDefinitions.forEach(routeDefinition -> {
            // 3.1.更新路由
            writer.save(Mono.just(routeDefinition)).subscribe();
            // 3.2.记录路由id，方便将来删除
            routeIds.add(routeDefinition.getId());
        });
    }
}

```



网关路由配置完成。

