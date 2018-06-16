#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description run script for docker-test container

# abort when trying to use unset variable
set -o nounset

WD="${PWD}"

# variable setup
DOCKER_DOCKER_TEST_TAG="ragedunicorn/docker_test"
DOCKER_DOCKER_TEST_NAME="docker_test"
DOCKER_DOCKER_TEST_ID=0
DOCKER_MOUNT_PATH=""

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# check if there is already an image created
docker inspect ${DOCKER_DOCKER_TEST_NAME} &> /dev/null

if [ $? -eq 0 ]; then
  # start container
  docker start "${DOCKER_DOCKER_TEST_NAME}"
else
  if [ "${OSTYPE}" == "msys" ]; then
    DOCKER_MOUNT_PATH="//var/run/docker.sock:/var/run/docker.sock"
  else
    DOCKER_MOUNT_PATH="/var/run/docker.sock:/var/run/docker.sock"
  fi
  ## run image:
  # -d run in detached mode
  # -i Keep STDIN open even if not attached
  # -t Allocate a pseudo-tty
  # -v mount/bind volume
  # --name define a name for the container(optional)
  DOCKER_DOCKER_TEST_ID=$(docker run \
  -dit \
  -v "${DOCKER_MOUNT_PATH}" \
  --name "${DOCKER_DOCKER_TEST_NAME}" "${DOCKER_DOCKER_TEST_TAG}")
fi

if [ $? -eq 0 ]; then
  # print some info about containers
  echo "$(date) [INFO]: Container info:"
  docker inspect -f '{{ .Config.Hostname }} {{ .Name }} {{ .Config.Image }} {{ .NetworkSettings.IPAddress }}' ${DOCKER_DOCKER_TEST_NAME}
else
  echo "$(date) [ERROR]: Failed to start container - ${DOCKER_DOCKER_TEST_NAME}"
fi

cd "${WD}"
