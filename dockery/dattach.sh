#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description script for attaching to running docker-container-test container

# abort when trying to use unset variable
set -o nounset

WD="${PWD}"

# variable setup
DOCKER_CONTAINER_TEST_NAME="docker_container_test"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

echo "$(date) [INFO]: attaching to container ${DOCKER_CONTAINER_TEST_NAME}. To detach from the container use Ctrl-p Ctrl-q"
# attach to container
docker attach "${DOCKER_CONTAINER_TEST_NAME}"

cd "${WD}"
