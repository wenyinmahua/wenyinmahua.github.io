---
title: JVM 基础（一）了解 JVM
date: 2024-08-24
updated: 2024-08-24
category: JVM
tags:
  - 笔记
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.iK1EFamgj6pjOvuhROEFNAHaEK?w=305&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---





# JVM 基础（一）了解 JVM

对源代码进行编译（javac）之后拿到的是字节码（字节码是一种中间代码，而且还算是能读吧，可读性较差一点），字节码不是机器语言（即不能被机器识别，被机器直接允许），想要其被机器识别就要将其解释成能被机器识别的代码（如机器码等），怎么实现这一步呢？交给 JVM 来实现吧！不同的操作系统（Windows、Mac、Linux）有配上了不同的 JVM，这样使同一份字节码文件能被不同平台的 JVM 解释，这下跨平台实现啦！



**JVM** 全称是 Java Virtual Machine，中文译名 Java虚拟机。JVM 本质上是一个运行在计算机上的程序，他的职责是**运行 Java 字节码文件**。

使用 Java 虚拟机加载并运行 Java 字节码文件，此时会启动一个新的进程。

**Java 性能低的主要原因：**JVM 需要将字节码指令实时地解释成计算机能够识别地机器码，这个过程在运行时可能会反复执行。

**Java 跨平台：**Java 的字节码指令能够在不同的平台上运行是因为 JVM 的存在。同一份字节码指令运行在不同平台的 JVM 上可以解释成不同的机器码。



字节码文件：使用 `javac` 命令编译 **Java 源代码文件**后生成的文件，里面包含**字节码指令**，通过 **JVM** 解释后（机器码），可以被计算机直接执行。



## 1. JVM 详解

### 1. JVM 的功能

- 解释和运行：将字节码文件中的字节码指令实时地解释成机器码，使计算机可以运行。
- 内存管理：
  - 自动为对象、方法分配内存
  - 自动的而垃圾回收机制，回收不再使用的对象
- 即时编译：对热点代码（被非常高频调用）进行优化，提升效率。（即时编译器会优化这段代码并将优化后的机器码保存在内存中，这样在第二次执行这段代码时，直接在内存中取出来直接进行调用。可以节省解释的步骤，同时执行的时优化后的代码，效率较高，性能geng）

### 2. JVM 的组成

![JVM 的组成](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/899262d1-c730-4fd1-ab34-f95bf0500b99.png)

- 类加载子系统：核心组件类加载器，负责将字节码文件中的内容加载到内存中
- 运行时数据区：JVM 管理的内存，创建出的对象，类的信息等等内容都会放在这块区域中
- 执行引擎：包含了**即时编译器**、**解释器**、**垃圾回收器**，执行引擎功能如下：
  - 使用解释器将字节码指令解释成机器码，
  - 使用即时编译器优化性能，
  - 使用垃圾回收器回收不再使用的对象
- 本地接口：调用本地使用 C/C++ 编译好的方法，本地方法在 Java中声明时，都会加上 `native` 关键字。



### 3. 常见 JVM

平时最常用的是 Hotspot 虚拟机

| 名称                       | 作者    | 支持版本                  | 社区活跃度（github star） | 特性                                                         | 适用场景                             |
| -------------------------- | ------- | ------------------------- | ------------------------- | ------------------------------------------------------------ | ------------------------------------ |
| HotSpot (Oracle JDK版)     | Oracle  | 所有版本                  | 高(闭源)                  | 使用最广泛，稳定可靠，社区活跃JIT支持Oracle JDK默认虚拟机    | 默认                                 |
| HotSpot (Open JDK版)       | Oracle  | 所有版本                  | 中(16.1k)                 | 同上开源，Open JDK默认虚拟机                                 | 默认对JDK有二次开发需求              |
| GraalVM                    | Oracle  | 11, 17,19企业版支持8      | 高（18.7k）               | 多语言支持高性能、JIT、AOT支持                               | 微服务、云原生架构需要多语言混合编程 |
| Dragonwell JDK龙井         | Alibaba | 标准版 8,11,17扩展版11,17 | 低(3.9k)                  | 基于OpenJDK的增强高性能、bug修复、安全性提升JWarmup、ElasticHeap、Wisp特性支持 | 电商、物流、金融领域对性能要求比较高 |
| Eclipse OpenJ9 (原 IBM J9) | IBM     | 8,11,17,19,20             | 低(3.1k)                  | 高性能、可扩展JIT、AOT特性支持                               | 微服务、云原生架构                   |



## 2. 字节码文件详解

### 1. 字节码文件的组成

字节码文件中保存了源代码编译后的内容，以二进制的方式存储，推荐通过 `jclasslib` 工具查看字节码文件。

Github地址： https://github.com/ingokegel/jclasslib

