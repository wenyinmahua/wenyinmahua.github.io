---
title: Spring 基础
date: 2023-09-08
updated: 2023-09-19
comments: true
category: Spring
tags:
  - 基础
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.eMS-g_JljisGqOSt-MXCnwHaDt?w=272&h=174&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# Spring

>1. Core Container：存放对象的核心容器。只有一种东西能存放在Java的容器当中，那就是java对象。即Java容器就是用来存放Java对象的。
>
>2. AOP：面向切面编程，是一种编程思想，在不改变源代码的基础上，对系统的功能进行增强。
>     Aspects：实现AOP思想的技术。
>
>   - 面向切面编程也叫面向方法编程，是一种针对java方法的编程思想。实现**增强功能部分的代码**的复用。
>
>   - 比如我写了十个方法，但是编写结束结束之后我还想统计每个方法的运行时长，在每一个方法中重新加入统计时长的代码并不划算，如果能找到一个使用代码实现的计时器可以多次用来统计每个方法的运行时长，将每一个**方法**通过以**参数的形式**传递到计时器的计时开始和计时结束的代码之间，运行之后便可以计算出方法的运行时长，就不需要在十个方法中加入统计运行时长的代码了。
>   - 这样就可以实现在不改变源代码的基础上，给程序增加一个计时的功能，实现功能的增强。
>   - 可以看出，Aspects技术实现的是一个可复用的功能（方法）。
>
>3. Data Access：数据访问
>
>4. Data Integration：数据集成，和其他技术整合起来使用（如Spring+Mybatis）
>
>5. Web：web开发
>
>6. Test：单元测试与集成测试

注意学习之前需要Maven创建项目的基本知识



# 一、IoC+DI+Bean

## 1.核心概念

### 	(1).IOC:Inversion of Control控制反转

​	**IoC：**控制反转，对象的创建权不再由程序员控制了，Spring程序获得了创建对象的权力，由spring程序自动创建对象并存放在IoC容器当中。

> 使用对象时，**由主动new产生对象转换为由IoC容器提供对象**，此过程中对象的创建控制权由程序转移到外部（由Spring提供的IoC容器创建对象）。

- 原因：没有采用Ioc思想的项目代码耦合性高，更改时难度大、繁琐，需要IoC解耦。
- Ioc容器负责对象的创建、初始化等一系列工作，**被创建或被管理的对象**在IoC容器中统称为**Bean** 。

### (2).DI：Dependency Injection 依赖注入

- 在容器中建立Bean与Bean之间的依赖关系的整个过程

### (3).目标

- 充分解耦
  - 使用Ioc容器管理Bean（IoC）
  - 在IoC容器内将有**关系**的Bean进行关系绑定（DI）
    这里的关系指的是被调用的关系。
- 使用对象时不仅可以直接从IoC容器中获取，并且获取到的Bean已经绑定了所有的依赖关系



## 2.IoC控制反转入门案例

### 	(1).IoC入门案例

> 将Bean对象告知IoC容器让其管理Bean	-->	获取IoC容器	-->	通过IoC容器获得Bean

