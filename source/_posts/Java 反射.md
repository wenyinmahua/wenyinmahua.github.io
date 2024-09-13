---
title: Java 反射
date: 2023-06-21
comments: true
category: java
tags:
  - 基础
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C._Lm_T3scKhVEVFC54gcRxwHaE8?w=249&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---



## 反射

是指在运行时去获取一个类的变量和方法信息。然后通过获取到的信息来创建对象，调用方法的一种机制。由于这种动态性，可以极大的增强程序的灵活性，程序不用在编译期就完成确定，在运行期仍然可以扩展。



获取 Class 类对象的四种方式

- 类名.class属性（知道具体类的情况下）
- 对象名.getClass()方法（通过对象实例获取）
- Class.forName(全类名)方法（通过传入类的全路径获取）
- 通过类加载器传入类路径获取

```java
Class<Student> c1 = Student.class;
Student student = new Student();
Class<Student> c2 = student.getClass();
Class<?> c4 = Class.forName("com.mahua.Student");
ClassLoader.getSystemClassLoader().loadClass("com.mahua.Student");
```



#### Class类获取构造方法对象的方法

| 方法名                                                       | 说明                                     |
| ------------------------------------------------------------ | ---------------------------------------- |
| Constructor<?>[] getConstructors()                           | 返回所有公共构造方法对象的数组           |
| Constructor<?>[] getDeclaredConstructors()                   | 返回所有构造方法对象的数组（包含私有的） |
| Constructor<T> getConstructor(Class<?>... parameterTypes)    | 返回单个公共构造方法对象                 |
| Constructor<T> getDeclaredConstructor(Class<?>... parameterTypes) | 返回单个构造方法对象（可以是私有的）     |



#### Constructor类用于创建对象的方法

| 方法名                           | 说明                       |
| -------------------------------- | -------------------------- |
| T newInstance(Object...initargs) | 根据指定的构造方法创建对象 |



#### Class类获取成员变量对象的方法

| 方法名                              | 说明                           |
| ----------------------------------- | ------------------------------ |
| Field[] getFields()                 | 返回所有公共成员变量对象的数组 |
| Field[] getDeclaredFields()         | 返回所有成员变量对象的数组     |
| Field getField(String name)         | 返回单个公共成员变量对象       |
| Field getDeclaredField(String name) | 返回单个成员变量对象           |



```java
Class<?> c = Class.forName("com.mahua.studytest.classLoad.Student");
Constructor<?> con = c.getDeclaredConstructor(String.class);
//暴力反射，可以调用私有方法。
//public void setAccessible(boolean flag):值为true，取消访问检查
con.setAccessible(true);
Object obj = con.newInstance("mahua");
System.out.println(obj);
```



#### Class类获取成员变量对象的方法

| 方法名                              | 说明                           |
| ----------------------------------- | ------------------------------ |
| Field[] getFields()                 | 返回所有公共成员变量对象的数组 |
| Field[] getDeclaredFields()         | 返回所有成员变量对象的数组     |
| Field getField(String name)         | 返回单个公共成员变量对象       |
| Field getDeclaredField(String name) | 返回单个成员变量对象           |



#### Field类用于给成员变量赋值的方法

| 方法名                            | 说明                           |
| --------------------------------- | ------------------------------ |
| void set(Object obj,Object value) | 给obj对象的成员变量赋值为value |



#### Class类获取成员方法对象的方法

| 方法名                                                       | 说明                                       |
| ------------------------------------------------------------ | ------------------------------------------ |
| Method[] getMethods()                                        | 返回所有公共成员方法对象的数组，包括继承的 |
| Method[] getDeclaredMethods()                                | 返回所有成员方法对象的数组，不包括继承的   |
| Method getMethod(String name, Class<?>... parameterTypes)    | 返回单个公共成员方法对象                   |
| Method getDeclaredMethod(String name, Class<?>... parameterTypes) | 返回单个成员方法对象                       |

#### Method类用于执行方法的方法

| 方法名                                   | 说明                                                 |
| ---------------------------------------- | ---------------------------------------------------- |
| Object invoke(Object obj,Object... args) | 调用obj对象的成员方法，参数是args,返回值是Object类型 |













