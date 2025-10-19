---
title: SpringBoot
date: 2023-09-20
updated: 2024-07-01
comments: true
category: SpringBoot
cover: https://tse3-mm.cn.bing.net/th/id/OIP-C.ZcK6buln_11JJkcngHzg4gHaC1?w=301&h=134&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# SpringBoot

- GET：用于获取资源
- POST：用于新建资源
- PUT：用于更新资源
- DELETE：用于删除资源

## 1.yml配置信息的书写与获取

- 书写

```yml
email:
	user: 50184777@qq.com #值前必须有空格，作为分隔符
	#使用空格作为缩进表示层级关系，系统的层级左侧对齐
```

- 配置信息

```java
@Value("${键名}")
@ConfigurationProperties(prefix = "前缀")//springboot自动封装
```

**注意：**配置文件在打包成jar包之后不能直接修改了，需要在jar项目下创建一个新的application.yml文件其中的配置会覆盖原来的配置

### 配置tomcat启动端口

```yaml
server:
	port: 9090
```



## 2.Spring Boot整合MyBatis

- 依赖

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.3.1</version>
</dependency>
<!--该起步依赖会讲其中的一些bean自动配置到IoC容器中-->
<!--注意还要引入MySQL驱动依赖；数据库驱动依赖-->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.30</version>
</dependency>
```

- 在application.yml文件中配置信息

```yml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc://localhost:3306/mybatis
    username: root
    password: 030109
```

- 直接使用即可

## 3.Bean扫描

- 标签：<context：component-scan base-package="com.itheima">
- 注解：
  - @ComponentScan(basePackages="com.itheima")
  - @SpringBootApplication   组合注解，里面含有ComponentScan注解，默认扫描该启动类所在的包及其子包
  
  注意：SpringBoot中的Bean扫描只需要在启动类上加上@SpringBootApplication组合注解

### 3.1 bean注册

注意外部bean的注册需要在配置类中进行（加上@Configuration注解的类）

- Component（声明Bean的基础注解，下面三个注解都是该注解的衍生注解）
- Controller
- Service
- Repository/Mapper

如果要注册的bean对象来自于第三方（不是自定义的），是无法使用@Component以及其衍生注解声明bean的

- @Bean：告诉Spring的IOC容器，下面定义的这个对象是一个Bean

```java
//通常在CommonConfig配置类中
@Bean  //@Bean("xxx")使用这样的注解，在IoC容器中这个类的bean的名称是xxx，而不是对象名了
public 需要注入IOC容器对象的类名	对象名(){
    return new 需要注入IOC容器对象的类名();
}
```

- @Import
  - 导入 配置类
  - 导入 ImportSelector接口实现类

```java
@Import({Xxx.class,Xxx.class,Xxx.class})
这个Xxx配置类放在启动类所在包的外部时才需要@Import引入，注意配置类中需要有@Bean注解注册某个类的bean对象
```

```java
public class CommonImportSelector implements ImportSelector {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{"com.itheima.config.CommonConfig"};
    }
}

