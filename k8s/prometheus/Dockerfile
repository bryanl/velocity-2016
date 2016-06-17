FROM quay.io/prometheus/busybox:latest
MAINTAINER bliles@digitalocean.com

ENV PROMETHEUS_VERSION 0.20.0
ENV PROMDIR "/prometheus-${PROMETHEUS_VERSION}.linux-amd64"

ADD https://github.com/prometheus/prometheus/releases/download/${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz /tmp/prometheus.tar.gz

RUN mkdir -p /etc/prometheus /prometheus-storage && \
  tar -C / -xzf /tmp/prometheus.tar.gz && \
  mv ${PROMDIR} /prometheus && \
  rm /tmp/prometheus.tar.gz

EXPOSE 9090
WORKDIR /prometheus

COPY prometheus.yaml /etc/prometheus

ENTRYPOINT ["/prometheus/prometheus"]
CMD        [ "-config.file=/etc/prometheus/prometheus.yaml", \
             "-storage.local.path=/prometheus-storage", \
             "-web.console.libraries=/prometheus/console_libraries", \
             "-web.console.templates=/prometheus/consoles" ]
