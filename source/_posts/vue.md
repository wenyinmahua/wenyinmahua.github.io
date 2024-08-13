---
title: Vue
date: 2023-09-10
updated: 2023-09-15
comments: true
category: Vue
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.Ve8s2wOzcP0qpU37-wQKlAHaEK?w=270&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---


# 不同页面的组件需要先引入后再使用

- 搭建页面
- 定义相关数据模型以及校验
- 绑定事件

# vue



@CrossOrigin注解支持跨域

在 `<script setup>` 语法中，Vue 会自动将响应式变量转化成普通的变量，因此你可以直接使用 `tableData` 而无需使用 `tableData.value`。但是，如果你需要修改 `tableData` 的值并希望视图更新，你仍然需要使用 `tableData.value`。

## 1.JavaScript-导入导出

JS提供的导入导出机制，可以实现按需导入。

```javascript
<!--showMessage.js-->
(1.export) function simpleMessage(msg){
    console.log(msg);
}
(1.export) function complexMessage(msg){
    console.log(new Date() +":" + msg);
}
<!--2-->
<!--export {simpleMessage as sm,complexMessage as cm}-->
<!--3-->
<!--export default {simpleMessage,complesMessage}-->
```

```html
<body>
	<div>
        <button id="btn">点我展示信息</button>
        <script src="showMessage.js"></script>
<!--注意这里的导入是将js文件中的所有的功能都导入进来，造成性能上的损失，解决方法：按需导入-->
        <script>
        	document.getElementById("btn").onclick = function(){
                complexMessage('nnbb');
            }
        </script>
    </div>
</body>
```

- 1.在js文件的函数前使用export完成导出，在html文件的script标签中使用import导入

```html
<script type="module">
	import {complexMessage} from './showMessage.js'
    import {导入的内容} from 'js文件所在的位置'
    document.getElementById("btn").onclick=function(){
        complexMessage('nnnnbbbbb');
    }
</script>
```

- 2.JS批量导出并起别名（导入的函数名过长）export {函数名1 as 别名1，函数名2 as 别名2}

```html
<script type="module">
	import {cm} from './showMessage.js'
    import {导入的内容} from 'js文件所在的位置'
    document.getElementById("btn").onclick=function(){
        cm('nnnnbbbbb');
    }
</script>
```

- 3.默认导出方式  export  default{simpleMessage,complesMessage}

```java
<script type="module">
	import messageMethods from './showMessage.js'
    import 别名(代表JS文件中默认导出的内容) from 'js文件所在的位置'
    document.getElementById("btn").onclick=function(){
        messageMethods.complexMessage('nnnnbbbbb');
    }
```

## 2.局部使用Vue

**Vue：**一款用于构建用户界面的渐进式的JavaScript框架。

### 2.1快速入门

- 在HTML页面中引入Vue模板(在线的js文件地址)
- 创建Vue程序的应用实例
- 准备元素(div)，并被Vue控制
- 准备数据
- 通过插值表达式渲染页面

```html
<div id="app">
    <!--被Vue控制的元素，其子元素都被Vue控制-->
    <!--使用插值表达式将vue的数据渲染到视图上展示-->
    <h1>{{msg}}</h1>
</div>
<script type="module">
    <!--导入vue线上模板-->
	import {createApp} from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'
    //使用createApp创造应用实例
    createApp({
        <!--参数列表-->
        data() {
            return {//返回的是一个JS对象
                <!--msg又叫做数据的签名-->
                msg:"hello Vue3"
            }
        }
    }).mount("#app")
    //链式的mount方法指定vue需要控制的元素的id属性
    
</script>
```

### 2.2vue中createApp格式

```vue
	import {createApp} from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'
    createApp({
        data() {
            return {
				msg:''
				list:[{
					键:"值",
					键:"值",
					键:"值"
				},{
					键:"值",
					键:"值",
					键:"值"
				},{
					键:"值",
					键:"值",
					键:"值"
				}]
            }
        },
		methods:{
			函数名: function(){函数体},
			函数名: function(){函数体}
			},
		mounted:function(){
			axios.get(url).then((result)=>{...}).catch((err)=>{...});
		}
    }).mount("#app")
```



## 3.常用指令

- 指令：HTML标签上带有 v-前缀的特殊属性，不同的指令具有不同的含义，可以实现不同的功能。

- 常用指令：

  |         指令          | 作用                                                |
  | :-------------------: | :-------------------------------------------------- |
  |         v-for         | 列表渲染，遍历容器的元素或对象的属性                |
  |        v-bind         | 为HTML标签绑定属性值，如设置href，css样式等         |
  | v-if/v-else-if/v-else | 条件性渲染某元素，判定为true时渲染，否则不渲染      |
  |        v-show         | 根据条件展示某元素，区别在于切换的是display属性的值 |
  |        v-model        | 在表单元素上创建双向数据绑定                        |
  |         v-on          | 为HTML标签绑定事件                                  |

