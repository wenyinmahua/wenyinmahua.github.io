---
title: Java I/O 流
date: 2023-06-28
comments: true
category: Java
tags:
  - 基础
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C._Lm_T3scKhVEVFC54gcRxwHaE8?w=249&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---



# Java I/O 流

>  总结:
>
>  - 输入输出、读写的参照物是程序：
>   - InputStream、Reader：都是程序将文件中的数据读取到内存中；
>     - （Buffered）+ FileInputStream、FileReader
>   - OutputStream、Writer：都是程序将内存中的数据写到文件中；
>     - （Buffered）+ FileOutputStream、FileWriter
>  - 读取方式一般有：
>    - 一次读一个字节
>    - 一次读一个字节数组
>
>  - 写的方式一般有：
>    - 一次写一个字节
>    - 一次写一个字节数组
>
>  - 注意事项
>    - 读之前需要创建对象
>    - 读完之后需要关闭对象
>
>
>  代码：
>
>  ```java
>  public class CopyTxtDemo {
>     public static void main(String[] args) throws IOException,FileNotFoundException {
>         FileInputStream fis = new FileInputStream("E:\\text\\窗里窗外.txt");
>         // 根据目的地创建字节输出流对象
>         FileOutputStream fos = new FileOutputStream("myByteStream\\窗里窗外.txt");
>  
>         byte [] bytes = new byte[1024]; // 1024 及其整数倍
>         int len;
>         while ((len=fis.read(bytes))!=-1) {
>             fos.write(bytes,0,len);
>         }
>         //释放资源
>         fos.close();
>         fis.close();
>     }
>  }
>  ```
>
>  

- 字节流

  ![字节流](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20241021210053307.png)

- 字符流

  ![字符流](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20241021210106482.png)



I/O（input/output）：存储和读取文件的解决方案。读写文件中的数据。以程序为参考物来进行读写。

File：标识系统中的文件或者文件夹的路径，FIle 类只能对文件本身继续操作，不能读写文件里面存储的数据。

流：是一种抽象概念，是对数据传输的总称。也就是说数据在设备间的传输称为流，流的本质是数据传输

IO流就是用来处理设备间数据传输问题的。常见的应用：文件复制；文件上传；文件下载



## IO 流的使用场景

- 如果操作的是纯文本文件，优先使用字符流
- 如果操作的是图片、视频、音频等二进制文件。优先使用字节流
- 如果不确定文件类型，优先使用字节流。字节流是万能的流



## 分类

### 流的方向：

- 输入流：读取
- 输出流：写出



### 操作文件类型：

- 字节流：所有类型的文件（Excel、Word）
- 字符流：纯文本文件（Markdown、txt等使用 Windows 记事本便能打开的文件。读这种文件一般选择字符流，因为使用字节流可能会出现乱码情况，字符流也是基于字节流实现的）

![IO流分类](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20241021170618851.png)

#### 字节流

- InputStream：字节输入流
- OutputStream：字节输出流
  - FileOutputStream(String name)：创建文件输出流以指定的名称写入文件

#### 字符流：

- Reader：字节输入流
- Writer：字节输出流

都是抽象类



## 字节流

字节流可以读任意类型的文件

### 字节输出流数据

通过 `FileOutPutStream` 来实现（从内存输出到文件）

FileOutputStream 的作用：可以把程序中的数据写到本地的文件上，是字节流的基本流；

使用字节输出流写数据的步骤（创建对象、写出数据、释放资源）

- 创建字节输出流对象(调用系统功能创建了文件，创建字节输出流对象，让字节输出流对象指向文件)
- 调用字节输出流对象的写数据方法
- 释放资源(关闭此文件输出流并释放与此流相关联的任何系统资源)

```java
public class FileOutputStreamDemo01 {
    public static void main(String[] args) throws IOException {
        FileOutputStream fos = new FileOutputStream("myByteStream\\fos.txt");
        fos.write(97);
        fos.close();
    }
}
```



#### 书写细节

1. 创建字节输出流对象
   1. 参数是字符串表示路径或者 File 对象都是可以的
   2. 如果文件不存在会创建一个新的文件，但是要保证父级路径是存在的；
   3. 如果文件已经存在，则会清空文件
2. 写数据
   1. write 方法的参数是整数，但是实际上写到本地文件中的是整数在 ASCII 上对应的字符；
