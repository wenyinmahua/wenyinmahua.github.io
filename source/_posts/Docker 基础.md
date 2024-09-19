---
title: Docker 基础
date: 2024-5-19 
updated: 2024-05-19
tags: 
  - 基础
category: Docker
comments: true
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.e2mXH8yj7gqfjgXFvz9LfAHaEh?w=295&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Docker 基础

> Docker 可以安装和部署软件

![image-20240727145727610](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240727145727610.png)

## 镜像&容器

### 如何理解镜像和容器的关系 。

Docker 中的镜像和容器的关系类似于 Java 中的类和对象的关系。

#### 类比说明

1. **类 (Class) vs. 镜像 (Image)**
   - **类**: 在 Java 中，类定义了对象的属性和行为。它是创建对象的模板或蓝图。
   - **镜像**: Docker 镜像是创建容器的基础。它包含了运行应用程序所需的所有文件、依赖项和配置信息。镜像是只读的，并且可以被分发和复用。
2. **对象 (Object) vs. 容器 (Container)**
   - **对象**: 在 Java 中，对象是类的一个实例。每个对象都有自己的状态（属性的值）和行为（方法）。
   - **容器**: Docker 容器是镜像的一个运行实例。容器有自己的文件系统、进程、网络配置等。每个容器都有自己的状态，可以独立运行。

#### 具体类比

- **创建**: 类通过构造函数创建对象；镜像通过 `docker build` 命令创建。
- **实例化**: 对象是类的实例；容器是镜像的实例。
- **状态**: 对象拥有自己的状态；容器也有自己的状态，包括文件系统上的任何更改。
- **可复用性**: 类可以被多个对象实例化；镜像可以被多次运行来创建多个容器。
- **修改**: 类不能被修改，但可以创建子类来扩展或覆盖方法；镜像不能被直接修改，但可以通过创建新的镜像来定制或扩展。
- **生命周期**: 对象有创建、使用和销毁的生命周期；容器同样有启动、运行、停止和销毁的生命周期。



在 Docker 中，使用 `Dockerfile` 定义一个镜像，该镜像可以包含运行一个 Web 服务器所需的所有文件和配置。可以基于这个镜像启动多个容器，每个容器都有自己的运行环境和状态。



## Docker 基础指令