> v-for
>
> - 作用：列表渲染，遍历容器的元素或对象的属性
> - 语法：v-for = "(item,index) in items"
>   - 参数说明
>     - items：为遍历的数组
>     - item：为遍历出来的元素
>     - index：为索引/下标，从0开始；可以省略：v-for = "item in items"
>
> - 遍历的数组，必须在data中定义；如果想让哪个标签循环展示多次，就在那个标签上使用v-for指令
>   ```html
>   <table>
>       <tr v-for = "(item,index) in items">
>       	<td>{{item.属性1}}</td>
>           <td>{{item.属性2}}</td>
>           <td>{{item.属性3}}</td>
>       </tr>
>   </table>
>   ```
>
> v-bind
>
> - 作用：动态为HTML标签绑定属性值，如设置href，src，style样式等
> - 语法：v-bind:属性名="属性值"
> - 简化：:属性名="属性值" 
>
> ```vue
> <a :href="url">黑马官网</a>
> 	return{
> 		url:'https://www.itheima.com'
> 	}
> ```
>
> v-if&v-show
>
> - 作用：用来控制元素的显示与隐藏
>
> - v-if
>   - 语法：v-if="表达式"，表达式值为true：显示；false：隐藏
>   - 其他：可以配合v-else-if/v-else进行链式调用条件判断
>   - 原理：基于条件控制，来控制创建和移除元素节点（渲染）
>   - 场景：要么显示，要么不显示，不频繁切换场景
> - v-show
>   - 语法：v-show="表达式"，表达式值为true：显示；false：隐藏
>   - 原理：基于CSS样式display来控制显示与隐藏
>   - 场景：频繁切换显示隐藏的场景
>
> ```vue
> <span v-if="age>0&&age<=18">未成年</span>
> <span v-if="age>18&&age<=60">中年人</span>
> <span v-else>老年人</span>
> 
> <span v-show="age>0&&age<=18">未成年</span>
> <span v-show="age>18&&age<=60">中年人</span>
> <span v-show="age>60">老年人</span>
> ```
>
> v-on
>
> - 作用：为HTML标签绑定事件
> - 语法：
>   - v-on:事件名="函数名"
>   - 简写为：@事件名="函数名"
>     - v-on使用的所有的函数都需要定义在methods中（与data同级）
>
> ```vue
> <botton v-on:click="函数名">点我有惊喜</bottun>
> <button @:click="函数名">点我有惊喜</button>
> ```
>
> v-model
>
> - 作用：在表单元素上使用，双向数据绑定，可以方便的获取或设置表单项数据
> - 语法：v-model="变量名"
>
> ```vue
> <input type="text" v-model="变量名"/>
> ```
>
> - v-model中绑定的变量，必须在data中定义。

## 4.vue的生命周期

- 生命周期：值一个对象从创建到销毁的整个过程
- 生命周期的八个阶段：每个阶段会自动执行一个生命周期方法（钩子方法），让开发者有机会在特定的阶段执行自己的代码。
- Vue生命周期典型的应用场景：在页面加载完毕时，发起异步请求，加载数据，渲染页面

|     状态      |  阶段周期  |
| :-----------: | :--------: |
| beforeCreate  |   创建前   |
|    created    |   创建后   |
|  beforeMount  |   载入前   |
|    mounted    |  挂载完成  |
| beforeUpdate  | 数据更新前 |
|    updated    | 数据更新后 |
| beforeUnmount | 组件销毁前 |
|    unmount    | 组件销毁后 |

比较常用的是mounted方法，mounted方法一般用来发送请求，拿到页面需要展示的数据，把这些数据渲染到页面上进行展示。mounted需要单独地声明，与data、methods同级。

```vue
createApp({
	mounted:function(){
		方法体；
	}
})
```

## 5.Axios

Axios：对原生的Ajax进行了封装，简化书写，快速开发。

- 引入Axios的JS文件
- 使用Axios发送请求，并获取相应结果
  - method：请求方式，GET/POST。。。
  - url：请求路径
  - data：请求参数

请求方式别名

- 为了方便起见，Axios已经为所有支持的请求方式提供了别名
- 格式：axios.请求方式(url [ , data [ , config ] ] )
  - axios.get(url).then((res)=>{...}).catch((err)=>{...})
  - axios.post(url,data).then((res)=>{...}).catch((err)=>{...})

### 1.GET请求

```html
<script src="https://unpkg.com/axios/dist/axios.min.js">
	axios({
        method:"GET",
        url:"https://mock.apifox.cn/m1/3083103-0-default/emps/list"
    }).then((result)=>{
        //成功回调函数
        //result代表服务器响应的所有数据，包含响应头，响应体，result.data代表的是接口响应的核心数据
        console.log(result.data);
    }).catch((err)=>{
        //失败回调函数
        alter(err);
    });
</script>
```

起别名的方式发送请求

```html
axios.get("https://mock.apifox.cn/m1/3083103-0-default/emps/list").then((result)=>{
	console.log(result.data);
}).catch((error) => {
	console.log(err);
});
```



