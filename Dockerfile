# ===================
# 阶段 1: 构建器
# 用于下载和解压 frp
# ===================
FROM alpine:latest AS builder

ARG FRP_VERSION

RUN apk add --no-cache wget tar

RUN FRP_VERSION_NO_V=${FRP_VERSION#v} && \
    wget --no-check-certificate https://github.com/fatedier/frp/releases/download/${FRP_VERSION}/frp_${FRP_VERSION_NO_V}_linux_amd64.tar.gz && \
    tar -xzvf frp_${FRP_VERSION_NO_V}_linux_amd64.tar.gz

# ===================
# 阶段 2: 最终镜像
# ===================
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache openssh supervisor

# 从 builder 阶段复制 frps 二进制文件
COPY --from=builder /frp_*_linux_amd64/frps /usr/local/bin/frps

# 创建统一的配置目录 /config
RUN mkdir -p /config/ssl

# 配置SSH (生成主机密钥)
RUN ssh-keygen -A

# 将所有配置文件复制到 /config 目录
COPY supervisord.conf /config/
COPY sshd_config /config/
COPY frps.ini /config/

# 暴露端口
EXPOSE 22 7000

# 启动supervisor，并指定配置文件在 /config 目录
CMD ["/usr/bin/supervisord", "-c", "/config/supervisord.conf"]
