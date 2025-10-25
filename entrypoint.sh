#!/usr/bin/env sh
set -euo pipefail

TEMPLATE="/etc/frp/frps.ini.tmpl"
CONF="/etc/frp/frps.ini"

# 渲染配置（按需注释 vhost_*）
# 允许端口范围（allow_ports）如果未设置则不写
# 其余核心配置均来自环境变量
{
  echo "; generated at $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "[common]"
  echo "bind_addr = ${FRPS_BIND_ADDR:-0.0.0.0}"
  echo "bind_port = ${FRPS_BIND_PORT:-7000}"

  # 允许端口范围（供客户端映射的公网端口），可为空
  if [ -n "${FRPS_ALLOW_PORTS:-}" ]; then
    echo "allow_ports = ${FRPS_ALLOW_PORTS}"
  fi

  # dashboard
  echo "dashboard_addr = 0.0.0.0"
  echo "dashboard_port = ${FRPS_DASHBOARD_PORT:-7500}"
  if [ -n "${FRPS_DASHBOARD_USER:-}" ]; then
    echo "dashboard_user = ${FRPS_DASHBOARD_USER}"
  fi
  if [ -n "${FRPS_DASHBOARD_PWD:-}" ]; then
    echo "dashboard_pwd = ${FRPS_DASHBOARD_PWD}"
  fi

  # 身份验证 token
  if [ -n "${FRPS_TOKEN:-}" ]; then
    echo "token = ${FRPS_TOKEN}"
  fi

  # vhost 端口（仅当提供变量时启用，否则注释掉）
  if [ -n "${VHOST_HTTP_PORT:-}" ]; then
    echo "vhost_http_port = ${VHOST_HTTP_PORT}"
  else
    echo "; vhost_http_port = 80"
  fi

  if [ -n "${VHOST_HTTPS_PORT:-}" ]; then
    echo "vhost_https_port = ${VHOST_HTTPS_PORT}"
  else
    echo "; vhost_https_port = 443"
  fi

  # 其他推荐设置（可按需开放）
  echo "log_file = /var/log/frp/frps.log"
  echo "log_level = info"
  echo "log_max_days = 3"
} > "$CONF"

exec "$@"
