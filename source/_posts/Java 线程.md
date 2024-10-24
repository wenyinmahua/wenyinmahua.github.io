---
title: Java 线程
date: 2023-06-15
comments: true
category: Java
tags:
  - 基础
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C._Lm_T3scKhVEVFC54gcRxwHaE8?w=249&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---

# java 线程

> ❓核心线程数到底配置多少？
>
> - 计算密集型：核心线程数量 = CPU 的核数 + 1；
>   - 比 CPU 核心数多出来的一个线程是为了防止线程偶发的缺页中断，或者其它原因导致的任务暂停而带来的影响。一旦任务暂停，CPU 就会处于空闲状态，而在这种情况下多出来的一个线程就可以充分利用 CPU 的空闲时间。
>
> - IO密集型：核心线程池数量 = CPU 的核数 *  2；
>   - 主要是因为进行 IO 操作时，IO操作会独立执行，不太需要 CPU 资源
>
>



> ❗注意：
>
> - 大型并发系统环境中使用 `Executors` 创建线程池如果不注意会出现系统风险（OOM，内存溢出）



## 1. 进程和线程

**进程：**是指计算机中在运行的一个程序实例，是操作系统进行**资源分配**的基本单位。

- 进程是一个具有独立功能的程序关于某个数据集合的一次运行活动。

**线程：**轻量级进程，多个线程可以在一个进程中同时执行，并且共享进程的资源，比如内存空间、文件描述符、网络连接等。

- 线程是进程划分成的更小的运行单位；是操作系统能够进行运算调度的最小单位，被包含在进程里面，是进程中的实际运作单位。
- 线程和进程最大的不同是各进程是独立的，各线程则不一定，因为同一进程中的线程极有可能会相互影响。
- 线程执行开销小，但是不利于资源的管理和保护（因为是共享进程的空间和资源，不需要操作系统进行再一次分配；对于共享资源，可以通过加锁的方式来实现），进程反之。

> 在 Java 中，一个进程可以有多个线程，多个线程共享进程的 **堆** 和 **方法区** 资源，如程序计数器、Java 虚拟机栈、本地方法栈等。





## 2. 线程的基本使用

进程：正在运行的程序是一个独立的进程

线程是属于进程的，一个进程可以运行多个线程。

进程中的多个线程其实是并发和并行执行的。

线程是一个程序内部的一条执行流程。



> 创建线程的四种方式：
>
> - 继承 Thread 类，重写 run 方法；  
>   - Thread 类实现了 Runnable 接口
> - 实现 Runnable 接口，重写 run 方法；
> - 实现 Callable 接口
> - 使用线程池
>
> run 方法内实现了要执行的任务，说明这个线程要干什么

多线程：只从软硬件上实现的多条执行流程的技术（多条先后曾由CPU负责调度执行）



![image-20240503161527608](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240503161527608.png)





### 方法一

#### 优缺点

优点：编码简单

缺点：java 单继承

#### 注意事项

启动线程必须是调用 start 方法，而不是调用 run 方法

- 直接调用 run 方法会当成普通的方法执行，此时相当于还是单线程执行
- 只有 start 方法才是启动一个新的线程执行

不要把主线程任务放在启动子线程之前

-  主线程先跑完才跑子线程

```java
public class ThreadTest {
    public static void main(String[] args) {
       MyThread myThread  = new MyThread();
       MyThread myThread1 = new MyThread();
		// 启动多线程需要使用 start 方法，使用 run 方法只能顺序执行
       myThread.start();
       myThread1.start();
    }

}
class MyThread extends Thread{
    // 这个方法需要手动实现
    @Override
    public void run() {
       for (int i = 0; i < 100; i++) {
          System.out.println(i);
       }
    }
}
```



### 方法二

实现 Runnable，重写 run 方法，通过 `new Thread(实现Runnable接口的对象).start()` 来调用；

1. 定义一个**线程任务类** MyRunnable 实现 `Runnable` 接口，重写 `run()` 方法
2. 创建 MyRunnable 任务对象
3. 把 MyRunnable 对象交给 Thread 处理（因为不是线程对象）
4. 调用线程对象的start 方法启动线程



优点：可以继续实现和继承，扩展性强

缺点：需要多一个Runnable对象

