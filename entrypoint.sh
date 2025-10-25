#!/bin/sh

# 配置文件路径
CONFIG_FILE="/etc/frp/frps.ini"

echo "--- Starting FRP Server Configuration ---"

# 1. 设置认证令牌
if [ -n "$TOKEN" ]; then
  echo "TOKEN is set. Updating frps.ini..."
  sed -i "s/^token.*/token = $TOKEN/" "$CONFIG_FILE"
else
  echo "WARNING: TOKEN is not set. Using default value from frps.ini."
fi

# 2. 设置仪表盘用户名
if [ -n "$DASHBOARD_USER" ]; then
  echo "DASHBOARD_USER is set. Updating frps.ini..."
  sed -i "s/^dashboard_user.*/dashboard_user = $DASHBOARD_USER/" "$CONFIG_FILE"
else
  echo "WARNING: DASHBOARD_USER is not set. Using default value from frps.ini."
fi

# 3. 设置仪表盘密码
if [ -n "$DASHBOARD_PWD" ]; then
  echo "DASHBOARD_PWD is set. Updating frps.ini..."
  sed -i "s/^dashboard_pwd.*/dashboard_pwd = $DASHBOARD_PWD/" "$CONFIG_FILE"
else
  echo "WARNING: DASHBOARD_PWD is not set. Using default value from frps.ini."
fi

# 4. 设置 VHOST HTTP 端口
if [ -n "$VHOST_HTTP_PORT" ]; then
  echo "VHOST_HTTP_PORT is set. Enabling HTTP proxy on port $VHOST_HTTP_PORT..."
  sed -i "s/^#vhost_http_port.*/vhost_http_port = $VHOST_HTTP_PORT/" "$CONFIG_FILE"
else
  echo "VHOST_HTTP_PORT is not set. HTTP proxy will remain disabled."
fi

# 5. 设置 VHOST HTTPS 端口
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

# 使用 exec 启动 frps
exec /usr/local/bin/frps -c "$CONFIG_FILE"
