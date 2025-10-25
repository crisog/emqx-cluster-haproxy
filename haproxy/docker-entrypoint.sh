#!/bin/sh
set -e

export EMQX1_HOST="${EMQX1_HOST:-emqx1.railway.internal}"
export EMQX2_HOST="${EMQX2_HOST:-emqx2.railway.internal}"
export EMQX3_HOST="${EMQX3_HOST:-emqx3.railway.internal}"
export EMQX_MQTT_PORT="${EMQX_MQTT_PORT:-1883}"
export EMQX_WS_PORT="${EMQX_WS_PORT:-8083}"
export EMQX_DASHBOARD_PORT="${EMQX_DASHBOARD_PORT:-18083}"
export EMQX1_WEIGHT="${EMQX1_WEIGHT:-5}"
export EMQX2_WEIGHT="${EMQX2_WEIGHT:-2}"
export EMQX3_WEIGHT="${EMQX3_WEIGHT:-3}"
export PORT="${PORT:-8080}"

envsubst < /tmp/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

exec /usr/local/bin/docker-entrypoint.sh "$@"
