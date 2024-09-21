---
title: JVM 基础（四）类加载器
date: 2024-08-29
updated: 2024-08-29
category: JVM
tags:
  - 笔记
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.iK1EFamgj6pjOvuhROEFNAHaEK?w=305&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7

---



# JVM 基础（四）类加载器

## 导言

> 在 Java 中，程序员编写出的代码为源代码，要让机器能看懂并执行，就要转换成机器语言，但是在不同的平台（操作系统）上将源代码编译后的机器语言可能不一样，因此可能会需要多次编译，才能在不同的平台上运行。而 Java 为了解决这个问题，实现跨平台的功能，设计了 JVM。源代码经过编译后生成 `class` 字节码文件，也就是中间代码，中间代码通过 不同平台的 JVM 解释后，会解释成相关平台能识别的机器语言。
>
> JVM 是怎么实现跨平台的呢？
>
> ![JDK 的版本分类](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240920110542612.png)
>
> - 由上图可见，JDK 分为 Linux、macOS、Windows，这些不同版本的 JVM 实现各不相同。
> - 如果将 Java 编译后生成一份字节码文件（中间代码），它们能将同一份字节码文件编译成不同平台上能识别的机器语言，就这样水灵灵地实现了跨平台的功能。这就是所说的“一次编译，到处运行”。
>
> JVM 本来就是运行在计算机上的程序，它负责解释和执行Java字节码。这个字节码怎么获取呢？
>
> - 答案是通过**类加载器**。



类加载器的运行机制是 Java 虚拟机（JVM）中的一个重要部分，它负责将类的二进制数据（字节码文件）加载到 JVM 的方法区，并生成一个对应的 `Class` 对象（虚拟机会在方法区和堆上生成对应的对象保存字节码信息）。类加载器的运行遵循双亲委派模型（Parent Delegation Model），确保类的加载具有层次性和安全性。

### 类加载器的运行机制

![类加载器](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/f6783f17-2a8f-45a0-8256-d0c2a143a3ce.png)

#### 1. 程序启动时

当 Java 应用程序启动时，JVM会使用引导类加载器（Bootstrap ClassLoader）加载核心类库（如 `rt.jar` 中的类）。随后，扩展类加载器（Extension ClassLoader）和应用类加载器（Application ClassLoader）会分别加载扩展类库和应用程序类路径上的类。

应用程序类路径上的类指的是由应用程序开发者编写的，并且编译后生成的 `.class` 文件会被放置在类路径指定的目录中。



#### 以下情况的类被加载的前提是类没有被加载



#### 2. 遇到 new 关键字

当程序首次使用 `new` 关键字创建一个类的对象时，如果该类还没有被加载，类加载器会加载该类。

```java
Student student = new Stundet();
```



#### 3. 访问静态资源

当程序首次访问某个类的静态变量或调用其静态方法时，类加载器会加载该类。

```java
String role = UserConstant.ADMIN_ROLE;
```



#### 4. 反射调用

通过Java的反射API访问一个尚未加载的类时，类加载器会加载该类。

```java
Class<?> studentClass = Class.forName("jvm.classLoader.Student");
```

#### 5. 初始化子类

当初始化一个类的子类时，如果父类还没有被加载，类加载器会先加载父类。

```java
public class Student {
    static {
       System.out.println("student 类被初始化");
    }
    public static int age = 20;
}

public class ClassLoaderTest {
	public static void main(String[] args) {
        // 这个过程会加载
		System.out.println(Student.age);
	}
}
```

#### 6. 动态代理

在使用Java的动态代理机制时，代理类会在运行时动态生成并加载。



#### 7. 类加载器的显式调用

在某些情况下，可以通过显式调用类加载器的方法来加载类。例如，自定义类加载器的 `loadClass` 方法



### 注意

- 类加载和类初始化是两个不同的阶段。
  - 类加载只是将类的二进制数据加载到内存中，并生成一个 `Class` 对象。
  - 类初始化则是在类加载之后的一个阶段，执行类的初始化代码，包括**静态初始化块和静态变量的赋值操作**。

- 类加载的字节码文件在 Java 虚拟机（JVM）中被加载到方法区（Method Area），并且生成一个对应的 `Class` 对象。类的元数据信息会一直保留在方法区中，直到满足某些条件才会被垃圾回收器（Garbage Collector, GC）回收。
  - 类的元数据信息在 JVM 中会一直保留，直到满足以下条件之一：
    - 应用程序终止。
    - 类加载器被垃圾回收。
    - 在某些动态类加载和卸载的场景中，类加载器主动卸载类。

