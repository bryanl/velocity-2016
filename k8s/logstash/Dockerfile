FROM quay.io/pires/docker-logstash:2.3.2
MAINTAINER bliles@digitalocean.com

RUN apk add curl

# Logstash config
COPY config/logstash.conf /logstash/config/logstash.conf