FROM php:7.0-apache

RUN apt-get update && apt-get install -y libmcrypt-dev \
    mysql-client libmagickwand-dev curl git --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install mcrypt pdo_mysql zip \
    && apt-get autoclean && apt-get clean
#
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html/myapp

COPY ./docker-configs/php/php.ini $PHP_INI_DIR/custom.ini
COPY ./docker-configs/httpd/devops.site.conf /etc/apache2/sites-available/000-default.conf
COPY . /var/www/html/myapp

EXPOSE 8081

