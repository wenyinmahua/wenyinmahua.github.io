---
title: Seata 实践
date: 2024-06-02
updated: 2024-06-02
tags: 
  - 实战
category: SpringCloud
comments: true
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.z8NU3Nl2sLqS6vu3GFncIAAAAA?w=290&h=141&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Seata 实践

>Seata 是一款开源的分布式事务解决方案，致力于提供高性能和简单易用的分布式事务服务。Seata 将为用户提供了 AT、TCC、SAGA 和 XA 事务模式，为用户打造一站式的分布式解决方案。
>
>官网：[Apache Seata](https://seata.apache.org/zh-cn/)
>
>1. **AT 模式（Automatic Transaction mode）：**AT 模式是 Seata 默认推荐使用的模式，它简化了开发人员的工作量，实现了自动化的两阶段提交过程。在 AT 模式下，Seata 会自动记录分支事务中的 SQL 语句及其参数，生成对应的补偿 SQL（用于回滚）。当全局事务提交时，所有分支事务都会被提交；当全局事务回滚时，Seata 会自动执行补偿 SQL 来撤销已提交的更改。
>2. **TCC 模式（Try-Confirm-Cancel mode）：**TCC 模式要求应用程序显式地定义三个方法：`Try`、`Confirm` 和 `Cancel`。`Try` 方法用于预留资源，`Confirm` 方法用于确认预留的资源，而 `Cancel` 方法则用于释放或回滚预留的资源。在 TCC 模式下，应用程序需要自己实现这三个方法来支持分布式事务。
>3.  **SAGA 模式：**Seata 的 SAGA 模式是一种基于 Saga 设计模式的实现。在这种模式下，一个业务流程可以被分解为多个子事务（Saga 步骤），每个步骤都是一个本地事务。如果任何步骤失败，那么之前成功的步骤都需要执行补偿操作来恢复系统状态。Seata 通过跟踪事务链路并执行补偿操作来管理 Saga 的执行流程。
>4. **XA模式：**XA 协议是一个标准的两阶段提交协议，它为分布式事务提供了一种标准化的方法。Seata 的 XA 模式遵循这一标准，但在实际应用中，由于 XA 协议的性能瓶颈和兼容性问题，它通常不是首选方案。



>相关概念：
>
>- **两阶段提交：**是最传统的分布式事务处理方法之一，涉及准备阶段和提交阶段。在准备阶段，所有参与者都准备好提交或回滚事务；在提交阶段，协调者根据所有参与者的反馈决定提交还是回滚整个事务。虽然这种方法可以保证强一致性，但它的性能较差，且容易产生死锁。
>- **Saga：**Saga 是一种用于处理分布式事务的设计模式，它将一个大的事务分解为多个局部事务（称为 Saga 步骤），并通过补偿操作来处理失败情况。每个步骤都是一个本地事务，如果某个步骤失败，则通过执行相反的操作（补偿操作）来回滚之前的所有步骤。
>  - **Saga 的实现方式：**
>    - **Orchestration (编排)**: 有一个中心协调器负责协调 Saga 中各个步骤的执行顺序以及在失败时触发补偿操作。
>    - **Choreography (编舞)**: 每个服务独立地决定何时执行下一步及如何处理失败情况，无需中心协调器。
>- **最终一致性：**对于不需要强一致性的场景，可以通过最终一致性的方式来实现。这种方法不依赖于事务来保证一致性，而是通过消息队列、事件发布/订阅等方式异步地更新数据状态。例如，当一个服务完成操作后，它可以将一个事件发送到消息队列，其他服务监听这些事件并在适当的时候做出响应。



**关于分布式事务：**

- **分支事务：**每个微服务的本地事务。
- **全局事务：**多个有关联的复制事务的集合。

> 分支事务能满足 ACID 特性，但是全局事务跨越多个服务、多个数据库，需要借助其他手段（如 Seata）才能满足 ACID 特性。
>
> - ACID 是 Atomicity（原子性）、Consistency（一致性）、Isolation（隔离性）和 Durability（持久性）的缩写。



分布式事务不会遵循ACID的原则，归其原因就是参与事务的多个子业务在不同的微服务，跨越了不同的数据库。虽然每个单独的业务都能在本地遵循ACID，但是它们互相之间没有感知，不知道有人失败了，无法保证最终结果的统一，也就无法遵循ACID的事务特性了。

这就是分布式事务问题，出现以下情况之一就可能产生分布式事务问题：

- 业务跨多个服务实现
- 业务跨多个数据源实现





> **Seata 的工作原理**
>
> - **服务端组件 (Server)**: Seata 的服务端组件负责协调全局事务的提交或回滚。
> - **客户端组件 (Client)**: Seata 的客户端组件集成到各个服务中，负责与服务端通信，并管理分支事务。
> - **资源管理器 (ResourceManager)**: 负责管理分支事务的状态，包括记录事务的日志、补偿逻辑等。
> - **事务管理器 (Transaction Manager)**: 负责发起全局事务，并管理全局事务的生命周期。



> **Seata 术语**
>
>  TC (Transaction Coordinator) - 事务协调者
>
> - 维护全局和分支事务的状态，驱动全局事务提交或回滚。
>
> TM (Transaction Manager) - 事务管理器
>
> - 定义全局事务的范围：开始全局事务、提交或回滚全局事务。
>
> RM (Resource Manager) - 资源管理器
>
> - 管理分支事务处理的资源，与TC交谈以注册分支事务和报告分支事务的状态，并驱动分支事务提交或回滚。



Seata 工作架构图![Seata 工作架构图](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/e931c59e-cb61-4072-a6ef-b06c5c4a9553.png)

其中，**TM **和 **RM** 可以理解为 Seata 的客户端部分，引入到参与事务的微服务依赖中即可。将来 **TM** 和 **RM** 就会协助微服务，实现本地分支事务与 **TC** 之间交互，实现事务的提交或回滚。

而 **TC** 服务则是事务协调中心，是一个独立的微服务，需要单独部署。

> - TM 请求 TC 开启一个全局事务。TC 会生成一个 **XID** 作为该全局事务的编号。
>
>   > **XID**，会在微服务的调用链路中传播，保证将多个微服务的子事务关联在一起。
>
> - RM 请求 TC 将本地事务注册为全局事务的分支事务，通过全局事务的 **XID** 进行关联。
>
> - TM 请求 TC 告诉 **XID** 对应的全局事务是进行提交还是回滚。
>
> - TC 驱动 RM 们将 **XID** 对应的自己的本地事务进行提交还是回滚。



## 1. 部署 TC Server

参考：[Docker部署 | Apache Seata](https://seata.apache.org/zh-cn/docs/ops/deploy-by-docker)



因为 TC 需要进行全局事务和分支事务的记录，所以需要对应的**存储**。目前，TC 有两种存储模式( `store.mode` )：

- file 模式：适合**单机**模式，全局事务会话信息在**内存**中读写，并持久化本地文件 `root.data`，性能较高。
- db 模式：适合**集群**模式，全局事务会话信息通过 **db** 共享，相对性能差点。



### 1.准备数据库表

初始化数据库：[Seata 极简入门 | 集群部署初始化数据库](https://seata.apache.org/zh-cn/blog/seata-quick-start/#32-初始化数据库)

```mysql
CREATE DATABASE IF NOT EXISTS `seata`;
USE `seata`;


CREATE TABLE IF NOT EXISTS `global_table`
(
    `xid`                       VARCHAR(128) NOT NULL,
    `transaction_id`            BIGINT,
    `status`                    TINYINT      NOT NULL,
    `application_id`            VARCHAR(32),
    `transaction_service_group` VARCHAR(32),
    `transaction_name`          VARCHAR(128),
    `timeout`                   INT,
    `begin_time`                BIGINT,
    `application_data`          VARCHAR(2000),
    `gmt_create`                DATETIME,
    `gmt_modified`              DATETIME,
    PRIMARY KEY (`xid`),
    KEY `idx_status_gmt_modified` (`status` , `gmt_modified`),
    KEY `idx_transaction_id` (`transaction_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


CREATE TABLE IF NOT EXISTS `branch_table`
(
    `branch_id`         BIGINT       NOT NULL,
    `xid`               VARCHAR(128) NOT NULL,
    `transaction_id`    BIGINT,
    `resource_group_id` VARCHAR(32),
    `resource_id`       VARCHAR(256),
    `branch_type`       VARCHAR(8),
    `status`            TINYINT,
    `client_id`         VARCHAR(64),
    `application_data`  VARCHAR(2000),
    `gmt_create`        DATETIME(6),
    `gmt_modified`      DATETIME(6),
    PRIMARY KEY (`branch_id`),
    KEY `idx_xid` (`xid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


CREATE TABLE IF NOT EXISTS `lock_table`
(
    `row_key`        VARCHAR(128) NOT NULL,
    `xid`            VARCHAR(128),
    `transaction_id` BIGINT,
    `branch_id`      BIGINT       NOT NULL,
    `resource_id`    VARCHAR(256),
    `table_name`     VARCHAR(32),
    `pk`             VARCHAR(36),
    `status`         TINYINT      NOT NULL DEFAULT '0' COMMENT '0:locked ,1:rollbacking',
    `gmt_create`     DATETIME,
    `gmt_modified`   DATETIME,
    PRIMARY KEY (`row_key`),
    KEY `idx_status` (`status`),
    KEY `idx_branch_id` (`branch_id`),
    KEY `idx_xid_and_branch_id` (`xid` , `branch_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `distributed_lock`
(
    `lock_key`       CHAR(20) NOT NULL,
    `lock_value`     VARCHAR(20) NOT NULL,
    `expire`         BIGINT,
    primary key (`lock_key`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('AsyncCommitting', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryCommitting', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryRollbacking', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('TxTimeoutCheck', ' ', 0);
```



### 2. Docker 部署

需要注意，要确保nacos、mysql都在 mahua 网络中。如果某个容器不再hm-net网络，可以参考下面的命令将某容器加入指定网络：

```Shell
docker network connect [网络名] [容器名]
```



#### 自定义配置文件

自定义配置文件需要通过挂载文件的方式实现，将宿主机上的 `application.yml` 挂载到容器中相应的目录

首先启动一个用户将resources目录文件拷出的临时容器

```powershell
docker run -d 
	-p 8091:8091 
	-p 7091:7091  
	--name seata-serve 
seataio/seata-server:latest

docker cp seata-serve:/seata-server/resources /User/seata/config
```



拷出后可以,可以选择修改 application.yml 再 cp 进容器,或者 rm 临时容器,如下重新创建,并做好映射路径设置

- 指定 application.yml

```bash
$docker run --name seata-server \
        -p 8091:8091 \
        -p 7091:7091 \
        -e SEATA_IP=192.168.183.137 \
        -v /User/seata/config:/seata-server/resources  \
        --privileged=true \
		--network mahua \
		-d \
        seataio/seata-server:1.5.2
```

接下来可以看到宿主机对应目录下已经有了,logback-spring.xml,application.example.yml,application.yml ，接下来就很简单了,只需要修改 application.yml 即可,详细配置可以参考 application.example.yml ,该文件存放了所有可使用的详细配置。

> 需要修改 application.yml 文件中的数据库连接密码

```YAML
server:
  port: 7091

spring:
  application:
    name: seata-server

logging:
  config: classpath:logback-spring.xml
  file:
    path: ${user.home}/logs/seata
  # extend:
  #   logstash-appender:
  #     destination: 127.0.0.1:4560
  #   kafka-appender:
  #     bootstrap-servers: 127.0.0.1:9092
  #     topic: logback_to_logstash

console:
  user:
    username: admin
    password: admin

seata:
  config:
    # support: nacos, consul, apollo, zk, etcd3
    type: file
    # nacos:
    #   server-addr: nacos:8848
    #   group : "DEFAULT_GROUP"
    #   namespace: ""
    #   dataId: "seataServer.properties"
    #   username: "nacos"
    #   password: "nacos"
  registry:
    # support: nacos, eureka, redis, zk, consul, etcd3, sofa
    type: nacos
    nacos:
      application: seata-server
      # nacos 已经加入了 Docker 网络，这时使用 nacos 代替 nacos 的地址
      server-addr: nacos:8848
      group : "DEFAULT_GROUP"
      namespace: ""
      username: "nacos"
      password: "nacos"
#  server:
#    service-port: 8091 #If not configured, the default is '${server.port} + 1000'
  security:
    secretKey: SeataSecretKey0c382ef121d778043159209298fd40bf3850a017
    tokenValidityInMilliseconds: 1800000
    ignore:
      urls: /,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/api/v1/auth/login
  server:
    # service-port: 8091 #If not configured, the default is '${server.port} + 1000'
    max-commit-retry-timeout: -1
    max-rollback-retry-timeout: -1
    rollback-retry-timeout-unlock-enable: false
    enable-check-auth: true
    enable-parallel-request-handle: true
    retry-dead-threshold: 130000
    xaer-nota-retry-timeout: 60000
    enableParallelRequestHandle: true
    recovery:
      committing-retry-period: 1000
      async-committing-retry-period: 1000
      rollbacking-retry-period: 1000
      timeout-retry-period: 1000
    undo:
      log-save-days: 7
      log-delete-period: 86400000
    session:
      branch-async-queue-size: 5000 #branch async remove queue size
      enable-branch-async-remove: false #enable to asynchronous remove branchSession
  store:
    # support: file 、 db 、 redis
    mode: db
    session:
      mode: db
    lock:
      mode: db
    db:
      datasource: druid
      db-type: mysql
      driver-class-name: com.mysql.cj.jdbc.Driver
      # 由于使用了 Docker 部署了 mysql ，这里的 mysql 可以找到相关 mysql 的网络
      url: jdbc:mysql://mysql:3306/seata?rewriteBatchedStatements=true&serverTimezone=UTC
      user: root
      # 需要修改这里
      password: "123456"
      min-conn: 10
      max-conn: 100
      global-table: global_table
      branch-table: branch_table
      lock-table: lock_table
      distributed-lock-table: distributed_lock
      query-limit: 1000
      max-wait: 5000
    # redis:
    #   mode: single
    #   database: 0
    #   min-conn: 10
    #   max-conn: 100
    #   password:
    #   max-total: 100
    #   query-limit: 1000
    #   single:
    #     host: 192.168.150.101
    #     port: 6379
  metrics:
    enabled: false
    registry-type: compact
    exporter-list: prometheus
    exporter-prometheus-port: 9898
  transport:
    rpc-tc-request-timeout: 15000
    enable-tc-server-batch-send-response: false
    shutdown:
      wait: 3
    thread-factory:
      boss-thread-prefix: NettyBoss
      worker-thread-prefix: NettyServerNIOWorker
      boss-thread-size: 1
```



## 2. 微服务集成 Seata

> **❗注意：**
>
> - 参与分布式事务的每一个微服务都需要集成 Seata。



### 2.1 引入依赖

为了方便各个微服务集成 seata，需要把 seata 配置共享到 nacos，因此每一个参与分布式事务的微服务模块不仅仅要引入 seata 依赖，还要引入 nacos 依赖:

```XML
<!--统一配置管理-->
  <dependency>
      <groupId>com.alibaba.cloud</groupId>
      <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
  </dependency>
  <!--读取bootstrap文件-->
  <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-bootstrap</artifactId>
  </dependency>
  <!--seata-->
  <dependency>
      <groupId>com.alibaba.cloud</groupId>
      <artifactId>spring-cloud-starter-alibaba-seata</artifactId>
  </dependency>
```



### 2.2 改造配置

首先在 nacos 上添加一个共享的 seata 配置，命名为`shared-seata.yaml`：

![seata 共享配置](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240730135142386.png)



```YAML
seata:
  registry: # TC服务注册中心的配置，微服务根据这些信息去注册中心获取tc服务地址
    type: nacos # 注册中心类型 nacos
    nacos:
      server-addr: 192.168.183.137:8848 # nacos地址
      namespace: "" # namespace，默认为空
      group: DEFAULT_GROUP # 分组，默认是DEFAULT_GROUP
      application: seata-server # seata服务名称
      username: nacos
      password: nacos
  tx-service-group: hmall # 事务组名称
  service:
    vgroup-mapping: # 事务组与tc集群的映射关系
      mahua: "default"
```



为相关 module 增加 bootstrap.yml 文件

```YAML
spring:
  application:
    name: demo-service # 服务名称
  profiles:
    active: dev
  cloud:
    nacos:
      server-addr: 192.168.183.137:8848 # nacos地址
      config:
        file-extension: yaml # 文件后缀名
        shared-configs: # 共享配置
          - dataId: shared-jdbc.yaml # 共享mybatis配置
          - dataId: shared-seata.yaml # 共享seata配置
```



然后改造application.yaml文件，内容如下：

```YAML
server:
  port: 8085
mahua:
  db:
    database: demo-service
    password: 123456
```



### 2.3 增加数据库表

seata 的客户端在解决分布式事务的时候需要记录一些中间数据，保存在数据库中。

```mysql
-- for AT mode you must to init this sql for you business database. the seata server not need it.
CREATE TABLE IF NOT EXISTS `undo_log`
(
    `branch_id`     BIGINT       NOT NULL COMMENT 'branch transaction id',
    `xid`           VARCHAR(128) NOT NULL COMMENT 'global transaction id',
    `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
    `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    `log_created`   DATETIME(6)  NOT NULL COMMENT 'create datetime',
    `log_modified`  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
    UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4 COMMENT ='AT transaction mode undo table';
```



### 2.4 实现全局事务

之后在需要事务管理的方法上将 `@Transactional` 修改为添加 Seata 提供的 `@GlobalTransactional` 注解。

> `@GlobalTransactional`注解就是在标记事务的起点，将来TM就会基于这个方法判断全局事务范围，初始化全局事务。



> **注意：**
>
> - 使用 `@GlobalTransactional` 标记全局事务的入口方法。
> - 下游服务不需要添加 `@GlobalTransactional`，但可以根据需要使用 `@Transactional` 来管理本地事务。



> 高版本 jdk (jdk > 11 )启动 Seata 服务报错解决方法：Edit Configuration 添加Vm Option --add-opens java.base/java.lang=ALL-UNNAMED 





## 3. 原理

Seata支持四种不同的分布式事务解决方案：

- **XA**
- **TCC**
- **AT**
- **SAGA**



### 3.1 XA 模式

`XA` 规范 是` X/Open` 组织定义的分布式事务处理（DTP，Distributed Transaction Processing）标准，XA 规范 描述了全局的`TM`与局部的`RM`之间的接口，几乎所有主流的数据库都对 XA 规范 提供了支持。



#### 3.1.1 两阶段提交

A是规范，目前主流数据库都实现了这种规范，实现的原理都是基于两阶段提交。

正常情况：

![正常情况](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/asynccode)

异常情况：

![异常情况](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/875d9024-f6ee-4dcd-8b41-a6194ed4138c.png)

一阶段：

- 事务协调者通知每个事务参与者执行本地事务
- 本地事务执行完成后报告事务执行状态给事务协调者，此时事务不提交，继续持有数据库锁

二阶段：

- 事务协调者基于一阶段的报告来判断下一步操作：
  - 如果一阶段都成功，则通知所有事务参与者，提交事务；
  - 如果一阶段任意一个参与者失败，则通知所有事务参与者回滚事务。



#### 3.1.2Seata 的 XA 模型

Seata对原始的XA模式做了简单的封装和改造，以适应自己的事务模型，基本架构如图：

![XA 基本架构图](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/505d5345-7ef1-4830-b94b-c8bb6a85b76c.png)

阶段一`RM`的工作：

- 注册分支事务
- 记录undo-log（数据快照）
- 执行业务sql并提交
- 报告事务状态

阶段二提交时`RM`的工作：

- 删除undo-log即可

阶段二回滚时`RM`的工作：

- 根据undo-log恢复数据到更新前

`RM` 一阶段的工作：

1. 注册分支事务到 `TC`
2. 执行分支业务 sql 但不提交
3. 报告执行状态到 `TC`

`C` 二阶段的工作：

1.  `TC` 检测各分支事务执行状态
   1. 如果都成功，通知所有 RM 提交事务
   2. 如果有失败，通知所有 RM 回滚事务 

`RM` 二阶段的工作：

- 接收 `TC` 指令，提交或回滚事务



#### 3.1.3 优缺点

`XA`模式的优点是：

- 事务的强一致性，满足ACID原则
- 常用数据库都支持，实现简单，并且没有代码侵入

`XA`模式的缺点是：

- 因为一阶段需要锁定数据库资源，等待二阶段结束才释放，性能较差
- 依赖关系型数据库实现事务



#### 3.1.4 实现步骤

1. 通过在 Nacos 中的共享中心配置 `shared-steata.yaml` 配置文件中设置：

```YAML
seata:
  data-source-proxy-mode: XA
```

2. 利用`@GlobalTransactional`标记分布式事务的入口方法即可实现分布式事务。



### 3.2 AT模型

#### 3.2.1 Seata的AT模型

基本流程图：

![AT 模型基本流程图](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/2377ef52-1256-40f9-bcbb-b8e1488c595a.png)



阶段一`RM`的工作：

- 注册分支事务
- 记录 undo-log（数据快照）
- 执行业务 sql 并提交
- 报告事务状态

阶段二提交时 `RM` 的工作：

- 删除 undo-log 即可

阶段二回滚时 `RM` 的工作：

- 根据 undo-log 恢复数据到更新前



#### 3.2.2 流程理解

我们用一个真实的业务来梳理下AT模式的原理。

比如，现在有一个数据库表，记录用户余额：

| **id** | **money** |
| :----- | :-------- |
| 1      | 100       |

其中一个分支业务要执行的SQL为：

```SQL
 update tb_account set money = money - 10 where id = 1
```

AT模式下，当前分支事务执行流程如下：

**一阶段**：

1. `TM` 发起并注册全局事务到`TC`
2. `TM` 调用分支事务
3. 分支事务准备执行业务 SQL
4. `RM` 拦截业务 SQL，根据 where 条件查询原始数据，形成快照。

```JSON
{
  "id": 1, "money": 100
}
```

1. `RM`执行业务 SQL，提交本地事务，释放数据库锁。此时 money = 90
2. `RM` 报告本地事务状态给 `TC`

**二阶段**：

1. `TM`通知`TC`事务结束
2. `TC`检查分支事务状态
   1. 如果都成功，则立即删除快照
   2. 如果有分支事务失败，需要回滚。读取快照数据（{"id": 1, "money": 100}），将快照恢复到数据库。此时数据库再次恢复为100

流程图：

![AT 模式流程图](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/2517fefc-c7b8-48db-865d-00f736221b68.png)



## 4. AT与XA的区别

简述`AT`模式与`XA`模式最大的区别是什么？

- `XA`模式一阶段不提交事务，锁定资源；`AT`模式一阶段直接提交，不锁定资源。
- `XA`模式依赖数据库机制实现回滚；`AT`模式利用数据快照实现数据回滚。
- `XA`模式强一致；`AT`模式最终一致

可见，AT 模式使用起来更加简单，无业务侵入，性能更好。因此企业 90% 的分布式事务都可以用 AT 模式来解决。



















