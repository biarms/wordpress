# Perform multi-stages build as explained at https://docs.docker.com/v17.09/engine/userguide/eng-image/multistage-build/#name-your-build-stages

# 1. Define args usable during the pre-build phase
# BUILD_ARCH: the docker architecture, with a tailing '/'. For instance, "arm64v8/"
ARG BUILD_ARCH
# VERSION: the version of the based image. ie: "4.9.8"
ARG VERSION

# 2. Reference the qemu helper docker image
FROM biarms/qemu-bin:latest as qemu-bin-ref

# 3. Create the 'builder' images
FROM ubuntu as builder
RUN apt-get update && apt-get install curl unzip -y

RUN cd /tmp \
 && curl https://downloads.wordpress.org/theme/baskerville.1.28.zip --output theme.zip \
 && mkdir -p /tmp/themes \
 && unzip theme.zip -d /tmp/themes

# 4. Start the creation of the final docker image
FROM ${BUILD_ARCH}wordpress:${VERSION}
MAINTAINER Brother In Arms <project.biarms@gmail.com>

# QEMU_ARCH: the qemu architecture. For instance, 'arm' or 'aarch64'
ARG QEMU_ARCH
COPY --from=qemu-bin-ref /usr/bin/qemu-${QEMU_ARCH}-static /usr/bin/qemu-${QEMU_ARCH}-static

# From https://github.com/docker-library/wordpress/blob/master/php5.6/fpm-alpine/Dockerfile
# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]
# USER root
COPY --from=builder /tmp/themes /usr/src/wordpress/wp-content/themes
RUN chown -R www-data:www-data /usr/src/wordpress

ARG VCS_REF
ARG BUILD_DATE
LABEL \
	org.label-schema.build-date=${BUILD_DATE} \
	org.label-schema.vcs-ref=${VCS_REF} \
	org.label-schema.vcs-url="https://github.com/biarms/wordpress"
