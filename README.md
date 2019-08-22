---
layout: post
title: "CI/CD Pipeline as Code"
date: 2019-08-22 15:06:15
image: '/assets/img/'
description:  '自动构建 CI/CD 环境 Pipeline as Code'
main-class:  'tools'
color: 
tags: 
 - tools
 - script
categories:
 - tools
twitter_text:  "auto deploy CI/CD env"
introduction: "auto deploy CI/CD env"
---


# 前言


根据需求，这里通过组合 **[VirtualBox][virtualbox]，[Vagrant][vagrant]，[gogs][gogs]** 和 **[Minikube][minikube]** 构建出一个一键部署的 CI/CD 本地测试环境


> **Tip:** 当前使用的版本为 **minikube v1.2.0** 、 **kubectl v1.15.0** 、**virtualbox 5.2.24** 和 **vagrant 2.2.2**

---

## 设计思路

* 开发，测试，生产三个环境
* 极简的布署过程(尽量做到开袋即食)
* 充分使用容器的灵活与快捷
* 尽量让常用操作自动化完成

## 当前版本解决了上一个版本存在的以下几点不足

* 开发测试生产环境的流水线打通
* 实现了不同环境在流水线构建过程中将文件整体做为实参传递的机制
* 通过 DockerHub 的国内镜像网站加速镜像的下载过程
* 添加了代码的版本管理功能，并且提供了其 web 管理后台
* 添加了提交代码后的主动触发构建机制
* 实现了 Pipeline as Code
* 加入了构建过程中的人为确认环节


# 部署方法


## OS环境

~~~
nothing@pc:~$ hostnamectl 
   Static hostname: pc
         Icon name: computer-laptop
           Chassis: laptop
        Machine ID: da43bae367934cabac43b08864bb91f9
           Boot ID: 72636b14dc414045989163692df5e6e8
  Operating System: Ubuntu 18.10
            Kernel: Linux 4.18.0-25-generic
      Architecture: x86-64
nothing@pc:~$ 
~~~

**Ubuntu 18.10** 下测试没问题

>**Note:** 其它Linux 版本没有直接测试, 但是理论上能正常运行 **virtualbox 5.2.24** 和 **vagrant 2.2.2** 的 Linux 环境也没问题

## 基础软件依赖

需要系统中已经安装如下两个软件

* **virtualbox 5.2.24**
* **vagrant 2.2.2**

~~~
nothing@pc:~$ virtualbox --help | head 
Oracle VM VirtualBox Manager 5.2.24
(C) 2005-2019 Oracle Corporation
All rights reserved.

Usage:
  --startvm <vmname|UUID>    start a VM by specifying its UUID or name
  --separate                 start a separate VM process
  --normal                   keep normal (windowed) mode during startup
  --fullscreen               switch to fullscreen mode during startup
  --seamless                 switch to seamless mode during startup
nothing@pc:~$ vagrant version
Installed Version: 2.2.2
Latest Version: 2.2.5
 
To upgrade to the latest version, visit the downloads page and
download and install the latest version of Vagrant from the URL
below:

  https://www.vagrantup.com/downloads.html

If you're curious what changed in the latest release, view the
CHANGELOG below:

  https://github.com/hashicorp/vagrant/blob/v2.2.5/CHANGELOG.md
nothing@pc:~$ 
~~~


## 安装方法

~~~
git clone https://github.com/wilmosfang/cicd.git
cd cicd
vagrant up
~~~


## 目录结构


~~~
nothing@pc:~/vagrant/cicd$ tree -L 3 . 
.
├── init.bash
├── package
│   ├── containerd.io-1.2.6-3.3.el7.x86_64.rpm
│   ├── docker-ce-19.03.1-3.el7.x86_64.rpm
│   ├── docker-ce-cli-19.03.1-3.el7.x86_64.rpm
│   ├── docker-ce.repo
│   ├── gogs.zip
│   ├── jenkins-2.176.2-1.1.noarch.rpm
│   ├── jenkins.repo
│   ├── jenkins.zip
│   ├── kubectl
│   └── minikube
├── test_file
│   ├── assets
│   │   ├── assets
│   │   ├── Dockerfile
│   │   ├── Jenkinsfile
│   │   └── README.md
│   ├── dynamic_web
│   │   ├── Dockerfile
│   │   ├── Jenkinsfile
│   │   ├── README.md
│   │   └── server.js
│   ├── dy.zip
│   └── static.zip
└── Vagrantfile

5 directories, 21 files
nothing@pc:~/vagrant/cicd$
~~~

主要由三部分构成

### Vagrantfile

用于对虚拟机的配置进行定义

### init.bash 

用作虚拟机的初始化

* 基础环境初始化
* 安装基础包 (java jenkins docker kubectl minikube git)
* 配置 jenkins
* 配置 Docker 镜像加速
* 生成单机 k8s 集群
* 拉取基础镜像
* 创建与初始化开发测试生产三个运行环境(并且提供三个环境的访问地址)
* 构建与初始化代码版本管理运行环境

**init.bash** 被 **Vagrantfile** 调用

### package

(由于构建过程中网速实在太慢)

为了加速构建过程，里面下载了离线的安装包

~~~
./package/
├── containerd.io-1.2.6-3.3.el7.x86_64.rpm
├── docker-ce-19.03.1-3.el7.x86_64.rpm
├── docker-ce-cli-19.03.1-3.el7.x86_64.rpm
├── docker-ce.repo
├── gogs.zip
├── jenkins-2.176.2-1.1.noarch.rpm
├── jenkins.repo
├── jenkins.zip
├── kubectl
└── minikube

0 directories, 10 files
~~~

* docker 安装包 (也附上了 docker 的库文件)
* jenkins 安装包 (也附带上了 jenkins 的库文件)
* jenkins 插件
* gogs 配置
* kubectl  命令 
* minikube 命令

**package** 被 **init.bash** 调用

## 其它

**test_file** 在此只是测试 demo，对项目的构建不起作用

# 使用


## 访问 jenkins 

安装完成后，可以直接访问 jenkins 

链接 **`http://10.1.0.165:8080/view/CI_CD/`**

![cicd](/assets/img/cicd/cicd13.png)

## 静态资源的发布

![cicd](/assets/img/cicd/cicd14.png)

![cicd](/assets/img/cicd/cicd03.png)

直接上传 zip 包，和对应的发布环境，点构建

## 静态资源的 pipeline 构建

第一步提示上传文件

![cicd](/assets/img/cicd/cicd15.png)

进入后选择要构建的文件

![cicd](/assets/img/cicd/cicd16.png)

在测试环境构建完成和STAGE环境构建完成后都会提示确认

都需要人工确认

![cicd](/assets/img/cicd/cicd17.png)

![cicd](/assets/img/cicd/cicd18.png)

Build 完成后点击步骤进入是可以跟随链接提示查看构建效果的

![cicd](/assets/img/cicd/cicd19.png)

经历了所有环节，成功构建的效果

![cicd](/assets/img/cicd/cicd20.png)

## 静态资源的 pipeline as code

首先拉取代码，做些修改，再上传

~~~
[vagrant@auto ~]$ git clone  http://10.1.0.165:10080/root/assets.git
正克隆到 'assets'...
remote: Enumerating objects: 29, done.
remote: Counting objects: 100% (29/29), done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 29 (delta 3), reused 0 (delta 0)
Unpacking objects: 100% (29/29), done.
[vagrant@auto ~]$ cd assets/
[vagrant@auto assets]$ ls
assets  Dockerfile  Jenkinsfile  README.md
[vagrant@auto assets]$ echo new_css.css > assets/css/new_css.css
[vagrant@auto assets]$ cat assets/css/new_css.css
new_css.css
[vagrant@auto assets]$ git add . 
[vagrant@auto assets]$ git commit -m "for test"

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: unable to auto-detect email address (got 'vagrant@auto.(none)')
[vagrant@auto assets]$ git config --global user.email "yyghdfz@163.com"
[vagrant@auto assets]$ git config --global user.name "root"
[vagrant@auto assets]$ git commit -m "for test"
[master 6ffc19f] for test
 1 file changed, 1 insertion(+)
 create mode 100644 assets/css/new_css.css
[vagrant@auto assets]$ git push 
warning: push.default 未设置，它的默认值将会在 Git 2.0 由 'matching'
修改为 'simple'。若要不再显示本信息并在其默认值改变后维持当前使用习惯，
进行如下设置：

  git config --global push.default matching

若要不再显示本信息并从现在开始采用新的使用习惯，设置：

  git config --global push.default simple

参见 'git help config' 并查找 'push.default' 以获取更多信息。
（'simple' 模式由 Git 1.7.11 版本引入。如果您有时要使用老版本的 Git，
为保持兼容，请用 'current' 代替 'simple' 模式）

Counting objects: 8, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (5/5), 420 bytes | 0 bytes/s, done.
Total 5 (delta 2), reused 0 (delta 0)
Username for 'http://10.1.0.165:10080': root
Password for 'http://root@10.1.0.165:10080': 
To http://10.1.0.165:10080/root/assets.git
   4a38670..6ffc19f  master -> master
[vagrant@auto assets]$ 
~~~


Pipeline 会自动触发构建操作

并且在需要人工确认的地方进行等待

![cicd](/assets/img/cicd/cicd21.png)

![cicd](/assets/img/cicd/cicd22.png)

人工确认之前，可以跟随构建结果链接查看变更后的效果

![cicd](/assets/img/cicd/cicd23.png)

查看变更是否达到预期

![cicd](/assets/img/cicd/cicd25.png)

经历了所有环节，成功构建的效果

![cicd](/assets/img/cicd/cicd24.png)


## 动态资源的发布

直接上源码 zip 包，和对应的发布环境，点构建

![cicd](/assets/img/cicd/cicd26.png)

![cicd](/assets/img/cicd/cicd05.png)

这里需要说明的是，我对 java(和 Prevayler) 不熟悉，就没有用来研究这个了，用了 nodejs 替代动态 web 的效果

## 动态资源的 pipeline as code

首先拉取代码，做些修改，再上传

~~~
[vagrant@auto ~]$ git clone http://10.1.0.165:10080/root/dynamic_web.git 
正克隆到 'dynamic_web'...
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 12 (delta 4), reused 0 (delta 0)
Unpacking objects: 100% (12/12), done.
[vagrant@auto ~]$ cd dynamic_web/
[vagrant@auto dynamic_web]$ ls
Dockerfile  Jenkinsfile  README.md  server.js
[vagrant@auto dynamic_web]$ cat server.js 
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.write("abc");
  response.write(" | ");
  response.write(process.env.HOSTNAME);
  response.end(": Hello World!  |v3| \n");
};
var www = http.createServer(handleRequest);
www.listen(8080);
[vagrant@auto dynamic_web]$ vim server.js 
[vagrant@auto dynamic_web]$ cat server.js 
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.write("123");
  response.write(" | ");
  response.write(process.env.HOSTNAME);
  response.end(": Hello World!  |v4| \n");
};
var www = http.createServer(handleRequest);
www.listen(8080);
[vagrant@auto dynamic_web]$ git add .; git commit -m "for dy test"
[master 88d7419] for dy test
 1 file changed, 2 insertions(+), 2 deletions(-)
[vagrant@auto dynamic_web]$ git push 
warning: push.default 未设置，它的默认值将会在 Git 2.0 由 'matching'
修改为 'simple'。若要不再显示本信息并在其默认值改变后维持当前使用习惯，
进行如下设置：

  git config --global push.default matching

若要不再显示本信息并从现在开始采用新的使用习惯，设置：

  git config --global push.default simple

参见 'git help config' 并查找 'push.default' 以获取更多信息。
（'simple' 模式由 Git 1.7.11 版本引入。如果您有时要使用老版本的 Git，
为保持兼容，请用 'current' 代替 'simple' 模式）

Counting objects: 5, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 285 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
Username for 'http://10.1.0.165:10080': root
Password for 'http://root@10.1.0.165:10080': 
To http://10.1.0.165:10080/root/dynamic_web.git
   92aa507..88d7419  master -> master
[vagrant@auto dynamic_web]$ 
~~~

Pipeline 会自动触发构建操作

并且在需要人工确认的地方进行等待

![cicd](/assets/img/cicd/cicd27.png)

人工确认之前，可以跟随构建结果的链接查看变更后的效果

![cicd](/assets/img/cicd/cicd28.png)

查看变更是否达到预期

![cicd](/assets/img/cicd/cicd29.png)

经历了所有环节，成功构建的效果

![cicd](/assets/img/cicd/cicd30.png)


## 应用初始化

也就是将应用恢复到初始状态

![cicd](/assets/img/cicd/cicd06.png)

其中第二步需要人工确认

## 查看集群监控

![cicd](/assets/img/cicd/cicd07.png)

![cicd](/assets/img/cicd/cicd08.png)

跟随链接可以看到监控界面(此链接不会发生变化)

![cicd](/assets/img/cicd/cicd09.png)

![cicd](/assets/img/cicd/cicd10.png)

监控里可以看到不同 namespace 中的 pod 资源占用量

主要有 CPU MEM DISK NET 用量信息

更高要求的情况下可以考虑构建 prometheus，同时通过脚本定制一些特殊对象

加入关键指标的报警

## 进行实例扩容

选中要扩容的对象指定扩容到多少实例

![cicd](/assets/img/cicd/cicd11.png)

![cicd](/assets/img/cicd/cicd12.png)

## 源码版本管理

比起前面一个版本，这个版本集成了源码管理的功能

![cicd](/assets/img/cicd/cicd31.png)

通过这个管理控制台，可以简单便捷地实现源码的常见管理

也可以提供给其它项目使用

# 其它

## 高可用

* 通过k8s集群扩容到多宿主机
* 前端考虑加上软硬件 LB
* 存储使用ceph 或其它分布式存储

## 日志

* 对接ELK
* 建议与开发约定输出日志格式全都为 json 

## 审核策略

* 通过 intpu 的 submitter 来控制确认有权限审批的对象 


## 说明

* 修改完代码将静态或动态代码包上传构建后，直接跟随链接就可以看到变化后的结果 (如非重置环境，访问的端口不会改变)
* 由于对 java 不熟悉，这里使用的 nodejs 来完成的动态 web 演示

# 附

## 安装过程

~~~
nothing@pc:~/vagrant/cicd$ time vagrant up 
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'centos/7'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'centos/7' is up to date...
==> default: Setting the name of the VM: cicd_default_1566493542945_67034
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
    default: Adapter 2: hostonly
    default: Adapter 3: hostonly
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: 
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default: 
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
[default] No Virtualbox Guest Additions installation found.
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.tuna.tsinghua.edu.cn
 * extras: mirror.jdcloud.com
 * updates: mirror.jdcloud.com
