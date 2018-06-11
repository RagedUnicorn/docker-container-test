#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description build script for docker-test container

# abort when trying to use unset variable
set -o nounset
set -x

WD="${PWD}"

# variable setup
DOCKER_DOCKER_TEST_TAG="ragedunicorn/docker_test"
DOCKER_DOCKER_TEST_NAME="docker_test"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

echo "$(date) [INFO]: Building container: ${DOCKER_DOCKER_TEST_NAME} - ${DOCKER_DOCKER_TEST_TAG}"

# build docker-test container
docker build -t "${DOCKER_DOCKER_TEST_TAG}" ../

cd "${WD}"