- 类的加载是按需加载的，类加载器会在程序真正需要某个类的时候才会去加载这个类。
  - 节省资源
  - 提高启动速度
  - 支持动态加载

- 子类被加载会加载父类（如果有的话），因为子类的初始化依赖于父类的初始化。



类加载器：Java 虚拟机提供给**应用程序**去实现获取**类和接口字节码数据**的**技术**，**类加载器只参与加载过程中的字节码获取并加载到内存这一部分。**（通过二进制的方式获取字节码文件的内容，将数据交给 JVM）

> 类加载器主要负责加载过程中的字节码获取，并将其加载到内存中，而后续的**验证、准备、解析和初始化**等工作则由 JVM 完成。



### 1 类加载器的分类

- 虚拟机底层源码实现（Hotspot【C++实现的】），保证Java程序运行中**基础类**（如 String 类等等）被正确地加载
- JDK 中默认提供或者自定义（所有的使用 Java 实现的类加载器需要继承 ClassLoader 这个抽象类）

**类加载器的涉及 JDK 8 和 8 之后差别较大**

JDK8 及之前的版本中默认的类加载器有如下几种：

在 `rt.jar` 包的 `sun.misc.Launcher` 包中

![JDK8 及之前的类加载器](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/3ef6c8e6-e204-410c-8733-5206d8f1bb43.png)



### 2 启动类加载器

- 启动类加载器（Bootstrap ClassLoader）是由 `Hotspot` 虚拟机提供的、使用 `C++` 编写的类加载器。
- 默认加载 Java 安装目录 `/jre /lib`下的类文件，比如 rt.jar，tools.jar，resources.jar 等。



通过如下代码获取 String 类的类加载器并将其打印下来：

```java
public class BootstrapClassLoaderDemo {
    public static void main(String[] args) throws IOException {
        ClassLoader classLoader = String.class.getClassLoader();
        System.out.println(classLoader); // 输出Null

        System.in.read();
    }
}
```

无法通过  String.class.getClassLoader(); 获取 String 类的类加载器，因为启动类加载器在 JDK8 是通过 C++ 写的，在Java 代码中获取是不安全的，返回的是 null；



#### 用户扩展基础jar包

如果用户想扩展一些比较基础的 jar 包，**让启动类加载器加载**，有两种途径：

- **放入jre/lib下进行扩展**。不推荐，尽可能不要去更改JDK安装目录中的内容，会出现即使放进去由于文件名不匹配的问题也不会正常地被加载。
- **使用参数进行扩展。**推荐，使用 `-Xbootclasspath/a:jar包目录/jar包名` 进行扩展，参数中的/a代表新增。





### 3 扩展类加载器和应用程序类加载器

- 都是 JDK 提供的，使用 Java 语言编写的类加载器，是**静态内部类**，继承自 `URLClassLoader`。具备通过目录或者指定 jar 包**将字节码文件加载到内存**中。

![类加载器的继承关系](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/eea2c3f7-c944-453e-95e7-5b5ce3ab36a7.png)

- `ClassLoader ` 类定义了具体的**行为模式**（简单来说就是先从本地或者网络获得字节码信息，然后调用虚拟机底层的方法**创建方法区和堆上的对象**）。
  - 这样的好处就是让子类只需要去实现如何获取字节码信息这部分代码。

- `SecureClassLoader` 提供了证书机制，提升了安全性。
- `URLClassLoader` 提供了根据 `URL` **获取目录下或者指定 jar 包进行加载，获取字节码的数据。**
- 扩展类加载器和应用程序类加载器继承自 URLClassLoader，获得了上述的三种能力。



#### 3.1 扩展类加载器

扩展类加载器（Extension Class Loader）默认加载 java 安装目录 `/jre/lib/ext` 下的类文件

![jre](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240917122241694.png)



![扩展类加载器加载的 jar 包](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240917122315192.png)

在 `/jre/lib/ext` 下随便找一个类进行测试，打印其的类加载器，可以看到是被扩展类加载器加载的。

![扩展类加载器](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240920172102702.png)

```Java
import com.sun.java.accessibility.AccessBridge;
public class ExtClassLoaderDemo {
	public static void main(String[] args){
		ClassLoader classLoader = AccessBridge.class.getClassLoader();
		System.out.println(classLoader);
	}
}
```

