---
title: Java 集合
date: 2023-08-21
updated: 2023-10-15
comments: true
comments: true
category: java
tags:
  - 源码
cover: https://tse1-mm.cn.bing.net/th/id/OIP-C.n4zVeHFdrJSVnHqSy0wd5AHaEd?w=275&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---





# Java 集合

- 使用工具类 `Arrays.asList()` 把数组转换成集合时，不能使用其修改集合相关的方法， 它的 `add/remove/clear` 方法会抛出 `UnsupportedOperationException` 异常。
- `Arrays.asList()` 方法返回的并不是 `java.util.ArrayList` ，而是 `java.util.Arrays` 的一个内部类,这个内部类并没有实现集合的修改方法或者说并没有重写这些方法。



### 1. Java 集合框架

存放单一元素Collection：

- Set（无序、不可重复）
  - HashSet（哈希表） 基于 HashMap 实现，底层使用 HashMap 保存元素。
    - 当把一个对象加入 HashSet 时，HashSet 会计算出对象的 hashCode 值来判断对象加入的地址，同时也会与其他加入的对象的 hashCode 进行比较，如果没有相符的 HashCode，那么 HahsSet 就会假设对象没有重复小狐仙，如果有相同的 hashCode，那么旧通过 equals 判断 两个对象是否相等，如果相等，就不会让加入操作成功。
    - LinkedHashSet
  - SortedSet（接口）
    - TreeSet（有序，唯一）红黑树（自平衡的排序二叉树）
- List（有序、可重复的）
  - ArrayList（数组）
  - LinkedList（1.7之后不是循环链表了，单纯的链表）
  - Vector
    - Stack
- Queue（有序，可重复的，有先后顺序） 
  - Deque（接口）
    - ArrayDeque：可扩容的动态双向数组。
    - LinkedList
  - PriorityQueue：数组实现小顶堆
  - DelayQueue

存放键值对 Map：（key 是无序的，不可重复的，value是无需的，可重复的，每个键最多映射到一个值）

一般 数组 是主体，链表和红黑树是为了解决 hash 冲突

- HashMap（数组+链表+红黑树）64-8 （树化（红黑树）以加快查询）
  - 长度是2 的次幂
    - 位运算效率更高
    - 更好地保证哈希值均匀分布
    - 是扩容变得简单高效

  - LinkedHashMap（链表+哈希表）

- Hashtable（数组+链表）
- SortedMap
  - TreeMap（红黑树，自平衡的排序二叉树）

### 2. List

#### 1. ArrayList 和 Array 的区别

- 动态数组
- 可以扩容
- 使用泛型保证类型的安全
- 只能存储对象
- 支持插入、删除、遍历等操作
- 不需要指定大小



#### 2. ArrayList 和 Vector 的区别？

- 都是使用 Object [] 存储
- 线程安全
- 一个是主要实现类，一个是古早实现类



#### 3.ArrayList 和 LinkedList 的区别

- 都是线程不安全的，不同步
- 一个使用数组，一个双向链表
- 插入和删除元素效率不一样
- 支持快速访问
- 内存占用

#### 4. Vector 和 Stack 的区别

- 都是线程安全，使用 synchronized 关键字进行同步处理。
- Stack 继承 Vector，是一个后进先出的栈，Vector 是一个列表



### 3. Set

#### 1. Comparable 和 Comparator 的区别



#### 2.HashSet、LinkedHashSet 和 TreeSet 的区别

- 实现了 Set 接口，线程不安全，元素唯一
- 底层数据结构不同



### 4.Queue

#### 1.Queue 和 Deque 的区别

- Queue：单端队列

  - | Queue 接口   | 抛出异常 | 返回特殊值 |
    | ------------ | -------- | ---------- |
    | 插入队列     | add      | offer      |
    | 删除队首     | remove   | poll       |
    | 查询队首元素 | element  | peek       |

- Deque：双端队列

  - | Deque 接口   | 抛出异常    | 返回特殊值 |
    | ------------ | ----------- | ---------- |
    | 插入队首     | addFirst()  | offerFirst |
    | 插入队尾     | addLast()   | offerLast  |
    | 删除队首     | removeFirst | pollFirst  |
    | 删除队尾     | removeLast  | pollLast   |
    | 查询队首元素 | getFirst    | peekFirst  |
    | 查询队尾     | getLast     | peekLast   |



#### 2. BlockingQueue 阻塞队列

BlockingQueue 是一个接口，继承自 Queue，BlockingQueue阻塞的原因是因为器支持的队列没有元素时一致阻塞，直到有元素，还支持如果队列已满，一直等到队列可以放入新元素时再放入。