Package binutils-2.27-34.base.el7.x86_64 already installed and latest version
Package 1:make-3.82-23.el7.x86_64 already installed and latest version
Package bzip2-1.0.6-13.el7.x86_64 already installed and latest version
Resolving Dependencies
--> Running transaction check
---> Package gcc.x86_64 0:4.8.5-36.el7_6.2 will be installed
--> Processing Dependency: cpp = 4.8.5-36.el7_6.2 for package: gcc-4.8.5-36.el7_6.2.x86_64
--> Processing Dependency: glibc-devel >= 2.2.90-12 for package: gcc-4.8.5-36.el7_6.2.x86_64
--> Processing Dependency: libmpfr.so.4()(64bit) for package: gcc-4.8.5-36.el7_6.2.x86_64
--> Processing Dependency: libmpc.so.3()(64bit) for package: gcc-4.8.5-36.el7_6.2.x86_64
---> Package kernel-devel.x86_64 0:3.10.0-957.12.2.el7 will be installed
---> Package kernel-devel.x86_64 0:3.10.0-957.27.2.el7 will be installed
---> Package perl.x86_64 4:5.16.3-294.el7_6 will be installed
--> Processing Dependency: perl-libs = 4:5.16.3-294.el7_6 for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Socket) >= 1.3 for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Scalar::Util) >= 1.10 for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl-macros for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl-libs for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(threads::shared) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(threads) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(constant) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Time::Local) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Time::HiRes) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Storable) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Socket) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Scalar::Util) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Pod::Simple::XHTML) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Pod::Simple::Search) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Getopt::Long) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Filter::Util::Call) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(File::Temp) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(File::Spec::Unix) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(File::Spec::Functions) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(File::Spec) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(File::Path) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Exporter) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Cwd) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: perl(Carp) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Processing Dependency: libperl.so()(64bit) for package: 4:perl-5.16.3-294.el7_6.x86_64
--> Running transaction check
---> Package cpp.x86_64 0:4.8.5-36.el7_6.2 will be installed
---> Package glibc-devel.x86_64 0:2.17-260.el7_6.6 will be installed
--> Processing Dependency: glibc-headers = 2.17-260.el7_6.6 for package: glibc-devel-2.17-260.el7_6.6.x86_64
--> Processing Dependency: glibc = 2.17-260.el7_6.6 for package: glibc-devel-2.17-260.el7_6.6.x86_64
--> Processing Dependency: glibc-headers for package: glibc-devel-2.17-260.el7_6.6.x86_64
---> Package libmpc.x86_64 0:1.0.1-3.el7 will be installed
---> Package mpfr.x86_64 0:3.1.1-4.el7 will be installed
---> Package perl-Carp.noarch 0:1.26-244.el7 will be installed
---> Package perl-Exporter.noarch 0:5.68-3.el7 will be installed
---> Package perl-File-Path.noarch 0:2.09-2.el7 will be installed
---> Package perl-File-Temp.noarch 0:0.23.01-3.el7 will be installed
---> Package perl-Filter.x86_64 0:1.49-3.el7 will be installed
---> Package perl-Getopt-Long.noarch 0:2.40-3.el7 will be installed
--> Processing Dependency: perl(Pod::Usage) >= 1.14 for package: perl-Getopt-Long-2.40-3.el7.noarch
--> Processing Dependency: perl(Text::ParseWords) for package: perl-Getopt-Long-2.40-3.el7.noarch
---> Package perl-PathTools.x86_64 0:3.40-5.el7 will be installed
---> Package perl-Pod-Simple.noarch 1:3.28-4.el7 will be installed
--> Processing Dependency: perl(Pod::Escapes) >= 1.04 for package: 1:perl-Pod-Simple-3.28-4.el7.noarch
--> Processing Dependency: perl(Encode) for package: 1:perl-Pod-Simple-3.28-4.el7.noarch
---> Package perl-Scalar-List-Utils.x86_64 0:1.27-248.el7 will be installed
---> Package perl-Socket.x86_64 0:2.010-4.el7 will be installed
---> Package perl-Storable.x86_64 0:2.45-3.el7 will be installed
---> Package perl-Time-HiRes.x86_64 4:1.9725-3.el7 will be installed
---> Package perl-Time-Local.noarch 0:1.2300-2.el7 will be installed
---> Package perl-constant.noarch 0:1.27-2.el7 will be installed
---> Package perl-libs.x86_64 4:5.16.3-294.el7_6 will be installed
---> Package perl-macros.x86_64 4:5.16.3-294.el7_6 will be installed
---> Package perl-threads.x86_64 0:1.87-4.el7 will be installed
---> Package perl-threads-shared.x86_64 0:1.43-6.el7 will be installed
--> Running transaction check
---> Package glibc.x86_64 0:2.17-260.el7_6.5 will be updated
--> Processing Dependency: glibc = 2.17-260.el7_6.5 for package: glibc-common-2.17-260.el7_6.5.x86_64
---> Package glibc.x86_64 0:2.17-260.el7_6.6 will be an update
---> Package glibc-headers.x86_64 0:2.17-260.el7_6.6 will be installed
--> Processing Dependency: kernel-headers >= 2.2.1 for package: glibc-headers-2.17-260.el7_6.6.x86_64
--> Processing Dependency: kernel-headers for package: glibc-headers-2.17-260.el7_6.6.x86_64
---> Package perl-Encode.x86_64 0:2.51-7.el7 will be installed
---> Package perl-Pod-Escapes.noarch 1:1.04-294.el7_6 will be installed
---> Package perl-Pod-Usage.noarch 0:1.63-3.el7 will be installed
--> Processing Dependency: perl(Pod::Text) >= 3.15 for package: perl-Pod-Usage-1.63-3.el7.noarch
--> Processing Dependency: perl-Pod-Perldoc for package: perl-Pod-Usage-1.63-3.el7.noarch
---> Package perl-Text-ParseWords.noarch 0:3.29-4.el7 will be installed
--> Running transaction check
---> Package glibc-common.x86_64 0:2.17-260.el7_6.5 will be updated
---> Package glibc-common.x86_64 0:2.17-260.el7_6.6 will be an update
---> Package kernel-headers.x86_64 0:3.10.0-957.27.2.el7 will be installed
---> Package perl-Pod-Perldoc.noarch 0:3.20-4.el7 will be installed
--> Processing Dependency: perl(parent) for package: perl-Pod-Perldoc-3.20-4.el7.noarch
--> Processing Dependency: perl(HTTP::Tiny) for package: perl-Pod-Perldoc-3.20-4.el7.noarch
---> Package perl-podlators.noarch 0:2.5.1-3.el7 will be installed
--> Running transaction check
---> Package perl-HTTP-Tiny.noarch 0:0.033-3.el7 will be installed
---> Package perl-parent.noarch 1:0.225-244.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package                   Arch      Version                   Repository  Size
================================================================================
Installing:
 gcc                       x86_64    4.8.5-36.el7_6.2          updates     16 M
 kernel-devel              x86_64    3.10.0-957.12.2.el7       updates     17 M
 kernel-devel              x86_64    3.10.0-957.27.2.el7       updates     17 M
 perl                      x86_64    4:5.16.3-294.el7_6        updates    8.0 M
Installing for dependencies:
 cpp                       x86_64    4.8.5-36.el7_6.2          updates    5.9 M
 glibc-devel               x86_64    2.17-260.el7_6.6          updates    1.1 M
 glibc-headers             x86_64    2.17-260.el7_6.6          updates    684 k
 kernel-headers            x86_64    3.10.0-957.27.2.el7       updates    8.0 M
 libmpc                    x86_64    1.0.1-3.el7               base        51 k
 mpfr                      x86_64    3.1.1-4.el7               base       203 k
 perl-Carp                 noarch    1.26-244.el7              base        19 k
 perl-Encode               x86_64    2.51-7.el7                base       1.5 M
 perl-Exporter             noarch    5.68-3.el7                base        28 k
 perl-File-Path            noarch    2.09-2.el7                base        26 k
 perl-File-Temp            noarch    0.23.01-3.el7             base        56 k
 perl-Filter               x86_64    1.49-3.el7                base        76 k
 perl-Getopt-Long          noarch    2.40-3.el7                base        56 k
 perl-HTTP-Tiny            noarch    0.033-3.el7               base        38 k
 perl-PathTools            x86_64    3.40-5.el7                base        82 k
 perl-Pod-Escapes          noarch    1:1.04-294.el7_6          updates     51 k
 perl-Pod-Perldoc          noarch    3.20-4.el7                base        87 k
 perl-Pod-Simple           noarch    1:3.28-4.el7              base       216 k
 perl-Pod-Usage            noarch    1.63-3.el7                base        27 k
 perl-Scalar-List-Utils    x86_64    1.27-248.el7              base        36 k
 perl-Socket               x86_64    2.010-4.el7               base        49 k
 perl-Storable             x86_64    2.45-3.el7                base        77 k
 perl-Text-ParseWords      noarch    3.29-4.el7                base        14 k
 perl-Time-HiRes           x86_64    4:1.9725-3.el7            base        45 k
 perl-Time-Local           noarch    1.2300-2.el7              base        24 k
 perl-constant             noarch    1.27-2.el7                base        19 k
 perl-libs                 x86_64    4:5.16.3-294.el7_6        updates    688 k
 perl-macros               x86_64    4:5.16.3-294.el7_6        updates     44 k
 perl-parent               noarch    1:0.225-244.el7           base        12 k
 perl-podlators            noarch    2.5.1-3.el7               base       112 k
 perl-threads              x86_64    1.87-4.el7                base        49 k
 perl-threads-shared       x86_64    1.43-6.el7                base        39 k
Updating for dependencies:
 glibc                     x86_64    2.17-260.el7_6.6          updates    3.7 M
 glibc-common              x86_64    2.17-260.el7_6.6          updates     12 M

Transaction Summary
================================================================================
Install  4 Packages (+32 Dependent packages)
Upgrade             (  2 Dependent packages)

Total download size: 92 M
Downloading packages:
Delta RPMs reduced 3.7 M of updates to 769 k (79% saved)
Public key for glibc-devel-2.17-260.el7_6.6.x86_64.rpm is not installed
warning: /var/cache/yum/x86_64/7/updates/packages/glibc-devel-2.17-260.el7_6.6.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for libmpc-1.0.1-3.el7.x86_64.rpm is not installed
--------------------------------------------------------------------------------
Total                                              6.9 MB/s |  89 MB  00:12     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-6.1810.2.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : glibc-common-2.17-260.el7_6.6.x86_64                        1/40 
  Updating   : glibc-2.17-260.el7_6.6.x86_64                               2/40 
  Installing : mpfr-3.1.1-4.el7.x86_64                                     3/40 
  Installing : libmpc-1.0.1-3.el7.x86_64                                   4/40 
  Installing : cpp-4.8.5-36.el7_6.2.x86_64                                 5/40 
  Installing : 1:perl-parent-0.225-244.el7.noarch                          6/40 
  Installing : perl-HTTP-Tiny-0.033-3.el7.noarch                           7/40 
  Installing : perl-podlators-2.5.1-3.el7.noarch                           8/40 
  Installing : perl-Pod-Perldoc-3.20-4.el7.noarch                          9/40 
  Installing : 1:perl-Pod-Escapes-1.04-294.el7_6.noarch                   10/40 
  Installing : perl-Encode-2.51-7.el7.x86_64                              11/40 
  Installing : perl-Text-ParseWords-3.29-4.el7.noarch                     12/40 
  Installing : perl-Pod-Usage-1.63-3.el7.noarch                           13/40 
  Installing : 4:perl-libs-5.16.3-294.el7_6.x86_64                        14/40 
  Installing : 4:perl-macros-5.16.3-294.el7_6.x86_64                      15/40 
  Installing : perl-threads-1.87-4.el7.x86_64                             16/40 
  Installing : perl-Storable-2.45-3.el7.x86_64                            17/40 
  Installing : perl-Exporter-5.68-3.el7.noarch                            18/40 
  Installing : perl-constant-1.27-2.el7.noarch                            19/40 
  Installing : perl-Time-Local-1.2300-2.el7.noarch                        20/40 
  Installing : perl-Socket-2.010-4.el7.x86_64                             21/40 
  Installing : perl-Carp-1.26-244.el7.noarch                              22/40 
  Installing : 4:perl-Time-HiRes-1.9725-3.el7.x86_64                      23/40 
  Installing : perl-threads-shared-1.43-6.el7.x86_64                      24/40 
  Installing : perl-PathTools-3.40-5.el7.x86_64                           25/40 
  Installing : perl-Scalar-List-Utils-1.27-248.el7.x86_64                 26/40 
  Installing : 1:perl-Pod-Simple-3.28-4.el7.noarch                        27/40 
  Installing : perl-File-Temp-0.23.01-3.el7.noarch                        28/40 
  Installing : perl-File-Path-2.09-2.el7.noarch                           29/40 
  Installing : perl-Filter-1.49-3.el7.x86_64                              30/40 
  Installing : perl-Getopt-Long-2.40-3.el7.noarch                         31/40 
  Installing : 4:perl-5.16.3-294.el7_6.x86_64                             32/40 
  Installing : kernel-headers-3.10.0-957.27.2.el7.x86_64                  33/40 
  Installing : glibc-headers-2.17-260.el7_6.6.x86_64                      34/40 
  Installing : glibc-devel-2.17-260.el7_6.6.x86_64                        35/40 
  Installing : gcc-4.8.5-36.el7_6.2.x86_64                                36/40 
  Installing : kernel-devel-3.10.0-957.27.2.el7.x86_64                    37/40 
  Installing : kernel-devel-3.10.0-957.12.2.el7.x86_64                    38/40 
  Cleanup    : glibc-common-2.17-260.el7_6.5.x86_64                       39/40 
  Cleanup    : glibc-2.17-260.el7_6.5.x86_64                              40/40 
  Verifying  : perl-HTTP-Tiny-0.033-3.el7.noarch                           1/40 
  Verifying  : perl-threads-shared-1.43-6.el7.x86_64                       2/40 
  Verifying  : perl-Storable-2.45-3.el7.x86_64                             3/40 
  Verifying  : 1:perl-Pod-Escapes-1.04-294.el7_6.noarch                    4/40 
  Verifying  : perl-threads-1.87-4.el7.x86_64                              5/40 
  Verifying  : perl-Exporter-5.68-3.el7.noarch                             6/40 
  Verifying  : perl-constant-1.27-2.el7.noarch                             7/40 
  Verifying  : perl-PathTools-3.40-5.el7.x86_64                            8/40 
  Verifying  : glibc-2.17-260.el7_6.6.x86_64                               9/40 
  Verifying  : kernel-headers-3.10.0-957.27.2.el7.x86_64                  10/40 
  Verifying  : gcc-4.8.5-36.el7_6.2.x86_64                                11/40 
  Verifying  : kernel-devel-3.10.0-957.27.2.el7.x86_64                    12/40 
  Verifying  : 1:perl-parent-0.225-244.el7.noarch                         13/40 
  Verifying  : 4:perl-libs-5.16.3-294.el7_6.x86_64                        14/40 
  Verifying  : perl-File-Temp-0.23.01-3.el7.noarch                        15/40 
  Verifying  : 1:perl-Pod-Simple-3.28-4.el7.noarch                        16/40 
  Verifying  : perl-Time-Local-1.2300-2.el7.noarch                        17/40 
  Verifying  : glibc-headers-2.17-260.el7_6.6.x86_64                      18/40 
  Verifying  : 4:perl-macros-5.16.3-294.el7_6.x86_64                      19/40 
  Verifying  : perl-Socket-2.010-4.el7.x86_64                             20/40 
  Verifying  : perl-Carp-1.26-244.el7.noarch                              21/40 
  Verifying  : 4:perl-Time-HiRes-1.9725-3.el7.x86_64                      22/40 
  Verifying  : perl-Scalar-List-Utils-1.27-248.el7.x86_64                 23/40 
  Verifying  : glibc-devel-2.17-260.el7_6.6.x86_64                        24/40 
  Verifying  : libmpc-1.0.1-3.el7.x86_64                                  25/40 
  Verifying  : perl-Pod-Usage-1.63-3.el7.noarch                           26/40 
  Verifying  : kernel-devel-3.10.0-957.12.2.el7.x86_64                    27/40 
  Verifying  : perl-Encode-2.51-7.el7.x86_64                              28/40 
  Verifying  : perl-Pod-Perldoc-3.20-4.el7.noarch                         29/40 
  Verifying  : perl-podlators-2.5.1-3.el7.noarch                          30/40 
  Verifying  : perl-File-Path-2.09-2.el7.noarch                           31/40 
  Verifying  : mpfr-3.1.1-4.el7.x86_64                                    32/40 
  Verifying  : perl-Filter-1.49-3.el7.x86_64                              33/40 
  Verifying  : perl-Getopt-Long-2.40-3.el7.noarch                         34/40 
  Verifying  : perl-Text-ParseWords-3.29-4.el7.noarch                     35/40 
  Verifying  : 4:perl-5.16.3-294.el7_6.x86_64                             36/40 
  Verifying  : cpp-4.8.5-36.el7_6.2.x86_64                                37/40 
  Verifying  : glibc-common-2.17-260.el7_6.6.x86_64                       38/40 
  Verifying  : glibc-common-2.17-260.el7_6.5.x86_64                       39/40 
  Verifying  : glibc-2.17-260.el7_6.5.x86_64                              40/40 

