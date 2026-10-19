FROM nginx:1.28-alpine

ARG BUILD_ID=local-001
LABEL org.opencontainers.image.title="DevOps Intern NGINX Assessment" \
      org.opencontainers.image.description="Static NGINX page with build-time metadata" \
      org.opencontainers.image.revision="${BUILD_ID}"

COPY index.html /usr/share/nginx/html/index.html

# Keep the value safe for substitution and reject empty/unsafe identifiers.
RUN case "$BUILD_ID" in *[!a-zA-Z0-9._-]*|'') echo "Invalid BUILD_ID: use letters, digits, dot, underscore or hyphen" >&2; exit 1 ;; esac \
    && sed -i "s|__BUILD_ID__|${BUILD_ID}|g" /usr/share/nginx/html/index.html \
    && ! grep -q '__BUILD_ID__' /usr/share/nginx/html/index.html

EXPOSE 80
