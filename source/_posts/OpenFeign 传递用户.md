---
title: OpenFeign 传递用户
date: 2024-07-27
updated: 2024-07-27
tags: 
  - 实战
category: SpringCloud
comments: true
cover: https://ts2.cn.mm.bing.net/th?id=OIP-C.KgHvzGJ_yB1eB3vRjQ3eJAHaEK&w=333&h=187&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2
---
# OpenFeign 传递用户

**背景：**不同微服务之间通过 `OpenFeign` 实现远程调用

> 实现微服务之间的通信传递用户信息
>
> - 由于微服务获取用户信息是通过拦截器在请求头中读取，因此要想实现微服务之间的用户信息传递，就**必须在微服务发起调用时把用户信息存入请求头**。
>
> - 由于微服务之间调用是基于 OpenFeign 来实现的，需要实现让每一个由 OpenFeign 发起的请求自动携带登录用户信息。



>需要借助 Feign 中提供的一个拦截器接口：`feign.RequestInterceptor`
>
>-  OpenFeign 每次发起远程调用前,底层都会自动调用 apply 方法

```Java
public interface RequestInterceptor {

  /**
   * Called for every request. 
   * Add data using methods on the supplied {@link RequestTemplate}.
   */
  void apply(RequestTemplate template);
}
```

只需要实现这个接口，然后实现 `apply` 方法，利用`RequestTemplate`类来添加请求头，将用户信息保存到请求头中。这样以来，每次 `OpenFeign` 发起请求的时候都会调用该方法，传递用户信息。

编写配置类

```Java
public class DefaultFeignConfig {
    @Bean
    public RequestInterceptor userInfoRequestInterceptor(){
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate template) {
                // 获取登录用户
                Long userId = UserContext.getUser();
                if(userId == null) {
                    // 如果为空则直接跳过
                    return;
                }
                // 如果不为空则放入请求头中，传递给下游微服务
                template.header("user-info", userId.toString());
            }
        };
    }
}    
```



让其全局生效：在`@EnableFeignClients`中配置，针对所有`FeignClient`生效。

```Java
@EnableFeignClients(defaultConfiguration = DefaultFeignConfig.class)
```