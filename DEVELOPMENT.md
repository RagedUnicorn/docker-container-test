# Development Guide

This document provides information for developers working on the Container Structure Test Docker image.

## Development Environment

### Prerequisites

- Docker installed and running
- Docker Compose installed
- Git for version control
- Text editor or IDE

### Project Structure

```
docker-container-test/
├── Dockerfile              # Main image definition
├── docker-compose.yml      # Basic usage configuration
├── docker-compose.dev.yml  # Development environment
├── docker-compose.test.yml # Test orchestration
├── docker-compose.test.template # Template for custom tests
├── .env                    # Default environment variables
├── test/                   # Test examples
│   └── example/            # Alpine Linux test examples
│       ├── alpine_test.yml
│       ├── alpine_command_test.yml
│       └── alpine_metadata_test.yml
└── docs/                   # Documentation assets
    ├── alpine_linux_logo.svg
    ├── docker_container_test.png
    └── license_badge.svg
```

## Development Workflow

### 1. Local Development Mode

The `docker-compose.dev.yml` file provides an interactive development environment:

```bash
# Build the image locally
docker compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker compose -f docker-compose.dev.yml run --rm container-test-dev

# Inside the container, you can run container-structure-test manually
container-structure-test --help
container-structure-test test --image alpine:latest --config /test/example/alpine_test.yml
container-structure-test test --image nginx:latest --config /test/nginx_test.yml
```

The development mode:

- Overrides the entrypoint to `/bin/sh` for interactive access
- Sets a custom prompt to identify the development environment
- Keeps STDIN open and allocates a TTY
- Provides full access to the container-structure-test binary

### 2. Building the Image

```bash
# Basic build
docker build -t ragedunicorn/container-test:dev .

# Build with specific versions
docker build \
  --build-arg CONTAINER_STRUCTURE_VERSION=v1.19.3 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=1.19.3-alpine3.22.1-1 \
  -t ragedunicorn/container-test:1.19.3-alpine3.22.1-1 .

# Multi-platform build (requires buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ragedunicorn/container-test:dev .
```

### 3. Testing Your Changes

After making changes, always run the test suite:

```bash
# Build the image locally first
docker build -t ragedunicorn/container-test:test .

# Test the Container Structure Test image itself
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml run test-all

# Test a specific functionality
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml up container-test-command
```

**Important**: Always test with locally built images. Docker Hub and GitHub Container Registry may override certain labels during automated builds, which can cause metadata tests to fail with registry-pulled images.

See [TEST.md](TEST.md) for detailed testing information.

## Making Changes

### Version Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically manage dependency updates:

- **Container Structure Test**: Renovate monitors GitHub releases and creates PRs for new versions
- **Alpine Linux**: Renovate monitors Docker Hub and creates PRs for new Alpine versions

When Renovate creates a PR:

1. Review the changes in the PR
2. Check the CI/CD pipeline passes all tests
3. Test the build locally if it's a major version update
4. Merge the PR if everything looks good

Manual version updates are rarely needed, but if required:

```dockerfile
# Container Structure Test version
ARG CONTAINER_STRUCTURE_VERSION=v1.20.0

# Alpine base image
FROM alpine:3.22.1
```

### Modifying the Dockerfile

When making changes to the Dockerfile:

1. **Multi-stage build**: Maintain separation between build and runtime stages
2. **Minimal runtime**: Only include necessary components in the final stage
3. **Labels**: Follow OCI specification for all labels
4. **Arguments**: Use ARG for values that might change between builds
5. **Cache efficiency**: Order commands from least to most frequently changed

### Adding New Features

1. Implement the feature in the appropriate stage
2. Update documentation to describe the new capability
3. Add tests to verify the feature works
4. Update examples if applicable
5. Consider backward compatibility

## Code Style and Best Practices

### Dockerfile Best Practices

1. **Security**: Don't include unnecessary tools in the final image
2. **Size optimization**: Use `--no-cache` with apk to avoid package cache
3. **Layer caching**: Group related commands to minimize layers
4. **Build args**: Document all build arguments with comments
5. **Labels**: Include all required OCI labels

Example:

```dockerfile
# Good: Combines update and install, removes cache
RUN apk add --no-cache ca-certificates

# Bad: Separate commands, leaves cache
RUN apk update
RUN apk add ca-certificates
```

### Documentation Standards

1. **README.md**: Keep focused on user-facing information
2. **Technical docs**: Use separate files (TEST.md, DEVELOPMENT.md, etc.)
3. **Examples**: Provide working examples for all use cases
4. **Comments**: Add comments in configuration files for clarity
5. **Commit messages**: Use conventional format:
   - `feat:` New features
   - `fix:` Bug fixes
   - `docs:` Documentation changes
   - `chore:` Maintenance tasks
   - `refactor:` Code refactoring
   - `test:` Test additions/changes

### Testing Guidelines

1. **Test coverage**: Include tests for all critical functionality
2. **Example tests**: Maintain working examples in `test/example/`
3. **Template updates**: Keep docker-compose.test.template current
4. **Cross-platform**: Ensure tests work on both linux/amd64 and linux/arm64

## Debugging

### Common Issues

**Build failures:**

```bash
# Verbose build output
docker build --progress=plain --no-cache -t ragedunicorn/container-test:debug .

# Check specific build stage
docker build --target build -t container-test-build-stage .
```

**Binary not found:**

```bash
# Check if binary was downloaded correctly
docker run --rm --entrypoint sh ragedunicorn/container-test:dev -c "ls -la /usr/local/bin/"

# Check binary architecture
docker run --rm --entrypoint sh ragedunicorn/container-test:dev -c "file /usr/local/bin/container-structure-test"
```

**Permission issues:**

```bash
# Check file permissions
docker run --rm --entrypoint sh ragedunicorn/container-test:dev -c "stat /usr/local/bin/container-structure-test"

# Test execution directly
docker run --rm --entrypoint sh ragedunicorn/container-test:dev -c "/usr/local/bin/container-structure-test version"
```

### Debugging Container Structure Test Issues

When Container Structure Test itself has issues:

```bash
# Run with debug output
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  ragedunicorn/container-test:dev \
  test --image alpine:latest --config /test/example/alpine_test.yml --verbosity debug

# Check Container Structure Test version
docker run --rm ragedunicorn/container-test:dev version

# Validate test file syntax
docker run --rm -v $(pwd)/test:/test \
  ragedunicorn/container-test:dev \
  test --config /test/example/alpine_test.yml --dry-run
```

## Contributing

### Before Submitting Changes

1. Run the full test suite
2. Update documentation if needed
3. Add tests for new features
4. Ensure your code follows the existing style
5. Write clear commit messages

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to your fork
5. Open a Pull Request with a clear description


## Release Process

See [RELEASE.md](RELEASE.md) for information about creating releases.

## Maintenance

### Automated Maintenance

Renovate runs weekly (every Monday) to check for updates:

1. **Container Structure Test**: Automatically creates PRs for new releases
2. **Alpine Linux**: Automatically creates PRs for new versions
3. **Manual tasks**: 
   - Review and merge Renovate PRs
   - Update documentation if features change
   - Create releases after merging updates

### Security Considerations

1. **Minimal attack surface**: Only include necessary components
2. **No secrets**: Never include credentials or tokens
3. **Regular updates**: Merge Renovate PRs promptly for security patches
4. **Vulnerability scanning**: Run security scanners on releases

### Deprecation Policy

1. Support at least 2 major versions of Container Structure Test
2. Announce deprecations in release notes
3. Provide migration guides when breaking changes occur
4. Follow semantic versioning principles
