# Test Directory Structure

This directory contains test files for Container Structure Test validation.

## Directory Organization

```
test/
├── README.md                           # This file
├── container_test_test.yml             # Self-test: File structure validation
├── container_test_command_test.yml     # Self-test: Command execution tests
├── container_test_metadata_test.yml    # Self-test: Metadata validation
└── example/                            # Example tests for other images
    ├── alpine_test.yml                 # Alpine: File structure tests
    ├── alpine_command_test.yml         # Alpine: Command execution tests
    └── alpine_metadata_test.yml        # Alpine: Metadata tests
```

## Test Types

### 1. Self-Tests (container_test_*.yml)

These tests validate the Container Structure Test image itself. They are used in CI/CD and for verifying the image works correctly.

- **container_test_test.yml**: Validates that the container-structure-test binary exists with correct permissions
- **container_test_command_test.yml**: Tests the container-structure-test binary functionality
- **container_test_metadata_test.yml**: Validates image metadata and OCI labels

Run self-tests with:

```bash
# Test the current build
docker compose -f docker-compose.test.yml run test-all

# Test a specific version
CONTAINER_STRUCTURE_TEST_VERSION=1.19.3-alpine3.22.1-1 docker compose -f docker-compose.test.yml run test-all
```

### 2. Example Tests (example/*.yml)

These demonstrate how to test other Docker images. The Alpine Linux examples show common test patterns.

- **alpine_test.yml**: Tests for file existence, permissions, and content
- **alpine_command_test.yml**: Tests command execution and output validation
- **alpine_metadata_test.yml**: Tests Docker metadata (note: will fail on standard Alpine as it lacks custom labels)

Run example tests with:

```bash
# Direct execution
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/test:ro \
  ragedunicorn/container-test:latest \
  --pull --image alpine:3.22.1 --config /test/example/alpine_test.yml

# Using docker compose (replace docker-compose.test.yml)
cp docker-compose.test.template docker-compose.test.yml
# Edit to set image and test paths, then:
docker compose -f docker-compose.test.yml run test-all
```

## Creating Your Own Tests

1. **Copy the appropriate example** based on what you want to test
2. **Modify the test content** for your specific image
3. **Use the template** to replace the docker-compose.test.yml:
   ```bash
   cp docker-compose.test.template docker-compose.test.yml
   ```
4. **Replace placeholders** in the compose file:
   - `[image_to_test]` → Your image name (e.g., `myapp:latest`)
   - `[application]` → Your application name (e.g., `myapp`)
   - Update volume paths if needed

## Test Schema Reference

For detailed information about test schemas and available options, see:
- [Container Structure Test Documentation](https://github.com/GoogleContainerTools/container-structure-test)
- [Schema Reference](https://github.com/GoogleContainerTools/container-structure-test#command-tests)

## Tips

1. **Start simple**: Begin with basic file existence tests
2. **Test critical paths**: Focus on what's essential for your image
3. **Use examples**: The Alpine examples demonstrate common patterns
4. **Version your tests**: Keep tests in version control alongside your Dockerfile
5. **CI/CD integration**: Use these tests in your build pipeline

## Common Issues

### Tests Pass Locally but Fail in CI

- Ensure the image being tested is available (built or pulled)
- Check that test files are included in the repository
- Verify Docker socket permissions in CI environment

### Metadata Tests Fail

- Standard images (like alpine:latest) don't have custom labels
- Either skip metadata tests or test only your custom images
- Check that your Dockerfile includes the expected labels
- **Important**: Docker Hub and GitHub Container Registry may override certain labels (title, description, vendor) during automated builds. Always test with locally built images (`docker build -t image:test .`) to ensure metadata tests pass consistently

### Permission Errors

- Ensure Docker socket is mounted: `-v /var/run/docker.sock:/var/run/docker.sock`
- On some systems, you may need to run with appropriate permissions
- Check that test files are readable (use `:ro` mount flag)