```java
public class RunnableTest {
	public static void main(String[] args) {
		MyRunnable myRunnable = new MyRunnable();
		MyRunnable myRunnable1 = new MyRunnable();
		Thread thread = new Thread(myRunnable);
		Thread thread1 = new Thread(myRunnable1);
		thread1.start();
		thread.start();
	}
}

class MyRunnable implements Runnable{

	@Override
	public void run() {
		for (int i = 0; i < 100; i++){
			System.out.println(i);
		}
	}
}

```



##### 匿名内部类写法

1. 创建 Runnable 的匿名内部类对象
2. 交给 Thread 线程对象
3. 调用start方法

```java
new Thread(new Runnable() {
    int i = 0;
    @Override
    public void run() {
        while (i < 100)
        System.out.println(i++);
    }
}).start();
// lamdba 表达式简化如下：

new Thread(()->{
    for(int i = 0; i < 100; i++){
        System.out.println(i);
    }
}).start();
```



### 方法三

前两种线程方法都存在一种问题

如果线程执行完毕后有一些数据要返回，他们重写的run 方法均不能直接返回结果。

JDK5.0 提供了 `Callable` 接口和 `FutureTask` 类来实现。

优点：可以返回线程执行完毕后的结果，只实现了接口，可扩展

缺点：代码复杂一点

1. 创建任务对象
   1. 定义一个类实现 `Callable` 接口，重写 `call()` 方法，封装要做的事情，和要返回的数据
   2. 把 Callable 类型的对象封装成 FutureTask 任务（线程任务对象）
   3. 调用 Thread 对象的 start() 方法启动线程
   4. 线程执行完毕后，通过 FutureTask 对象的 `get()` 方法取获取线程任务执行的结果

```java
public class CallableTest {
	public static void main(String[] args) throws ExecutionException, InterruptedException {
		MyCallableTest myCallableTest = new MyCallableTest(10);
		// 把 Callable 对象 封装成一个 FutureTask 对象（任务对象）
		FutureTask<String> f1 = new FutureTask<>(myCallableTest);
		new Thread(f1).start();
		for (int i = 0; i < 100; i++){
			System.out.println(i);
		}
		// 获取线程的执行效果
		// 如果执行到这里，但是上面的for还没有执行完成，这里的代码就会暂停，直到上面的代码执行完毕后才会获得结果
		System.out.println(f1.get());// 输出为Thread-0：sum = 45
	}
}

class MyCallableTest implements Callable<String>{

	private int n;

	public MyCallableTest(int n) {
		this.n = n;
	}

	@Override
	public String call() throws Exception {
		int sum = 0;
		for (int i = 0; i < n; i++){
			sum += i;
			System.out.println(sum);
		}
		return Thread.currentThread().getName()+"：sum = " + sum;
	}
}
```



## 线程的生命周期

- 新建（new）：线程被创建，但是`没有调用 start` 方法
- 就绪（ready）：执行 `run` 方法
- 运行（running）：执行 `yield` 方法
- 等待（waiting）：处于状态的线程需要等待其他线程对其进行通知或中断等操作，进而进入下一各状态
- 超时等待（timed_waiting）：可以在一定的时间按自行返回
- 阻塞（blocked）：需要等待其他线程**释放锁**，或者等待进入 **synchronized**
- 终止（terminated）：表示线程执行完毕





### 线程安全问题

**线程安全：**某个函数在**并发**的环境下被调用，能够正确处理**多个线程**之间的共享变量，使程序能**正确完成。**

- 存在多个线程在同时执行
- 同时访问同一个共享资源
- 存在修改该共享资源



### 线程同步

线程同步是两个或多个共享关键资源的线程并发执行。应该同步线程以避免关键的资源使用冲突。



**思想：**让多个线程实现先后访问共享资源，就解决了安全问题

**加锁**：每次只允许一个线程加锁，加锁之后才能访问，访问完毕后自动解锁，然后其他线程才能加锁进来

#### 方法一：同步代码块

**作用：**把访问共享资源的核心代码上锁，一次保证线程安全

```java
synchronized(同步锁){
    访问共享资源的核心代码块
}

// 注意静态方法加锁方法
synchronized(类名.class){
    访问共享资源的核心代码块
}
```

原理：每次只允许一个线程加锁后加进入，执行完毕后自动解锁，其他线程才能进来。

注意事项：对于当前同时执行的线程来说，同步锁必须是同一把锁（同一个对象），否则会出现 bug

**锁的对象不是随便选择一个唯一的对象，会影响其他无关的线程的执行**

使用规范：

- 建议使用共享资源作为锁对象，对于实例方法建议使用 this 作为锁对象
- 对于静态方法建议使用字节码（类名.class）对象作为锁对象



