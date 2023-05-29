# Nombre base de la imagen Docker que vamos a utilizar
# En este caso la imagen es la que está en el repositorio de Hub de Docker y 
# es la imagen oficial de PHP. El resto de la configuración la tendremos en el 
# archivo docker-compose.yml
FROM php:7.4-apache

# Instalo paquetes complementarios
RUN apt-get update && apt-get install --no-install-recommends -y libmcrypt-dev \
    mariadb-client libmagickwand-dev  \
    git \
    zip \
    zlib1g-dev \
    libzip-dev \
    libonig-dev 

RUN pecl install imagick 
RUN docker-php-ext-install pdo_mysql zip mbstring xml \
    && a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer 

VOLUME ["/var/www/utn-devops-app/myapp","/var/www/html"]

COPY ./configs/php/php.ini /usr/local/etc/php/php.ini
COPY ./configs/httpd/devops.site.conf /etc/apache2/sites-available/000-default.conf
COPY ./configs/app/config_app.sh /tmp/config_app.sh

EXPOSE 8081