启动类中加上下面的注解
@Import(CommonImportSelector.class)
```

### 3.2 bean注解条件

- @ConditionOnProperty：配置文件中存在对应的属性，才声明该bean
  **@ConditionOnProperty(prefix="",name={"","",""})**

- @ConditionOnMissingBean：当不存在当前类型的Bean时，才声明该bean
  **@ConditionOnMissingBean(Xxx.class)**

- @ConditionOnClass：当前环境存在指定的这个类时，才声明该bean

  **@ConditionOnClass(name="全限定类名")**

## 4.自动配置原理

**自动配置：**遵循约定大约配置的原则，在boot程序启动后，起步依赖中的一些bean对象会自动注入到IOC容器中

- 在主启动类上的SpringBootApplication注解组合了 EnableAutoConfiguration注解
- EnableAutoConfiguration注解又组合了Import注解，导入了AutoConfigurationImportSelector类
- 实现selectImports方法，这个方法经过层层调用，最终会读取META_INF目录下的后缀名为imports的文件（注意，SpringBoot2.7之前的版本读取的是spring.factories文件，2.7-3.0之间两种文件都读，3.0之后只能读imports文件）
- 读取到全类名了之后，会解析注册条件，也就是@Conditional及其衍生注解，把满足注册条件的Bean对象自动注入到IOC容器中。

## 5.参数校验

使用Spring Validation

### 1.对注册接口的参数进行合法性校验

- 引入Spring Validation 依赖
- 在参数前面添加@Pattern注解(@Pattern(regexp="^\\\s{5,16}$") String name)        #正则表达式
- 在Controller类上添加@Validated注解

```java
@Validated
@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;
    @PostMapping("/register")
    public Result register(@Pattern(regexp = "^\\S{5,16}$")String username , @Pattern(regexp = "^\\S{5,16}$")String password) {
        User user = userService.findByName(username);
        if(user == null) {
            userService.register(username,password);
            return Result.success("注册成功");
        }else {
            return  Result.error( "用户名已存在");
        }
    }
    @PostMapping("/login")
    public Result<String> login(@Pattern(regexp = "^\\S{5,16}")String username,@Pattern(regexp = "^\\S{5,16}$")String password){
//根据用户名查询用户
        User user = userService.findByName(username);
        if(user == null) {
            return Result.error("用户名不存在");
        }
        if(Md5Util.getMD5String(password).equals(user.getPassword())) {
            return Result.success("jwt令牌");
        }
        return Result.error("密码错误");
    }
}
```

### 2.实体参数校验

当使用这些注解时，需要注意的是要在相关接口方法的实体参数前加上@Validated

```java
    @NotNull//不能不传递
    private Integer id;//主键ID
//当mvc把当前对象转换成json字符串时，忽略password，最终转换的json字符串中就没有password这个属性
    @JsonIgnore//注意这个注解不是参数校验的注解
    private String password;//密码
    @NotEmpty//不能不传递，传递的参数为字符串时，不能为空字符串
    @Pattern(regexp = "^\\s{1,10}$",message = "昵称不能为空")
    private String nickname;//昵称
    @NotEmpty
    @Email
    private String email;//邮箱


//注意要在实体参数前面加上@Validated，这时校验条件才会生效，否则不进行参数的校验
	public Result update(@RequestBody @Validated User user)
```

### 3.分组校验

把校验项进行归类分组，在完成不同的功能的时候，校验指定族中的校验项。
定义校验项时如果没有指定分组，默认属于Default分组，分组之间继承。

1. 定义分组	使用接口定义分组
2. 定义校验项时指定归属的分组       groups={a.class,b.class}
3. 校验时指定要校验的分组         在控制器中的实体参数前面加上@Validated(类名.分组名.Class)

> 1. 如何定义分组-->在实体类内部定义接口
> 2. 如何对校验项分组-->通过groups属性指定
> 3. 校验时如何指定分组-->在控制器中给@Validated注解的value属性赋值
> 4. 校验项默认属于Default分组

```java
@Data
public class Category {
    @NotNull(groups = Update.class)
    private Integer id;//主键ID
//    @NotEmpty(groups = {Update.class,Add.class})
    @NotEmpty//这里的分组继承了默认分组，没有加上分组名就是使用了默认分组即使用了Update和Add两个分组，因为这两个分组都继承了默认分组
    private String categoryName;//分类名称
    @NotEmpty(groups = {Update.class,Add.class})
    private String categoryAlias;//分类别名
    private Integer createUser;//创建人ID
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;//创建时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;//更新时间

//    public interface Update{
//
//    }
//    public interface Add{
//
//    }

    public interface Update extends Default {

    }
    public interface Add extends Default{

    }
}


