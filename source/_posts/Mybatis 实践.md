---
title: MyBatis 实践
date: 2023-09-17
updated: 2024-09-19
sticky: 3
comments: true
category: MyBatis
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C.GKAMkayAM_3-HpEgKPnMewHaB2?w=329&h=87&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# Mybatis 实践

> Mybatis是一款持久层框架，在实体类和SQL语句之间建立映射关系，是一种半自动的ORM（对象关系映射）实现，通过Java语言完成对数据库的操作。
>
> 官网：[MyBatis中文官网](http://www.mybatis.cn/)
>
> - 持久层：指的就是数据访问层，用来操作数据库的
> - 框架：半成品软件，一套可重用的、通用的、软件基础代码模型。
>
> 使用Mybatis操作数据库，就是在Mybatis中编写SQL查询代码，发送给数据库执行，数据库执行后返回结果。
>
> Mybatis会把数据库执行的查询结果，使用实体类封装起来。在这个过程中，Mybatis会指定查询结果的封装对象，将数据库中表的字段和Java实体类对象的属性进行一一（驼峰命名）映射，将数据库中查询的结果封装到Java实体类对象中。



## 传统的JDBC介绍

JDBC： ( Java DataBase Connectivity )，使用java语言操作关系数据库的一套API。

JDBC对于数据库的操作步骤如下：

1. 注册驱动
2. 获取连接对象
3. 执行SQL语句，返回执行结果
4. 处理执行结果
5. 释放资源

原始的JDBC程序，存在以下几点问题：

1. 数据库链接的四要素(驱动、链接、用户名、密码)全部硬编码在java代码中
2. 查询结果的解析及封装非常繁琐
3. 每一次查询数据库都需要获取连接,操作完毕后释放连接, 资源浪费, 性能降低

分析了JDBC的缺点之后，在mybatis中解决了这些问题的：

1. 数据库连接四要素(驱动、链接、用户名、密码)，都配置在springboot默认的配置文件 application.properties 中

2. 查询结果的解析及封装，由mybatis自动完成映射封装，我们无需关注

3. 在mybatis中使用了数据库连接池技术，从而避免了频繁的创建连接、销毁连接而带来的资源浪费。



## 数据库连接池

客户端执行SQL语句：要先创建一个新的连接对象，然后执行SQL语句，SQL语句执行后又需要关闭连接对象从而释放资源，每次执行SQL时都需要创建连接、销毁连接，这种频繁的重复创建销毁的过程是比较耗费计算机的性能。

> 每执行一次SQL语句都要创建一个新的连接，执行完之后需要将该连接删除

数据库连接池存放了一定数量的Connection对象。允许应用程序重复使用一个现有的数据库连接。

>数据库连接池是个容器，负责分配、管理数据库连接(Connection)
>
>- 程序在启动时，会在数据库连接池(容器)中，创建一定数量的Connection对象
>
>允许应用程序重复使用一个现有的数据库连接，而不是再重新建立一个
>
>- 客户端在执行SQL时，先从连接池中获取一个Connection对象，然后在执行SQL语句，SQL语句执行完之后，释放Connection时就会把Connection对象归还给连接池（Connection对象可以复用）
>
>释放 空闲时间 超过 最大空闲时间 的 连接，来避免因为没有释放连接而引起的数据库连接遗漏
>
>- 客户端获取到Connection对象了，但是Connection对象并没有去访问数据库(处于空闲)，数据库连接池发现Connection对象的空闲时间 > 连接池中预设的最大空闲时间，此时数据库连接池就会自动释放掉这个连接对象

数据库连接池的好处：

1. 资源重用
2. 提升系统响应速度
3. 避免数据库连接遗漏

常见的数据库连接池：

* C3P0
* DBCP
* Druid
* Hikari (springboot默认)

如何使用Druid数据库连接池：

1.在pom.xml文件中引入依赖

```xml
<dependency>
    <!-- Druid连接池依赖 -->
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.2.8</version>
</dependency>
```

2.在application.properties文件中映入数据库连接配置

```properties
spring.datasource.druid.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.druid.url=jdbc:mysql://localhost:3306/mybatis
spring.datasource.druid.username=root
spring.datasource.druid.password=1234

#日志输出
mybatis.configuration.log-impl=org.apache.ibatis.logging.stdout.StdOutImpl
```



## 1.使用mybatis操作数据库的步骤

Mybatis操作数据库的步骤：

1. 准备工作(创建springboot工程、数据库表user、实体类User)
2. 引入Mybatis的相关依赖，配置Mybatis(数据库连接信息)
3. 编写SQL语句(注解/XML)



### 1.使用maven引入mybatis依赖

```xml
<dependencies>
        <!-- mybatis起步依赖 -->
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.3.0</version>
        </dependency>
        <!-- mysql驱动包依赖 -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>
</dependencies>
```



### 2.为Mybatis连接数据库配置信息

通过编写application.properties文件配置数据库连接信息。包含驱动、路径、用户名、密码

```properties
#驱动类名称
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
#数据库连接的url，最后面的mybatis为连接的数据库的名称，可以自定义修改
spring.datasource.url=jdbc:mysql://localhost:3306/mybatis
#连接数据库的用户名，一般来说都是root
spring.datasource.username=root
#连接数据库的密码，密码需要修改为自己的密码
spring.datasource.password=1234
```



### 3.编写SQL语句

编写SQL语句一般编写在持久层接口（XxxMapper）中。注意这里是一个接口

```java
@Mapper
public interface UserMapper {
    
    //查询所有用户数据
    @Select("select id, name, age, gender, phone from user")
    public List<User> list();
    
}
```

> @Mapper注解：表示是mybatis中的Mapper接口
>
> - 程序运行时：框架会自动生成接口的实现类对象(代理对象)，并给交Spring的IOC容器管理
>
> @Select注解：代表的就是select查询，用于书写select查询语句



### 4.SQL安全

SQL注入：是通过操作输入的数据来修改实现定义好的SQL语句，以达到执行代码对服务器进行高级的方法。

参数占位符：一般使用**#{}**

- 执行SQL时，会将#{…}替换为?，生成预编译SQL，会自动设置参数值
- 使用时机：参数传递，都使用#{…}

使用MySQL提供的字符串拼接函数：concat('%' , '关键字' , '%')

```java
@Mapper
public interface EmpMapper {

    @Select("select * from emp " +
            "where name like concat('%',#{name},'%')")
    public List<Emp> list(String name);

}
```



### 5.主键返回

默认情况下，执行插入操作时，是不会主键值返回的。如果我们想要拿到主键值，需要在Mapper接口中的方法上添加一个Options注解，并在注解中指定属性useGeneratedKeys=true和keyProperty="实体类属性名"

```java
@Mapper
public interface EmpMapper {
    
    //会自动将生成的主键值，赋值给emp对象的id属性
    @Options(useGeneratedKeys = true,keyProperty = "id")
    @Insert("")
    public void insert(Emp emp);

}
```

### 6.数据封装

**手动结果映射**：通过 @Results及@Result 进行手动结果映射

```java
@Results({@Result(column = "dept_id", property = "deptId"),
          @Result(column = "create_time", property = "createTime"),
          @Result(column = "update_time", property = "updateTime")})
@Select("select id, username, password, name, gender, image, job, entrydate, dept_id, create_time, update_time from emp where id=#{id}")
public Emp getById(Integer id);
```

**开启驼峰命名(推荐)**：如果字段名与属性名符合驼峰命名规则，mybatis会自动通过驼峰命名规则映射

```properties
# 在application.properties中添加：
mybatis.configuration.map-underscore-to-camel-case=true
```

> 要使用驼峰命名前提是 实体类的属性 与 数据库表中的字段名严格遵守驼峰命名。



## 2.Mybatis的XML配置文件

- **Mybatis的配置文件写在 resources 文件夹下**

Mybatis 的开发由两种方式：

1. 注解：用于完成一些简单的增删查改功能
2. XML：用于完成一些复杂的增删查改功能，使用XML配置映射语句，将SQL语句写在XML配置文件中。



在Mybatis中使用 XML 映射文件方式开发，需要符合一定的规范：

1. XML映射文件的名称与Mapper接口名称一致，并且将XML映射文件和Mapper接口放置在相同包下（同包同名）

2. XML映射文件的namespace属性为Mapper接口全限定名一致

3. XML映射文件中sql语句的id与Mapper接口中的方法名一致，并保持返回类型一致。

编写Mybatis配置文件需要通过Mybatis的dtd约束

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
  PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="Mapper接口全限定名/com.itheima.mapper.XxxMapper">
 <select id="list" resultType="">
     <!--查询语句-->
    <!--XML映射文件中sql语句的id与Mapper接口中的方法名一致，并保持返回类型一致-->
    </select>
</mapper>
```



## 3.Mybatis动态SQL

动态SQL：在SQL语句中动态地传递参数进行语句拼接。SQL语句会随着用户的输入或外部条件的变化而变化。

Mybatis'实现动态SQL的标签：<if>、<where>、<set>、<foreach>、<sql>and<include>

- `<where>`只会在子元素有内容的情况下才插入where子句，而且会自动去除子句的开头的AND或OR
- `<if>`：用于判断条件是否成立。使用test属性进行条件判断，如果条件为true，则拼接SQL。
- `<set>`：动态的在SQL语句中插入set关键字，并会删掉额外的逗号。（用于update语句中）
- `<foreach>`：使用`<foreach>`遍历deleteByIds方法中传递的参数ids集合
- `<sql>`：定义可重用的SQL片段
- `<include>`：通过属性refid(在sql标签中id的值)，指定包含的SQL片段

```xml
<select id="list" resultType="com.itheima.pojo.Emp">
        select * from emp
        <where>
             <!-- if做为where标签的子元素 -->
             <if test="name != null">
                 and name like concat('%',#{name},'%')
             </if>
             <if test="gender != null">
                 and gender = #{gender}
             </if>
             <if test="begin != null and end != null">
                 and entrydate between #{begin} and #{end}
             </if>
        </where>
</select>
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.itheima.mapper.EmpMapper">

    <!--更新操作-->
    <update id="update">
        update emp
        <!-- 使用set标签，代替update语句中的set关键字 -->
        <set>
            <if test="username != null">
                username=#{username},
            </if>
            <if test="name != null">
                name=#{name},
            </if>
            <if test="gender != null">
                gender=#{gender},
            </if>
            <if test="image != null">
                image=#{image},
            </if>
            <if test="job != null">
                job=#{job},
            </if>
            <if test="entrydate != null">
                entrydate=#{entrydate},
            </if>
            <if test="deptId != null">
                dept_id=#{deptId},
            </if>
            <if test="updateTime != null">
                update_time=#{updateTime}
            </if>
        </set>
        where id=#{id}
    </update>
</mapper>
```

```xml
<foreach collection="集合名称" item="集合遍历出来的元素/项" separator="每一次遍历使用的分隔符" open="遍历开始前拼接的片段" close="遍历结束后拼接的片段">
</foreach>

<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.itheima.mapper.EmpMapper">
    <!--删除操作-->
    <delete id="deleteByIds">
        delete from emp where id in
        <foreach collection="ids" item="id" separator="," open="(" close=")">
            #{id}
        </foreach>
    </delete>
</mapper> 
```



