---
title: Rabbit 基础
date: 2024-07-19
updated: 2024-07-20
tags:
  - 基础
category: RabbitMQ
comments: true
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.U4OCDM45FXAfMRK8FtOKkAHaEG?w=275&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# RabbitMQ

> 整个过程需要：
>
> - 声明交换机和队列
> - 绑定队列到交换机（需要时指定 RoutingKey）
> - 通过 RabbitTemplate 对象的 convertAndSend 方法完成消息发送，需要的话要指定 `RoutingKey`
> - 需要通过 @RabbitListener(queues = "fanout.queue") 注解绑定消费者的方法完成消息接收。

> 消息交换机的类别：
>
> - fanout
> - direct
> - topic
> - headers

**异步调用**方式其实就是基于消息通知的方式，一般包含三个角色：

- 消息发送者：投递消息的人，就是原来的调用方
- 消息 Broker：管理、暂存、转发消息，可以理解成微信服务器
- 消息接收者：接收和处理消息的人，就是原来的服务提供方

在异步调用中，发送者不再直接同步调用接收者的业务接口，而是发送一条消息投递给消息 Broker。然后接收者根据自己的需求从消息 Broker 那里订阅消息。每当发送方发送消息后，接受者都能获取消息并处理。

异步调用的优势包括：

- 耦合度更低
- 性能更好
- 业务拓展性强
- 故障隔离，避免级联失败

缺点：

- 完全依赖于 Broker 的可靠性、安全性和性能
- 架构复杂，后期维护和调试麻烦

消息 Broker，目前常见的实现方案就是消息队列（MessageQueue），简称为 MQ.

 几种常见 MQ 的对比：

|            | RabbitMQ                | ActiveMQ                       | RocketMQ   | Kafka      |
| ---------- | ----------------------- | ------------------------------ | ---------- | ---------- |
| 公司/社区  | Rabbit                  | Apache                         | 阿里       | Apache     |
| 开发语言   | Erlang                  | Java                           | Java       | Scala&Java |
| 协议支持   | AMQP，XMPP，SMTP，STOMP | OpenWire,STOMP，REST,XMPP,AMQP | 自定义协议 | 自定义协议 |
| 可用性     | 高                      | 一般                           | 高         | 高         |
| 单机吞吐量 | 一般                    | 差                             | 高         | 非常高     |
| 消息延迟   | 微秒级                  | 毫秒级                         | 毫秒级     | 毫秒以内   |
| 消息可靠性 | 高                      | 一般                           | 高         | 一般       |

追求可用性：Kafka、 RocketMQ 、RabbitMQ

追求可靠性：RabbitMQ、RocketMQ

追求吞吐能力：RocketMQ、Kafka

追求消息低延迟：RabbitMQ、Kafka



# Rabbit 入门

## 1. 安装

基于 Docker 安装 RabbitMQ

```shell
docker run \
 -e RABBITMQ_DEFAULT_USER=mahua \
 -e RABBITMQ_DEFAULT_PASS=123456 \
 -v mq-plugins:/plugins \
 --name mq \
 --hostname mq \
 -p 15672:15672 \
 -p 5672:5672 \
 --restart=always\
 --network mahua\
 -d \
 rabbitmq:3.8-management
```

安装命令中有两个映射的端口：

- 15672：RabbitMQ 提供的管理控制台的端口
- 5672：RabbitMQ 的消息发送处理接口

安装完成之后，访问 http://localhsot:15672 ，便可访问管理控制台，需要账号和密码。



### RabbitMQ 中的主要概念

- `publisher`：生产者，也就是发送消息的一方，发送消息给交换机；
- `consumer`：消费者，也就是消费消息的一方，订阅队列；
- `queue`：队列，存储消息。生产者投递的消息会暂存在消息队列中，等待消费者处理，队列一定要与交换机绑定。
- `exchange`：交换机，负责消息路由。生产者发送的消息由交换机决定投递到哪个队列。一方面，接收生产者发送的消息。另一方面，知道如何处理消息，例如递交给某个特别队列、递交给所有队列、或是将消息丢弃。到底如何操作，取决于 Exchange 的类型。**交换机没有存储消息的能力**
- `virtual host`：虚拟主机，起到数据隔离的作用。每个虚拟主机相互独立，有各自的 exchange、queue。



## 2.收发消息

### 2.1 交换机 exchange

> 交换机没有存储消息的能力。

![image-20240808145609781](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240808145609781.png)

### 2.2队列 queue

> 发送到交换机的消息，只会路由到与其绑定的队列，因此仅仅创建队列是不够的，还需要将其与交换机绑定。

![image-20240808145803172](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240808145803172.png)



### 2.3 绑定关系 binding

![image-20240808150026169](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240808150026169.png)

### 2.4 发送消息

