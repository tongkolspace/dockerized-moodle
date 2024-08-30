FROM easyengine/php8.1:v4.7.3

LABEL maintainer="Todi Adiyatmo <todiadiyatmo@gmail.com>"
LABEL org.label-schema.vendor="Tongkolspace"
LABEL org.label-schema.name="php-fpm"

USER root
RUN set -ex; \
    apt-get update; \
	apt-get install -y --no-install-recommends \
        rsync \
        git \
        curl \
        vim \
        nano \
        ca-certificates \
        inetutils-ping \
        gnupg \
        ntp \
    &&  rm -rf /etc/cron.*/* \
    ######################################
    # Install moodle dependency
    ######################################
    && docker-php-ext-install pcntl \
    ######################################
    # Add user workspace and asign id=1000
    ######################################
    && useradd -u 1000 -g www-data -G www-data workspace \
    && groupadd workspace -g 1000  \
    && usermod -a -G workspace workspace \
    && mkdir /home/workspace  \
    && chown workspace:workspace /home/workspace \
    && apt-get clean 

# Custom Moodle
COPY ./moodle /var/www/html
COPY ./moodle_mod /var/www/html
RUN chmod -R a-w /var/www/html

USER  www-data
