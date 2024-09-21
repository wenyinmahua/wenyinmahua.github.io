---
title: Java Stream
date: 2024-08-19
updated: 2024-09-20
comments: true
category: Java
tags:
  - 基础
cover: https://tse4-mm.cn.bing.net/th/id/OIP-C._Lm_T3scKhVEVFC54gcRxwHaE8?w=249&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---



# Stream

Stream（流）是一个来自数据源中的元素队列并支持聚合操作

### Stream流的三类方法

- 获取Stream流
  - 创建一条流水线,并把数据放到流水线上准备进行操作
- 中间方法
  - 流水线上的操作
  - 一次操作完毕之后,还可以继续进行其他操作
- 终结方法
  - 一个 Stream 流只能有一个终结方法
  - 是流水线上的最后一个操作

### 生成 Stream 流的方式

- Collection体系集合

  使用默认方法 stream() 生成流， default Stream<E> stream()

- Map 体系集合

  把 Map 转成 Set 集合，间接的生成流

- 数组

  通过 Arrays 中的静态方法 stream 生成流

- 同种数据类型的多个数据

  通过 Stream 接口的静态方法 of(T... values) 生成流



```java
public class StreamDemo {
    public static void main(String[] args) {
        //Collection体系的集合可以使用默认方法stream()生成流
        List<String> list = new ArrayList<String>();
        Stream<String> listStream = list.stream();

        Set<String> set = new HashSet<String>();
        Stream<String> setStream = set.stream();

        //Map体系的集合间接的生成流
        Map<String,Integer> map = new HashMap<String, Integer>();
        Stream<String> keyStream = map.keySet().stream();
        Stream<Integer> valueStream = map.values().stream();
        Stream<Map.Entry<String, Integer>> entryStream = map.entrySet().stream();

        //数组可以通过Arrays中的静态方法stream生成流
        String[] strArray = {"hello","world","java"};
        Stream<String> strArrayStream = Arrays.stream(strArray);
      
      	//同种数据类型的多个数据可以通过Stream接口的静态方法of(T... values)生成流
        Stream<String> strArrayStream2 = Stream.of("hello", "world", "java");
        Stream<Integer> intStream = Stream.of(10, 20, 30);
    }
}
```



### 常见方法

| 方法名                                          | 说明                                                       |
| ----------------------------------------------- | ---------------------------------------------------------- |
| Stream<T> filter(Predicate predicate)           | 用于对流中的数据进行过滤                                   |
| Stream<T> limit(long maxSize)                   | 返回此流中的元素组成的流，截取前指定参数个数的数据         |
| Stream<T> skip(long n)                          | 跳过指定参数个数的数据，返回由该流的剩余元素组成的流       |
| static <T> Stream<T> concat(Stream a, Stream b) | 合并a和b两个流为一个流                                     |
| Stream<T> distinct()                            | 返回由该流的不同元素（根据Object.equals(Object) ）组成的流 |
| void forEach(Consumer action)                   | 对此流的每个元素执行操作                                   |
| long count()                                    | 返回此流中的元素数                                         |
| R collect(Collector collector)                  | 把结果收集到集合中                                         |
| Stream<R> map(Function mapper)                  | 映射每个元素到对应的结果                                   |

### Stream 流实战代码

#### 对字符串集合的处理

```Java
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class StreamTest {
    public static void main(String[] args) {
       List<String> list = Arrays.asList("A","B","A","C","D","E","B","C","D");
       List<String> collect = list
             // 开始 Stream 流
             .stream()
             // 去重操作
             .distinct()
             // 把流中的元素收集到 List 列表中
             .collect(Collectors.toList());
       // 遍历流中的每一个元素，并将其打印出来
       collect.stream().forEach(System.out::print);
       System.out.println();

       List<String> lowerStrList = list.stream()
             // 过略其中为 A 的元素，使其不参与后续操作
             .filter(str -> !str.equals("A"))
             // 跳过两个元素
             .skip(2)
             // 截取前五个数据
             .limit(5)
             // 对每个元素进行小写映射
             .map(String::toLowerCase)
             .collect(Collectors.toList());
       System.out.println(lowerStrList);
       // 统计流中的元素数量
       long count = lowerStrList.stream().count();
       System.out.println(count);
    }
}
```



#### 对数字集合的处理

```java
public class StreamTest2 {
    public static void main(String[] args) {
       List<String> list = Arrays.asList("5","9","3","4","2","7","1");
       
       List<Integer> digit = list.stream()
             // 将字符串元素转换为 Integer 类型的元素
             .map(Integer::parseInt)
             // 降序排序
             .sorted((x,y) -> y-x)
             .collect(Collectors.toList());
       int sum = digit.stream()
             // 转换为基本类型
             .mapToInt(Integer::intValue)
             .sum();
       System.out.println("求和："+sum);
       // List<Integer> 对象转换成基本类型的数组
       int arr[] = digit.stream()
             // 转换为基本类型 .mapToInt(Integer::intValue) 也可以使用这个语法
             .mapToInt((x)->x)
             .toArray();
       System.out.println("转换为数组："+Arrays.toString(arr));
    }
}
```

工具类 Collectors 提供了具体的收集方式

| 方法名                                                       | 说明                     |
| ------------------------------------------------------------ | ------------------------ |
| public static <T> Collector toList()                         | 把元素收集到 List 集合中 |
| public static <T> Collector toSet()                          | 把元素收集到 Set 集合中  |
| public static  Collector toMap(Function keyMapper,Function valueMapper) | 把元素收集到 Map 集合中  |