### 2.POST请求

```vue
let article={
	title:"美好的一天",
	catgory:"生活",
	time:"2023-12-19",
	state:"草稿"
}
axios({
	method:"POST",
	url="http:/hostlocal:8080/article/add",
	data:article
}).then((result)=>{
	console.log(result.data);
}).catch((err)=>{
	console.log(err);
});
```

起别名的方式发送请求

```html
axios.post("http:/hostlocal:8080/article/add", article).then((result)=>{
	console.log(result.data);
}).catch((err)=>{
	console.log(err);
});
```

### 3.案例

```html
<div id="app">

        文章分类: <input type="text" v-model="searchConditions.category">

        发布状态: <input type="text" v-model="searchConditions.state">

        <button v-on:click="search">搜索</button>
        <br />
        <table border="1 solid" colspa="0" cellspacing="0">
            <tr>
                <th>文章标题</th>
                <th>分类</th>
                <th>发表时间</th>
                <th>状态</th>
                <th>操作</th>
            </tr>
            <tr v-for="(article,indec) in articleList">
                <td>{{article.title}}</td>
                <td>{{article.category}}</td>
                <td>{{article.time}}</td>
                <td>{{article.state}}</td>
                <td>
                    <button>编辑</button>
                    <button @click="clear">删除</button>
                </td>
            </tr>
        </table>
    </div>

    <script src="https://unpkh.com/axios/dist/axios.min.js"></script>
    <script type="module">
        import {createApp} from 'https://unpkh.com/vue@3/dist/vue.esm-browser.js';
        createApp({
            data(){
                return {
                    articleList:[],
                    searchConditions:{
                        category:'',
                        state:''
                    }
                }
            },
            methods:{
                search:function(){
                    axios.get("http://hostlocal:8080/article/search?category="+this.searchConditions.category+"&state=" +this.searchConditions.state)
                    .then((result)=>{
                        this.articleList=result.data;
                    }).catch((err)=>{
                        console.log(err);
                    })
                },
                clear:function(){
                    this.searchConditions.category='';
                    this.searchConditions.state='';
                }
            },
            mounted:function(){
                axios.get('http://hostlocal:8080/article/getALL').then((result)=>{
                    // console.log(result.data);
                    this.articleList = result.data;
                }).catch((err)=>{
                    console.log(err);
                });
            }
        }).mount("#app");
    </script>

```

# VUE工程化

创建Vue项目需要使用Vue提供的项目构建工具create-Vue（Vue官方提供的最新的脚手架工具，用于快速生成一个工程化的Vue项目）。

create-Vue可以提供统一的目录结构、本地调试、热部署、单元测试、集体打包等功能

vue工程化（create-Vue）需要**Node.js依赖环境**（跨平台的JS运行时环境，用来运行JS）

- 使用Vue工程化必须安装NodeJS
- nmp：Node Package Manager，是Node JS的软件包管理器，类似于与maven

<h5>一般来说，解析script中的代码是从上往下的，因此发送异步请求获取数据不一定要写在钩子方法中


## 1.Vue项目-创建

- 创建一个工程化Vue，需要执行命令：npm init Vue@latest
  - 执行上述指令，将会安装并执行creat-Vue，它是Vue官方的项目脚手架工具。
- 进入项目目录，执行命令安装当前项目的依赖：npm insatll
  - 创建项目以及安装依赖的过程，都是需要联网的。
- 使用VSCode打开当前创建的Vue项目：code .
- Vue启动：npm run dev
  - code中使用NPM脚本的：dev(vite)

> - 创建 Vue 项目：npm init vue@latest
> - 安装依赖：npm install
> - 启动：npm run dev



### vue页面解读

index.html是vue项目启动之后的默认首页，其中引入了main.js入口文件，而main.js文件中又引入了*.Vue文件。

**\*.Vue**是Vue项目中的组件文件，在Vue项目中也称为单文件组件（SFC，Single-File Components）。Vue的单文件组件会将一个组件的逻辑（JS），模板（HTML）和样式（style）封装到同一个文件里（\*.Vue）

```html
*.Vue文件的结构
<script>控制模板的数据及行为</script>
<temple>模板部分，由它生成HTML</temple>
<style>当前组件的CSS样式</style>
```

#### Vue引入Axios

```
npm install axios //控制台导入axios
import axios from 'axios'//*.vue文件中引入axios

npm install sass -D //CSS语言扩展包
```



## 2.Vue的API风格

- Vue的组件有两种不同的风格：**组合式API**和**选项式API**
  - 选项式API可以包含多个选项的对象来描述组建的逻辑关系，如data、methods、mounted等
  - 组合式API：在script标签中加上setup属性，使用import {onMounted, ref} from'vue'的API
- 在开发时推荐使用组合式API，更灵活

### 选项式API

