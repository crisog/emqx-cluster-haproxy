# EMQX Cluster with HAProxy Load Balancer

A 3-node EMQX MQTT broker cluster with HAProxy load balancing, designed for deployment on Railway or local Docker Compose environments.

<p align="center">
  <a href="https://railway.com/deploy/emqx-cluster-haproxy?referralCode=crisog">
    <img src="https://railway.app/button.svg" alt="Deploy on Railway">
  </a>
</p>

## Architecture

```
Internet (TLS encrypted via Railway)
    ↓
HAProxy Load Balancer
    ├─→ EMQX Node 1 (emqx1)
    ├─→ EMQX Node 2 (emqx2)
    └─→ EMQX Node 3 (emqx3)
```

## Features

- **3-Node Cluster**: High availability with automatic failover
- **Sticky Sessions**: MQTT clients maintain consistent connections using client identifier
- **Load Balancing**: Weighted round-robin distribution with health checks
- **Secure Clustering**: Erlang cookie-based authentication between nodes
- **Admin Dashboard**: Load-balanced access to EMQX web UI (port 18083)
- **Monitoring**: HAProxy stats dashboard (port 8888)

## Quick Start

### Local Development

```bash
# Clone and start
git clone <repository-url>
cd emqx-cluster-haproxy
cp .env.sample .env
docker-compose up -d

# Access services
# MQTT: mqtt://localhost:1883
# WebSocket: ws://localhost:8083
# Dashboard: http://localhost:18083 (admin / check .env)
# HAProxy Stats: http://localhost:8888/stats
```

### Railway Deployment

Click the deploy button above. After deployment, find the admin password in the HAProxy service environment variables (`EMQX_DASHBOARD__DEFAULT_PASSWORD`).

## Configuration

Edit `.env` to customize:
- HAProxy/EMQX versions
- Load balancing weights
- Ports and hostnames

See `.env.sample` for all options.

## Benchmarking

```bash
# Test with 10 MQTT subscribers
mqttx bench sub -c 10 -t "t/%c" -h localhost -p 1883 -V 5

# Check distribution across nodes
docker exec emqx1 /opt/emqx/bin/emqx ctl broker stats | grep "connections.count"
docker exec emqx2 /opt/emqx/bin/emqx ctl broker stats | grep "connections.count"
docker exec emqx3 /opt/emqx/bin/emqx ctl broker stats | grep "connections.count"
```

## Credits

Based on the [EMQX HAProxy example](https://github.com/emqx/emqx-usage-example/tree/main/mqtt-lb-haproxy) from the official EMQX usage examples repository.

## References

- [EMQX Documentation](https://docs.emqx.com/)
- [HAProxy Documentation](https://www.haproxy.org/#docs)
- [MQTTX Client](https://mqttx.app/)
