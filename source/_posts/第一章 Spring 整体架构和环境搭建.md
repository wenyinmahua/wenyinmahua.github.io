---
title: 第一章 Spring 整体架构和环境搭建
date: 2024-08-21
updated: 2024-08-22
comments: true
category: Spring
tags:
  - 阅读
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.eMS-g_JljisGqOSt-MXCnwHaDt?w=272&h=174&c=7&r=0&o=5&dpr=1.3&pid=1.7
---





## 第一章 Spring 整体架构和环境搭建

Spring：轻量级的 Java 开源框架，为了解决企业应用开发的复杂性而创建的，使用基本的 JavaBean 来完成以前只能由 EJB 完成的事情。

![Spring 整体架构](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240821094641355.png)

### Core Container

Core Container：核心容器，这个模块是Spring最核心的模块，其他的都需要依赖该模块。包含有 Core、Beans、Context和Expression Language 模块。Core 和 Beans模块是框架的基础部分，提供 IoC (控制反转)和依赖注入特性。这里的基础概念是 **BeanFactory**，它提供对 Factory 模式的经典实现来消除对程序性单例模式的需要，并真正地允许你从程序逻辑中分离出依赖关系和配置。

- Core：

  > 提供了 IoC 容器的基本功能，包括 Bean 的创建和依赖注入。
  > 侧重于 Bean 的创建和销毁，以及依赖注入.

  - 提供了基本的 IoC 容器支持，包括 `BeanFactory` 接口及其实现。
  - 包含了 Bean 的生命周期管理、依赖注入等功能。
  - `BeanFactory` 是最基础的 IoC 容器，它负责创建和管理 Bean 的实例，以及 Bean 之间的依赖关系。

- Beans：

  > 建立在 Core 模块之上，提供了更具体的 `BeanFactory` 实现，并**增强**了 Bean 的生命周期管理功能，如支持初始化和销毁方法的调用。

  - 提供了对 Bean 的配置、创建和管理的支持。
  - 包含了 `BeanFactory` 接口的具体实现，如 `DefaultListableBeanFactory`。
  - 支持 Bean 的生命周期管理、依赖注入、属性设置等。

- Context：

  > 建立在 Core 和 Beans 模块之上，提供了 `ApplicationContext` 接口的实现，增加了面向实际应用的高级功能，如事件发布、资源访问、国际化等。

  - 提供了对象访问方法（`ApplicationContext` 接口）。
  - 建立在 Core 模块之上，扩展了 `BeanFactory` 的功能。
  - 提供了 `ApplicationContext` 接口的实现，`ApplicationContext` 是 `BeanFactory` 的子接口，它提供了更多的服务，比如资源加载、事件发布机制、国际化支持等。

- Expression Languages：

  > 提供了强大的表达式语言，增强了 Spring 框架的灵活性和动态性。

  - 提供的表达式语言用于在运行时查询和操作对象。
  - 支持设置/获取属性的值、属性分配、方法的调用、访问数组上下文、容器和索引器、逻辑和算术运算符，变量命名以及从 Spring 的 IoC 容器中根据名称检索对象。
  - 支持 list 投影、选择和一般的 list 聚合。

### Data Access / Integration（集成）

- JDBC（**J**ava **D**ata**B**ase **C**onnectivity）：

  > 提供了对 JDBC 的封装，简化了数据访问代码，支持批处理更新和事务管理。

  - 包含了 Spring 对 JDBC 数据访问进行**封装**的所有类。
  - 提供了 `JdbcTemplate` 类，简化了 JDBC 编程模型。
  - 支持批处理更新和事务管理。
  - 通过使用异常层次结构，将 JDBC 的运行时异常转换为可预测的、统一的异常。

- ORM（**O**bject-**R**elational **M**apping）：

  > 提供了对多种 ORM 框架的支持，允许开发者利用 Spring 的特性进行 O/R 映射。

  - 为对象关系映射 API，如 JPA、JDO、Hibernate、MyBatis 等提供了一个交互层（Spring 为对象关系映射 API 提供的“交互层”是指 Spring 为不同的 ORM 技术提供的一组抽象和集成支持，使得开发者可以以一种一致的方式使用这些技术，并且可以利用 Spring 提供的事务管理、异常处理等特性。这种交互层简化了开发者的开发工作，提高了代码的可维护性和可移植性）。
  - 利用 ORM 封装包（即 Spring 为 ORM 技术提供的支持），可以混合使用所有 Spring 提供的特性（如简单声明式事务管理）进行 O/R 映射（对象关系映射）。
  - 支持多种 ORM 框架，允许开发者在不修改业务逻辑的情况下更换 ORM 框架。

