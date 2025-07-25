FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ARG FLUENTBIT_VERSION=4.0.5
ENV FLUENTBIT_VERSION=${FLUENTBIT_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl gnupg ca-certificates jq lsb-release && \
    curl -fsSL https://packages.fluentbit.io/fluentbit.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/fluentbit.gpg && \
    echo "deb https://packages.fluentbit.io/debian/bookworm $(lsb_release -cs) main" > /etc/apt/sources.list.d/fluentbit.list && \
    apt-get update && \
    apt-get install -y fluent-bit=${FLUENTBIT_VERSION} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /usr/sbin/nologin fluent-bit && \
    mkdir -p /fluent-bit/etc /fluent-bit/storage /tmp/fluent-bit && \
    chown -R fluent-bit:fluent-bit /fluent-bit /tmp/fluent-bit

USER fluent-bit

EXPOSE 2020

CMD ["/opt/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