//在控制类中校验时指定要校验的分组
public Result update(@RequestBody @Validated(Category.Update.class)  Category category)
```





### 4.自定义校验

已有的注解不能满足所有的校验需求，特殊的情况需要自定义校验（自定义校验注解）

1. 自定义注解Status
2. 自定义校验数据的类StateValidation，实现ConstraintValidator接口
3. 在需要的地方使用自定义注解

State自定义注解

```java
@Documented//元注解，标识State，可以抽取到帮助文档中
//Target元注解，标识State注解可以使用在哪些地方（方法、字段、注解类型、构造方法等等地方）
@Target({ElementType.FIELD})
//@Retention注解指定了该注解在编译、类加载和运行时的状态，参数值为RUNTIME表示该注解在运行时仍然保留。
@Retention(RetentionPolicy.RUNTIME)
//指定为这个注解提供校验规则的类为”StateValidation“
@Constraint(validatedBy = { StateValidation.class})
public @interface State {
	//提供校验失败后的提示信息
	String message() default "state参数的值只能是已发布或草稿";
	//指定分组
	Class<?>[] groups() default {};
	//负载  获取到State注解的附加信息，一般用不到
	Class<? extends Payload>[] payload() default {};
}

```

指明校验规则的类

```java
//ConstraintValidation<给哪个注解提供校验规则,校验的数据类型>
public class StateValidation implements ConstraintValidator<State,String > {

	/**
	 *
	 * @param value 将来要验证的数据
	 * @param context
	 * @return 如果返回false，则校验不通过，反之校验通过
	 */
	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		//提供校验规则
		if(value == null)
			return false;
		if (value.equals("已发布")||value.equals("草稿"))
			return true;
		return false;
	}
}

```



## 6.全局异常处理器

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(Exception.class)
    public Result handleException(Exception e){
        e.printStackTrace();
        return Result.error(StringUtils.hasLength(e.getMessage()) ? e.getMessage():"操作失败");
    }
}
```

## 7.登陆验证

令牌技术：JWT（JSON Web Token）

令牌：就是一段字符串

- 承载业务数据，减少后续请求查询数据库的次数
- 防篡改，保证信息的合法性和有效性

JWT：定义了一种简洁的、自包含的格式，用于通信双方以json数据格式安全的传输信息。

组成：auifewuif.fuiwrgfw.srihgoerhg0ew=

- Header(头)，记录令牌类型、算法签名等。例如：{"alg":"HS256","type":"JWT"}
- Payload(有效载荷)：携带一些自定义信息、默认信息等。例如{"id":"1","username","Tom"}
- Signature(签名)：防止Token被篡改，确保安全性。将header、payload，并加入指定密钥，通过指定签名算法计算而来。

1.导入JWTUtil工具类

```java
public class JwtUtil {
    private static final String KEY = "itheima";
	//接收业务数据,生成token并返回
    public static String genToken(Map<String, Object> claims) {
        return JWT.create()
                .withClaim("claims", claims)
                .withExpiresAt(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 12))
                .sign(Algorithm.HMAC256(KEY));
    }
	//接收token,验证token,并返回业务数据
    public static Map<String, Object> parseToken(String token) {
        return JWT.require(Algorithm.HMAC256(KEY))
                .build()
                .verify(token)
                .getClaim("claims")
                .asMap();
    }
}
```

2.用户登录时生成JWT

```java
    if(Md5Util.getMD5String(password).equals(user.getPassword())) {
        Map<String,Object> cliams = new HashMap<>();
        cliams.put("id",user.getId());
        cliams.put("username", user.getUsername());
        String token = JwtUtil.genToken(cliams);
        return Result.success(token);
    }
```

3.解析JWT

JWT一般解析在拦截器中，拦截器将所有的请求拦截之后，得到请求头中的token（存储着jwt令牌），将其加入Thread Local对象中，标识本次操作人员的身份

```java
Map<String, Object> claims = JwtUtil.parseToken(token);
```

### 问题

这种登录方式存在一个问题，就是短时间多次登录，生成的多个令牌都可以正常使用，用户账号被盗之后，即使修改密码，重新登陆，盗号者仍然可以通过原来的jwt令牌篡改数据。

解决方案：令牌主动失效机制

- 登录成功之后，给浏览器响应令牌的提示，把该令牌存储到redis中
- LoginInterceptor拦截器中，需要验证浏览器携带的令牌，同时需要获取到redis中存储的与之相同的令牌
- 当用户修改密码成功后，删除redis中存储的旧令牌

## 8.拦截器（interceptor）

- Login拦截器类：实现HandlerInterceptor接口，重写preHandle方法（在目标方法执行之前进行拦截）
- Web配置类：实现WebMvcConfigurer接口，重写addInterceptors方法，注册拦截器