| **命令**       | **说明**                       | **文档地址**                                                 |
| :------------- | :----------------------------- | :----------------------------------------------------------- |
| docker pull    | 拉取镜像                       | [docker pull](https://docs.docker.com/engine/reference/commandline/pull/) |
| docker push    | 推送镜像到DockerRegistry       | [docker push](https://docs.docker.com/engine/reference/commandline/push/) |
| docker images  | 查看本地镜像                   | [docker images](https://docs.docker.com/engine/reference/commandline/images/) |
| docker rmi     | 删除本地镜像                   | [docker rmi](https://docs.docker.com/engine/reference/commandline/rmi/) |
| docker run     | 创建并运行容器（不能重复创建） | [docker run](https://docs.docker.com/engine/reference/commandline/run/) |
| docker stop    | 停止指定容器                   | [docker stop](https://docs.docker.com/engine/reference/commandline/stop/) |
| docker start   | 启动指定容器                   | [docker start](https://docs.docker.com/engine/reference/commandline/start/) |
| docker restart | 重新启动容器                   | [docker restart](https://docs.docker.com/engine/reference/commandline/restart/) |
| docker rm      | 删除指定容器                   | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/rm/) |
| docker ps      | 查看容器                       | [docker ps](https://docs.docker.com/engine/reference/commandline/ps/) |
| docker logs    | 查看容器运行日志               | [docker logs](https://docs.docker.com/engine/reference/commandline/logs/) |
| docker exec    | 进入容器                       | [docker exec](https://docs.docker.com/engine/reference/commandline/exec/) |
| docker save    | 保存镜像到本地压缩文件         | [docker save](https://docs.docker.com/engine/reference/commandline/save/) |
| docker load    | 加载本地压缩文件到镜像         | [docker load](https://docs.docker.com/engine/reference/commandline/load/) |
| docker inspect | 查看容器详细信息               | [docker inspect](https://docs.docker.com/engine/reference/commandline/inspect/) |

![image-20240727150023979](https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/image-20240727150023979.png)

| docker run 参数  | 说明       |
| :--------------- | :--------- |
| --name           | 容器名称   |
| -p               | 端口映射   |
| -e               | 环境变量   |
| -v               | 数据卷配置 |
| --network        | 网络       |
| --restart=always | 自动启动   |



Docker 下载 MySQL 镜像，并创建和允许 MySQL 容器

```powershell
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=123456 \
  mysql
```

> -d: `-- detach`
>
> - 这个选项告诉 Docker 在后台模式下运行容器。
> - 在后台模式下，容器将在启动后立即返回控制台，不会阻塞终端窗口。
> - 这意味着命令执行完成后，你可以在终端继续执行其他命令，而容器将继续在后台运行。



>  MySQL版本在 2024 年 7 月份已经变成 9.0 了，如果需要 8.0 执行下面的指令即可

```PowerShell
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=123456 \
  mysql:8.0
```



> 注意：
>
> - 如果一台主机运行了两个 MySQL 容器，那么这两个 MySQL 容器的端口号都是 3306，不会出现端口冲突问题，但是主机的端口号不能一样，主机会出现端口冲突问题。
> - 在 Docker 中，即使多个容器内的应用都监听相同的端口，只要这些容器映射到宿主机的不同端口，它们是可以共存并且不会冲突的。
> - 容器内部监听相同的端口之所以不会发生冲突，是因为每个容器实际上都是一个隔离的环境。每个容器都有自己的网络栈和文件系统，这意味着它们可以在内部监听相同的端口，而不会相互干扰。这是因为容器内的网络栈和端口绑定仅对该容器可见。



Docker 容器开机自启

```powershell
docker update --restart=always [容器名|容器id]
```



Docker 查看运行中的容器

```powershell
docker ps
```



Docker 格式化查看运行中的容器

```powershell
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}\t{{.Names}}"
```



Docker 查看所有的容器（包含已停止的容器）

```powershell
docker ps -a
```



Docker 强制删除容器，以 MySQL 8.0  为例

```powershell
docker rm -f mysql:8.0  # 这里的 mysql:8.0  使容器名
```



Docker 进入 MySQL 容器

```powershell
docker exec -it mysql mysql -uroot -p123456
```



Docker 在执行`docker run`过程中下载的是**镜像（image）。**镜像中不仅包含了软件本身，还包含了其运行所需要的环境、配置、系统级函数库。因此它在运行时就有自己独立的环境，就可以跨系统运行，也不需要手动再次配置环境了。这套独立运行的隔离环境被称为**容器（container）**。

镜像的来源有两种：

- 基于官方基础镜像自己制作
- 直接去DockerRegistry下载



### Docker 给命令起别名

给常用Docker命令起别名，方便使用：

```PowerShell
# 修改/root/.bashrc文件
vi /root/.bashrc
# 内容如下：
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}\t{{.Names}}"'
alias dis='docker images'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
```

然后，执行命令使别名生效

```PowerShell
source /root/.bashrc
```







## 数据卷

**数据卷（volume）：**是一个虚拟目录，是**容器内目录**与**宿主机目录**之间映射的桥梁。

**挂载：**容器内目录和宿主机目录进行关联。



>`/var/lib/docker/volumes`目录就是默认的存放所有容器数据卷的目录，其下再根据数据卷名称创建新目录，格式为`/数据卷名/_data`。



### Docker 数据卷命令

| **命令**              | **说明**             | **文档地址**                                                 |
| :-------------------- | :------------------- | :----------------------------------------------------------- |
| docker volume create  | 创建数据卷           | [docker volume create](https://docs.docker.com/engine/reference/commandline/volume_create/) |
| docker volume ls      | 查看所有数据卷       | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/volume_ls/) |
| docker volume rm      | 删除指定数据卷       | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/volume_prune/) |
| docker volume inspect | 查看某个数据卷的详情 | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/volume_inspect/) |
| docker volume prune   | 清除数据卷           | [docker volume prune](https://docs.docker.com/engine/reference/commandline/volume_prune/) |

> 注意：
>
> - 容器与数据卷的挂载要在创建容器时配置，对于创建好的容器，是不能设置数据卷的。而且**创建容器的过程中，数据卷会自动创建**。定义容器未设置容器名，会自动生成匿名卷名字，一串hash值（如：29524ff09715d3688eae3f99803a2796558dbd00ca584a25a4bbc193ca82459f）。
> - 每一个不同的镜像，将来创建容器后内部有哪些目录可以挂载，可以参考 DockerHub 对应的页面



创建容器并指定数据卷，注意通过 -v 参数来指定数据卷 

```powershell
docker run -d \
	--name nginx \
	-p 3306:3306 \
	-e TZ=Asia/Shanghai \
  	-e MYSQL_ROOT_PASSWORD=123456 \
	-v mysql:/var/lib/mysql # 会被识别为一个数据卷叫mysql，运行时会自动创建这个数据卷
	nginx
```



### 挂载本地目录或文件

在很多情况下，直接将容器目录与宿主机指定目录挂载。挂载语法：

```Bash
# 挂载本地目录
-v 本地目录:容器内目录
# 挂载本地文件
-v 本地文件:容器内文件
```

>注意：
>
>- 本地目录或文件必须以 `/` 或 `./`开头，如果直接以名字开头，会被识别为数据卷名而非本地目录名。
>- 本地挂载的数据卷在 `/var/lib/docker/volumes`，如 `/var/lib/docker/volumes/mysql/data_`



## 镜像

> 如果想部署一个 java 项目，需要将其打包为一个镜像。



### 镜像结构

镜像中包含了程序运行需要的系统函数库、环境、配置、依赖。

自定义镜像本质就是依次准备好程序运行的基础环境、依赖、应用本身、运行配置等文件，并且打包而成。

镜像文件不是随意堆放的，而是按照操作的步骤分层叠加而成，每一层形成的文件都会单独打包并标记一个唯一id，称为**Layer**（**层**）。如果构建时用到的某些层其他人已经制作过，就可以直接拷贝使用这些层，而不用重复制作。



<img src="https://web-tlias-mmh.oss-cn-beijing.aliyuncs.com/img/download_image.png" alt="Java 项目的镜像结构" />



> 打包镜像的步骤：
>
> - 安装并配置JDK
> - 拷贝jar包
> - 配置启动脚本
>
> 上述步骤中的每一次操作其实都是在生产一些文件（系统运行环境、函数库、配置最终都是磁盘文件），所以**镜像就是一堆文件的集合**。



### Dockerfile

由于制作镜像的过程中，需要逐层处理和打包，比较复杂，所以Docker就提供了自动打包镜像的功能。只需要将打包的过程，每一层要做的事情用固定的语法写下来，交给Docker去执行即可。

而这种记录镜像结构的文件就称为**Dockerfile**，其常用的语法如下：

| **指令**       | **说明**                                     | **示例**                     |
| :------------- | :------------------------------------------- | :--------------------------- |
| **FROM**       | 指定基础镜像                                 | `FROM centos:6`              |
| **ENV**        | 设置环境变量，可在后面指令使用               | `ENV key value`              |
| **COPY**       | 拷贝本地文件到镜像的指定目录                 | `COPY ./xx.jar /tmp/app.jar` |
| **RUN**        | 执行Linux的shell命令，一般是安装过程的命令   | `RUN yum install gcc`        |
| **EXPOSE**     | 指定容器运行时监听的端口，是给镜像使用者看的 | EXPOSE 8080                  |
| **ENTRYPOINT** | 镜像中应用的启动命令，容器运行时调用         | ENTRYPOINT java -jar xx.jar  |



### 制作java镜像

准备好一个 `jar` 包以及一个 `Dockerfile `

```
├── demo
│   ├── docker-demo.jar
│   ├── Dockerfile
└──
```

Dockerfile 内容

```Dockerfile
# 基础镜像
FROM openjdk:11.0-jre-buster
# 设定时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# 拷贝jar包
COPY docker-demo.jar /app.jar
# 入口
ENTRYPOINT ["java", "-jar", "/app.jar"]
```



> 这段 Dockerfile 用于构建一个 Docker 镜像，该镜像基于 `openjdk:11.0-jre-buster` 镜像，并且配置了运行一个 Java 应用程序所需的环境。
>
> 1. `FROM openjdk:11.0-jre-buster`
>    - 指定基础镜像为 `openjdk:11.0-jre-buster`。
>
> 2. `ENV TZ=Asia/Shanghai`
>    - 设置环境变量 `TZ` 为 `Asia/Shanghai`，用于指定时区。
>
> 3. `RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone`
>    - 使用 `RUN` 指令执行命令，该命令创建了一个软链接，将 `/usr/share/zoneinfo/Asia/Shanghai` 链接到 `/etc/localtime`，并将时区名称写入 `/etc/timezone` 文件。这确保了容器内的时区设置为上海时区。
>
> 4. `COPY docker-demo.jar /app.jar`
>    - 使用 `COPY` 指令将本地目录中的 `docker-demo.jar` 文件复制到镜像的 `/` 目录下，并重命名为 `app.jar`。这意味着 Java 应用程序被打包成了一个名为 `docker-demo.jar` 的 JAR 文件，并且在构建镜像时会被复制到容器中。
>
> 5. `ENTRYPOINT ["java", "-jar", "/app.jar"]`
>    - 使用 `ENTRYPOINT` 指令指定容器启动时运行的命令。这里指定了当容器启动时，应该运行 `java -jar /app.jar` 命令。这意味着容器启动时会运行 `/app.jar` 这个 Java 应用程序。
>
> #### 总结
>
> 这段 Dockerfile 的作用是：
>
> - 从 `openjdk:11.0-jre-buster` 镜像开始构建。
> - 设置容器内的时区为上海时区。
> - 将 `docker-demo.jar` 文件复制到镜像中，并重命名为 `app.jar`。
> - 配置容器启动时自动运行 `java -jar /app.jar` 命令。
>
> 当你使用这个 Dockerfile 构建镜像并运行容器时，容器将使用上海时区，并且自动运行 Java 应用程序。



### 构建镜像

上传上述文件夹到 `/root` 目录下

```powershell
docker build -t docker-demo:1.0 /root/demo
```

> 命令说明：
>
> - `docker build `: 就是构建一个docker镜像
> - `-t docker-demo:1.0` ：`-t`参数是指定镜像的名称（`repository`和`tag`）
> - `/root/demo` : 最后的点是指构建时 Dockerfile 所在路径



或者进入镜像目录，执行：

```powershell
docker build -t docker-demo:1.0 .
```



查看镜像列表：

```powershell
docker images 
# 可以发现镜像列表中出现了 docker-demo 容器
```



### 创建并运行容器

```powershell
docker run -d --name docker-demo -p 8080:8080 docker-demo:1.0
```



## 网络

在 Docker 中，每个容器都有自己的 ip 地址。容器的网络IP其实是一个虚拟的IP，其值并不固定与某一个容器绑定，如果在开发时写死某个IP，而在部署时很可能MySQL容器的IP会发生变化，连接会失败。**借助于docker的网络功能来解决这个问题。**

> 在某些情况下，容器的 IP 地址可能会发生变化：
>
> 1. **容器被删除**:
>    - 当删除一个容器时，与该容器关联的 IP 地址将被释放。
>    - 如果随后启动另一个容器，它可能会获得这个已释放的 IP 地址。
> 2. **使用自定义网络**:
>    - 如果使用自定义的 Docker 网络（例如 `overlay` 或 `macvlan` 网络），你可以为容器手动分配 IP 地址。
>    - 在这种情况下，可以通过 `--ip` 参数为容器指定一个静态 IP 地址。



> 注意
>
> - 容器的 IP 地址通常在容器首次启动时分配，并且在容器的生命周期内保持不变。（容器的 IP 地址不会在容器停止和启动之间发生变化）
> - 如果容器被删除，其 IP 地址将被释放，可以被其他容器使用。
> - 如果使用自定义网络并为容器手动分配 IP 地址，那么 IP 地址将由创建者控制。
> > 这也就意味着在线上部署时，各个容器的 IP 地址可能与本地部署时的 IP 地址不一致，而在某个容器与其他容器通信需要 IP地址，如果没有网络，则 IP 地址变换后导致容器启动失败。



### Docker 网络的常见命令

| **命令**                  | **说明**                 | **文档地址**                                                 |
| :------------------------ | :----------------------- | :----------------------------------------------------------- |
| docker network create     | 创建一个网络             | [docker network create](https://docs.docker.com/engine/reference/commandline/network_create/) |
| docker network ls         | 查看所有网络             | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/network_ls/) |
| docker network rm         | 删除指定网络             | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/network_rm/) |
| docker network prune      | 清除未使用的网络         | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/network_prune/) |
| docker network connect    | 使指定容器连接加入某网络 | [docs.docker.com](https://docs.docker.com/engine/reference/commandline/network_connect/) |
| docker network disconnect | 使指定容器连接离开某网络 | [docker network disconnect](https://docs.docker.com/engine/reference/commandline/network_disconnect/) |
| docker network inspect    | 查看网络详细信息         | [docker network inspect](https://docs.docker.com/engine/reference/commandline/network_inspect/) |



Docker 创建一个网络

```powershell
docker network create mahua
```



使已创建的 MySQL 容器加入网络 `mahua`，并起别名叫 `db` （db 这里指的是容器名）

```powershell
docker network connect mahua mysql --alias db
```

> 小Tip：
>
> - Docker 自定义网络可以通过容器名相互访问：
>   - ping mysql
>
> - 在自定义网络中，可以给容器起多个别名，默认的别名是容器名本身；
> - 在同一个自定义网络中的容器，可以通过别名互相访问。





## DockerCompose

> **DockerCompose：** 实现**多个相互关联的Docker容器的快速部署**。它允许用户通过一个单独的 docker-compose.yml 模板文件（YAML 格式）来定义一组相关联的应用容器。

docker-compose文件中可以定义多个相互关联的应用容器，每一个应用容器被称为一个服务（service）。service就是在定义某个应用的运行时参数，因此与`docker run`参数非常相似。

对比如下：

| **docker run 参数** | **docker compose 指令** | **说明**   |
| :------------------ | :---------------------- | :--------- |
| --name              | container_name          | 容器名称   |
| -p                  | ports                   | 端口映射   |
| -e                  | environment             | 环境变量   |
| -v                  | volumes                 | 数据卷配置 |
| --network           | networks                | 网络       |



举例来说，用docker run部署MySQL的命令如下：

```Bash
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=123 \
  -v ./mysql/data:/var/lib/mysql \
  -v ./mysql/conf:/etc/mysql/conf.d \
  -v ./mysql/init:/docker-entrypoint-initdb.d \
  --network mahua
  mysql
```

如果用`docker-compose.yml`文件来定义，就是这样：

```YAML
version: "3.8"

services:
  mysql:
    image: mysql
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: 123456
    volumes:
      - "./mysql/conf:/etc/mysql/conf.d"
      - "./mysql/data:/var/lib/mysql"
    networks:
      - new
networks:
  new:
    name: mahua
```





### 示例

mysql + demo（自己写的应用程序） + Nginx

#### 编写 docker-compose.yml 文件

```YAML
version: "1.1"

services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: 123456
    volumes:
      - "./mysql/conf:/etc/mysql/conf.d"
      - "./mysql/data:/var/lib/mysql"
      - "./mysql/init:/docker-entrypoint-initdb.d"
    networks:
      - mahua-net
      
# 自己的应用服务   
  demo: 
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: demo
    ports:
      - "8080:8080"
    networks:
      - mahua-net
    depends_on:   # 在 mysql 容器启动后启动（依赖于 mysql）。
      - mysql
      
  nginx:
    image: nginx
    container_name: nginx
    ports:
      - "8000:8000"
    volumes:
      - "./nginx/nginx.conf:/etc/nginx/nginx.conf"
      - "./nginx/html:/usr/share/nginx/html"
    depends_on:
      - demo
    networks:
      - mahua-net
networks:
  mahua-net:
    name: mahua # 别名
```



#### 部署项目

编写好docker-compose.yml文件，就可以部署项目了。

##### 基础命令

```Bash
docker compose [OPTIONS] [COMMAND]
```

其中，OPTIONS 和 COMMAND 都是可选参数。

OPTIONS 比较常见的有：

| **参数或指令** | **说明**                                                     |
| :------------- | :----------------------------------------------------------- |
| -f             | 指定 compose 文件的路径和名称                                |
| -p             | 指定 project 名称。project 就是当前 compose 文件中设置的多个 service 的集合，是逻辑概念 |



COMMAND 比较常见的有：

| **参数或指令** | **说明**                     |
| :------------- | :--------------------------- |
| up             | 创建并启动所有service容器    |
| down           | 停止并移除所有容器、网络     |
| ps             | 列出所有启动的容器           |
| logs           | 查看指定容器的日志           |
| stop           | 停止容器                     |
| start          | 启动容器                     |
| restart        | 重启容器                     |
| top            | 查看运行的进程               |
| exec           | 在指定的运行中容器中执行命令 |



##### 部署

启动所有服务, -d 参数是后台启动

```powershell
docker compose up -d
```



查看镜像

```powershell
docker compose images
```



显示当前运行的容器列表。

```powershell
docker compose ps
```



登录 MySQL 容器

```powershell
docker compose exec mysql mysql -u root -p
```



强制停止容器(发送 SIGKILL 信号给容器，强制关闭容器。)

```powershell
docker compose kill [容器名|容器ID]
```



暂停容器：

```powershell
docker compose unpause [容器名|容器ID]
```



恢复之前被暂停的容器：

```powershell
docker compose unpause [容器名|容器ID]
# 或
docker unpause $(docker ps -a -q --filter "name=容器名")
```

> `docker ps -a -q --filter "name=mysql"`:
>
> - `docker ps -a` 列出所有容器（包括正在运行和已停止的）。
> - `-q` 只输出容器的 ID。
> - `--filter "name=mysql"` 过滤出名称为 `mysql` 的容器。****