3. 释放资源
   1. 每一次使用完流都需要释放资源

| 方法名                                   | 说明                                                         |
  | ---------------------------------------- | ------------------------------------------------------------ |
  | void   write(int b)                      | 将指定的字节写入此文件输出流   一次写一个字节数据            |
  | void   write(byte[] b)                   | 将 b.length字节从指定的字节数组写入此文件输出流   一次写一个字节数组数据 |
  | void   write(byte[] b, int off, int len) | 将 len字节从指定的字节数组开始，从偏移量off开始写入此文件输出流   一次写一个字节数组的部分数据 |



#### 字节流写数据如何实现追加写入

字节流写数据如何实现换行

换行符：

- windows:\r\n
- linux:\n
- mac:\r

如何换行

- **public FileOutputStream(String name,boolean append)**
- 创建文件输出流以指定的名称写入文件。如果第二个参数为 true ，则字节将写入文件的末尾而不是开头



### 字节流读数据

字节输入流

- FileInputStream(String name)：通过打开与实际文件的连接来创建一个FileInputStream ，该文件由文件系统中的路径名name命名

字节输入流读取数据的步骤

- 创建字节输入流对象
- 调用字节输入流对象的读数据方法
- 释放资源

```java 
public class FileInputStreamDemo01 {
    public static void main(String[] args) throws IOException {
        FileInputStream fis = new FileInputStream("myByteStream\\fos.txt");
        int by;
        while ((by=fis.read())!=-1) {
            System.out.print((char)by);
        }
        fis.close();
    }
}
```



### FileInputStream 书写细节

1. 创建字节输入流对象
   1. 如果文件不存在，就直接报错（创建文件没有意义）FileNotFoundException
2. 读取数据
   1. 一次读一个字节，读出来的是数据在 ASCII 上对应的数字
   2. 读到文件末尾了，read 方法返回 -1；
3. 释放资源：每次使用完流必须要释放资源；



### 字节流复制文本文件(图片同理)

```java 
public class CopyTxtDemo {
    public static void main(String[] args) throws IOException,FileNotFoundException {
        FileInputStream fis = new FileInputStream("E:\\text\\窗里窗外.txt");
        //根据目的地创建字节输出流对象
        FileOutputStream fos = new FileOutputStream("myByteStream\\窗里窗外.txt");

        byte [] bytes = new byte[1024]; // 1024 及其整数倍
        int len;
        while ((len=fis.read(bytes))!=-1) {
            fos.write(bytes,0,len);
        }
        //释放资源
        fos.close();
        fis.close();
    }
}
```



### 字节缓冲流

字节缓冲流介绍

- lBufferOutputStream：该类实现缓冲输出流。 通过设置这样的输出流，应用程序可以向底层输出流写入字节，而不必为写入的每个字节导致底层系统的调用。

- lBufferedInputStream：创建BufferedInputStream将创建一个内部缓冲区数组。 当从流中读取或跳过字节时，内部缓冲区将根据需要从所包含的输入流中重新填充，一次很多字节。

构造方法：

| 方法名                                 | 说明                   |
| -------------------------------------- | ---------------------- |
| BufferedOutputStream(OutputStream out) | 创建字节缓冲输出流对象 |
| BufferedInputStream(InputStream in)    | 创建字节缓冲输入流对象 |

实现步骤

- 根据数据源创建字节输入流对象

- 根据目的地创建字节输出流对象
- 读写数据，复制视频
- 释放资源

字节缓冲流复制视频

