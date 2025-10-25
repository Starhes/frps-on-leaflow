# 仅复制 action 下载好的 frps 二进制到最终镜像
FROM alpine:3.20

# frps 可执行文件由 GitHub Actions 在构建前下载到 build 上下文
# 我们只需复制进来
COPY frps /usr/local/bin/frps
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY frps.ini.tmpl /etc/frp/frps.ini.tmpl

RUN chmod +x /usr/local/bin/frps /usr/local/bin/entrypoint.sh \
    && adduser -D -H -s /sbin/nologin frp \
    && mkdir -p /etc/frp /var/log/frp \
    && chown -R frp:frp /etc/frp /var/log/frp

USER frp

# 默认暴露：7000 监听客户端（tcp/udp），7500 web 面板（tcp）
# 其他公网服务端口请按需映射（容器运行时 -p 指定）
EXPOSE 7000/tcp 7000/udp 7500/tcp

# 可选：通过环境变量传参（也可在运行时覆盖）
ENV FRPS_BIND_PORT=7000 \
    FRPS_DASHBOARD_PORT=7500 \
    FRPS_DASHBOARD_USER=admin \
    FRPS_DASHBOARD_PWD= \
    FRPS_TOKEN= \
    VHOST_HTTP_PORT= \
    VHOST_HTTPS_PORT= \
    FRPS_BIND_ADDR=0.0.0.0 \
    FRPS_ALLOW_PORTS= # 例如 "20000-20100,30000-30100"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frps", "-c", "/etc/frp/frps.ini"]
