ARG EMQX_VERSION=5.4.1
FROM emqx/emqx:${EMQX_VERSION}

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD ["/opt/emqx/bin/emqx", "ctl", "status"]