```java 
public class CopyAviDemo {
    public static void main(String[] args) throws IOException {
        //记录开始时间
        long startTime = System.currentTimeMillis();

        //复制视频
        method4();

        //记录结束时间
        long endTime = System.currentTimeMillis();
        System.out.println("共耗时：" + (endTime - startTime) + "毫秒");
    }

    // 字节缓冲流一次读写一个字节数组
    public static void method4() throws IOException {
        BufferedInputStream bis = new BufferedInputStream(new FileInputStream("E:\\字节流复制图片.avi"));
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("myByteStream\\字节流复制图片.avi"));

        byte[] bys = new byte[1024];
        int len;
        while ((len=bis.read(bys))!=-1) {
            bos.write(bys,0,len);
        }

        bos.close();
        bis.close();
    }

    // 字节缓冲流一次读写一个字节
    public static void method3() throws IOException {
        BufferedInputStream bis = new BufferedInputStream(new FileInputStream("E:\\字节流复制图片.avi"));
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("myByteStream\\字节流复制图片.avi"));

        int by;
        while ((by=bis.read())!=-1) {
            bos.write(by);
        }

        bos.close();
        bis.close();
    }


    // 基本字节流一次读写一个字节数组
    public static void method2() throws IOException {
        // E:\\字节流复制图片.avi
        // 模块目录下的 字节流复制图片.avi
        FileInputStream fis = new FileInputStream("E:\\字节流复制图片.avi");
        FileOutputStream fos = new FileOutputStream("myByteStream\\字节流复制图片.avi");

        byte[] bys = new byte[1024];
        int len;
        while ((len=fis.read(bys))!=-1) {
            fos.write(bys,0,len);
        }

        fos.close();
        fis.close();
    }

    // 基本字节流一次读写一个字节
    public static void method1() throws IOException {
        // E:\\字节流复制图片.avi
        //模块目录下的 字节流复制图片.avi
        FileInputStream fis = new FileInputStream("E:\\字节流复制图片.avi");
        FileOutputStream fos = new FileOutputStream("myByteStream\\字节流复制图片.avi");

        int by;
        while ((by=fis.read())!=-1) {
            fos.write(by);
        }

        fos.close();
        fis.close();
    }
}
```



## 字符流

字符流：由于字节流操作中文不是特别的方便，所以Java就提供字符流。

> 字符流 = 字节流 + 编码表

### 字符流原理

1. 创建字符输入流

   1. 底层：关联文件，并处案件缓冲区（长度为 8192 的字节数组）

2. 读取数据

   1. 底层：

      1. 判断缓冲区中是否有数据可以读取

      2. 缓冲区没有数据：就从文件中获取数据，装到缓冲区中，每次尽可能装满缓冲区，如果文件中也没有数据了，返回 -1；

      3. 缓冲区有数据：就从缓冲区中读取。

         空参的 read 方法：一次读取一个字节，遇到中文一次读多个字节，把字节解码并转换成十进制返回

         有参的 read 方法：把读取字节，解码，强转三步合并了，强转之后的字符放到数组中

### 字符串中的编码节码相关方法：

| 方法名                                   | 说明                                               |
| ---------------------------------------- | -------------------------------------------------- |
| byte[] getBytes()                        | 使用平台的默认字符集将该 String 编码为一系列字节   |
| byte[] getBytes(String charsetName)      | 使用指定的字符集将该 String编码为一系列字节        |
| String(byte[] bytes)                     | 使用平台的默认字符集解码指定的字节数组来创建字符串 |
| String(byte[] bytes, String charsetName) | 通过指定的字符集解码指定的字节数组来创建字符串     |

```java
public class StringDemo {
  public static void main(String[] args) throws UnsupportedEncodingException {
      //定义一个字符串
      String s = "中国";
      byte[] bys = s.getBytes("GBK"); //[-42, -48, -71, -6]
      System.out.println(Arrays.toString(bys));
      String ss = new String(bys,"GBK");
      System.out.println(ss);
  }
}
```



### 字符流中和编码解码问题相关的两个类

- InputStreamReader：是从字节流到字符流的桥梁

  ​	它读取字节，并使用指定的编码将其解码为字符

  ​	它使用的字符集可以由名称指定，也可以被明确指定，或者可以接受平台的默认字符集

- OutputStreamWriter：是从字符流到字节流的桥梁

  ​	是从字符流到字节流的桥梁，使用指定的编码将写入的字符编码为字节

  ​	它使用的字符集可以由名称指定，也可以被明确指定，或者可以接受平台的默认字符集



#### 构造方法：

| 方法名                                              | 说明                                         |
| --------------------------------------------------- | -------------------------------------------- |
| InputStreamReader(InputStream in)                   | 使用默认字符编码创建InputStreamReader对象    |
| InputStreamReader(InputStream in,String chatset)    | 使用指定的字符编码创建InputStreamReader对象  |
| OutputStreamWriter(OutputStream out)                | 使用默认字符编码创建OutputStreamWriter对象   |
| OutputStreamWriter(OutputStream out,String charset) | 使用指定的字符编码创建OutputStreamWriter对象 |

#### 代码：

