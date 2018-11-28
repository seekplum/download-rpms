# 指定镜像源
FROM centos:centos7.4.1708

# 将工作目录设置为 /assets
WORKDIR /assets

# 将当前目录内容复制到位于 /assets 中的容器中
ADD assets /assets

# 下载rpm插件
RUN yum install -y yum-plugin-downloadonly

# 安装createrepo包
RUN yum install -y createrepo

# 创建目录 
ENV RPMS_DATA /rpms/data/admin/files/repo/rhel74-x86_64
ENV PORT 80

RUN mkdir -p ${RPMS_DATA}

# 使端口 80 可供此容器外的环境使用
EXPOSE ${PORT}

ENTRYPOINT ["sh", "/assets/entrypoint.sh"] 
