############################################
# Container Structure Test build stage
############################################
FROM alpine:3.22.1 AS build

ARG CONTAINER_STRUCTURE_VERSION=v1.19.3

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

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

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

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
