---
title: Docker 的安装与卸载
date: 2024-05-19 
updated: 2024-05-19
tags: 
  - 环境
category: Docker
comments: true
cover: https://tse2-mm.cn.bing.net/th/id/OIP-C.e2mXH8yj7gqfjgXFvz9LfAHaEh?w=295&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7
---
# Docker 的安装



## Docker 是什么

**Docker** 是一种开源的应用容器引擎，它允许开发者打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 或 Windows 机器上，也可以实现虚拟化。（“虚拟化”一词在这里是指一种轻量级的虚拟化技术，称为“容器化”。容器化是一种操作系统级别的虚拟化技术，它允许在单个操作系统实例上运行多个隔离的进程，每个进程看起来像是在自己的独立操作系统上运行一样。）

Docker 提供了一种轻量级的、可移植的、自包含的软件打包技术，使得应用程序及其运行环境可以被打包成一个 Docker 镜像。**镜像就像是应用程序的模板，可以通过这个模板快速创建出一个或多个 Docker 容器实例。**每个容器实例都像是一个独立的虚拟环境，拥有自己的文件系统、配置文件和进程空间，但它们共享宿主机的操作系统内核，这使得 Docker 容器比传统虚拟机更加高效和轻便。



Docker 的主要特点包括：

- **容器化**：将应用和其依赖打包在一个容器内，使得应用可以在任何支持 Docker 的环境中运行。
- **隔离性**：容器之间互相隔离，每个容器有自己的命名空间。
- **可移植性**：容器可以在不同的机器之间迁移而无需重新配置。
- **可复制性**：通过 Dockerfile 可以定义容器的构建过程，使得容器可以被轻易地复制和重建。
- **资源占用少**：与传统的虚拟机相比，Docker 容器启动速度快，资源消耗少。

Docker 使用场景广泛，包括但不限于开发环境搭建、持续集成与持续部署 (CI/CD)、微服务架构部署等。Docker 由 Docker Inc. 开发并维护，同时也得到了广泛的社区支持。



## 在 Linux 环境下安装 Docker



### 1.配置 Docker 的yum 库

> 注意：
>
> - 没有管理员全选需要加上 `sudo` 

安装 yum 工具

```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
```

安装成功后，执行命令，配置Docker的yum源（已更新为阿里云源）：

```Bash
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
```

更新yum，建立缓存

```Bash
yum makecache fast
```



### 2.安装 Docker

```Bash
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```



### 3.启动 Docker

```Bash
# 启动Docker
systemctl start docker

# 停止Docker
systemctl stop docker

# 重启
systemctl restart docker

# 设置开机自启
systemctl enable docker

# 执行docker ps命令，如果不报错，说明安装启动成功
docker ps
```



### 卸载 Docker

```bash
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    docker-selinux 
```



### 注意 Docker 需要配置镜像加速

找到合适的**镜像加速器地址**替换下面的地址即可

具体命令如下：

```Bash
# 创建目录
mkdir -p /etc/docker

tee /etc/docker/daemon.json <<-'EOF'
{
	# 需要挺欢的镜像加速地址
  "registry-mirrors": ["https://xxxx.mirror.aliyuncs.com"]
}
EOF

# 重新加载配置
systemctl daemon-reload

# 重启Docker
systemctl restart docker
```









































