```vue
<script>
    <!--为什么不是createApp？因为这个vue文件最终要导入main.js文件中，而main.js文件中声明了createApp，这里不需要再声明了-->
    export default{
        data() {
            return {
                count:0;
            }
		},
        methods: {
            increment:function(){
                this.count++;
            }
        },
        mounted:function(){
            console.log("Vue Start");
        }
    }
</script>
```

#### 在script中定义实体数据模型


```vue
data(){
    return {
        searchConditions:{
            category:'',
            state:''
        }
    }
},
```

### 组合式API

```vue
<script setup>
	import {onMounted,ref} from 'vue';
    //在组合式API中一般使用ref()把数据定义为响应式数据，即 const num = ref(0);
    const count = ref(0);
    function increment(){
        count.value++;
    }
    onMounted(()=>{
        console.log('Vue Start')
    })
</script>
```

#### 在script定义实体数据

```vue
    const searchConditions = ref({
      category: "",
      state:""
    })
```

#### 在script定义函数向后端发送请求

```vue
const 函数名 = function(){
	axios.get('url', {param:{...对象名.value}}).then(result=>{}).catch(err=>{})
						 <!--三个“.”代表解析对象-->
}
```



#### 组合式API解读

- script标签中的setup是一个标识，告诉Vue需要进行一些处理，让我们可以更简洁的使用组合式APUI；
- ref()：接收一个内部值，返回一个响应式ref对象，此对象只有一个指向内部值的属性value；
- onMounted()：是组合式API中的钩子方法，注册一个回调函数，在组建挂载完后执行。

<h3>在vue中引入其他的vue

- 在script中引入vue文件并起别名
- 在template标签中使用标签引入组件

```vue
<script setup>
    //引入当前目录下自定义的Api.vue组件，起别名为apiVue
    import apiVue from './Api.vue'
</script>
<template>
在APP.Vue页面上展示组件apiVue的内容
<apiVue/>
</template>
```

## 3.API文件夹以及拦截器

**接口调用**的js代码一般会封装到.js文件中，并且以函数的形式暴露给外部。

- 这里需要**同步等待**调用服务器的方法传回的结果。

- 这些JS代码会存放在src目录下的API文件夹中，（只有通过js文件函数调用时会出现下面的结果）。
  - 发送异步请求，需要等待服务器响应结果，但获取到服务器中的数据需要一段时间，结果什么时候能返回给请求就不清楚了，因此通过函数调用js文件中的异步请求时，得不到服务器响应的数据。（即调用函数时可能没有得到服务器返回的数据，函数将结果返回给变量时，服务器还没有给函数返回结果，因此函数返回给变量的是一个空的数据，导致变量存储的数据为空，这样浏览器无法展示数据）
  - 详细参考：[用代码详细讲解AJAX同步和异步 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/356232107)
  - 解决的方法就是同步等待服务器响应的结果，并返回：async...await
    - 使用async，await同步接收网络请求的结果
      - 同步等待await必须放在异步async函数中

<h4>js文件中写入相关的axios请求

```js
import axios from 'axios';
export async function articleGetAllService(){
    return await axios.get('http://hostlocal:8080/article/getAll')
    .then((result)=>{
      return result.data;
    }).catch((err)=>{
      alert(err);
    })
}

export async function articleSearchService(condition){
    return await axios.get('http://hostname:8080/article/search',{param:conditions})
    .then(result=>{
        return result.data;
    }).catch(err=>{
      console.log(err);
    })
}
```

<h4>vue文件中调用函数发送请求

```vue
<!--同步获取articleGetAllService的返回结果 async await -->
const getAllAtricle = async function(){
    let data = await articleGetAllService();
    articleList.data = data;
}
getAllAtricle();

const search = async function() {

    let data =  await articleSearchService({param:{...articleList.value}})
    articleList.value = data;
}
```

### 继续优化1

- 以上的请求都含有一个公共前缀：http://hostlocal:8080，当服务端端口改变时需要大量改变请求路径，这里可以抽出到一个变量中，方便修改。这里还要优化baseURL，参考本文档的 **跨域优化**

修改如下

```js
//request.js
import axios from 'axios';
//定义一个变量，记录公共的前缀
const baseUrl = 'http://hostlocal:8080';
const insatnce= axios.create({baseUrl});

export async function articleGetAllService(){
    return await insatnce.get('/article/getAll')
    .then((result)=>{
      return result.data;
    }).catch((err)=>{
      alert(err);
    })
}

export async function articleSearchService(condition){
    return await insatnce.get('/article/search',{param:condition})
    .then(result=>{
        return result.data;
    }).catch(err=>{
      console.log(err);
    })
}
```

### 继续优化2

- 以上函数中有含有then和catch函数，可以通过提供一个request.js请求工具，定制request的实例，然后暴露给外界使用，使用的是响应拦截器，存放在src的util文件夹下。
- 在请求或响应被then或catch处理前拦截它们
  - 浏览器会给服务器发送请求，服务器处理完毕的时候会给页面响应结果，浏览器与服务器经常会发生多次交互（请求和响应），如果每一次请求和响应都用共性的操作，那么就添加拦截器，对于请求和响应继续统一处理。
    - 在请求发出之前添加一个请求拦截器，成功：配置请求头（token）；失败：请求错误处理
    - 在响应到达之前添加一个响应拦截器，成功：响应数据处理；失败：响应错误提示