通过扩展类加载器去加载用户jar包：

- **放入/jre/lib/ext下进行扩展**。不推荐，尽可能不要去更改 JDK 安装目录中的内容。
- **使用参数进行扩展使用参数进行扩展**。推荐，使用 `-Djava.ext.dirs="jar包目录"` 进行扩展,这种方式会覆盖掉原始目录，可以用;(windows):(macos/linux)追加上原始目录
  - **使用`引号`将整个地址包裹起来，路径中要包含原来ext文件夹，同时在最后加上扩展的路径，通过分号分割。**




#### 3.2 应用程序 类加载器

应用程序类加载器会加载 `classpath` 下的类文件，默认加载的是 `项目中的类`以及通过 `maven 引入的第三方 jar 包中的类`。

![应用程序类加载器](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240920172657083.png)



### 4 双亲委派机制

>- 自底向上判断是否加载过，是就返回；
>  - 最顶层的**启动类加载器**没有父类
>- 自顶向下判断是否能加载，是就加载。

- 委派请求
- 加载类
- 自加载



双亲委派机制指的是：当一个类加载器接受到加载类的任务的时候，会自底向上查找是否加载过，再由顶向下进行加载。每个类都有一个父类加载器，但是**启动类加载器没有父类加载器**。

![双亲委派机制](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/04513c52-e20b-4b0f-a82e-8084da860eb5.png)

在类加载的过程中，每个类加载器都会先检查是否已经加载了该类，如果已经加载则直接返回，否则会将加载请求委派给父类加载器。



#### 双亲委派机制的作用

1. 保证类加载的安全性。通过双亲委派机制避免恶意代码替换 JDK 中的核心类库，比如 java.lang.String，确保核心类库的完整性和安全性。
2. 避免重复加载。双亲委派机制可以避免同一个类被多次加载。类被加载后会保存在 JVM 的方法区，重复加载没有意义。



**String 类能覆盖吗，在自己的项目中去创建一个java.lang.String类，会被加载吗？**

- 不能，会返回启动类加载器加载在 rt.jar 包中的 String 类。





#### 如何指定加载类的类加载器

- 使用 `Class.forName()` 方法，使用当前类的类加载器去加载指定的类；
- 获取到类加载器，通过类加载器的 loadClass 方法指定某个类加载器加载；

```java
public class ClassLoaderTest {

	public static void main(String[] args) throws ClassNotFoundException, InstantiationException, IllegalAccessException {

		ClassLoader classLoader = ClassLoaderTest.class.getClassLoader();
		System.out.println(classLoader);
		Class<?> aClass = classLoader.loadClass("jvm.Test2");
	}
}
```



#### 打破双亲委派系统

- 自定义类加载器继承 `ClassLoader` 并重写 `loadClass` 方法
- 利用线程上下文类加载器
- 使用 Osgi 等框架的类加载器

自定义类加载器

ClassLoader中包含了4个核心方法，双亲委派机制的核心代码就位于loadClass方法中。

```Java
public Class<?> loadClass(String name)
// 类加载的入口，提供了双亲委派机制。内部会调用findClass   重要

protected Class<?> findClass(String name)
// 由类加载器子类实现,获取二进制数据调用defineClass ，比如URLClassLoader会根据文件路径去获取类文件中的二进制数据。重要

protected final Class<?> defineClass(String name, byte[] b, int off, int len)
// 做一些类名的校验，然后调用虚拟机底层的方法将字节码信息加载到虚拟机内存中

protected final void resolveClass(Class<?> c)
// 执行类生命周期中的连接阶段
```



### JDK 9 之后的类加载器

1.启动类加载器使用 Java 编写，位于 jdk.internal.loader.ClassLoaders 类中。

   Java 中的 BootClassLoader 继承自 BuiltinClassLoader 实现从模块中找到要加载的字节码资源文件。

   启动类加载器依然无法通过 java 代码获取到，返回的仍然是 null ，保持了统一。

2、扩展类加载器被替换成了平台类加载器（Platform Class Loader）。

​     平台类加载器遵循模块化方式加载字节码文件，所以继承关系从 URLClassLoader 变成了 `BuiltinClassLoader`，BuiltinClassLoader 实现了从模块中加载字节码文件。平台类加载器的存在更多的是为了与老版本的设计方案兼容，自身没有特殊的逻辑。