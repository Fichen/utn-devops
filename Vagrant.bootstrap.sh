#!/bin/bash

#Aprovisionamiento de software

#Actualizo los paquetes de la maquina virtual
sudo apt-get update -y ;

# Directorio para los archivos de la base de datos MySQL. El servidor de la base de datos 
# es instalado mediante una imagen de Docker. Esto está definido en el archivo
# docker-compose.yml
sudo mkdir -p /var/db/mysql

# Directorio para scripts
sudo mkdir /scripts
# Muevo scripts para el inicio y la detención de los contenedores de Docker
sudo mv -f /tmp/docker-stop.sh /scripts
sudo mv -f /tmp/docker-start.sh /scripts
sudo chmod 755 /scripts/*
sudo dos2unix /scripts/docker-start.sh
sudo dos2unix /scripts/docker-stop.sh

# Muevo el archivo de configuración de firewall al lugar correspondiente
sudo mv -f /tmp/ufw /etc/default/ufw
# Muevo el archivo hosts. En este archivo esta asociado el nombre de dominio con una dirección
# ip para que funcione las configuraciones de Puppet
sudo mv -f /tmp/etc_hosts.txt /etc/hosts

## Configuración applicación
# ruta raíz 
APP_ROOT="/var/www";
#ruta aplicación
APP_PATH=$APP_PATH . "/utn-devops-app";

# descargo la app del repositorio
cd $APP_ROOT;
sudo git clone https://github.com/Fichen/utn-devops-app.git;
cd $APP_PATH;
sudo git checkout unidad-2;


###### Instalación de Puppet ######
#configuración de repositorio
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
sudo dpkg -i puppet5-release-xenial.deb
sudo apt update

# Instalación de master
sudo apt-get install -y puppet-lint puppetmaster

# Instalación de agente. Esto se debiera hacer en otro equipo pero se realiza aquí para simplificar
# el ejemplo
sudo apt-get install -y puppet 

# Muevo el archivo de configuración de Puppet al lugar correspondiente
sudo mv -f /tmp/puppet-master.conf /etc/puppet/puppet.conf

# elimino certificados de que se generan en la instalación.
# no nos sirven ya que el certificado depende del nombre que se asigne al maestro
# y en este ejemplo se modifico.
sudo rm -rf /var/lib/puppet/ssl

# Agrego el usuario puppet al grupo de sudo, para no necesitar password al reiniciar un servicio
sudo usermod -a -G sudo,puppet puppet

# Estructura de directorios para crear el modulo de Puppet
sudo mkdir -p /etc/puppet/modules/docker_install/manifests
sudo mkdir /etc/puppet/modules/docker_install/files

# muevo los archivos que utiliza Puppet
sudo mv -f /tmp/site.pp /etc/puppet/manifests/
sudo mv -f /tmp/init.pp /etc/puppet/modules/docker_install/manifests/init.pp
sudo mv -f /tmp/.env /etc/puppet/modules/docker_install/files

# al detener e iniciar el servicio se regeneran los certificados 
sudo service puppetmaster stop && service puppetmaster start

# limpieza de configuración del dominio utn-devops.localhost es nuestro nodo agente.
# en nuestro caso es la misma máquina
sudo puppet node clean utn-devops

# Para este nodo lanzo una petición a Puppet Master para que acepte las peticiones del agente que
# acabamos de instalar, recalco de nuevo que en este caso es el mismo equipo, pero es necesario ejecutarlo.
# El master realizará una serie de configuraciones para aceptar el agente que realizó la petición. Esto 
# se realiza por seguridad.
# Este comando en otro tipo de configuración se debería ejecutar en el nodo que contiene solamente el Puppet agente

# Primero habilito el agente
#sudo puppet agent --certname utn-devops --enable
# Lanzo una prueba de conexión del agente al maestro
#sudo puppet agent --certname utn-devops --verbose --server utn-devops.localhost --waitforcert 60 --test


# Esta llamada se debería ejecutar en el master. Se utiliza para generar los certificados
# de seguridad con el nodo agente
#sudo puppet cert sign utn-devops

# Ejecuto una segunda llamada para que se ejecuten todas las directivas 
#sudo puppet agent --certname utn-devops --verbose --server utn-devops.localhost --waitforcert 60 --test

#### FIN PUPPET ####

### Inicio Docker ###
sudo cd /vagrant/docker/

# Build de la imagen web
sudo docker build -t apache2_php .

# Build de la imagen MySQL
sudo docker build -f"Dockerfile_mysql" -t mysql .
	
sudo /scripts/docker-start.sh
#Instalar la app. Obtener el id del container y ejecutar dentro del contenedor
#sh /tmp/config_app.sh

	
#MySQL
#mysql -uroot -proot devops_app < /tmp/script.sql

