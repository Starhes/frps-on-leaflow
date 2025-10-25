#!/bin/sh

# 配置文件路径
CONFIG_FILE="/etc/frp/frps.ini"

echo "--- Starting FRP Server Configuration ---"

# 检查是否设置了 VHOST_HTTP_PORT 环境变量
if [ -n "$VHOST_HTTP_PORT" ]; then
  echo "VHOST_HTTP_PORT is set. Enabling HTTP proxy on port $VHOST_HTTP_PORT..."
  # 使用 sed 命令取消注释并设置端口
  # sed -i "s/^#vhost_http_port.*/vhost_http_port = $VHOST_HTTP_PORT/" 会查找以 #vhost_http_port 开头的行，并将其替换为新行
  sed -i "s/^#vhost_http_port.*/vhost_http_port = $VHOST_HTTP_PORT/" "$CONFIG_FILE"
else
  echo "VHOST_HTTP_PORT is not set. HTTP proxy will remain disabled."
fi

# 检查是否设置了 VHOST_HTTPS_PORT 环境变量
if [ -n "$VHOST_HTTPS_PORT" ]; then
  echo "VHOST_HTTPS_PORT is set. Enabling HTTPS proxy on port $VHOST_HTTPS_PORT..."
  sed -i "s/^#vhost_https_port.*/vhost_https_port = $VHOST_HTTPS_PORT/" "$CONFIG_FILE"
else
  echo "VHOST_HTTPS_PORT is not set. HTTPS proxy will remain disabled."
fi

echo "--- FRP Server Configuration Finished ---"
echo "--- Final configuration ---"
cat "$CONFIG_FILE"
echo "--------------------------"

# 使用 exec 启动 frps，这样 frps 进程可以接收信号（如 docker stop）
exec /usr/local/bin/frps -c "$CONFIG_FILE"