```js
//在request.js文件中定制请求的实例
import axios from 'axios';
const baseUrl = 'http://hostlocal:8080';
const instance= axios.create({baseUrl});

//添加响应拦截器
instance.interceptors.response.use(
    result=>{
        //http响应状态为2xx时会触发该函数
        return result.data;
    },
    err=>{
        //http响应状态非2xx时会触发该函数
        alert('服务异常');
        return Promise.reject(err);//异步的状态转换为失败的状态

    }
)
//将实例暴露给外边
export default instance;
```

```js
//在article.js文件中引入请求工具，自定义函数
import request from '@/util/request.js';

export function articleGetAllService(){
    return request.get('/article/getAll');
}

export function articleSearchService(condition){
    return request.get('/article/search',{param:condition});
}
```

- 由于添加的拦截器本身是异步的，因此在article.js文件中不需要再加上await来同步等待，return给vue文件后会由vue中的await进行处理（同步等待结果）。

### 继续优化3——axios响应拦截器

- 尽管已经优化到这种程度，但是后续还要读取result中的code响应码判断结果是否返回成功，这时可以将判断放入在拦截器中，后继在其他函数中不再判断result中的响应码，节省开发工作量

```js
//导入axios  npm install axios
import axios from 'axios';
import { ElMessage } from 'element-plus'
//定义一个变量,记录公共的前缀  ,  baseURL
const baseURL = '/api';//为了解决跨域请求
const instance = axios.create({baseURL})

//添加响应拦截器
instance.interceptors.response.use(
    result=>{
        if(result.data.code === 0){
            return result.data;
        }
        // alert(result.data.msg ? result.data.msg : '服务异常');
        ElMessage.error(result.data.msg ? result.data.msg : '服务异常');
        //异步操作的状态转换为失败
        return Promise.reject(result.data);
    },
    err=>{
        ElMessage.error('服务异常');
        return Promise.reject(err);//异步的状态转化成失败的状态
    }
)
export default instance;
```

## 4.数据模型的建立与绑定

### 在script中建立数据模型

```js
const registerData = ref({
    username:'',
    password:'',
    rePassword:''
})
// 注意：在script中修改响应式数据需要加上.value 如：registerData.value.username = "mahua";
```

在template中相关表单绑定数据模型，有两种方式

- **:model=“ModelData”**  双向绑定数据，用于输入表单
  - 表单项使用v-model="ModelData.property"绑定数据
- **:data=“ModelData”**   展示数据，不支持修改
  - 通过prop="property"绑定数据





# Element Plus的使用

**Element：**是饿了么团体研发的，基于Vue3，面向设计师和开发者的组件库。提供了组成页面的组件，快速搭建前端页面。

**组件：**组成网页的部件，例如：超链接、按钮、图片、表格、表单、分页条等。

## 快速入门

### 准备工作

1. 创建一个工程化的Vue项目

2. 参考官方文档，安装Element Plus组件库（在当前的工程目录下）：
   ```
   npm install element-plus --save
   ```

3. 在main.js即vue实例中引入Element Plus组件库（参照官方文档）
   ```js
   import { createApp } from 'vue'//导入Vue
   import ElementPlus from 'element-plus'//导入Element
   import 'element-plus/dist/index.css'//导入Element-plus样式
   import App from './App.vue'//导入App.vue
   
   const app = createApp(App)//创建应用实例
   
   app.use(ElementPlus)//使用element-plus
   app.mount('#app')//控制html元素
   ```

4. 在新建的button.vue文件黏贴官方文档的组件代码

5. 在App.vue中导入button.vue,在下方使用组件
   ```vue
   <script setup>
   import ButtonVue from './Button.vue'
   </script>
   
   <template>
     <ButtonVue/>
   </template>
   ```

   

### 制作组件

- 访问Element官方文档，复制组件代码，根据自己的需求调整

#### 分页组件的使用

```html
<style scoped> //scope代表仅在当前vue页面生效
    .el-p{
      margin-top: 20px;
      display: flex;//变成弹性盒子
      justify-content: flex-end;//向右对其
    }
</style>
```

- 关于分页组件字体为英文的解决方法：在main.js文件中导入下述内容
  ```js
  import locale from 'element-plus/dist/locale/zh-cn.js'
  app.use(ElementPlus,{locale})
  ```


# 开发案例注意事项


> 需要将 Element-Plus引入在App.vue
> axios 引入在utils下面的request.js

开发步骤：

- 搭建页面
- 绑定数据与事件（表单校验）
- 调用后台接口（src/api/xx.js封装、页面函数调用）

## 1.登录与注册

**登录与注册：**登录与注册的页面都写在Login.vue文件中，登录和注册又使用同一个数据模型

