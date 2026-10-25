# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 mtalavi
FROM coollabsio/coolify@sha256:d96931bef961ab5c173edfca190e03d4b77e93dee622da780ddfa22cfa2b77cf
USER root
ARG NGINX_VERSION=1.31.8-r1
RUN set -eux; \
    cp -a /etc/nginx /tmp/disclosure-nginx-preserved; \
    apk add --no-cache --upgrade "nginx@nginx=${NGINX_VERSION}"; \
    rm -rf /etc/nginx; \
    mv /tmp/disclosure-nginx-preserved /etc/nginx; \
    nginx -v
USER www-data

