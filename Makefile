SHELL = bash

DOCKER_REGISTRY ?= 'docker.io'
DOCKER_IMAGE_VERSION ?= 5.4.1-php7.4-fpm
DOCKER_IMAGE_NAME = biarms/wordpress
BUILD_DATE ?= $(date -u +"%Y-%m-%dT%H-%M-%SZ")
PLATFORM ?= linux/arm/v7,linux/arm64/v8,linux/amd64

ARCH ?= arm64v8
LINUX_ARCH ?= aarch64
# |---------|------------|
# |  ARCH   | LINUX_ARCH |
# |---------|------------|
# |  amd64  |   x86_64   |
# | arm32v6 |   armv6l   |
# | arm32v7 |   armv7l   |
# | arm64v8 |   aarch64  |
# |---------|------------|

# DOCKER_CLI_EXPERIMENTAL = enabled is needed for "docker manifest". See https://docs.docker.com/engine/reference/commandline/manifest/ (at least with 19.03)

default: build-and-tests

check:
	@ which docker > /dev/null || (echo "Please install docker before using this script" && exit 1)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker manifest --help | grep "docker manifest COMMAND" > /dev/null || (echo "docker manifest is needed. Consider upgrading docker" && exit 2)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker version -f '{{.Client.Experimental}}' | grep "true" > /dev/null || (echo "docker experimental mode is not enabled" && exit 2)
	@ echo "DOCKER_REGISTRY: $(DOCKER_REGISTRY)"

infra-tests: check
	docker version
	docker buildx version

prepare: infra-tests
	docker buildx create --name=buildx-multi-arch || true
	docker buildx use buildx-multi-arch

build: prepare
	docker buildx build -f Dockerfile --platform $(PLATFORM) --tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) --build-arg VERSION="${DOCKER_IMAGE_VERSION}" .

test-arm32v7: check
	ARCH=arm32v7 LINUX_ARCH=armv7l DOCKER_IMAGE_VERSION=$(DOCKER_IMAGE_VERSION) make -f test-one-image

test-arm64v8: check
	ARCH=arm64v8 LINUX_ARCH=aarch64 DOCKER_IMAGE_VERSION=$(DOCKER_IMAGE_VERSION) make -f test-one-image

test-amd64: check
	ARCH=amd64 LINUX_ARCH=x86_64 DOCKER_IMAGE_VERSION=$(DOCKER_IMAGE_VERSION) make -f test-one-image

test-images: test-arm32v7 test-arm64v8 test-amd64
	echo "All tests are OK :)"

build-and-tests: prepare test-images
	docker buildx build -f Dockerfile --platform $(PLATFORM) --tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) --build-arg VERSION="${DOCKER_IMAGE_VERSION}" .

build-and-push: prepare test-images
	docker buildx build -f Dockerfile --push --platform linux/arm64/v8,linux/amd64 --tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION) --build-arg VERSION="${DOCKER_IMAGE_VERSION}" .

