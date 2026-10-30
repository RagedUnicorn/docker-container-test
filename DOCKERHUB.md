# Container Structure Test Alpine Docker Image

![Docker Container Test](https://raw.githubusercontent.com/RagedUnicorn/docker-container-test/master/docs/docker_container_test_banner.png)

A lightweight Google Container Structure Test installation on Alpine Linux for automated Docker image validation.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/container-test:latest

# Or pull specific version (see the Tags tab for the available versions)
docker pull ragedunicorn/container-test:<container-test-version>-alpine<alpine-version>-<build>

# Run tests on an image
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image nginx:latest --config /test/nginx_test.yml
```

## Features

- 🚀 **Small footprint**: Minimal Alpine Linux base image
- 📦 **Container Structure Test**: Pinned upstream release, kept current by Renovate
- 🔍 **Comprehensive testing**: Validate file existence, command outputs, and metadata
- 🏗️ **Multi-platform**: Supports linux/amd64 and linux/arm64
- 🐳 **Docker-in-Docker**: Tests images through Docker socket mounting

## Test Types

**File Tests**: Verify file/directory existence and content  
**Command Tests**: Execute commands and validate outputs  
**Metadata Tests**: Check labels, exposed ports, volumes, and other image properties

## Usage Examples

### Test file existence
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image myapp:latest --config /test/app_test.yml
```

### Run with auto-pull
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --pull --image myapp:latest --config /test/app_test.yml
```

### Test specific platform
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --platform linux/arm64 --image myapp:latest --config /test/app_test.yml
```

### Generate test report
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image myapp:latest --config /test/app_test.yml \
  --output json --test-report /test/report.json
```

## Sample Test Configuration

Create a test file (e.g., `test/app_test.yml`):

```yaml
schemaVersion: 2.0.0

fileExistenceTests:
  - name: 'App binary exists'
    path: '/usr/local/bin/app'
    shouldExist: true

commandTests:
  - name: 'App version check'
    command: 'app'
    args: ['--version']
    expectedOutput: ['1.0.0']
    exitCode: 0

metadataTest:
  labels:
    - key: 'version'
      value: '1.0.0'
  exposedPorts: ['8080']
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{container-structure-test_version}-alpine{alpine_version}-{build_number}`

### Version Examples

`X.Y.Z` is the Container Structure Test version, `A.B.C` the Alpine version:

- `X.Y.Z-alpineA.B.C-1` - Container Structure Test X.Y.Z on Alpine A.B.C, build 1
- `X.Y.Z-alpineA.B.C-2` - Rebuild of same versions (bug fixes, optimizations)
- `X.Y.Z-alpineA.B.D-1` - Alpine Linux patch update
- `X.Y+1.0-alpineA.B.C-1` - Container Structure Test version update
- `latest` - Most recent stable release

The available versions are listed in the [Tags tab](https://hub.docker.com/r/ragedunicorn/container-test/tags).

## Platform Support

### Windows
```bash
docker run -v //var/run/docker.sock:/var/run/docker.sock -v ${PWD}/test:/test \
  ragedunicorn/container-test:latest --image myapp:latest --config /test/app_test.yml
```

### Linux/macOS
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image myapp:latest --config /test/app_test.yml
```

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-container-test](https://github.com/RagedUnicorn/docker-container-test)
- **Issues**: [https://github.com/RagedUnicorn/docker-container-test/issues](https://github.com/RagedUnicorn/docker-container-test/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-container-test/releases](https://github.com/RagedUnicorn/docker-container-test/releases)
- **Container Structure Test**: [https://github.com/GoogleContainerTools/container-structure-test](https://github.com/GoogleContainerTools/container-structure-test)

## License

MIT License - See [GitHub repository](https://github.com/RagedUnicorn/docker-container-test) for details.
