SHELL = bash

# Inspired from https://github.com/hypriot/rpi-mysql/blob/master/Makefile

#DOCKER_REGISTRY=''
ARCH=arm64v8/
QEMU_ARCH=aarch64
DOCKER_IMAGE_VERSION=5.4.0-php7.3-fpm-alpine
DOCKER_IMAGE_NAME=biarms/wordpress
DOCKER_IMAGE_TAGNAME=$(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_FILE=Dockerfile

default: build test tag push

check:
	@which manifest-tool > /dev/null || (echo "Ensure that you've got the manifest-tool utility in your path. Could be downloaded from  https://github.com/estesp/manifest-tool/releases/download/" && exit 2)
	@echo "DOCKER_REGISTRY: $(DOCKER_REGISTRY)"

tag: check
	docker tag $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):latest $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
	docker tag $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_TAGNAME)

build: check
	docker build -t $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):latest -f $(DOCKER_FILE) --build-arg VERSION="${DOCKER_IMAGE_VERSION}" --build-arg ARCH="${ARCH}" --build-arg QEMU_ARCH="${QEMU_ARCH}" .

push-images: check
	docker push $(DOCKER_IMAGE_TAGNAME)
	# docker push $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):latest

push: push-images

test: check
	docker run --rm $(DOCKER_IMAGE_NAME) /bin/echo "Success."
	docker run --rm $(DOCKER_IMAGE_NAME) uname -a
	docker run --rm $(DOCKER_IMAGE_NAME) ls -l /usr/src/wordpress/wp-content/themes
	docker run --rm $(DOCKER_IMAGE_NAME) ls -l /usr/src/wordpress/wp-content/themes | grep baskerville
	docker run --rm $(DOCKER_IMAGE_NAME) ls -l /usr/src/wordpress/wp-content/plugins
	docker run --rm $(DOCKER_IMAGE_NAME) ls -l /usr/src/wordpress/wp-content/plugins | grep resize-image-after-upload

rmi: check
	docker rmi -f $(DOCKER_IMAGE_TAGNAME)

rebuild: rmi build
