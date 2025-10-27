ARG HAPROXY_VERSION=3.2.7
FROM haproxy:${HAPROXY_VERSION}

USER root

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN chown -R haproxy:haproxy /usr/local/etc/haproxy

USER haproxy