- IoC容器用来管理Bean，需要在一个application.xml（自定义的）配置文件中配置被管理的Bean，自动告知IoC容器该对象要被IoC容器管理；
- 要使用Bean，需要通过**接口**先获取IoC容器，然后在IoC容器中通过**接口方法getBean**获取Bean。[参考4和5](#获取IoC容器，即初始化IoC容器（Spring容器/Spring核心容器）)

> 注意application.xml文件是一个spring类型的配置文件，需要在pom.xml中引入依赖spring-context才能成功配置该文件。
>
> - 每引入一项新的依赖都需要使用maven重新加载，使其加入本地仓库才能正常使用。

**源程序：**

注意项目工程的创建需要依靠Maven，

```java
//BookDao.jva
package com.itheima.dao;
public interface BookDao {
    public void save();
}
```

```java
//BookDaoImple.java
package com.itheima.dao.impl;
import com.itheima.dao.BookDao;
public class BookDaoImpl implements BookDao {
    @Override
    public void save() {
        System.out.println("book dao save...");
    }
}
```

```java
//BookService.java
package com.itheima.service;
public interface BookService {
    public void save();
}

```

```java
//BookServiceImpl.java
package com.itheima.service.impl;
import com.itheima.dao.BookDao;
import com.itheima.dao.impl.BookDaoImpl;
import com.itheima.service.BookService;
public class BookServiceImpl implements BookService {
    private BookDao bookDao = new BookDaoImpl();
    //一旦BookDaoImpl原类改名为其他的名字如“juanjuanchuan”,这里也需要将new BookDaoImpl()改变成new juanjuanchuan()，所以说代码的耦合性高。
    //由IoC容器配置Bean之后，通过“private BookDao bookDao;”以及setXxx方法便可得到IoC容器中的xxx对象，注意这里的Xxx与xxx是匹配的。bean中不区分大小写，但是set方法区分大小写
    @Override
    public void save() {
        System.out.println("book service save...");
        bookDao.save();
    }
}
```

```java
//App.java
package com.itheima;
import com.itheima.service.BookService;
import com.itheima.service.impl.BookServiceImpl;

public class App {
    public static void main(String[] args) {
        BookService bookService = new BookServiceImpl();
        bookService.save();
    }
}
```

IoC容器中的Bean一般来说都是单例的（提供一个的对象多次使用）

1. 在pom.xml文件中**导入spring坐标spring-context**，对应版本是5.2.10.RELEASE

   ```xml
   <dependencies>        
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-context</artifactId>
           <version>5.2.10.RELEASE</version>
       </dependency>
   </dependencies>
   ```

2. 改变BookServiceImpl类，是创建对象变为setXxx方法

   ```java
   去掉new BookDaoImpl()，通过setXxx的方法重新获取对象，降低耦合
       public void setBookDao(BookDao bookDao) {
           this.bookDao = bookDao;
       }
   ```

3. 在创建的ApplicationContext.xml配置文件中配置对应类作为Spring管理的Bean，同时确定两个Bean之间的关系

   ```xml
   <bean id="bookDao" name="dao,dao1;dao2 dao" class="com.itheima.dao.impl.BookDaoImpl" scope="prototype"/>
   <bean id="bookService" class="com.itheima.service.impl.BookServiceImpl">
       <!--关系绑定-->
   	<property name="bookDao" ref="bookDao"/>
   </bean>
   <!--解释
   id：Bean的唯一标识，使用容器的getBean方法时可以通过id值来获取对应的Bean
   name：为Bean起别名，使用逗号、分号以及空格分隔，也可以使用name值类获取对应的Bean
   class：Bean的类型，即匹配的Bean的全路径类名；
   scope：指定Bean的作用域，有singlen和prototype两种，前者创建的对象是单例的，后者是多例的
   property的ref：绑定关系，值为对应Bean的id或name，优先使用id
   property的name的值为setBookDao的首字母小写的bookDao，
   	注意要和该方法名的对应部分匹配，小写首字母，set方法和property绑定了。
       public void setBookDao(BookDao bookDao) {
           this.bookDao = bookDao;
       }
   -->
   ```

4. ##### 获取IoC容器，即初始化IoC容器（Spring容器/Spring核心容器），加载类路径下的配置文件

   ```java
   ApplicationContext ctx = new ClassPathXmlApplicationContext("application.xml");
   	接口			对象名			对象的运行类型				在什么地方获取Bean
   ```

5. 获取Bean并使用

   ```java
   BookDao bookDao = (BookDao)ctx.getBean("bookDao");//返回类型是Object
   bookDao.save();
   ```



### (2).实例化Bean的四种方法

1. 构造方法（常用）
   提供可使用的无参构造方法，分为系统提供的和自定义的无参构造方法
   Bean本质上就是对象，创建bean使用构造方法完成。
   
   配置文件中配置Bean
   
   ```xml
   <bean id="bookDao" class="com.itheima.dao.impl.BookDaoImpl"></bean>
   <!--这里根据class中的具体的类，使用系统提供的无参构造器创建对象-->
   ```
   
2. 静态工厂（了解即可）

   ```java
   //静态工厂
   public class OrderDaoFactory(){
       public static OrderDao getOrderDao(){
           return new OrderDaoImpl();
       }
   }
   ```

   配置文件中配置Bean

   ```xml
   <bean id="orderDao" factory-method="getOrderDao" class="com.itheima.factory.OrderDaoFactory"></bean>
   <!--这里并不是使用OrderDaoImpl配置Bean而是静态工厂的类，需要使用factory-method指明创建对象的方法，不然会把工厂的对象造出来-->
   ```

3. 实例工厂(了解)

   实例工厂

   ```java
   public class UserDaoFactory{
       public UserDao getUserDao(){//注意这里不再是static修饰的静态方法了
           return new UserDaoImpl();
       }
   }
   ```

   配置文件中配置Bean

   ```xml
   先创建工厂的对象，然后再使用工厂对象创建UserDao的对象
   <bean id="factory" class="com.itheima.factory.UserDaoFactory"></bean>
   <bean id="uderDao" factory-bean="factory" factory-method="getUserDao"/>
   ```

4. FactoryBean，第三种方式的改良，(必须掌握，实用)
   FactoryBean

   ```java
   public class UserDaoFactoryBean implements FactoryBean<UserDao>{
       //代替原始实例工厂中创建对象的方法
       public UserDao getObject() throws Exceptiom{
           return new UserDaoImpl();
       }
       //创建的对象是什么类型的？明显是UserDao类型，将UserDao的字节码返回即可
       public Class<?> getObjectType(){
           return UserDao.class;
       }
       //默认是创造单例对象，需要修改为多例时需要重写该方法
       public boolean isSingle(){
           return true;
       }
   }
   ```

   配置文件配置Bean

   ```xml
   <bean id="userDao" class="com.itheima.factory.UserDaoFactoryBean"/>
   很明显这种配置方法比第三种简单多了
   ```



## 3.Bean的生命周期

- 生命周期：从创建到死亡的完整过程
- Bean生命周期：Bean从创建到销毁的整体过程
- bean生命周期控制：bean**创建后到销毁前**做一些操作
  - 初始化容器
    1. 创建对象（内存分配）
    2. 执行构造方法
    3. 执行属性注入（set方法）
    4. 执行bean初始化方法
  - 使用bean
    1. 执行业务操作
  - 关闭/销毁容器
    1. 执行bean销毁方法

1.在bean中配置相应的属性进行bean的生命周期的控制

```xml
<bean id="bookDao" class="com.itheima.service.impl.BookServiceImpl" init-method="init" destroy-method="destory"/>
注意Java虚拟机关闭时也不会执行Bean的destory-method方法，因为该方法执行前虚拟机已被关闭
```

解决以上问题有两种方法

```java
//1.手工关闭容器
//将ctx的编译类型变为“ClassPathXmlApplicationContext”，执行相关的关闭操作
ClassPathXmlApplicationContext ctx = new ClassPathXmlApplicationContext("application.xml")
ctx.close();//在恰当的位置加入这个方法即可提前关闭IoC容器，执行销毁方法，这种方法比较暴力，推荐下面的钩子方法
//2.注册关闭钩子方法，在虚拟机退出前先关闭容器再退出虚拟机
ctx.registerShutdounHook();//在虚拟机关闭之前关闭IoC容器，对于放置的位置没有规定，放置到任何位置都可以。
```

2.不需要在bean中配置init-method和destory-method属性，通过ServiceImpl类实现InitializingBean和DisposableBean接口，并在类中重写afterPropertiesSet和destory方法（了解）

```java
public class BookDaoImpl implements BookDao, DisposableBean, InitializingBean {
    @Override
    public void save() {
        System.out.println("book dao save...");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("service destory..");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("service init");
    }
}
```



## 4.依赖注入方式

依赖注入的两种方式：普通方法（setter方法） 注入和构造器注入，两者都可注入简单类型和复杂类型的数据。



### 1.setter方法（推荐）

1. 在bean中定义简单类型属性提供可访问的set方法

   ```java
   class BookDaoImpl implements BookDao{
       private int num;
       public void setNum(int num){
           this.num = num;
       }
   }
   ```

2. 在配置中使用property标签value属性注入简单类型数据

   ```xml
   <bean id="bookDao" class="com.itheima.dao.imol.BookDao">
   	<property name = "num" value ="100"/>
   </bean>
   ```



### 2.构造器注入

1. 在bean中定义引用类型属性并提供可访问的构造器方法

   ```java
   public class BookServiceImpl implements BookService{
       private BookDao bookDao;
       private int num
       public void setBookDao(BookDao bookDao,int num){
           this.bookDao = bookDao;
           this.num = num;
       }
   }
   ```

2. 在配置中使用constructor-arg表i按ref属性注入引用数据类型

   ```xml
   <bean id="bookService" class="com.itheima.service.impl.BookServiceImpl">
   	<constructor-arg name="bookDao" ref="bookDao"/>
       <constructor-arg name="num" value="100"/>
   </bean>
   <bean id="bookDao" class="com.itheima.service.impl.BookDaoImpl"></bean>
   ```



## 5.依赖自动装配

IoC容器根据bean所依赖的资源在容器中自动查找被注入到bean中的过程称为**自动装配**

+ 自动装配的类型
  + 按类型（常用）
  + 按名称
  + 按构造方法
  + 不启动自动装配

1.按类型匹配

```xml
<bean id="bookService" class="com.itheima.service.impl.BookServiceImpl" autowire="byType"/>
原代码如下，修改如上，根据setter方法中的类型进行匹配
<bean id="bookService" class="com.itheima.service.impl.BookServiceImpl">
        <property name="bookDao" ref="bookDao"/>
    </bean>
```

2.按名称匹配

```xml
<bean id="bookService" class="com.itheima.service.impl.BookServiceImpl" autowire="byName"/>
<bean id="bookDao" class="com.itheima.dao.impl.BookDaoImpl"/>
如果自动匹配的第二个bean，那么要保证第二个bean的id与setter方法对应名称部分相同，id不匹配就注入失败，因此不推荐使用这种方法
```



## 6.集合注入

数组、list、set、Map、properties等通过setter方法注入

```xml
<bean id="bookDao" class="com.itheima.dao.impl.BookDaoImpl">
	<property name="array">
    	<array>
            <value>200</value>
        </array>
    </property>
    <property name="list">
    	<list>
            <value>200</value>
        </list>
    </property>
        <property name="set">
    	<set>
            <value>200</value>
        </set>
    </property>
    </property>
        <property name="list">
    	<list>
            <value>200</value>
        </list>
    </property>
    </property>
        <property name="map">
    	<map>
            <entry key="1" value="200"/>
        </map>
    </property>
    </property>
        <property name="properties">
    	<map>
            <prop key="1">200</prop>
        </map>
    </property>
</bean>
```



## 7.加载properties文件

1. 开启context命名空间

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:context="http://www.springframework.org/schema/context"
          xsi:schemaLocation="
           http://www.springframework.org/schema/beans
           http://www.springframework.org/schema/beans/spring-beans.xsd
           http://www.springframework.org/schema/context
           http://www.springframework.org/schema/context/spring-context.xsd
           ">
   </beans>
   ```

2. 使用context命名空间，加载指定的properties文件

   ```xml
   <context:property-placeholder localtion="classpath:*.properties"/>
   ```

3. 使用${}读取加载的属性值

   ```xml
   <property name="username" value="${jdbc.username}"/>
   ```

jdbc.properties文件

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/jdbc
jdbc.username=root
jdbc.password=030109
```



# 二、注解开发（简化开发）



## 1.Springboot2配置注解开发

1.使用@component定义bean

- 在需要配置bean的实现类上增加@Component("首字母小写的接口名")，注意不要写在接口上，如在BookDaoImpl类中
  - @Contorller:用于表现层bean定义
  - @Service:与用户业务层bean定义
  - @Repository：用于数据层bean定义

```java
@component("bookDao")
public class BookDaoImpl implements BookDao{}
```

2.核心配置文件中通过组件扫描加载bean

- 将配置文件applicationContext.xml文件中增加以下分析

```xml
<context:component-scan base-package="com.itheima"/>
扫描组件并配置bean，base-package表示自动配置com.itheima包下的所有的bean对象
如下：
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd
">
    <context:component-scan base-package="com.itheima"/>
</beans>
```



## 2.Spring3.0纯注解开发

1.使用Java类（配置类）代替配置文件，开启了Spring快速开发赛道

1. Java配置类代替Spring核心配置文件

   ```java
   @Configuration//设当当前类为配置类
   @ComponentScan({"com.itheiam.Dao","com.itheima.Service"})//设定扫描路径，此注解只能添加一次，多个数据使用数组格式作为参数传递
   public class SpringConfig{}
   ```

2. 读取Spring核心配置文件初始化容器对象--->读取Java配置类初始化容器对象

   ```java
   //加载配置类初始化容器
   ApplicationContext ctx = new AnnotationConfigApplicationContext(SpringConfig.class);
   ```



## 3.bean的作用范围和生命周期管理

1.bean的作用范围有单例和多例两种

- 通过@Scope注解进行配置，常用的有两种：singletom和prototype，放置在实现类上

2.bean的生命周期

- 通过@PostConstruct和@PreDestory两种注解进行初始化和销毁的配置

```java
@Repository
@Scpoe("singleton")
public class BookDaoImpl implements BookDao{
    @PostContruct//在构造器初始化之后
    public void Init(){}
    @PreDestory//在IoC容器销毁之前
    public void Destory(){}
}
```



## 4.依赖注入

使用@Autowired和@Qualifier("注入的bean的名称")进行自动装配模式（按类型）

```java
@Autowired
@Qualifier("bookDao")
private BookDao bookDao;
@Value("mamenghua")//注入简单类型
private String name;
```

- 自动装配基于反射设计创建对象并暴力反射对应属性为私有属性初始化数据，因此无需提供setter方法
- 自动配置建议使用午餐构造方法创建对象(默认)，如果不提供调用构造方法，请提供唯一的构造方法



## 5.加载properties文件

- 需要在配置类中使用@PropertySource注解加载properties文件

```java
@Configuration
@ComponentScan("com.itheima")
@PropertySource("classpath:jdbc.properties")
public class SpringConfig{}

//在其他类中通过@Value{"key"}进行赋值
@Value("jdbc.username")
private String name;
```

- 注意：路径仅支持单一文件配置，多文件请使用数组格式配置，不允许使用通配符*



## 6.第三方bean管理

- 使用@Bean配置第三方bean,将单独的配置类加入核心配置

```java
@Configuration
public class JdbcConfig{
    @Bean
    public DataSource dataSource(){
        DruidDataSource ds = new DruodDataSource();
        ds.setDriverClassName("com.mysql.jdbc.Driver");
        ds.setUrl("jdbc:mysql://localhost:3306/mysql");
        ds.setUserName("root");
        ds.setPassword("030109");
    }
}
```

```java
@Configuration
//有两种加入方式，分别是导入式和扫描式
//1.使用@Import注解将配置类手动加入到核心配置，此注解只能添加一次，多个数据请用数组格式
@Import(JdbcConfig.class)//导入式，此注解只能添加一次，多个数据使用数组格式
//2.使用@Component注解扫描配置类所在的包，加载对应的配置类信息。
@ComponentScan("{JdbcConfig}")//扫描式，不推荐使用
public class SpringConfig{}
```



## 7.总结

1.定义bean

>@Component
>
>- @Controller
>- @Service
>- @Repository
>
>@ComponentScan

2.设置依赖注入

> @Autowired
>
> - @Qualifier
>
> @Value

3.配置Bean：@Bean
4.作用范围：@Scope
5.生命周期：@PostConstruct、@PreDestory



