- 绑定数据，复用注册表单的数据模型
- 表单数据校验
- 登录函数

### 表单校验

1. 定义校验规则
   ```js
   const rules={
       username:[
           //校验规则，校验错误提示信息，校验触发时机
           {required:true,message:'请输入用户名',trigger:'blur'},//触发时机为失焦之后校验
           {min: 5,max: 16,message:'控制姓名为5-16个非空字符',trigger:'blur'}
       ],
       password:[
           {required:true,message:'请输入密码',trigger:'blur'},
           {min: 5,max: 16,message:'长度为5-16个非空字符',trigger:'blur'}
       ],
       rePassword:[
           {validator:checkRePassword,trigger:'blur'}//这里是下面的自定义校验规则
       ]
   }
   ```
   
2. 自定义校验规则，校验密码的函数
   ```js
   const checkRePassword = (rule,value,callback) =>{
       if(value ===""){
           callback(new Error('请输入确认密码'))
       }else if(value !== registedData.value.password){//注意这里要访问响应式数据需要加上“.value”
           callback(new Error('请确保两次密码一样'))
       }else{
           callback()
       }
   }
   ```

3. 将校验规则和表单绑定
   
   - el-from标签上通过rules属性，绑定校验规则
   - el-from-item标签上通过prop属性，指定校验项
   
   ```vue
   表单中加入如下：
   :rules="rules"
   表单项修改如下
   <el-form-item prop="username"/>
   ```





#### 注册接口的调用

在Login.vue文件调用vue.js中的请求函数

- 在src/api/user.js文件中封装登录调用接口的函数

  ```js
  //调用后台的接口需要发送异步请求，导入request.js请求工具，这里面存放在公共请求前缀
  import request from '@/utils/request.js'
  //提供调用注册接口的函数
  export const userRegisterService = (registerData)=>{//以json格式传递参数，但是要求是其他的格式
      //借助UrlSearchParams完成传递
      var params = new URLSearchParams()
      for(let key in registerData){
          params.append(key,registerData[key]);
      }
      //发送请求并返回响应数据
      return request.post('/user/register',params);
  }
  ```

- 在src/views/Login.vue页面中调用即可
  ```js
  <script>
  import {userRegisterService} from '@/api/user.js'
  const  register = async()=>{
      //这里的registerData是一个响应式对象，如果要获取值，需要.value
      let result = await userRegisterService(registerData.value);
      if(result.code === 0){
          alert(result.msg? result.msg: '注册成功');
      }else{
          alert('注册失败');
      }
  }
  </script>
  
  <el-button class="button" type="primary" auto-insert-space @click="register">
      注册
  </el-button>
  ```

#### 跨域问题

由于**浏览器**的**同源策略**限制，向不同源（不同协议、不同域名、不同端口）发送ajax请求会失败

- 解决方案：配置代理

  - 页面请求发送给前端服务然后发送给后端服务。修改request.js文件中的baseURL

    - **const baseURL = '/api'**   ==自动转变为==>   **http:/localhost:5173/api**

  - 在vite.config.js中配置代理

    ```js
    server: {				//做服务相关的配置
        proxy: {			//配置了代理
            'api': {		//请求路径中如果有'/api'，那么就做下面的处理
                target: 'http://localhost:8080', //api换源换成http://localhost:8080
               	changeOrigin: true,		//换源
                rewrite:(path)=>path.replace(/^\/api/,'')  //路径重写，把/api替换成空串
            }
        }
    }
    ```


## 2.Vue Router（路由）

- 路由：决定从起点到终点的路径的进程。

  - 在前端工程中，路由指的是根据不同的访问路径，展示不同组件的内容。

- Vue Router是Vue.js的官方路由

  - 安装Vue-Router ： **npm install vue-router@4**   //第四个版本

  - 在src/router/index.js中创建路由器，并导出
    ```js
    //导入需要的模板
    import {createRouter,createWebHistory} from 'vue-router'
    //导入组件
    import LoginVue from '@/views/Login.vue'
    import LayoutVue from '@/views/Layout.vue'
    //定义路由关系,定义一个数组，里面放着多个JS对象，分别表示路径和对应的组件
    const routes =[
        {path:'/login',component :LoginVue},
        {path:'/',component: LayoutVue}
    ]
    
    //创建路由器
    const router = createRouter({
        //路由模式，创建一个createWebHistory对象，用于记录路由的历史。
        history:createWebHistory(),
        //将路由关系传递进来，将routes数组传递给routes属性。
        routes:routes
    })
    
    //导出路由器，将创建的路由器对象导出，以便在其他地方使用。
    export default router
    ```

  - 在vue应用实例（app）中使用vue-router
    ```js
    //在main.js文件中
    import router from '@/router'
    app.use(router);
    ```

  - 声明router-view标签，展示组件内容

    ```vue
    <!--在App.vue中声明router-view标签-->
    <script setup></script>
    <template>
    <router-view></router-view>
    </template>
    <style scoped></style>
    ```

