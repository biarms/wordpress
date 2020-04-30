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

# Add themes
RUN cd /tmp \
 && curl https://downloads.wordpress.org/theme/baskerville.2.1.2.zip --output theme.zip \
 && mkdir -p /tmp/themes \
 && unzip theme.zip -d /tmp/themes

RUN cd /tmp \
 && curl https://downloads.wordpress.org/theme/travelera-lite.1.0.1.7.zip --output theme.zip \
 && mkdir -p /tmp/themes \
 && unzip theme.zip -d /tmp/themes

# Add plugins
RUN cd /tmp \
 && curl https://downloads.wordpress.org/plugin/upload-max-file-size.2.0.4.zip --output plugin.zip \
 && mkdir -p /tmp/plugins \
 && unzip plugin.zip -d /tmp/plugins

RUN cd /tmp \
 && curl https://downloads.wordpress.org/plugin/resize-image-after-upload.1.8.6.zip --output plugin.zip \
 && mkdir -p /tmp/plugins \
 && unzip plugin.zip -d /tmp/plugins

RUN cd /tmp \
 && curl https://downloads.wordpress.org/plugin/user-access-manager.2.1.12.zip --output plugin.zip \
 && mkdir -p /tmp/plugins \
 && unzip plugin.zip -d /tmp/plugins

RUN cd /tmp \
 && curl https://downloads.wordpress.org/plugin/wp-mail-smtp.2.0.0.zip --output plugin.zip \
 && mkdir -p /tmp/plugins \
 && unzip plugin.zip -d /tmp/plugins

# 4. Start the creation of the final docker image
FROM ${BUILD_ARCH}wordpress:${VERSION}
#wordpress:5.4.0-php7.3-fpm-alpine
# TODO: -php7.3-fpm-alpine
# TODO: ${BUILD_ARCH} ???
MAINTAINER Brother In Arms <project.biarms@gmail.com>

# QEMU_ARCH: the qemu architecture. For instance, 'arm' or 'aarch64'
ARG QEMU_ARCH
COPY --from=qemu-bin-ref /usr/bin/qemu-${QEMU_ARCH}-static /usr/bin/qemu-${QEMU_ARCH}-static

# From https://github.com/docker-library/wordpress/blob/master/php5.6/fpm-alpine/Dockerfile
# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]
# USER root

# Add themes
COPY --from=builder /tmp/themes /usr/src/wordpress/wp-content/themes
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content/themes

# Remove default plugins
# RUN rm -rf /usr/src/wordpress/wp-content/plugins/*

# Add plugins
COPY --from=builder /tmp/plugins /usr/src/wordpress/wp-content/plugins
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content/plugins

COPY php-conf.d/upload_max_filesize.ini /usr/local/etc/php/conf.d/upload_max_filesize.ini
RUN chown -R www-data:www-data /usr/local/etc/php/conf.d/upload_max_filesize.ini

ARG VCS_REF
ARG BUILD_DATE
LABEL \
	org.label-schema.build-date=${BUILD_DATE} \
	org.label-schema.vcs-ref=${VCS_REF} \
	org.label-schema.vcs-url="https://github.com/biarms/wordpress"