![image-20240808150218707](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240808150218707.png)

## 3. 数据隔离



### 3.1 用户管理



![用户管理](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240809082616485.png)

RabbitMQ控制台的用户管理界面里的用户都是 RabbitMQ 的管理或运维人员。其用户表中有如下字段：

- `Name`：`mahua`，也就是用户名
- `Tags`：`administrator`，说明`mahua`用户是超级管理员，拥有所有权限
- `Can access virtual host`： `/`，可以访问的`virtual host`，这里的`/`是默认的`virtual host`

对于小型企业而言，出于成本考虑，通常只会搭建一套 MQ 集群，公司内的多个不同项目同时使用。这个时候为了避免互相干扰， 会利用`virtual host`的隔离特性，将不同项目隔离。一般会做两件事情：



- 给每个项目创建独立的运维账号，将管理权限分离。（add a user）
  ![最佳运维账号](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240809083255613.png)
- 给每个项目创建不同的`virtual host`，将每个项目的数据隔离。
  ![创建 virtual host](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240809083155837.png)

只有登录用户的创建 `virtual host`，该用户才有对其的访问权限。



# SpringAMQP

由于 `RabbitMQ` 采用了 AMQP 协议，因此它具备跨语言的特性。任何语言只要遵循AMQP 协议收发消息，都可以与 `RabbitMQ` 交互。

Spring 的官方基于 RabbitMQ 提供了一套消息收发的模板工具：SpringAMQP

> SpringAMQP 提供了三个功能：
>
> - 自动声明队列、交换机及其绑定关系
> - 基于注解的监听器模式，异步接收消息
> - 封装了 RabbitTemplate 工具，用于发送消息



## 1. SpringAMQP 入门

### 1.1 引入依赖

```XML
<!--AMQP依赖，包含RabbitMQ-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```

开发中需要经过交换机发送消息到队列，有时候为了测试方便，也可以直接向队列发送消息，跳过交换机。

- publisher 直接发送消息到队列
- 消费者监听并处理队列中的消息



### 1.2 消息发送与接收

1. 配置 MQ 地址（发到哪里），在消息的发送者和消息的接收者中都需要这样配置

```YAML
spring:
  rabbitmq:
    host: 192.168.183.138 # 你的虚拟机IP
    port: 5672 # 端口
    virtual-host: /mahua # 虚拟主机
    username: mahua # 用户名
    password: 123456 # 密码
```

2. 编写测试类，并利用`RabbitTemplate`实现消息发送，需要知道：
   1. 消息队列的名字（发给谁）
   2. 发送的具体信息（发什么）

```java
@SpringBootTest
public class SpringAmqpTest {

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @Test
    public void testSimpleQueue() {
        // 队列名称
        String queueName = "simple.queue";
        // 消息
        String message = "hello, spring amqp!";
        // 发送消息
        rabbitTemplate.convertAndSend(queueName, message);
    }
}
```

3. 编写监听器，监听队列中的消息
   1. 需要通过 `RabbitListener` 的 `queues` 参数来声明需要加监听的消息队列名

```java
@Component
public class SpringRabbitListener {
    // 利用RabbitListener来声明要监听的队列信息
    // 将来一旦监听的队列中有了消息，就会推送给当前服务，调用当前方法，处理消息。
    // 可以看到方法体中接收的就是消息体的内容
    @RabbitListener(queues = "simple.queue")
    public void listenSimpleQueueMessage(String msg) throws InterruptedException {
        System.out.println("spring 消费者接收到消息：【" + msg + "】");
    }
}
```



### 声明队列

SpringAMQP 提供了一个 Queue 类，用来创建队列；

SpringAMQP 还提供了一个 Exchange 接口，来表示所有不同类型的交换机；

可以自己创建队列和交换机，不过 SpringAMQP 还提供了 ExchangeBuilder 来简化这个过程；

而在绑定队列和交换机时，则需要使用 BindingBuilder 来创建 Binding 对象；

```Java
@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "direct.queue1"),
    exchange = @Exchange(name = "mahua.direct", type = ExchangeTypes.DIRECT),
    key = {"red", "blue"}
))
public void listenDirectQueue1(String msg){
    System.out.println("消费者1接收到direct.queue1的消息：【" + msg + "】");
}

@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "direct.queue2"),
    exchange = @Exchange(name = "mahua.direct", type = ExchangeTypes.DIRECT),
    key = {"red", "yellow"}
))
public void listenDirectQueue2(String msg){
    System.out.println("消费者2接收到direct.queue2的消息：【" + msg + "】");
}
```



