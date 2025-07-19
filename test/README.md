# Container Structure Test Examples

This directory contains example test files demonstrating how to use the container-structure-test image.

## Example Tests

The `example/` directory contains tests for the Alpine Linux image:

- **alpine_test.yml** - Basic file existence and content tests
- **alpine_command_test.yml** - Command execution tests
- **alpine_metadata_test.yml** - Docker metadata tests

## Running the Tests

To run all tests:
```bash
docker-compose -f docker-compose.test.yml up
```

To run specific test suites:
```bash
# Basic tests
docker-compose -f docker-compose.test.yml up container-test

# Command tests
docker-compose -f docker-compose.test.yml up container-test-command

# Metadata tests
docker-compose -f docker-compose.test.yml up container-test-metadata
```

## Creating Your Own Tests

1. Create a new directory for your image tests
2. Copy the example files and modify them for your image
3. Update `docker-compose.test.yml` to point to your image and test files
4. Run the tests

## Test File Structure

Each test file should follow the container-structure-test schema:
- **schemaVersion**: 2.0.0
- **fileExistenceTests**: Check if files/directories exist
- **fileContentTests**: Verify file contents
- **commandTests**: Execute commands and check outputs
- **metadataTest**: Verify Docker image metadata