字节码文件总共可以分为以下几部分：

- **基础信息：**魔数、字节码文件对应的 Java 版本号、访问标识符、父类和接口等信息。
- **常量池：**保存了字符串常量、类或接口名、字段名，主要在**字节码指令**中使用。
- **字段：**当前类或接口声明的字段信息
- **方法：**当前类或接口声明的方法信息，核心内容为方法的字节码指令
- **属性：**类的属性，比如源码的文件名、内部类列表。

#### 1.1 基本信息

###### Magic 魔数

每个 Java 字节码文件的前四个字节是固定的，用 16 进制表示就是 `0xcafebabe`。文件是无法通过文件扩展名来确定文件类型的，文件扩展名可以随意修改不影响文件的内容。软件会使用文件的头几个字节（文件头）去校验文件的类型，如果软件不支持该种类型就会出错。

Java 字节码文件中，将文件头称为 **magic 魔数**。Java 虚拟机会校验字节码文件的前四个字节是不是 0xcafebabe，如果不是，该字节码文件就无法正常使用，Java 虚拟机会抛出对应的错误。



##### 主副版本号

主副版本号指的是 编译字节码文件使用的 JDK 版本号，

主版本号 = JDK 版本号 + 44，如主版本号为52，52-44=8，JDK 的版本是8

版本号的作用主要是判断当前的字节码的版本和运行时的 JDK 是否兼容。不允许用较低版本的 JDK  去运行较高版本的 JDK 的字节码文件。

出现这种异常，解决方案有两种：

- 升级 JDK 版本（不推荐）
- 降低第三方依赖的版本号或更换依赖（推荐）

p;lj,

#### 1.2 常量池

字节码文件中的常量池的作用：避免相同的内容重复定义，节省空间。

> 常量池的数据都有一个编号，类似于 key -value 可以通过编号找到常量池中的数据。

符号引用：字节码指令中通过**编号**引用到**常量池**的过程



#### 1.3 字段

字段中存放的是当前类或接口声明的字段信息。

包含字段的名字、描述符（字段的类型）、访问呢标识符（public/private static final）



#### 1.4 方法

字节码的**方法区域**是存放**字节码指令**的核心位置，字节码指令的内容存放在方法的 Code 属性中。需要了解字节码指令的含义。



#### 1.5 属性

注销主要是指类的属性、内部类的列表等



#### 字节码指令

**操作数栈**是用来存放临时数据的内容，是一个栈式的结构，先进后出。

**局部变量表**是存放方法中的局部变量，包含方法的参数、方法中定义的局部变量，在编译期就已经可以确定方法有多少个局部变量。

- 局部变量表都是 从 1 开始的；

> 变量的定义： int i = 5;
>
> - 默认 i 在局部变量表中的索引为 1； 
>
> 1. 常量先入操作数栈 iconst_5
> 2. 弹出操作数栈顶的整数，存储在局部变量表的指定位置；（根据索引存储） istore 1
>
> 

```java
int i = 0;
i = i++;
// 结果是 0
```

字节码：

```
iconst_0 : 将常量 0 放入操作数栈中，下划线后面的数字表示要存入操作数栈的数字
istore1 : 从操作数栈中取出放入局部变量表 1 号位置（弹出操作数栈顶的元素，赋值给局部变量表的 1 号位置的变量）
innc 1 by 1 : 将局部变量表 1 号位置的变量的值 增加 1
iload 1 : 将局部变量表 1 号位置的数据加载到操作数栈中
istore 1 : 将操作数栈中的值保存到局部变量表 1 号位置
return : 方法结束返回
```



![i= ++i](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240915133129003.png)

i = i++:将 i 的值放入操作数栈中，对局部变量表中的 i 进行自增；将操作数栈栈顶的数字存储到局部变量表中

i = ++ i; 将 局部变量表中 i 进行自增操作，局部变量表 i 的值加载到操作数栈中，

#### 其他字节码指令

| 指令      | 解释                                           |
| --------- | ---------------------------------------------- |
| putstatic | 将操作数栈上的数弹出来，放入堆中静态变狼的位置 |





### 2. 字节码的常用工具

#### 2.1. javap

javap 是 JDK 自带的反编译工具，可以通过控制台查看字节码文件的内容。

输入`javap -v` 字节码文件名称 查看具体的字节码信息。

如果jar包需要先使用 `jar –xvf` 命令解压。



#### 2.2. jclasslib 插件

使用 IDEA 安装 jclasslib 插件，可以在代码编译之后实时看到字节码文件内容

选中要查看的源代码文件，选择 `视图(View) - Show Bytecode `

> tips:
>
> 1、一定要选择文件再点击视图(view)菜单，否则菜单项不会出现。
>
> 2、文件修改后一定要重新编译之后，再点击刷新按钮。