```java
public class ConversionStreamDemo {
    public static void main(String[] args) throws IOException {
        OutputStreamWriter osw = new OutputStreamWriter(new                                              FileOutputStream("myCharStream\\osw.txt"),"GBK");
        osw.write("中国");
        osw.close();
        
        InputStreamReader isr = new InputStreamReader(new                                                 FileInputStream("myCharStream\\osw.txt"),"GBK");
        //一次读取一个字符数据
        int ch;
        while ((ch=isr.read())!=-1) {
            System.out.print((char)ch);
        }
        isr.close();
    }
}
```



### 字符流写数据的 5 中方式

| 方法名                                    | 说明                 |
| ----------------------------------------- | -------------------- |
| void   write(int c)                       | 写一个字符           |
| void   write(char[] cbuf)                 | 写入一个字符数组     |
| void write(char[] cbuf, int off, int len) | 写入字符数组的一部分 |
| void write(String str)                    | 写一个字符串         |
| void write(String str, int off, int len)  | 写一个字符串的一部分 |



刷新和关闭的方法

| 方法名  | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| flush() | 刷新流，之后还可以继续写数据                                 |
| close() | 关闭流，释放资源，但是在关闭之前会先刷新流。一旦关闭，就不能再写数据 |

代码

```java
public class OutputStreamWriterDemo {
    public static void main(String[] args) throws IOException {
        OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream("myCharStream\\osw.txt"));

        // void write(int c)：写一个字符
        osw.write(97);

        // void writ(char[] cbuf)：写入一个字符数组
        char[] chs = {'a', 'b', 'c', 'd', 'e'};
        osw.write(chs);

        // void write(char[] cbuf, int off, int len)：写入字符数组的一部分
        osw.write(chs, 0, chs.length);

        // void write(String str)：写一个字符串
        osw.write("abcde");

        //void write(String str, int off, int len)：写一个字符串的一部分
        osw.write("abcde", 0, "abcde".length());

        //释放资源
        osw.close();
    }
}
```





### 读取字符流

| 方法名                | 说明                   |
| --------------------- | ---------------------- |
| int read()            | 一次读一个字符数据     |
| int read(char[] cbuf) | 一次读一个字符数组数据 |



```java
public class InputStreamReaderDemo {
    public static void main(String[] args) throws IOException {
   
        InputStreamReader isr = new InputStreamReader(new FileInputStream("myCharStream\\ConversionStreamDemo.java"));

        //int read()：一次读一个字符数据
        int ch;
        while ((ch=isr.read())!=-1) {
            System.out.print((char)ch);
        }

        //int read(char[] cbuf)：一次读一个字符数组数据
        char[] chs = new char[1024];
        int len;
        isr = new InputStreamReader(new FileInputStream("myCharStream\\ConversionStreamDemo.java"));
        while ((len = isr.read(chs)) != -1) {
            System.out.print(new String(chs, 0, len));
        }

        //释放资源
        isr.close();
    }
}
```



### 字符流复制文件

把模块目录下的“ConversionStreamDemo.java” 复制到模块目录下的“Copy.java”

- 实现步骤
  - 根据数据源创建字符输入流对象
  - 根据目的地创建字符输出流对象
  - 读写数据，复制文件
  - 释放资源

```java
public class CopyJavaDemo01 {
    public static void main(String[] args) throws IOException {
        //根据数据源创建字符输入流对象
        InputStreamReader isr = new InputStreamReader(new FileInputStream("myCharStream\\ConversionStreamDemo.java"));
        //根据目的地创建字符输出流对象
        OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream("myCharStream\\Copy.java"));

        //读写数据，复制文件
        //一次读写一个字符数据
//        int ch;
//        while ((ch=isr.read())!=-1) {
//            osw.write(ch);
//        }

        //一次读写一个字符数组数据
        char[] chs = new char[1024];
        int len;
        while ((len=isr.read(chs))!=-1) {
            osw.write(chs,0,len);
        }

        //释放资源
        osw.close();
        isr.close();
    }
}
```



### 改进版

```java
public class CopyJavaDemo02 {
    public static void main(String[] args) throws IOException {
        //根据数据源创建字符输入流对象
        FileReader fr = new FileReader("myCharStream\\ConversionStreamDemo.java");
        //根据目的地创建字符输出流对象
        FileWriter fw = new FileWriter("myCharStream\\Copy.java");

        //读写数据，复制文件
//        int ch;
//        while ((ch=fr.read())!=-1) {
//            fw.write(ch);
//        }

        char[] chs = new char[1024];
        int len;
        while ((len=fr.read(chs))!=-1) {
            fw.write(chs,0,len);
        }

        //释放资源
        fw.close();
        fr.close();
    }
}
```



