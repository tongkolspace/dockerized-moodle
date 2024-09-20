ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="Todi <t@tonjoo.id>"
LABEL Description="PHP Web App Container"
ARG PHP_VERSION=8.2
ENV EDITOR=nano

# Setup document root
WORKDIR /var/www/html

ARG PHP_VERSION=82

# Create user and home folder
# Create home directory for app user

# Add User
RUN addgroup -g 1000 app \
  && adduser -u 1000 -G app -h /home/app -s /bin/sh -D app \
  && chown app:app /home/app \
  && mkdir -p /tmp/nginx \
  && chown -R app:app /tmp/nginx


# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  nginx-mod-http-redis2 \
  nginx-mod-http-vts \
  nginx-mod-http-headers-more \
  php${PHP_VERSION} \
  php${PHP_VERSION}-ctype \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-dom \
  php${PHP_VERSION}-fileinfo \
  php${PHP_VERSION}-fpm \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-intl \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-mysqli \
  php${PHP_VERSION}-opcache \
  php${PHP_VERSION}-openssl \
  php${PHP_VERSION}-phar \
  php${PHP_VERSION}-session \
  php${PHP_VERSION}-tokenizer \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-xmlreader \
  php${PHP_VERSION}-xmlwriter \
  php${PHP_VERSION}-cli \  
  php${PHP_VERSION}-pcntl \  
  php${PHP_VERSION}-iconv \
  php${PHP_VERSION}-cli \
  php${PHP_VERSION}-zip \
  php${PHP_VERSION}-simplexml \
  php${PHP_VERSION}-sodium \
  apache2-utils \
  tzdata \
  iputils \
  redis \
  nano \
  supervisor \
  iproute2 \
  iputils-ping \
  redis 


# Nginx Config
RUN rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
COPY ./docker/app/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/app/nginx/common /etc/nginx/common
COPY ./docker/app/nginx/conf.d /etc/nginx/conf.d
COPY ./docker/app/nginx/sites-available /etc/nginx/sites-available
COPY ./docker/app/nginx/sites-available/moodle.conf /etc/nginx/sites-enabled/moodle.conf
COPY ./docker/app/nginx/snippets /etc/nginx/snippets
COPY ./docker/app/nginx/empty /etc/nginx/empty

# PHP-FPM Config
COPY ./docker/app/php-fpm/php-fpm-prod.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY ./docker/app/php-fpm/php-prod.ini /etc/php/${PHP_VERSION}/fpm/conf.d/custom.ini

RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm
RUN ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

# Supervisor Config
COPY --chown=app ./docker/app/supervisor /home/app/supervisor
COPY --chown=app ./docker/app/cron /home/app/cron


# Web Apps
COPY --chown=app --chmod=444 ./moodle /var/www/html/
COPY --chown=app --chmod=444 ./moodle_mod /var/www/moodle_mod/
COPY --chown=app --chmod=444 ./admin /var/www/admin/

# If need to modify specific folder
# RUN chmod 755 /var/www/moodledata

COPY --chown=app ./docker/app/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN chown -R app:app /run /var/lib/nginx /var/log /etc/nginx
USER app
# Expose ports
EXPOSE 8000 57710

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]