#### 2.3 Arthas 

Arthas 是一款线上监控诊断产品，通过全局视角实时查看应用 load、内存、gc、线程的状态信息，并能在不修改应用代码的情况下，对业务问题进行诊断，大大提升线上问题排查效率。 官网：https://arthas.aliyun.com/doc/



**安装方法：**

1、将 arthas-boot.jar 文件复制到任意工作目录。

2、使用`java -jar arthas-boot.jar ` 启动程序。

3、输入需要 Arthas 监控的进程 id。

4、输入命令即可使用。



**dump**

命令详解：https://arthas.aliyun.com/doc/dump.html

dump 命令可以将字节码文件保存到本地



**jad**

命令详解：https://arthas.aliyun.com/doc/jad.html

jad命令可以将类的字节码文件进行反编译成源代码，用于确认服务器上的字节码文件是否是最新的。



### 3. 类的生命周期

类的生命周期描述了一个类**加载、使用、卸载**的整个过程。整体可以分为：

- 加载：类加载器根据类的额全限定名通过不同的渠道以二进制流的方式获取类的字节码信息，将其保存到方法区，在堆上生成对象。
- 连接
  - 验证：是否遵循了《Java 虚拟机规范》中的约束。
    - 验证文件格式（0xCAFEBABE、主次版本号，编译文件的主版本号不能高于允许环境主版本号，如果相等，比较副版本号）
    - 元信息（父类）
    - 验证程序执行指令含义（是否正确）
    - 符号引用验证（是否访问了其他类的 private 方法）
  - 准备：给静态变量分配内存，赋默认值
    - 注意：**final 修饰的基本类型的静态变量**，准备阶段直接将代码中的值进行复制。
  - 解析：将常量池里面的符号引用（使用编号访问常量池的内容）替换为内存的直接引用（通过内存地址进行访问具体的数据）
- 初始化：执行字节码文件中 clinit 方法的字节码指令（包含静态代码块中的代码，并为静态变量赋值）
- 使用
- 卸载

![类的生命周期](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240830101730751.png)

#### 3.1 加载阶段

- 获取字节码信息，将类的信息保存到方法区，
- 在方法区生成一个 **InstanceKlass** 对象，保存类的全部信息，
- JVM 在堆上生成与方法区中数据类似的 java.lang.Class 对象

1、加载(Loading)阶段第一步是类加载器根据**类的全限定名（包名+类名）**通过不同的渠道以**二进制流**的方式获取**字节码信息**，程序员可以使用 Java 代码拓展的不同的渠道。

- 从本地磁盘上获取文件
- 运行时通过动态代理生成，比如 Spring 框架
- Applet 技术通过网络获取字节码文件

2、类加载器在加载完类之后，**Java 虚拟机**会将字节码中的信息保存到**方法区**中，方法区中生成一个 **InstanceKlass** 对象，保存类的所有信息，里边还包含实现特定功能比如**多态**的信息。

![方法区内容](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/e9b50cae-733a-42d5-8098-fc284908e4ea.png)



3、Java 虚拟机同时会在堆上生成与方法区中数据类似的 **java.lang.Class** 对象，

- 作用是在 Java 代码中去获取类的信息以及存储静态字段的数据（JDK8及之后）。

![堆区](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/e4f5a13a-1674-4a4c-bfd2-a3d790b5920d.png)



#### 3.2 连接阶段

连接阶段分为三个子阶段:

- 验证，验证内容是否满足《Java虚拟机规范》。
- 准备，给静态（static）变量分配内存并赋初值（注意这里赋值的是默认值）。
  - 注意 final 修饰的基本数据类型的静态变量，准备阶段直接会将代码中的值进行赋值。
- 解析，将常量池中的符号引用替换成指向内存的直接引用。
  - 符号引用就是在字节码文件中使用编号来访问常量池中的内容。
  - 直接引用不在使用编号，而是使用内存中地址进行访问具体的数据。

![连接阶段](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/asynccode)



#### 3.3 初始化阶段

> 代码编译成字节码文件之后，会生成三个方法：
>
> - init 方法，会在对象初始化时执行（构造方法）
> - main 方法，主方法（没有 mian 方法，你代码都跑不了，怎么来的字节码文件？所有肯定有个 main 方法）
> - clinit 方法，类的初始化阶段执行（为类的静态变量赋值 [**注意使用 final 修饰的静态变量不会在这里赋值**]，如果没有静态变量以及赋值，就没有 clinit 方法）
>   - 如果所有的静态变量被 final 修饰，且赋值，等号右边是常数而不是方法（Integer.valueOf(1)需要执行指令），就不会执行 clinit 方法
>
> 在执行 main 方法之前会执行 clinit 指令