Installed:
  gcc.x86_64 0:4.8.5-36.el7_6.2                                                 
  kernel-devel.x86_64 0:3.10.0-957.12.2.el7                                     
  kernel-devel.x86_64 0:3.10.0-957.27.2.el7                                     
  perl.x86_64 4:5.16.3-294.el7_6                                                

Dependency Installed:
  cpp.x86_64 0:4.8.5-36.el7_6.2                                                 
  glibc-devel.x86_64 0:2.17-260.el7_6.6                                         
  glibc-headers.x86_64 0:2.17-260.el7_6.6                                       
  kernel-headers.x86_64 0:3.10.0-957.27.2.el7                                   
  libmpc.x86_64 0:1.0.1-3.el7                                                   
  mpfr.x86_64 0:3.1.1-4.el7                                                     
  perl-Carp.noarch 0:1.26-244.el7                                               
  perl-Encode.x86_64 0:2.51-7.el7                                               
  perl-Exporter.noarch 0:5.68-3.el7                                             
  perl-File-Path.noarch 0:2.09-2.el7                                            
  perl-File-Temp.noarch 0:0.23.01-3.el7                                         
  perl-Filter.x86_64 0:1.49-3.el7                                               
  perl-Getopt-Long.noarch 0:2.40-3.el7                                          
  perl-HTTP-Tiny.noarch 0:0.033-3.el7                                           
  perl-PathTools.x86_64 0:3.40-5.el7                                            
  perl-Pod-Escapes.noarch 1:1.04-294.el7_6                                      
  perl-Pod-Perldoc.noarch 0:3.20-4.el7                                          
  perl-Pod-Simple.noarch 1:3.28-4.el7                                           
  perl-Pod-Usage.noarch 0:1.63-3.el7                                            
  perl-Scalar-List-Utils.x86_64 0:1.27-248.el7                                  
  perl-Socket.x86_64 0:2.010-4.el7                                              
  perl-Storable.x86_64 0:2.45-3.el7                                             
  perl-Text-ParseWords.noarch 0:3.29-4.el7                                      
  perl-Time-HiRes.x86_64 4:1.9725-3.el7                                         
  perl-Time-Local.noarch 0:1.2300-2.el7                                         
  perl-constant.noarch 0:1.27-2.el7                                             
  perl-libs.x86_64 4:5.16.3-294.el7_6                                           
  perl-macros.x86_64 4:5.16.3-294.el7_6                                         
  perl-parent.noarch 1:0.225-244.el7                                            
  perl-podlators.noarch 0:2.5.1-3.el7                                           
  perl-threads.x86_64 0:1.87-4.el7                                              
  perl-threads-shared.x86_64 0:1.43-6.el7                                       

Dependency Updated:
  glibc.x86_64 0:2.17-260.el7_6.6     glibc-common.x86_64 0:2.17-260.el7_6.6    