#### 方法二：同步方法

作用：把访问共享资源的核心方法上锁，保证安全

```java
修饰符 synchronized 返回值类型 方法名称(参数列表){
    操作共享资源的代码
}
```

原理：每次只能一个线程进入加速，执行完毕后自动解锁，其他线程才能进来

同步方法底层原理

- 同步方法其实底层是**隐式锁**对象，只是锁的范围是整个方法代码
- 实例方法：默认使用 `this` 作为的锁对象
- 静态方法：默认使用 `类名.class` 作为锁对象



同步代码块好还是同步方法好？

- 范围上：同步代码锁的范围更小
- 可读性：同步方法更好



#### 方法三：Lock 锁

Lock 锁：JDK5 提供的一个新的锁定操作，通过它可以创建出锁对象继续加锁和解锁，更灵活、更方便、更强大。

Lock 是接口，不能实例化，可以采用他的实现类 ReentrantLock 来构建 Lock 锁对象。

```java
private final Lock lock = new ReentrantLock();
lock.lock(); // 加锁
需要加锁的核心代码块
try{}catch{}finally{
    lock.unlock();// 解锁
}
```



## 3.线程通信

**线程通信：**当多个线程共同操作共享的资源时，线程间通过某种方式告知自己的状态，以防止相互协调，并避免无效的资源争夺

线程通信的常见模型（生产者与消费者模型）

- 生产者负责生产数据
- 消费者负责消费生产者产生的数据
- 注意：生产者生产完数据应该等待自己，通知消费者消费，消费者消费完数据也应该等待自己，再通知生产者生产
- 先唤醒别人，再等待自己

![image-20240503170801142](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240503170801142.png)



## 4. 线程池

**线程池是一个可以复用线程的技术**

不使用线程池

- 用户每发送一个请求，后台就需要创建一个新的线程来处理，下次新任务来了肯定要创建新线程出来，二创建新线程的开销是很大的，并且请求过多时，肯定会产生大量的线程出来，这样会严重影响系统的性能。

使用线程池需要控制线程的数量和任务的数量（工作线程、任务队列）

任务需要实现 Runnable 或者 Callable 接口。

### 前置知识

#### 阻塞队列





### 如何创建线程池

JDK 提供了代表线程池的接口 ExecutorService，实现类 ThreadPoolExecutor

如何得到线程池对象

1. 方法一：使用 ExecutorService 的实现类 ThreadPoolExecutor 自创建一个线程池对象
2. 方法二：使用 Executors（线程池的工具类）调用方法返回不同特点的线程池对象

```java
public ThreadPoolExecutor(int corePoolSize, // 核心线程池的数量，可长期复用
                          int maximumPoolSize,  // 最大线程数量
                          int keepAliveTime, // 临时线程的存活时间
                          TimeUnit unit,  // 指定临时线程存活的时间单位
                          BolckingQueue<Runnable> workQUeue, // 线程池的任务队列
                          ThreadFactory threadFactory, // 线程池的线程工厂
                          RejectedExecutionHandler handler // 指定线程池的任务拒绝策略
                         )
```

```java
ExecutorService executorService = new ThreadPoolExecutor(3,2,10,
				TimeUnit.SECONDS, new ArrayBlockingQueue<>(50), Executors.defaultThreadFactory(),new ThreadPoolExecutor.AbortPolicy());
```



临时线程什么时候创建？

- 新任务提交时核心线程都在忙，任务队列也满了，并且还可以创建线程，此时才会创建临时线程

什么时候开始拒绝新任务？

- 核心线程和临时线程都在忙，并且任务队列也满了，新的任务过来时才会拒绝任务。

![image-20240503174945163](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240503174945163.png)

![image-20240503180148594](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240503180148594.png)



### Executors 接口![image-20240503203453927](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240503203453927.png)



#### newFixedThreadPool 详解

newFixedThreadPool 的构造方法1，指定核心线程数

```java
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                  0L, TimeUnit.MILLISECONDS,
                                  new LinkedBlockingQueue<Runnable>());
}
```

newFixedThreadPool 的构造方法2，指定核心线程数和创建线程的工厂

```java
public static ExecutorService newFixedThreadPool(int nThreads, ThreadFactory threadFactory) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                  0L, TimeUnit.MILLISECONDS,
                                  new LinkedBlockingQueue<Runnable>(),
                                  threadFactory);
}
```