初始化阶段会执行字节码文件中 clinit（class init 类的初始化）方法的字节码指令，包含了静态代码块中的代码，并为静态变量赋值。



以下几种方式会导致类的初始化：

1. 访问一个类的静态变量或者静态方法，注意变量是 final 修饰的并且等号右边是常量不会触发初始化。

2. 调用Class.forName(String className)。

3. new一个该类的对象时。

4. 执行Main方法的当前类。

添加-XX:+TraceClassLoading 参数可以打印出加载并初始化的类

> clinit 不会执行的集中情况：
>
> 1. 无静态代码块且无静态变量赋值语句。
> 2. 有静态变量的声明，但是没有赋值语句。
> 3. 静态变量的定义使用 final 关键字，这类变量会在准备阶段直接进行初始化（注意等号右边不是 Integer.valueOf(1)，而是常数 1）。

数组的创建不会导致数组中元素的类进行初始化。

final 修饰的变量如果赋值的内容需要执行指令才能得出结果，会执行clinit 方法进行初始化。



#### 其他注意事项

##### 构造代码块

1. 在类中没与任何的前缀或后缀,并使用"{}"括起来的代码片段称为构造代码块。
2. 每次调用构造函数时，都会先执行构造代码块，然后执行相应构造函数的其他代码。
3. 构造代码块可以提取构造函数的共同量，减少各个构造函数的重复代码。

##### 子类被加载

子类被加载时先加载父类

```java
public class ClassTest {
	public static void main(String[] args) throws InterruptedException {
		System.out.println(B.a); // 1 先加载父类，加载父类读到这个静态变量时就停止加载了，解决方案是提前加载子类便可：new B();
		System.out.println(B.b); // 3 先加载父类，父类中没有静态变量 b，然后加载子类，读取子类静态变量
		System.out.println(B.a); // 2 由于上方子类已经被加载这里读到的是子类覆盖过后的值 2 
	}
}

class A{
	static int a = 0;
	static {
		a = 1;
		System.out.println("father class is loading");
	}
}

class B extends A{
	static int b = 3;
	static {
		a = 2;
		System.out.println("son class is loading");
	}
}
```

##### 数组的创建不会导致数组中元素的类进行初始化

```java
public class Test{
    public void main(String [] args){
        A[] a = new A[2];
    }
}
class A{
    static{
        System.out.println("A 被加载");
    }
}
```





### 字节码分析了解类的生命周期

```java
package jvm;

public class ClassTest {
	private static int a = 1;
	private static final int  b = 10;
	public static void main(String[] args) {
		int c = 1;
	}
}
```

其字节码如下：

```java
// class version 55.0 (55)
// access flags 0x21
public class jvm/ClassTest {

  // compiled from: ClassTest.java

  // access flags 0xA
  // 没有使用 final 修饰的静态变量
  private static I a

  // access flags 0x1A
  // 使用 final 修饰的静态变量直接赋值，而没有使用 final 修饰的静态变量（a）在下面的 clinit 方法中赋值（先是赋默认值） 
  private final static I b = 10

  // access flags 0x1
  // init 方法
  public <init>()V
   L0
    LINENUMBER 3 L0
    ALOAD 0
    INVOKESPECIAL java/lang/Object.<init> ()V
    RETURN
   L1
    LOCALVARIABLE this Ljvm/ClassTest; L0 L1 0
    MAXSTACK = 1
    MAXLOCALS = 1

  // access flags 0x9
  public static main([Ljava/lang/String;)V
   L0
    LINENUMBER 7 L0
    ICONST_1
    ISTORE 1
   L1
    LINENUMBER 8 L1
    RETURN
   L2
    LOCALVARIABLE args [Ljava/lang/String; L0 L2 0
    LOCALVARIABLE c I L1 L2 1
    MAXSTACK = 1
    MAXLOCALS = 2

  // access flags 0x8
  // clinit 方法，负责静态变量 a 的初始化
  static <clinit>()V
   L0
    LINENUMBER 4 L0
    ICONST_1
    PUTSTATIC jvm/ClassTest.a : I
    RETURN
    MAXSTACK = 1
    MAXLOCALS = 0
}

```

关于 final 修饰的静态变量 在 static 静态代码块中进行赋值时

```java
public class ClassTest {
	private static final int  b;
	static {
		b = 2;
	}
	public static void main(String[] args) {}
}
```

其字节码如下：（省略 init 和main 方法）

```java
public class jvm/ClassTest {
  private final static I b
  // 可以看到 final 修饰的变量 b 在这里通过 clinit 方法进行初始化
  static <clinit>()V
   L0
    LINENUMBER 6 L0
    ICONST_2
    PUTSTATIC jvm/ClassTest.b : I
   L1
    LINENUMBER 7 L1
    RETURN
    MAXSTACK = 1
    MAXLOCALS = 0
}
```



