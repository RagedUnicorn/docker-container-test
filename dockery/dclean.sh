#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description cleanup script for docker-test container.
# Does not delete other containers that where built from the dockerfile

# abort when trying to use unset variable
set -o nounset

WD="${PWD}"

# variable setup
DOCKER_DOCKER_TEST_NAME="docker_test"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# search for containers including non-running containers
docker ps -a | grep "${DOCKER_DOCKER_TEST_NAME}" > /dev/null

# if a container can be found - delete it
if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Cleaning up container ${DOCKER_DOCKER_TEST_NAME} ..."
  docker rm "${DOCKER_DOCKER_TEST_NAME}" > /dev/null
else
  echo "$(date) [INFO]: No existing container with name: ${DOCKER_DOCKER_TEST_NAME} found"
fi

cd "${WD}"