- OXM（**O**bject/**X**ML **M**apping）：

  > 提供了对 Object / XML 映射实现的抽象层，支持多种 XML 映射工具。
  >
  > 支持对象与 XML 之间的序列化和反序列化。

  - OXM 模块提供了一个对 Object/XML 映射实现的抽象层（允许使用相同的编程接口与不同的 Object/XML 映射实现进行交互。）。
  - Object/XML 映射实现包括 JAXB、Castor、XMLBeans、JiBX 和 XStream。
  - 提供了 `Marshaller` 和 `Unmarshaller` 接口来处理对象与 XML 文档之间的转换。

- JMS(Java消息服务)：
  >支持制造和消费消息，简化了 JMS 编程模型。

  - JMS 模块主要包含了一些制造和消费消息的特性。
  - 提供了 `JmsTemplate` 类来简化 JMS 编程。
  - 支持消息驱动 POJOs (MDPs)，允许开发者以面向对象的方式编写消息处理逻辑。

- Transaction：

  > 提供了编程式和声明式的事务管理支持，适用于各种数据访问技术。

  - 支持编程式和声明式的事务管理。
  - 事务管理类必须实现特定的接口，并且对所有的 POJO 都适用。
  - 提供了 `PlatformTransactionManager` 接口和具体的实现类，如 `DataSourceTransactionManager` 和 `JtaTransactionManager`。

### Web

Web 上下文模块（Web 模块）建立在应用程序上下文模块（Context 模块）之上， 专门为基于 Web 的应用程序提供了上下文支持。它不仅简化了 Web 应用程序的开发，还提供了处理 HTTP 请求和响应的能力。

> 在 Spring 框架中，"上下文"（Context）指的是 `ApplicationContext`，它是一个高级别的 IoC 容器，用于管理应用中的 Bean （如获取 Bean）和配置信息。Web 上下文模块则进一步扩展了 `ApplicationContext` 的功能，使其更适合 Web 应用程序的需求。
>
> “提供了上下文支持”是指为特定的应用场景或环境提供了一种组织和管理应用对象（Bean）的方式。
>
> 在 Spring 框架中，“提供了上下文支持”意味着为应用提供了一种组织和管理对象的方式。通过 `ApplicationContext`，可以配置和管理应用中的所有 Bean，包括它们的生命周期、依赖注入等。此外，上下文还支持资源访问、事件发布机制、国际化等功能，使得应用更加灵活和强大。

- Web：
  - 提供了对 Web 应用程序上下文的支持。
  - 包括了对 Servlet、Filter 和 Listener 的配置支持。
  - 提供了 `WebApplicationContext` 接口的实现，这是 Web 应用程序上下文的实现。它是 `ApplicationContext` 的子接口。
  - `WebApplicationContext` 通常在 Servlet 容器启动时初始化，并可以访问 Servlet 容器提供的上下文信息。
- Web-Servlet：
  - 提供了 MVC 控制器框架，用于处理 HTTP 请求。
  - 支持视图解析、表单验证、拦截器等功能。
  - 包括了对 Spring MVC 的支持。
  - 提供了 `DispatcherServlet` 作为前端控制器。
- Web-Socket：
  - 支持 WebSocket 协议，允许服务器与客户端之间进行全双工通信。
  - 提供了 WebSocket 消息处理的框架。
- Web-Portlet：
  - 支持 Portlet 规范，允许开发者使用 Spring MVC 构建 Portlet 应用程序。

### AOP

#### Spring AOP 的关键概念

- Aspect（切面）：一个关注点的模块化，如日志记录、权限检查等。
- Joinpoint（连接点）：程序执行过程中某个特定的点，如方法调用或异常抛出。
- Pointcut（切入点）：匹配 Joinpoints 的断言，用于确定哪些 Joinpoints 应该应用 Aspect。
- Advice（通知/增强）：在切入点定义的 Joinpoint 上执行的操作，如 Before、After、Around 等。
- Weaving（织入）：将 Aspect 加入到程序的过程，Spring AOP 在运行时进行织入。
- Proxy（代理）：Spring AOP 通过创建代理对象来实现 AOP。

#### Spring AOP 的实现方式

- 基于 XML 的配置：通过 XML 文件定义切面、切入点和通知。
- 基于注解的配置：使用注解来定义切面、切入点和通知，这种方式更为简洁。
- AspectJ：虽然 Spring AOP 使用自己的 AOP API，但也可以与 AspectJ 集成，使用 AspectJ 的语法编写切面。

#### 如何定义切面

- 使用 @Aspect 注解：标记类为切面。
- 使用 @Pointcut 注解：定义切入点表达式。
- 使用 @Before、@After、@AfterReturning、@AfterThrowing 和 @Around 注解：定义不同类型的增强。



```java
@Aspect
@Component
public class LoggingAspect {

    @Pointcut("execution(* com.example.service.*.*(..))")
    public void serviceLayerOperations() {}

    @Before("serviceLayerOperations()")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Executing: " + joinPoint.getSignature());
    }

    @After("serviceLayerOperations()")
    public void logAfter(JoinPoint joinPoint) {
        System.out.println("Executed: " + joinPoint.getSignature());
    }
}
```





### 补充：

#### Bean 的生命周期

1. Bean 实例化：
   - 当 Spring 容器创建 Bean 的实例时，它首先会调用 Bean 的构造函数来创建 Bean 的实例。
   - 如果 Bean 定义中指定了构造函数，那么 Spring 会调用相应的构造函数来创建 Bean 的实例；否则，它将调用默认的无参构造函数。
2. 依赖注入：
   - 在 Bean 实例化后，Spring 容器会根据配置文件中的定义，使用依赖注入（Dependency Injection, DI）来设置 Bean 的属性。
   - 这个过程可能涉及注入其他 Bean 的引用、基本类型的值、集合类型等。
3. 初始化：
   - 在所有属性都注入完毕后，Spring 会调用初始化方法（如果有的话）可以通过实现特定接口（如 `InitializingBean`）或使用注解（如 `@PostConstruct`）来完成。。
   - 初始化方法可以是 Bean 类中的一个方法，也可以是实现了特定接口的方法。
   - 初始化方法可以确保 Bean 在使用前已经处于完全可用的状态。
4. Bean 使用：
   - Bean 正常执行其业务逻辑。这个阶段 Bean 可以被 Spring 容器管理，用于执行其预定的任务。
5. 销毁方法调用：
   - 当 Bean 不再需要时，Spring 容器调用 Bean 的销毁方法。这可以通过实现特定接口（如 `DisposableBean`）或使用注解（如 `@PreDestroy`）来完成。
6. Bean 销毁：
   - Bean 已经被销毁，Spring 容器不再管理该 Bean。

在 Spring 框架中，`ApplicationContext` 提供了对 Bean 生命周期的管理。这意味着可以定义 Bean 初始化和销毁的方法，并让 Spring 自动调用这些方法。



#### 如何定义初始化和销毁方法

1. **使用 `@PostConstruct` 和 `@PreDestroy` 注解**：

   - `@PostConstruct` 注解可以标记在非静态的 void 方法上，表示该方法应该在依赖注入完成后调用。
   - `@PreDestroy` 注解可以标记在非静态的 void 方法上，表示该方法应该在容器销毁 Bean 之前调用。

2. **实现 `InitializingBean` 和 `DisposableBean` 接口**：

   - 实现 `InitializingBean` 接口的 `afterPropertiesSet` 方法作为初始化方法。
   - 实现 `DisposableBean` 接口的 `destroy` 方法作为销毁方法。

3. **在配置文件中定义初始化和销毁方法**：

   - 在 XML 配置文件中使用 `init-method` 和 `destroy-method` 属性来指定初始化和销毁方法。例如：

     ```xml
     <bean id="myBean" class="com.example.MyBean"
           init-method="initialize" destroy-method="cleanup" />
     ```

#### 事务管理

##### 1. 编程式事务管理

编程式事务管理要求开发者在代码中**显式地控制事务**的开始、提交或回滚。这种方式适用于需要精细控制事务边界的情况，特别是在事务逻辑比较复杂的场景下。

> **特点：**
>
> 1. **显式控制**：
>    - 开发者需要显式地调用 `beginTransaction()`、`commit()` 和 `rollback()` 方法来控制事务的生命周期。
>    - 这种方式提供了更细粒度的控制，可以在事务中嵌套其他事务。
> 2. **灵活性**：
>    - 适用于需要在事务中执行复杂逻辑的情况。
>    - 可以根据业务逻辑动态决定是否提交或回滚事务。
> 3. **代码侵入性**：
>    - 需要在业务逻辑代码中显式地添加事务控制代码，这可能会导致代码侵入性较高。

**代码演示：**

```java
@Service
public class AccountService {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private PlatformTransactionManager transactionManager;

    public void transferMoney(Long fromId, Long toId, double amount) {
        // 创建事务定义，DefaultTransactionDefinition 是 TransactionDefinition 接口的一个实现类，它提供了默认的事务属性。当没有特别指定事务属性时，通常使用 DefaultTransactionDefinition 来创建一个默认的事务定义。
        TransactionDefinition def = new DefaultTransactionDefinition();
        // 获取事务状态
        TransactionStatus status = transactionManager.getTransaction(def);

        try {
            Account fromAccount = accountRepository.findById(fromId);
            Account toAccount = accountRepository.findById(toId);

            fromAccount.decreaseBalance(amount);
            toAccount.increaseBalance(amount);

            accountRepository.save(fromAccount);
            accountRepository.save(toAccount);

            transactionManager.commit(status);
        } catch (Exception e) {
            transactionManager.rollback(status);
            throw e;
        }
    }
}
```

在这个示例中使用了 `PlatformTransactionManager` 来手动管理事务。在 `transferMoney` 方法中，显式地开始了一个事务，在尝试转账的过程中捕获任何异常，并根据情况提交或回滚事务。

整体流程：

1. 创建一个 `DefaultTransactionDefinition` 实例，定义事务的属性。
2. 使用 `PlatformTransactionManager` 的 `getTransaction` 方法开始一个新的事务，并获取一个 `TransactionStatus` 对象。
3. 在事务逻辑完成后，根据业务逻辑的结果调用 `TransactionStatus` 的 `commit()` 或 `rollback()` 方法来提交或回滚事务。

##### 2.声明式事务管理

声明式事务管理允许开发者通过**注解**或 **XML** 配置来声明事务边界，而不需要在代码中显式地控制事务的生命周期。这种方式简化了代码，提高了可读性和可维护性。

> **特点：**
>
> 1. **简洁性**：
>    - 通过使用 `@Transactional` 注解或 XML 配置来声明事务边界。
>    - 无需在业务逻辑代码中添加额外的事务管理代码。
> 2. **易于维护**：
>    - 事务边界在方法级别声明，使得代码更加清晰，易于理解和维护。
>    - 支持全局默认事务配置和特定方法的覆盖配置。
> 3. **减少侵入性**：
>    - 事务管理代码与业务逻辑分离，降低了代码侵入性。

```java
@Service
public class AccountService {

    @Autowired
    private AccountRepository accountRepository;

    @Transactional
    public void transferMoney(Long fromId, Long toId, double amount) {
        Account fromAccount = accountRepository.findById(fromId);
        Account toAccount = accountRepository.findById(toId);

        fromAccount.decreaseBalance(amount);
        toAccount.increaseBalance(amount);

        accountRepository.save(fromAccount);
        accountRepository.save(toAccount);
    }
}
```



##### 总结

- **编程式事务管理**：
  - 提供了更细粒度的控制，适用于事务逻辑复杂的场景。
  - 代码侵入性较高，需要在业务逻辑中添加事务管理代码。
- **声明式事务管理**：
  - 简化了代码，提高了可读性和可维护性。
  - 减少了代码侵入性，事务管理与业务逻辑分离。

通常情况下，对于大多数简单的业务逻辑，推荐使用声明式事务管理；而对于需要更细粒度控制的情况，则可以考虑使用编程式事务管理。