```Java
@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "topic.queue1"),
    exchange = @Exchange(name = "mahua.topic", type = ExchangeTypes.TOPIC),
    key = "china.#"
))
public void listenTopicQueue1(String msg){
    System.out.println("消费者1接收到topic.queue1的消息：【" + msg + "】");
}

@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "topic.queue2"),
    exchange = @Exchange(name = "mahua.topic", type = ExchangeTypes.TOPIC),
    key = "#.news"
))
public void listenTopicQueue2(String msg){
    System.out.println("消费者2接收到topic.queue2的消息：【" + msg + "】");
}
```





### WorkQueues 模型

Work queues，任务模型：让**多个消费者绑定到一个队列，共同消费队列中的消息**。

> **只需要多个消费者绑定同一队列便可实现**
>
> Work模型的使用：
>
> - 多个消费者绑定到一个队列，同一条消息只会被一个消费者处理
> - 通过设置 prefetch 来控制消费者预取的消息数量

当消息处理比较耗时的时候，可能生产消息的速度会远远大于消息的消费速度。长此以往，消息就会堆积越来越多，无法及时处理。此时就可以使用work 模型，**多个消费者共同处理消息处理，消息处理的速度就能大大提高**了。



发送消息不变，需要在消息的接收端实现多个消费者绑定同一个队列。

```Java
@RabbitListener(queues = "work.queue")
public void listenWorkQueue1(String msg) throws InterruptedException {
    System.out.println("消费者1接收到消息：【" + msg + "】" + LocalTime.now());
    Thread.sleep(20);
}

@RabbitListener(queues = "work.queue")
public void listenWorkQueue2(String msg) throws InterruptedException {
    System.err.println("消费者2........接收到消息：【" + msg + "】" + LocalTime.now());
    Thread.sleep(200);
}
```

这个过程中消息是平均分配给每个消费者，并没有考虑到消费者的处理能力。导致1个消费者空闲，另一个消费者忙的不可开交。

修改消费者的配置便可解决这个问题：

```YAML
spring:
  rabbitmq:
    listener:
      simple:
        prefetch: 1 # 每次只能获取一条消息，处理完成才能获取下一个消息
```

这样充分利用每一个消费者的处理能力，可以有效避免消息积压问题。



## 交换机

### 1. 交换机类型

**Exchange（交换机）只负责转发消息，不具备存储消息的能力**，因此如果没有任何队列与 Exchange 绑定，或者没有符合路由规则的队列，那么消息会丢失！

> 交换机的类型有四种：
>
> - **Fanout**：广播，将消息交给所有绑定到交换机的队列；
> - **Direct**：订阅，基于 RoutingKey（路由key）发送给订阅了消息的队列；
> - **Topic**：通配符订阅，与 Direct 类似，只不过 RoutingKey 可以使用通配符；
> - **Headers**：头匹配，基于 MQ 的消息头匹配，用的较少。



### 2. Fanout 交换机

Fanout，英文翻译是扇出，在 MQ 中叫广播更合适。

> 给一个交换机发送消息，会将其发送给与之绑定的队列。

在广播模式下，消息发送流程是这样的：

- 1）  可以有多个队列
- 2）  每个队列都要绑定到 Exchange（交换机）
- 3）  生产者发送的消息，只能发送到交换机
- 4）  交换机把消息发送给绑定过的所有队列
- 5）  订阅队列的消费者都能拿到消息



交换机的作用：

- 接收 publisher 发送的消息
- 将消息按照规则路由到与之绑定的队列
- 不能缓存消息，路由失败，消息丢失
- FanoutExchange 的会将消息路由到每个绑定的队列



### 3. Direct 交换机

当希望不同的消息被不同的队列消费，这时就要用到 Direct 类型的 Exchange。

> - 消息发送者需要在发送消息的时候携带上 RoutingKey，
> - 交换机需要在绑定队列的时候指定相关的 key；
>
> - 消息队列需要指定相关的 RoutingKey，
> - 消息的消费者只需要绑定队列即可，不需要 RoutingKey。

在 Direct 模型下：

- 队列与交换机的绑定，不能是任意绑定了，而是要指定一个 `RoutingKey`（路由key）；
- 消息的发送方在向 Exchange 发送消息时，也必须指定消息的 `RoutingKey`；
- Exchange 不再把消息交给每一个绑定的队列，而是根据消息的 `RoutingKey` 进行判断，只有队列的 `Routingkey` 与消息的 `Routingkey` 完全一致，才会接收到消息。



消息的发送：

```java
rabbitTemplate.convertAndSend(exchangeName, "red", message);
```

描述下 Direct 交换机与 Fanout 交换机的差异：

- Fanout 交换机将消息路由给每一个与之绑定的队列
- Direct 交换机根据 RoutingKey 判断路由给哪个队列
- 如果多个队列具有相同的 RoutingKey，则与 Fanout 功能类似



### 4. Topic 交换机

`Topic`类型的`Exchange`与`Direct`相比，都是可以根据`RoutingKey`把消息路由到不同的队列。