### 字符缓冲流

#### 字符缓冲流介绍

- BufferedWriter：将文本写入字符输出流，缓冲字符，以提供单个字符，数组和字符串的高效写入，可以指定缓冲区大小，或者可以接受默认大小。默认值足够大，可用于大多数用途

- BufferedReader：从字符输入流读取文本，缓冲字符，以提供字符，数组和行的高效读取，可以指定缓冲区大小，或者可以使用默认大小。 默认值足够大，可用于大多数用途

#### 构造方法

| 方法名                     | 说明                   |
| -------------------------- | ---------------------- |
| BufferedWriter(Writer out) | 创建字符缓冲输出流对象 |
| BufferedReader(Reader in)  | 创建字符缓冲输入流对象 |

> 把模块目录下的ConversionStreamDemo.java 复制到模块目录下的 Copy.java

- 实现步骤

  - 根据数据源创建字符缓冲输入流对象
  - 根据目的地创建字符缓冲输出流对象
  - 读写数据，复制文件，使用字符缓冲流特有功能实现
  - 释放资源

```java 
public class CopyJavaDemo01 {
    public static void main(String[] args) throws IOException {
        //根据数据源创建字符缓冲输入流对象
        BufferedReader br = new BufferedReader(new FileReader("myCharStream\\ConversionStreamDemo.java"));
        //根据目的地创建字符缓冲输出流对象
        BufferedWriter bw = new BufferedWriter(new FileWriter("myCharStream\\Copy.java"));

        //一次读写一个字符数组数据
        char[] chs = new char[1024];
        int len;
        while ((len=br.read(chs))!=-1) {
            bw.write(chs,0,len);
        }

        //释放资源
        bw.close();
        br.close();
    }
}
```

### 字符缓冲流特有功能

方法介绍

BufferedWriter：

| 方法名         | 说明                                         |
| -------------- | -------------------------------------------- |
| void newLine() | 写一行行分隔符，行分隔符字符串由系统属性定义 |

BufferedReader:

| 方法名            | 说明                                                         |
| ----------------- | ------------------------------------------------------------ |
| String readLine() | 读一行文字。 结果包含行的内容的字符串，不包括任何行终止字符如果流的结尾已经到达，则为null |



字符缓冲流复制 Java 文件

```java
public class CopyJavaDemo02 {
    public static void main(String[] args) throws IOException {
        //根据数据源创建字符缓冲输入流对象
        BufferedReader br = new BufferedReader(new FileReader("myCharStream\\ConversionStreamDemo.java"));
        //根据目的地创建字符缓冲输出流对象
        BufferedWriter bw = new BufferedWriter(new FileWriter("myCharStream\\Copy.java"));

        //读写数据，复制文件
        //使用字符缓冲流特有功能实现
        String line;
        while ((line=br.readLine())!=null) {
            bw.write(line);
            bw.newLine();
            bw.flush();
        }

        //释放资源
        bw.close();
        br.close();
    }
}
```



## 对象序列化流与反序列化流

对象序列化：就是将对象保存在磁盘中（持久存储），或者在网络中传输对象。如果流是网络套接字流，则可以在另一个主机上或另一个进程中重构对象 。

- 使用一个字节序列表示一个对象，该字节序列主要包含：对象的类型、对象的数据和对象中存储的属性等信息。
- 字节序列写到文件之后，相当于文件中持久保存了一个对象的信息。



### 对象序列化流： ObjectOutputStream

注意事项

- 一个对象要想被序列化，该对象所属的类必须必须实现Serializable 接口
- Serializable是一个标记接口，实现该接口，不需要重写任何方法

构造方法

| 方法名                               | 说明                                               |
  | ------------------------------------ | -------------------------------------------------- |
  | ObjectOutputStream(OutputStream out) | 创建一个写入指定的OutputStream的ObjectOutputStream |

序列化对象的方法

  | 方法名                       | 说明                               |
  | ---------------------------- | ---------------------------------- |
  | void writeObject(Object obj) | 将指定的对象写入ObjectOutputStream |

代码

