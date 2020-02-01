FROM docker:19.03.5

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

#    ______            __        _                    ______          __
#   / ____/___  ____  / /_____ _(_)___  ___  _____   /_  __/__  _____/ /_
#  / /   / __ \/ __ \/ __/ __ `/ / __ \/ _ \/ ___/    / / / _ \/ ___/ __/
# / /___/ /_/ / / / / /_/ /_/ / / / / /  __/ /       / / /  __(__  ) /_
# \____/\____/_/ /_/\__/\__,_/_/_/ /_/\___/_/       /_/  \___/____/\__/

ENV \
  CONTAINER_STRUCTURE_VERSION=v1.8.0

RUN \
  if ! wget -O /usr/bin/container-structure-test https://storage.googleapis.com/container-structure-test/"${CONTAINER_STRUCTURE_VERSION}"/container-structure-test-linux-amd64; then \
    echo >&2 "Error: Failed to download Container structure test binary"; \
    exit 1; \
  fi && \
  chmod +x /usr/bin/container-structure-test

ENTRYPOINT ["container-structure-test", "test"]
