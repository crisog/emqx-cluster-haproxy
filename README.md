# EMQX Cluster with HAProxy Load Balancer

A production-ready EMQX MQTT broker cluster with HAProxy load balancing, designed for deployment on Railway or local Docker Compose environments.

## Architecture

```
Internet (TLS encrypted via Railway)
    ↓
HAProxy Load Balancer
    ├─→ EMQX Node 1 (emqx1)
    ├─→ EMQX Node 2 (emqx2)
    └─→ EMQX Node 3 (emqx3)
```

### Load Balancing Strategy

- **MQTT (port 1883)**: Sticky session load balancing based on MQTT client identifier

  - Ensures the same client always connects to the same node
  - 10 second inspection delay for MQTT packet parsing
  - MQTT protocol validation

- **WebSocket (port 8083)**: Round-robin with health checks

  - Distributes WebSocket connections evenly
  - Weighted load balancing (configurable via environment variables)

- **Stats (port 8888)**: HAProxy statistics dashboard
  - Real-time monitoring of backend servers
  - Connection metrics and health status

## Features

- **Configurable Versions**: Both HAProxy and EMQX versions can be set via environment variables
- **Dynamic Configuration**: All hostnames, ports, and weights can be configured through environment variables
- **EMQX Clustering**: 3-node EMQX cluster with static discovery
- **Railway Ready**: Designed for deployment on Railway with private networking
- **Health Checks**: Automatic health monitoring for all services
- **Sticky Sessions**: MQTT clients maintain consistent connections using client identifier

## Prerequisites

- Docker and Docker Compose
- For benchmarking: `mqttx-cli` - see [MQTTX installation guide](https://mqttx.app/)
  - macOS: `brew install emqx/mqttx/mqttx-cli`
  - Linux/Windows: See https://mqttx.app/ for installation instructions

## Quick Start

### Local Development

1. Clone the repository:

```bash
git clone <repository-url>
cd emqx-cluster-haproxy
```

2. Start the cluster:

```bash
docker-compose up -d
```

3. Verify the cluster is running:

```bash
docker ps
```

4. Access HAProxy stats:

```
http://localhost:8888/stats
```

5. Connect MQTT clients to:

```
mqtt://localhost:1883
ws://localhost:8083
```

## Configuration

Copy `.env.sample` to `.env` and customize as needed:

```bash
cp .env.sample .env
```

See `.env.sample` for all available configuration options including HAProxy version, EMQX version, hostnames, ports, and load balancing weights.

## Benchmarking

Test the cluster with MQTTX CLI:

```bash
# Subscribe benchmark with 10 clients
mqttx bench sub -c 10 -t "t/%c" -h localhost -p 1883 -V 5

# Check connection distribution
docker exec emqx1 /opt/emqx/bin/emqx ctl broker stats | grep "connections.count"
docker exec emqx2 /opt/emqx/bin/emqx ctl broker stats | grep "connections.count"
docker exec emqx3 /opt/emqx/bin/emqx ctl broker stats | grep "connections.count"
```

Expected output: 10 connections distributed across the 3 nodes (e.g., 4/3/3)

## Monitoring

Access HAProxy stats dashboard at `http://localhost:8888/stats` to monitor:

- Active/backup server status
- Connection counts per backend
- Request/response rates
- Health check status

## References

- [EMQX Official Documentation](https://docs.emqx.com/)
- [HAProxy Documentation](https://www.haproxy.org/#docs)
- [Railway Documentation](https://docs.railway.app/)

## Credits

This project is based on the [EMQX HAProxy example](https://github.com/emqx/emqx-usage-example/tree/main/mqtt-lb-haproxy) from the official EMQX usage examples repository.
