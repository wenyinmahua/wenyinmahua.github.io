---
title: Docker 部署 MySQL
date: 2024-03-21
updated: 2024-07-10
tags: 
  - 实战
category: Docker
comments: true
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.e2mXH8yj7gqfjgXFvz9LfAHaEh?w=295&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
## Docker 部署 MySQL

### 1.准备文件

```
├── mysql
│   ├── conf
│       ├── mysql.conf # mysql 的配置文件
│   ├── init
│   	├── user.sql # 用户表的建表代码，里面还可以加上插入语句代码
└──
```

各文件内容如下：

mysql.conf 文件

```tex
[client]
default_character_set=utf8mb4
[mysql]
default_character_set=utf8mb4
[mysqld]
character_set_server=utf8mb4
collation_server=utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'
```

user.sql文件

```mysql
create database mahua
create table user
(
    id           bigint auto_increment comment '用户id' primary key,
    username     varchar(255) default '暂无昵称'  null comment '用户昵称',
    userAccount  varchar(255) not null unique comment '账号',
    userPassword varchar(255) default '52e218fc3f06b8eedafd3c36a8681953' not null comment '密码',
    userStatus   int    default 0  null comment '状态：0-正常，1-禁用',
    userRole     tinyint  default 0  null comment '用户角色：0-user/1- admin',
    profile      varchar(1024)    null,
    createTime   datetime     default CURRENT_TIMESTAMP  null comment '创建时间',
    updateTime   datetime     default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete     tinyint      default 0 null comment '是否删除',
)
    comment '用户表' engine = InnoDB;
```


### 2.创建网络

```powershell
docker create network mahua
```


### 3.创建并允许 MySQL 容器

上传上述文件夹到 Linux 虚拟机中 的 `root` 目录下
> 注意：2024 年 7 月 1 日 MySQL 最新版本变成 9.0 
```Bash
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -v ./mysql/data:/var/lib/mysql \
  -v ./mysql/conf:/etc/mysql/conf.d \
  -v ./mysql/init:/docker-entrypoint-initdb.d \
  -- network mahua \
  --restart=always\
  mysql:8.0
```



> 解读：
>
> - `docker run -d` ：创建并运行一个容器，`-d`则是让容器以后台进程运行
> - `--name mysql ` : 给容器起个名字叫`mysql`，当然也可以叫别的：`mysql-8.0` 
> - `-p 3306:3306` : 设置端口映射。
>   - **容器是隔离环境**，外界不可访问。但是可以将**宿主机端口**映射**容器内的端口**，当访问宿主机指定端口时，就是在访问容器内的端口了。
>   - 容器内端口往往是由容器内的进程决定，例如 MySQL 进程默认端口是3306，因此容器内端口一定是3306；而宿主机端口则可以任意指定，一般与容器内保持一致。
>   - 格式： `-p 宿主机端口:容器内端口`，示例中就是将宿主机的 3306 映射到容器内的 3306 端口
> - `-e TZ=Asia/Shanghai` : 配置容器内进程运行时的一些参数
>   - 格式：`-e KEY=VALUE`，KEY 和 VALUE 都由容器内进程决定
>   - 案例中，`TZ``=Asia/Shanghai`是设置时区；`MYSQL_ROOT_PASSWORD=123456`是设置MySQL默认密码
> - `-v ./mysql/data:/var/lib/mysql`：挂载`/root/mysql/data`到容器内的`/var/lib/mysql`目录
> - `-v ./mysql/conf:/etc/mysql/conf.d`：挂载`/root/mysql/conf`到容器内的`/etc/mysql/conf.d`目录（这个是MySQL配置文件目录）
> - `-v ./mysql/init:/docker-entrypoint-initdb.d` ：挂载`/root/mysql/init`到容器内的`/docker-entrypoint-initdb.d`目录（初始化的SQL脚本目录）
> - `-- network mahua`：将创建的 MySQL 容器加入 mahua 网络
> - `mysql` : 设置**镜像**名称，Docker会根据这个名字搜索并下载镜像
>   - 格式：`REPOSITORY:TAG`，例如`mysql:8.0`，其中`REPOSITORY`可以理解为镜像名，`TAG`是版本号
>   - 在未指定`TAG`的情况下，默认是最新版本，也就是`mysql:latest`



### 4. 提取 MySQL 中的数据

```powershell
docker exec -i mysql mysqldump -u root -p123456 mahua >  > /root/user.sql
```



>命令的各个部分的解释：
>
>- **`docker exec -i mysql`**: 使用 `docker exec` 命令在名为 `mysql` 的容器中运行一个命令。`-i` 选项表示以交互模式运行，这样我们可以从宿主机向容器发送输入。
>- **`mysqldump -u root -p123456 mydatabase`**: 使用 `mysqldump` 命令来导出数据库 `mydatabase`。`-u root` 表示使用 root 用户进行导出，`-p123456` 表示 root 用户的密码是 `123456`。
>- **`> /root/user.sql`**: 将导出的数据重定向到宿主机上的一个文件，例如 `/root/user.sql`。



如果想备份所有的数据库，那么执行下面的指令：

```powershell
docker exec -i mysql mysqldump -u root -p123456 --all-databases > /root/all_databases_backup.sql
```





### 5. 将生成的备份文件导入到新的 MySQL

```powershell
docker exec mysql mysql -u root -p123456 < /root/user.sql
```



