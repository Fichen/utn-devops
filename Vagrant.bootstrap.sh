#!/bin/bash

#Aprovisionamiento de software

#Actualizo los paquetes de la maquina virtual
sudo apt-get update -y ;

# Directorio para los archivos de la base de datos MySQL. El servidor de la base de datos 
# es instalado mediante una imagen de Docker. Esto está definido en el archivo
# docker-compose.yml
sudo mkdir -p /var/db/mysql

# Muevo el archivo de configuración de firewall al lugar correspondiente
sudo mv -f /tmp/ufw /etc/default/ufw

## Configuración applicación
# ruta raíz del servidor web
APACHE_ROOT="/var/www";
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-devops-app/";

# descargo la app del repositorio
cd $APACHE_ROOT;
sudo git clone https://github.com/Fichen/utn-devops-app.git;
cd $APP_PATH;
sudo git checkout unidad-2;

## Instalación de Puppet
#configuración de repositorio
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
sudo dpkg -i puppet5-release-xenial.deb
sudo apt update

#instalación de master y agentes
sudo apt-get install -y puppet-lint puppetmaster

# Muevo el archivo de configuración de Puppet al lugar correspondiente
sudo mv -f /tmp/puppet.conf /etc/puppet/puppet.conf

## Comandos de limpieza de configuración. el dominio utn-devops.localhost es nuestro nodo agente.
# en nuestro caso es la misma máquina
sudo puppet node clean utn-devops.localhost
# elimino certificados del cliente
sudo rm -rf /var/lib/puppet/ssl


# Para este nodo lanzo una petición a Puppet Master para que acepte las peticiones del agente que
# acabamos de instalar, recalco de nuevo que en este caso es el mismo equipo, pero es necesario ejecutarlo.
# El master realizará una serie de configuraciones para aceptar el agente que realizó la petición. Esto 
# se realiza por seguridad.
# Este comando en otro tipo de configuración se debería ejecutar en el nodo que contiene solamente el Puppet agente
sudo puppet agent --verbose --debug --server utn-devops.localhost --waitforcert 60

# Esta llamada se debería ejecutar en el master. Se utiliza para generar los certificados
# de seguridad con el nodo agente
sudo puppet cert sign utn-devops.localhost