## 3.类加载器

- JVM 本来就是运行在计算机上的程序。
- 类加载 并不意味着 类被初始化。

类加载器：Java 虚拟机提供给**应用程序**去实现获取**类和接口字节码数据**的**技术**，**类加载器只参与加载过程中的字节码获取并加载到内存这一部分。**（通过二进制的方式获取字节码文件的内容，将数据交给 JVM）

### 3.1 类加载器的分类

- 虚拟机底层源码实现（Hotspot【C++】）
- JDK 中默认提供或者自定义（所有的使用 Java 实现的类加载器需要继承 ClassLoader 这个抽象类）

类加载器的涉及 JDK 8 和 8 之后差别较大

JDK8 及之前的版本中默认的类加载器有如下几种：

在 `rt.jar` 包的 `sun.misc.Launcher` 包中

![JDK8 及之前的类加载器](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/3ef6c8e6-e204-410c-8733-5206d8f1bb43.png)



### 3.2 启动类加载器

- 启动类加载器（Bootstrap ClassLoader）是由 `Hotspot` 虚拟机提供的、使用 `C++` 编写的类加载器。
- 默认加载 Java 安装目录 `/jre /lib`下的类文件，比如 rt.jar，tools.jar，resources.jar 等。



通过如下代码获取 String 类的累加器并将其打印下来：

```java
public class BootstrapClassLoaderDemo {
    public static void main(String[] args) throws IOException {
        ClassLoader classLoader = String.class.getClassLoader();
        System.out.println(classLoader); // 输出Null

        System.in.read();
    }
}
```

无法通过  String.class.getClassLoader(); 获取 String 类的类加载器，因为启动类加载器再 JDK8 是通过 C++ 写的，在Java 代码中获取是不安全的，返回的是 null；



#### 用户扩展基础jar包

如果用户想扩展一些比较基础的jar包，让启动类加载器加载，有两种途径：

- **放入jre/lib下进行扩展**。不推荐，尽可能不要去更改JDK安装目录中的内容，会出现即时放进去由于文件名不匹配的问题也不会正常地被加载。
- **使用参数进行扩展。**推荐，使用 `-Xbootclasspath/a:jar包目录/jar包名` 进行扩展，参数中的/a代表新增。





### 3.3 扩展类加载器和应用程序类加载器

- 都是 JDK 提供的，使用 Java 语言编写的类加载器，是**静态内部类**，继承自 `URLClassLoader`。具备通过目录或者指定 jar 包**将字节码文件加载到内存**中。

![类加载器的继承关系](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/eea2c3f7-c944-453e-95e7-5b5ce3ab36a7.png)

- `ClassLoader ` 类定义了具体的**行为模式**，简单来说就是先从本地或者网络获得字节码信息，然后调用虚拟机底层的方法**创建方法区和堆上的对象**。这样的好处就是让子类只需要去实现如何获取字节码信息这部分代码。
- `SecureClassLoader` 提供了证书机制，提升了安全性。
- `URLClassLoader` 提供了根据 `URL` **获取目录下或者指定 jar 包进行加载，获取字节码的数据。**
- 扩展类加载器和应用程序类加载器继承自 URLClassLoader，获得了上述的三种能力。



#### 3.3.1 扩展类加载器

扩展类加载器（Extension Class Loader）默认加载 java 安装目录 `/jre/lib/ext` 下的类文件

![jre](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240917122241694.png)



![扩展类加载器加载的 jar 包](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240917122315192.png)



通过扩展类加载器去加载用户jar包：

- **放入/jre/lib/ext下进行扩展**。不推荐，尽可能不要去更改 JDK 安装目录中的内容。
- **使用参数进行扩展使用参数进行扩展**。推荐，使用 `-Djava.ext.dirs="jar包目录"` 进行扩展,这种方式会覆盖掉原始目录，可以用;(windows):(macos/linux)追加上原始目录



#### 3.3.2 应用程序 类加载器

应用程序类加载器会加载 `classpath` 下的类文件，默认加载的是 `项目中的类`以及通过 `maven 引入的第三方 jar 包中的类`。



### 3.4 双亲委派机制

- 自底向上判断是否加载过，是就返回；
- 自顶向下判断是否能加载，是就加载。

双亲委派机制指的是：当一个类加载器接受到加载类的任务的时候，会自底向上查找是否加载过，再由顶向下进行加载。每个类都有一个父类加载器，但是**启动类加载器没有父类加载器**。

![双亲委派机制](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/04513c52-e20b-4b0f-a82e-8084da860eb5.png)

在类加载的过程中，每个类加载器都会先检查是否已经加载了该类，如果已经加载则直接返回，否则会将加载请求委派给父类加载器。



#### 双亲委派机制的作用

