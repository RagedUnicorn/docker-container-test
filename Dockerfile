############################################
# Container Structure Test build stage
############################################
FROM alpine:3.24.3 AS build

# renovate: datasource=github-releases depName=GoogleContainerTools/container-structure-test
ARG CONTAINER_STRUCTURE_VERSION=v1.22.1
# Set by buildx per target platform (amd64, arm64) - matches the upstream asset suffix
ARG TARGETARCH

LABEL org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-container-test" \
      org.opencontainers.image.licenses="MIT"

# Install build dependencies
RUN apk add --no-cache --update \
    ca-certificates \
    wget

# Download the Container Structure Test binary, then verify it before use:
#   verify the binary's checksum against the published checksums.txt
# Upstream publishes NO signature (no cosign/GPG), so a SHA256 checksum is the
# strongest verification available.
RUN set -eux; \
    cd /tmp; \
    base="https://github.com/GoogleContainerTools/container-structure-test/releases/download/${CONTAINER_STRUCTURE_VERSION}"; \
    file="container-structure-test-linux-${TARGETARCH}"; \
    wget -O "${file}" "${base}/${file}"; \
    wget -O checksums.txt "${base}/checksums.txt"; \
    grep "  ${file}\$" checksums.txt > "${file}.sha256"; \
    [ -s "${file}.sha256" ]; \
    sha256sum -c "${file}.sha256"; \
    mv "${file}" container-structure-test; \
    chmod +x container-structure-test

############################################
# Runtime stage
############################################
FROM alpine:3.24.3

# renovate: datasource=github-releases depName=GoogleContainerTools/container-structure-test
ARG CONTAINER_STRUCTURE_VERSION=v1.22.1
ARG BUILD_DATE
ARG VERSION

LABEL org.opencontainers.image.title="Container Structure Test on Alpine Linux" \
      org.opencontainers.image.description="Google Container Structure Test for validating Docker images, built on Alpine Linux" \
      org.opencontainers.image.vendor="ragedunicorn" \
      org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-container-test" \
      org.opencontainers.image.documentation="https://github.com/RagedUnicorn/docker-container-test/blob/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.base.name="docker.io/library/alpine:3.24.3"

# Install runtime dependencies only
RUN apk add --no-cache --update \
    ca-certificates \
    docker-cli

# Copy Container Structure Test binary from build stage
COPY --from=build /tmp/container-structure-test /usr/bin/container-structure-test

# Set the entrypoint to container-structure-test binary
ENTRYPOINT ["container-structure-test", "test"]

# Default to showing help if no arguments provided
CMD ["--help"]
