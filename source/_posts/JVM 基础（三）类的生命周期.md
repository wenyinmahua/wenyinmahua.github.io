---
title: JVM 基础（三）类的生命周期
date: 2024-08-26
updated: 2024-08-27
category: JVM
tags:
  - 笔记
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.iK1EFamgj6pjOvuhROEFNAHaEK?w=305&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---



# JVM 基础（三）类的生命周期

类的生命周期描述了一个类**加载、使用、卸载**的整个过程。整体可以分为：

- 加载：类加载器根据类的全限定名（包名+类名）通过不同的渠道以二进制流的方式获取类的字节码信息，将其保存到方法区，在堆上生成 `class` 对象。
- 连接
  - 验证：**是否遵循了《Java 虚拟机规范》中的约束**。
    - 验证文件格式（0xCAFEBABE、主次版本号，编译文件的主版本号不能高于允许环境主版本号，如果相等，比较副版本号）
    - 元信息（父类）
    - 验证程序执行指令含义（是否正确）
    - 符号引用验证（是否访问了其他类的 private 方法）
  - 准备：给静态变量分配内存，**赋默认值**
    - 注意：**final 修饰的基本类型的静态变量**，准备阶段直接将代码中的值进行赋值。
  - 解析：将常量池里面的**符号引用**（使用编号访问常量池的内容）替换为内存的**直接引用**（通过内存地址进行访问具体的数据）
- 初始化：执行字节码文件中 clinit 方法的字节码指令（包含静态代码块中的代码，**并为静态变量赋值**）
- 使用
- 卸载

![类的生命周期](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240830101730751.png)



### 1. 加载阶段

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



### 2. 连接阶段

连接阶段分为三个子阶段:

- 验证，验证内容是否满足《Java虚拟机规范》。
- 准备，给静态（static）变量分配内存并赋初值（注意这里赋值的是默认值）。
  - 注意 final 修饰的基本数据类型的静态变量，准备阶段直接会将代码中的值进行赋值。
- 解析，将常量池中的符号引用替换成指向内存的直接引用。
  - 符号引用就是在字节码文件中使用编号来访问常量池中的内容。
  - 直接引用不在使用编号，而是使用内存中地址进行访问具体的数据。

![连接阶段](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/asynccode)



### 3. 初始化阶段

> 类的初始化是指对类的**静态成员**（静态变量和静态初始化块）进行初始化的过程。
>
> - 类初始化只发生一次，通常在类第一次被使用时进行。
> - 类的初始化 ！= 对象的初始化



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

1. 访问一个类的静态变量或者静态方法，**注意变量是 final 修饰的并且等号右边是常量不会触发初始化**。但是 final 修饰的变量在 static 静态代码块中赋值还是会引起类的初始化的。

   ```java
   public class Student {
   	static {
   		System.out.println("student 类被初始化");
   	}
   	public final static int age = 20;
   }
   ```

   访问 Student.age 不会导致类被初始化，因为这个静态变量被 final 修饰

   ```java
   public class Student {
   	static {
   		age = 10;
   		System.out.println("student 类被初始化");
   	}
   	public final static int age;
   }
   ```

   图上代码中 final 修饰的 age 变量在静态代码块中被赋值，这时会导致类被初始化，具体原因看字节码可以发现，clinit 方法中出现了 给 age 赋值的情况，意味着 age 只有在类被初始化后才进行了赋值。

2. 调用Class.forName(String className)。

3. new 一个该类的对象时。

4. 执行 main 方法的当前类。

添加 `-XX:+TraceClassLoading` 参数可以打印出加载并初始化的类（JDK 17 不支持）

- `-Xlog:class+load=info` JDK 17 支持这个参数

> clinit 不会执行几种情况：
>
> 1. 无静态代码块且无静态变量赋值语句。
> 2. 有静态变量的声明，但是没有赋值语句。
> 3. 静态变量的定义使用 final 关键字，这类变量会在准备阶段直接进行初始化（注意等号右边不是 Integer.valueOf(1) 等等，而是常数 1）。





### 其他注意事项

#### 构造代码块

1. 在类中没与任何的前缀或后缀,并使用"{}"括起来的代码片段称为构造代码块。
2. 每次调用构造函数时，都会先执行构造代码块，然后执行相应构造函数的其他代码。
3. 构造代码块可以提取构造函数的共同量，减少各个构造函数的重复代码。



#### 子类被加载

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





#### 数组的创建不会导致数组中元素的类进行初始化

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

执行上述代码不会输出 "A 被加载"



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
