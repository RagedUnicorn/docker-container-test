############################################
# Container Structure Test build stage
############################################
FROM alpine:3.22.1 AS build

ARG CONTAINER_STRUCTURE_VERSION=v1.19.3

LABEL org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-container-test" \
      org.opencontainers.image.licenses="MIT"

# Install build dependencies
RUN apk add --no-cache --update \
    ca-certificates \
    wget

# Download Container Structure Test binary
RUN cd /tmp && \
    wget -O container-structure-test https://github.com/GoogleContainerTools/container-structure-test/releases/download/${CONTAINER_STRUCTURE_VERSION}/container-structure-test-linux-amd64 && \
    chmod +x container-structure-test

############################################
# Runtime stage
############################################
FROM alpine:3.22.1

ARG CONTAINER_STRUCTURE_VERSION=v1.19.3
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
      org.opencontainers.image.base.name="docker.io/library/alpine:3.22.1"

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