- ArrayBlockingQueue：使用数组实现的有界阻塞列表。在创建时需要只当容量大小，并支持公平和非公平两种方式的锁访问机制。
- LinkedBlockingQueue：使用单项链表实现的可选有界阻塞队列，在创建时可以指定默认大小，不指定就是 Integer.MAX_VALUE;
- PriorityBlockingQueue：支持优先级排序的无界限阻塞队列，必须实现 Comparable 接口或者在构造函数中传入 Comparator 对象，不能插入null
- SynchronousQueue：同步队列，不存储元素的阻塞队列
- DelayQueue：延迟到特定的时间才能出队



##### ArrayBlockingQueue 和 LinkedBlockingQueue 的区别

- 线程安全
- 底层实现：数组、链表
- 有界：需要指定大小，不需要指定大小
- 锁是否分离：没有分离，分离
- 内存占用：提前分配、根据元素的增加逐渐占用内存。





### 5. Map

#### 1. HashMap 和 Hashtable 的区别

- 线程不安全 synchronized
- 效率较高
- 支持 nullkey 和 nullValue，Hashtable 不支持
- 初始容量大小和扩容大小不一样
  - HashMap：16 - 2 （给定容量会扩充为 2 的幂次方大小）
    - 位运算更快；
  - Hashtable：11 - 2n+1



#### 2. HashMap 和 HashSet 的区别

- HashSet 底层基于 HashMap 实现的

- hashSet 仅存储对象、HashMap 存储键值对

- add、put

  

#### 3. HashMap 和 TreeMap 的区别

- 都是继承自 AbstractMap
- 

#### 4.ConcurrentHashMap 和 Hashtable 的区别

- 底层数据结构：分段数组+链表/红黑树；数组+链表
- 线程安全：放弃了 Segment 概念，直接使用 Node数组+；链表+红黑树实现，并发控制使用 synchronized 和 CAS 来操作；     使用 synchronized 保证线程的安全，效率低





### fail-fast机制

多个线程对 fail-fast 集合进行修改时，可能会抛出一个 ConcurrentModificationException。单线程下也会出现这种问题。

fail-fast：一种错误检测机制，一旦检测到可能发生错误，就立马抛出异常，程序不继续往下执行。（在 for 循环中删除、增加元素）如下代码:(存放数字类型的不一定删除时不一定会出现 ConcurrentModificationException 异常)

```Java
public static void main(String[] args) {
    List<String> list = new ArrayList<>();
    list.add("Mahua");
    list.add("tyut");
    list.add("aaa");
    for (String item : list){
       if (item.equals("aaa")){
          list.remove("aaa");
       }
    }
}
```

原因：增强 for 使用的是迭代器 Iterator。iterator 的 next 方法会抛出异常：

```java
final void checkForComodification() {
    if (modCount != expectedModCount)
        throw new ConcurrentModificationException();
}
```

**解决方法**：

- 使用普通 for(根本原因在于迭代器 Integer 的 next 方法抛出异常)
  ```java
  for (int i = 0; i < list.size(); i++){
      if (list.get(i).equals("aaa")){
          list.remove(i);
      }
  }
  ```

- 直接使用 Iterator

  ```java
  Iterator iterator = list.iterator();
  while(iterator.hashNext){
      if(iterator.next().equals("mahua")){
          list.removve("mahua");
      }
  }
  ```

- Java 8 中提供的 filter，在增强for 进行删除操作之后，立即结束循环体，不再就行遍历；

  ```java
  List<String> newList = list.stream().filter(item -> !item.equals("aaa")).collect(Collectors.toList());
  ```

- 直接使用 fail-safe 机制的集合类(如：ConcurrentLinkedDeque)（这类集合遍历时，不是直接在集合内容上访问，而是先复制集合内容，在拷贝的集合上进行遍历，修改是在原集合上，不会被迭代器检测到）

  ```java
  public static void main(String[] args) {
      ConcurrentLinkedDeque<String> list = new ConcurrentLinkedDeque<>();
      list.add("Mahua");
      list.add("tyut");
      list.add("aaa");
      for (String item : list){
          if (item.equals("aaa")){
              list.remove(item);
          }
      }
      System.out.println(list);
  }
  ```

- 在移除元素时直接结束循环

  ```java
  for (String item : list){
      if (item.equals("aaa")){
          list.remove(item);
          break;
      }
  }
  ```





# 集合源码分析

int 的最大值是 $2^{31}-1$ ( 4 个字节)

文章参考：

