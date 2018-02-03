# From https://github.com/docker-library/wordpress/blob/master/php5.6/fpm-alpine/Dockerfile
# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]
# USER root
FROM wordpress:4.9.2
MAINTAINER Brother In Arms <project.biarms@gmail.com>

COPY wp-content /usr/src/wordpress/wp-content
RUN chown -R www-data:www-data /usr/src/wordpress