1.保证类加载的安全性。通过双亲委派机制避免恶意代码替换 JDK 中的核心类库，比如 java.lang.String，确保核心类库的完整性和安全性。

2.避免重复加载。双亲委派机制可以避免同一个类被多次加载。





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



String类能覆盖吗，在自己的项目中去创建一个java.lang.String类，会被加载吗？

- 不能，会返回启动类加载器加载在 rt.jar 包中的 String 类。



#### 打破双亲委派系统

- 自定义类加载器继承 ClassLoader 并重写 loadClass 方法
- 利用线程上下文类加载器
- 使用 Osgi 等框架的类加载器





### JDK 9 之后的类加载器

1.启动类加载器使用 Java 编写，位于 jdk.internal.loader.ClassLoaders 类中。

   Java 中的 BootClassLoader 继承自 BuiltinClassLoader 实现从模块中找到要加载的字节码资源文件。

   启动类加载器依然无法通过 java 代码获取到，返回的仍然是 null ，保持了统一。

2、扩展类加载器被替换成了平台类加载器（Platform Class Loader）。

​     平台类加载器遵循模块化方式加载字节码文件，所以继承关系从 URLClassLoader 变成了 `BuiltinClassLoader`，BuiltinClassLoader 实现了从模块中加载字节码文件。平台类加载器的存在更多的是为了与老版本的设计方案兼容，自身没有特殊的逻辑。





## 4.运行时数据区

Java 虚拟机在运行 Java 程序过程中**管理的内存区域**，称之为运行时数据区。

![运行时数据区](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/output.png)



### 4.1 程序计数器

程序计数器（Program Counter Register）PC寄存器

- 每个线程会通过程序计数器来记录**当前要执行（即下一行）的字节码指令的偏移量地址**。（在 JVM 中，字节码文件中的指令并不会直接以偏移量的形式转换为内存地址）
-  程序计数器存储的是一个指向当前线程将要执行的下一行字节码指令的索引。

程序计数器可以控制程序指令的进行，实现分支、跳转、异常等逻辑。不管是分支、跳转、异常，只需要在程序计数器中放入下一行要执行的指令地址即可。

在多线程执行情况下，Java 虚拟机需要通过程序计数器记录 CPU 切换前解释执行到那一句指令并继续解释运行。



### 4.2 Java虚拟机栈

Java虚拟机栈（Java Virtual Machine Stack）采用栈的数据结构来管理**方法调用中的基本数据**，先进后出（First In Last Out）,每一个方法的调用使用一个栈帧（Stack Frame）来保存。

Java虚拟机栈随着线程的创建而创建，而回收则会在线程的销毁时进行。由于方法可能会在不同线程中执行，每个线程都会包含一个自己的虚拟机栈。

Java 虚拟机栈的栈帧中主要包含三方面的内容：

- **局部变量表**：局部变量表的作用是在运行过程中存放所有的局部变量
- **操作数栈**：操作数栈是栈帧中虚拟机在执行指令过程中用来存放临时数据的一块区域
- **帧数据**：帧数据主要包含动态链接、方法出口、异常表的引用



#### 局部变量表

局部变量表的作用是在方法执行过程中存放所有的局部变量。局部变量表分为两种：

- 字节码文件中的
  - 编译成字节码文件时就可以确定局部变量表的内容。
  - 在局部变量表中，变量下标从 0 开始
- 栈帧中的，也就是保存在内存中
  - 栈帧中的局部变量表是根据字节码文件中的内容生成的。
  - 栈帧中的局部变量表是一个`数组`，数组长度在编译期间就确定了，数组中每一个位置称之为槽(slot) ，long 和 double 类型占用两个槽，其他类型占用一个槽。

> - 静态方法中的序号为 0 的位置存放的就是该方法中的变量；
> - 实例方法中的序号为0的位置存放的是 `this`，指的是当前调用方法的对象，运行时会在内存中存放实例对象的地址。
> - 方法参数也会保存在局部变量表中，其顺序与方法中参数定义的顺序一致。局部变量表保存的内容有：实例方法的`this`对象，方法的参数，方法体中声明的局部变量。



#### 操作数栈

操作数栈是栈帧中虚拟机在执行指令过程中用来存放中间数据的一块区域。他是一种栈式的数据结构，如果一条指令将一个值压入操作数栈，则后面的指令可以弹出并使用该值。

在编译期就可以确定操作数栈的最大深度，从而在执行时正确的分配内存大小。



#### 帧数据

帧数据主要包含动态链接、方法出口、异常表的引用。

##### 动态链接

当前类的字节码指令引用了其他类的属性或者方法时，需要将符号引用（编号）转换成对应的运行时常量池中的内存地址。

- 动态链接就保存了编号到运行时常量池的内存地址的映射关系。