- [HashMap 源码分析 | JavaGuide](https://javaguide.cn/java/collection/hashmap-source-code.html#hashmap-简介)

## ArrayList 分析

ArrayList 底层是数组队列，即动态数组，容量能动态增长。

> 总结：
>
> ArrayList 如果不指定初始容量大小，那么在创建的时候容量大小默认是10；
>
> - DEFAULT_CAPACITY：未指定链表长度时列表数组的长度，值为 10；
> - EMPTY_ELEMENTDATA：空数组，如果使用有参构造器指定初始容量大小为0，那么ArrayList 对象就会指向这个空数组；
> - DEFAULTCAPACITY_EMPTY_ELEMENTDATA：默认空数组，与上面的那个空数组区分开，以了解在添加第一个元素时要扩容多少。如果通过无参构造器创建 ArrayList 对象，那么ArrayList 对象就会指向这个空数组，同时长度也变成了 DEFAULT_CAPACITY，即为10；
> - 使用有参（集合）构造器创建 ArrayList 对象的时候，如果长度 = 0，那么实际是DEFAULT_CAPACITY；
> - 扩容机制： int newCapacity = oldCapacity + (oldCapacity >> 1);扩大 1.5 倍左右（考虑奇数要丢掉 `>>>1`后的小数点 ）
>   - 如果增加元素后数组的长度 > 存放数据的数组长度，那么就开始扩容，否则不扩容。
> - 最大限制为：Integer.MAX_VALUE;



ArrayList 可以存储任何类型的对象，包括 null 值（无意义，不推荐存 null）。

ArrayList 核心源码解读：

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable {
    private static final long serialVersionUID = 8683452581122892189L;

    /**
     * 默认初始容量大小，如果创建对象时不指定长度，那么在增加第一个元素的时候，容量为10；
     */
    private static final int DEFAULT_CAPACITY = 10;

    /**
     * 空数组（用于空实例）。
     */
    private static final Object[] EMPTY_ELEMENTDATA = {};

    // 用于默认大小空实例的共享空数组实例。
    // 我们把它从EMPTY_ELEMENTDATA数组中区分出来，以知道在添加第一个元素时容量需要增加多少。
    // 参考 ensureCapacity 方法
    /*
       int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
        ? 0 : DEFAULT_CAPACITY;
    */
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

    /**
     * 实际保存ArrayList数据的数组，支持“扩容”，说白了就是创建一个更大的数组将其复制进去。
     */
    transient Object[] elementData; 

    /**
     * ArrayList 所包含的元素个数，和容量不是一回事
     */
    private int size;

    /**
     * 带初始容量参数的构造函数（用户可以在创建ArrayList对象时自己指定集合的初始大小）
     */
    public ArrayList(int initialCapacity) {
        if (initialCapacity > 0) {
            //如果传入的参数大于0，创建initialCapacity大小的数组
            this.elementData = new Object[initialCapacity];
        } else if (initialCapacity == 0) {
            //如果传入的参数等于0，创建空数组
            this.elementData = EMPTY_ELEMENTDATA;
        } else {
            //其他情况，抛出异常
            throw new IllegalArgumentException("Illegal Capacity: " +
                    initialCapacity);
        }
    }

    /**
     * 默认无参构造函数
     * DEFAULTCAPACITY_EMPTY_ELEMENTDATA 为0.初始化为10，也就是说初始其实是空数组 当添加第一个元素的时候数组容量才变成10
     */
    public ArrayList() {
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
    }

    /**
     * 构造一个包含指定集合的元素的列表，按照它们由集合的迭代器返回的顺序。
     */
    public ArrayList(Collection<? extends E> c) {
        //将指定集合转换为数组
        elementData = c.toArray();
        //如果elementData数组的长度不为0
        if ((size = elementData.length) != 0) {
            // 如果elementData不是Object类型数据（c.toArray可能返回的不是Object类型的数组所以加上下面的语句用于判断）
            if (elementData.getClass() != Object[].class)
                //将原来不是Object类型的elementData数组的内容，赋值给新的Object类型的elementData数组
                elementData = Arrays.copyOf(elementData, size, Object[].class);
        } else {
            // 其他情况，用空数组代替
            this.elementData = EMPTY_ELEMENTDATA;
        }
    }

    /**
     * 修改这个ArrayList实例的容量是列表的当前大小。 应用程序可以使用此操作来最小化ArrayList实例的存储。
     */
    public void trimToSize() {
        modCount++;
        if (size < elementData.length) {
            elementData = (size == 0)
                    ? EMPTY_ELEMENTDATA
                    : Arrays.copyOf(elementData, size);
        }
    }
// 下面是 ArrayList 的扩容机制
// ArrayList 的扩容机制提高了性能，如果每次只扩充一个，那么频繁的插入会导致频繁的拷贝，降低性能，
// 而 ArrayList 的扩容机制避免了这种情况。

    /**
     * 如有必要，增加此 ArrayList 实例的容量，以确保它至少能容纳元素的数量
     *
     * @param minCapacity 所需的最小容量
     */
    public void ensureCapacity(int minCapacity) {
        //如果是true，minExpand的值为0，如果是false,minExpand的值为10
        int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
                // any size if not default element table
                ? 0
                // larger than default for default empty table. It's already
                // supposed to be at default size.
                : DEFAULT_CAPACITY;
        //如果最小容量大于已有的最大容量
        if (minCapacity > minExpand) {
            ensureExplicitCapacity(minCapacity);
        }
    }

    // 根据给定的最小容量和当前数组元素来计算所需容量。calculate：计算、核算、预测、推测
    private static int calculateCapacity(Object[] elementData, int minCapacity) {
        // 如果当前数组元素为空数组（初始情况），返回默认容量和最小容量中的较大值作为所需容量
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
            return Math.max(DEFAULT_CAPACITY, minCapacity);
        }
        // 否则直接返回最小容量
        return minCapacity;
    }

    // 确保内部容量达到指定的最小容量。
    private void ensureCapacityInternal(int minCapacity) {
        ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
    }

    //判断是否需要扩容 Explicit：明确的
    private void ensureExplicitCapacity(int minCapacity) {
        modCount++;
        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
            //调用grow方法进行扩容，调用此方法代表已经开始扩容了
            grow(minCapacity);
    }

    /**
     * 要分配的最大数组大小
     */
    private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

    /**
     * ArrayList扩容的核心方法。
     */
    private void grow(int minCapacity) {
        // oldCapacity为旧容量，newCapacity为新容量
        int oldCapacity = elementData.length;
        //将oldCapacity 右移一位，其效果相当于oldCapacity /2，
        //我们知道位运算的速度远远快于整除运算，整句运算式的结果就是将新容量更新为旧容量的1.5倍，
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        //然后检查新容量是否大于最小需要容量，若还是小于最小需要容量，那么就把最小需要容量当作数组的新容量，
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        //再检查新容量是否超出了ArrayList所定义的最大容量，
        //若超出了，则调用hugeCapacity()来比较minCapacity和 MAX_ARRAY_SIZE，
        //如果minCapacity大于MAX_ARRAY_SIZE，则新容量则为Integer.MAX_VALUE，否则，新容量大小则为 MAX_ARRAY_SIZE。
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
    }

    //比较minCapacity和 MAX_ARRAY_SIZE
    private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
                Integer.MAX_VALUE :
                MAX_ARRAY_SIZE;
    }

    /**
     * 返回此列表中的元素数。
     */
    public int size() {
        return size;
    }

    /**
     * 如果此列表不包含元素，则返回 true 。
     */
    public boolean isEmpty() {
        //注意=和==的区别
        return size == 0;
    }

    /**
     * 如果此列表包含指定的元素，则返回true 。
     */
    public boolean contains(Object o) {
        //indexOf()方法：返回此列表中指定元素的首次出现的索引，如果此列表不包含此元素，则为-1
        return indexOf(o) >= 0;
    }

    /**
     * 返回此列表中指定元素的首次出现的索引，如果此列表不包含此元素，则为-1
     */
    public int indexOf(Object o) {
        if (o == null) {
            for (int i = 0; i < size; i++)
                if (elementData[i] == null)
                    return i;
        } else {
            for (int i = 0; i < size; i++)
                //equals()方法比较
                if (o.equals(elementData[i]))
                    return i;
        }
        return -1;
    }

    /**
     * 返回此列表中指定元素的最后一次出现的索引，如果此列表不包含元素，则返回-1。.
     */
    public int lastIndexOf(Object o) {
        if (o == null) {
            for (int i = size - 1; i >= 0; i--)
                if (elementData[i] == null)
                    return i;
        } else {
            for (int i = size - 1; i >= 0; i--)
                if (o.equals(elementData[i]))
                    return i;
        }
        return -1;
    }

    /**
     * 返回此ArrayList实例的浅拷贝。 （元素本身不被复制。）
     */
    public Object clone() {
        try {
            ArrayList<?> v = (ArrayList<?>) super.clone();
            //Arrays.copyOf功能是实现数组的复制，返回复制后的数组。参数是被复制的数组和复制的长度
            v.elementData = Arrays.copyOf(elementData, size);
            v.modCount = 0;
            return v;
        } catch (CloneNotSupportedException e) {
            // 这不应该发生，因为我们是可以克隆的
            throw new InternalError(e);
        }
    }

    /**
     * 以正确的顺序（从第一个到最后一个元素）返回一个包含此列表中所有元素的数组。
     * 返回的数组将是“安全的”，因为该列表不保留对它的引用。 （换句话说，这个方法必须分配一个新的数组）。
     * 因此，调用者可以自由地修改返回的数组。 此方法充当基于阵列和基于集合的API之间的桥梁。
     */
    public Object[] toArray() {
        return Arrays.copyOf(elementData, size);
    }

    /**
     * 以正确的顺序返回一个包含此列表中所有元素的数组（从第一个到最后一个元素）;
     * 返回的数组的运行时类型是指定数组的运行时类型。 如果列表适合指定的数组，则返回其中。
     * 否则，将为指定数组的运行时类型和此列表的大小分配一个新数组。
     * 如果列表适用于指定的数组，其余空间（即数组的列表数量多于此元素），则紧跟在集合结束后的数组中的元素设置为null 。
     * （这仅在调用者知道列表不包含任何空元素的情况下才能确定列表的长度。）
     */
    @SuppressWarnings("unchecked")
    public <T> T[] toArray(T[] a) {
        if (a.length < size)
            // 新建一个运行时类型的数组，但是ArrayList数组的内容
            return (T[]) Arrays.copyOf(elementData, size, a.getClass());
        //调用System提供的arraycopy()方法实现数组之间的复制
        System.arraycopy(elementData, 0, a, 0, size);
        if (a.length > size)
            a[size] = null;
        return a;
    }

    // Positional Access Operations

    @SuppressWarnings("unchecked")
    E elementData(int index) {
        return (E) elementData[index];
    }

    /**
     * 返回此列表中指定位置的元素。
     */
    public E get(int index) {
        rangeCheck(index);

        return elementData(index);
    }

    /**
     * 用指定的元素替换此列表中指定位置的元素。
     */
    public E set(int index, E element) {
        //对index进行界限检查
        rangeCheck(index);

        E oldValue = elementData(index);
        elementData[index] = element;
        //返回原来在这个位置的元素
        return oldValue;
    }

    /**
     * 将指定的元素追加到此列表的末尾。
     */
    public boolean add(E e) {
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        //这里看到ArrayList添加元素的实质就相当于为数组赋值
        elementData[size++] = e;
        return true;
    }

    /**
     * 在此列表中的指定位置插入指定的元素。
     * 先调用 rangeCheckForAdd 对index进行界限检查；然后调用 ensureCapacityInternal 方法保证capacity足够大；
     * 再将从index开始之后的所有成员后移一个位置；将element插入index位置；最后size加1。
     */
    public void add(int index, E element) {
        rangeCheckForAdd(index);

        ensureCapacityInternal(size + 1);  // Increments modCount!!
        //arraycopy()这个实现数组之间复制的方法一定要看一下，下面就用到了arraycopy()方法实现数组自己复制自己
        System.arraycopy(elementData, index, elementData, index + 1,
                size - index);
        elementData[index] = element;
        size++;
    }

    /**
     * 删除该列表中指定位置的元素。 将任何后续元素移动到左侧（从其索引中减去一个元素）。
     */
    public E remove(int index) {
        rangeCheck(index);

        modCount++;
        E oldValue = elementData(index);

        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index + 1, elementData, index,
                    numMoved);
        elementData[--size] = null; // clear to let GC do its work
        //从列表中删除的元素
        return oldValue;
    }

    /**
     * 从列表中删除指定元素的第一个出现（如果存在）。 如果列表不包含该元素，则它不会更改。
     * 返回true，如果此列表包含指定的元素
     */
    public boolean remove(Object o) {
        if (o == null) {
            for (int index = 0; index < size; index++)
                if (elementData[index] == null) {
                    fastRemove(index);
                    return true;
                }
        } else {
            for (int index = 0; index < size; index++)
                if (o.equals(elementData[index])) {
                    fastRemove(index);
                    return true;
                }
        }
        return false;
    }

    /*
     * Private remove method that skips bounds checking and does not
     * return the value removed.
     */
    private void fastRemove(int index) {
        modCount++;
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index + 1, elementData, index,
                    numMoved);
        elementData[--size] = null; // clear to let GC do its work
    }

    /**
     * 从列表中删除所有元素。
     */
    public void clear() {
        modCount++;

        // 把数组中所有的元素的值设为null
        for (int i = 0; i < size; i++)
            elementData[i] = null;

        size = 0;
    }

    /**
     * 按指定集合的Iterator返回的顺序将指定集合中的所有元素追加到此列表的末尾。
     */
    public boolean addAll(Collection<? extends E> c) {
        Object[] a = c.toArray();
        int numNew = a.length;
        ensureCapacityInternal(size + numNew);  // Increments modCount
        System.arraycopy(a, 0, elementData, size, numNew);
        size += numNew;
        return numNew != 0;
    }

    /**
     * 将指定集合中的所有元素插入到此列表中，从指定的位置开始。
     */
    public boolean addAll(int index, Collection<? extends E> c) {
        rangeCheckForAdd(index);

        Object[] a = c.toArray();
        int numNew = a.length;
        ensureCapacityInternal(size + numNew);  // Increments modCount

        int numMoved = size - index;
        if (numMoved > 0)
            System.arraycopy(elementData, index, elementData, index + numNew,
                    numMoved);

        System.arraycopy(a, 0, elementData, index, numNew);
        size += numNew;
        return numNew != 0;
    }

    /**
     * 从此列表中删除所有索引为fromIndex （含）和toIndex之间的元素。
     * 将任何后续元素移动到左侧（减少其索引）。
     */
    protected void removeRange(int fromIndex, int toIndex) {
        modCount++;
        int numMoved = size - toIndex;
        System.arraycopy(elementData, toIndex, elementData, fromIndex,
                numMoved);

        // clear to let GC do its work
        int newSize = size - (toIndex - fromIndex);
        for (int i = newSize; i < size; i++) {
            elementData[i] = null;
        }
        size = newSize;
    }

    /**
     * 检查给定的索引是否在范围内。
     */
    private void rangeCheck(int index) {
        if (index >= size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    /**
     * add和addAll使用的rangeCheck的一个版本
     */
    private void rangeCheckForAdd(int index) {
        if (index > size || index < 0)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    /**
     * 返回IndexOutOfBoundsException细节信息
     */
    private String outOfBoundsMsg(int index) {
        return "Index: " + index + ", Size: " + size;
    }

    /**
     * 从此列表中删除指定集合中包含的所有元素。
     */
    public boolean removeAll(Collection<?> c) {
        Objects.requireNonNull(c);
        //如果此列表被修改则返回true
        return batchRemove(c, false);
    }

    /**
     * 仅保留此列表中包含在指定集合中的元素。
     * 换句话说，从此列表中删除其中不包含在指定集合中的所有元素。
     */
    public boolean retainAll(Collection<?> c) {
        Objects.requireNonNull(c);
        return batchRemove(c, true);
    }


    /**
     * 从列表中的指定位置开始，返回列表中的元素（按正确顺序）的列表迭代器。
     * 指定的索引表示初始调用将返回的第一个元素为next 。 初始调用previous将返回指定索引减1的元素。
     * 返回的列表迭代器是fail-fast 。
     */
    public ListIterator<E> listIterator(int index) {
        if (index < 0 || index > size)
            throw new IndexOutOfBoundsException("Index: " + index);
        return new ListItr(index);
    }

    /**
     * 返回列表中的列表迭代器（按适当的顺序）。
     * 返回的列表迭代器是fail-fast 。
     */
    public ListIterator<E> listIterator() {
        return new ListItr(0);
    }

    /**
     * 以正确的顺序返回该列表中的元素的迭代器。
     * 返回的迭代器是fail-fast 。
     */
    public Iterator<E> iterator() {
        return new Itr();
    }

```





## LinkedList 分析

LinkedList 是一个基于**双向链表**实现的集合类。

`LinkedList` 仅仅在头尾插入或者删除元素的时候时间复杂度近似 O(1)，其他情况增删元素的平均时间复杂度都是 O(n) 。

![LinkedList 类图](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/linkedlist--class-diagram.png)



`LinkedList` 中的元素通过 `Node` 定义：

```java
private static class Node<E> {
    E item;// 节点值
    Node<E> next; // 指向的下一个节点（后继节点）
    Node<E> prev; // 指向的前一个节点（前驱结点）

    // 初始化参数顺序分别是：前驱结点、本身节点值、后继节点
    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```



LinkedList 有两种初始化方式：

```java
// 无参构造器，创建一个空的链表元素
public LinkedList() {
}
// 接收一个集合类型作为参数，会创建一个与传入集合相同元素的链表对象
public LinkedList(Collection<? extends E> c) {
    this();
    addAll(c);
}
```



#### 插入元素

`add()` 方法有两个版本：

- `add(E e)`：用于在 `LinkedList` 的尾部插入元素，即将新元素作为链表的最后一个元素，时间复杂度为 O(1)。
- `add(int index, E element)`:用于在指定位置插入元素。这种插入方式需要先移动到指定位置，再修改指定节点的指针完成插入/删除，因此需要移动平均 n/2 个元素，时间复杂度为 O(n)。

```java
// 在链表的尾部插入元素
public boolean add(E e) {
    linkLast(e);
    return true;
}
void linkLast(E e) {
    // 拿到链表的最后一个节点
    final Node<E> l = last;
    final Node<E> newNode = new Node<>(l, e, null);
    // 将最后一个节点指向将插入链表尾部的节点
    last = newNode;
    if (l == null)
        // l = null 说明这次插入的元素在第一个位置，即第一次插入元素 e，
        first = newNode;
    else
        // l != null 要在链表的最后一位插入元素 e
        l.next = newNode;
    // 链表长度 + 1；
    size++;
    modCount++;
}
```



```java
// 在指定位置插入元素
public void add(int index, E element) {
    checkPositionIndex(index);
	// 在最后一位插入元素
    if (index == size)
        linkLast(element);
    else
        // 在指定位置插入元素
        linkBefore(element, node(index));
}
// 确定要插入元素的下标位置的附近元素从哪一端开始找比较快，以便插入较快地实现元素（为了提高效率，该方法根据索引值来决定是从链表的头部开始遍历还是从尾部开始遍历。找到插入位置的前一个或后一个节点，方便继续插入操作）。
Node<E> node(int index) {
    // assert isElementIndex(index);

    if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    } else {
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}

void linkBefore(E e, Node<E> succ) {
        // assert succ != null;
        final Node<E> pred = succ.prev;
        final Node<E> newNode = new Node<>(pred, e, succ);
        succ.prev = newNode;
        if (pred == null)
            first = newNode;
        else
            pred.next = newNode;
        size++;
        modCount++;
    }
```



删除元素

```java
// 删除指定位置的元素
public E remove(int index) {
    // 下表越界检查
    checkElementIndex(index);
    return unlink(node(index));
}
// 删除第一个相关元素。
public boolean remove(Object o) {
    if (o == null) {
        for (Node<E> x = first; x != null; x = x.next) {
            if (x.item == null) {
                unlink(x);
                return true;
            }
        }
    } else {
        for (Node<E> x = first; x != null; x = x.next) {
            if (o.equals(x.item)) {
                unlink(x);
                return true;
            }
        }
    }
    return false;
}

E unlink(Node<E> x) {
    // assert x != null;
    final E element = x.item;
    final Node<E> next = x.next;
    final Node<E> prev = x.prev;

    if (prev == null) {
        first = next;
    } else {
        prev.next = next;
        x.prev = null;
    }

    if (next == null) {
        last = prev;
    } else {
        next.prev = prev;
        x.next = null;
    }

    x.item = null;
    size--;
    modCount++;
    return element;
}
```



### ArrayList 和 Vector 的区别?（了解即可）

- `ArrayList` 是 `List` 的主要实现类，底层使用 `Object[]`存储，适用于频繁的查找工作，线程不安全 。
- `Vector` 是 `List` 的古老实现类，底层使用`Object[]` 存储，线程安全。



### ArrayList 和 LinkedList 的区别

- 线程安全：都是不同步的，不能保证线程安全；
- 底层数据结构：ArrayList 是 Object 数组；LinkedList 是 双向链表（7之后没有循环了）
- 插入和删除是否受元素位置影响：
  - ArrayList：受，时间复杂度为O(n)；
  - LinkedList：
    - 在头尾插入或删除：不受，时间复杂度为 O(1);
    - 在指定位置插入或删除：受，时间复杂度为O(n);因为要找到对应的位置。
- 是否支持快速访问：LinkedList 不支持高效的随机访问，ArrayList 支持（通过序号快速获取元素对象（对应 get(int index) 方法）；
- 内存占用：
  - ArrayList：内存浪费在 list 列表的结尾预留一定的容量空间
  - LikedList：每一个元素都需要消耗比 ArrayList更多的空间（要存放直接后继和直接前继以及数据）





## HashMap 分析

> 默认容量为 16，负载因子为0.75，当容量炒作 16.*0.75 = 12 时，就会自动扩容。

HashMap 主要用来存放键值对，基于哈希表的 Map 接口实现，**非线程安全**。

HashMap 可以存储 null 的 key 和 value，但 null 作为键只能有一个，null 作为值可以有多个。

JDK 1.8 之前 Hash Map 由 数组 + 链表 组成（链表散列），数组是 HashMap 的主题，链表则是主要为了解决哈希冲突而存在的（通过“拉链法”解决冲突）。

 **“拉链法”** ：将链表和数组相结合。创建一个数组，数组中每一个元素都是一个链表。若遇到哈希冲突，则将冲突的值加到链表中即可。

JDK1.8 之后，HashMap 在解决哈希冲突有了较大的变化，当链表长度大约等于阈值（8）的时候（将链表转换成红黑树前会判断，如果数组长度小于 64，那么会选择先进性扩容，而不是转换为红黑树）时，将链表转换为红黑树，以减少搜索时间。

HashMap 默认的初始化大小为 16 每次扩容容量都会变成原来的 2 倍。并且 Hashmap 总是使用 2 的幂作为哈希表的大小。



#### HashMap JDK 8 之前如何存放元素？

HashMap 通过 key 的 hashCode 经过**扰动函数**处理过后得到 hash 值，然后通过 `(n - 1) & hash` 判断当前元素存放的位置（这里的 n 指的是数组的长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的 hash 值以及 key 是否相同，如果相同的话，直接覆盖，不相同就通过拉链法解决冲突。

所谓扰动函数指的就是 HashMap 的 hash 方法。使用 hash 方法也就是扰动函数是为了防止一些实现比较差的 hashCode() 方法 换句话说**使用扰动函数之后可以减少碰撞**。

JDK 1.8 的 hash 方法 相比于 JDK 1.7 hash 方法更加简化，但是原理不变。

这种方法简单且高效，能够有效地将 `hashCode` 的高 16 位与低 16 位混合在一起，从而降低哈希冲突的可能性。

```java
    static final int hash(Object key) {
      int h;
      // key.hashCode()：返回散列值也就是hashcode
      // ^：按位异或：同为0，异为1。
      // >>>:无符号右移，忽略符号位，空位都以0补齐
      // 使用 key.hashCode() 的结果与自身无符号右移 16 位的结果进行异或操作。
      return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
  }
```

对比一下 JDK1.7 的 HashMap 的 hash 方法源码.

```java
static int hash(int h) {
    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).

    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}
```

相比于 JDK1.8 的 hash 方法 ，JDK 1.7 的 hash 方法的性能会稍差一点点，因为毕竟扰动了 4 次（通过多次扰动来减少哈希冲突，但计算成本更高）。

当**链表**长度大于阈值（默认为 8）时，会首先调用 `treeifyBin()`方法。这个方法会根据 HashMap 数组来决定是否转换为红黑树。只有当数组长度大于或者等于 64 的情况下，才会执行转换红黑树操作，以减少搜索时间。否则，就是只是执行 `resize()` 方法对数组扩容。

#### HashMap 的属性

```java
public class HashMap<K,V> extends AbstractMap<K,V> implements Map<K,V>, Cloneable, Serializable {
    // 序列号
    private static final long serialVersionUID = 362498820763181265L;
    // 默认的初始容量是16
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4;
    // 最大容量 2^30
    static final int MAXIMUM_CAPACITY = 1 << 30;
    // 默认的负载因子
    static final float DEFAULT_LOAD_FACTOR = 0.75f;
    // 当桶(bucket)上的结点数大于等于这个值时会转成红黑树
    static final int TREEIFY_THRESHOLD = 8;
    // 当桶(bucket)上的结点数小于等于这个值时树转链表
    static final int UNTREEIFY_THRESHOLD = 6;
    // 桶中结构转化为红黑树对应的table的最小容量
    static final int MIN_TREEIFY_CAPACITY = 64;
    // 存储元素的数组，总是2的幂次倍
    transient Node<k,v>[] table;
    // 一个包含了映射中所有键值对的集合视图
    transient Set<map.entry<k,v>> entrySet;
    // 存放元素的个数，注意这个不等于数组的长度。
    transient int size;
    // 每次扩容和更改map结构的计数器
    transient int modCount;
    // 阈值(容量*负载因子) 当实际大小超过阈值时，会进行扩容
    int threshold;
    // 负载因子
    final float loadFactor;
}
```

- loadFactory：负载因子
  - 控制数组存放元素的疏密程度；loadFactory 默认值为 0.75f；
  - loadFactory 太大数组中存放的数据越多，链表长度增加，会导致查找元素效率低；
  - loadFactory 太小数组中存放的元素越少，会导致数组的利用率低，存放元素很分散。
- threshold：阈值
  - threshold = size * loadFactory；当实际大小（size）超过 threshold 时就会扩容。



#### 构造方法

```java
// 默认构造函数。
public HashMap() {
    this.loadFactor = DEFAULT_LOAD_FACTOR; // all   other fields defaulted
 }

// 包含另一个“Map”的构造函数
 public HashMap(Map<? extends K, ? extends V> m) {
     this.loadFactor = DEFAULT_LOAD_FACTOR;
     putMapEntries(m, false);//下面会分析到这个方法
 }

// 指定“容量大小”的构造函数
 public HashMap(int initialCapacity) {
     this(initialCapacity, DEFAULT_LOAD_FACTOR);
 }

// 指定“容量大小”和“负载因子”的构造函数
 public HashMap(int initialCapacity, float loadFactor) {
     if (initialCapacity < 0)
         throw new IllegalArgumentException("Illegal initial capacity: " + initialCapacity);
     // MAXIMUM_CAPACITY = 1 << 30; = 2^30
     if (initialCapacity > MAXIMUM_CAPACITY)
         initialCapacity = MAXIMUM_CAPACITY;
     if (loadFactor <= 0 || Float.isNaN(loadFactor))
         throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
     this.loadFactor = loadFactor;
     // 初始容量暂时存放到 threshold ，在resize中再赋值给 newCap 进行table初始化
     this.threshold = tableSizeFor(initialCapacity);
 }

```













