- vue-router使用路由器实现页面跳转(切换组件)

  ```vue
  <!--注意这一部分的router时使用路由函数得到路由-->
  import {useRouter} from 'vue-router'
  const router = useRouter();
  
  const login = async()=>{
      let result = await userLoginService(loginData.value);
      ElMessage.success(result.msg? result.msg : '登录成功');
  //指定跳转路径
      router.push('/');
  }
  ```

### 二级路由

- 在router/index.js文件中配置子路由
  ```js
  const routes =[
      {path:'/login',component: LoginVue},
      {path:'/',component: LayoutVue,redirect:'/article/manage',//redirect重定向
      children:[//配置子路由
          { path:'/article/category',component:ArticleCategoryVue},
          { path:'/article/manage',component:ArticleManageVue },
          { path:'/user/info',component:UserInfoVue },
          { path:'/user/avatar',component:UserAvatar },
          { path:'/user/resetPassword',component:UserPasswordVue },
      ]
  }
  ]
  ```

  

- 在Layout.vue文件中的内容展示区声明router-view标签
  ```vue
  <el-main>
      <!-- <div style="width: 1290px; height: 570px;border: 1px solid red;">
          内容展示区
      </div> -->
      <router-view></router-view>
  </el-main>
  ```

- 为菜单el-menu-item设置index属性，设置点击后的路由路径
  ```vue
  <el-menu-item index="/article/category" ></el-menu-item>
  ```

## 3.Pinia状态管理库以及持久化

#### Pinia是Vue的专属状态管理库，它允许跨组件或页面共享状态。

- 安装pinia：	
  ```shell
    npm install pinia
  ```


- 在vue应用实例（app）中使用pinia
  ```js
  //main.js
  import {createPinia} from 'pinia'
  const pinia = createPinia();
  app.use(pinia)
  ```

- 在src/stores/token.js文件中定义store
  ```js
  import {defineStore} from 'pinia';
  import {ref} from 'vue'
  /*
  	defineStore参数描述：
  		第一个参数：给状态起名，具有唯一性
  		第二个参数：函数，函数的内部可以定义该状态中的所有内容
  	defineStore返回值描述
  		返回的是一个函数，将来可以调用该函数，得到第二个参数返回的内容
  */
  export const useTokenStore = defineStore('token',()=>{
      const token = ref('');
      const setToken = (newToken) =>{
          token.value = newToken;
      }
      const removeToken = () =>{
          token.value = '';
      }
      return {
          token,setToken,removeToken
      }
  })

- 在组件中使用store
  ```vue
  <!--Login.vue,ArticleCategory.vue-->
  <!--在登录组件中使用store将生成的token保存起来-->
  import { useTokenStore } from '@/stores/token.js'
  const tokenStore = useTokenStore();
  //登录函数
  const login = async()=>{
      let result = await userLoginService(loginData.value);
      ElMessage.success(result.msg? result.msg : '登录成功');
      tokenStore.setToken(result.data);
      router.push('/');
  }
  ```

- 设置请求拦截器，保证每次请求都会带上jwt令牌的token
  ```js
  //添加请求拦截器
  import { useTokenStore } from '@/stores/token';
  instance.interceptors.request.use(
      (config)=>{
          //请求前回调
          //添加token
          let tokenStore = useTokenStore();
          if(tokenStore.token){
              config.headers.Authorization = tokenStore.token
          }
          return config;
      },
      (err)=>{
          //如果请求错误的回调
          Promise.reject(err);
      }
  )
  ```

### Pinia持久化插件-persist

- Pinia默认是内存存储，当刷新浏览器的时候会丢失数据。

- Persist插件可以将Pinia中的数据持久化的存储

  - 安装persist：   
  ```shell
  npm install pinia-persistedstate-plugin
  ```
  - 在Pinia中使用persist（在main.js中操作）
    ```js
    import {createPersistedState} from 'pinia-persistedstate-pligin'
    const persist = createPersistedState();
    pinia.use(persist);
    ```

  - 定义状态Store时指定持久化配置参数(token.js)
    ```js
    {
        presist:true;
    }
    ```

## 4.未登录统一处理

```js
instance.interceptors.response.use(
    result=>{
        if(result.data.code === 0){
            return result.data;
        }
        // alert(result.data.msg ? result.data.msg : '服务异常');
        ElMessage.error(result.data.msg ? result.data.msg : '服务异常');
        //异步操作的状态转换为失败
        return Promise.reject(result.data);
    },
    err=>{
        //判断响应状态码是否是401,如果是,则证明未登录,提示请登录,并跳转
        if(err.response.status === 401){
            ElMessage.error('请先登录');
            router.push('/login');
        }else{
            ElMessage.error('服务异常');
        }
        
        return Promise.reject(err);//异步的状态转化成失败的状态
    }
)
```

## 5.实现对话框标题不重复的复用,实现数据回写

- 定义title变量数据模型绑定在标题上，对于不同的操作赋予标题不同的值

```vue
<el-dialog v-model="dialogVisible" :title="title" width="30%"></el-dialog>
<el-button :icon="Edit" circle plain type="primary" @click="showDialog(row)"></el-button>
<!--传递的row代表所在行的所有的数据-->
const showDialog = async(row)=>{
    dialogVisible.value=true; 
    <!--标题修改-->
    title.value="编辑分类";
    <!--数据回写-->
    categoryModel.value.categoryName = row.categoryName;
    categoryModel.value.categoryAlias = row.categoryAlias;
    categoryModel.value.id = row.id;
}

