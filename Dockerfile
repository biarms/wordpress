# From https://github.com/docker-library/wordpress/blob/master/php5.6/fpm-alpine/Dockerfile
# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]
# USER root
ARG ARCH # ie: "arm64v8/"
ARG VERSION # ie: "4.9.8"
FROM ${ARCH}wordpress:${VERSION}
MAINTAINER Brother In Arms <project.biarms@gmail.com>

COPY wp-content /usr/src/wordpress/wp-content
RUN chown -R www-data:www-data /usr/src/wordpress

ARG VCS_REF
ARG BUILD_DATE
LABEL \
	org.label-schema.build-date=${BUILD_DATE} \
	org.label-schema.vcs-ref=${VCS_REF} \
	org.label-schema.vcs-url="https://github.com/biarms/wordpress"
