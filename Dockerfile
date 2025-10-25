FROM alpine:3.20

COPY frps /usr/local/bin/frps
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY frps.ini.tmpl /etc/frp/frps.ini.tmpl

RUN chmod +x /usr/local/bin/frps /usr/local/bin/entrypoint.sh \
    && adduser -D -H -s /sbin/nologin frp \
    && mkdir -p /etc/frp /var/log/frp \
    && chown -R frp:frp /etc/frp /var/log/frp

USER frp

EXPOSE 7000/tcp 7000/udp 7500/tcp

# 这些只是默认值，运行时可覆盖
ENV FRPS_BIND_PORT=7000 \
    FRPS_DASHBOARD_PORT=7500 \
    FRPS_DASHBOARD_USER=admin \
    FRPS_DASHBOARD_PWD= \
    FRPS_TOKEN= \
    VHOST_HTTP_PORT= \
    VHOST_HTTPS_PORT= \
    FRPS_BIND_ADDR=0.0.0.0 \
    FRPS_ALLOW_PORTS=

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frps", "-c", "/etc/frp/frps.ini"]