##### 方法出口

方法出口指的是方法在**正确或者异常结束**时，当前栈帧会被弹出，同时**程序计数器应该指向上一个栈帧中的下一条指令的地址。**

##### 异常表

异常表存放的是代码中异常的处理信息，包含了异常捕获的生效范围以及异常发生后跳转到的字节码指令位置。



#### 栈内存溢出

Java虚拟机栈如果栈帧过多，占用内存超过栈内存可以分配的最大大小就会出现内存溢出。Java 虚拟机栈内存溢出时会出现 `StackOverflowError` 的错误。

如果不指定栈的大小，JVM 将创建一个具有默认大小的栈。大小取决于操作系统和计算机的体系结构。

要修改 Java 虚拟机栈的大小，可以使用虚拟机参数 `-Xss` 。

- 语法：-Xss栈大小
- 单位：字节（默认，必须是 1024 的倍数）、k或者K(KB)、m或者M(MB)、g或者G(GB)

```Java
-Xss1048576 
-Xss1024K      
-Xss1m
-Xss1g
```

> IDEA版本的设置方式：
>
> 1、点击修改配置Modify options
>
> 2、点击Add VM options
>
> 3、添加参数

**注意事项：**

1. 与-Xss类似，也可以使用 -XX:ThreadStackSize 调整标志来配置堆栈大小。

格式为： `-XX:ThreadStackSize=1024`

2. HotSpot JVM对栈大小的最大值和最小值有要求：

   比如测试如下两个参数，会直接报错:

```
-Xss1k
-Xss1025m
```

Windows（64位）下的JDK8测试最小值为`180k`，最大值为`1024m`。

3. 局部变量过多、操作数栈深度过大也会影响栈内存的大小。

> 一般情况下，工作中即便使用了递归进行操作，栈的深度最多也只能到几百,不会出现栈的溢出。所以此参数可以手动指定为-Xss256k节省内存。



### 4.3 本地方法栈

- Java 虚拟机栈存储了 `Java` 方法调用时的栈帧，
- 本地方法栈存储的是 `native` 本地方法的栈帧。

在 Hotspot 虚拟机中，**Java 虚拟机栈和本地方法栈实现上使用了同一个栈空间。** 本地方法栈会在栈内存上生成一个栈帧，临时保存方法的参数同时方便出现异常时也把本地方法的栈信息打印出来。

![栈空间的使用](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/6fe9420a-b06d-40d8-b8ec-5504d247b301.png)



### 4.4 堆内存

> - 一般 Java 程序中**堆内存是空间最大的一块内存区域**。
> - **创建出来的对象都存在于堆上。**
> - 栈上的局部变量表中，可以**存放堆上对象的引用**。
> - 静态变量也可以存放堆对象的引用，通过静态变量就可以实现对象在线程之间共享。
> - 堆内存大小是有上限的，当对象一直向堆中放入对象达到上限之后，就会抛出 `OutOfMemory` 错误。

通过`new`关键字创建了两个`Student`类的对象，这两个对象会被存放在堆上。在栈上通过`s1`和`s2`两个局部变量保存堆上两个对象的地址，从而实现了引用关系的建立。

![堆内存](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/c5cf0920-fda7-4045-b013-956ad32eb93b.png)



#### 堆内存的三个重要的值

堆空间有三个需要关注的值: used、total、max。

- used 指的是当前已使用的堆内存，
- total 是 java 虚拟机已经分配的可用堆内存，
- max 是 java 虚拟机可以分配的最大堆内存。

堆内存used total max三个值可以通过`arthas` 的 `dashboard` 命令看到。

> 手动指定刷新频率（不指定默认5秒一次）：`dashboard –i  刷新频率(毫秒)`

1. 随着堆中的对象增多，当 total 可以使用的内存即将不足时，java 虚拟机会继续分配内存给堆。
2. 此时 used 达到了 total 的大小，Java 虚拟机会向操作系统申请更大的内存。
3. 但是这个申请过程不是无限的，total 最多只能与 max 相等。

> 如果不设置任何的虚拟机参数，max 默认是系统内存的 `1/4`，total 默认是系统内存的 `1/64`。在实际应用中一般都需要设置 total 和 max 的值。



#### 设置堆的大小

要修改**堆的大小**，可以使用虚拟机参数 `–Xmx（max最大值）`和 `-Xms (初始的 total)`。

语法：`-Xmx值 -Xms值`

单位：字节（默认，必须是 1024 的倍数）、k或者K(KB)、m或者M(MB)、g或者G(GB)

限制：Xmx必须大于 2 MB，Xms必须大于1MB

```Java
-Xms6291456
-Xms6144k
-Xms6m
-Xmx83886080
-Xmx81920k
-Xmx80m
```

查看堆的大小需要使用`arthas`的`memory`命令

