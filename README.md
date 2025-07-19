# docker-container-test

![](./docs/docker_container_test.png)

[![Release Build](https://github.com/RagedUnicorn/docker-container-test/actions/workflows/docker_release.yml/badge.svg)](https://github.com/RagedUnicorn/docker-container-test/actions/workflows/docker_release.yml)
![License: MIT](docs/license_badge.svg)

> Docker Alpine image with Google Container Structure Test for validating container images.

![](./docs/alpine_linux_logo.svg)

## Overview

This Docker image provides a lightweight Container Structure Test installation on Alpine Linux. It enables automated validation of Docker images by testing their structure, contents, and behavior without needing to run them.

## Features

- **Small footprint**: Minimal Alpine Linux base image
- **Container Structure Test v1.19.3**: Latest stable version
- **Docker-in-Docker support**: Can test images using the Docker socket
- **Multi-platform**: Supports linux/amd64 and linux/arm64
- **Ready-to-use**: Pre-configured for immediate testing

## Building the Image

```bash
docker build -t ragedunicorn/container-test .
```

## Usage

The container uses Container Structure Test as the entrypoint, so test parameters can be passed directly to the `docker run` command.

### Basic Usage

```bash
# Using latest version
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image [image-to-test] --config /test/[test-file].yml

# Using specific version
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:1.19.3-alpine3.22.1-1 --image [image-to-test] --config /test/[test-file].yml
```

### Test File Structure

Container Structure Test supports three types of tests:

| Test Type                         | Description                                                       |
|-----------------------------------|-------------------------------------------------------------------|
| `[application]_test.yml`          | Basic tests for file existence and content validation             |
| `[application]_command_test.yml`  | Tests for command execution and output validation                 |
| `[application]_metadata_test.yml` | Tests for Dockerfile metadata like labels, exposed ports, volumes |

### Examples

#### Test File Existence

```yaml
# test/app_test.yml
schemaVersion: 2.0.0

fileExistenceTests:
  - name: 'App binary exists'
    path: '/usr/local/bin/app'
    shouldExist: true
  - name: 'Config directory exists'
    path: '/etc/app'
    shouldExist: true
```

#### Test Command Output

```yaml
# test/app_command_test.yml
schemaVersion: 2.0.0

commandTests:
  - name: 'App version'
    command: 'app'
    args: ['--version']
    expectedOutput: ['v1.0.0']
    exitCode: 0
```

#### Test Metadata

```yaml
# test/app_metadata_test.yml
schemaVersion: 2.0.0

metadataTest:
  labels:
    - key: 'maintainer'
      value: 'example@email.com'
  exposedPorts: ['8080']
  volumes: ['/data']
```

## Docker Compose Usage

### Using the Template

1. Copy `docker-compose.test.template` to `docker-compose.test.yml`
2. Replace `[image_to_test]` with your image name
3. Update test file paths as needed

### Running Tests

```bash
# Run all tests
docker-compose -f docker-compose.test.yml up

# Run specific test suites
docker-compose -f docker-compose.test.yml up container-test
docker-compose -f docker-compose.test.yml up container-test-command
docker-compose -f docker-compose.test.yml up container-test-metadata
```

### Platform-Specific Notes

#### Windows

```shell
docker run -v //var/run/docker.sock:/var/run/docker.sock -v ${PWD}/test:/test \
  ragedunicorn/container-test:1.19.3-alpine3.22.1-1 --image [image] --config /test/[test].yml
```

#### Unix/Linux/macOS

```shell
docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}/test:/test \
  ragedunicorn/container-test:1.19.3-alpine3.22.1-1 --image [image] --config /test/[test].yml
```

## Common Issues

### Image Not Found

Ensure the image to test is available locally:
```bash
docker pull [image-to-test]
```

Or use the `--pull` flag to automatically pull the image:
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --pull --image [image] --config /test/[test].yml
```

### Tests Blocked by Running Processes

Container Structure Test overrides the entrypoint to prevent blocking processes. If tests fail due to running services, ensure your test configuration accounts for this behavior.

### Docker Socket Permission

On some systems, you may need to run with appropriate permissions to access the Docker socket:
```bash
sudo docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```

## Development Mode

For testing and debugging, use the development compose file:

```bash
# Build the image locally
docker-compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker-compose -f docker-compose.dev.yml run --rm container-test-dev

# Inside the container, you can run container-structure-test manually
container-structure-test --help
container-structure-test test --image alpine:latest --config /test/example_test.yml
```

## Versioning

This project uses semantic versioning that matches the Docker image contents:

**Format:** `{container-structure-test_version}-alpine{alpine_version}-{build_number}`

Examples:
- `1.19.3-alpine3.22.1-1` - Container Structure Test 1.19.3 on Alpine 3.22.1, build 1
- `latest` - Most recent stable release

For detailed release process and versioning guidelines, see [RELEASE.md](RELEASE.md).

## Links

- [Container Structure Test Documentation](https://github.com/GoogleContainerTools/container-structure-test)
- [Alpine Linux](https://www.alpinelinux.org/)

## License

MIT License

Copyright (c) 2025 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.