> - 只有消息队列需要设置匹配的 通配符 key
> - 消息的发送者在发送时需要指定具体的 key
> - 消息的交换机需要绑定 队列，同时指定 路由信息`RoutingKey`。
> - 消息的消费者指定队列即可

只不过`Topic`类型`Exchange`可以让队列在绑定`BindingKey` 的时候使用通配符！

`BindingKey` 一般都是有一个或多个单词组成，多个单词之间以`.`分割，例如： `shanxi.linfen`

通配符规则：

- `#`：匹配一个或多个词
- `*`：匹配不多不少恰好1个词

举例：

- `shanxi.#`：能够匹配`shanxi.linfen.yichen` 或者 `shanxi.linfen`
- `shanxi.*`：只能匹配`shanxi.linfen`
- `#.new`：能够匹配`china.news` 或者 `china.shanxi.news`
- `*.new`：只能够匹配`shanxi.news`或`china.news`



**声明交换机和队列：**

```Java
@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "topic.queue1"),
    exchange = @Exchange(name = "mahua.topic", type = ExchangeTypes.TOPIC),
    key = "china.#"
))
public void listenTopicQueue1(String msg){
    System.out.println("消费者1接收到topic.queue1的消息：【" + msg + "】");
}

@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "topic.queue2"),
    exchange = @Exchange(name = "mahua.topic", type = ExchangeTypes.TOPIC),
    key = "#.news"
))
public void listenTopicQueue2(String msg){
    System.out.println("消费者2接收到topic.queue2的消息：【" + msg + "】");
}
```



**消息发送：**

```java
rabbitTemplate.convertAndSend(exchangeName, "china.news", message);
```



> 描述下Direct交换机与Topic交换机的差异：
>
> - Topic 交换机接收的消息 RoutingKey 必须是多个单词，以 **`.`** 分割
> - Topic 交换机与队列绑定时的 bindingKey 可以指定通配符
> - `#`：代表0个或多个词
> - `*`：代表1个词





### 消息转换器

Spring 的消息发送代码接收的消息体是一个 Object，而在数据传输时，它会把发送的消息序列化为字节发送给 MQ，接收消息的时候，还会把字节反序列化为 Java 对象。

只不过，默认情况下 Spring 采用的序列化方式是 JDK 序列化。众所周知，JDK 序列化存在下列问题:

- **安全性问题：**JDK 序列化可能允许恶意用户构造特定的序列化数据流，从而执行远程代码。
- **效率问题：**JDK 序列化通常比其他序列化方式（如 JSON、Protobuf 等）更慢且生成的数据量更大。
- **兼容性问题：**JDK 序列化的对象结构与类结构紧密相关，如果类结构发生变化，则可能会导致序列化失败。
- **可读性差：**JDK 序列化后的数据不易于阅读和调试。

JDK 序列化方式并不合适。希望消息体的体积更小、可读性更高，因此可以使用 JSON 方式来做序列化和反序列化。



**引入如下依赖：**

```XML
<dependency>
    <groupId>com.fasterxml.jackson.dataformat</groupId>
    <artifactId>jackson-dataformat-xml</artifactId>
    <version>2.9.10</version>
</dependency>
```

注意，如果项目中引入了`spring-boot-starter-web`依赖，则无需再次引入`Jackson`依赖。



**配置消息转换器**

在相关启动类中添加一个 Bean

```Java
@Bean
public MessageConverter messageConverter(){
    // 1.定义消息转换器
    Jackson2JsonMessageConverter jackson2JsonMessageConverter = new Jackson2JsonMessageConverter();
    // 2.配置自动创建消息id，用于识别不同消息，也可以在业务中基于ID判断是否是重复消息
    jackson2JsonMessageConverter.setCreateMessageIds(true);
    return jackson2JsonMessageConverter;
}
```

springboot 会将 jackson2JsonMessageConverter 这个 bean 对象自动注入到 RabbitTemplate 中，消息转换器中添加的 messageId 可以便于将来做幂等性判断。

**发送消息**

在 publisher 模块的 SpringAmqpTest 中新增一个消息发送的代码，发送一个 Map 对象：

```Java
@Test
public void testSendMap() throws InterruptedException {
    // 准备消息
    Map<String,Object> msg = new HashMap<>();
    msg.put("name", "柳岩");
    msg.put("age", 21);
    // 发送消息
    rabbitTemplate.convertAndSend("object.queue", msg);
}
```

**接收消息**

在 consumer 服务中定义一个新的消费者，publisher 是用 Map 发送，那么消费者也一定要用 Map 接收，格式如下：

```Java
@RabbitListener(queues = "object.queue")
public void listenSimpleQueueMessage(Map<String, Object> msg) throws InterruptedException {
    System.out.println("消费者接收到object.queue消息：【" + msg + "】");
}
```