```java
public class ObjectOutputStreamDemo {
    public static void main(String[] args) throws IOException {
        //ObjectOutputStream(OutputStream out)：创建一个写入指定的OutputStream的ObjectOutputStream
        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("myOtherStream\\oos.txt"));

        //创建对象
        Student mahua = new Student("麻花",19);

        //void writeObject(Object obj)：将指定的对象写入ObjectOutputStream
        oos.writeObject(mahua);

        //释放资源
        oos.close();
    }
}
```



serialVersionUID

- 用对象序列化流序列化了一个对象后，修改了对象所属的类文件，读取数据会抛出InvalidClassException异常
- 如何解决：
  - 重新序列化
  - 给对象所属的类加一个serialVersionUID 
    - private static final long serialVersionUID = 42L;

如何不让一个成员变量被序列化呢？

transient

- 如果一个对象中的某个成员变量的值不想被序列化，又该如何实现呢？
  - 给该成员变量加transient关键字修饰，该关键字标记的成员变量不参与序列化过程



### 对象反序列化流

对象反序列化流： ObjectInputStream

- ObjectInputStream 反序列化先前使用 ObjectOutputStream 编写的原始数据和对象

构造方法

| 方法名                            | 说明                                           |
| --------------------------------- | ---------------------------------------------- |
| ObjectInputStream(InputStream in) | 创建从指定的InputStream读取的ObjectInputStream |

反序列化对象的方法

| 方法名              | 说明                            |
| ------------------- | ------------------------------- |
| Object readObject() | 从ObjectInputStream读取一个对象 |

```java
public class ObjectInputStreamDemo {
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        //ObjectInputStream(InputStream in)：创建从指定的InputStream读取的ObjectInputStream
        ObjectInputStream ois = new ObjectInputStream(new FileInputStream("myOtherStream\\oos.txt"));

        //Object readObject()：从ObjectInputStream读取一个对象
        Object obj = ois.readObject();

        Student s = (Student) obj;
        System.out.println(s.getName() + "," + s.getAge());

        ois.close();
    }
}
```



## 打印流

- 打印流分类

  - 字节打印流：PrintStream
  - 字符打印流：PrintWriter
- 打印流的特点

  - 只负责输出数据，不负责读取数据
  - 永远不会抛出 IOException
  - 有自己的特有方法

### 字节打印流

- PrintStream(String fileName)：使用指定的文件名创建新的打印流

- 使用继承父类的方法写数据，查看的时候会转码；使用自己的特有方法写数据，查看的数据原样输出

- 可以改变输出语句的目的地

  ​	public static void setOut(PrintStream out)：重新分配“标准”输出流

- 示例代码

  ```java
  public class PrintStreamDemo {
      public static void main(String[] args) throws IOException {
          //PrintStream(String fileName)：使用指定的文件名创建新的打印流，将数据写到该文件中
          PrintStream ps = new PrintStream("myOtherStream\\ps.txt");
  
          //写数据
          //字节输出流有的方法
          ps.write(97);
  
          //使用特有方法写数据
          ps.print(97);
          ps.println(98);
          
          //释放资源
          ps.close();
      }
  }
  ```

### 字符打印流

- 字符打印流构造方法

  | 方法名                                       | 说明                                                         |
  | -------------------------------------------- | ------------------------------------------------------------ |
  | PrintWriter(String   fileName)               | 使用指定的文件名创建一个新的 PrintWriter，而不需要自动执行刷新 |
  | PrintWriter(Writer   out, boolean autoFlush) | 创建一个新的PrintWriter    out：字符输出流    autoFlush： 一个布尔值，如果为真，则 println ， printf ，或 format 方法将刷新输出缓冲区 |

- 示例代码

  ```java
  public class PrintWriterDemo {
      public static void main(String[] args) throws IOException {
          //PrintWriter(String fileName) ：使用指定的文件名创建一个新的PrintWriter，而不需要自动执行行刷新
          PrintWriter pw1 = new PrintWriter("myOtherStream\\pw.txt");
  
          pw1.write("hello");
          pw1.write("\r\n");
          pw1.flush();
          pw1.println("world");
  
          //PrintWriter(Writer out, boolean autoFlush)：创建一个新的PrintWriter
          PrintWriter pw = new PrintWriter(new FileWriter("myOtherStream\\pw.txt"),true);
  
          pw.println("hello");
  		pw.write("hello");
          pw.write("\r\n");
          pw.flush();
  
          pw.close();
      }
  }
  ```

### 

































































































































































