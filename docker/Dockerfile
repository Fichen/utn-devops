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