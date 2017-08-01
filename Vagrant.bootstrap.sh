#!/bin/bash

#Aprovisionamiento de software

#Actualizo los paquetes de la maquina virtual
sudo apt-get update -y ;

#Desintalo el servidor web instalado previamente en la unidad 1, 
# a partir de ahora va a estar en un contenedor de Docker.
sudo apt-get remove --purge apache2 -y; 
sudo apt autoremove -y;

# Directorio para los archivos de la base de datos MySQL. El servidor de la base de datos 
# es instalado mediante una imagen de Docker. Esto está definido en el archivo
# docker-compose.yml
sudo mkdir -p /var/db/mysql

# Muevo el archivo de configuración de firewall al lugar correspondiente
sudo mv -f /tmp/ufw /etc/default/ufw

# Configuración applicación
# ruta raíz del servidor web
APACHE_ROOT="/var/www";
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-devops-app/";

# descargo la app del repositorio
cd $APACHE_ROOT;
sudo git clone https://github.com/Fichen/utn-devops-app.git;
cd $APP_PATH;
sudo git checkout unidad-2;

######## Instalacion de DOCKER ########
#
# Esta instalación de docker es para demostrar el aprovisionamiento 
# complejo mediante Vagrant. La herramienta Vagrant por si misma permite 
# un aprovisionamiento de container mediante el archivo Vagrantfile. A fines 
# del ejemplo que se desea mostrar en esta unidad que es la instalación mediante paquetes del
# software Docker este ejemplo es suficiente, para un uso más avanzado de Vagrant
# se puede consultar la documentación oficial en https://www.vagrantup.com
#

#Instalamos paquetes adicionales 
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common ;

##Configuramos el repositorio
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" > /tmp/docker_gpg;
sudo apt-key add < /tmp/docker_gpg && sudo rm -f /tmp/docker_gpg;
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable";

#Actualizo los paquetes con los nuevos repositorios
sudo apt-get update -y ;

#Instalo docker desde el repositorio oficial
sudo apt-get install -y docker-ce docker-compose

#Lo configuro para que inicie en el arranque
sudo systemctl enable docker


