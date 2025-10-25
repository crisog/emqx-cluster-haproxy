# Deploy and Host EMQX Cluster + HAProxy on Railway

A **production-ready 3-node EMQX cluster** with HAProxy load balancing. Provides **high availability**, automatic failover, sticky session routing, and weighted load distribution. Built for mission-critical IoT applications requiring **zero-downtime** deployments and horizontal scalability with secure cluster communication.

## About Hosting EMQX Cluster + HAProxy

This template deploys three EMQX broker nodes in a cluster behind an HAProxy load balancer. The cluster ensures continuous operation when individual nodes fail or restart.

HAProxy routes MQTT clients based on their client identifier, ensuring sticky sessions while automatically failing over to healthy nodes. The cluster uses Erlang cookie authentication for secure inter-node communication and synchronizes shared state across all brokers.

Railway's private networking handles connectivity between components with TLS termination at the edge. Health checks monitor all backends and instantly reroute traffic during failures. The setup supports MQTT over TCP and WebSocket, with a load-balanced admin dashboard accessible from any node.

## Common Use Cases

- **IoT Device Management**: Deploy device fleets with automatic failover when nodes go down.
- **High-Throughput Telemetry**: Handle millions of concurrent connections distributed across cluster nodes for vehicle tracking, environmental monitoring, or utility metering
- **Real-Time Messaging**: Build scalable chat and collaboration systems with session persistence across server updates and zero-downtime deployments
- **Distributed IoT Platforms**: Serve geographically distributed devices through weighted load balancing based on node capacity
- **Financial Data Feeds**: Support low-latency pub/sub messaging for market data with QoS guarantees and retained messages for state recovery

## Key Benefits

- **Zero-Downtime Deployments**: Roll out updates one node at a time while maintaining service availability.
- **Horizontal Scalability**: Add more nodes to the cluster without reconfiguration as your IoT fleet grows beyond single-server capacity
- **Automatic Failover**: Node crashes or restarts are invisible to clients; HAProxy instantly reroutes to healthy nodes within milliseconds
- **Load Distribution**: Balance millions of connections across multiple servers with configurable weights for different node capacities
- **Cluster Reliability**: Follows EMQX clustering best practices with sticky sessions, health monitoring, and shared state synchronization

## Dependencies for EMQX Cluster + HAProxy Hosting

- **EMQX 5.4.1**: Open-source MQTT broker with native clustering support and handles millions of concurrent connections with distributed state management
- **HAProxy 3.2.7**: TCP/HTTP load balancer with MQTT protocol awareness, sticky sessions, and health checking
- **Railway Private Networking**: Required for inter-node cluster communication between EMQX instances
- **Environment Variables**: Erlang cookie and admin password must be shared across all cluster nodes

### Deployment Dependencies

- [EMQX Clustering Documentation](https://docs.emqx.com/en/emqx/latest/deploy/cluster/introduction.html)
- [HAProxy with EMQX](https://docs.emqx.com/en/emqx/latest/deploy/cluster/lb-haproxy.html)
- [MQTTX Client Tools](https://mqttx.app/)

### Implementation Details

**Sticky Sessions:**
HAProxy inspects MQTT CONNECT packets to extract client identifiers, ensuring session affinity while automatically failing over to healthy nodes:

```haproxy
backend mqtt_backend
  mode tcp
  # 30-minute session persistence with 1M client capacity
  stick-table type string len 32 size 1000k expire 30m
  stick on req.payload(0,0),mqtt_field_value(connect,client_identifier)

  # Round-robin failover across healthy nodes
  server emqx1 ${EMQX1_HOST}:1883
  server emqx2 ${EMQX2_HOST}:1883
  server emqx3 ${EMQX3_HOST}:1883
```

**Distributed Cluster Discovery:**
EMQX nodes automatically discover and synchronize with each other using static seeds over Railway's private network:

```bash
# All nodes share cluster configuration
EMQX_CLUSTER__DISCOVERY_STRATEGY=static
EMQX_CLUSTER__STATIC__SEEDS=[
  emqx@${{emqx1.RAILWAY_PRIVATE_DOMAIN}},
  emqx@${{emqx2.RAILWAY_PRIVATE_DOMAIN}},
  emqx@${{emqx3.RAILWAY_PRIVATE_DOMAIN}}
]
```

**Weighted Load Balancing:**
Distribute load based on node capacity (useful for different Railway plan sizes)

```bash
EMQX1_WEIGHT=5  # Higher capacity node
EMQX2_WEIGHT=2  # Standard node
EMQX3_WEIGHT=3  # Standard node
```

**Unified HTTP Frontend:**
Railway exposes a single public HTTP endpoint that intelligently routes traffic to appropriate backends:

```haproxy
frontend http_public
  bind *:${PORT}
  mode http

  # Route WebSocket MQTT connections to /mqtt path
  acl is_websocket hdr(Connection) -i upgrade
  acl is_websocket hdr(Upgrade) -i websocket
  acl mqtt_ws_path path_beg /mqtt
  use_backend mqtt_ws_http_backend if is_websocket mqtt_ws_path

  # Route HAProxy stats to /stats path
  acl is_stats path_beg /stats
  use_backend stats_backend if is_stats

  # Default: EMQX dashboard for all other requests
  default_backend emqx_dashboard_backend
```

This configuration allows you to access:
- WebSocket MQTT at `wss://your-app.railway.app/mqtt`
- HAProxy stats at `https://your-app.railway.app/stats`
- EMQX dashboard at `https://your-app.railway.app/`

**Security & Monitoring:**

- **128-character Erlang cookie** secures cluster RPC communication
- **32-character random admin password** generated on deployment
- **HTTP health checks** monitor EMQX status API (`/api/v5/status`)
- **HAProxy stats dashboard** (port 8888) provides real-time cluster visibility

## Why Deploy EMQX Cluster + HAProxy on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying EMQX Cluster + HAProxy on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

Railway's private networking handles inter-node cluster communication automatically. No VPN or firewall configuration needed. Deploy close to your IoT devices for minimal latency, scale resources as your fleet grows, and leverage automatic TLS termination for all client connections.
