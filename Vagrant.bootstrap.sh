#!/bin/bash

#Aprovisionamiento de software

#Actualizo los paquetes de la maquina virtual
sudo apt-get update -y ;

#Desintalo el servidor web, a partir de ahora va a estar en un contenedor de Docker
sudo apt-get remove --purge apache2 -y; 
sudo apt autoremove -y;

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
sudo apt-get install -y docker-ce;

#Lo configuro para que inicie en el arranque
sudo systemctl enable docker

