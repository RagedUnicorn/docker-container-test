# Testing Guide

This document describes how to test Docker images using the Container Structure Test image.

## Quick Start

```bash
# Run all tests
docker-compose -f docker-compose.test.yml run test-all

# Run individual test suites
docker-compose -f docker-compose.test.yml up container-test          # File structure tests
docker-compose -f docker-compose.test.yml up container-test-command  # Command execution tests
docker-compose -f docker-compose.test.yml up container-test-metadata # Metadata validation tests
```

## Test Structure

Container Structure Test supports three main types of tests:

### 1. File Structure Tests (`[application]_test.yml`)

Validates:

- File and directory existence
- File permissions and ownership
- File content matching
- Configuration file presence

Example:

```yaml
schemaVersion: 2.0.0

fileExistenceTests:
  - name: 'App binary exists'
    path: '/usr/local/bin/app'
    shouldExist: true
  - name: 'Config directory exists'
    path: '/etc/app'
    shouldExist: true
```

### 2. Command Execution Tests (`[application]_command_test.yml`)

Validates:

- Command execution and exit codes
- Output content validation
- Error message checking
- Environment variable behavior

Example:

```yaml
schemaVersion: 2.0.0

commandTests:
  - name: 'App version'
    command: 'app'
    args: ['--version']
    expectedOutput: ['v1.0.0']
    exitCode: 0
```

### 3. Metadata Tests (`[application]_metadata_test.yml`)

Validates:

- Docker labels (OCI-compliant)
- Exposed ports
- Volumes
- Environment variables
- Entrypoint and command configuration

Example:

```yaml
schemaVersion: 2.0.0

metadataTest:
  labels:
    - key: 'maintainer'
      value: 'example@email.com'
  exposedPorts: ['8080']
  volumes: ['/data']
```

## Running Tests

### Prerequisites

1. Docker must be installed and running
2. Docker socket must be accessible
3. Test files must be present in the `test/` directory

### Basic Usage

Test your own image:

```bash
# Using latest Container Structure Test
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image [image-to-test] --config /test/[test-file].yml

# Using specific version
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:1.19.3-alpine3.22.1-1 --image [image-to-test] --config /test/[test-file].yml
```

### Using Docker Compose

1. Copy `docker-compose.test.template` to `docker-compose.test.yml`
2. Replace placeholders:
   - `[image_to_test]` with your image name
   - `[application]` with your application name
   - Update test file paths as needed

3. Run tests:

```bash
# Run all tests sequentially
docker-compose -f docker-compose.test.yml run test-all

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

## Advanced Options

### Auto-pull Images

Automatically pull the image before testing:

```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --pull --image [image] --config /test/[test].yml
```

### Test Specific Platform

Test a specific platform variant:

```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --platform linux/arm64 --image [image] --config /test/[test].yml
```

### Generate Test Reports

Output test results in different formats:

```bash
# JSON output
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image [image] --config /test/[test].yml \
  --output json --test-report /test/report.json

# JUnit output
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image [image] --config /test/[test].yml \
  --output junit --test-report /test/report.xml
```

## Example Test Suite

The `test/example/` directory contains a complete test suite for Alpine Linux:

- `alpine_test.yml` - Tests for Alpine base system files
- `alpine_command_test.yml` - Tests for Alpine commands and package manager
- `alpine_metadata_test.yml` - Tests for Alpine image metadata

## Troubleshooting

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

Or ensure your user is in the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Permission Errors on Windows

Use double slashes for the Docker socket path:

```bash
docker run -v //var/run/docker.sock:/var/run/docker.sock ...
```

## Development Mode

For testing and debugging Container Structure Test itself:

```bash
# Build the image locally
docker-compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker-compose -f docker-compose.dev.yml run --rm container-test-dev

# Inside the container, you can run container-structure-test manually
container-structure-test --help
container-structure-test test --image alpine:latest --config /test/example_test.yml
```

## Writing Effective Tests

### Best Practices

1. **Group related tests** - Use separate files for different test types
2. **Use descriptive names** - Make test failures easy to understand
3. **Test critical functionality** - Focus on what's essential for your image
4. **Keep tests maintainable** - Update tests when the image changes

### Common Test Patterns

#### Testing installed packages

```yaml
fileExistenceTests:
  - name: 'Package binary installed'
    path: '/usr/bin/package'
    shouldExist: true
    permissions: '-rwxr-xr-x'
```

#### Testing configuration files

```yaml
fileContentTests:
  - name: 'Config contains required setting'
    path: '/etc/app/config.conf'
    expectedContents: ['required_setting = true']
```

#### Testing service availability

```yaml
commandTests:
  - name: 'Service responds to health check'
    command: 'curl'
    args: ['-f', 'http://localhost:8080/health']
    exitCode: 0
```

## CI/CD Integration

These tests can be integrated into CI/CD pipelines. The `test-all` service returns:
- Exit code 0: All tests passed
- Exit code 1: One or more tests failed

Example GitHub Actions step:

```yaml
- name: Run Container Structure Tests
  run: |
    docker build -t myapp:test .
    docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${{ github.workspace }}/test:/test \
      ragedunicorn/container-test:latest --image myapp:test --config /test/myapp_test.yml
```

Example GitLab CI:

```yaml
test:
  stage: test
  script:
    - docker build -t $CI_PROJECT_NAME:$CI_COMMIT_SHA .
    - docker run -v /var/run/docker.sock:/var/run/docker.sock -v $CI_PROJECT_DIR/test:/test
        ragedunicorn/container-test:latest --image $CI_PROJECT_NAME:$CI_COMMIT_SHA --config /test/app_test.yml
```

## Links

- [Container Structure Test Documentation](https://github.com/GoogleContainerTools/container-structure-test)
- [Container Structure Test Schema Reference](https://github.com/GoogleContainerTools/container-structure-test#command-tests)
- [Writing Tests Tutorial](https://github.com/GoogleContainerTools/container-structure-test/blob/master/examples/sample_test.yaml)
