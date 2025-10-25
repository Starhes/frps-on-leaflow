# ===================
# 阶段 1: 构建器
# (此部分无变化)
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

# 从 builder 阶段复制 frps 二进制文件
COPY --from=builder /frp_*_linux_amd64/frps /usr/local/bin/frps

# 创建配置目录
RUN mkdir -p /etc/frp

# 复制配置文件模板和启动脚本
COPY frps.ini /etc/frp/frps.ini
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 给启动脚本执行权限
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露端口
# 7000: frp通信端口
# 80, 443: 可能的HTTP/HTTPS代理端口
EXPOSE 7000 80 443

# 设置入口点为我们的启动脚本
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