> **建议：**
>
> Java 服务端程序开发时，建议将 -Xmx 和 -Xms 设置为相同的值，这样在程序启动之后可使用的总内存就是最大内存，而无需向 java 虚拟机再次申请，减少了申请并分配内存时间上的开销，同时也不会出现内存过剩之后堆收缩的情况



### 4.5 方法区

方法区是存放**基础信息**的位置，**线程共享**，主要包含三部分内容：

- **类的元信息**，保存了所有类的基本信息
- **运行时常量池**，保存了字节码文件中的常量池内容
- **字符串常量池**，保存了字符串常量



#### 方法区的实现

每款 Java 虚拟机在实现上都各不相同，Hotspot 设计如下：

JDK7 及之前的版本将方法区存放在**堆区域**中的永久代空间，堆的大小由虚拟机参数来控制。`-XX:MaxPermSize=值来控制`

- 永久代（Permanent Generation，PermGen）是Java虚拟机（JVM）中一个特定的内存区域，它主要用于存储类的信息、常量池、字段和方法数据（方法区）等。

JDK8 及之后的版本将方法区存放在**元空间（Metaspace）**中，元空间位于**操作系统维护的直接内存**中，默认情况下只要不超过操作系统承受的上限，可以一直分配。可以使用d `-XX:MaxMetaspaceSize=值将元空间最大大小` 进行限制。

![方法区的实现](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/74768bd5-d1a9-4fce-9488-1fb2c4cc7b51.png)

如果大量字节码数据加载到方法区中，方法区会有**内存溢出**的情况。



#### 类的元信息

方法区是用来存储每个类的**基本信息**（元信息），一般称之为 `InstanceKlass` 对象。其中就包含了类的**字段**、**方法**等字节码文件中的内容，同时还保存了运行过程中需要使用的**虚方法表**（实现多态的基础）等信息。

![类的元信息](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/efreferg1233242ef.png)

#### 运行时常量池

常量池中存放的是**字节码中的常量池内容**。

- 字节码文件中通过**编号**查表的方式找到**常量**，这种常量池称为**静态常量池**。
- 当常量池加载到内存中之后，可以通过**内存地址**快速的定位到常量池中的内容，这种常量池称为**运行时常量池**。





#### 字符串常量池（StringTable）

字符串常量池存储的是**代码中定义的常量字符串内容**。

早期设计时，字符串常量池是属于运行时常量池的一部分，他们存储的位置也是一致的。后续做出了调整，将字符串常量池和运行时常量池做了拆分。

![字符串常量池](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/c298a4d4-e2f7-40bf-a5a3-ed33ddfcb464.png)



#### String的 intern

`String.intern()` 方法是可以手动将字符串放入字符串常量池中。（对象拿到的是字符串常量池中的引用）

```java
public class InternTest {
    public static void main(String[] args) {
       String s1 = "1";
       String s2 = "2";
       String s3 = "12";
       String s4 = s1 + s2;
       String s5 = "1"+"2";
       System.out.println(s3 == s4); // false 因为s3 直接指向了字符串常量池中的引用，而 s4 指向的是堆上的对象（这个过程中涉及了 StringBuilder 的 append 方法和 toString 方法，而 StringBuilder 对象的 toString 方法是返回一个 String 对象，即堆上的对象）
       System.out.println(s4.intern() == s3); // true s4 通过 intern 指向了常量池中的引用，s3 也是
       System.out.println(s4.intern() == s4); // false 一个是字符串常量池的引用，一个是堆上对象的引用
       System.out.println(s5 == s3); // true 两个都是字符串常量池的引用
    }
}
```



####  面试题：静态变量存储在哪里呢？

- JDK6及之前的版本中，静态变量是存放在方法区中的，也就是永久代。
- JDK7及之后的版本中，静态变量是存放在堆中的Class对象中，脱离了永久代。



### 4.6 直接内存

> 直接内存不属于 Java 运行时的内存区域

在 Java 中，将文件读取到直接内存中，同时 Java 堆上维护直接内存的引用，减少之前需要赋值直接内存中的文件的开销。

![直接内存的使用](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/c4664b79-32b7-471b-85db-82287a10496c.png)

#### 使用方法

要创建直接内存上的数据，可以使用 `ByteBuffer`

```java
ByteBuffer directBuffer = ByteBuffer.allocateDirect(size); // 会创建一个 size 大小的直接内存
```

如果服务器上部署了其他应用，为了避免将内存耗尽，需要设置直接内存的最大值。如果需要手动调整直接内存的大小，可以使用`XX:MaxDirectMemorySize=大小`

单位k或K表示千字节，m或M表示兆字节，g或G表示千兆字节。默认不设置该参数情况下，JVM 自动选择 最大分配的大小。







