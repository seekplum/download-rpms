# 下载RPM依赖包 & 搭建yum源服务

## 前言
在 `CentOS`/`RedHat` 中，安装软件绝大部分都是通过 `yum` 的方式进行安装的。针对无外网的情况下，只能去官网搜索 `RPM`包或源码包进行安装，一个软件往往都是十几二十几个依赖包的，也就是说你想安装一个软件，你需要把它依赖包都安装成功。

通过`downloadonly`插件可以下载相关依赖包，但带来的问题是若原机器安装过该包，则无法再次下载相关依赖包，只会下载自身软件包。

通过 `centos7.4` 基础镜像来完成下载依赖包和启动 `http-server` 功能，于是就有了本项目。

## 功能
* 1.下载软件依赖包到指定共享目录
* 2.在镜像内启动yum源服务，客户端(需要安装软件的节点)配置yum源后可以通过yum安装

## 查看帮助信息
> docker run --rm download-rpms -h

## 示例
下载 `wget` 包到 `/root/rpms` 目录，并启动yum源服务

> docker run \-\-rm -it \-\-name download-rpms -p 8080:80 -v /root/rpms:/rpms/data/admin/files/repo/rhel74-x86_64 download-rpms wget


在客户端配置yum源

```bash
cat >/etc/yum.repos.d/rpm-install.repo <<EOF
[td-agent]
name=Server
baseurl=http://10.10.20.98:8080
enable=1
gpgcheck=0
EOF
```

yum安装wget

yum install -y wget