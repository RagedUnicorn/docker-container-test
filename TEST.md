# Testing Guide

This document describes how to test Docker images using the Container Structure Test image.

## Quick Start

### Testing the Container Structure Test Image Itself

The provided `docker-compose.test.yml` is configured to test the container-test image itself:

```bash
# Run all self-tests
docker compose -f docker-compose.test.yml run test-all

# Run individual test suites
docker compose -f docker-compose.test.yml up container-test          # File structure tests
docker compose -f docker-compose.test.yml up container-test-command  # Command execution tests
docker compose -f docker-compose.test.yml up container-test-metadata # Metadata validation tests
```

### Testing Other Images

To test your own images, use the template or run directly:

```bash
# Using the template (replace the existing docker-compose.test.yml)
cp docker-compose.test.template docker-compose.test.yml
# Edit the file to replace placeholders with your image and test names
docker compose -f docker-compose.test.yml run test-all

# Or run directly
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/test:/test \
  ragedunicorn/container-test:latest --image [your-image] --config /test/[your-test].yml
```

## Test Organization

The test directory contains two types of tests:

1. **Self-tests** (`container_test_*.yml`) - Tests for the container-test image itself
2. **Example tests** (`test/example/alpine_*.yml`) - Examples for testing other images

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
2. Build the Container Structure Test image locally before testing

### Important: Always Test Local Builds

**⚠️ Always build and test locally to ensure consistency:**

```bash
# Build the image locally with a test tag
docker build -t ragedunicorn/container-test:test .
```

**Linux/macOS:**

```bash
# Run tests against your local build
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Run tests against your local build
$env:CONTAINER_STRUCTURE_TEST_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Why local testing is important:**
- Remote images (Docker Hub, GHCR) may have different labels due to CI/CD overrides
- Ensures you're testing exactly what you built
- Avoids false positives/negatives from version mismatches
- Guarantees consistent test results

**Never pull remote images for testing:**

**❌ DON'T DO THIS - may have different labels/settings:**

```bash
docker pull ragedunicorn/container-test:latest
docker compose -f docker-compose.test.yml run test-all
```

**✅ DO THIS - test your local build:**

**Linux/macOS:**

```bash
docker build -t ragedunicorn/container-test:test .
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
docker build -t ragedunicorn/container-test:test .
$env:CONTAINER_STRUCTURE_TEST_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Test Execution

Run all tests against your local build:

**Linux/macOS:**

```bash
# Ensure you've built locally first!
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Ensure you've built locally first!
$env:CONTAINER_STRUCTURE_TEST_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Ensure you've built locally first!
set CONTAINER_STRUCTURE_TEST_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

Run specific test categories:

**Linux/macOS:**

```bash
# File structure tests
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml up container-test

# Command execution tests
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml up container-test-metadata
```

**Windows (PowerShell):**

```powershell
# File structure tests
$env:CONTAINER_STRUCTURE_TEST_VERSION="test"; docker compose -f docker-compose.test.yml up container-test

# Command execution tests
$env:CONTAINER_STRUCTURE_TEST_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
$env:CONTAINER_STRUCTURE_TEST_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-metadata
```

### Testing Different Versions

When testing different versions, always build locally first:

```bash
# Build a specific version locally
docker build -t ragedunicorn/container-test:1.19.3-alpine3.22.1-1 .
```

**Linux/macOS:**

```bash
# Test that specific version
CONTAINER_STRUCTURE_TEST_VERSION=1.19.3-alpine3.22.1-1 docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Test that specific version
$env:CONTAINER_STRUCTURE_TEST_VERSION="1.19.3-alpine3.22.1-1"; docker compose -f docker-compose.test.yml run test-all
```

### Using Docker Compose

#### For Testing Your Own Images

1. Copy `docker-compose.test.template` to replace `docker-compose.test.yml`
2. Replace placeholders:
   - `[image_to_test]` with your image name (e.g., `myapp:latest`)
   - `[application]` with your application name (e.g., `myapp`)
   - `[application_test]` with your test file name (e.g., `myapp_test`)
   - `[application_metadata_test]` with your metadata test file name (e.g., `myapp_metadata_test`)
   - `[application_command_test]` with your command test file name (e.g., `myapp_command_test`)
3. Create corresponding test files in the `test/` directory
4. Run the tests:

```bash
# Run all tests sequentially
docker compose -f docker-compose.test.yml run test-all

# Run specific test suites
docker compose -f docker-compose.test.yml up container-test
docker compose -f docker-compose.test.yml up container-test-command
docker compose -f docker-compose.test.yml up container-test-metadata
```

#### Using the Existing docker-compose.test.yml

The provided `docker-compose.test.yml` is pre-configured to test the container-test image itself using:
- `container_test_test.yml` - File structure tests
- `container_test_command_test.yml` - Command execution tests
- `container_test_metadata_test.yml` - Metadata validation tests

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

## Example Test Suites

### Container Structure Test Self-Tests

The `test/` directory contains tests for the container-test image itself:

- `container_test_test.yml` - Tests for Container Structure Test binary and files
- `container_test_command_test.yml` - Tests for Container Structure Test command execution
- `container_test_metadata_test.yml` - Tests for container-test image metadata

### Alpine Linux Example Tests

The `test/example/` directory contains a complete test suite for Alpine Linux that serves as a template:

- `alpine_test.yml` - Tests for Alpine base system files
- `alpine_command_test.yml` - Tests for Alpine commands and package manager
- `alpine_metadata_test.yml` - Tests for Alpine image metadata

These Alpine tests demonstrate how to test any Docker image and can be used as templates for your own tests.

## Troubleshooting Test Failures

### Metadata Test Failures

**Common causes:**

1. **Testing remote images instead of local builds**
   - Remote images (Docker Hub, GHCR) have labels overridden by CI/CD
   - Always test your local builds with `CONTAINER_STRUCTURE_TEST_VERSION=test`

2. **Label value mismatches**
   - CI/CD systems may capitalize values (e.g., "RagedUnicorn" vs "ragedunicorn")
   - GitHub Actions may override labels during build
   - Docker Hub automated builds may set different values

3. **Version-specific labels**
   - The `org.opencontainers.image.version` label changes with each build
   - Build date labels are dynamic

**Solution:** Always build and test locally before pushing:

```bash
docker build -t ragedunicorn/container-test:test .
CONTAINER_STRUCTURE_TEST_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

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
docker compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker compose -f docker-compose.dev.yml run --rm container-test-dev

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
