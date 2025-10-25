ARG HAPROXY_VERSION=3.2.7-alpine
FROM haproxy:${HAPROXY_VERSION}

USER root
# Install gettext for envsubst - use apk for Alpine, apt-get for Debian
RUN if command -v apk > /dev/null; then \
      apk add --no-cache gettext; \
    else \
      apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*; \
    fi

COPY haproxy.cfg.template /tmp/haproxy.cfg.template

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Ensure haproxy user can write config
RUN chown -R haproxy:haproxy /usr/local/etc/haproxy

USER haproxy

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