Complete!
Copy iso file /usr/share/virtualbox/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
Mounting Virtualbox Guest Additions ISO to: /mnt
mount: /dev/loop0 is write-protected, mounting read-only
Installing Virtualbox Guest Additions 5.2.24 - guest version is unknown
Verifying archive integrity... All good.
Uncompressing VirtualBox 5.2.24 Guest Additions for Linux........
VirtualBox Guest Additions installer
Copying additional installer modules ...
Installing additional modules ...
VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel modules.  This may take a while.
VirtualBox Guest Additions: To build modules for other installed kernels, run
VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup <version>
VirtualBox Guest Additions: Building the modules for kernel 3.10.0-957.12.2.el7.x86_64.
VirtualBox Guest Additions: Starting.
Redirecting to /bin/systemctl start vboxadd.service
Redirecting to /bin/systemctl start vboxadd-service.service
Unmounting Virtualbox Guest Additions ISO from: /mnt
==> default: Checking for guest additions in VM...
==> default: Setting hostname...
==> default: Configuring and enabling network interfaces...
==> default: Rsyncing folder: /home/nothing/vagrant/cicd/ => /vagrant
==> default: Running provisioner: file...
==> default: Running provisioner: shell...
    default: Running: /tmp/vagrant-shell20190823-9209-jpqep9.bash
    default: Loaded plugins: fastestmirror
    default: Loading mirror speeds from cached hostfile
    default:  * base: mirrors.tuna.tsinghua.edu.cn
    default:  * extras: mirror.jdcloud.com
    default:  * updates: mirror.jdcloud.com
    default: Resolving Dependencies
    default: --> Running transaction check
    default: ---> Package java-1.8.0-openjdk.x86_64 1:1.8.0.222.b10-0.el7_6 will be installed
    default: --> Processing Dependency: java-1.8.0-openjdk-headless(x86-64) = 1:1.8.0.222.b10-0.el7_6 for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: xorg-x11-fonts-Type1 for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libjvm.so(SUNWprivate_1.1)(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libjpeg.so.62(LIBJPEG_6.2)(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libjava.so(SUNWprivate_1.1)(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libasound.so.2(ALSA_0.9.0rc4)(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libasound.so.2(ALSA_0.9)(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libXcomposite(x86-64) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: gtk2(x86-64) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: fontconfig(x86-64) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libjvm.so()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libjpeg.so.62()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libjava.so()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libgif.so.4()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libasound.so.2()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libXtst.so.6()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libXrender.so.1()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libXi.so.6()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libXext.so.6()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: libX11.so.6()(64bit) for package: 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Running transaction check
    default: ---> Package alsa-lib.x86_64 0:1.1.6-2.el7 will be installed
    default: ---> Package fontconfig.x86_64 0:2.13.0-4.3.el7 will be installed
    default: --> Processing Dependency: fontpackages-filesystem for package: fontconfig-2.13.0-4.3.el7.x86_64
    default: --> Processing Dependency: dejavu-sans-fonts for package: fontconfig-2.13.0-4.3.el7.x86_64
    default: ---> Package giflib.x86_64 0:4.1.6-9.el7 will be installed
    default: --> Processing Dependency: libSM.so.6()(64bit) for package: giflib-4.1.6-9.el7.x86_64
    default: --> Processing Dependency: libICE.so.6()(64bit) for package: giflib-4.1.6-9.el7.x86_64
    default: ---> Package gtk2.x86_64 0:2.24.31-1.el7 will be installed
    default: --> Processing Dependency: pango >= 1.20.0-1 for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libtiff >= 3.6.1 for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libXrandr >= 1.2.99.4-2 for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: atk >= 1.29.4-2 for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: hicolor-icon-theme for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: gtk-update-icon-cache for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libpangoft2-1.0.so.0()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libpangocairo-1.0.so.0()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libpango-1.0.so.0()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libgdk_pixbuf-2.0.so.0()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libcairo.so.2()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libatk-1.0.so.0()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libXrandr.so.2()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libXinerama.so.1()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libXfixes.so.3()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libXdamage.so.1()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: --> Processing Dependency: libXcursor.so.1()(64bit) for package: gtk2-2.24.31-1.el7.x86_64
    default: ---> Package java-1.8.0-openjdk-headless.x86_64 1:1.8.0.222.b10-0.el7_6 will be installed
    default: --> Processing Dependency: tzdata-java >= 2015d for package: 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: copy-jdk-configs >= 3.3 for package: 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: pcsc-lite-libs(x86-64) for package: 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: lksctp-tools(x86-64) for package: 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_64
    default: --> Processing Dependency: jpackage-utils for package: 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_64
    default: ---> Package libX11.x86_64 0:1.6.5-2.el7 will be installed
    default: --> Processing Dependency: libX11-common >= 1.6.5-2.el7 for package: libX11-1.6.5-2.el7.x86_64
    default: --> Processing Dependency: libxcb.so.1()(64bit) for package: libX11-1.6.5-2.el7.x86_64
    default: ---> Package libXcomposite.x86_64 0:0.4.4-4.1.el7 will be installed
    default: ---> Package libXext.x86_64 0:1.3.3-3.el7 will be installed
    default: ---> Package libXi.x86_64 0:1.7.9-1.el7 will be installed
    default: ---> Package libXrender.x86_64 0:0.9.10-1.el7 will be installed
    default: ---> Package libXtst.x86_64 0:1.2.3-1.el7 will be installed
    default: ---> Package libjpeg-turbo.x86_64 0:1.2.90-6.el7 will be installed
    default: ---> Package xorg-x11-fonts-Type1.noarch 0:7.5-9.el7 will be installed
    default: --> Processing Dependency: ttmkfdir for package: xorg-x11-fonts-Type1-7.5-9.el7.noarch
    default: --> Processing Dependency: ttmkfdir for package: xorg-x11-fonts-Type1-7.5-9.el7.noarch
    default: --> Processing Dependency: mkfontdir for package: xorg-x11-fonts-Type1-7.5-9.el7.noarch
    default: --> Processing Dependency: mkfontdir for package: xorg-x11-fonts-Type1-7.5-9.el7.noarch
    default: --> Running transaction check
    default: ---> Package atk.x86_64 0:2.28.1-1.el7 will be installed
    default: ---> Package cairo.x86_64 0:1.15.12-3.el7 will be installed
    default: --> Processing Dependency: libpixman-1.so.0()(64bit) for package: cairo-1.15.12-3.el7.x86_64
    default: --> Processing Dependency: libGL.so.1()(64bit) for package: cairo-1.15.12-3.el7.x86_64
    default: --> Processing Dependency: libEGL.so.1()(64bit) for package: cairo-1.15.12-3.el7.x86_64
    default: ---> Package copy-jdk-configs.noarch 0:3.3-10.el7_5 will be installed
    default: ---> Package dejavu-sans-fonts.noarch 0:2.33-6.el7 will be installed
    default: --> Processing Dependency: dejavu-fonts-common = 2.33-6.el7 for package: dejavu-sans-fonts-2.33-6.el7.noarch
    default: ---> Package fontpackages-filesystem.noarch 0:1.44-8.el7 will be installed
    default: ---> Package gdk-pixbuf2.x86_64 0:2.36.12-3.el7 will be installed
    default: --> Processing Dependency: libjasper.so.1()(64bit) for package: gdk-pixbuf2-2.36.12-3.el7.x86_64
    default: ---> Package gtk-update-icon-cache.x86_64 0:3.22.30-3.el7 will be installed
    default: ---> Package hicolor-icon-theme.noarch 0:0.12-7.el7 will be installed
    default: ---> Package javapackages-tools.noarch 0:3.4.1-11.el7 will be installed
    default: --> Processing Dependency: python-javapackages = 3.4.1-11.el7 for package: javapackages-tools-3.4.1-11.el7.noarch
    default: ---> Package libICE.x86_64 0:1.0.9-9.el7 will be installed
    default: ---> Package libSM.x86_64 0:1.2.2-2.el7 will be installed
    default: ---> Package libX11-common.noarch 0:1.6.5-2.el7 will be installed
    default: ---> Package libXcursor.x86_64 0:1.1.15-1.el7 will be installed
    default: ---> Package libXdamage.x86_64 0:1.1.4-4.1.el7 will be installed
    default: ---> Package libXfixes.x86_64 0:5.0.3-1.el7 will be installed
    default: ---> Package libXinerama.x86_64 0:1.1.3-2.1.el7 will be installed
    default: ---> Package libXrandr.x86_64 0:1.5.1-2.el7 will be installed
    default: ---> Package libtiff.x86_64 0:4.0.3-27.el7_3 will be installed
    default: --> Processing Dependency: libjbig.so.2.0()(64bit) for package: libtiff-4.0.3-27.el7_3.x86_64
    default: ---> Package libxcb.x86_64 0:1.13-1.el7 will be installed
    default: --> Processing Dependency: libXau.so.6()(64bit) for package: libxcb-1.13-1.el7.x86_64
    default: ---> Package lksctp-tools.x86_64 0:1.0.17-2.el7 will be installed
    default: ---> Package pango.x86_64 0:1.42.4-2.el7_6 will be installed
    default: --> Processing Dependency: libthai(x86-64) >= 0.1.9 for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: libXft(x86-64) >= 2.0.0 for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: harfbuzz(x86-64) >= 1.4.2 for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: fribidi(x86-64) >= 1.0 for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: libthai.so.0(LIBTHAI_0.1)(64bit) for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: libthai.so.0()(64bit) for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: libharfbuzz.so.0()(64bit) for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: libfribidi.so.0()(64bit) for package: pango-1.42.4-2.el7_6.x86_64
    default: --> Processing Dependency: libXft.so.2()(64bit) for package: pango-1.42.4-2.el7_6.x86_64
    default: ---> Package pcsc-lite-libs.x86_64 0:1.8.8-8.el7 will be installed
    default: ---> Package ttmkfdir.x86_64 0:3.0.9-42.el7 will be installed
    default: ---> Package tzdata-java.noarch 0:2019b-1.el7 will be installed
    default: ---> Package xorg-x11-font-utils.x86_64 1:7.5-21.el7 will be installed
    default: --> Processing Dependency: libfontenc.so.1()(64bit) for package: 1:xorg-x11-font-utils-7.5-21.el7.x86_64
    default: --> Running transaction check
    default: ---> Package dejavu-fonts-common.noarch 0:2.33-6.el7 will be installed
    default: ---> Package fribidi.x86_64 0:1.0.2-1.el7 will be installed
    default: ---> Package harfbuzz.x86_64 0:1.7.5-2.el7 will be installed
    default: --> Processing Dependency: libgraphite2.so.3()(64bit) for package: harfbuzz-1.7.5-2.el7.x86_64
    default: ---> Package jasper-libs.x86_64 0:1.900.1-33.el7 will be installed
    default: ---> Package jbigkit-libs.x86_64 0:2.0-11.el7 will be installed
    default: ---> Package libXau.x86_64 0:1.0.8-2.1.el7 will be installed
    default: ---> Package libXft.x86_64 0:2.3.2-2.el7 will be installed
    default: ---> Package libfontenc.x86_64 0:1.1.3-3.el7 will be installed
    default: ---> Package libglvnd-egl.x86_64 1:1.0.1-0.8.git5baa1e5.el7 will be installed
    default: --> Processing Dependency: libglvnd(x86-64) = 1:1.0.1-0.8.git5baa1e5.el7 for package: 1:libglvnd-egl-1.0.1-0.8.git5baa1e5.el7.x86_64
    default: --> Processing Dependency: mesa-libEGL(x86-64) >= 13.0.4-1 for package: 1:libglvnd-egl-1.0.1-0.8.git5baa1e5.el7.x86_64
    default: --> Processing Dependency: libGLdispatch.so.0()(64bit) for package: 1:libglvnd-egl-1.0.1-0.8.git5baa1e5.el7.x86_64
    default: ---> Package libglvnd-glx.x86_64 1:1.0.1-0.8.git5baa1e5.el7 will be installed
    default: --> Processing Dependency: mesa-libGL(x86-64) >= 13.0.4-1 for package: 1:libglvnd-glx-1.0.1-0.8.git5baa1e5.el7.x86_64
    default: ---> Package libthai.x86_64 0:0.1.14-9.el7 will be installed
    default: ---> Package pixman.x86_64 0:0.34.0-1.el7 will be installed
    default: ---> Package python-javapackages.noarch 0:3.4.1-11.el7 will be installed
    default: --> Processing Dependency: python-lxml for package: python-javapackages-3.4.1-11.el7.noarch
    default: --> Running transaction check
    default: ---> Package graphite2.x86_64 0:1.3.10-1.el7_3 will be installed
    default: ---> Package libglvnd.x86_64 1:1.0.1-0.8.git5baa1e5.el7 will be installed
    default: ---> Package mesa-libEGL.x86_64 0:18.0.5-4.el7_6 will be installed
    default: --> Processing Dependency: mesa-libgbm = 18.0.5-4.el7_6 for package: mesa-libEGL-18.0.5-4.el7_6.x86_64
    default: --> Processing Dependency: libxshmfence.so.1()(64bit) for package: mesa-libEGL-18.0.5-4.el7_6.x86_64
    default: --> Processing Dependency: libwayland-server.so.0()(64bit) for package: mesa-libEGL-18.0.5-4.el7_6.x86_64
    default: --> Processing Dependency: libwayland-client.so.0()(64bit) for package: mesa-libEGL-18.0.5-4.el7_6.x86_64
    default: --> Processing Dependency: libglapi.so.0()(64bit) for package: mesa-libEGL-18.0.5-4.el7_6.x86_64
    default: --> Processing Dependency: libgbm.so.1()(64bit) for package: mesa-libEGL-18.0.5-4.el7_6.x86_64
    default: ---> Package mesa-libGL.x86_64 0:18.0.5-4.el7_6 will be installed
    default: --> Processing Dependency: libXxf86vm.so.1()(64bit) for package: mesa-libGL-18.0.5-4.el7_6.x86_64
    default: ---> Package python-lxml.x86_64 0:3.2.1-4.el7 will be installed
    default: --> Running transaction check
    default: ---> Package libXxf86vm.x86_64 0:1.1.4-1.el7 will be installed
    default: ---> Package libwayland-client.x86_64 0:1.15.0-1.el7 will be installed
    default: ---> Package libwayland-server.x86_64 0:1.15.0-1.el7 will be installed
    default: ---> Package libxshmfence.x86_64 0:1.2-1.el7 will be installed
    default: ---> Package mesa-libgbm.x86_64 0:18.0.5-4.el7_6 will be installed
    default: ---> Package mesa-libglapi.x86_64 0:18.0.5-4.el7_6 will be installed
    default: --> Finished Dependency Resolution
    default: 
    default: Dependencies Resolved
    default: 
    default: ================================================================================
    default:  Package                     Arch   Version                       Repository
    default:                                                                            Size
    default: ================================================================================
    default: Installing:
    default:  java-1.8.0-openjdk          x86_64 1:1.8.0.222.b10-0.el7_6       updates 274 k
    default: Installing for dependencies:
    default:  alsa-lib                    x86_64 1.1.6-2.el7                   base    424 k
    default:  atk                         x86_64 2.28.1-1.el7                  base    263 k
    default:  cairo                       x86_64 1.15.12-3.el7                 base    741 k
    default:  copy-jdk-configs            noarch 3.3-10.el7_5                  base     21 k
    default:  dejavu-fonts-common         noarch 2.33-6.el7                    base     64 k
    default:  dejavu-sans-fonts           noarch 2.33-6.el7                    base    1.4 M
    default:  fontconfig                  x86_64 2.13.0-4.3.el7                base    254 k
    default:  fontpackages-filesystem     noarch 1.44-8.el7                    base    9.9 k
    default:  fribidi                     x86_64 1.0.2-1.el7                   base     79 k
    default:  gdk-pixbuf2                 x86_64 2.36.12-3.el7                 base    570 k
    default:  giflib                      x86_64 4.1.6-9.el7                   base     40 k
    default:  graphite2                   x86_64 1.3.10-1.el7_3                base    115 k
    default:  gtk-update-icon-cache       x86_64 3.22.30-3.el7                 base     28 k
    default:  gtk2                        x86_64 2.24.31-1.el7                 base    3.4 M
    default:  harfbuzz                    x86_64 1.7.5-2.el7                   base    267 k
    default:  hicolor-icon-theme          noarch 0.12-7.el7                    base     42 k
    default:  jasper-libs                 x86_64 1.900.1-33.el7                base    150 k
    default:  java-1.8.0-openjdk-headless x86_64 1:1.8.0.222.b10-0.el7_6       updates  32 M
    default:  javapackages-tools          noarch 3.4.1-11.el7                  base     73 k
    default:  jbigkit-libs                x86_64 2.0-11.el7                    base     46 k
    default:  libICE                      x86_64 1.0.9-9.el7                   base     66 k
    default:  libSM                       x86_64 1.2.2-2.el7                   base     39 k
    default:  libX11                      x86_64 1.6.5-2.el7                   base    606 k
    default:  libX11-common               noarch 1.6.5-2.el7                   base    164 k
    default:  libXau                      x86_64 1.0.8-2.1.el7                 base     29 k
    default:  libXcomposite               x86_64 0.4.4-4.1.el7                 base     22 k
    default:  libXcursor                  x86_64 1.1.15-1.el7                  base     30 k
    default:  libXdamage                  x86_64 1.1.4-4.1.el7                 base     20 k
    default:  libXext                     x86_64 1.3.3-3.el7                   base     39 k
    default:  libXfixes                   x86_64 5.0.3-1.el7                   base     18 k
    default:  libXft                      x86_64 2.3.2-2.el7                   base     58 k
    default:  libXi                       x86_64 1.7.9-1.el7                   base     40 k
    default:  libXinerama                 x86_64 1.1.3-2.1.el7                 base     14 k
    default:  libXrandr                   x86_64 1.5.1-2.el7                   base     27 k
    default:  libXrender                  x86_64 0.9.10-1.el7                  base     26 k
    default:  libXtst                     x86_64 1.2.3-1.el7                   base     20 k
    default:  libXxf86vm                  x86_64 1.1.4-1.el7                   base     18 k
    default:  libfontenc                  x86_64 1.1.3-3.el7                   base     31 k
    default:  libglvnd                    x86_64 1:1.0.1-0.8.git5baa1e5.el7    base     89 k
    default:  libglvnd-egl                x86_64 1:1.0.1-0.8.git5baa1e5.el7    base     44 k
    default:  libglvnd-glx                x86_64 1:1.0.1-0.8.git5baa1e5.el7    base    125 k
    default:  libjpeg-turbo               x86_64 1.2.90-6.el7                  base    134 k
    default:  libthai                     x86_64 0.1.14-9.el7                  base    187 k
    default:  libtiff                     x86_64 4.0.3-27.el7_3                base    170 k
    default:  libwayland-client           x86_64 1.15.0-1.el7                  base     33 k
    default:  libwayland-server           x86_64 1.15.0-1.el7                  base     39 k
    default:  libxcb                      x86_64 1.13-1.el7                    base    214 k
    default:  libxshmfence                x86_64 1.2-1.el7                     base    7.2 k
    default:  lksctp-tools                x86_64 1.0.17-2.el7                  base     88 k
    default:  mesa-libEGL                 x86_64 18.0.5-4.el7_6                updates 102 k
    default:  mesa-libGL                  x86_64 18.0.5-4.el7_6                updates 162 k
    default:  mesa-libgbm                 x86_64 18.0.5-4.el7_6                updates  38 k
    default:  mesa-libglapi               x86_64 18.0.5-4.el7_6                updates  44 k
    default:  pango                       x86_64 1.42.4-2.el7_6                updates 280 k
    default:  pcsc-lite-libs              x86_64 1.8.8-8.el7                   base     34 k
    default:  pixman                      x86_64 0.34.0-1.el7                  base    248 k
    default:  python-javapackages         noarch 3.4.1-11.el7                  base     31 k
    default:  python-lxml                 x86_64 3.2.1-4.el7                   base    758 k
    default:  ttmkfdir                    x86_64 3.0.9-42.el7                  base     48 k
    default:  tzdata-java                 noarch 2019b-1.el7                   updates 187 k
    default:  xorg-x11-font-utils         x86_64 1:7.5-21.el7                  base    104 k
    default:  xorg-x11-fonts-Type1        noarch 7.5-9.el7                     base    521 k
    default: 
    default: Transaction Summary
    default: ================================================================================
    default: Install  1 Package (+62 Dependent packages)
    default: Total download size: 45 M
    default: Installed size: 147 M
    default: Downloading packages:
    default: --------------------------------------------------------------------------------
    default: Total                                              1.9 MB/s |  45 MB  00:24     
    default: Running transaction check
    default: Running transaction test
    default: Transaction test succeeded
    default: Running transaction
    default:   Installing : libjpeg-turbo-1.2.90-6.el7.x86_64                           1/63
    default:  
    default:   Installing : mesa-libglapi-18.0.5-4.el7_6.x86_64                         2/63
    default:  
    default:   Installing : libxshmfence-1.2-1.el7.x86_64                               3/63
    default:  
    default:   Installing : 1:libglvnd-1.0.1-0.8.git5baa1e5.el7.x86_64                  4/63
    default:  
    default:   Installing : fontpackages-filesystem-1.44-8.el7.noarch                   5/63
    default:  
    default:   Installing : libICE-1.0.9-9.el7.x86_64                                   6/63
    default:  
    default:   Installing : libwayland-server-1.15.0-1.el7.x86_64                       7/63
    default:  
    default:   Installing : mesa-libgbm-18.0.5-4.el7_6.x86_64                           8/63
    default:  
    default:   Installing : libSM-1.2.2-2.el7.x86_64                                    9/63
    default:  
    default:   Installing : dejavu-fonts-common-2.33-6.el7.noarch                      10/63
    default:  
    default:   Installing : dejavu-sans-fonts-2.33-6.el7.noarch                        11/63
    default:  
    default:   Installing : fontconfig-2.13.0-4.3.el7.x86_64                           12/63
    default:  
    default:   Installing : jasper-libs-1.900.1-33.el7.x86_64                          13/63
    default:  
    default:   Installing : pixman-0.34.0-1.el7.x86_64                                 14/63
    default:  
    default:   Installing : copy-jdk-configs-3.3-10.el7_5.noarch                       15/63
    default:  
    default:   Installing : libfontenc-1.1.3-3.el7.x86_64                              16/63
    default:  
    default:   Installing : 1:xorg-x11-font-utils-7.5-21.el7.x86_64                    17/63
    default:  
    default:   Installing : libthai-0.1.14-9.el7.x86_64                                18/63
    default:  
    default:   Installing : python-lxml-3.2.1-4.el7.x86_64                             19/63
    default:  
    default:   Installing : python-javapackages-3.4.1-11.el7.noarch                    20/63
    default:  
    default:   Installing : javapackages-tools-3.4.1-11.el7.noarch                     21/63
    default:  
    default:   Installing : libX11-common-1.6.5-2.el7.noarch                           22/63
    default:  
    default:   Installing : graphite2-1.3.10-1.el7_3.x86_64                            23/63
    default:  
    default:   Installing : harfbuzz-1.7.5-2.el7.x86_64                                24/63
    default:  
    default:   Installing : libXau-1.0.8-2.1.el7.x86_64                                25/63
    default:  
    default:   Installing : libxcb-1.13-1.el7.x86_64                                   26/63
    default:  
    default:   Installing : libX11-1.6.5-2.el7.x86_64                                  27/63
    default:  
    default:   Installing : libXext-1.3.3-3.el7.x86_64                                 28/63
    default:  
    default:   Installing : libXrender-0.9.10-1.el7.x86_64                             29/63
    default:  
    default:   Installing : libXfixes-5.0.3-1.el7.x86_64                               30/63
    default:  
    default:   Installing : libXi-1.7.9-1.el7.x86_64                                   31/63
    default:  
    default:   Installing : libXdamage-1.1.4-4.1.el7.x86_64                            32/63
    default:  
    default:   Installing : libXcomposite-0.4.4-4.1.el7.x86_64                         33/63
    default:  
    default:   Installing : libXtst-1.2.3-1.el7.x86_64                                 34/63
    default:  
    default:   Installing : libXcursor-1.1.15-1.el7.x86_64                             35/63
    default:  
    default:   Installing : libXft-2.3.2-2.el7.x86_64                                  36/63
    default:  
    default:   Installing : libXrandr-1.5.1-2.el7.x86_64                               37/63
    default:  
    default:   Installing : libXinerama-1.1.3-2.1.el7.x86_64                           38/63
    default:  
    default:   Installing : libXxf86vm-1.1.4-1.el7.x86_64                              39/63
    default:  
    default:   Installing : mesa-libGL-18.0.5-4.el7_6.x86_64                           40/63
    default:  
    default:   Installing : 1:libglvnd-glx-1.0.1-0.8.git5baa1e5.el7.x86_64             41/63
    default:  
    default:   Installing : giflib-4.1.6-9.el7.x86_64                                  42/63
    default:  
    default:   Installing : jbigkit-libs-2.0-11.el7.x86_64                             43/63
    default:  
    default:   Installing : libtiff-4.0.3-27.el7_3.x86_64                              44/63
    default:  
    default:   Installing : gdk-pixbuf2-2.36.12-3.el7.x86_64                           45/63
    default:  
    default:   Installing : gtk-update-icon-cache-3.22.30-3.el7.x86_64                 46/63
    default:  
    default:   Installing : atk-2.28.1-1.el7.x86_64                                    47/63
    default:  
    default:   Installing : pcsc-lite-libs-1.8.8-8.el7.x86_64                          48/63
    default:  
    default:   Installing : fribidi-1.0.2-1.el7.x86_64                                 49/63
    default:  
    default:   Installing : lksctp-tools-1.0.17-2.el7.x86_64                           50/63
    default:  
    default:   Installing : alsa-lib-1.1.6-2.el7.x86_64                                51/63
    default:  
    default:   Installing : tzdata-java-2019b-1.el7.noarch                             52/63
    default:  
    default:   Installing : 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_   53/63
    default:  
    default:   Installing : libwayland-client-1.15.0-1.el7.x86_64                      54/63
    default:  
    default:   Installing : 1:libglvnd-egl-1.0.1-0.8.git5baa1e5.el7.x86_64             55/63
    default:  
    default:   Installing : mesa-libEGL-18.0.5-4.el7_6.x86_64                          56/63
    default:  
    default:   Installing : cairo-1.15.12-3.el7.x86_64                                 57/63
    default:  
    default:   Installing : pango-1.42.4-2.el7_6.x86_64                                58/63
    default:  
    default:   Installing : hicolor-icon-theme-0.12-7.el7.noarch                       59/63
    default:  
    default:   Installing : gtk2-2.24.31-1.el7.x86_64                                  60/63
    default:  
    default:   Installing : ttmkfdir-3.0.9-42.el7.x86_64                               61/63
    default:  
    default:   Installing : xorg-x11-fonts-Type1-7.5-9.el7.noarch                      62/63
    default:  
    default:   Installing : 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64          63/63
    default:  
    default:   Verifying  : 1:java-1.8.0-openjdk-headless-1.8.0.222.b10-0.el7_6.x86_    1/63
    default:  
    default:   Verifying  : libXext-1.3.3-3.el7.x86_64                                  2/63
    default:  
    default:   Verifying  : libXi-1.7.9-1.el7.x86_64                                    3/63
    default:  
    default:   Verifying  : libtiff-4.0.3-27.el7_3.x86_64                               4/63
    default:  
    default:   Verifying  : fontconfig-2.13.0-4.3.el7.x86_64                            5/63
    default:  
    default:   Verifying  : giflib-4.1.6-9.el7.x86_64                                   6/63
    default:  
    default:   Verifying  : libXinerama-1.1.3-2.1.el7.x86_64                            7/63
    default:  
    default:   Verifying  : libXrender-0.9.10-1.el7.x86_64                              8/63
    default:  
    default:   Verifying  : javapackages-tools-3.4.1-11.el7.noarch                      9/63
    default:  
    default:   Verifying  : 1:xorg-x11-font-utils-7.5-21.el7.x86_64                    10/63
    default:  
    default:   Verifying  : libXxf86vm-1.1.4-1.el7.x86_64                              11/63
    default:  
    default:   Verifying  : libwayland-server-1.15.0-1.el7.x86_64                      12/63
    default:  
    default:   Verifying  : libXcursor-1.1.15-1.el7.x86_64                             13/63
    default:  
    default:   Verifying  : libICE-1.0.9-9.el7.x86_64                                  14/63
    default:  
    default:   Verifying  : pango-1.42.4-2.el7_6.x86_64                                15/63
    default:  
    default:   Verifying  : fontpackages-filesystem-1.44-8.el7.noarch                  16/63
    default:  
    default:   Verifying  : ttmkfdir-3.0.9-42.el7.x86_64                               17/63
    default:  
    default:   Verifying  : libjpeg-turbo-1.2.90-6.el7.x86_64                          18/63
    default:  
    default:   Verifying  : hicolor-icon-theme-0.12-7.el7.noarch                       19/63
    default:  
    default:   Verifying  : libwayland-client-1.15.0-1.el7.x86_64                      20/63
    default:  
    default:   Verifying  : gdk-pixbuf2-2.36.12-3.el7.x86_64                           21/63
    default:  
    default:   Verifying  : gtk2-2.24.31-1.el7.x86_64                                  22/63
    default:  
    default:   Verifying  : gtk-update-icon-cache-3.22.30-3.el7.x86_64                 23/63
    default:  
    default:   Verifying  : python-javapackages-3.4.1-11.el7.noarch                    24/63
    default:  
    default:   Verifying  : tzdata-java-2019b-1.el7.noarch                             25/63
    default:  
    default:   Verifying  : mesa-libgbm-18.0.5-4.el7_6.x86_64                          26/63
    default:  
    default:   Verifying  : dejavu-fonts-common-2.33-6.el7.noarch                      27/63
    default:  
    default:   Verifying  : alsa-lib-1.1.6-2.el7.x86_64                                28/63
    default:  
    default:   Verifying  : libXcomposite-0.4.4-4.1.el7.x86_64                         29/63
    default:  
    default:   Verifying  : libXtst-1.2.3-1.el7.x86_64                                 30/63
    default:  
    default:   Verifying  : 1:libglvnd-1.0.1-0.8.git5baa1e5.el7.x86_64                 31/63
    default:  
    default:   Verifying  : libxcb-1.13-1.el7.x86_64                                   32/63
    default:  
    default:   Verifying  : libXft-2.3.2-2.el7.x86_64                                  33/63
    default:  
    default:   Verifying  : 1:libglvnd-egl-1.0.1-0.8.git5baa1e5.el7.x86_64             34/63
    default:  
    default:   Verifying  : lksctp-tools-1.0.17-2.el7.x86_64                           35/63
    default:  
    default:   Verifying  : 1:java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64          36/63
    default:  
    default:   Verifying  : mesa-libEGL-18.0.5-4.el7_6.x86_64                          37/63
    default:  
    default:   Verifying  : mesa-libGL-18.0.5-4.el7_6.x86_64                           38/63
    default:  
    default:   Verifying  : xorg-x11-fonts-Type1-7.5-9.el7.noarch                      39/63
    default:  
    default:   Verifying  : harfbuzz-1.7.5-2.el7.x86_64                                40/63
    default:  
    default:   Verifying  : fribidi-1.0.2-1.el7.x86_64                                 41/63
    default:  
    default:   Verifying  : libX11-1.6.5-2.el7.x86_64                                  42/63
    default:  
    default:   Verifying  : 1:libglvnd-glx-1.0.1-0.8.git5baa1e5.el7.x86_64             43/63
    default:  
    default:   Verifying  : dejavu-sans-fonts-2.33-6.el7.noarch                        44/63
    default:  
    default:   Verifying  : libXrandr-1.5.1-2.el7.x86_64                               45/63
    default:  
    default:   Verifying  : pcsc-lite-libs-1.8.8-8.el7.x86_64                          46/63
    default:  
    default:   Verifying  : atk-2.28.1-1.el7.x86_64                                    47/63
    default:  
    default:   Verifying  : jbigkit-libs-2.0-11.el7.x86_64                             48/63
    default:  
    default:   Verifying  : cairo-1.15.12-3.el7.x86_64                                 49/63
    default:  
    default:   Verifying  : libxshmfence-1.2-1.el7.x86_64                              50/63
    default:  
    default:   Verifying  : libXau-1.0.8-2.1.el7.x86_64                                51/63
    default:  
    default:   Verifying  : libSM-1.2.2-2.el7.x86_64                                   52/63
    default:  
    default:   Verifying  : jasper-libs-1.900.1-33.el7.x86_64                          53/63
    default:  
    default:   Verifying  : graphite2-1.3.10-1.el7_3.x86_64                            54/63
    default:  
    default:   Verifying  : libX11-common-1.6.5-2.el7.noarch                           55/63
    default:  
    default:   Verifying  : python-lxml-3.2.1-4.el7.x86_64                             56/63
    default:  
    default:   Verifying  : libthai-0.1.14-9.el7.x86_64                                57/63
    default:  
    default:   Verifying  : libXdamage-1.1.4-4.1.el7.x86_64                            58/63
    default:  
    default:   Verifying  : libXfixes-5.0.3-1.el7.x86_64                               59/63
    default:  
    default:   Verifying  : libfontenc-1.1.3-3.el7.x86_64                              60/63
    default:  
    default:   Verifying  : mesa-libglapi-18.0.5-4.el7_6.x86_64                        61/63
    default:  
    default:   Verifying  : copy-jdk-configs-3.3-10.el7_5.noarch                       62/63
    default:  
    default:   Verifying  : pixman-0.34.0-1.el7.x86_64                                 63/63
    default:  
    default: 
    default: Installed:
    default:   java-1.8.0-openjdk.x86_64 1:1.8.0.222.b10-0.el7_6                             
    default: 
    default: Dependency Installed:
    default:   alsa-lib.x86_64 0:1.1.6-2.el7                                                 
    default:   atk.x86_64 0:2.28.1-1.el7                                                     
    default:   cairo.x86_64 0:1.15.12-3.el7                                                  
    default:   copy-jdk-configs.noarch 0:3.3-10.el7_5                                        
    default:   dejavu-fonts-common.noarch 0:2.33-6.el7                                       
    default:   dejavu-sans-fonts.noarch 0:2.33-6.el7                                         
    default:   fontconfig.x86_64 0:2.13.0-4.3.el7                                            
    default:   fontpackages-filesystem.noarch 0:1.44-8.el7                                   
    default:   fribidi.x86_64 0:1.0.2-1.el7                                                  
    default:   gdk-pixbuf2.x86_64 0:2.36.12-3.el7                                            
    default:   giflib.x86_64 0:4.1.6-9.el7                                                   
    default:   graphite2.x86_64 0:1.3.10-1.el7_3                                             
    default:   gtk-update-icon-cache.x86_64 0:3.22.30-3.el7                                  
    default:   gtk2.x86_64 0:2.24.31-1.el7                                                   
    default:   harfbuzz.x86_64 0:1.7.5-2.el7                                                 
    default:   hicolor-icon-theme.noarch 0:0.12-7.el7                                        
    default:   jasper-libs.x86_64 0:1.900.1-33.el7                                           
    default:   java-1.8.0-openjdk-headless.x86_64 1:1.8.0.222.b10-0.el7_6                    
    default:   javapackages-tools.noarch 0:3.4.1-11.el7                                      
    default:   jbigkit-libs.x86_64 0:2.0-11.el7                                              
    default:   libICE.x86_64 0:1.0.9-9.el7                                                   
    default:   libSM.x86_64 0:1.2.2-2.el7                                                    
    default:   libX11.x86_64 0:1.6.5-2.el7                                                   
    default:   libX11-common.noarch 0:1.6.5-2.el7                                            
    default:   libXau.x86_64 0:1.0.8-2.1.el7                                                 
    default:   libXcomposite.x86_64 0:0.4.4-4.1.el7                                          
    default:   libXcursor.x86_64 0:1.1.15-1.el7                                              
    default:   libXdamage.x86_64 0:1.1.4-4.1.el7                                             
    default:   libXext.x86_64 0:1.3.3-3.el7                                                  
    default:   libXfixes.x86_64 0:5.0.3-1.el7                                                
    default:   libXft.x86_64 0:2.3.2-2.el7                                                   
    default:   libXi.x86_64 0:1.7.9-1.el7                                                    
    default:   libXinerama.x86_64 0:1.1.3-2.1.el7                                            
    default:   libXrandr.x86_64 0:1.5.1-2.el7                                                
    default:   libXrender.x86_64 0:0.9.10-1.el7                                              
    default:   libXtst.x86_64 0:1.2.3-1.el7                                                  
    default:   libXxf86vm.x86_64 0:1.1.4-1.el7                                               
    default:   libfontenc.x86_64 0:1.1.3-3.el7                                               
    default:   libglvnd.x86_64 1:1.0.1-0.8.git5baa1e5.el7                                    
    default:   libglvnd-egl.x86_64 1:1.0.1-0.8.git5baa1e5.el7                                
    default:   libglvnd-glx.x86_64 1:1.0.1-0.8.git5baa1e5.el7                                
    default:   libjpeg-turbo.x86_64 0:1.2.90-6.el7                                           
    default:   libthai.x86_64 0:0.1.14-9.el7                                                 
    default:   libtiff.x86_64 0:4.0.3-27.el7_3                                               
    default:   libwayland-client.x86_64 0:1.15.0-1.el7                                       
    default:   libwayland-server.x86_64 0:1.15.0-1.el7                                       
    default:   libxcb.x86_64 0:1.13-1.el7                                                    
    default:   libxshmfence.x86_64 0:1.2-1.el7                                               
    default:   lksctp-tools.x86_64 0:1.0.17-2.el7                                            
    default:   mesa-libEGL.x86_64 0:18.0.5-4.el7_6                                           
    default:   mesa-libGL.x86_64 0:18.0.5-4.el7_6                                            
    default:   mesa-libgbm.x86_64 0:18.0.5-4.el7_6                                           
    default:   mesa-libglapi.x86_64 0:18.0.5-4.el7_6                                         
    default:   pango.x86_64 0:1.42.4-2.el7_6                                                 
    default:   pcsc-lite-libs.x86_64 0:1.8.8-8.el7                                           
    default:   pixman.x86_64 0:0.34.0-1.el7                                                  
    default:   python-javapackages.noarch 0:3.4.1-11.el7                                     
    default:   python-lxml.x86_64 0:3.2.1-4.el7                                              
    default:   ttmkfdir.x86_64 0:3.0.9-42.el7                                                
    default:   tzdata-java.noarch 0:2019b-1.el7                                              
    default:   xorg-x11-font-utils.x86_64 1:7.5-21.el7                                       
    default:   xorg-x11-fonts-Type1.noarch 0:7.5-9.el7                                       
    default: Complete!
    default: Loaded plugins: fastestmirror
    default: Loading mirror speeds from cached hostfile
    default:  * base: mirrors.tuna.tsinghua.edu.cn
    default:  * extras: mirror.jdcloud.com
    default:  * updates: mirror.jdcloud.com
    default: Resolving Dependencies
    default: --> Running transaction check
    default: ---> Package curl.x86_64 0:7.29.0-51.el7 will be updated
    default: ---> Package curl.x86_64 0:7.29.0-51.el7_6.3 will be an update
    default: --> Processing Dependency: libcurl = 7.29.0-51.el7_6.3 for package: curl-7.29.0-51.el7_6.3.x86_64
    default: ---> Package git.x86_64 0:1.8.3.1-20.el7 will be installed
    default: --> Processing Dependency: perl-Git = 1.8.3.1-20.el7 for package: git-1.8.3.1-20.el7.x86_64
    default: --> Processing Dependency: perl(Term::ReadKey) for package: git-1.8.3.1-20.el7.x86_64
    default: --> Processing Dependency: perl(Git) for package: git-1.8.3.1-20.el7.x86_64
    default: --> Processing Dependency: perl(Error) for package: git-1.8.3.1-20.el7.x86_64
    default: ---> Package net-tools.x86_64 0:2.0-0.24.20131004git.el7 will be installed
    default: ---> Package unzip.x86_64 0:6.0-19.el7 will be installed
    default: ---> Package vim-enhanced.x86_64 2:7.4.160-6.el7_6 will be installed
    default: --> Processing Dependency: vim-common = 2:7.4.160-6.el7_6 for package: 2:vim-enhanced-7.4.160-6.el7_6.x86_64
    default: --> Processing Dependency: libgpm.so.2()(64bit) for package: 2:vim-enhanced-7.4.160-6.el7_6.x86_64
    default: ---> Package zip.x86_64 0:3.0-11.el7 will be installed
    default: --> Running transaction check
    default: ---> Package gpm-libs.x86_64 0:1.20.7-5.el7 will be installed
    default: ---> Package libcurl.x86_64 0:7.29.0-51.el7 will be updated
    default: ---> Package libcurl.x86_64 0:7.29.0-51.el7_6.3 will be an update
    default: ---> Package perl-Error.noarch 1:0.17020-2.el7 will be installed
    default: ---> Package perl-Git.noarch 0:1.8.3.1-20.el7 will be installed
    default: ---> Package perl-TermReadKey.x86_64 0:2.30-20.el7 will be installed
    default: ---> Package vim-common.x86_64 2:7.4.160-6.el7_6 will be installed
    default: --> Processing Dependency: vim-filesystem for package: 2:vim-common-7.4.160-6.el7_6.x86_64
    default: --> Running transaction check
    default: ---> Package vim-filesystem.x86_64 2:7.4.160-6.el7_6 will be installed
    default: --> Finished Dependency Resolution
    default: 
    default: Dependencies Resolved
    default: 
    default: ================================================================================
    default:  Package              Arch       Version                      Repository   Size
    default: ================================================================================
    default: Installing:
    default:  git                  x86_64     1.8.3.1-20.el7               updates     4.4 M
    default:  net-tools            x86_64     2.0-0.24.20131004git.el7     base        306 k
    default:  unzip                x86_64     6.0-19.el7                   base        170 k
    default:  vim-enhanced         x86_64     2:7.4.160-6.el7_6            updates     1.0 M
    default:  zip                  x86_64     3.0-11.el7                   base        260 k
    default: Updating:
    default:  curl                 x86_64     7.29.0-51.el7_6.3            updates     269 k
    default: Installing for dependencies:
    default:  gpm-libs             x86_64     1.20.7-5.el7                 base         32 k
    default:  perl-Error           noarch     1:0.17020-2.el7              base         32 k
    default:  perl-Git             noarch     1.8.3.1-20.el7               updates      55 k
    default:  perl-TermReadKey     x86_64     2.30-20.el7                  base         31 k
    default:  vim-common           x86_64     2:7.4.160-6.el7_6            updates     5.9 M
    default:  vim-filesystem       x86_64     2:7.4.160-6.el7_6            updates      10 k
    default: Updating for dependencies:
    default:  libcurl              x86_64     7.29.0-51.el7_6.3            updates     222 k
    default: 
    default: Transaction Summary
    default: ================================================================================
    default: Install  5 Packages (+6 Dependent packages)
    default: Upgrade  1 Package  (+1 Dependent package)
    default: Total download size: 13 M
    default: Downloading packages:
    default: Delta RPMs reduced 492 k of updates to 206 k (57% saved)
    default: --------------------------------------------------------------------------------
    default: Total                                              7.5 MB/s |  12 MB  00:01     
    default: Running transaction check
    default: Running transaction test
    default: Transaction test succeeded
    default: Running transaction
    default:   Updating   : libcurl-7.29.0-51.el7_6.3.x86_64                            1/15
    default:  
    default:   Installing : 1:perl-Error-0.17020-2.el7.noarch                           2/15
    default:  
    default:   Installing : gpm-libs-1.20.7-5.el7.x86_64                                3/15
    default:  
    default:   Installing : 2:vim-filesystem-7.4.160-6.el7_6.x86_64                     4/15
    default:  
    default:   Installing : 2:vim-common-7.4.160-6.el7_6.x86_64                         5/15
    default:  
    default:   Installing : perl-TermReadKey-2.30-20.el7.x86_64                         6/15
    default:  
    default:   Installing : git-1.8.3.1-20.el7.x86_64                                   7/15
    default:  
    default:   Installing : perl-Git-1.8.3.1-20.el7.noarch                              8/15
    default:  
    default:   Installing : 2:vim-enhanced-7.4.160-6.el7_6.x86_64                       9/15
    default:  
    default:   Updating   : curl-7.29.0-51.el7_6.3.x86_64                              10/15
    default:  
    default:   Installing : unzip-6.0-19.el7.x86_64                                    11/15
    default:  
    default:   Installing : zip-3.0-11.el7.x86_64                                      12/15
    default:  
    default:   Installing : net-tools-2.0-0.24.20131004git.el7.x86_64                  13/15
    default:  
    default:   Cleanup    : curl-7.29.0-51.el7.x86_64                                  14/15
    default:  
    default:   Cleanup    : libcurl-7.29.0-51.el7.x86_64                               15/15
    default:  
    default:   Verifying  : 2:vim-enhanced-7.4.160-6.el7_6.x86_64                       1/15
    default:  
    default:   Verifying  : net-tools-2.0-0.24.20131004git.el7.x86_64                   2/15
    default:  
    default:   Verifying  : perl-Git-1.8.3.1-20.el7.noarch                              3/15
    default:  
    default:   Verifying  : 1:perl-Error-0.17020-2.el7.noarch                           4/15
    default:  
    default:   Verifying  : perl-TermReadKey-2.30-20.el7.x86_64                         5/15
    default:  
    default:   Verifying  : git-1.8.3.1-20.el7.x86_64                                   6/15
    default:  
    default:   Verifying  : zip-3.0-11.el7.x86_64                                       7/15
    default:  
    default:   Verifying  : curl-7.29.0-51.el7_6.3.x86_64                               8/15
    default:  
    default:   Verifying  : 2:vim-filesystem-7.4.160-6.el7_6.x86_64                     9/15
    default:  
    default:   Verifying  : unzip-6.0-19.el7.x86_64                                    10/15
    default:  
    default:   Verifying  : 2:vim-common-7.4.160-6.el7_6.x86_64                        11/15
    default:  
    default:   Verifying  : libcurl-7.29.0-51.el7_6.3.x86_64                           12/15
    default:  
    default:   Verifying  : gpm-libs-1.20.7-5.el7.x86_64                               13/15
    default:  
    default:   Verifying  : curl-7.29.0-51.el7.x86_64                                  14/15
    default:  
    default:   Verifying  : libcurl-7.29.0-51.el7.x86_64                               15/15
    default:  
    default: 
    default: Installed:
    default:   git.x86_64 0:1.8.3.1-20.el7    net-tools.x86_64 0:2.0-0.24.20131004git.el7   
    default:   unzip.x86_64 0:6.0-19.el7      vim-enhanced.x86_64 2:7.4.160-6.el7_6         
    default:   zip.x86_64 0:3.0-11.el7       
    default: 
    default: Dependency Installed:
    default:   gpm-libs.x86_64 0:1.20.7-5.el7       perl-Error.noarch 1:0.17020-2.el7       
    default:   perl-Git.noarch 0:1.8.3.1-20.el7     perl-TermReadKey.x86_64 0:2.30-20.el7   
    default:   vim-common.x86_64 2:7.4.160-6.el7_6  vim-filesystem.x86_64 2:7.4.160-6.el7_6 
    default: 
    default: Updated:
    default:   curl.x86_64 0:7.29.0-51.el7_6.3                                               
    default: 
    default: Dependency Updated:
    default:   libcurl.x86_64 0:7.29.0-51.el7_6.3                                            
    default: Complete!
    default: Loaded plugins: fastestmirror
    default: Examining jenkins-2.176.2-1.1.noarch.rpm: jenkins-2.176.2-1.1.noarch
    default: Marking jenkins-2.176.2-1.1.noarch.rpm to be installed
    default: Resolving Dependencies
    default: --> Running transaction check
    default: ---> Package jenkins.noarch 0:2.176.2-1.1 will be installed
    default: --> Finished Dependency Resolution
    default: 
    default: Dependencies Resolved
    default: 
    default: ================================================================================
    default:  Package     Arch       Version           Repository                       Size
    default: ================================================================================
    default: Installing:
    default:  jenkins     noarch     2.176.2-1.1       /jenkins-2.176.2-1.1.noarch      74 M
    default: 
    default: Transaction Summary
    default: ================================================================================
    default: Install  1 Package
    default: Total size: 74 M
    default: Installed size: 74 M
    default: Downloading packages:
    default: Running transaction check
    default: Running transaction test
    default: Transaction test succeeded
    default: Running transaction
    default:   Installing : jenkins-2.176.2-1.1.noarch                                   1/1
    default:  
    default:   Verifying  : jenkins-2.176.2-1.1.noarch                                   1/1
    default:  
    default: 
    default: Installed:
    default:   jenkins.noarch 0:2.176.2-1.1                                                  
    default: Complete!
    default: Stopping jenkins (via systemctl):  
    default: [  OK  ]
    default: Archive:  /tmp/package/jenkins.zip
    default:    creating: /var/lib/jenkins/
    default:    creating: /var/lib/jenkins/.java/
    default:    creating: /var/lib/jenkins/.java/fonts/
    default:    creating: /var/lib/jenkins/.java/fonts/1.8.0_222/
    default:   inflating: /var/lib/jenkins/caches/git-fd1f3a6b94c08077929e575f6838c96a/.git/FETCH_HEAD  
...
...
    default:    creating: /var/lib/jenkins/caches/git-fd1f3a6b94c08077929e575f6838c96a/.git/logs/
    default:    creating: /var/lib/jenkins/caches/git-fd1f3a6b94c08077929e575f6838c96a/.git/logs/refs/
    default:    creating: /var/lib/jenkins/caches/git-fd1f3a6b94c08077929e575f6838c96a/.git/logs/refs/remotes/
    default:    creating: /var/lib/jenkins/caches/git-fd1f3a6b94c08077929e575f6838c96a/.git/logs/refs/remotes/origin/
    default:   inflating: /var/lib/jenkins/caches/git-fd1f3a6b94c08077929e575f6838c96a/.git/logs/refs/remotes/origin/master  
    default:   inflating: /var/lib/jenkins/queue.xml  
    default: Starting jenkins (via systemctl):  
    default: [  OK  ]
    default: ● jenkins.service - LSB: Jenkins Automation Server
    default:    Loaded: loaded (/etc/rc.d/init.d/jenkins; bad; vendor preset: disabled)
    default:    Active: active (running) since Thu 2019-08-22 17:10:50 UTC; 80ms ago
    default:      Docs: man:systemd-sysv-generator(8)
    default:   Process: 10517 ExecStart=/etc/rc.d/init.d/jenkins start (code=exited, status=0/SUCCESS)
    default:    CGroup: /system.slice/jenkins.service
    default:            └─10541 /etc/alternatives/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=8080 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
    default: 
    default: Aug 22 17:10:50 auto systemd[1]: Starting LSB: Jenkins Automation Server...
    default: Aug 22 17:10:50 auto runuser[10522]: pam_unix(runuser:session): session opened for user jenkins by (uid=0)
    default: Aug 22 17:10:50 auto runuser[10522]: pam_unix(runuser:session): session closed for user jenkins
    default: Aug 22 17:10:50 auto jenkins[10517]: Starting Jenkins [  OK  ]
    default: Aug 22 17:10:50 auto systemd[1]: Started LSB: Jenkins Automation Server.
    default: Loaded plugins: fastestmirror
    default: No Match for argument: docker
    default: No Match for argument: docker-client
    default: No Match for argument: docker-client-latest
    default: No Match for argument: docker-common
    default: No Match for argument: docker-latest
    default: No Match for argument: docker-latest-logrotate
    default: No Match for argument: docker-logrotate
    default: No Match for argument: docker-engine
    default: No Packages marked for removal
    default: Loaded plugins: fastestmirror
    default: Loading mirror speeds from cached hostfile
    default:  * base: mirrors.tuna.tsinghua.edu.cn
    default:  * extras: mirror.jdcloud.com
    default:  * updates: mirror.jdcloud.com
    default: Package yum-utils-1.1.31-50.el7.noarch already installed and latest version
    default: Resolving Dependencies
    default: --> Running transaction check
    default: ---> Package device-mapper-persistent-data.x86_64 0:0.7.3-3.el7 will be installed
    default: --> Processing Dependency: libaio.so.1(LIBAIO_0.4)(64bit) for package: device-mapper-persistent-data-0.7.3-3.el7.x86_64
    default: --> Processing Dependency: libaio.so.1(LIBAIO_0.1)(64bit) for package: device-mapper-persistent-data-0.7.3-3.el7.x86_64
    default: --> Processing Dependency: libaio.so.1()(64bit) for package: device-mapper-persistent-data-0.7.3-3.el7.x86_64
    default: ---> Package lvm2.x86_64 7:2.02.180-10.el7_6.8 will be installed
    default: --> Processing Dependency: lvm2-libs = 7:2.02.180-10.el7_6.8 for package: 7:lvm2-2.02.180-10.el7_6.8.x86_64
    default: --> Processing Dependency: liblvm2app.so.2.2(Base)(64bit) for package: 7:lvm2-2.02.180-10.el7_6.8.x86_64
    default: --> Processing Dependency: libdevmapper-event.so.1.02(Base)(64bit) for package: 7:lvm2-2.02.180-10.el7_6.8.x86_64
    default: --> Processing Dependency: liblvm2app.so.2.2()(64bit) for package: 7:lvm2-2.02.180-10.el7_6.8.x86_64
    default: --> Processing Dependency: libdevmapper-event.so.1.02()(64bit) for package: 7:lvm2-2.02.180-10.el7_6.8.x86_64
    default: --> Running transaction check
    default: ---> Package device-mapper-event-libs.x86_64 7:1.02.149-10.el7_6.8 will be installed
    default: ---> Package libaio.x86_64 0:0.3.109-13.el7 will be installed
    default: ---> Package lvm2-libs.x86_64 7:2.02.180-10.el7_6.8 will be installed
    default: --> Processing Dependency: device-mapper-event = 7:1.02.149-10.el7_6.8 for package: 7:lvm2-libs-2.02.180-10.el7_6.8.x86_64
    default: --> Running transaction check
    default: ---> Package device-mapper-event.x86_64 7:1.02.149-10.el7_6.8 will be installed
    default: --> Processing Dependency: device-mapper = 7:1.02.149-10.el7_6.8 for package: 7:device-mapper-event-1.02.149-10.el7_6.8.x86_64
    default: --> Running transaction check
    default: ---> Package device-mapper.x86_64 7:1.02.149-10.el7_6.7 will be updated
    default: --> Processing Dependency: device-mapper = 7:1.02.149-10.el7_6.7 for package: 7:device-mapper-libs-1.02.149-10.el7_6.7.x86_64
    default: ---> Package device-mapper.x86_64 7:1.02.149-10.el7_6.8 will be an update
    default: --> Running transaction check
    default: ---> Package device-mapper-libs.x86_64 7:1.02.149-10.el7_6.7 will be updated
    default: ---> Package device-mapper-libs.x86_64 7:1.02.149-10.el7_6.8 will be an update
    default: --> Finished Dependency Resolution
    default: 
    default: Dependencies Resolved
    default: 
    default: ================================================================================
    default:  Package                        Arch    Version                  Repository
    default:                                                                            Size
    default: ================================================================================
    default: Installing:
    default:  device-mapper-persistent-data  x86_64  0.7.3-3.el7              base     405 k
    default:  lvm2                           x86_64  7:2.02.180-10.el7_6.8    updates  1.3 M
    default: Installing for dependencies:
    default:  device-mapper-event            x86_64  7:1.02.149-10.el7_6.8    updates  189 k
    default:  device-mapper-event-libs       x86_64  7:1.02.149-10.el7_6.8    updates  188 k
    default:  libaio                         x86_64  0.3.109-13.el7           base      24 k
    default:  lvm2-libs                      x86_64  7:2.02.180-10.el7_6.8    updates  1.1 M
    default: Updating for dependencies:
    default:  device-mapper                  x86_64  7:1.02.149-10.el7_6.8    updates  293 k
    default:  device-mapper-libs             x86_64  7:1.02.149-10.el7_6.8    updates  321 k
    default: 
    default: Transaction Summary
    default: ================================================================================
    default: Install  2 Packages (+4 Dependent packages)
    default: Upgrade             ( 2 Dependent packages)
    default: 
    default: Total download size: 3.8 M
    default: Downloading packages:
    default: Delta RPMs reduced 321 k of updates to 171 k (46% saved)
    default: --------------------------------------------------------------------------------
    default: Total                                              5.1 MB/s | 3.6 MB  00:00     
    default: Running transaction check
    default: Running transaction test
    default: Transaction test succeeded
    default: Running transaction
    default:   Updating   : 7:device-mapper-1.02.149-10.el7_6.8.x86_64                  1/10
    default:  
    default:   Updating   : 7:device-mapper-libs-1.02.149-10.el7_6.8.x86_64             2/10
    default:  
    default:   Installing : 7:device-mapper-event-libs-1.02.149-10.el7_6.8.x86_64       3/10
    default:  
    default:   Installing : libaio-0.3.109-13.el7.x86_64                                4/10
    default:  
    default:   Installing : device-mapper-persistent-data-0.7.3-3.el7.x86_64            5/10
    default:  
    default:   Installing : 7:device-mapper-event-1.02.149-10.el7_6.8.x86_64            6/10
    default:  
    default:   Installing : 7:lvm2-libs-2.02.180-10.el7_6.8.x86_64                      7/10
    default:  
    default:   Installing : 7:lvm2-2.02.180-10.el7_6.8.x86_64                           8/10
    default:  
    default:   Cleanup    : 7:device-mapper-1.02.149-10.el7_6.7.x86_64                  9/10
    default:  
    default:   Cleanup    : 7:device-mapper-libs-1.02.149-10.el7_6.7.x86_64            10/10
    default:  
    default:   Verifying  : device-mapper-persistent-data-0.7.3-3.el7.x86_64            1/10
    default:  
    default:   Verifying  : 7:device-mapper-event-libs-1.02.149-10.el7_6.8.x86_64       2/10
    default:  
    default:   Verifying  : 7:device-mapper-libs-1.02.149-10.el7_6.8.x86_64             3/10
    default:  
    default:   Verifying  : 7:lvm2-2.02.180-10.el7_6.8.x86_64                           4/10
    default:  
    default:   Verifying  : 7:lvm2-libs-2.02.180-10.el7_6.8.x86_64                      5/10
    default:  
    default:   Verifying  : libaio-0.3.109-13.el7.x86_64                                6/10
    default:  
    default:   Verifying  : 7:device-mapper-1.02.149-10.el7_6.8.x86_64                  7/10
    default:  
    default:   Verifying  : 7:device-mapper-event-1.02.149-10.el7_6.8.x86_64            8/10
    default:  
    default:   Verifying  : 7:device-mapper-libs-1.02.149-10.el7_6.7.x86_64             9/10 
    default:   Verifying  : 7:device-mapper-1.02.149-10.el7_6.7.x86_64                 10/10
    default:  
    default: 
    default: Installed:
    default:   device-mapper-persistent-data.x86_64 0:0.7.3-3.el7                            
    default:   lvm2.x86_64 7:2.02.180-10.el7_6.8                                             
    default: 
    default: Dependency Installed:
    default:   device-mapper-event.x86_64 7:1.02.149-10.el7_6.8                              
    default:   device-mapper-event-libs.x86_64 7:1.02.149-10.el7_6.8                         
    default:   libaio.x86_64 0:0.3.109-13.el7                                                
    default:   lvm2-libs.x86_64 7:2.02.180-10.el7_6.8                                        
    default: 
    default: Dependency Updated:
    default:   device-mapper.x86_64 7:1.02.149-10.el7_6.8                                    
    default:   device-mapper-libs.x86_64 7:1.02.149-10.el7_6.8                               
    default: 
    default: Complete!
    default: Loaded plugins: fastestmirror
    default: Examining docker-ce-19.03.1-3.el7.x86_64.rpm: 3:docker-ce-19.03.1-3.el7.x86_64
    default: Marking docker-ce-19.03.1-3.el7.x86_64.rpm to be installed
    default: Examining docker-ce-cli-19.03.1-3.el7.x86_64.rpm: 1:docker-ce-cli-19.03.1-3.el7.x86_64
    default: Marking docker-ce-cli-19.03.1-3.el7.x86_64.rpm to be installed
    default: Examining containerd.io-1.2.6-3.3.el7.x86_64.rpm: containerd.io-1.2.6-3.3.el7.x86_64
    default: Marking containerd.io-1.2.6-3.3.el7.x86_64.rpm to be installed
    default: Resolving Dependencies
    default: --> Running transaction check
    default: ---> Package containerd.io.x86_64 0:1.2.6-3.3.el7 will be installed
    default: --> Processing Dependency: container-selinux >= 2:2.74 for package: containerd.io-1.2.6-3.3.el7.x86_64
    default: Loading mirror speeds from cached hostfile
    default:  * base: mirrors.tuna.tsinghua.edu.cn
    default:  * extras: mirror.jdcloud.com
    default:  * updates: mirror.jdcloud.com
    default: ---> Package docker-ce.x86_64 3:19.03.1-3.el7 will be installed
    default: --> Processing Dependency: libcgroup for package: 3:docker-ce-19.03.1-3.el7.x86_64
    default: ---> Package docker-ce-cli.x86_64 1:19.03.1-3.el7 will be installed
    default: --> Running transaction check
    default: ---> Package container-selinux.noarch 2:2.107-1.el7_6 will be installed
    default: --> Processing Dependency: policycoreutils-python for package: 2:container-selinux-2.107-1.el7_6.noarch
    default: ---> Package libcgroup.x86_64 0:0.41-20.el7 will be installed
    default: --> Running transaction check
    default: ---> Package policycoreutils-python.x86_64 0:2.5-29.el7_6.1 will be installed
    default: --> Processing Dependency: setools-libs >= 3.3.8-4 for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: libsemanage-python >= 2.5-14 for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: audit-libs-python >= 2.1.3-4 for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: python-IPy for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: libqpol.so.1(VERS_1.4)(64bit) for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: libqpol.so.1(VERS_1.2)(64bit) for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: libapol.so.4(VERS_4.0)(64bit) for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: checkpolicy for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: libqpol.so.1()(64bit) for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Processing Dependency: libapol.so.4()(64bit) for package: policycoreutils-python-2.5-29.el7_6.1.x86_64
    default: --> Running transaction check
    default: ---> Package audit-libs-python.x86_64 0:2.8.4-4.el7 will be installed
    default: ---> Package checkpolicy.x86_64 0:2.5-8.el7 will be installed
    default: ---> Package libsemanage-python.x86_64 0:2.5-14.el7 will be installed
    default: ---> Package python-IPy.noarch 0:0.75-6.el7 will be installed
    default: ---> Package setools-libs.x86_64 0:3.3.8-4.el7 will be installed
    default: --> Finished Dependency Resolution
    default: 
    default: Dependencies Resolved
    default: 
    default: ================================================================================
    default:  Package                Arch   Version         Repository                  Size
    default: ================================================================================
    default: Installing:
    default:  containerd.io          x86_64 1.2.6-3.3.el7   /containerd.io-1.2.6-3.3.el7.x86_64
    default:                                                                            96 M
    default:  docker-ce              x86_64 3:19.03.1-3.el7 /docker-ce-19.03.1-3.el7.x86_64
    default:                                                                           104 M
    default:  docker-ce-cli          x86_64 1:19.03.1-3.el7 /docker-ce-cli-19.03.1-3.el7.x86_64
    default:                                                                           169 M
    default: Installing for dependencies:
    default:  audit-libs-python      x86_64 2.8.4-4.el7     base                        76 k
    default:  checkpolicy            x86_64 2.5-8.el7       base                       295 k
    default:  container-selinux      noarch 2:2.107-1.el7_6 extras                      39 k
    default:  libcgroup              x86_64 0.41-20.el7     base                        66 k
    default:  libsemanage-python     x86_64 2.5-14.el7      base                       113 k
    default:  policycoreutils-python x86_64 2.5-29.el7_6.1  updates                    456 k
    default:  python-IPy             noarch 0.75-6.el7      base                        32 k
    default:  setools-libs           x86_64 3.3.8-4.el7     base                       620 k
    default: 
    default: Transaction Summary
    default: ================================================================================
    default: Install  3 Packages (+8 Dependent packages)
    default: 
    default: Total size: 370 M
    default: Total download size: 1.7 M
    default: Installed size: 374 M
    default: Downloading packages:
    default: --------------------------------------------------------------------------------
    default: Total                                              2.1 MB/s | 1.7 MB  00:00     
    default: Running transaction check
    default: Running transaction test
    default: Transaction test succeeded
    default: Running transaction
    default:   Installing : libcgroup-0.41-20.el7.x86_64                                1/11
    default:  
    default:   Installing : setools-libs-3.3.8-4.el7.x86_64                             2/11
    default:  
    default:   Installing : 1:docker-ce-cli-19.03.1-3.el7.x86_64                        3/11
    default:  
    default:   Installing : python-IPy-0.75-6.el7.noarch                                4/11
    default:  
    default:   Installing : libsemanage-python-2.5-14.el7.x86_64                        5/11
    default:  
    default:   Installing : audit-libs-python-2.8.4-4.el7.x86_64                        6/11
    default:  
    default:   Installing : checkpolicy-2.5-8.el7.x86_64                                7/11
    default:  
    default:   Installing : policycoreutils-python-2.5-29.el7_6.1.x86_64                8/11
    default:  
    default:   Installing : 2:container-selinux-2.107-1.el7_6.noarch                    9/11
    default:  
    default:   Installing : containerd.io-1.2.6-3.3.el7.x86_64                         10/11
    default:  
    default:   Installing : 3:docker-ce-19.03.1-3.el7.x86_64                           11/11
    default:  
    default:   Verifying  : libcgroup-0.41-20.el7.x86_64                                1/11
    default:  
    default:   Verifying  : checkpolicy-2.5-8.el7.x86_64                                2/11
    default:  
    default:   Verifying  : policycoreutils-python-2.5-29.el7_6.1.x86_64                3/11
    default:  
    default:   Verifying  : audit-libs-python-2.8.4-4.el7.x86_64                        4/11
    default:  
    default:   Verifying  : libsemanage-python-2.5-14.el7.x86_64                        5/11
    default:  
    default:   Verifying  : 2:container-selinux-2.107-1.el7_6.noarch                    6/11
    default:  
    default:   Verifying  : python-IPy-0.75-6.el7.noarch                                7/11
    default:  
    default:   Verifying  : containerd.io-1.2.6-3.3.el7.x86_64                          8/11
    default:  
    default:   Verifying  : 1:docker-ce-cli-19.03.1-3.el7.x86_64                        9/11
    default:  
    default:   Verifying  : 3:docker-ce-19.03.1-3.el7.x86_64                           10/11
    default:  
    default:   Verifying  : setools-libs-3.3.8-4.el7.x86_64                            11/11
    default:  
    default: 
    default: Installed:
    default:   containerd.io.x86_64 0:1.2.6-3.3.el7     docker-ce.x86_64 3:19.03.1-3.el7    
    default:   docker-ce-cli.x86_64 1:19.03.1-3.el7    
    default: 
    default: Dependency Installed:
    default:   audit-libs-python.x86_64 0:2.8.4-4.el7                                        
    default:   checkpolicy.x86_64 0:2.5-8.el7                                                
    default:   container-selinux.noarch 2:2.107-1.el7_6                                      
    default:   libcgroup.x86_64 0:0.41-20.el7                                                
    default:   libsemanage-python.x86_64 0:2.5-14.el7                                        
    default:   policycoreutils-python.x86_64 0:2.5-29.el7_6.1                                
    default:   python-IPy.noarch 0:0.75-6.el7                                                
    default:   setools-libs.x86_64 0:3.3.8-4.el7                                             
    default: 
    default: Complete!
    default: Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
    default: ● docker.service - Docker Application Container Engine
    default:    Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
    default:    Active: active (running) since Thu 2019-08-22 17:11:31 UTC; 38ms ago
    default:      Docs: https://docs.docker.com
    default:  Main PID: 10898 (dockerd)
    default:     Tasks: 13
    default:    Memory: 42.0M
    default:    CGroup: /system.slice/docker.service
    default:            └─10898 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
    default: 
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.297142956Z" level=info msg="ClientConn switching balancer to \"pick_first\"" module=grpc
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.297187812Z" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc0006be9e0, CONNECTING" module=grpc
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.297820073Z" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc0006be9e0, READY" module=grpc
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.515597524Z" level=info msg="Loading containers: start."
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.644557050Z" level=info msg="Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. Daemon option --bip can be used to set a preferred IP address"
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.702660839Z" level=info msg="Loading containers: done."
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.744486527Z" level=info msg="Docker daemon" commit=74b1e89 graphdriver(s)=overlay2 version=19.03.1
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.744997982Z" level=info msg="Daemon has completed initialization"
    default: Aug 22 17:11:31 auto dockerd[10898]: time="2019-08-22T17:11:31.762590991Z" level=info msg="API listen on /var/run/docker.sock"
    default: Aug 22 17:11:31 auto systemd[1]: Started Docker Application Container Engine.
    default: Unable to find image 'hello-world:latest' locally
    default: latest: Pulling from library/hello-world
    default: 1b930d010525: Pulling fs layer
    default: 1b930d010525: Download complete
    default: 1b930d010525: Pull complete
    default: Digest: sha256:451ce787d12369c5df2a32c85e5a03d52cbcef6eb3586dd03075f3034f10adcd
    default: Status: Downloaded newer image for hello-world:latest
    default: 
    default: Hello from Docker!
    default: This message shows that your installation appears to be working correctly.
    default: 
    default: To generate this message, Docker took the following steps:
    default:  1. The Docker client contacted the Docker daemon.
    default:  2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    default:     (amd64)
    default:  3. The Docker daemon created a new container from that image which runs the
    default:     executable that produces the output you are currently reading.
    default:  4. The Docker daemon streamed that output to the Docker client, which sent it
    default:     to your terminal.
    default: 
    default: To try something more ambitious, you can run an Ubuntu container with:
    default:  $ docker run -it ubuntu bash
    default: 
    default: Share images, automate workflows, and more with a free Docker ID:
    default:  https://hub.docker.com/
    default: 
    default: For more examples and ideas, visit:
    default:  https://docs.docker.com/get-started/
    default: docker version >= 1.12
    default: {"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
    default: Success.
    default: You need to restart docker to take effect: sudo systemctl restart docker 
    default: ● docker.service - Docker Application Container Engine
    default:    Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
    default:    Active: active (running) since Thu 2019-08-22 17:11:59 UTC; 23ms ago
    default:      Docs: https://docs.docker.com
    default:  Main PID: 11286 (dockerd)
    default:     Tasks: 13
    default:    Memory: 43.9M
    default:    CGroup: /system.slice/docker.service
    default:            └─11286 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
    default: 
    default: Aug 22 17:11:58 auto dockerd[11286]: time="2019-08-22T17:11:58.947880648Z" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc000866620, CONNECTING" module=grpc
    default: Aug 22 17:11:58 auto dockerd[11286]: time="2019-08-22T17:11:58.948275382Z" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc000866620, READY" module=grpc
    default: Aug 22 17:11:58 auto dockerd[11286]: time="2019-08-22T17:11:58.964607528Z" level=info msg="[graphdriver] using prior storage driver: overlay2"
    default: Aug 22 17:11:58 auto dockerd[11286]: time="2019-08-22T17:11:58.971908586Z" level=info msg="Loading containers: start."
    default: Aug 22 17:11:59 auto dockerd[11286]: time="2019-08-22T17:11:59.092077195Z" level=info msg="Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. Daemon option --bip can be used to set a preferred IP address"
    default: Aug 22 17:11:59 auto dockerd[11286]: time="2019-08-22T17:11:59.140494651Z" level=info msg="Loading containers: done."
    default: Aug 22 17:11:59 auto dockerd[11286]: time="2019-08-22T17:11:59.167767602Z" level=info msg="Docker daemon" commit=74b1e89 graphdriver(s)=overlay2 version=19.03.1
    default: Aug 22 17:11:59 auto dockerd[11286]: time="2019-08-22T17:11:59.167847429Z" level=info msg="Daemon has completed initialization"
    default: Aug 22 17:11:59 auto dockerd[11286]: time="2019-08-22T17:11:59.183866340Z" level=info msg="API listen on /var/run/docker.sock"
    default: Aug 22 17:11:59 auto systemd[1]: Started Docker Application Container Engine.
    default:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    default:                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
 12 39.8M   12 4927k    0     0  4871k      0  0:00:08  0:00:01  0:00:07 4873k
 34 39.8M   34 13.6M    0     0  6972k      0  0:00:05  0:00:02  0:00:03 6974k
 57 39.8M   57 22.8M    0     0  7757k      0  0:00:05  0:00:03  0:00:02 7756k
 80 39.8M   80 32.2M    0     0  8231k      0  0:00:04  0:00:04 --:--:-- 8231k
100 39.8M  100 39.8M    0     0  8516k      0  0:00:04  0:00:04 --:--:-- 8540k
    default: * minikube v1.2.0 on linux (amd64)
    default: * using image repository registry.cn-hangzhou.aliyuncs.com/google_containers
    default: * Creating none VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
    default: * Configuring environment for Kubernetes v1.15.0 on Docker 19.03.1
    default: * Downloading kubelet v1.15.0
    default: * Downloading kubeadm v1.15.0
    default: * Pulling images ...
    default: * Launching Kubernetes ... 
    default: * Configuring local host environment ...
    default: 
    default:   - https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md
    default: 
    default: 
    default:   - sudo mv /root/.kube /root/.minikube $HOME
    default:   - sudo chown -R $USER $HOME/.kube $HOME/.minikube
    default: 
    default: * This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
    default: * Verifying:
    default: ! The 'none' driver provides limited isolation and may reduce system security and reliability.
    default: ! For more information, see:
    default: ! kubectl and minikube configuration will be stored in /root
    default: ! To use kubectl or minikube commands as your own user, you may
    default: ! need to relocate them. For example, to overwrite your own settings:
    default:  apiserver
    default:  proxy
    default:  etcd
    default:  scheduler
    default:  controller
    default:  dns
    default: 
    default: * Done! kubectl is now configured to use "minikube"
    default: * heapster was successfully enabled
    default: 6.14.2: Pulling from library/node
    default: 3d77ce4481b1: Pulling fs layer
    default: 7d2f32934963: Pulling fs layer
    default: 0c5cf711b890: Pulling fs layer
    default: 9593dc852d6b: Pulling fs layer
    default: 4e3b8a1eb914: Pulling fs layer
    default: ddcf13cc1951: Pulling fs layer
    default: 2e460d114172: Pulling fs layer
    default: d94b1226fbf2: Pulling fs layer
    default: 4e3b8a1eb914: Waiting
    default: ddcf13cc1951: Waiting
    default: 2e460d114172: Waiting
    default: d94b1226fbf2: 
    default: Waiting
    default: 9593dc852d6b: Waiting
    default: 7d2f32934963: Verifying Checksum
    default: 7d2f32934963: Download complete
    default: 0c5cf711b890: Verifying Checksum
    default: 0c5cf711b890: Download complete
    default: 4e3b8a1eb914: Verifying Checksum
    default: 4e3b8a1eb914: Download complete
    default: ddcf13cc1951: Verifying Checksum
    default: ddcf13cc1951: Download complete
    default: 3d77ce4481b1: Verifying Checksum
    default: 3d77ce4481b1: Download complete
    default: d94b1226fbf2: Verifying Checksum
    default: d94b1226fbf2: Download complete
    default: 3d77ce4481b1: Pull complete
    default: 7d2f32934963: Pull complete
    default: 0c5cf711b890: Pull complete
    default: 9593dc852d6b: Verifying Checksum
    default: 9593dc852d6b: Download complete
    default: 9593dc852d6b: Pull complete
    default: 4e3b8a1eb914: Pull complete
    default: ddcf13cc1951: Pull complete
    default: 2e460d114172: Verifying Checksum
    default: 2e460d114172: Download complete
    default: 2e460d114172: Pull complete
    default: d94b1226fbf2: Pull complete
    default: Digest: sha256:85a878cb14deb5a5a59944e906d43ef400e182e9fcc81a6beb18907f52309261
    default: Status: Downloaded newer image for daocloud.io/library/node:6.14.2
    default: daocloud.io/library/node:6.14.2
    default: Using default tag: latest
    default: latest: Pulling from library/nginx
    default: 0a4690c5d889: Pulling fs layer
    default: 9719afee3eb7: Pulling fs layer
    default: 44446b456159: Pulling fs layer
    default: 44446b456159: Verifying Checksum
    default: 44446b456159: Download complete
    default: 9719afee3eb7: Verifying Checksum
    default: 9719afee3eb7: 
    default: Download complete
    default: 0a4690c5d889: Verifying Checksum
    default: 0a4690c5d889: Download complete
    default: 0a4690c5d889: Pull complete
    default: 9719afee3eb7: Pull complete
    default: 44446b456159: Pull complete
    default: Digest: sha256:f83b2ffd963ac911f9e638184c8d580cc1f3139d5c8c33c87c3fb90aebdebf76
    default: Status: Downloaded newer image for daocloud.io/library/nginx:latest
    default: daocloud.io/library/nginx:latest
    default: Using default tag: latest
    default: latest: Pulling from gogs/gogs
    default: [DEPRECATION NOTICE] registry v2 schema1 support will be removed in an upcoming release. Please contact admins of the docker.io registry NOW to avoid future disruption.
    default: 050382585609: 
    default: Pulling fs layer
    default: da970bb7d5e8: Pulling fs layer
    default: 3d985387bce7: Pulling fs layer
    default: cafc497b4de2: Pulling fs layer
    default: a4be98e46571: Pulling fs layer
    default: 97142f536ce9: Pulling fs layer
    default: e208b6376d69: Pulling fs layer
    default: 153cbf5ae1ce: Pulling fs layer
    default: f3008dcd5700: Pulling fs layer
    default: 0ebc0ebf1a9b: Pulling fs layer
    default: 97142f536ce9: Waiting
    default: e208b6376d69: Waiting
    default: cafc497b4de2: Waiting
    default: a4be98e46571: Waiting
    default: 153cbf5ae1ce: Waiting
    default: f3008dcd5700: Waiting
    default: 0ebc0ebf1a9b: Waiting
    default: da970bb7d5e8: Verifying Checksum
    default: da970bb7d5e8: Download complete
    default: cafc497b4de2: Verifying Checksum
    default: cafc497b4de2: Download complete
    default: a4be98e46571: Verifying Checksum
    default: a4be98e46571: Download complete
    default: 3d985387bce7: Verifying Checksum
    default: 3d985387bce7: Download complete
    default: e208b6376d69: Verifying Checksum
    default: e208b6376d69: Download complete
    default: 050382585609: Verifying Checksum
    default: 050382585609: Download complete
    default: 050382585609: Pull complete
    default: da970bb7d5e8: Pull complete
    default: 3d985387bce7: Pull complete
    default: cafc497b4de2: Pull complete
    default: a4be98e46571: Pull complete
    default: 153cbf5ae1ce: Verifying Checksum
    default: 153cbf5ae1ce: Download complete
    default: 0ebc0ebf1a9b: Download complete
    default: 97142f536ce9: Verifying Checksum
    default: 97142f536ce9: Download complete
    default: 97142f536ce9: Pull complete
    default: e208b6376d69: Pull complete
    default: 153cbf5ae1ce: Pull complete
    default: f3008dcd5700: Verifying Checksum
    default: f3008dcd5700: Download complete
    default: f3008dcd5700: Pull complete
    default: 0ebc0ebf1a9b: Pull complete
    default: Digest: sha256:0474162845fa99a80d58a9fc94ac35fcc72e3519fa9e96c1a97230c354182939
    default: Status: Downloaded newer image for gogs/gogs:latest
    default: docker.io/gogs/gogs:latest
    default: Sending build context to Docker daemon  300.5MB
    default: Step 1/5 : FROM daocloud.io/library/node:6.14.2
    default:  ---> 00165cd5d0c0
    default: Step 2/5 : EXPOSE 8080
    default:  ---> Running in eafbf9790ae4
    default: Removing intermediate container eafbf9790ae4
    default:  ---> b4c7211e7cdb
    default: Step 3/5 : ENV ENV_TAG INIT
    default:  ---> Running in 8d0ab1fd3205
    default: Removing intermediate container 8d0ab1fd3205
    default:  ---> fb4c8dcfcc95
    default: Step 4/5 : COPY server.js .
    default:  ---> 7d82243934ce
    default: Step 5/5 : CMD node server.js
    default:  ---> Running in 402c09b6e80f
    default: Removing intermediate container 402c09b6e80f
    default:  ---> a16efbc141a0
    default: Successfully built a16efbc141a0
    default: Successfully tagged registry.cn-hangzhou.aliyuncs.com/wilmos/nodejs:INIT_v1
    default: deployment.apps/nodejs created
    default: service/nodejs exposed
    default: deployment.apps/nodejs-stag created
    default: service/nodejs-stag exposed
    default: deployment.apps/nodejs-prod created
    default: service/nodejs-prod exposed
    default: nodejs dev/test env:
    default: http://10.1.0.165:30374
    default: nodejs stage env:
    default: http://10.1.0.165:31334
    default: nodejs prod env:
    default: http://10.1.0.165:30818
    default: Sending build context to Docker daemon  300.5MB
    default: Step 1/2 : FROM daocloud.io/library/nginx
    default:  ---> 98ebf73aba75
    default: Step 2/2 : COPY env.txt /usr/share/nginx/html/
    default:  ---> be9c775ae699
    default: Successfully built be9c775ae699
    default: Successfully tagged registry.cn-hangzhou.aliyuncs.com/wilmos/nginx:INIT_v1
    default: deployment.apps/nginx created
    default: service/nginx exposed
    default: deployment.apps/nginx-stag created
    default: service/nginx-stag exposed
    default: deployment.apps/nginx-prod created
    default: service/nginx-prod exposed
    default: nginx dev/test env:
    default: http://10.1.0.165:32547/env.txt
    default: nginx stage env:
    default: http://10.1.0.165:32404/env.txt
    default: nginx prod env:
    default: http://10.1.0.165:30219/env.txt
    default: Archive:  /tmp/package/gogs.zip
    default:    creating: /var/lib/gogs/
    default:    creating: /var/lib/gogs/gogs/
    default:    creating: /var/lib/gogs/gogs/data/
    default:   inflating: /var/lib/gogs/gogs/data/gogs.db  
...
...
    default:   inflating: /var/lib/gogs/git/.gitconfig  
    default:    creating: /var/lib/gogs/ssh/
    default:   inflating: /var/lib/gogs/ssh/ssh_host_rsa_key  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_rsa_key.pub  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_dsa_key  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_dsa_key.pub  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_ecdsa_key  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_ecdsa_key.pub  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_ed25519_key  
    default:   inflating: /var/lib/gogs/ssh/ssh_host_ed25519_key.pub  
    default: d5f129fe2e9606f6784db59539346e3ee22416768ad37b4b14a0984cf9118db8
    default: env init finished!
==> default: Running provisioner: shell...
    default: Running: inline script
    default: * Stopping "minikube" in none ...
    default: * "minikube" stopped.
    default: * minikube v1.2.0 on linux (amd64)
    default: * using image repository registry.cn-hangzhou.aliyuncs.com/google_containers
    default: * Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
    default: * Restarting existing none VM for "minikube" ...
    default: * Waiting for SSH access ...
    default: * Configuring environment for Kubernetes v1.15.0 on Docker 19.03.1
    default: * Relaunching Kubernetes v1.15.0 using kubeadm ... 
    default: * Configuring local host environment ...
    default: 
    default:   - https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md
    default: ! The 'none' driver provides limited isolation and may reduce system security and reliability.
    default: ! For more information, see:
    default: ! kubectl and minikube configuration will be stored in /root
    default: ! To use kubectl or minikube commands as your own user, you may
    default: 
    default:   - sudo mv /root/.kube /root/.minikube $HOME
    default:   - sudo chown -R $USER $HOME/.kube $HOME/.minikube
    default: 
    default: * This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
    default: ! need to relocate them. For example, to overwrite your own settings:
    default: * Verifying:
    default:  apiserver
    default:  proxy
    default:  etcd
    default:  scheduler
    default:  controller
    default:  dns
    default: 
    default: * Done! kubectl is now configured to use "minikube"
==> default: Running provisioner: shell...
    default: Running: inline script
    default: gogs
    default: gogs is up, follow this link to access the web:
    default: http://10.1.0.165:10080
    default: default password:
    default: root/root
==> default: Running provisioner: shell...
    default: Running: inline script
    default: env is up, follow this link to access the web:
    default: http://10.1.0.155:8080
    default: default password:
    default: admin/admin

real	11m55.325s
user	0m31.427s
sys	0m5.126s
nothing@pc:~/vagrant/cicd$ 
~~~

不得不说，从之前半个多小时，现在下降到12分钟不到，提速还是很明显的


---

# 总结


~~~
git clone https://github.com/wilmosfang/cicd.git
cd cicd
vagrant up
~~~


* TOC
{:toc}

---


[virtualbox]:https://www.virtualbox.org/
[minikube]:https://minikube.sigs.k8s.io/
[vagrant]:https://www.vagrantup.com/
[gogs]:https://gogs.io/