<!--确认按钮复用-->
<el-button type="primary" @click="title =='添加分类'? addCategory() : updateCategory()" > 确认 </el-button>
```

## 6.富文本编辑器

文章内容需要使用到富文本编辑器，这里使用开源的富文本编辑器 Quill

官网地址： https://vueup.github.io/vue-quill/

**安装：**

```shell
npm install @vueup/vue-quill@latest --save
```

**导入组件和样式：**

```js
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css'
```

**页面长使用quill组件：**

```html
<quill-editor
  theme="snow"
  v-model:content="articleModel.content"
  contentType="html"
  >
</quill-editor>
```

**样式美化：**

```css
.editor {
  width: 100%;
  :deep(.ql-editor) {
    min-height: 200px;
  }
}
```

## 7.图片上传

使用el-upload上传图片，不需要通过request.js转发，直接转发给后端，但是还要解决浏览器的同源问题。

auto-upload:是否自动上传

action: 服务器接口路径

name: 上传的文件字段名

headers: 设置上传的请求头

on-success: 上传成功的回调函数

```html
import {
    Plus
} from '@element-plus/icons-vue'

<el-form-item label="文章封面">
    <el-upload class="avatar-uploader" 
               :show-file-list="false" 
               >
        <img v-if="articleModel.coverImg" :src="articleModel.coverImg" class="avatar" />
        <el-icon v-else class="avatar-uploader-icon">
            <Plus />
        </el-icon>
    </el-upload>
</el-form-item>
```

**注意：**

1. 由于这个请求时el-upload自动发送的异步请求，并没有使用request.js请求工具，由于浏览器的跨域问题，需要在请求的路径上加上/api, 这个时候请求代理才能拦截到这个请求，转发到后台服务器上

2. 要携带请求头，还需要导入pinia状态才可以使用

   ```js
   import { useTokenStore } from '@/stores/token.js'
   const tokenStore = useTokenStore();
   ```

3. 在成功的回调函数中，可以拿到服务器响应的数据，其中有一个属性为data，对应的就是图片在阿里云oss上存储的访问地址，需要把它赋值给articleModel的coverImg属性，这样img标签就能显示这张图片了，因为img标签上通过src属性绑定了articleModel.coverImg

   ```js
   //上传图片成功回调
   const uploadSuccess = (img) => {
       //img就是后台响应的数据，格式为：{code:状态码，message：提示信息，data: 图片的存储地址}
       articleModel.value.coverImg=img.data
   }
   ```

## 8.command的使用

command是下拉菜单中的一个事件

```vue      
import {useRouter} from 'vue-router'
const router = useRouter();
import { useTokenStore } from '@/stores/token.js';
const tokenStore = useTokenStore();
import {ElMessage,ElMessageBox} from 'element-plus'
const handleCommand = (command) =>{
    if(command ==='logout'){
        ElMessageBox.confirm(
        '确认退出登录吗？',
        '温馨提示',
        {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: 'warning',
        }
    )
        .then(() => {
            //1.清空pinia中存储的token以及个人信息
             tokenStore.removeToken;
             userInfoStore.removeInfo;
             //2.跳转登陆页面
             router.push('/login')
            ElMessage({
                type: 'success',
                message: '退出登录成功',
            })
        })
        .catch(() => {
            ElMessage({
                type: 'info',
                message: '取消退出登录',
            })
        }) 
        }else{
            router.push('/user/'+command)
        }
}

<!-- command：条目被点击后会触发，在事件函数上声明一个参数，接收条目对应的指令 -->
<el-dropdown placement="bottom-end" @command="handleCommand">
    <span class="el-dropdown__box">
        <el-avatar :src="userInfoStore.info.userPic ? userInfoStore.info.userPic : avatar" />
        <el-icon>
            <CaretBottom />
        </el-icon>
    </span>
    <template #dropdown>
        <el-dropdown-menu>
            			 <!-- command = '指令'-->
            <el-dropdown-item command="info" :icon="User">基本资料</el-dropdown-item>
            <el-dropdown-item command="avatar" :icon="Crop">更换头像</el-dropdown-item>
            <el-dropdown-item command="resetPassword" :icon="EditPen">重置密码</el-dropdown-item>
            <el-dropdown-item command="logout" :icon="SwitchButton">退出登录</el-dropdown-item>
        </el-dropdown-menu>
    </template>
</el-dropdown>
```