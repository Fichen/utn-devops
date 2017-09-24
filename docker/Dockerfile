# Nombre base de la imagen Docker que vamos a utilizar
# En este caso la imagen es la que está en el repositorio de Hub de Docker y 
# es la imagen oficial de PHP. El resto de la configuración la tendremos en el 
# archivo docker-compose.yml
FROM php:7.0-apache

# Instalo paquetes complementarios
RUN apt-get update && apt-get install -y libmcrypt-dev \
    mysql-client libmagickwand-dev --no-install-recommends \
	git \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install mcrypt pdo_mysql zip 

VOLUME ["/var/www/utn-devops-app/myapp","/var/www/html"]

COPY ./configs/php/php.ini /usr/local/etc/php/php.ini
COPY ./configs/httpd/devops.site.conf /etc/apache2/sites-available/000-default.conf
COPY ./configs/app/config_app.sh /tmp/config_app.sh

#CMD ["sh","/tmp/config_app.sh"]

EXPOSE 8081

