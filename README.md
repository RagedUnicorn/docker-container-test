# docker-container-test

![](./docs/docker_container_test.png)

[![Release Build](https://github.com/RagedUnicorn/docker-container-test/actions/workflows/docker_release.yml/badge.svg)](https://github.com/RagedUnicorn/docker-ffmpeg/actions/workflows/docker_release.yml)
![License: MIT](docs/license_badge.svg)


> Docker Alpine base image for executing container tests

![](./docs/alpine_linux_logo.svg)

## Using the image

This image can be used as a base to run container structure tests on other images. As a convention all projects should create a `test` folder at the topmost project level containing all tests for the image.

| Testname | Description                                                                                                                |
| -------- | -------------------------------------------------------------------------------------------------------------------------- |
| [application]_metadata_test.yml  | A set of tests to check for certain expected entries in the Dockerfile such as ports, volumes etc. |
| [application]_command_test.yml   | Basic tests for executing a command related to the image                                           |
| [application]_test.yml           | Basic tests for the image such as file existence checks                                            |

Projects can then either run the tests by hand or create a specific docker compose setup to execute all tests. As a convention this configuration should be named `docker-compose.test.yml`. An example that can be used as a template can be found in this repository (`docker-compose.test.template`). Only the image to be tested and the tests itself need to be changed if the recommended conventions of this readme are followed.

After that the tests can be run by starting the services

`docker-compose -f docker-compose.test.yml up`

**Note:** using -d option for docker-compose is not recommended in this case. Otherwise, the logs with the results of the tests need to be grabbed manually in each container. Without the -d option the result will already be displayed.


Tests can also be run separate by starting single services in `docker-compose.test.yml`

```
# basic file existence tests
docker-compose -f docker-compose.test.yml up container-test
# command tests
docker-compose -f docker-compose.test.yml up container-test-command
# metadata tests
docker-compose -f docker-compose.test.yml up container-test-metadata
```

Instead of using a docker-compose file the tests can be run with docker directly.

**Note:** Take attention to the difference of mounting the docker socket on different platforms.

##### Windows:
```shell
docker run -v //var/run/docker.sock:/var/run/docker.sock -v ${PWD}/test:/test -t ragedun
icorn/container-test:1.0.0-stable --image [some-image] --config [some-test-file]
```

##### Unix:
```shell
docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}/test:/test -t ragedun
icorn/container-test:1.0.0-stable --image [some-image] --config [some-test-file]
```

## Known Issues

#### No such image

Also make sure to pull or create the image to be tested locally before running the tests otherwise the following error might occur.

```
ERROR: Error creating container: no such image
...
```

Using the template the image to test will be automatically pulled from the repository if not available locally. This might be unwanted behavior. Change the template accordingly by removing `--pull` from the command section of docker-compose.

#### Tests Blocked

Google Container Structure Test is overriding the entrypoint by default to prevent containers that run blocking processes from blocking the tests. If for an example a docker image starts a webserver the tests cannot be run because that process is blocking the tests. Usually this works out with GCST overriding the entrypoint. However, if it does not keep this in mind and make sure no process is blocking the running of the tests.

## Development

To debug the container and get more insight into the container use the `docker-compose.dev.yml`
configuration.

```
docker-compose -f docker-compose.dev.yml up -d
```

By default, the container will be setup to keep `stdin` open and allocating a pseudo `tty`. This allows for connecting to a shell and work on the container. A shell can be opened inside the container with `docker attach [container-id]`. From there tests can be run manually for further insight of what is happening in the container.

## Links

Google Container Structure Tests repository
- https://github.com/GoogleContainerTools/container-structure-test

## License

Copyright (C) 2025 Michael Wiesendanger

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
