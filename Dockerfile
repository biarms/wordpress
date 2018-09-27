# BUILD_ARCH: ie: "arm64v8/"
ARG BUILD_ARCH
# VERSION: the version. ie: "4.9.8"
ARG VERSION

# Perform a multi-stage build as explained at https://docs.docker.com/v17.09/engine/userguide/eng-image/multistage-build/#name-your-build-stages
FROM biarms/qemu-bin:latest as qemu-bin-ref

FROM ${BUILD_ARCH}wordpress:${VERSION}
ARG QEMU_ARCH
COPY --from=qemu-bin-ref /usr/bin/qemu-${QEMU_ARCH}-static /usr/bin/qemu-${QEMU_ARCH}-static

# From https://github.com/docker-library/wordpress/blob/master/php5.6/fpm-alpine/Dockerfile
# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]
# USER root
MAINTAINER Brother In Arms <project.biarms@gmail.com>


ADD https://downloads.wordpress.org/theme/baskerville.1.26.zip /usr/src/wordpress/wp-content/themes

# COPY wp-content /usr/src/wordpress/wp-content
RUN chown -R www-data:www-data /usr/src/wordpress

ARG VCS_REF
ARG BUILD_DATE
LABEL \
	org.label-schema.build-date=${BUILD_DATE} \
	org.label-schema.vcs-ref=${VCS_REF} \
	org.label-schema.vcs-url="https://github.com/biarms/wordpress"