```java
@Component
public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //令牌验证
        String token = request.getHeader("Authorization");
        try {
            //解析jwt令牌
            Map<String, Object> claims = JwtUtil.parseToken(token);
            //如果登陆成功就将jwt令牌解析后的用户信息（名称、id等）加入线程
            ThreadLocalUtil.set(claims);
            return true;
        } catch (Exception e) {
            response.setStatus(401);
            return false;
        }
    }
}
```

### 注册拦截器配置类

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Autowired
    private LoginInterceptor loginInterceptor;

    public void addInterceptors(InterceptorRegistry registry) {
        //登录接口和注册接口不拦截，注册拦截器
      registry.addInterceptor(loginInterceptor).excludePathPatterns("/user/login","/user/register");
    }
}
```

## 9.ThreadLocal的使用

ThreadLocal提供线程局部变量

- 用来存取数据：set()/get()
- 使用ThreadLocal存储的数据，线程安全

1.导入ThreadLocalUtil工具类

```java
public class ThreadLocalUtil {
    //提供ThreadLocal对象,
    private static final ThreadLocal THREAD_LOCAL = new ThreadLocal();
    //根据键获取值
    public static <T> T get(){
        return (T) THREAD_LOCAL.get();
    }
    //存储键值对
    public static void set(Object value){
        THREAD_LOCAL.set(value);
    }
    //清除ThreadLocal 防止内存泄漏
    public static void remove(){
        THREAD_LOCAL.remove();
    }
}
```

2.在拦截器中使用ThreadLocalUtil进行设置线程内容以及释放线程

```java
public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //令牌验证
        String token = request.getHeader("Authorization");
        Map<String, Object> claims = JwtUtil.parseToken(token);
        ThreadLocalUtil.set(claims);
    }

public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        ThreadLocalUtil.remove();
    }
```

## 10.分页查询

1. 引入分页查询插件PageHelper的坐标
   ```xml
       <dependency>
         <groupId>com.github.pagehelper</groupId>
         <artifactId>pagehelper-spring-boot-starter</artifactId>
         <version>1.4.6</version>
       </dependency>
   ```

2. 创建封装分页查询结果的类PageBean
   ```java
   @Data
   @NoArgsConstructor
   @AllArgsConstructor
   public class PageBean <T>{
       private Long total;//总条数
       private List<T> items;//当前页数据集合
   }
   ```

3. 在控制器中使用PageBean<类名>来接收查询的结果
   ```java
       @GetMapping
       public Result<PageBean<Article>> list(Integer pageNum,Integer pageSize,@RequestParam(required = false) Integer categoryId,@RequestParam(required = false) String state){
           PageBean<Article> pageBean = articleService.list(pageNum,pageSize,categoryId,state);
           return Result.success(pageBean);
       }
   ```

4. 在服务层通过分页查询插件实现分页查询
   ```java
   	public PageBean<Article> list(Integer pageNum, Integer pageSize, Integer categoryId, String state) {
   		//2.开启分页查询，需要使用PageHelper插件，需要导入这个插件的坐标
   		//PageHHelper会自动将pageNum和pageSize拼接到SQL语句后面，加上limit，完成一个分页查询
   		PageHelper.startPage(pageNum,pageSize);
   		//3.调用napper
   		Map<String,Object> claim =ThreadLocalUtil.get();
   		Integer userId = (Integer) claim.get("id");
   		Page<Article> page  = articleMapper.list(userId,categoryId,state);
   		return new PageBean(page.getTotal(),page.getResult());
   	}
   ```

5. 在数据访问层访问数据，以及创建xml文件

   ```java
   Page<Article> list(Integer userId, Integer categoryId, String state);
   ```

   ```xml
   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE mapper
           PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
           "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
   <mapper namespace="com.itheima.mapper.ArticleMapper">
       <select id="list" resultType="com.itheima.pojo.Article">
           select * from article
           <where>
               <if test="categoryId != null">
                   category_id = #{categoryId}
               </if>
               <if test="state != null and state != ''">
                   and state = #{state}
               </if>
           and create_user = #{userId}
           </where>
       </select>
   </mapper>
   ```
   

## 12.实体类日期转换

数据库取出的日期会转换为：	2023-12-02T23:28:15
要将获取的日期转换为正常：	2023-12-02 23:28:15

需要在该属性上添加@JsonFormat注解如下

```java
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
private LocalDateTime createTime;//创建时间
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
private LocalDateTime updateTime;//更新时间
```



## 13.SpringBoot整合redis

1.在pom.xml中引入依赖坐标

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

2.在application.yml中配置redis配置信息

```yml
spring:
  data:
    redis:
      host: localhost
      port: 6379
