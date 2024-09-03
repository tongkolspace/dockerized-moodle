ARG IMAGE_MOODLE_VERSION
FROM tongkolspace/php-fpm-moodle:${IMAGE_MOODLE_VERSION}
LABEL maintainer="Todi Adiyatmo <todiadiyatmo@gmail.com>"
LABEL org.label-schema.vendor="Tongkolspace"
LABEL org.label-schema.name="supervisor"

USER  root
RUN set -ex; \
    apt-get update; \
	apt-get install -y --no-install-recommends \
        cron \
        supervisor \
    &&  rm -rf /etc/cron.*/* 

COPY ./docker/supervisor/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
WORKDIR  /var/www/html
ENTRYPOINT ["/entrypoint.sh"]