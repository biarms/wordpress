SHELL = bash

# Inspired from https://github.com/hypriot/rpi-mysql/blob/master/Makefile

#DOCKER_REGISTRY=''
DOCKER_IMAGE_VERSION=4.9.4
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
	docker build -t $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):latest -f $(DOCKER_FILE) .

push-images: check
	docker push $(DOCKER_IMAGE_TAGNAME)
	docker push $(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):latest

push: push-images

test: check
	docker run --rm $(DOCKER_IMAGE_NAME) /bin/echo "Success."
	docker run --rm $(DOCKER_IMAGE_NAME) uname -a

rmi: check
	docker rmi -f $(DOCKER_IMAGE_TAGNAME)

rebuild: rmi build
