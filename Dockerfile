FROM alpine:3.20 AS prep
ARG APP_VERSION=dev
COPY src/index.html /tmp/index.html
RUN sed -i "s|__APP_VERSION__|${APP_VERSION}|g" /tmp/index.html

FROM nginxinc/nginx-unprivileged:1.27-alpine
ARG APP_VERSION=dev
LABEL org.opencontainers.image.title="nile-storefront"
LABEL org.opencontainers.image.version="${APP_VERSION}"

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=prep /tmp/index.html /usr/share/nginx/html/index.html

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health || exit 1

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]