```

3.打开redis在电脑的本地服务

4.进行操作

## 14.springBoot项目部署

- 引入打包插件，可以将写好的代码编译打包生成一个jar包
  ```xml
    <build>
      <plugins>
        <plugin>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-maven-plugin</artifactId>
          <version>3.1.3</version>
        </plugin>
      </plugins>
    </build>
  ```

- 刷新maven之后进行打包操作
  
  - 执行Lifecycle中的**package**指令进行打包：编译-->测试-->打包

  - **打包好的jar包存放在target目录下**
  
- 将项目的jar包发送到服务器上，在服务器上使用**java -jar 项目jar包的位置**指令来运行jar包

- 注意jar包部署时，服务器必须要有jre环境

- 停止服务器java服务：Ctrl+C

### 切换tomcat运行端口号

### 1.命令行参数方式

```java
//	参考：--键=值
java -jar 项目jar包的位置 --server.port=9090
```

### 2.环境变量方式

在系统的高级系统设置中增加环境变量

- 直接运行jar包，SpringBoot自动读取并使用这些环境变量

```xml
变量:server.port
值  :9090
```

### 3.配置优先级

**优先级从上往下依次变高**

- 项目中resource目录下的application.yml
- jar包所在的目录下的application.yml
- 操作系统环境变量
- 命令行参数



## 15.多环境开发profiles

程序可能会运行在不同的环境中，常见的三种环境有：开发、测试、生产

如：在开发、测试、生产使用不同的数据库环境，以方便测试。

Spring Boot提供的Profiles可以用来隔离应用程序配置的各个部分，并在特定环境下指定部分配置生效。

如果特定环境中的配置和通用信息冲突了，则生效的是特定环境中的配置

- 如何分隔不同环境的配置？
  ```yaml
  ---
  ```

- 如何指定哪些配置属于哪个环境？
  ```yaml
  spring:
    config:
      activate:
        on-profile: 环境名称
  ```

- 如何指定哪个环境的配置生效

  ```yaml
  spring:
    profiles:
      activate: 环境名称
  ```

如下：

### 1.多环境开发单环境使用

```yaml
#多环境下共享的属性
#通用信息，指定生效的环境为开发环境
spring:
  profiles:
    activate: dev

---
#开发环境 dev
spring:
  config:
    activate:
      on-profile: dev
server:
  port:8081
---
#测试环境 test
spring:
  config:
    activate:
      on-profile: test
server:
  port:8082
---
#生产环境  pro
spring:
  config:
    activate:
      on-profile: pro
server:
  port:8083
```

### 2.多环境开发多文件使用

- 使用多个yml文件进行指定配置信息

  > - application-dev.yml：开发环境    的配置信息
  > - application-test.yml：测试环境    的配置信息
  > - application-pro.yml：生产环境    的配置信息
  > - application.yml：共性配置并激活指定环境

### 3.多环境开发-profiles-分组

profiles提供了对配置文件分组的功能：把开发环境的配置信息根据功能的不同再次进行拆分，把它们写到不同的配置文件里边，使用分组让与开发环境相关的多个配置文件生效，如下

> - 按照配置的类别，把配置信息配置到不同的配置文件中
>   - application-分组名.yml
> - 在application.yml中定义分组
>   - spring.profiles.group
> - 在application.yml中激活分组
>   - spring.profiles.active

```yaml
#application-devServer.yml		服务器相关配置
#application-devDB.yml			数据源相关配置
#application-devSelf.yml		自定义配置


application.yml
spring:
  profiles:
    group:
      "dev": devServer,devDB,devSelf
    active: dev
```





























